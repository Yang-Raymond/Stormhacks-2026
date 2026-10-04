"""Runs inside the sandboxed subprocess: executes the user's solution under a line tracer and records each step.

Two modes:
- trace: record every line/return/exception event (locals, call stack, stdout position) so the browser can
  step through the run forwards and backwards.
- eval: replay the same deterministic run up to step N and evaluate expressions in one of its frames.
  This powers watch expressions and the debug console without keeping a paused process around.
"""
import io
import json
import os
import sys
import traceback
import types

FILENAME = "solution.py"
MAX_STEPS = 2000
MAX_REPR = 200
MAX_VARS = 50
MAX_FRAMES = 20
MAX_STDOUT = 20_000
MAX_REPORT_CHARS = 3_000_000
HIDDEN_TYPES = (types.ModuleType, types.FunctionType, types.BuiltinFunctionType, type)


def short(value):
    try:
        text = repr(value)
    except Exception as exc:
        text = f"<repr failed: {type(exc).__name__}>"
    return text if len(text) <= MAX_REPR else text[:MAX_REPR] + "..."


def describe(exc):
    return "".join(traceback.format_exception_only(exc)).strip()[-2000:]


class CappedStdout(io.StringIO):
    def write(self, s):
        room = MAX_STDOUT - self.tell()
        if room > 0:
            super().write(s[:room])
        return len(s)


def solution_frames(frame):
    """User frames from innermost outwards; frames from the tracer itself are skipped."""
    frames = []
    while frame is not None:
        if frame.f_code.co_filename == FILENAME:
            frames.append(frame)
        frame = frame.f_back
    return frames


def snapshot_locals(frame):
    shown = {}
    for name, value in frame.f_locals.items():
        if name.startswith("__") or isinstance(value, HIDDEN_TYPES):
            continue
        if len(shown) >= MAX_VARS:
            break
        shown[name] = short(value)
    return shown


def main():
    spec = json.load(sys.stdin)
    # Keep a private handle for the report and send raw fd output to /dev/null so the solution can't forge it.
    report = os.fdopen(os.dup(1), "w")
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, 1)
    stdout = CappedStdout()
    sys.stdout = stdout

    conditions = {}
    for cond in spec.get("conditions") or []:
        conditions[cond["line"]] = cond["expr"]
    eval_spec = spec.get("eval")
    steps = []
    budget = [MAX_REPORT_CHARS]

    def finish(payload):
        payload.setdefault("stdout", stdout.getvalue())
        report.write(json.dumps(payload))
        report.flush()
        # Exit straight away: the solution may still be mid-loop (step limit) and must not resume.
        os._exit(0)

    def evaluate(frame, expr):
        try:
            return {"value": short(eval(expr, frame.f_globals, frame.f_locals))}
        except Exception as exc:
            return {"error": describe(exc)}

    def record(frame, event, arg):
        index = len(steps)
        frames = solution_frames(frame)
        if eval_spec is not None and index == eval_spec["step"]:
            if eval_spec["frame"] >= len(frames):
                finish({"error": "frame no longer exists at this step"})
            target = frames[eval_spec["frame"]]
            finish({"values": [evaluate(target, e) for e in eval_spec["expressions"]]})

        step = {
            "line": frame.f_lineno,
            "event": event,
            "depth": len(frames),
            "out": stdout.tell(),
            "frames": [
                {"name": f.f_code.co_name, "line": f.f_lineno, "locals": snapshot_locals(f)}
                for f in frames[:MAX_FRAMES]
            ],
        }
        if event == "return":
            step["value"] = short(arg)
        elif event == "exception":
            step["exception"] = describe(arg[1])
        if event == "line" and frame.f_lineno in conditions:
            try:
                step["cond"] = bool(eval(conditions[frame.f_lineno], frame.f_globals, frame.f_locals))
            except Exception as exc:
                # A condition that raises still pauses, as in most debuggers, so the mistake is visible.
                step["cond"] = True
                step["condError"] = describe(exc)

        if eval_spec is None:
            budget[0] -= len(json.dumps(step))
            if budget[0] < 0:
                finish({"steps": steps, "truncated": True})
        steps.append(step)
        if len(steps) >= MAX_STEPS and eval_spec is None:
            finish({"steps": steps, "truncated": True})

    def tracer(frame, event, arg):
        if frame.f_code.co_filename != FILENAME:
            return None
        if event in ("line", "return", "exception"):
            record(frame, event, arg)
        return tracer

    namespace = {"__name__": "solution"}
    try:
        exec(compile(spec["code"], FILENAME, "exec"), namespace)
        func = namespace[spec["entry_point"]]
    except Exception as exc:
        finish({"steps": [], "error": describe(exc)})

    outcome = {}
    sys.settrace(tracer)
    try:
        outcome["result"] = short(func(*spec["args"]))
    except (Exception, SystemExit) as exc:
        outcome["error"] = describe(exc)
    finally:
        sys.settrace(None)

    if eval_spec is not None:
        finish({"error": "the program finished before reaching this step"})
    finish({"steps": steps, "truncated": False, **outcome})


if __name__ == "__main__":
    main()
