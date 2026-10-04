import os

from sandbox import MB, Limits

from . import Program

HERE = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(HERE, "Json.java"), encoding="utf-8") as f:
    JSON_HELPER = f.read()

# JSON value -> native argument, per neutral type.
CONVERT = {
    "int": "Json.toInt",
    "double": "Json.toDouble",
    "bool": "Json.toBool",
    "string": "Json.toStr",
    "int[]": "Json.toIntArray",
    "double[]": "Json.toDoubleArray",
    "bool[]": "Json.toBoolArray",
    "string[]": "Json.toStrArray",
    "int[][]": "Json.toIntMatrix",
}

JVM_FLAGS = ["-XX:+UseSerialGC", "-XX:TieredStopAtLevel=1", "-XX:-UsePerfData", "-Xshare:auto"]
# The JVM reserves a large address space up front, so memory is bounded by -Xmx and the container instead.
COMPILE_LIMITS = Limits(cpu=30, wall=20, fsize=16 * MB, nofile=512)
RUN_LIMITS = Limits(cpu=15, wall=10, fsize=4 * MB, nofile=256)

MAIN = """import java.io.*;
import java.util.*;

public class Main {{
    public static void main(String[] argv) throws Exception {{
        BufferedReader in = new BufferedReader(new InputStreamReader(System.in, "UTF-8"));
        String nonce = in.readLine();
        StringBuilder text = new StringBuilder();
        char[] buf = new char[8192];
        for (int n; (n = in.read(buf)) > 0; ) text.append(buf, 0, n);
        List<Object> tests = Json.list(Json.parse(text.toString()));
        StringBuilder out = new StringBuilder("[");
        for (int t = 0; t < tests.size(); t++) {{
            List<Object> args = Json.list(tests.get(t));
            if (t > 0) out.append(',');
            try {{
                Object result = new Solution().{entry}({args});
                out.append("{{\\"value\\":").append(Json.write(result)).append('}}');
            }} catch (Throwable e) {{
                out.append("{{\\"error\\":").append(Json.quote(e.toString())).append('}}');
            }}
        }}
        out.append(']');
        System.out.flush();
        System.out.print("\\n" + nonce + out + nonce + "\\n");
        System.out.flush();
    }}
}}
"""


def build(code, entry_point, signature):
    args = ", ".join(f"{CONVERT[p['type']]}(args.get({i}))" for i, p in enumerate(signature["params"]))
    return Program(
        files={"Main.java": MAIN.format(entry=entry_point, args=args), "Json.java": JSON_HELPER, "Solution.java": code},
        compile=[
            "javac",
            *(f"-J{flag}" for flag in JVM_FLAGS),
            "-J-Xmx512m",
            "-encoding", "UTF-8",
            "-nowarn",
            "-Xmaxerrs", "20",
            "-d", ".",
            "Solution.java", "Main.java", "Json.java",
        ],
        compile_limits=COMPILE_LIMITS,
        run=["java", *JVM_FLAGS, "-Xmx256m", "-Xss64m", "-cp", ".", "Main"],
        run_limits=RUN_LIMITS,
    )
