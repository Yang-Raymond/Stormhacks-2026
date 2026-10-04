"""Tracer for C and C++ solutions, run inside gdb: `gdb -batch -nx -x gdb_tracer.py ./main`.

Produces the same report as tracer.py (trace and eval modes); see languages/__init__.py for the trace protocol.
The program is the normal test driver built with debug info, run on one test case; gdb single-steps by source line
through the solution file only. The environment names the breakpoint (LB_BREAK), the solution file (LB_SOURCE) and
whether C++ exceptions should be caught (LB_CXX).
"""
import json
import os
import re
import secrets
import sys

import gdb

MAX_STEPS = 2000
MAX_REPR = 200
MAX_VARS = 50
MAX_FRAMES = 20
MAX_ELEMENTS = 50
MAX_STDOUT = 20_000
MAX_REPORT_CHARS = 3_000_000
SIGNALS = {
    "SIGSEGV": "Segmentation fault (invalid memory access or stack overflow)",
    "SIGFPE": "Floating point exception (e.g. division by zero)",
    "SIGABRT": "Aborted",
    "SIGBUS": "Bus error",
}

SOURCE = os.environ["LB_SOURCE"]
CXX = os.environ.get("LB_CXX") == "1"

lines = sys.stdin.read().split("\n", 1)
nonce, spec = lines[0], json.loads(lines[1])
eval_spec = spec.get("eval")
conditions = {c["line"]: c["expr"] for c in spec.get("conditions") or []}
steps = []
budget = [MAX_REPORT_CHARS]
stop_events = []
gdb.events.stop.connect(stop_events.append)


def stdout_text():
    try:
        with open(".out", encoding="utf-8", errors="replace") as f:
            return f.read(MAX_STDOUT)
    except OSError:
        return ""


def finish(payload):
    payload.setdefault("stdout", stdout_text())
    sys.stdout.write("\n" + nonce + json.dumps(payload) + nonce + "\n")
    sys.stdout.flush()
    # Exit straight away: the inferior is killed with gdb's process group, and must not resume.
    os._exit(0)


def clip(text):
    return text if len(text) <= MAX_REPR else text[:MAX_REPR] + "..."


def show(value, sizes=None, name=None):
    """A gdb value as text; a pointer with a matching `<name>Size` variable (LeetCode's C convention) as an array."""
    try:
        kind = value.type.strip_typedefs()
        if sizes and name and kind.code == gdb.TYPE_CODE_PTR and f"{name}Size" in sizes:
            target = kind.target().strip_typedefs()
            if target.code not in (gdb.TYPE_CODE_INT,) or target.sizeof != 1:  # char* is a string, not an array
                n = max(0, min(int(sizes[f"{name}Size"]), MAX_ELEMENTS))
                cols = sizes.get(f"{name}ColSize")
                items = []
                for k in range(n):
                    item = value[k]
                    if cols is not None and target.code == gdb.TYPE_CODE_PTR:
                        width = max(0, min(int(cols[k]), MAX_ELEMENTS))
                        items.append("{" + ", ".join(str(item[j]) for j in range(width)) + "}")
                    else:
                        items.append(str(item))
                more = ", ..." if int(sizes[f"{name}Size"]) > n else ""
                return clip("{" + ", ".join(items) + more + "}")
        text = str(value)
    except gdb.error as exc:
        text = f"<{exc}>"
    # libstdc++ printers lead with e.g. "std::vector of length 3, capacity 3 = {...}"; keep just the contents.
    return clip(re.sub(r"^std::\S.*? = (?=[{\[])", "", text))


def solution_frames():
    frames = []
    frame = gdb.newest_frame()
    while frame is not None:
        sal = frame.find_sal()
        if sal.symtab is not None and os.path.basename(sal.symtab.filename) == SOURCE:
            frames.append(frame)
        frame = frame.older()
    return frames


def frame_values(frame):
    """(name, gdb.Value) for the variables in scope, innermost block first so shadowing variables win."""
    line = frame.find_sal().line
    found = {}
    try:
        block = frame.block()
    except RuntimeError:
        return found
    while block is not None:
        for sym in block:
            if not (sym.is_argument or sym.is_variable) or sym.name in found:
                continue
            # Skip variables declared further down the block; they hold garbage until reached.
            if not sym.is_argument and sym.line > line:
                continue
            try:
                found[sym.name] = sym.value(frame)
            except (gdb.error, RuntimeError):
                pass
        if block.function is not None:
            break
        block = block.superblock
    return found


def snapshot_locals(frame):
    values = frame_values(frame)
    sizes = {name: v for name, v in values.items() if name.endswith("Size") or name.endswith("ColSize")}
    return {name: show(v, sizes, name) for name, v in list(values.items())[:MAX_VARS]}


def frame_name(frame):
    return frame.name() or "??"


def evaluate(frame, expr):
    try:
        frame.select()
        return {"value": show(gdb.parse_and_eval(expr))}
    except (gdb.error, RuntimeError) as exc:
        return {"error": str(exc)[:2000]}


def record(frames, event, **extra):
    index = len(steps)
    if eval_spec is not None and index == eval_spec["step"]:
        if eval_spec["frame"] >= len(frames):
            finish({"error": "frame no longer exists at this step"})
        target = frames[eval_spec["frame"]]
        finish({"values": [evaluate(target, e) for e in eval_spec["expressions"]]})

    line = frames[0].find_sal().line
    step = {"line": line, "event": event, "depth": len(frames), "out": os.path.getsize(".out"), **extra}
    if event == "line" and line in conditions:
        outcome = evaluate(frames[0], conditions[line])
        try:
            step["cond"] = "error" in outcome or bool(gdb.parse_and_eval(f"({conditions[line]}) != 0"))
        except (gdb.error, RuntimeError):
            step["cond"] = True
        if "error" in outcome:
            step["condError"] = outcome["error"]
    if eval_spec is None:
        step["frames"] = [
            {"name": frame_name(f), "line": f.find_sal().line, "locals": snapshot_locals(f)} for f in frames[:MAX_FRAMES]
        ]
        budget[0] -= len(json.dumps(step))
        if budget[0] < 0:
            finish({"steps": steps, "truncated": True})
    steps.append(step)
    if len(steps) >= MAX_STEPS and eval_spec is None:
        finish({"steps": steps, "truncated": True})


def add_return():
    """The previous line's call returned: repeat that step as a return event, like Python's tracer reports."""
    if eval_spec is not None and len(steps) == eval_spec["step"]:
        finish({"error": "the function has already returned at this step"})
    last = {k: v for k, v in steps[-1].items() if k not in ("exception", "cond", "condError")}
    steps.append({**last, "event": "return"})
    if len(steps) >= MAX_STEPS and eval_spec is None:
        finish({"steps": steps, "truncated": True})


def driver_report(run_nonce):
    """The test driver's own report for the single test: the solution's return value or error."""
    with open(".out", encoding="utf-8", errors="replace") as f:
        text = f.read()
    end = text.rfind(run_nonce)
    start = text.rfind(run_nonce, 0, end) if end > 0 else -1
    if start == -1:
        return {}
    try:
        [item] = json.loads(text[start + len(run_nonce) : end])
    except (ValueError, TypeError):
        return {}
    if "value" in item:
        return {"result": clip(json.dumps(item["value"]))}
    return {"error": str(item.get("error", "no result"))[:2000]}


def command(cmd):
    stop_events.clear()
    gdb.execute(cmd, to_string=True)
    return stop_events[-1] if stop_events else None


def alive():
    return gdb.selected_inferior().pid != 0


def main():
    for setting in ("pagination off", "confirm off", "disable-randomization off", "print elements 50", "width 0"):
        gdb.execute(f"set {setting}", to_string=True)
    # Never step into system headers or the driver; `finish` covers anything else outside the solution.
    for depth in range(6):
        gdb.execute("skip -gfi /usr/" + "*/" * depth + "*", to_string=True)
    gdb.execute("skip -gfi driver.c*", to_string=True)
    gdb.execute(f"break {os.environ['LB_BREAK']}", to_string=True)
    if CXX:
        gdb.execute("catch throw", to_string=True)
        gdb.execute("catch catch", to_string=True)

    run_nonce = secrets.token_hex(16)
    with open(".in", "w", encoding="utf-8") as f:
        f.write(run_nonce + "\n" + json.dumps([spec["args"]]))
    open(".out", "w").close()
    event = command("run < .in > .out 2> .err")

    while alive():
        if isinstance(event, gdb.SignalEvent):
            frames = solution_frames()
            if frames:
                record(frames, "exception", exception=SIGNALS.get(event.stop_signal, event.stop_signal))
            break
        frames = solution_frames()
        if steps and len(frames) < steps[-1]["depth"]:
            add_return()
        if not frames:
            if steps:
                break  # back in the driver: the call is over
            event = command("continue")
            continue
        top = gdb.newest_frame()
        if frames[0] != top:
            if CXX and isinstance(event, gdb.BreakpointEvent) and "__cxa_throw" in frame_name(top):
                record(frames, "exception", exception="C++ exception thrown")
                event = command("continue")  # to the matching `catch catch` stop, then `finish` into the handler
            else:
                event = command("finish")
            continue
        record(frames, "line")
        event = command("step")

    if eval_spec is not None:
        finish({"error": "the program finished before reaching this step"})
    if isinstance(event, gdb.SignalEvent):
        finish({"steps": steps, "truncated": False, "error": "Runtime error: " + SIGNALS.get(event.stop_signal, event.stop_signal)})
    # Let the driver print its report for the call, which carries the return value (or the error it caught).
    user_output = stdout_text()  # before the driver's report
    while alive() and not isinstance(event, gdb.SignalEvent):
        event = command("continue")
    outcome = driver_report(run_nonce)
    if steps and steps[-1]["event"] == "return" and "result" in outcome:
        steps[-1]["value"] = outcome["result"]
    finish({"steps": steps, "truncated": False, "stdout": user_output, **outcome})


try:
    main()
except Exception as exc:  # noqa: BLE001 - report tracer failures instead of an empty response
    finish({"steps": steps, "error": f"tracer failed: {exc}"})
