import os

from sandbox import MB, Limits

from . import Program

HARNESS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "node_harness.js")
NODE = "/usr/local/bin/node"
# V8 reserves far more address space than it uses, so memory is capped by the heap flag instead of RLIMIT_AS.
LIMITS = Limits(cpu=6, wall=6, fsize=4 * MB, nofile=64)


def _build(language, filename):
    def build(code, entry_point, _signature):
        return Program(
            files={filename: code},
            run=[NODE, "--max-old-space-size=256", "--stack-size=4000", HARNESS, filename, entry_point, language],
            run_limits=LIMITS,
        )

    return build


build_javascript = _build("javascript", "solution.js")
build_typescript = _build("typescript", "solution.ts")
