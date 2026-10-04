"""Runs one command in a resource-limited subprocess (defence in depth; the container is the real sandbox)."""
import os
import resource
import signal
import subprocess
from dataclasses import dataclass

MB = 1024 * 1024
PATH = "/usr/local/bin:/usr/bin:/bin"


@dataclass(frozen=True)
class Limits:
    cpu: int  # CPU seconds (all threads)
    wall: float  # wall-clock seconds
    memory: int | None = None  # address space; None for runtimes that reserve huge virtual ranges (JVM, V8)
    fsize: int = 4 * MB  # largest file the process may write, which also caps redirected stdout
    nofile: int = 64


@dataclass
class Outcome:
    returncode: int | None
    output: str  # combined stdout+stderr when not redirected to a file
    timed_out: bool


def _apply(limits):
    def preexec():
        # Hard limit a second later so the soft limit delivers SIGXCPU (reported as a timeout), not SIGKILL.
        resource.setrlimit(resource.RLIMIT_CPU, (limits.cpu, limits.cpu + 1))
        if limits.memory:
            resource.setrlimit(resource.RLIMIT_AS, (limits.memory, limits.memory))
        resource.setrlimit(resource.RLIMIT_FSIZE, (limits.fsize, limits.fsize))
        resource.setrlimit(resource.RLIMIT_NOFILE, (limits.nofile, limits.nofile))
        os.setsid()

    return preexec


def run(cmd, *, cwd, limits, env=None, stdin_text=None, stdout_path=None, stderr_path=None, max_output=64 * 1024):
    """Runs `cmd`; stdout/stderr go to files when paths are given (so a chatty program can't exhaust memory)."""
    stdout = open(stdout_path, "wb") if stdout_path else subprocess.PIPE
    stderr = open(stderr_path, "wb") if stderr_path else (subprocess.STDOUT if not stdout_path else subprocess.DEVNULL)
    try:
        proc = subprocess.Popen(
            cmd,
            cwd=cwd,
            stdin=subprocess.PIPE,
            stdout=stdout,
            stderr=stderr,
            env={"PATH": PATH, "HOME": cwd, "TMPDIR": cwd, "LANG": "C.UTF-8", **(env or {})},
            preexec_fn=_apply(limits),
        )
        timed_out = False
        try:
            out, _ = proc.communicate((stdin_text or "").encode(), timeout=limits.wall)
        except subprocess.TimeoutExpired:
            timed_out = True
            out = b""
        finally:
            # Each run gets its own session; kill the whole group so forked children can't linger.
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            proc.wait()
    finally:
        for f in (stdout, stderr):
            if hasattr(f, "close"):
                f.close()
    # Hitting the CPU rlimit is a time limit too, it just arrives before the wall-clock one.
    timed_out = timed_out or proc.returncode == -signal.SIGXCPU
    return Outcome(proc.returncode, (out or b"")[:max_output].decode(errors="replace"), timed_out)


SIGNAL_MESSAGES = {
    signal.SIGSEGV: "Runtime error: segmentation fault (invalid memory access or stack overflow)",
    signal.SIGFPE: "Runtime error: floating point exception (e.g. division by zero)",
    signal.SIGABRT: "Runtime error: aborted",
    signal.SIGBUS: "Runtime error: bus error",
    signal.SIGXFSZ: "Output limit exceeded",
    signal.SIGKILL: "Runtime error: killed (most likely out of memory)",
}


def describe_exit(returncode):
    if returncode is not None and returncode < 0:
        return SIGNAL_MESSAGES.get(-returncode, f"Runtime error: killed by signal {-returncode}")
    return f"Runtime error: process exited with code {returncode}"
