"""Runs solutions in languages other than Python through one driver protocol.

Each language module turns (code, entry point, signature) into a `Program`: source files, an optional compile
command and a run command. The program reads a nonce line and then a JSON list of argument lists on stdin, calls the
solution once per test, and prints `<nonce><report><nonce>` last on stdout. The report is a list with
`{"value": <json>}` or `{"error": "..."}` per test, or `{"error": "..."}` if the solution couldn't be loaded.
The nonce means nothing the solution prints can pass for a report. Comparison with expected values happens here.

Debuggable languages also have a tracer `Program`: it reads the nonce line and then the trace spec as JSON (args,
conditions, optional eval) and prints `<nonce><report><nonce>`, where the report has the same shape tracer.py's has.
"""
import json
import math
import os
import secrets
import tempfile
from dataclasses import dataclass, field

from sandbox import MB, Limits, describe_exit, run

# Language-neutral types a problem signature may use (see server/src/languages.ts).
TYPES = {"int", "double", "bool", "string", "int[]", "double[]", "bool[]", "string[]", "int[][]"}
MAX_REPR = 500
MAX_COMPILE_OUTPUT = 3000


@dataclass
class Program:
    files: dict[str, str]
    run: list[str]
    run_limits: Limits
    compile: list[str] | None = None
    compile_limits: Limits | None = None
    env: dict[str, str] = field(default_factory=dict)


class UnsupportedSignature(ValueError):
    pass


GDB_TRACER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "gdb_tracer.py")
# gdb plus the traced program; tracing is far slower than running, hence the larger budget.
GDB_LIMITS = Limits(cpu=10, wall=10, memory=1024 * MB, fsize=8 * MB, nofile=64)


def gdb_program(files, compile, compile_limits, source, breakpoint, cxx):
    """A tracer Program that runs the compiled test driver (`./main`) under gdb_tracer.py."""
    return Program(
        files=files,
        compile=compile,
        compile_limits=compile_limits,
        run=["gdb", "-batch", "-nx", "-q", "-x", GDB_TRACER, "./main"],
        run_limits=GDB_LIMITS,
        env={"LB_SOURCE": source, "LB_BREAK": breakpoint, "LB_CXX": "1" if cxx else "0"},
    )


def matches(actual, expected):
    if isinstance(actual, bool) or isinstance(expected, bool):
        return type(actual) is type(expected) and actual == expected
    if isinstance(actual, (int, float)) and isinstance(expected, (int, float)):
        if isinstance(actual, int) and isinstance(expected, int):
            return actual == expected
        return math.isclose(actual, expected, rel_tol=1e-6, abs_tol=1e-6)
    if isinstance(actual, list) and isinstance(expected, list):
        return len(actual) == len(expected) and all(map(matches, actual, expected))
    if isinstance(actual, dict) and isinstance(expected, dict):
        return actual.keys() == expected.keys() and all(matches(actual[k], expected[k]) for k in expected)
    return actual == expected


def short(value):
    text = json.dumps(value)
    return text if len(text) <= MAX_REPR else text[:MAX_REPR] + "..."


def tidy(output, workdir):
    """Compiler output without the temp directory path, truncated."""
    text = output.replace(workdir + os.sep, "").replace(workdir, "").strip()
    return text if len(text) <= MAX_COMPILE_OUTPUT else text[:MAX_COMPILE_OUTPUT] + "\n..."


def extract_report(stdout, nonce):
    end = stdout.rfind(nonce)
    start = stdout.rfind(nonce, 0, end) if end > 0 else -1
    if start == -1:
        return None
    try:
        return json.loads(stdout[start + len(nonce) : end])
    except json.JSONDecodeError:
        return None


def run_tests(build, code, entry_point, signature, tests):
    """Compiles (if needed) and runs a solution; returns {status, error?, results} like the Python harness."""
    try:
        program = build(code, entry_point, signature)
    except UnsupportedSignature as exc:
        return {"status": "error", "error": str(exc), "results": []}

    with tempfile.TemporaryDirectory() as workdir:
        for name, content in program.files.items():
            with open(os.path.join(workdir, name), "w", encoding="utf-8") as f:
                f.write(content)

        if program.compile:
            compiled = run(program.compile, cwd=workdir, limits=program.compile_limits, env=program.env)
            if compiled.timed_out:
                return {"status": "error", "error": "Compilation timed out", "results": []}
            if compiled.returncode != 0:
                return {"status": "error", "error": tidy(compiled.output, workdir) or "Compilation failed", "results": []}

        nonce = secrets.token_hex(16)
        stdout_path = os.path.join(workdir, ".stdout")
        stderr_path = os.path.join(workdir, ".stderr")
        outcome = run(
            program.run,
            cwd=workdir,
            limits=program.run_limits,
            env=program.env,
            stdin_text=nonce + "\n" + json.dumps([t["args"] for t in tests]),
            stdout_path=stdout_path,
            stderr_path=stderr_path,
        )
        if outcome.timed_out:
            return {"status": "timeout", "results": []}
        with open(stdout_path, encoding="utf-8", errors="replace") as f:
            report = extract_report(f.read(), nonce)
        if report is None:
            with open(stderr_path, encoding="utf-8", errors="replace") as f:
                stderr = tidy(f.read()[-2000:], workdir)
            message = describe_exit(outcome.returncode) if outcome.returncode != 0 else "The program produced no report"
            return {"status": "error", "error": f"{message}\n{stderr}".strip(), "results": []}

    if isinstance(report, dict):
        return {"status": "error", "error": str(report.get("error", "Could not load the solution"))[:2000], "results": []}
    if not isinstance(report, list) or len(report) != len(tests):
        return {"status": "error", "error": "test driver produced an incomplete report", "results": []}

    results = []
    for test, item in zip(tests, report):
        if isinstance(item, dict) and "value" in item:
            results.append({"passed": matches(item["value"], test["expected"]), "actual": short(item["value"])})
        else:
            error = item.get("error") if isinstance(item, dict) else None
            results.append({"passed": False, "error": str(error or "no result")[:MAX_REPR]})
    return {"status": "ok", "results": results}


def trace(build, code, entry_point, signature, spec):
    """Compiles (if needed) and traces one call; returns {status, error?, steps, ...} like tracer.py."""
    try:
        program = build(code, entry_point, signature)
    except UnsupportedSignature as exc:
        return {"status": "error", "error": str(exc), "steps": []}

    with tempfile.TemporaryDirectory() as workdir:
        for name, content in program.files.items():
            with open(os.path.join(workdir, name), "w", encoding="utf-8") as f:
                f.write(content)

        if program.compile:
            compiled = run(program.compile, cwd=workdir, limits=program.compile_limits, env=program.env)
            if compiled.timed_out:
                return {"status": "error", "error": "Compilation timed out", "steps": []}
            if compiled.returncode != 0:
                return {"status": "error", "error": tidy(compiled.output, workdir) or "Compilation failed", "steps": []}

        nonce = secrets.token_hex(16)
        stdout_path = os.path.join(workdir, ".stdout")
        stderr_path = os.path.join(workdir, ".stderr")
        outcome = run(
            program.run,
            cwd=workdir,
            limits=program.run_limits,
            env=program.env,
            stdin_text=nonce + "\n" + json.dumps(spec),
            stdout_path=stdout_path,
            stderr_path=stderr_path,
        )
        if outcome.timed_out:
            return {"status": "timeout", "steps": []}
        with open(stdout_path, encoding="utf-8", errors="replace") as f:
            report = extract_report(f.read(), nonce)
        if not isinstance(report, dict):
            with open(stderr_path, encoding="utf-8", errors="replace") as f:
                stderr = tidy(f.read()[-2000:], workdir)
            message = describe_exit(outcome.returncode) if outcome.returncode != 0 else "The tracer produced no report"
            return {"status": "error", "error": f"{message}\n{stderr}".strip(), "steps": []}
    return {"status": "ok", **report}


def _registry():
    from . import c, cpp, java, node

    builders = {
        "javascript": node.build_javascript,
        "typescript": node.build_typescript,
        "java": java.build,
        "cpp": cpp.build,
        "c": c.build,
    }
    tracers = {
        "javascript": node.trace_javascript,
        "typescript": node.trace_typescript,
        "java": java.trace,
        "cpp": cpp.trace,
        "c": c.trace,
    }
    return builders, tracers


BUILDERS, TRACERS = _registry()
# Statically typed languages need the signature to convert JSON arguments into native values.
NEEDS_SIGNATURE = {"java", "cpp", "c"}
LANGUAGES = {"python", *BUILDERS}
DEBUGGABLE = {"python", *TRACERS}
