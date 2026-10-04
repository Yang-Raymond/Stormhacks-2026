"""C driver. Follows LeetCode's C conventions so generated solutions look familiar:
arrays are passed as (T* x, int xSize), int[][] as (int** x, int xSize, int* xColSize), and a function returning an
array takes a trailing `int* returnSize`. Returning int[][] isn't supported in C.
"""
from sandbox import MB, Limits

from . import Program, UnsupportedSignature

COMPILE_LIMITS = Limits(cpu=20, wall=15, fsize=64 * MB, nofile=128)
RUN_LIMITS = Limits(cpu=5, wall=5, memory=512 * MB, fsize=4 * MB, nofile=32)

PRELUDE = """#include <ctype.h>
#include <limits.h>
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cjson/cJSON.h>
"""

HELPERS = r"""
static char* lb__str(cJSON* v) { return strdup(cJSON_IsString(v) ? v->valuestring : ""); }
static int* lb__ints(cJSON* v, int* size) {
    *size = cJSON_GetArraySize(v);
    int* a = malloc(sizeof(int) * (*size + 1));
    for (int k = 0; k < *size; k++) a[k] = (int)cJSON_GetArrayItem(v, k)->valuedouble;
    return a;
}
static double* lb__doubles(cJSON* v, int* size) {
    *size = cJSON_GetArraySize(v);
    double* a = malloc(sizeof(double) * (*size + 1));
    for (int k = 0; k < *size; k++) a[k] = cJSON_GetArrayItem(v, k)->valuedouble;
    return a;
}
static bool* lb__bools(cJSON* v, int* size) {
    *size = cJSON_GetArraySize(v);
    bool* a = malloc(sizeof(bool) * (*size + 1));
    for (int k = 0; k < *size; k++) a[k] = cJSON_IsTrue(cJSON_GetArrayItem(v, k));
    return a;
}
static char** lb__strs(cJSON* v, int* size) {
    *size = cJSON_GetArraySize(v);
    char** a = malloc(sizeof(char*) * (*size + 1));
    for (int k = 0; k < *size; k++) a[k] = lb__str(cJSON_GetArrayItem(v, k));
    return a;
}
static int** lb__matrix(cJSON* v, int* rows, int** cols) {
    *rows = cJSON_GetArraySize(v);
    int** a = malloc(sizeof(int*) * (*rows + 1));
    *cols = malloc(sizeof(int) * (*rows + 1));
    for (int k = 0; k < *rows; k++) a[k] = lb__ints(cJSON_GetArrayItem(v, k), &(*cols)[k]);
    return a;
}
static cJSON* lb__from_ints(const int* a, int n) {
    cJSON* out = cJSON_CreateArray();
    for (int k = 0; a && k < n; k++) cJSON_AddItemToArray(out, cJSON_CreateNumber(a[k]));
    return out;
}
static cJSON* lb__from_doubles(const double* a, int n) {
    cJSON* out = cJSON_CreateArray();
    for (int k = 0; a && k < n; k++) cJSON_AddItemToArray(out, cJSON_CreateNumber(a[k]));
    return out;
}
static cJSON* lb__from_bools(const bool* a, int n) {
    cJSON* out = cJSON_CreateArray();
    for (int k = 0; a && k < n; k++) cJSON_AddItemToArray(out, cJSON_CreateBool(a[k]));
    return out;
}
static cJSON* lb__from_strs(char** a, int n) {
    cJSON* out = cJSON_CreateArray();
    for (int k = 0; a && k < n; k++) cJSON_AddItemToArray(out, a[k] ? cJSON_CreateString(a[k]) : cJSON_CreateNull());
    return out;
}
static char* lb__read_all(FILE* f) {
    size_t cap = 1 << 16, len = 0;
    char* buf = malloc(cap);
    for (size_t n; (n = fread(buf + len, 1, cap - len - 1, f)) > 0; ) {
        len += n;
        if (cap - len < 2) buf = realloc(buf, cap *= 2);
    }
    buf[len] = 0;
    return buf;
}
"""

MAIN = r"""
int main(void) {{
    char nonce[128] = {{0}};
    if (!fgets(nonce, sizeof nonce, stdin)) return 1;
    nonce[strcspn(nonce, "\n")] = 0;
    cJSON* tests = cJSON_Parse(lb__read_all(stdin));
    cJSON* out = cJSON_CreateArray();
    for (int t = 0; t < cJSON_GetArraySize(tests); t++) {{
        cJSON* args = cJSON_GetArrayItem(tests, t);
{body}
        cJSON* item = cJSON_CreateObject();
        cJSON_AddItemToObject(item, "value", value);
        cJSON_AddItemToArray(out, item);
    }}
    fflush(stdout);
    printf("\n%s%s%s\n", nonce, cJSON_PrintUnformatted(out), nonce);
    fflush(stdout);
    return 0;
}}
"""

# type -> (declaration lines, call arguments); {i} is the parameter index.
ARGS = {
    "int": (["int a{i} = (int)cJSON_GetArrayItem(args, {i})->valuedouble;"], ["a{i}"]),
    "double": (["double a{i} = cJSON_GetArrayItem(args, {i})->valuedouble;"], ["a{i}"]),
    "bool": (["bool a{i} = cJSON_IsTrue(cJSON_GetArrayItem(args, {i}));"], ["a{i}"]),
    "string": (["char* a{i} = lb__str(cJSON_GetArrayItem(args, {i}));"], ["a{i}"]),
    "int[]": (["int a{i}Size; int* a{i} = lb__ints(cJSON_GetArrayItem(args, {i}), &a{i}Size);"], ["a{i}", "a{i}Size"]),
    "double[]": (["int a{i}Size; double* a{i} = lb__doubles(cJSON_GetArrayItem(args, {i}), &a{i}Size);"], ["a{i}", "a{i}Size"]),
    "bool[]": (["int a{i}Size; bool* a{i} = lb__bools(cJSON_GetArrayItem(args, {i}), &a{i}Size);"], ["a{i}", "a{i}Size"]),
    "string[]": (["int a{i}Size; char** a{i} = lb__strs(cJSON_GetArrayItem(args, {i}), &a{i}Size);"], ["a{i}", "a{i}Size"]),
    "int[][]": (
        ["int a{i}Size; int* a{i}ColSize; int** a{i} = lb__matrix(cJSON_GetArrayItem(args, {i}), &a{i}Size, &a{i}ColSize);"],
        ["a{i}", "a{i}Size", "a{i}ColSize"],
    ),
}

# return type -> (C result type, needs returnSize, expression turning `r` into a cJSON value)
RETURNS = {
    "int": ("int", False, "cJSON_CreateNumber(r)"),
    "double": ("double", False, "cJSON_CreateNumber(r)"),
    "bool": ("bool", False, "cJSON_CreateBool(r)"),
    "string": ("char*", False, "r ? cJSON_CreateString(r) : cJSON_CreateNull()"),
    "int[]": ("int*", True, "lb__from_ints(r, returnSize)"),
    "double[]": ("double*", True, "lb__from_doubles(r, returnSize)"),
    "bool[]": ("bool*", True, "lb__from_bools(r, returnSize)"),
    "string[]": ("char**", True, "lb__from_strs(r, returnSize)"),
}


def build(code, entry_point, signature):
    returns = signature["returns"]
    if returns not in RETURNS:
        raise UnsupportedSignature(f"C solutions can't return {returns}")
    lines, call = [], []
    for i, p in enumerate(signature["params"]):
        decl, args = ARGS[p["type"]]
        lines += [d.format(i=i) for d in decl]
        call += [a.format(i=i) for a in args]
    c_type, needs_size, to_json = RETURNS[returns]
    if needs_size:
        lines.append("int returnSize = 0;")
        call.append("&returnSize")
    lines.append(f"{c_type} r = {entry_point}({', '.join(call)});")
    lines.append(f"cJSON* value = {to_json};")
    body = "\n".join("        " + line for line in lines)
    source = f'{PRELUDE}#line 1 "solution.c"\n{code}\n#line 1 "driver.c"\n{HELPERS}{MAIN.format(body=body)}'
    return Program(
        files={"main.c": source},
        compile=["gcc", "-std=gnu11", "-O1", "-fmax-errors=20", "main.c", "-o", "main", "-lcjson", "-lm"],
        compile_limits=COMPILE_LIMITS,
        run=["./main"],
        run_limits=RUN_LIMITS,
    )
