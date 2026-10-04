import os

from sandbox import MB, Limits

from . import Program

PRELUDE_DIR = os.path.dirname(os.path.abspath(__file__))
# Must match the flags the Dockerfile uses to precompile cpp_prelude.hpp, or GCC silently ignores the PCH.
CXXFLAGS = ["-std=gnu++17", "-O1"]

NATIVE = {
    "int": "int",
    "double": "double",
    "bool": "bool",
    "string": "std::string",
    "int[]": "std::vector<int>",
    "double[]": "std::vector<double>",
    "bool[]": "std::vector<bool>",
    "string[]": "std::vector<std::string>",
    "int[][]": "std::vector<std::vector<int>>",
}

COMPILE_LIMITS = Limits(cpu=30, wall=20, fsize=64 * MB, nofile=128)
RUN_LIMITS = Limits(cpu=5, wall=5, memory=512 * MB, fsize=4 * MB, nofile=32)

DRIVER = """
int main() {{
    std::string nonce;
    std::getline(std::cin, nonce);
    std::string text((std::istreambuf_iterator<char>(std::cin)), std::istreambuf_iterator<char>());
    nlohmann::json tests = nlohmann::json::parse(text);
    nlohmann::json out = nlohmann::json::array();
    for (auto& args : tests) {{
        nlohmann::json item;
        try {{
{locals}
            Solution solution;
            item["value"] = solution.{entry}({call});
        }} catch (const std::exception& e) {{
            item["error"] = std::string("exception: ") + e.what();
        }} catch (...) {{
            item["error"] = "unknown exception";
        }}
        out.push_back(item);
    }}
    std::cout.flush();
    std::cout << "\\n" << nonce << out.dump() << nonce << "\\n";
    std::cout.flush();
    return 0;
}}
"""


def build(code, entry_point, signature):
    params = signature["params"]
    locals_ = "\n".join(
        f"            {NATIVE[p['type']]} a{i} = args.at({i}).get<{NATIVE[p['type']]}>();" for i, p in enumerate(params)
    )
    driver = DRIVER.format(locals=locals_, entry=entry_point, call=", ".join(f"a{i}" for i in range(len(params))))
    source = f'#include "cpp_prelude.hpp"\n#line 1 "solution.cpp"\n{code}\n#line 1 "driver.cpp"\n{driver}'
    return Program(
        files={"main.cpp": source},
        compile=["g++", *CXXFLAGS, "-fmax-errors=20", "-I", PRELUDE_DIR, "main.cpp", "-o", "main"],
        compile_limits=COMPILE_LIMITS,
        run=["./main"],
        run_limits=RUN_LIMITS,
    )
