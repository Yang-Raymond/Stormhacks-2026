import os

from sandbox import MB, Limits

from . import Program

HERE = os.path.dirname(os.path.abspath(__file__))
HARNESS = os.path.join(HERE, "node_harness.js")
TRACER = os.path.join(HERE, "node_tracer.js")
NODE = "/usr/local/bin/node"
# V8 reserves far more address space than it uses, so memory is capped by the heap flag instead of RLIMIT_AS.
LIMITS = Limits(cpu=6, wall=6, fsize=4 * MB, nofile=64)


def _build(driver, language, filename):
    def build(code, entry_point, _signature):
        return Program(
            files={filename: code},
            run=[NODE, "--max-old-space-size=256", "--stack-size=4000", driver, filename, entry_point, language],
            run_limits=LIMITS,
        )

    return build


build_javascript = _build(HARNESS, "javascript", "solution.js")
build_typescript = _build(HARNESS, "typescript", "solution.ts")
trace_javascript = _build(TRACER, "javascript", "solution.js")
trace_typescript = _build(TRACER, "typescript", "solution.ts")
