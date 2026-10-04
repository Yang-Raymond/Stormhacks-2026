"""Runs inside the sandboxed subprocess: imports the user's solution and calls it once per argument list.

Only arguments are sent here; server.py compares the returned values with the expected ones, so the solution
can't read or forge them.
"""
import json
import os
import sys
import traceback

MAX_REPR = 500


def main():
    spec = json.load(sys.stdin)
    # Keep a private handle for the report and send anything the solution prints to /dev/null,
    # so user output can't be mistaken for (or forge) the report.
    report = os.fdopen(os.dup(1), "w")
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, 1)
    sys.stdout = open(os.devnull, "w")
    namespace = {"__name__": "solution"}
    try:
        exec(compile(spec["code"], "solution.py", "exec"), namespace)
        func = namespace[spec["entry_point"]]
    except Exception as exc:
        error = "".join(traceback.format_exception_only(exc))[-2000:]
        report.write(json.dumps({"error": error}))
        return

    results = []
    for args in spec["args"]:
        try:
            # Round-trip through JSON so tuples/lists compare like the expected JSON value.
            results.append({"value": json.loads(json.dumps(func(*args)))})
        except Exception as exc:
            results.append({"error": f"{type(exc).__name__}: {exc}"[:MAX_REPR]})
    report.write(json.dumps({"results": results}))


if __name__ == "__main__":
    main()
