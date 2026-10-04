"""Minimal HTTP service that executes untrusted Python against test cases.

Isolation here is defence in depth only (rlimits, timeout, empty env, temp dir).
Real isolation comes from the container: no network, read-only FS, non-root, cgroup limits.
"""
import json
import os
import resource
import signal
import subprocess
import sys
import tempfile
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HARNESS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "harness.py")
TIMEOUT_SECONDS = 5
MAX_BODY_BYTES = 256 * 1024
MAX_OUTPUT_BYTES = 256 * 1024
MAX_TESTS = 100


def limit_resources():
    resource.setrlimit(resource.RLIMIT_CPU, (TIMEOUT_SECONDS, TIMEOUT_SECONDS))
    resource.setrlimit(resource.RLIMIT_AS, (256 * 1024 * 1024,) * 2)
    resource.setrlimit(resource.RLIMIT_FSIZE, (1024 * 1024,) * 2)
    resource.setrlimit(resource.RLIMIT_NOFILE, (32, 32))
    os.setsid()


def run(code, entry_point, tests):
    with tempfile.TemporaryDirectory() as workdir:
        proc = subprocess.Popen(
            [sys.executable, "-I", "-S", HARNESS],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            cwd=workdir,
            env={},
            preexec_fn=limit_resources,
        )
        try:
            stdout, stderr = proc.communicate(
                json.dumps({"code": code, "entry_point": entry_point, "tests": tests}), timeout=TIMEOUT_SECONDS
            )
        except subprocess.TimeoutExpired:
            return {"status": "timeout", "results": []}
        finally:
            # The harness runs in its own session; kill the whole group so forked children can't linger.
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            proc.wait()

    try:
        report = json.loads(stdout[:MAX_OUTPUT_BYTES])
    except json.JSONDecodeError:
        stderr = stderr[-2000:] or f"process exited with code {proc.returncode}"
        return {"status": "error", "error": stderr, "results": []}

    if "error" in report:
        return {"status": "error", "error": report["error"], "results": []}
    if len(report.get("results", [])) != len(tests):
        return {"status": "error", "error": "test harness produced an incomplete report", "results": []}
    return {"status": "ok", "results": report["results"]}


def valid(payload):
    return (
        isinstance(payload, dict)
        and isinstance(payload.get("code"), str)
        and isinstance(payload.get("entry_point"), str)
        and payload["entry_point"].isidentifier()
        and isinstance(payload.get("tests"), list)
        and len(payload["tests"]) <= MAX_TESTS
        and all(isinstance(t, dict) and isinstance(t.get("args"), list) and "expected" in t for t in payload["tests"])
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
        if self.path != "/run":
            return self._send(404, {"error": "not found"})
        length = int(self.headers.get("Content-Length") or 0)
        if length <= 0 or length > MAX_BODY_BYTES:
            return self._send(413, {"error": "invalid body size"})
        try:
            payload = json.loads(self.rfile.read(length))
        except json.JSONDecodeError:
            return self._send(400, {"error": "invalid json"})
        if not valid(payload):
            return self._send(400, {"error": "expected {code, entry_point, tests:[{args, expected}]}"})
        self._send(200, run(payload["code"], payload["entry_point"], payload["tests"]))


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8000"))
    print(f"runner listening on :{port}", flush=True)
    ThreadingHTTPServer(("0.0.0.0", port), Handler).serve_forever()
