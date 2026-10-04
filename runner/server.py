"""Minimal HTTP service that executes untrusted code against test cases.

Isolation here is defence in depth only (rlimits, timeout, empty env, temp dir).
Real isolation comes from the container: no network, read-only FS, non-root, cgroup limits.
"""
import json
import os
import resource
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import traceback
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import languages

HERE = os.path.dirname(os.path.abspath(__file__))
HARNESS = os.path.join(HERE, "harness.py")
TRACER = os.path.join(HERE, "tracer.py")
TIMEOUT_SECONDS = 5
MAX_BODY_BYTES = 256 * 1024
MAX_OUTPUT_BYTES = 256 * 1024
MAX_TRACE_OUTPUT_BYTES = 4 * 1024 * 1024
MAX_TESTS = 100
MAX_EXPRESSIONS = 20
MAX_CONDITIONS = 50
MAX_EXPR_CHARS = 200


# User code runs as the same uid as this service, and a child that calls setsid() escapes the killpg cleanup.
# So jobs run one at a time, and after each one every other process of this uid is killed and scratch space wiped:
# nothing a submission leaves behind can see or tamper with the next one, or hold pids/tmpfs hostage.
JOB_LOCK = threading.Lock()
# Only in the container, where this service is PID 1; run locally, sweeping the uid would kill the developer's processes.
IN_SANDBOX = os.getpid() == 1
SCRATCH_DIRS = (tempfile.gettempdir(), "/dev/shm")


def sweep():
    if not IN_SANDBOX:
        return
    me, uid = os.getpid(), os.getuid()
    # Repeat until nothing is left, since a process may fork while we're killing.
    while True:
        killed = False
        for entry in os.listdir("/proc"):
            if not entry.isdigit() or int(entry) == me:
                continue
            try:
                if os.stat(f"/proc/{entry}").st_uid == uid:
                    os.kill(int(entry), signal.SIGKILL)
                    killed = True
            except (FileNotFoundError, ProcessLookupError, PermissionError):
                pass
        if not killed:
            break
        try:
            while os.waitpid(-1, os.WNOHANG)[0]:
                pass
        except ChildProcessError:
            pass
    for directory in SCRATCH_DIRS:
        try:
            names = os.listdir(directory)
        except OSError:
            continue
        for name in names:
            path = os.path.join(directory, name)
            if os.path.isdir(path) and not os.path.islink(path):
                shutil.rmtree(path, ignore_errors=True)
            else:
                try:
                    os.unlink(path)
                except OSError:
                    pass


def limit_resources(max_output):
    resource.setrlimit(resource.RLIMIT_CPU, (TIMEOUT_SECONDS, TIMEOUT_SECONDS))
    resource.setrlimit(resource.RLIMIT_AS, (256 * 1024 * 1024,) * 2)
    resource.setrlimit(resource.RLIMIT_FSIZE, (max_output,) * 2)
    resource.setrlimit(resource.RLIMIT_NOFILE, (32, 32))
    os.setsid()


def spawn(script, payload, max_output):
    """Runs a script in a resource-limited subprocess; returns (report dict, None) or (None, failure result)."""
    # File redirection makes RLIMIT_FSIZE effective before any output enters server memory.
    with tempfile.TemporaryDirectory() as workdir, tempfile.TemporaryFile() as stdout_file, tempfile.TemporaryFile() as stderr_file:
        proc = subprocess.Popen(
            [sys.executable, "-I", "-S", script],
            stdin=subprocess.PIPE, stdout=stdout_file, stderr=stderr_file,
            text=True, cwd=workdir, env={},
            preexec_fn=lambda: limit_resources(max_output),
        )
        try:
            proc.communicate(json.dumps(payload), timeout=TIMEOUT_SECONDS)
        except subprocess.TimeoutExpired:
            return None, {"status": "timeout"}
        finally:
            # Kill the whole session so forked children cannot linger.
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            proc.wait()
        stdout_file.seek(0)
        stdout = stdout_file.read(max_output).decode(errors="replace")
        stderr_file.seek(0, os.SEEK_END)
        stderr_file.seek(max(0, stderr_file.tell() - 2000))
        stderr = stderr_file.read(2000).decode(errors="replace")

    try:
        return json.loads(stdout[:max_output]), None
    except json.JSONDecodeError:
        # Hitting the CPU rlimit kills the process before the wall-clock timeout; report it the same way.
        if proc.returncode in (-signal.SIGXCPU, -signal.SIGKILL):
            return None, {"status": "timeout"}
        return None, {"status": "error", "error": stderr[-2000:] or f"process exited with code {proc.returncode}"}


def run(payload):
    language = payload.get("language", "python")
    code, entry_point, tests = payload["code"], payload["entry_point"], payload["tests"]
    if language != "python":
        return languages.run_tests(languages.BUILDERS[language], code, entry_point, payload.get("signature"), tests)
    args = [t["args"] for t in tests]
    report, failure = spawn(HARNESS, {"code": code, "entry_point": entry_point, "args": args}, MAX_OUTPUT_BYTES)
    if failure:
        return {**failure, "results": []}
    if "error" in report:
        return {"status": "error", "error": report["error"], "results": []}
    if len(report.get("results", [])) != len(tests):
        return {"status": "error", "error": "test harness produced an incomplete report", "results": []}
    return {"status": "ok", "results": [grade(test, item) for test, item in zip(tests, report["results"])]}


def grade(test, item):
    if isinstance(item, dict) and "value" in item:
        return {"passed": languages.matches(item["value"], test["expected"]), "actual": languages.short(item["value"])}
    error = item.get("error") if isinstance(item, dict) else None
    return {"passed": False, "error": str(error or "no result")[:languages.MAX_REPR]}


def trace(payload):
    language = payload.get("language", "python")
    if language != "python":
        spec = {k: payload[k] for k in ("args", "conditions", "eval") if k in payload}
        return languages.trace(languages.TRACERS[language], payload["code"], payload["entry_point"], payload.get("signature"), spec)
    report, failure = spawn(TRACER, payload, MAX_TRACE_OUTPUT_BYTES)
    if failure:
        return {**failure, "steps": []}
    return {"status": "ok", **report}


def valid(payload):
    return (
        isinstance(payload, dict)
        and isinstance(payload.get("code"), str)
        and isinstance(payload.get("entry_point"), str)
        and payload["entry_point"].isidentifier()
        and isinstance(payload.get("tests"), list)
        and len(payload["tests"]) <= MAX_TESTS
        and all(isinstance(t, dict) and isinstance(t.get("args"), list) and "expected" in t for t in payload["tests"])
        and payload.get("language", "python") in languages.LANGUAGES
        and (payload.get("language") not in languages.NEEDS_SIGNATURE or valid_signature(payload.get("signature")))
    )


def valid_signature(signature):
    return (
        isinstance(signature, dict)
        and isinstance(signature.get("params"), list)
        and len(signature["params"]) <= 20
        and all(isinstance(p, dict) and p.get("type") in languages.TYPES for p in signature["params"])
        and signature.get("returns") in languages.TYPES
    )


def short_str(value):
    return isinstance(value, str) and len(value) <= MAX_EXPR_CHARS


def non_negative_int(value):
    return isinstance(value, int) and not isinstance(value, bool) and value >= 0


def valid_trace(payload):
    if not (
        isinstance(payload, dict)
        and isinstance(payload.get("code"), str)
        and isinstance(payload.get("entry_point"), str)
        and payload["entry_point"].isidentifier()
        and isinstance(payload.get("args"), list)
        and payload.get("language", "python") in languages.DEBUGGABLE
        and (payload.get("language") not in languages.NEEDS_SIGNATURE or valid_signature(payload.get("signature")))
    ):
        return False
    conditions = payload.get("conditions", [])
    if not (
        isinstance(conditions, list)
        and len(conditions) <= MAX_CONDITIONS
        and all(isinstance(c, dict) and non_negative_int(c.get("line")) and short_str(c.get("expr")) for c in conditions)
    ):
        return False
    ev = payload.get("eval")
    return ev is None or (
        isinstance(ev, dict)
        and non_negative_int(ev.get("step"))
        and non_negative_int(ev.get("frame"))
        and isinstance(ev.get("expressions"), list)
        and 0 < len(ev["expressions"]) <= MAX_EXPRESSIONS
        and all(short_str(e) for e in ev["expressions"])
    )


class Handler(BaseHTTPRequestHandler):
    def _send(self, status, body):
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/health":
            self._send(200, {"ok": True})
        else:
            self._send(404, {"error": "not found"})

    def do_POST(self):
        routes = {"/run": (valid, run), "/trace": (valid_trace, trace)}
        if self.path not in routes:
            return self._send(404, {"error": "not found"})
        validator, handler = routes[self.path]
        length = int(self.headers.get("Content-Length") or 0)
        if length <= 0 or length > MAX_BODY_BYTES:
            return self._send(413, {"error": "invalid body size"})
        try:
            payload = json.loads(self.rfile.read(length))
        except json.JSONDecodeError:
            return self._send(400, {"error": "invalid json"})
        if not validator(payload):
            return self._send(400, {"error": f"invalid payload for {self.path}"})
        try:
            with JOB_LOCK:
                try:
                    result = handler(payload)
                finally:
                    sweep()
        except Exception:
            traceback.print_exc()
            return self._send(500, {"error": "the runner failed to execute this request"})
        self._send(200, result)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8000"))
    print(f"runner listening on :{port}", flush=True)
    ThreadingHTTPServer(("0.0.0.0", port), Handler).serve_forever()
