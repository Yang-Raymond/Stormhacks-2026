import os

from sandbox import MB, Limits

from . import Program

HERE = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(HERE, "Json.cs"), encoding="utf-8") as f:
    JSON_HELPER = f.read()

CONVERT = {
    "int": "Json.ToInt",
    "double": "Json.ToDouble",
    "bool": "Json.ToBool",
    "string": "Json.ToStr",
    "int[]": "Json.ToIntArray",
    "double[]": "Json.ToDoubleArray",
    "bool[]": "Json.ToBoolArray",
    "string[]": "Json.ToStrArray",
    "int[][]": "Json.ToIntMatrix",
}

# Mono reserves a large address space, so memory is bounded by the container instead of RLIMIT_AS.
COMPILE_LIMITS = Limits(cpu=30, wall=20, fsize=16 * MB, nofile=256)
RUN_LIMITS = Limits(cpu=15, wall=10, fsize=4 * MB, nofile=128)

MAIN = """using System;
using System.Collections.Generic;
using System.Text;

static class Program
{{
    static void Main()
    {{
        string nonce = Console.In.ReadLine();
        var tests = Json.List(Json.Parse(Console.In.ReadToEnd()));
        var output = new StringBuilder("[");
        for (int t = 0; t < tests.Count; t++)
        {{
            var args = Json.List(tests[t]);
            if (t > 0) output.Append(',');
            try
            {{
                object result = new Solution().{entry}({args});
                output.Append("{{\\"value\\":").Append(Json.Write(result)).Append('}}');
            }}
            catch (Exception e)
            {{
                output.Append("{{\\"error\\":").Append(Json.Quote(e.GetType().Name + ": " + e.Message)).Append('}}');
            }}
        }}
        output.Append(']');
        Console.Out.Flush();
        Console.Write("\\n" + nonce + output + nonce + "\\n");
        Console.Out.Flush();
    }}
}}
"""


def build(code, entry_point, signature):
    args = ", ".join(f"{CONVERT[p['type']]}(args[{i}])" for i, p in enumerate(signature["params"]))
    return Program(
        files={"Main.cs": MAIN.format(entry=entry_point, args=args), "Json.cs": JSON_HELPER, "Solution.cs": code},
        compile=["mcs", "-optimize+", "-nowarn:162,168,219,414", "-r:System.Core", "-out:main.exe",
                 "Solution.cs", "Main.cs", "Json.cs"],
        compile_limits=COMPILE_LIMITS,
        run=["mono", "main.exe"],
        run_limits=RUN_LIMITS,
        env={"MONO_GC_PARAMS": "max-heap-size=256m"},
    )
