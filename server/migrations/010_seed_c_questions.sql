-- 010_seed_c_questions.sql
-- C translations of the seeded questions; the first two tests are public examples.
INSERT INTO problems (title, description, difficulty, topic, language, signature, entry_point,
                      buggy_code, fixed_code, tests, visible_test_count)
SELECT title, description, difficulty, topic, language, signature, entry_point,
       buggy_code, fixed_code, tests, 2
FROM jsonb_to_recordset($questions$
[
  {
    "title": "Longest Overheating Streak",
    "topic": "arrays",
    "difficulty": "easy",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "readings",
          "type": "int[]"
        },
        {
          "name": "threshold",
          "type": "int"
        }
      ],
      "returns": "int"
    },
    "description": "A machine records one temperature reading each minute. A reading is overheating when it is **greater than or equal to** a given threshold.\n\nImplement `int entryPoint(int* readings, int readingsSize, int threshold)` to return the longest consecutive streak of overheating readings. Return `0` if no reading qualifies.\n\n### Examples\n- Input: `readings = [70, 80, 85, 60], threshold = 80`\n  Output: `2`\n- Input: `readings = [40, 50], threshold = 60`\n  Output: `0`\n\n### Constraints\n- `0 <= readingsSize <= 10000`\n- Each reading and `threshold` is an integer between `-100` and `1000`.\n",
    "fixed_code": "int entryPoint(int* readings, int readingsSize, int threshold) {\n    int longest = 0;\n    int current = 0;\n    for (int i = 0; i < readingsSize; i++) {\n        if (readings[i] >= threshold) {\n            current++;\n            if (current > longest) {\n                longest = current;\n            }\n        } else {\n            current = 0;\n        }\n    }\n    return longest;\n}\n",
    "buggy_code": "int entryPoint(int* readings, int readingsSize, int threshold) {\n    int longest = 0;\n    int current = 0;\n    for (int i = 0; i < readingsSize; i++) {\n        if (readings[i] > threshold) {\n            current++;\n            if (current > longest) {\n                longest = current;\n            }\n        } else {\n            current = 0;\n        }\n    }\n    return longest;\n}\n",
    "tests": [
      {
        "args": [
          [
            70,
            80,
            85,
            60
          ],
          80
        ],
        "expected": 2
      },
      {
        "args": [
          [
            40,
            50
          ],
          60
        ],
        "expected": 0
      },
      {
        "args": [
          [],
          80
        ],
        "expected": 0
      },
      {
        "args": [
          [
            80
          ],
          80
        ],
        "expected": 1
      },
      {
        "args": [
          [
            81,
            82,
            83
          ],
          80
        ],
        "expected": 3
      },
      {
        "args": [
          [
            80,
            79,
            80,
            80,
            79,
            90
          ],
          80
        ],
        "expected": 2
      },
      {
        "args": [
          [
            -2,
            -1,
            0,
            -3
          ],
          -1
        ],
        "expected": 2
      }
    ]
  },
  {
    "title": "Clean a Display Label",
    "topic": "strings",
    "difficulty": "easy",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "label",
          "type": "string"
        }
      ],
      "returns": "string"
    },
    "description": "A label imported from a text file may contain extra spaces. Clean it by removing leading and trailing spaces and replacing every consecutive group of internal spaces with one space. Preserve all other characters and their capitalization.\n\nImplement `char* entryPoint(char* label)` to return the cleaned label as a dynamically allocated null-terminated string. A label containing only spaces becomes an empty string.\n\n### Examples\n- Input: `label = \"  Main   Office  \"`\n  Output: `\"Main Office\"`\n- Input: `label = \"Desk 7\"`\n  Output: `\"Desk 7\"`\n\n### Constraints\n- `0 <= strlen(label) <= 10000`\n- `label` contains only English letters, digits, and ordinary ASCII spaces.\n",
    "fixed_code": "char* entryPoint(char* label) {\n    int len = strlen(label);\n    char* result = malloc(len + 1);\n    int rlen = 0;\n    for (int i = 0; i < len; i++) {\n        char character = label[i];\n        if (character != ' ') {\n            result[rlen++] = character;\n        } else if (rlen > 0 && result[rlen - 1] != ' ') {\n            result[rlen++] = ' ';\n        }\n    }\n    result[rlen] = '\\0';\n    while (rlen > 0 && result[rlen - 1] == ' ') {\n        result[--rlen] = '\\0';\n    }\n    return result;\n}\n",
    "buggy_code": "char* entryPoint(char* label) {\n    int len = strlen(label);\n    char* result = malloc(len + 1);\n    int rlen = 0;\n    for (int i = 0; i < len; i++) {\n        char character = label[i];\n        if (character != ' ') {\n            result[rlen++] = character;\n        } else if (rlen > 0 && result[rlen - 1] != ' ') {\n            result[rlen++] = ' ';\n        }\n    }\n    result[rlen] = '\\0';\n    int start = 0;\n    while (start < rlen && result[start] == ' ') {\n        start++;\n    }\n    if (start > 0) {\n        memmove(result, result + start, rlen - start + 1);\n    }\n    return result;\n}\n",
    "tests": [
      {
        "args": [
          "  Main   Office  "
        ],
        "expected": "Main Office"
      },
      {
        "args": [
          "Desk 7"
        ],
        "expected": "Desk 7"
      },
      {
        "args": [
          ""
        ],
        "expected": ""
      },
      {
        "args": [
          "     "
        ],
        "expected": ""
      },
      {
        "args": [
          " A"
        ],
        "expected": "A"
      },
      {
        "args": [
          "A "
        ],
        "expected": "A"
      },
      {
        "args": [
          "North    Wing  12"
        ],
        "expected": "North Wing 12"
      }
    ]
  },
  {
    "title": "Combine Warehouse Deliveries",
    "topic": "hash maps",
    "difficulty": "easy",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "items",
          "type": "string[]"
        },
        {
          "name": "quantities",
          "type": "int[]"
        }
      ],
      "returns": "int[]"
    },
    "description": "A warehouse receives delivery records represented as two parallel arrays: `items` and `quantities`. `items[i]` is the item name and `quantities[i]` is the delivered quantity. The same item may appear multiple times.\n\nImplement `int* entryPoint(char** items, int itemsSize, int* quantities, int quantitiesSize, int* returnSize)` to return a dynamically allocated array containing the total quantity delivered for each distinct item, in order of their first appearance. Set `*returnSize` to the number of distinct items.\n\n### Examples\n- Input: `items = [\"bolts\", \"bolts\"], quantities = [3, 4]`\n  Output: `[7]`\n- Input: `items = [\"tape\", \"glue\"], quantities = [2, 5]`\n  Output: `[2, 5]`\n\n### Constraints\n- `0 <= itemsSize == quantitiesSize <= 10000`\n- Item names contain between `1` and `30` English letters and are case-sensitive.\n- `0 <= quantities[i] <= 100000`.\n",
    "fixed_code": "int* entryPoint(char** items, int itemsSize, int* quantities, int quantitiesSize, int* returnSize) {\n    char** distinct = malloc(sizeof(char*) * (itemsSize + 1));\n    int* totals = malloc(sizeof(int) * (itemsSize + 1));\n    int count = 0;\n\n    for (int i = 0; i < itemsSize; i++) {\n        int found = -1;\n        for (int j = 0; j < count; j++) {\n            if (strcmp(distinct[j], items[i]) == 0) {\n                found = j;\n                break;\n            }\n        }\n        if (found == -1) {\n            distinct[count] = items[i];\n            totals[count] = quantities[i];\n            count++;\n        } else {\n            totals[found] += quantities[i];\n        }\n    }\n\n    free(distinct);\n    *returnSize = count;\n    return totals;\n}\n",
    "buggy_code": "int* entryPoint(char** items, int itemsSize, int* quantities, int quantitiesSize, int* returnSize) {\n    char** distinct = malloc(sizeof(char*) * (itemsSize + 1));\n    int* totals = malloc(sizeof(int) * (itemsSize + 1));\n    int count = 0;\n\n    for (int i = 0; i < itemsSize; i++) {\n        int found = -1;\n        for (int j = 0; j < count; j++) {\n            if (strcmp(distinct[j], items[i]) == 0) {\n                found = j;\n                break;\n            }\n        }\n        if (found == -1) {\n            distinct[count] = items[i];\n            totals[count] = quantities[i];\n            count++;\n        } else {\n            totals[found] = quantities[i];\n        }\n    }\n\n    free(distinct);\n    *returnSize = count;\n    return totals;\n}\n",
    "tests": [
      {
        "args": [
          [
            "bolts",
            "bolts"
          ],
          [
            3,
            4
          ]
        ],
        "expected": [
          7
        ]
      },
      {
        "args": [
          [
            "tape",
            "glue"
          ],
          [
            2,
            5
          ]
        ],
        "expected": [
          2,
          5
        ]
      },
      {
        "args": [
          [],
          []
        ],
        "expected": []
      },
      {
        "args": [
          [
            "washers"
          ],
          [
            0
          ]
        ],
        "expected": [
          0
        ]
      },
      {
        "args": [
          [
            "nuts",
            "nuts"
          ],
          [
            5,
            0
          ]
        ],
        "expected": [
          5
        ]
      },
      {
        "args": [
          [
            "Tape",
            "tape",
            "Tape"
          ],
          [
            2,
            3,
            4
          ]
        ],
        "expected": [
          6,
          3
        ]
      },
      {
        "args": [
          [
            "a",
            "b",
            "a",
            "b",
            "a"
          ],
          [
            1,
            2,
            3,
            4,
            5
          ]
        ],
        "expected": [
          9,
          6
        ]
      }
    ]
  },
  {
    "title": "Undo Draft Lines",
    "topic": "stacks",
    "difficulty": "easy",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "actions",
          "type": "string[]"
        }
      ],
      "returns": "string[]"
    },
    "description": "A small drafting tool processes an array of string actions. An action equal to `\"UNDO\"` removes the most recently added line that is still present. If no lines remain, `\"UNDO\"` does nothing. Every other action adds that string as a new line, including an empty string.\n\nImplement `char** entryPoint(char** actions, int actionsSize, int* returnSize)` to return the remaining lines in their original insertion order as a dynamically allocated array of strings. Set `*returnSize` to the number of remaining lines.\n\n### Examples\n- Input: `actions = [\"Title\", \"Draft\", \"UNDO\"]`\n  Output: `[\"Title\"]`\n- Input: `actions = [\"UNDO\", \"Hello\"]`\n  Output: `[\"Hello\"]`\n\n### Constraints\n- `0 <= actionsSize <= 10000`\n- Each action is a string containing at most `100` characters.\n- Actions are case-sensitive.\n",
    "fixed_code": "char** entryPoint(char** actions, int actionsSize, int* returnSize) {\n    char** lines = malloc(sizeof(char*) * (actionsSize + 1));\n    int count = 0;\n    for (int i = 0; i < actionsSize; i++) {\n        if (strcmp(actions[i], \"UNDO\") == 0) {\n            if (count > 0) {\n                count--;\n            }\n        } else {\n            lines[count++] = actions[i];\n        }\n    }\n    *returnSize = count;\n    return lines;\n}\n",
    "buggy_code": "char** entryPoint(char** actions, int actionsSize, int* returnSize) {\n    char** lines = malloc(sizeof(char*) * (actionsSize + 1));\n    int count = 0;\n    for (int i = 0; i < actionsSize; i++) {\n        if (strcmp(actions[i], \"UNDO\") == 0) {\n            if (count > 0) {\n                for (int j = 0; j < count - 1; j++) {\n                    lines[j] = lines[j + 1];\n                }\n                count--;\n            }\n        } else {\n            lines[count++] = actions[i];\n        }\n    }\n    *returnSize = count;\n    return lines;\n}\n",
    "tests": [
      {
        "args": [
          [
            "Title",
            "Draft",
            "UNDO"
          ]
        ],
        "expected": [
          "Title"
        ]
      },
      {
        "args": [
          [
            "UNDO",
            "Hello"
          ]
        ],
        "expected": [
          "Hello"
        ]
      },
      {
        "args": [
          []
        ],
        "expected": []
      },
      {
        "args": [
          [
            "UNDO",
            "UNDO"
          ]
        ],
        "expected": []
      },
      {
        "args": [
          [
            "A",
            "B",
            "C",
            "UNDO",
            "UNDO"
          ]
        ],
        "expected": [
          "A"
        ]
      },
      {
        "args": [
          [
            "A",
            "UNDO",
            "B"
          ]
        ],
        "expected": [
          "B"
        ]
      },
      {
        "args": [
          [
            "",
            "note",
            "UNDO"
          ]
        ],
        "expected": [
          ""
        ]
      },
      {
        "args": [
          [
            "undo",
            "Keep"
          ]
        ],
        "expected": [
          "undo",
          "Keep"
        ]
      }
    ]
  },
  {
    "title": "Count Maintenance Notices",
    "topic": "intervals",
    "difficulty": "easy",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "windows",
          "type": "int[][]"
        },
        {
          "name": "session_start",
          "type": "int"
        },
        {
          "name": "session_end",
          "type": "int"
        }
      ],
      "returns": "int"
    },
    "description": "A service publishes maintenance windows as pairs `[start, end]`. Each window includes its start time and excludes its end time. A customer's session follows the same rule.\n\nImplement `int entryPoint(int** windows, int windowsSize, int* windowsColSize, int session_start, int session_end)` to count how many maintenance windows overlap the session for a positive amount of time. A window that ends exactly when the session starts, or starts exactly when the session ends, does not overlap. Count each listed window separately, including duplicate windows.\n\n### Examples\n- Input: `windows = [[1, 4], [6, 9]], session_start = 3, session_end = 7`\n  Output: `2`\n- Input: `windows = [[1, 3], [7, 9]], session_start = 3, session_end = 7`\n  Output: `0`\n\n### Constraints\n- `0 <= windowsSize <= 10000`\n- Each window contains two integers satisfying `0 <= start < end <= 1000000`.\n- `0 <= session_start < session_end <= 1000000`\n- Windows may appear in any order and may overlap one another.\n",
    "fixed_code": "int entryPoint(int** windows, int windowsSize, int* windowsColSize, int session_start, int session_end) {\n    int count = 0;\n    for (int i = 0; i < windowsSize; i++) {\n        int start = windows[i][0];\n        int end = windows[i][1];\n        int overlap_start = start > session_start ? start : session_start;\n        int overlap_end = end < session_end ? end : session_end;\n        if (overlap_start < overlap_end) {\n            count++;\n        }\n    }\n    return count;\n}\n",
    "buggy_code": "int entryPoint(int** windows, int windowsSize, int* windowsColSize, int session_start, int session_end) {\n    int count = 0;\n    for (int i = 0; i < windowsSize; i++) {\n        int start = windows[i][0];\n        int end = windows[i][1];\n        int overlap_start = start > session_start ? start : session_start;\n        int overlap_end = end < session_end ? end : session_end;\n        if (overlap_start <= overlap_end) {\n            count++;\n        }\n    }\n    return count;\n}\n",
    "tests": [
      {
        "args": [
          [
            [
              1,
              4
            ],
            [
              6,
              9
            ]
          ],
          3,
          7
        ],
        "expected": 2
      },
      {
        "args": [
          [
            [
              1,
              3
            ],
            [
              7,
              9
            ]
          ],
          3,
          7
        ],
        "expected": 0
      },
      {
        "args": [
          [],
          2,
          5
        ],
        "expected": 0
      },
      {
        "args": [
          [
            [
              3,
              7
            ]
          ],
          3,
          7
        ],
        "expected": 1
      },
      {
        "args": [
          [
            [
              0,
              10
            ],
            [
              4,
              5
            ]
          ],
          3,
          7
        ],
        "expected": 2
      },
      {
        "args": [
          [
            [
              0,
              2
            ],
            [
              8,
              10
            ]
          ],
          3,
          7
        ],
        "expected": 0
      },
      {
        "args": [
          [
            [
              5,
              8
            ],
            [
              1,
              4
            ],
            [
              5,
              8
            ]
          ],
          4,
          6
        ],
        "expected": 2
      },
      {
        "args": [
          [
            [
              0,
              1
            ],
            [
              1,
              2
            ],
            [
              2,
              3
            ]
          ],
          1,
          2
        ],
        "expected": 1
      }
    ]
  },
  {
    "title": "Select a Contiguous Audit Sample",
    "topic": "sliding window and hash maps",
    "difficulty": "medium",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "categories",
          "type": "string[]"
        },
        {
          "name": "costs",
          "type": "int[]"
        },
        {
          "name": "budget",
          "type": "int"
        },
        {
          "name": "category_limit",
          "type": "int"
        }
      ],
      "returns": "int"
    },
    "description": "An audit system stores events in chronological order. Each event has a category and a nonnegative review cost.\n\nImplement `int entryPoint(char** categories, int categoriesSize, int* costs, int costsSize, int budget, int category_limit)` to return the maximum number of consecutive events that can be selected while satisfying both rules:\n\n- Their total review cost is at most `budget`.\n- No category appears more than `category_limit` times.\n\nReturn `0` if no nonempty selection is valid. The input lists have equal lengths, and their matching positions describe the same event.\n\n### Examples\n- Input: `categories = [\"a\", \"b\", \"a\"], costs = [2, 1, 2], budget = 5, category_limit = 2`\n  Output: `3`\n- Input: `categories = [\"a\", \"a\", \"b\"], costs = [1, 1, 1], budget = 3, category_limit = 1`\n  Output: `2`\n\n### Constraints\n- `0 <= categoriesSize == costsSize <= 100000`\n- Categories are nonempty lowercase English strings of length at most `20`.\n- `0 <= costs[i] <= 10000`\n- `0 <= budget <= 1000000000`\n- `1 <= category_limit <= 100000`\n",
    "fixed_code": "typedef struct {\n    char* key;\n    int count;\n} Entry;\n\nstatic unsigned int hash_key(const char* s) {\n    unsigned int h = 2166136261u;\n    while (*s) {\n        h ^= (unsigned char)*s++;\n        h *= 16777619;\n    }\n    return h;\n}\n\nstatic int get_count(Entry* table, int mask, const char* key) {\n    unsigned int idx = hash_key(key) & mask;\n    while (table[idx].key) {\n        if (strcmp(table[idx].key, key) == 0) return table[idx].count;\n        idx = (idx + 1) & mask;\n    }\n    return 0;\n}\n\nstatic void add_count(Entry* table, int mask, char* key, int delta) {\n    unsigned int idx = hash_key(key) & mask;\n    while (table[idx].key) {\n        if (strcmp(table[idx].key, key) == 0) {\n            table[idx].count += delta;\n            return;\n        }\n        idx = (idx + 1) & mask;\n    }\n    table[idx].key = key;\n    table[idx].count = delta;\n}\n\nint entryPoint(char** categories, int categoriesSize, int* costs, int costsSize, int budget, int category_limit) {\n    int cap = 131072;\n    int mask = cap - 1;\n    Entry* table = calloc(cap, sizeof(Entry));\n    int left = 0;\n    long long total = 0;\n    int best = 0;\n\n    for (int right = 0; right < categoriesSize; right++) {\n        add_count(table, mask, categories[right], 1);\n        total += costs[right];\n        while (total > budget || get_count(table, mask, categories[right]) > category_limit) {\n            char* departing = categories[left];\n            add_count(table, mask, departing, -1);\n            total -= costs[left];\n            left++;\n        }\n        int cur = right - left + 1;\n        if (cur > best) best = cur;\n    }\n\n    free(table);\n    return best;\n}\n",
    "buggy_code": "typedef struct {\n    char* key;\n    int count;\n} Entry;\n\nstatic unsigned int hash_key(const char* s) {\n    unsigned int h = 2166136261u;\n    while (*s) {\n        h ^= (unsigned char)*s++;\n        h *= 16777619;\n    }\n    return h;\n}\n\nstatic int get_count(Entry* table, int mask, const char* key) {\n    unsigned int idx = hash_key(key) & mask;\n    while (table[idx].key) {\n        if (strcmp(table[idx].key, key) == 0) return table[idx].count;\n        idx = (idx + 1) & mask;\n    }\n    return 0;\n}\n\nstatic void add_count(Entry* table, int mask, char* key, int delta) {\n    unsigned int idx = hash_key(key) & mask;\n    while (table[idx].key) {\n        if (strcmp(table[idx].key, key) == 0) {\n            table[idx].count += delta;\n            return;\n        }\n        idx = (idx + 1) & mask;\n    }\n    table[idx].key = key;\n    table[idx].count = delta;\n}\n\nint entryPoint(char** categories, int categoriesSize, int* costs, int costsSize, int budget, int category_limit) {\n    int cap = 131072;\n    int mask = cap - 1;\n    Entry* table = calloc(cap, sizeof(Entry));\n    int left = 0;\n    long long total = 0;\n    int best = 0;\n\n    for (int right = 0; right < categoriesSize; right++) {\n        add_count(table, mask, categories[right], 1);\n        total += costs[right];\n        if (total > budget || get_count(table, mask, categories[right]) > category_limit) {\n            char* departing = categories[left];\n            add_count(table, mask, departing, -1);\n            total -= costs[left];\n            left++;\n        }\n        int cur = right - left + 1;\n        if (cur > best) best = cur;\n    }\n\n    free(table);\n    return best;\n}\n",
    "tests": [
      {
        "args": [
          [
            "a",
            "b",
            "a"
          ],
          [
            2,
            1,
            2
          ],
          5,
          2
        ],
        "expected": 3
      },
      {
        "args": [
          [
            "a",
            "a",
            "b"
          ],
          [
            1,
            1,
            1
          ],
          3,
          1
        ],
        "expected": 2
      },
      {
        "args": [
          [],
          [],
          10,
          2
        ],
        "expected": 0
      },
      {
        "args": [
          [
            "a",
            "b",
            "c",
            "d"
          ],
          [
            1,
            10,
            1,
            1
          ],
          3,
          2
        ],
        "expected": 2
      },
      {
        "args": [
          [
            "a",
            "b",
            "b",
            "c"
          ],
          [
            0,
            0,
            0,
            0
          ],
          0,
          1
        ],
        "expected": 2
      },
      {
        "args": [
          [
            "a",
            "a",
            "a"
          ],
          [
            0,
            0,
            0
          ],
          0,
          2
        ],
        "expected": 2
      },
      {
        "args": [
          [
            "a",
            "b"
          ],
          [
            5,
            6
          ],
          4,
          1
        ],
        "expected": 0
      },
      {
        "args": [
          [
            "a",
            "b",
            "c",
            "a"
          ],
          [
            2,
            2,
            2,
            2
          ],
          6,
          1
        ],
        "expected": 3
      }
    ]
  },
  {
    "title": "Parse a Quoted Search Query",
    "topic": "strings and state machines",
    "difficulty": "medium",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "query",
          "type": "string"
        }
      ],
      "returns": "string[]"
    },
    "description": "A search box accepts a small query language. Implement `char** entryPoint(char* query, int* returnSize)` to return its tokens in order as a dynamically allocated array of strings according to these rules:\n\n- Ordinary ASCII spaces separate tokens when outside double quotes.\n- Double quotes toggle quoted mode and are omitted from the token. Spaces inside quotes are preserved.\n- A backslash escapes the next character, inside or outside quotes. The escaped character is added literally, and the backslash is omitted.\n- Adjacent quoted and unquoted portions belong to the same token unless separated by an unquoted, unescaped space.\n- Empty quoted portions count as a token when standing alone.\n- Leading, trailing, and repeated separator spaces do not create tokens.\n\nSet `*returnSize` to the number of tokens.\n\n### Examples\n- Input: `query = \"red \\\"blue sky\\\"\"`\n  Output: `[\"red\", \"blue sky\"]`\n- Input: `query = \"a\\\"b c\\\"d\"`\n  Output: `[\"ab cd\"]`\n\n### Constraints\n- `0 <= strlen(query) <= 100000`\n- The query contains printable ASCII characters.\n- Every backslash has a following character.\n- Unescaped double quotes are balanced.\n",
    "fixed_code": "char** entryPoint(char* query, int* returnSize) {\n    int n = strlen(query);\n    char** tokens = malloc(sizeof(char*) * (n + 1));\n    char* current = malloc(n + 1);\n    int cur_len = 0;\n    int tok_count = 0;\n    bool quoted = false;\n    bool active = false;\n    int i = 0;\n\n    while (i < n) {\n        char character = query[i];\n        if (character == '\\\\') {\n            i++;\n            if (i < n) {\n                current[cur_len++] = query[i];\n                active = true;\n            }\n        } else if (character == '\"') {\n            quoted = !quoted;\n            active = true;\n        } else if (character == ' ' && !quoted) {\n            if (active) {\n                current[cur_len] = '\\0';\n                tokens[tok_count++] = strdup(current);\n                cur_len = 0;\n                active = false;\n            }\n        } else {\n            current[cur_len++] = character;\n            active = true;\n        }\n        i++;\n    }\n\n    if (active) {\n        current[cur_len] = '\\0';\n        tokens[tok_count++] = strdup(current);\n    }\n\n    free(current);\n    *returnSize = tok_count;\n    return tokens;\n}\n",
    "buggy_code": "char** entryPoint(char* query, int* returnSize) {\n    int n = strlen(query);\n    char** tokens = malloc(sizeof(char*) * (n + 1));\n    char* current = malloc(n + 1);\n    int cur_len = 0;\n    int tok_count = 0;\n    bool quoted = false;\n    bool active = false;\n    int i = 0;\n\n    while (i < n) {\n        char character = query[i];\n        if (character == '\\\\' && quoted) {\n            i++;\n            if (i < n) {\n                current[cur_len++] = query[i];\n                active = true;\n            }\n        } else if (character == '\"') {\n            quoted = !quoted;\n            active = true;\n        } else if (character == ' ' && !quoted) {\n            if (active) {\n                current[cur_len] = '\\0';\n                tokens[tok_count++] = strdup(current);\n                cur_len = 0;\n                active = false;\n            }\n        } else {\n            current[cur_len++] = character;\n            active = true;\n        }\n        i++;\n    }\n\n    if (active) {\n        current[cur_len] = '\\0';\n        tokens[tok_count++] = strdup(current);\n    }\n\n    free(current);\n    *returnSize = tok_count;\n    return tokens;\n}\n",
    "tests": [
      {
        "args": [
          "red \"blue sky\""
        ],
        "expected": [
          "red",
          "blue sky"
        ]
      },
      {
        "args": [
          "a\"b c\"d"
        ],
        "expected": [
          "ab cd"
        ]
      },
      {
        "args": [
          ""
        ],
        "expected": []
      },
      {
        "args": [
          "   "
        ],
        "expected": []
      },
      {
        "args": [
          "\"\" x \"\""
        ],
        "expected": [
          "",
          "x",
          ""
        ]
      },
      {
        "args": [
          "alpha\\ beta gamma"
        ],
        "expected": [
          "alpha beta",
          "gamma"
        ]
      },
      {
        "args": [
          "\"say \\\"hi\\\"\""
        ],
        "expected": [
          "say \"hi\""
        ]
      },
      {
        "args": [
          "path\\\\name"
        ],
        "expected": [
          "path\\name"
        ]
      },
      {
        "args": [
          "  one   \"two  three\"  "
        ],
        "expected": [
          "one",
          "two  three"
        ]
      }
    ]
  },
  {
    "title": "Schedule Dependent Export Jobs",
    "topic": "graphs and topological ordering",
    "difficulty": "medium",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "durations",
          "type": "int[]"
        },
        {
          "name": "release_times",
          "type": "int[]"
        },
        {
          "name": "dependencies",
          "type": "int[][]"
        }
      ],
      "returns": "int[]"
    },
    "description": "A data platform must run `n` export jobs, numbered from `0` to `n - 1`. Job `i` takes `durations[i]` time units and cannot start before time `release_times[i]`.\n\nEach dependency `[before, after]` means that job `after` must wait until job `before` finishes. A job must wait for all its prerequisites. Unlimited workers are available, so unrelated jobs may run simultaneously. Jobs begin as soon as their release times and dependencies permit.\n\nImplement `int* entryPoint(int* durations, int durationsSize, int* release_times, int release_timesSize, int** dependencies, int dependenciesSize, int* dependenciesColSize, int* returnSize)` to return a dynamically allocated array containing the earliest finish time of every job, in job-number order. Set `*returnSize` to `n`. The dependency graph is guaranteed to have no cycles.\n\n### Examples\n- Input: `durations = [2, 3], release_times = [0, 0], dependencies = [[0, 1]]`\n  Output: `[2, 5]`\n- Input: `durations = [2, 1], release_times = [5, 0], dependencies = []`\n  Output: `[7, 1]`\n\n### Constraints\n- `0 <= durationsSize == release_timesSize <= 10000`\n- `1 <= durations[i] <= 1000000`\n- `0 <= release_times[i] <= 1000000000`\n- There are at most `50000` dependencies.\n- Dependencies use valid, distinct job numbers, and duplicate dependency pairs do not occur.\n",
    "fixed_code": "int* entryPoint(int* durations, int durationsSize, int* release_times, int release_timesSize, int** dependencies, int dependenciesSize, int* dependenciesColSize, int* returnSize) {\n    int n = durationsSize;\n    *returnSize = n;\n    if (n == 0) return malloc(sizeof(int));\n\n    int* out_count = calloc(n, sizeof(int));\n    for (int i = 0; i < dependenciesSize; i++) {\n        out_count[dependencies[i][0]]++;\n    }\n    int** outgoing = malloc(sizeof(int*) * n);\n    int* out_idx = calloc(n, sizeof(int));\n    for (int i = 0; i < n; i++) {\n        outgoing[i] = malloc(sizeof(int) * (out_count[i] + 1));\n    }\n    int* remaining = calloc(n, sizeof(int));\n    for (int i = 0; i < dependenciesSize; i++) {\n        int u = dependencies[i][0];\n        int v = dependencies[i][1];\n        outgoing[u][out_idx[u]++] = v;\n        remaining[v]++;\n    }\n\n    int* ready = malloc(sizeof(int) * (n + 1));\n    int q_head = 0, q_tail = 0;\n    for (int i = 0; i < n; i++) {\n        if (remaining[i] == 0) {\n            ready[q_tail++] = i;\n        }\n    }\n\n    int* starts = malloc(sizeof(int) * n);\n    int* finishes = malloc(sizeof(int) * n);\n    for (int i = 0; i < n; i++) {\n        starts[i] = release_times[i];\n        finishes[i] = 0;\n    }\n\n    while (q_head < q_tail) {\n        int job = ready[q_head++];\n        finishes[job] = starts[job] + durations[job];\n        for (int k = 0; k < out_count[job]; k++) {\n            int child = outgoing[job][k];\n            if (finishes[job] > starts[child]) {\n                starts[child] = finishes[job];\n            }\n            remaining[child]--;\n            if (remaining[child] == 0) {\n                ready[q_tail++] = child;\n            }\n        }\n    }\n\n    for (int i = 0; i < n; i++) free(outgoing[i]);\n    free(outgoing);\n    free(out_count);\n    free(out_idx);\n    free(remaining);\n    free(ready);\n    free(starts);\n\n    return finishes;\n}\n",
    "buggy_code": "int* entryPoint(int* durations, int durationsSize, int* release_times, int release_timesSize, int** dependencies, int dependenciesSize, int* dependenciesColSize, int* returnSize) {\n    int n = durationsSize;\n    *returnSize = n;\n    if (n == 0) return malloc(sizeof(int));\n\n    int* out_count = calloc(n, sizeof(int));\n    for (int i = 0; i < dependenciesSize; i++) {\n        out_count[dependencies[i][0]]++;\n    }\n    int** outgoing = malloc(sizeof(int*) * n);\n    int* out_idx = calloc(n, sizeof(int));\n    for (int i = 0; i < n; i++) {\n        outgoing[i] = malloc(sizeof(int) * (out_count[i] + 1));\n    }\n    int* remaining = calloc(n, sizeof(int));\n    for (int i = 0; i < dependenciesSize; i++) {\n        int u = dependencies[i][0];\n        int v = dependencies[i][1];\n        outgoing[u][out_idx[u]++] = v;\n        remaining[v]++;\n    }\n\n    int* ready = malloc(sizeof(int) * (n + 1));\n    int q_head = 0, q_tail = 0;\n    for (int i = 0; i < n; i++) {\n        if (remaining[i] == 0) {\n            ready[q_tail++] = i;\n        }\n    }\n\n    int* starts = malloc(sizeof(int) * n);\n    int* finishes = malloc(sizeof(int) * n);\n    for (int i = 0; i < n; i++) {\n        starts[i] = release_times[i];\n        finishes[i] = 0;\n    }\n\n    while (q_head < q_tail) {\n        int job = ready[q_head++];\n        finishes[job] = starts[job] + durations[job];\n        for (int k = 0; k < out_count[job]; k++) {\n            int child = outgoing[job][k];\n            starts[child] = release_times[child] > finishes[job] ? release_times[child] : finishes[job];\n            remaining[child]--;\n            if (remaining[child] == 0) {\n                ready[q_tail++] = child;\n            }\n        }\n    }\n\n    for (int i = 0; i < n; i++) free(outgoing[i]);\n    free(outgoing);\n    free(out_count);\n    free(out_idx);\n    free(remaining);\n    free(ready);\n    free(starts);\n\n    return finishes;\n}\n",
    "tests": [
      {
        "args": [
          [
            2,
            3
          ],
          [
            0,
            0
          ],
          [
            [
              0,
              1
            ]
          ]
        ],
        "expected": [
          2,
          5
        ]
      },
      {
        "args": [
          [
            2,
            1
          ],
          [
            5,
            0
          ],
          []
        ],
        "expected": [
          7,
          1
        ]
      },
      {
        "args": [
          [],
          [],
          []
        ],
        "expected": []
      },
      {
        "args": [
          [
            8,
            2,
            3
          ],
          [
            0,
            0,
            0
          ],
          [
            [
              0,
              2
            ],
            [
              1,
              2
            ]
          ]
        ],
        "expected": [
          8,
          2,
          11
        ]
      },
      {
        "args": [
          [
            2,
            3
          ],
          [
            0,
            10
          ],
          [
            [
              0,
              1
            ]
          ]
        ],
        "expected": [
          2,
          13
        ]
      },
      {
        "args": [
          [
            2,
            5,
            1,
            4
          ],
          [
            0,
            0,
            0,
            0
          ],
          [
            [
              0,
              1
            ],
            [
              0,
              2
            ],
            [
              1,
              3
            ],
            [
              2,
              3
            ]
          ]
        ],
        "expected": [
          2,
          7,
          3,
          11
        ]
      },
      {
        "args": [
          [
            3,
            2,
            4
          ],
          [
            1,
            10,
            0
          ],
          [
            [
              0,
              1
            ],
            [
              1,
              2
            ]
          ]
        ],
        "expected": [
          4,
          12,
          16
        ]
      },
      {
        "args": [
          [
            4,
            2,
            1
          ],
          [
            0,
            0,
            20
          ],
          [
            [
              0,
              2
            ],
            [
              1,
              2
            ]
          ]
        ],
        "expected": [
          4,
          2,
          21
        ]
      }
    ]
  },
  {
    "title": "Measure High-Demand Time",
    "topic": "intervals and sweep lines",
    "difficulty": "medium",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "intervals",
          "type": "int[][]"
        },
        {
          "name": "threshold",
          "type": "int"
        }
      ],
      "returns": "int"
    },
    "description": "A facility receives resource reservations. Each reservation is `[start, end, units]` and uses `units` resources throughout the half-open time interval `[start, end)`. Simultaneous reservations add their resource usage.\n\nImplement `int entryPoint(int** intervals, int intervalsSize, int* intervalsColSize, int threshold)` to return the total duration during which combined resource usage is at least `threshold`.\n\nCount elapsed time only once, regardless of how many reservations overlap. Reservations may be unsorted, duplicated, nested, or adjacent. Usage is zero outside all reservations.\n\n### Examples\n- Input: `intervals = [[0, 4, 2], [2, 6, 3]], threshold = 4`\n  Output: `2`\n  Explanation: Usage reaches at least 4 only during [2, 4).\n- Input: `intervals = [[1, 5, 3]], threshold = 3`\n  Output: `4`\n\n### Constraints\n- `0 <= intervalsSize <= 100000`\n- `0 <= start < end <= 1000000000`\n- `1 <= units <= 1000000`\n- `1 <= threshold <= 100000000000`\n",
    "fixed_code": "typedef struct {\n    int time;\n    int delta;\n} Event;\n\nstatic int compare_events(const void* a, const void* b) {\n    const Event* ea = (const Event*)a;\n    const Event* eb = (const Event*)b;\n    if (ea->time < eb->time) return -1;\n    if (ea->time > eb->time) return 1;\n    return 0;\n}\n\nint entryPoint(int** intervals, int intervalsSize, int* intervalsColSize, int threshold) {\n    if (intervalsSize == 0) return 0;\n    int event_count = intervalsSize * 2;\n    Event* events = malloc(sizeof(Event) * event_count);\n    for (int i = 0; i < intervalsSize; i++) {\n        events[2 * i] = (Event){intervals[i][0], intervals[i][2]};\n        events[2 * i + 1] = (Event){intervals[i][1], -intervals[i][2]};\n    }\n    qsort(events, event_count, sizeof(Event), compare_events);\n\n    long long active = 0;\n    int has_prev = 0;\n    int previous = 0;\n    int duration = 0;\n\n    int i = 0;\n    while (i < event_count) {\n        int cur_time = events[i].time;\n        long long delta_sum = 0;\n        while (i < event_count && events[i].time == cur_time) {\n            delta_sum += events[i].delta;\n            i++;\n        }\n        if (has_prev && active >= threshold) {\n            duration += cur_time - previous;\n        }\n        active += delta_sum;\n        previous = cur_time;\n        has_prev = 1;\n    }\n\n    free(events);\n    return duration;\n}\n",
    "buggy_code": "typedef struct {\n    int time;\n    int delta;\n} Event;\n\nstatic int compare_events(const void* a, const void* b) {\n    const Event* ea = (const Event*)a;\n    const Event* eb = (const Event*)b;\n    if (ea->time < eb->time) return -1;\n    if (ea->time > eb->time) return 1;\n    return 0;\n}\n\nint entryPoint(int** intervals, int intervalsSize, int* intervalsColSize, int threshold) {\n    if (intervalsSize == 0) return 0;\n    int event_count = intervalsSize * 2;\n    Event* events = malloc(sizeof(Event) * event_count);\n    for (int i = 0; i < intervalsSize; i++) {\n        events[2 * i] = (Event){intervals[i][0], intervals[i][2]};\n        events[2 * i + 1] = (Event){intervals[i][1], -intervals[i][2]};\n    }\n    qsort(events, event_count, sizeof(Event), compare_events);\n\n    long long active = 0;\n    int has_prev = 0;\n    int previous = 0;\n    int duration = 0;\n\n    int i = 0;\n    while (i < event_count) {\n        int cur_time = events[i].time;\n        long long delta_sum = 0;\n        while (i < event_count && events[i].time == cur_time) {\n            delta_sum += events[i].delta;\n            i++;\n        }\n        if (has_prev && active > threshold) {\n            duration += cur_time - previous;\n        }\n        active += delta_sum;\n        previous = cur_time;\n        has_prev = 1;\n    }\n\n    free(events);\n    return duration;\n}\n",
    "tests": [
      {
        "args": [
          [
            [
              0,
              4,
              2
            ],
            [
              2,
              6,
              3
            ]
          ],
          4
        ],
        "expected": 2
      },
      {
        "args": [
          [
            [
              1,
              5,
              3
            ]
          ],
          3
        ],
        "expected": 4
      },
      {
        "args": [
          [],
          1
        ],
        "expected": 0
      },
      {
        "args": [
          [
            [
              0,
              2,
              2
            ],
            [
              2,
              5,
              2
            ]
          ],
          2
        ],
        "expected": 5
      },
      {
        "args": [
          [
            [
              0,
              3,
              2
            ],
            [
              0,
              3,
              2
            ]
          ],
          4
        ],
        "expected": 3
      },
      {
        "args": [
          [
            [
              0,
              10,
              1
            ],
            [
              2,
              4,
              3
            ],
            [
              6,
              9,
              3
            ]
          ],
          4
        ],
        "expected": 5
      },
      {
        "args": [
          [
            [
              5,
              7,
              10
            ],
            [
              0,
              2,
              10
            ]
          ],
          5
        ],
        "expected": 4
      },
      {
        "args": [
          [
            [
              0,
              10,
              2
            ],
            [
              3,
              8,
              1
            ]
          ],
          4
        ],
        "expected": 0
      }
    ]
  },
  {
    "title": "Batch Sequential Print Jobs",
    "topic": "dynamic programming",
    "difficulty": "medium",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "intensities",
          "type": "int[]"
        },
        {
          "name": "max_batch",
          "type": "int"
        },
        {
          "name": "setup_cost",
          "type": "int"
        }
      ],
      "returns": "int"
    },
    "description": "A print shop must process jobs in their existing order. Each job has a positive intensity value. The shop partitions the jobs into nonempty, consecutive batches containing at most `max_batch` jobs each.\n\nThe cost of a batch is:\n\n`setup_cost + (number of jobs in the batch) * (maximum intensity in the batch)`\n\nEvery job must belong to exactly one batch. Jobs cannot be reordered.\n\nImplement `int entryPoint(int* intensities, int intensitiesSize, int max_batch, int setup_cost)` to return the minimum total cost. Return `0` when there are no jobs.\n\n### Examples\n- Input: `intensities = [2, 2], max_batch = 2, setup_cost = 3`\n  Output: `7`\n  Explanation: One batch costs 3 + 2 * 2 = 7.\n- Input: `intensities = [1, 10], max_batch = 2, setup_cost = 2`\n  Output: `15`\n  Explanation: Separate batches cost (2 + 1) + (2 + 10) = 15.\n\n### Constraints\n- `0 <= intensitiesSize <= 1000`\n- `1 <= intensities[i] <= 10000`\n- `0 <= max_batch <= 100`\n- `0 <= setup_cost <= 10000`\n",
    "fixed_code": "int entryPoint(int* intensities, int intensitiesSize, int max_batch, int setup_cost) {\n    int n = intensitiesSize;\n    int* dp = calloc(n + 1, sizeof(int));\n    for (int end = 1; end <= n; end++) {\n        int peak = intensities[end - 1];\n        int best = dp[end - 1] + setup_cost + peak;\n        int limit = max_batch < end ? max_batch : end;\n        for (int length = 1; length <= limit; length++) {\n            if (intensities[end - length] > peak) {\n                peak = intensities[end - length];\n            }\n            int candidate = dp[end - length] + setup_cost + length * peak;\n            if (candidate < best) {\n                best = candidate;\n            }\n        }\n        dp[end] = best;\n    }\n    int ans = dp[n];\n    free(dp);\n    return ans;\n}\n",
    "buggy_code": "int entryPoint(int* intensities, int intensitiesSize, int max_batch, int setup_cost) {\n    int n = intensitiesSize;\n    int* dp = calloc(n + 1, sizeof(int));\n    for (int end = 1; end <= n; end++) {\n        int peak = intensities[end - 1];\n        int best = dp[end - 1] + setup_cost + peak;\n        int limit = max_batch < end ? max_batch : end;\n        for (int length = 1; length < limit; length++) {\n            if (intensities[end - length] > peak) {\n                peak = intensities[end - length];\n            }\n            int candidate = dp[end - length] + setup_cost + length * peak;\n            if (candidate < best) {\n                best = candidate;\n            }\n        }\n        dp[end] = best;\n    }\n    int ans = dp[n];\n    free(dp);\n    return ans;\n}\n",
    "tests": [
      {
        "args": [
          [
            2,
            2
          ],
          2,
          3
        ],
        "expected": 7
      },
      {
        "args": [
          [
            1,
            10
          ],
          2,
          2
        ],
        "expected": 15
      },
      {
        "args": [
          [],
          3,
          5
        ],
        "expected": 0
      },
      {
        "args": [
          [
            7
          ],
          5,
          4
        ],
        "expected": 11
      },
      {
        "args": [
          [
            2,
            5,
            1
          ],
          1,
          3
        ],
        "expected": 17
      },
      {
        "args": [
          [
            5,
            5,
            5
          ],
          2,
          3
        ],
        "expected": 21
      },
      {
        "args": [
          [
            1,
            10,
            1
          ],
          2,
          10
        ],
        "expected": 41
      },
      {
        "args": [
          [
            3,
            1,
            4
          ],
          3,
          0
        ],
        "expected": 8
      },
      {
        "args": [
          [
            2,
            2,
            2,
            2
          ],
          3,
          5
        ],
        "expected": 18
      }
    ]
  },
  {
    "title": "Audit Temporary Network Links",
    "topic": "offline dynamic connectivity and rollback",
    "difficulty": "hard",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "n",
          "type": "int"
        },
        {
          "name": "links",
          "type": "int[][]"
        },
        {
          "name": "queries",
          "type": "int[][]"
        }
      ],
      "returns": "bool[]"
    },
    "description": "A network contains `n` devices numbered from `0` to `n - 1`. Its undirected links are available only during specified time windows.\n\nEach record `[u, v, start, end]` in `links` makes a link available throughout the half-open interval `[start, end)`. Multiple records may describe the same pair of devices; the link is available whenever any corresponding record is active.\n\nEach query `[time, u, v]` asks whether the devices are connected by a path of links that are all available at that time. A device is always connected to itself.\n\nImplement `bool* entryPoint(int n, int** links, int linksSize, int* linksColSize, int** queries, int queriesSize, int* queriesColSize, int* returnSize)` to return a dynamically allocated array of booleans in the original query order. Set `*returnSize` to `queriesSize`. Neither links nor queries are necessarily sorted.\n\n### Examples\n- Input: `n = 3, links = [[0,1,0,5],[1,2,2,4]], queries = [[1,0,2],[3,0,2]]`\n  Output: `[false, true]`\n- Input: `n = 2, links = [[0,1,1,3]], queries = [[1,0,1],[3,0,1]]`\n  Output: `[true, false]`\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= linksSize, queriesSize <= 30000`\n- All device numbers are valid.\n- Link endpoints are distinct.\n- `0 <= start < end <= 1000000000`\n- Query times are integers between `0` and `1000000000`.\n",
    "fixed_code": "typedef struct EdgeNode {\n    int u, v;\n    struct EdgeNode* next;\n} EdgeNode;\n\ntypedef struct QueryNode {\n    int q_index, u, v;\n    struct QueryNode* next;\n} QueryNode;\n\ntypedef struct {\n    int root_u;\n    int root_v;\n    bool increased;\n} History;\n\nstatic int cmp_ints(const void* a, const void* b) {\n    int ia = *(const int*)a;\n    int ib = *(const int*)b;\n    return (ia > ib) - (ia < ib);\n}\n\nstatic int bisect_left(int* arr, int n, int val) {\n    int l = 0, r = n;\n    while (l < r) {\n        int m = l + (r - l) / 2;\n        if (arr[m] < val) l = m + 1;\n        else r = m;\n    }\n    return l;\n}\n\nstatic int bisect_right(int* arr, int n, int val) {\n    int l = 0, r = n;\n    while (l < r) {\n        int m = l + (r - l) / 2;\n        if (arr[m] <= val) l = m + 1;\n        else r = m;\n    }\n    return l;\n}\n\nstatic int find(int* parent, int x) {\n    while (parent[x] != x) {\n        x = parent[x];\n    }\n    return x;\n}\n\nstatic void visit(int node, int base, int num_times, EdgeNode** tree, QueryNode** queries_at_time,\n                  int* parent, int* rank, History* history, int* hist_len, bool* answer) {\n    int checkpoint = *hist_len;\n    for (EdgeNode* e = tree[node]; e; e = e->next) {\n        int root_u = find(parent, e->u);\n        int root_v = find(parent, e->v);\n        if (root_u != root_v) {\n            if (rank[root_u] < rank[root_v]) {\n                int tmp = root_u; root_u = root_v; root_v = tmp;\n            }\n            parent[root_v] = root_u;\n            bool increased = (rank[root_u] == rank[root_v]);\n            if (increased) rank[root_u]++;\n            history[(*hist_len)++] = (History){root_u, root_v, increased};\n        }\n    }\n\n    if (node >= base) {\n        int t_index = node - base;\n        if (t_index < num_times) {\n            for (QueryNode* q = queries_at_time[t_index]; q; q = q->next) {\n                answer[q->q_index] = (find(parent, q->u) == find(parent, q->v));\n            }\n        }\n    } else {\n        visit(node * 2, base, num_times, tree, queries_at_time, parent, rank, history, hist_len, answer);\n        visit(node * 2 + 1, base, num_times, tree, queries_at_time, parent, rank, history, hist_len, answer);\n    }\n\n    while (*hist_len > checkpoint) {\n        (*hist_len)--;\n        History h = history[*hist_len];\n        parent[h.root_v] = h.root_v;\n        if (h.increased) rank[h.root_u]--;\n    }\n}\n\nbool* entryPoint(int n, int** links, int linksSize, int* linksColSize, int** queries, int queriesSize, int* queriesColSize, int* returnSize) {\n    *returnSize = queriesSize;\n    if (queriesSize == 0) return malloc(sizeof(bool));\n\n    int* raw_times = malloc(sizeof(int) * queriesSize);\n    for (int i = 0; i < queriesSize; i++) raw_times[i] = queries[i][0];\n    qsort(raw_times, queriesSize, sizeof(int), cmp_ints);\n\n    int num_times = 0;\n    int* times = malloc(sizeof(int) * queriesSize);\n    for (int i = 0; i < queriesSize; i++) {\n        if (i == 0 || raw_times[i] != raw_times[i - 1]) {\n            times[num_times++] = raw_times[i];\n        }\n    }\n    free(raw_times);\n\n    int base = 1;\n    while (base < num_times) base *= 2;\n\n    EdgeNode** tree = calloc(2 * base, sizeof(EdgeNode*));\n    for (int i = 0; i < linksSize; i++) {\n        int u = links[i][0], v = links[i][1];\n        int start = links[i][2], end = links[i][3];\n        int left = bisect_left(times, num_times, start) + base;\n        int right = bisect_left(times, num_times, end) + base;\n        while (left < right) {\n            if (left & 1) {\n                EdgeNode* e = malloc(sizeof(EdgeNode));\n                e->u = u; e->v = v; e->next = tree[left];\n                tree[left] = e;\n                left++;\n            }\n            if (right & 1) {\n                right--;\n                EdgeNode* e = malloc(sizeof(EdgeNode));\n                e->u = u; e->v = v; e->next = tree[right];\n                tree[right] = e;\n            }\n            left /= 2;\n            right /= 2;\n        }\n    }\n\n    QueryNode** queries_at_time = calloc(num_times, sizeof(QueryNode*));\n    for (int i = 0; i < queriesSize; i++) {\n        int t_idx = bisect_left(times, num_times, queries[i][0]);\n        QueryNode* q = malloc(sizeof(QueryNode));\n        q->q_index = i; q->u = queries[i][1]; q->v = queries[i][2];\n        q->next = queries_at_time[t_idx];\n        queries_at_time[t_idx] = q;\n    }\n\n    int* parent = malloc(sizeof(int) * n);\n    int* rank = calloc(n, sizeof(int));\n    for (int i = 0; i < n; i++) parent[i] = i;\n\n    History* history = malloc(sizeof(History) * (linksSize * 64 + 100));\n    int hist_len = 0;\n    bool* answer = malloc(sizeof(bool) * queriesSize);\n\n    visit(1, base, num_times, tree, queries_at_time, parent, rank, history, &hist_len, answer);\n\n    // cleanup\n    free(times);\n    free(parent);\n    free(rank);\n    free(history);\n    return answer;\n}\n",
    "buggy_code": "typedef struct EdgeNode {\n    int u, v;\n    struct EdgeNode* next;\n} EdgeNode;\n\ntypedef struct QueryNode {\n    int q_index, u, v;\n    struct QueryNode* next;\n} QueryNode;\n\ntypedef struct {\n    int root_u;\n    int root_v;\n    bool increased;\n} History;\n\nstatic int cmp_ints(const void* a, const void* b) {\n    int ia = *(const int*)a;\n    int ib = *(const int*)b;\n    return (ia > ib) - (ia < ib);\n}\n\nstatic int bisect_left(int* arr, int n, int val) {\n    int l = 0, r = n;\n    while (l < r) {\n        int m = l + (r - l) / 2;\n        if (arr[m] < val) l = m + 1;\n        else r = m;\n    }\n    return l;\n}\n\nstatic int bisect_right(int* arr, int n, int val) {\n    int l = 0, r = n;\n    while (l < r) {\n        int m = l + (r - l) / 2;\n        if (arr[m] <= val) l = m + 1;\n        else r = m;\n    }\n    return l;\n}\n\nstatic int find(int* parent, int x) {\n    while (parent[x] != x) {\n        parent[x] = parent[parent[x]];\n        x = parent[x];\n    }\n    return x;\n}\n\nstatic void visit(int node, int base, int num_times, EdgeNode** tree, QueryNode** queries_at_time,\n                  int* parent, int* rank, History* history, int* hist_len, bool* answer) {\n    int checkpoint = *hist_len;\n    for (EdgeNode* e = tree[node]; e; e = e->next) {\n        int root_u = find(parent, e->u);\n        int root_v = find(parent, e->v);\n        if (root_u != root_v) {\n            if (rank[root_u] < rank[root_v]) {\n                int tmp = root_u; root_u = root_v; root_v = tmp;\n            }\n            parent[root_v] = root_u;\n            bool increased = (rank[root_u] == rank[root_v]);\n            if (increased) rank[root_u]++;\n            history[(*hist_len)++] = (History){root_u, root_v, increased};\n        }\n    }\n\n    if (node >= base) {\n        int t_index = node - base;\n        if (t_index < num_times) {\n            for (QueryNode* q = queries_at_time[t_index]; q; q = q->next) {\n                answer[q->q_index] = (find(parent, q->u) == find(parent, q->v));\n            }\n        }\n    } else {\n        visit(node * 2, base, num_times, tree, queries_at_time, parent, rank, history, hist_len, answer);\n        visit(node * 2 + 1, base, num_times, tree, queries_at_time, parent, rank, history, hist_len, answer);\n    }\n\n    while (*hist_len > checkpoint) {\n        (*hist_len)--;\n        History h = history[*hist_len];\n        parent[h.root_v] = h.root_v;\n        if (h.increased) rank[h.root_u]--;\n    }\n}\n\nbool* entryPoint(int n, int** links, int linksSize, int* linksColSize, int** queries, int queriesSize, int* queriesColSize, int* returnSize) {\n    *returnSize = queriesSize;\n    if (queriesSize == 0) return malloc(sizeof(bool));\n\n    int* raw_times = malloc(sizeof(int) * queriesSize);\n    for (int i = 0; i < queriesSize; i++) raw_times[i] = queries[i][0];\n    qsort(raw_times, queriesSize, sizeof(int), cmp_ints);\n\n    int num_times = 0;\n    int* times = malloc(sizeof(int) * queriesSize);\n    for (int i = 0; i < queriesSize; i++) {\n        if (i == 0 || raw_times[i] != raw_times[i - 1]) {\n            times[num_times++] = raw_times[i];\n        }\n    }\n    free(raw_times);\n\n    int base = 1;\n    while (base < num_times) base *= 2;\n\n    EdgeNode** tree = calloc(2 * base, sizeof(EdgeNode*));\n    for (int i = 0; i < linksSize; i++) {\n        int u = links[i][0], v = links[i][1];\n        int start = links[i][2], end = links[i][3];\n        int left = bisect_left(times, num_times, start) + base;\n        int right = bisect_right(times, num_times, end) + base;\n        while (left < right) {\n            if (left & 1) {\n                EdgeNode* e = malloc(sizeof(EdgeNode));\n                e->u = u; e->v = v; e->next = tree[left];\n                tree[left] = e;\n                left++;\n            }\n            if (right & 1) {\n                right--;\n                EdgeNode* e = malloc(sizeof(EdgeNode));\n                e->u = u; e->v = v; e->next = tree[right];\n                tree[right] = e;\n            }\n            left /= 2;\n            right /= 2;\n        }\n    }\n\n    QueryNode** queries_at_time = calloc(num_times, sizeof(QueryNode*));\n    for (int i = 0; i < queriesSize; i++) {\n        int t_idx = bisect_left(times, num_times, queries[i][0]);\n        QueryNode* q = malloc(sizeof(QueryNode));\n        q->q_index = i; q->u = queries[i][1]; q->v = queries[i][2];\n        q->next = queries_at_time[t_idx];\n        queries_at_time[t_idx] = q;\n    }\n\n    int* parent = malloc(sizeof(int) * n);\n    int* rank = calloc(n, sizeof(int));\n    for (int i = 0; i < n; i++) parent[i] = i;\n\n    History* history = malloc(sizeof(History) * (linksSize * 64 + 100));\n    int hist_len = 0;\n    bool* answer = malloc(sizeof(bool) * queriesSize);\n\n    visit(1, base, num_times, tree, queries_at_time, parent, rank, history, &hist_len, answer);\n\n    // cleanup\n    free(times);\n    free(parent);\n    free(rank);\n    free(history);\n    return answer;\n}\n",
    "tests": [
      {
        "args": [
          3,
          [
            [
              0,
              1,
              0,
              5
            ],
            [
              1,
              2,
              2,
              4
            ]
          ],
          [
            [
              1,
              0,
              2
            ],
            [
              3,
              0,
              2
            ]
          ]
        ],
        "expected": [
          false,
          true
        ]
      },
      {
        "args": [
          2,
          [
            [
              0,
              1,
              1,
              3
            ]
          ],
          [
            [
              1,
              0,
              1
            ],
            [
              3,
              0,
              1
            ]
          ]
        ],
        "expected": [
          true,
          false
        ]
      },
      {
        "args": [
          1,
          [],
          [
            [
              0,
              0,
              0
            ],
            [
              10,
              0,
              0
            ]
          ]
        ],
        "expected": [
          true,
          true
        ]
      },
      {
        "args": [
          3,
          [],
          [
            [
              0,
              0,
              1
            ],
            [
              2,
              1,
              2
            ]
          ]
        ],
        "expected": [
          false,
          false
        ]
      },
      {
        "args": [
          2,
          [
            [
              0,
              1,
              0,
              2
            ],
            [
              0,
              1,
              4,
              6
            ]
          ],
          [
            [
              5,
              0,
              1
            ],
            [
              3,
              0,
              1
            ],
            [
              1,
              0,
              1
            ]
          ]
        ],
        "expected": [
          true,
          false,
          true
        ]
      },
      {
        "args": [
          2,
          [
            [
              0,
              1,
              0,
              5
            ],
            [
              0,
              1,
              2,
              7
            ]
          ],
          [
            [
              4,
              0,
              1
            ],
            [
              6,
              0,
              1
            ],
            [
              7,
              0,
              1
            ]
          ]
        ],
        "expected": [
          true,
          true,
          false
        ]
      },
      {
        "args": [
          4,
          [
            [
              0,
              1,
              0,
              8
            ],
            [
              2,
              3,
              0,
              8
            ],
            [
              0,
              2,
              0,
              4
            ]
          ],
          [
            [
              1,
              3,
              1
            ],
            [
              5,
              3,
              1
            ]
          ]
        ],
        "expected": [
          true,
          false
        ]
      },
      {
        "args": [
          2,
          [
            [
              0,
              1,
              0,
              1
            ]
          ],
          []
        ],
        "expected": []
      }
    ]
  },
  {
    "title": "Route a Shipment With One Express Dispatch",
    "topic": "time-dependent shortest paths and state tracking",
    "difficulty": "hard",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "n",
          "type": "int"
        },
        {
          "name": "routes",
          "type": "int[][]"
        },
        {
          "name": "start_time",
          "type": "int"
        }
      ],
      "returns": "int"
    },
    "description": "A shipment starts at depot `0` at `start_time` and must reach depot `n - 1`.\n\nEach directed route is `[u, v, offset, period, duration]`. Regular vehicles depart depot `u` at times `offset + k * period` for every integer `k >= 0`, and take `duration` time units to reach depot `v`. A shipment arriving exactly at a departure time may board that vehicle. Waiting at depots is allowed.\n\nThe shipment has one express dispatch voucher. At most once during the entire journey, it may traverse any listed route immediately, ignoring its departure schedule but still taking that route's full travel duration. This is allowed even before the route's first regular departure.\n\nImplement `int entryPoint(int n, int** routes, int routesSize, int* routesColSize, int start_time)` to return the earliest absolute arrival time at depot `n - 1`, or `-1` if it is unreachable. The voucher does not need to be used.\n\n### Examples\n- Input: `n = 2, routes = [[0,1,10,5,3]], start_time = 0`\n  Output: `3`\n  Explanation: An express dispatch leaves immediately.\n- Input: `n = 3, routes = [[0,1,0,10,2],[1,2,5,10,2]], start_time = 0`\n  Output: `4`\n  Explanation: Take the first regular departure, then use the voucher.\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= routesSize <= 50000`\n- Routes use valid, distinct endpoints. Parallel routes and directed cycles are allowed.\n- `0 <= offset, start_time <= 1000000000`\n- `1 <= period, duration <= 1000000`\n",
    "fixed_code": "typedef struct {\n    long long time;\n    int node;\n    int used;\n} HeapNode;\n\ntypedef struct {\n    HeapNode* data;\n    int size;\n    int cap;\n} MinHeap;\n\nstatic void heap_push(MinHeap* h, HeapNode item) {\n    if (h->size == h->cap) {\n        h->cap = h->cap ? h->cap * 2 : 1024;\n        h->data = realloc(h->data, sizeof(HeapNode) * h->cap);\n    }\n    int i = h->size++;\n    while (i > 0) {\n        int p = (i - 1) / 2;\n        if (h->data[p].time <= item.time) break;\n        h->data[i] = h->data[p];\n        i = p;\n    }\n    h->data[i] = item;\n}\n\nstatic HeapNode heap_pop(MinHeap* h) {\n    HeapNode ret = h->data[0];\n    HeapNode item = h->data[--h->size];\n    if (h->size == 0) return ret;\n    int i = 0;\n    while (i * 2 + 1 < h->size) {\n        int left = i * 2 + 1;\n        int right = left + 1;\n        int best = left;\n        if (right < h->size && h->data[right].time < h->data[left].time) best = right;\n        if (item.time <= h->data[best].time) break;\n        h->data[i] = h->data[best];\n        i = best;\n    }\n    h->data[i] = item;\n    return ret;\n}\n\ntypedef struct {\n    int target;\n    long long offset;\n    long long period;\n    long long duration;\n} Edge;\n\ntypedef struct {\n    Edge* edges;\n    int count;\n    int cap;\n} NodeEdges;\n\nint entryPoint(int n, int** routes, int routesSize, int* routesColSize, int start_time) {\n    NodeEdges* graph = calloc(n, sizeof(NodeEdges));\n    for (int i = 0; i < routesSize; i++) {\n        int u = routes[i][0];\n        int v = routes[i][1];\n        long long offset = routes[i][2];\n        long long period = routes[i][3];\n        long long duration = routes[i][4];\n        if (graph[u].count == graph[u].cap) {\n            graph[u].cap = graph[u].cap ? graph[u].cap * 2 : 4;\n            graph[u].edges = realloc(graph[u].edges, sizeof(Edge) * graph[u].cap);\n        }\n        graph[u].edges[graph[u].count++] = (Edge){v, offset, period, duration};\n    }\n\n    long long (*best)[2] = malloc(sizeof(long long[2]) * n);\n    for (int i = 0; i < n; i++) {\n        best[i][0] = LLONG_MAX;\n        best[i][1] = LLONG_MAX;\n    }\n    best[0][0] = start_time;\n\n    MinHeap h = {0};\n    heap_push(&h, (HeapNode){start_time, 0, 0});\n\n    long long ans = -1;\n    while (h.size > 0) {\n        HeapNode top = heap_pop(&h);\n        if (top.time != best[top.node][top.used]) continue;\n        if (top.node == n - 1) {\n            ans = top.time;\n            break;\n        }\n        for (int i = 0; i < graph[top.node].count; i++) {\n            Edge e = graph[top.node].edges[i];\n            long long departure;\n            if (top.time <= e.offset) {\n                departure = e.offset;\n            } else {\n                departure = e.offset + ((top.time - e.offset + e.period - 1) / e.period) * e.period;\n            }\n            long long arrival = departure + e.duration;\n            if (arrival < best[e.target][top.used]) {\n                best[e.target][top.used] = arrival;\n                heap_push(&h, (HeapNode){arrival, e.target, top.used});\n            }\n            if (top.used == 0) {\n                long long express_arrival = top.time + e.duration;\n                if (express_arrival < best[e.target][1]) {\n                    best[e.target][1] = express_arrival;\n                    heap_push(&h, (HeapNode){express_arrival, e.target, 1});\n                }\n            }\n        }\n    }\n\n    for (int i = 0; i < n; i++) free(graph[i].edges);\n    free(graph);\n    free(best);\n    free(h.data);\n    return (int)ans;\n}\n",
    "buggy_code": "typedef struct {\n    long long time;\n    int node;\n    int used;\n} HeapNode;\n\ntypedef struct {\n    HeapNode* data;\n    int size;\n    int cap;\n} MinHeap;\n\nstatic void heap_push(MinHeap* h, HeapNode item) {\n    if (h->size == h->cap) {\n        h->cap = h->cap ? h->cap * 2 : 1024;\n        h->data = realloc(h->data, sizeof(HeapNode) * h->cap);\n    }\n    int i = h->size++;\n    while (i > 0) {\n        int p = (i - 1) / 2;\n        if (h->data[p].time <= item.time) break;\n        h->data[i] = h->data[p];\n        i = p;\n    }\n    h->data[i] = item;\n}\n\nstatic HeapNode heap_pop(MinHeap* h) {\n    HeapNode ret = h->data[0];\n    HeapNode item = h->data[--h->size];\n    if (h->size == 0) return ret;\n    int i = 0;\n    while (i * 2 + 1 < h->size) {\n        int left = i * 2 + 1;\n        int right = left + 1;\n        int best = left;\n        if (right < h->size && h->data[right].time < h->data[left].time) best = right;\n        if (item.time <= h->data[best].time) break;\n        h->data[i] = h->data[best];\n        i = best;\n    }\n    h->data[i] = item;\n    return ret;\n}\n\ntypedef struct {\n    int target;\n    long long offset;\n    long long period;\n    long long duration;\n} Edge;\n\ntypedef struct {\n    Edge* edges;\n    int count;\n    int cap;\n} NodeEdges;\n\nint entryPoint(int n, int** routes, int routesSize, int* routesColSize, int start_time) {\n    NodeEdges* graph = calloc(n, sizeof(NodeEdges));\n    for (int i = 0; i < routesSize; i++) {\n        int u = routes[i][0];\n        int v = routes[i][1];\n        long long offset = routes[i][2];\n        long long period = routes[i][3];\n        long long duration = routes[i][4];\n        if (graph[u].count == graph[u].cap) {\n            graph[u].cap = graph[u].cap ? graph[u].cap * 2 : 4;\n            graph[u].edges = realloc(graph[u].edges, sizeof(Edge) * graph[u].cap);\n        }\n        graph[u].edges[graph[u].count++] = (Edge){v, offset, period, duration};\n    }\n\n    long long (*best)[2] = malloc(sizeof(long long[2]) * n);\n    for (int i = 0; i < n; i++) {\n        best[i][0] = LLONG_MAX;\n        best[i][1] = LLONG_MAX;\n    }\n    best[0][0] = start_time;\n\n    MinHeap h = {0};\n    heap_push(&h, (HeapNode){start_time, 0, 0});\n\n    long long ans = -1;\n    while (h.size > 0) {\n        HeapNode top = heap_pop(&h);\n        if (top.time != best[top.node][top.used]) continue;\n        if (top.node == n - 1) {\n            ans = top.time;\n            break;\n        }\n        for (int i = 0; i < graph[top.node].count; i++) {\n            Edge e = graph[top.node].edges[i];\n            long long departure;\n            if (top.time <= e.offset) {\n                departure = e.offset;\n            } else {\n                departure = e.offset + ((top.time - e.offset + e.period) / e.period) * e.period;\n            }\n            long long arrival = departure + e.duration;\n            if (arrival < best[e.target][0]) {\n                best[e.target][0] = arrival;\n                heap_push(&h, (HeapNode){arrival, e.target, 0});\n            }\n            if (top.used == 0) {\n                long long express_arrival = top.time + e.duration;\n                if (express_arrival < best[e.target][1]) {\n                    best[e.target][1] = express_arrival;\n                    heap_push(&h, (HeapNode){express_arrival, e.target, 1});\n                }\n            }\n        }\n    }\n\n    for (int i = 0; i < n; i++) free(graph[i].edges);\n    free(graph);\n    free(best);\n    free(h.data);\n    return (int)ans;\n}\n",
    "tests": [
      {
        "args": [
          2,
          [
            [
              0,
              1,
              10,
              5,
              3
            ]
          ],
          0
        ],
        "expected": 3
      },
      {
        "args": [
          3,
          [
            [
              0,
              1,
              0,
              10,
              2
            ],
            [
              1,
              2,
              5,
              10,
              2
            ]
          ],
          0
        ],
        "expected": 4
      },
      {
        "args": [
          1,
          [],
          7
        ],
        "expected": 7
      },
      {
        "args": [
          3,
          [
            [
              0,
              1,
              0,
              1,
              2
            ]
          ],
          0
        ],
        "expected": -1
      },
      {
        "args": [
          3,
          [
            [
              0,
              1,
              10,
              100,
              1
            ],
            [
              1,
              2,
              20,
              100,
              1
            ]
          ],
          0
        ],
        "expected": 12
      },
      {
        "args": [
          3,
          [
            [
              0,
              1,
              0,
              5,
              5
            ],
            [
              1,
              2,
              0,
              5,
              2
            ]
          ],
          0
        ],
        "expected": 7
      },
      {
        "args": [
          4,
          [
            [
              0,
              1,
              0,
              10,
              1
            ],
            [
              1,
              3,
              50,
              100,
              1
            ],
            [
              0,
              2,
              0,
              1,
              10
            ],
            [
              2,
              3,
              0,
              1,
              10
            ]
          ],
          0
        ],
        "expected": 2
      },
      {
        "args": [
          3,
          [
            [
              0,
              1,
              0,
              4,
              1
            ],
            [
              1,
              0,
              0,
              4,
              1
            ],
            [
              1,
              2,
              0,
              4,
              1
            ]
          ],
          3
        ],
        "expected": 5
      },
      {
        "args": [
          3,
          [
            [
              0,
              1,
              10,
              100,
              5
            ],
            [
              1,
              2,
              0,
              5,
              2
            ]
          ],
          0
        ],
        "expected": 7
      },
      {
        "args": [
          4,
          [
            [
              0,
              1,
              10,
              100,
              1
            ],
            [
              1,
              2,
              0,
              1,
              1
            ],
            [
              2,
              3,
              20,
              100,
              1
            ]
          ],
          0
        ],
        "expected": 13
      }
    ]
  },
  {
    "title": "Price a Wildcard Encoding",
    "topic": "tries, wildcard matching, and dynamic programming",
    "difficulty": "hard",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "text",
          "type": "string"
        },
        {
          "name": "patterns",
          "type": "string[]"
        },
        {
          "name": "costs",
          "type": "int[]"
        }
      ],
      "returns": "int[]"
    },
    "description": "An encoding service must cover a text using a sequence of catalog entries represented as two parallel arrays: `patterns` and `costs`. `patterns[i]` is the pattern string and `costs[i]` is its cost.\n\nA pattern contains lowercase English letters and may contain `?`, which matches exactly one lowercase letter. Applying an entry consumes a consecutive portion of the text whose length equals the pattern's length. Entries must cover the entire text in order, without gaps or overlaps. Every catalog entry may be reused any number of times.\n\nImplement `int* entryPoint(char* text, char** patterns, int patternsSize, int* costs, int costsSize, int* returnSize)` to return a dynamically allocated array `[minimum_cost, optimal_encoding_count]`. Set `*returnSize` to `2`. Count optimal encodings modulo `1000000007`.\n\nAn encoding is identified by its ordered sequence of catalog indices. Duplicate catalog rows are distinct choices. Different matching characters for a wildcard do not create additional choices because the text is fixed.\n\nReturn `[-1, 0]` if the text cannot be covered. The empty text has cost `0` and exactly one encoding: the empty sequence.\n\n### Examples\n- Input: `text = \"ab\", patterns = [\"a\", \"b\", \"ab\"], costs = [2, 3, 4]`\n  Output: `[4, 1]`\n- Input: `text = \"ab\", patterns = [\"a\", \"b\", \"??\"], costs = [1, 1, 2]`\n  Output: `[2, 2]`\n\n### Constraints\n- `0 <= strlen(text) <= 2000`\n- `text` contains only lowercase English letters.\n- `0 <= patternsSize == costsSize <= 200`\n- Each pattern has length between `1` and `30`.\n- `0 <= costs[i] <= 1000000`\n",
    "fixed_code": "#define MOD 1000000007LL\n\ntypedef struct {\n    int cost;\n    int length;\n} PatternEntry;\n\ntypedef struct {\n    int next[27];\n    PatternEntry* entries;\n    int entry_count;\n    int entry_cap;\n} TrieNode;\n\nstatic TrieNode trie[6005];\nstatic int trie_size = 0;\n\nstatic int new_node(void) {\n    int idx = trie_size++;\n    memset(trie[idx].next, 0, sizeof(trie[idx].next));\n    trie[idx].entries = NULL;\n    trie[idx].entry_count = 0;\n    trie[idx].entry_cap = 0;\n    return idx;\n}\n\nstatic void add_entry(int node, int cost, int length) {\n    if (trie[node].entry_count == trie[node].entry_cap) {\n        trie[node].entry_cap = trie[node].entry_cap ? trie[node].entry_cap * 2 : 2;\n        trie[node].entries = realloc(trie[node].entries, sizeof(PatternEntry) * trie[node].entry_cap);\n    }\n    trie[node].entries[trie[node].entry_count++] = (PatternEntry){cost, length};\n}\n\nstatic void search(int pos, int node_idx, int start, int n, char* text, long long* best, long long* ways) {\n    TrieNode* node = &trie[node_idx];\n    if (node->entry_count > 0) {\n        for (int i = 0; i < node->entry_count; i++) {\n            int cost = node->entries[i].cost;\n            int length = node->entries[i].length;\n            int end = start + length - 1;\n            long long candidate = best[start] + cost;\n            if (candidate < best[end + 1]) {\n                best[end + 1] = candidate;\n                ways[end + 1] = ways[start];\n            } else if (candidate == best[end + 1]) {\n                ways[end + 1] = (ways[end + 1] + ways[start]) % MOD;\n            }\n        }\n    }\n    if (pos < n) {\n        char ch = text[pos];\n        int ch_idx = ch - 'a';\n        if (node->next[ch_idx] != 0) {\n            search(pos + 1, node->next[ch_idx], start, n, text, best, ways);\n        }\n        if (node->next[26] != 0) {\n            search(pos + 1, node->next[26], start, n, text, best, ways);\n        }\n    }\n}\n\nint* entryPoint(char* text, char** patterns, int patternsSize, int* costs, int costsSize, int* returnSize) {\n    trie_size = 0;\n    int root = new_node();\n\n    for (int i = 0; i < patternsSize; i++) {\n        int curr = root;\n        char* p = patterns[i];\n        int len = strlen(p);\n        for (int j = 0; j < len; j++) {\n            int idx = (p[j] == '?') ? 26 : (p[j] - 'a');\n            if (trie[curr].next[idx] == 0) {\n                trie[curr].next[idx] = new_node();\n            }\n            curr = trie[curr].next[idx];\n        }\n        add_entry(curr, costs[i], len);\n    }\n\n    int n = strlen(text);\n    long long* best = malloc(sizeof(long long) * (n + 1));\n    long long* ways = malloc(sizeof(long long) * (n + 1));\n    for (int i = 0; i <= n; i++) {\n        best[i] = LLONG_MAX / 2;\n        ways[i] = 0;\n    }\n    best[0] = 0;\n    ways[0] = 1;\n\n    for (int start = 0; start < n; start++) {\n        if (best[start] >= LLONG_MAX / 4) continue;\n        search(start, root, start, n, text, best, ways);\n    }\n\n    int* ans = malloc(sizeof(int) * 2);\n    *returnSize = 2;\n    if (best[n] >= LLONG_MAX / 4) {\n        ans[0] = -1;\n        ans[1] = 0;\n    } else {\n        ans[0] = (int)best[n];\n        ans[1] = (int)ways[n];\n    }\n\n    for (int i = 0; i < trie_size; i++) free(trie[i].entries);\n    free(best);\n    free(ways);\n    return ans;\n}\n",
    "buggy_code": "#define MOD 1000000007LL\n\ntypedef struct {\n    int cost;\n    int length;\n} PatternEntry;\n\ntypedef struct {\n    int next[27];\n    PatternEntry* entries;\n    int entry_count;\n    int entry_cap;\n} TrieNode;\n\nstatic TrieNode trie[6005];\nstatic int trie_size = 0;\n\nstatic int new_node(void) {\n    int idx = trie_size++;\n    memset(trie[idx].next, 0, sizeof(trie[idx].next));\n    trie[idx].entries = NULL;\n    trie[idx].entry_count = 0;\n    trie[idx].entry_cap = 0;\n    return idx;\n}\n\nstatic void add_entry(int node, int cost, int length) {\n    if (trie[node].entry_count == trie[node].entry_cap) {\n        trie[node].entry_cap = trie[node].entry_cap ? trie[node].entry_cap * 2 : 2;\n        trie[node].entries = realloc(trie[node].entries, sizeof(PatternEntry) * trie[node].entry_cap);\n    }\n    trie[node].entries[trie[node].entry_count++] = (PatternEntry){cost, length};\n}\n\nstatic void search(int pos, int node_idx, int start, int n, char* text, long long* best, long long* ways) {\n    TrieNode* node = &trie[node_idx];\n    if (node->entry_count > 0) {\n        for (int i = 0; i < node->entry_count; i++) {\n            int cost = node->entries[i].cost;\n            int length = node->entries[i].length;\n            int end = start + length - 1;\n            long long candidate = best[start] + cost;\n            if (candidate < best[end + 1]) {\n                best[end + 1] = candidate;\n                ways[end + 1] = (ways[end + 1] + ways[start]) % MOD;\n            } else if (candidate == best[end + 1]) {\n                ways[end + 1] = ways[start];\n            }\n        }\n    }\n    if (pos < n) {\n        char ch = text[pos];\n        int ch_idx = ch - 'a';\n        if (node->next[ch_idx] != 0) {\n            search(pos + 1, node->next[ch_idx], start, n, text, best, ways);\n        }\n        if (node->next[26] != 0) {\n            search(pos + 1, node->next[26], start, n, text, best, ways);\n        }\n    }\n}\n\nint* entryPoint(char* text, char** patterns, int patternsSize, int* costs, int costsSize, int* returnSize) {\n    trie_size = 0;\n    int root = new_node();\n\n    for (int i = 0; i < patternsSize; i++) {\n        int curr = root;\n        char* p = patterns[i];\n        int len = strlen(p);\n        for (int j = 0; j < len; j++) {\n            int idx = (p[j] == '?') ? 26 : (p[j] - 'a');\n            if (trie[curr].next[idx] == 0) {\n                trie[curr].next[idx] = new_node();\n            }\n            curr = trie[curr].next[idx];\n        }\n        add_entry(curr, costs[i], len);\n    }\n\n    int n = strlen(text);\n    long long* best = malloc(sizeof(long long) * (n + 1));\n    long long* ways = malloc(sizeof(long long) * (n + 1));\n    for (int i = 0; i <= n; i++) {\n        best[i] = LLONG_MAX / 2;\n        ways[i] = 0;\n    }\n    best[0] = 0;\n    ways[0] = 1;\n\n    for (int start = 0; start < n; start++) {\n        if (best[start] >= LLONG_MAX / 4) continue;\n        search(start, root, start, n, text, best, ways);\n    }\n\n    int* ans = malloc(sizeof(int) * 2);\n    *returnSize = 2;\n    if (best[n] >= LLONG_MAX / 4) {\n        ans[0] = -1;\n        ans[1] = 0;\n    } else {\n        ans[0] = (int)best[n];\n        ans[1] = (int)ways[n];\n    }\n\n    for (int i = 0; i < trie_size; i++) free(trie[i].entries);\n    free(best);\n    free(ways);\n    return ans;\n}\n",
    "tests": [
      {
        "args": [
          "ab",
          [
            "a",
            "b",
            "ab"
          ],
          [
            2,
            3,
            4
          ]
        ],
        "expected": [
          4,
          1
        ]
      },
      {
        "args": [
          "ab",
          [
            "a",
            "b",
            "??"
          ],
          [
            1,
            1,
            2
          ]
        ],
        "expected": [
          2,
          2
        ]
      },
      {
        "args": [
          "",
          [
            "?"
          ],
          [
            5
          ]
        ],
        "expected": [
          0,
          1
        ]
      },
      {
        "args": [
          "abc",
          [
            "a",
            "b"
          ],
          [
            1,
            1
          ]
        ],
        "expected": [
          -1,
          0
        ]
      },
      {
        "args": [
          "a",
          [
            "a",
            "?"
          ],
          [
            5,
            2
          ]
        ],
        "expected": [
          2,
          1
        ]
      },
      {
        "args": [
          "aa",
          [
            "a",
            "a"
          ],
          [
            1,
            1
          ]
        ],
        "expected": [
          2,
          4
        ]
      },
      {
        "args": [
          "ab",
          [
            "a",
            "b",
            "ab",
            "??"
          ],
          [
            1,
            1,
            5,
            2
          ]
        ],
        "expected": [
          2,
          2
        ]
      },
      {
        "args": [
          "aaa",
          [
            "a",
            "aa",
            "?"
          ],
          [
            0,
            0,
            0
          ]
        ],
        "expected": [
          0,
          12
        ]
      }
    ]
  },
  {
    "title": "Choose Profitable Equipment Reservations",
    "topic": "interval optimization and minimum-cost flow",
    "difficulty": "hard",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "jobs",
          "type": "int[][]"
        },
        {
          "name": "capacity",
          "type": "int"
        }
      ],
      "returns": "int"
    },
    "description": "A laboratory owns `capacity` interchangeable pieces of equipment. Each requested job is `[start, end, profit]` and requires one piece of equipment continuously throughout the half-open interval `[start, end)`.\n\nThe laboratory may accept or reject each job. Accepted jobs cannot be interrupted, and no more than `capacity` accepted jobs may be active at any time. A piece of equipment may be reused immediately when a job ends.\n\nImplement `int entryPoint(int** jobs, int jobsSize, int* jobsColSize, int capacity)` to return the maximum total profit obtainable.\n\nEach list position represents a separate request, even when multiple requests have identical values. Each request may be accepted at most once. Accepting no jobs is allowed.\n\n### Examples\n- Input: `jobs = [[0,2,5],[1,3,7]], capacity = 1`\n  Output: `7`\n- Input: `jobs = [[0,2,5],[1,3,7]], capacity = 2`\n  Output: `12`\n\n### Constraints\n- `0 <= jobsSize <= 500`\n- `1 <= capacity <= 20`\n- `0 <= start < end <= 1000000000`\n- `1 <= profit <= 1000000`\n- Jobs may be unsorted, duplicated, nested, or adjacent.\n",
    "fixed_code": "typedef struct {\n    int v;\n    int limit;\n    int cost;\n    int reverse;\n} FlowEdge;\n\ntypedef struct {\n    FlowEdge* edges;\n    int count;\n    int cap;\n} FlowNode;\n\nstatic void add_edge(FlowNode* graph, int u, int v, int limit, int cost) {\n    if (graph[u].count == graph[u].cap) {\n        graph[u].cap = graph[u].cap ? graph[u].cap * 2 : 4;\n        graph[u].edges = realloc(graph[u].edges, sizeof(FlowEdge) * graph[u].cap);\n    }\n    if (graph[v].count == graph[v].cap) {\n        graph[v].cap = graph[v].cap ? graph[v].cap * 2 : 4;\n        graph[v].edges = realloc(graph[v].edges, sizeof(FlowEdge) * graph[v].cap);\n    }\n    int u_idx = graph[u].count++;\n    int v_idx = graph[v].count++;\n    graph[u].edges[u_idx] = (FlowEdge){v, limit, cost, v_idx};\n    graph[v].edges[v_idx] = (FlowEdge){u, 0, -cost, u_idx};\n}\n\nstatic int cmp_times(const void* a, const void* b) {\n    int ia = *(const int*)a;\n    int ib = *(const int*)b;\n    return (ia > ib) - (ia < ib);\n}\n\nint entryPoint(int** jobs, int jobsSize, int* jobsColSize, int capacity) {\n    if (jobsSize == 0) return 0;\n\n    int* raw_times = malloc(sizeof(int) * jobsSize * 2);\n    int t_cnt = 0;\n    for (int i = 0; i < jobsSize; i++) {\n        raw_times[t_cnt++] = jobs[i][0];\n        raw_times[t_cnt++] = jobs[i][1];\n    }\n    qsort(raw_times, t_cnt, sizeof(int), cmp_times);\n\n    int num_times = 0;\n    int* times = malloc(sizeof(int) * t_cnt);\n    for (int i = 0; i < t_cnt; i++) {\n        if (i == 0 || raw_times[i] != raw_times[i - 1]) {\n            times[num_times++] = raw_times[i];\n        }\n    }\n    free(raw_times);\n\n    FlowNode* graph = calloc(num_times, sizeof(FlowNode));\n    for (int i = 0; i < num_times - 1; i++) {\n        add_edge(graph, i, i + 1, capacity, 0);\n    }\n\n    for (int i = 0; i < jobsSize; i++) {\n        int start = jobs[i][0], end = jobs[i][1], profit = jobs[i][2];\n        int u = -1, v = -1;\n        // binary search for start and end\n        int l = 0, r = num_times - 1;\n        while (l <= r) {\n            int m = (l + r) / 2;\n            if (times[m] == start) { u = m; break; }\n            if (times[m] < start) l = m + 1; else r = m - 1;\n        }\n        l = 0; r = num_times - 1;\n        while (l <= r) {\n            int m = (l + r) / 2;\n            if (times[m] == end) { v = m; break; }\n            if (times[m] < end) l = m + 1; else r = m - 1;\n        }\n        add_edge(graph, u, v, 1, -profit);\n    }\n\n    int total = 0;\n    int remaining = capacity;\n\n    int* dist = malloc(sizeof(int) * num_times);\n    int* prev_node = malloc(sizeof(int) * num_times);\n    int* prev_edge = malloc(sizeof(int) * num_times);\n    int* queue = malloc(sizeof(int) * (num_times * 4 + 100));\n    bool* in_queue = calloc(num_times, sizeof(bool));\n\n    while (remaining > 0) {\n        for (int i = 0; i < num_times; i++) {\n            dist[i] = 1e9;\n            prev_node[i] = -1;\n            prev_edge[i] = -1;\n            in_queue[i] = false;\n        }\n        dist[0] = 0;\n        int q_head = 0, q_tail = 0;\n        queue[q_tail++] = 0;\n        in_queue[0] = true;\n\n        while (q_head < q_tail) {\n            int u = queue[q_head++];\n            in_queue[u] = false;\n            for (int e = 0; e < graph[u].count; e++) {\n                FlowEdge edge = graph[u].edges[e];\n                if (edge.limit > 0 && dist[u] + edge.cost < dist[edge.v]) {\n                    dist[edge.v] = dist[u] + edge.cost;\n                    prev_node[edge.v] = u;\n                    prev_edge[edge.v] = e;\n                    if (!in_queue[edge.v]) {\n                        queue[q_tail++] = edge.v;\n                        in_queue[edge.v] = true;\n                    }\n                }\n            }\n        }\n\n        if (dist[num_times - 1] >= 1e8) break;\n\n        int pushed = remaining;\n        int curr = num_times - 1;\n        while (curr > 0) {\n            int u = prev_node[curr];\n            int e = prev_edge[curr];\n            if (graph[u].edges[e].limit < pushed) {\n                pushed = graph[u].edges[e].limit;\n            }\n            curr = u;\n        }\n\n        curr = num_times - 1;\n        while (curr > 0) {\n            int u = prev_node[curr];\n            int e = prev_edge[curr];\n            graph[u].edges[e].limit -= pushed;\n            int rev = graph[u].edges[e].reverse;\n            graph[curr].edges[rev].limit += pushed;\n            curr = u;\n        }\n\n        remaining -= pushed;\n        total -= pushed * dist[num_times - 1];\n    }\n\n    for (int i = 0; i < num_times; i++) free(graph[i].edges);\n    free(graph);\n    free(times);\n    free(dist);\n    free(prev_node);\n    free(prev_edge);\n    free(queue);\n    free(in_queue);\n\n    return total;\n}\n",
    "buggy_code": "typedef struct {\n    int v;\n    int limit;\n    int cost;\n    int reverse;\n} FlowEdge;\n\ntypedef struct {\n    FlowEdge* edges;\n    int count;\n    int cap;\n} FlowNode;\n\nstatic void add_edge(FlowNode* graph, int u, int v, int limit, int cost) {\n    if (graph[u].count == graph[u].cap) {\n        graph[u].cap = graph[u].cap ? graph[u].cap * 2 : 4;\n        graph[u].edges = realloc(graph[u].edges, sizeof(FlowEdge) * graph[u].cap);\n    }\n    if (graph[v].count == graph[v].cap) {\n        graph[v].cap = graph[v].cap ? graph[v].cap * 2 : 4;\n        graph[v].edges = realloc(graph[v].edges, sizeof(FlowEdge) * graph[v].cap);\n    }\n    int u_idx = graph[u].count++;\n    int v_idx = graph[v].count++;\n    graph[u].edges[u_idx] = (FlowEdge){v, limit, cost, v_idx};\n    graph[v].edges[v_idx] = (FlowEdge){u, 0, -cost, u_idx};\n}\n\nstatic int cmp_times(const void* a, const void* b) {\n    int ia = *(const int*)a;\n    int ib = *(const int*)b;\n    return (ia > ib) - (ia < ib);\n}\n\nint entryPoint(int** jobs, int jobsSize, int* jobsColSize, int capacity) {\n    if (jobsSize == 0) return 0;\n\n    int* raw_times = malloc(sizeof(int) * jobsSize * 2);\n    int t_cnt = 0;\n    for (int i = 0; i < jobsSize; i++) {\n        raw_times[t_cnt++] = jobs[i][0];\n        raw_times[t_cnt++] = jobs[i][1];\n    }\n    qsort(raw_times, t_cnt, sizeof(int), cmp_times);\n\n    int num_times = 0;\n    int* times = malloc(sizeof(int) * t_cnt);\n    for (int i = 0; i < t_cnt; i++) {\n        if (i == 0 || raw_times[i] != raw_times[i - 1]) {\n            times[num_times++] = raw_times[i];\n        }\n    }\n    free(raw_times);\n\n    FlowNode* graph = calloc(num_times, sizeof(FlowNode));\n    for (int i = 0; i < num_times - 1; i++) {\n        add_edge(graph, i, i + 1, capacity, 0);\n    }\n\n    for (int i = 0; i < jobsSize; i++) {\n        int start = jobs[i][0], end = jobs[i][1], profit = jobs[i][2];\n        bool duplicate = false;\n        for (int j = 0; j < i; j++) {\n            if (jobs[j][0] == start && jobs[j][1] == end && jobs[j][2] == profit) {\n                duplicate = true;\n                break;\n            }\n        }\n        if (duplicate) continue;\n\n        int u = -1, v = -1;\n        int l = 0, r = num_times - 1;\n        while (l <= r) {\n            int m = (l + r) / 2;\n            if (times[m] == start) { u = m; break; }\n            if (times[m] < start) l = m + 1; else r = m - 1;\n        }\n        l = 0; r = num_times - 1;\n        while (l <= r) {\n            int m = (l + r) / 2;\n            if (times[m] == end) { v = m; break; }\n            if (times[m] < end) l = m + 1; else r = m - 1;\n        }\n        add_edge(graph, u, v, 1, -profit);\n    }\n\n    int total = 0;\n    int remaining = capacity;\n\n    int* dist = malloc(sizeof(int) * num_times);\n    int* prev_node = malloc(sizeof(int) * num_times);\n    int* prev_edge = malloc(sizeof(int) * num_times);\n    int* queue = malloc(sizeof(int) * (num_times * 4 + 100));\n    bool* in_queue = calloc(num_times, sizeof(bool));\n\n    while (remaining > 0) {\n        for (int i = 0; i < num_times; i++) {\n            dist[i] = 1e9;\n            prev_node[i] = -1;\n            prev_edge[i] = -1;\n            in_queue[i] = false;\n        }\n        dist[0] = 0;\n        int q_head = 0, q_tail = 0;\n        queue[q_tail++] = 0;\n        in_queue[0] = true;\n\n        while (q_head < q_tail) {\n            int u = queue[q_head++];\n            in_queue[u] = false;\n            for (int e = 0; e < graph[u].count; e++) {\n                FlowEdge edge = graph[u].edges[e];\n                if (edge.limit > 0 && dist[u] + edge.cost < dist[edge.v]) {\n                    dist[edge.v] = dist[u] + edge.cost;\n                    prev_node[edge.v] = u;\n                    prev_edge[edge.v] = e;\n                    if (!in_queue[edge.v]) {\n                        queue[q_tail++] = edge.v;\n                        in_queue[edge.v] = true;\n                    }\n                }\n            }\n        }\n\n        if (dist[num_times - 1] >= 1e8) break;\n\n        int pushed = remaining;\n        int curr = num_times - 1;\n        while (curr > 0) {\n            int u = prev_node[curr];\n            int e = prev_edge[curr];\n            if (graph[u].edges[e].limit < pushed) {\n                pushed = graph[u].edges[e].limit;\n            }\n            curr = u;\n        }\n\n        curr = num_times - 1;\n        while (curr > 0) {\n            int u = prev_node[curr];\n            int e = prev_edge[curr];\n            graph[u].edges[e].limit -= pushed;\n            curr = u;\n        }\n\n        remaining -= pushed;\n        total -= pushed * dist[num_times - 1];\n    }\n\n    for (int i = 0; i < num_times; i++) free(graph[i].edges);\n    free(graph);\n    free(times);\n    free(dist);\n    free(prev_node);\n    free(prev_edge);\n    free(queue);\n    free(in_queue);\n\n    return total;\n}\n",
    "tests": [
      {
        "args": [
          [
            [
              0,
              2,
              5
            ],
            [
              1,
              3,
              7
            ]
          ],
          1
        ],
        "expected": 7
      },
      {
        "args": [
          [
            [
              0,
              2,
              5
            ],
            [
              1,
              3,
              7
            ]
          ],
          2
        ],
        "expected": 12
      },
      {
        "args": [
          [],
          3
        ],
        "expected": 0
      },
      {
        "args": [
          [
            [
              0,
              2,
              5
            ],
            [
              2,
              4,
              6
            ]
          ],
          1
        ],
        "expected": 11
      },
      {
        "args": [
          [
            [
              0,
              5,
              4
            ],
            [
              0,
              5,
              4
            ],
            [
              0,
              5,
              4
            ]
          ],
          2
        ],
        "expected": 8
      },
      {
        "args": [
          [
            [
              0,
              10,
              12
            ],
            [
              0,
              4,
              7
            ],
            [
              4,
              10,
              7
            ]
          ],
          1
        ],
        "expected": 14
      },
      {
        "args": [
          [
            [
              0,
              4,
              8
            ],
            [
              2,
              6,
              9
            ],
            [
              4,
              8,
              8
            ],
            [
              0,
              8,
              14
            ]
          ],
          2
        ],
        "expected": 30
      },
      {
        "args": [
          [
            [
              1,
              2,
              3
            ]
          ],
          4
        ],
        "expected": 3
      },
      {
        "args": [
          [
            [
              3,
              4,
              5
            ],
            [
              5,
              8,
              8
            ],
            [
              1,
              2,
              6
            ],
            [
              0,
              5,
              10
            ],
            [
              3,
              6,
              9
            ]
          ],
          2
        ],
        "expected": 33
      }
    ]
  },
  {
    "title": "Balance Consecutive Reconciliation Batches",
    "topic": "dynamic programming and Li Chao trees",
    "difficulty": "hard",
    "language": "c",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "values",
          "type": "int[]"
        },
        {
          "name": "groups",
          "type": "int"
        },
        {
          "name": "target",
          "type": "int"
        }
      ],
      "returns": "int"
    },
    "description": "A financial reconciliation system receives an ordered list of signed adjustments. It must partition the entire list into exactly `groups` nonempty, consecutive batches without changing their order.\n\nFor a batch whose adjustments sum to `s`, its penalty is `(s - target)²`. Positive and negative adjustments may cancel within a batch.\n\nImplement `int entryPoint(int* values, int valuesSize, int groups, int target)` to return the minimum possible sum of batch penalties. Every adjustment must belong to exactly one batch.\n\n### Examples\n- Input: `values = [1,2], groups = 1, target = 3`\n  Output: `0`\n  Explanation: The single batch sums to the target.\n- Input: `values = [1,2], groups = 2, target = 2`\n  Output: `1`\n  Explanation: The required batches are `[1]` and `[2]`, with penalties `1` and `0`.\n\n### Constraints\n- `1 <= valuesSize <= 5000`\n- `1 <= groups <= min(30, valuesSize)`\n- `-10000 <= values[i], target <= 10000`\n- All inputs are integers.\n",
    "fixed_code": "#define INF (1LL << 60)\n\ntypedef struct {\n    long long m;\n    long long c;\n    bool has_line;\n} Line;\n\nstatic inline long long eval_line(Line l, long long x) {\n    return l.m * x + l.c;\n}\n\nstatic void insert_line(Line* tree, long long* xs, Line line, int node, int left, int right) {\n    if (!tree[node].has_line) {\n        tree[node] = line;\n        return;\n    }\n    int middle = (left + right) / 2;\n    bool better_left = eval_line(line, xs[left]) < eval_line(tree[node], xs[left]);\n    bool better_middle = eval_line(line, xs[middle]) < eval_line(tree[node], xs[middle]);\n    if (better_middle) {\n        Line tmp = tree[node];\n        tree[node] = line;\n        line = tmp;\n    }\n    if (left == right) return;\n    if (better_left != better_middle) {\n        insert_line(tree, xs, line, node * 2, left, middle);\n    } else {\n        insert_line(tree, xs, line, node * 2 + 1, middle + 1, right);\n    }\n}\n\nstatic long long query_line(Line* tree, long long* xs, long long x, int node, int left, int right) {\n    long long ans = tree[node].has_line ? eval_line(tree[node], x) : INF;\n    if (left == right) return ans;\n    int middle = (left + right) / 2;\n    if (x <= xs[middle]) {\n        long long res = query_line(tree, xs, x, node * 2, left, middle);\n        return res < ans ? res : ans;\n    } else {\n        long long res = query_line(tree, xs, x, node * 2 + 1, middle + 1, right);\n        return res < ans ? res : ans;\n    }\n}\n\nstatic int cmp_ll(const void* a, const void* b) {\n    long long ia = *(const long long*)a;\n    long long ib = *(const long long*)b;\n    return (ia > ib) - (ia < ib);\n}\n\nint entryPoint(int* values, int valuesSize, int groups, int target) {\n    int n = valuesSize;\n    long long* prefix = malloc(sizeof(long long) * (n + 1));\n    prefix[0] = 0;\n    for (int i = 0; i < n; i++) prefix[i + 1] = prefix[i] + values[i];\n\n    long long* raw_xs = malloc(sizeof(long long) * n);\n    for (int i = 1; i <= n; i++) raw_xs[i - 1] = prefix[i] - target;\n    qsort(raw_xs, n, sizeof(long long), cmp_ll);\n\n    int xs_count = 0;\n    long long* xs = malloc(sizeof(long long) * n);\n    for (int i = 0; i < n; i++) {\n        if (i == 0 || raw_xs[i] != raw_xs[i - 1]) {\n            xs[xs_count++] = raw_xs[i];\n        }\n    }\n    free(raw_xs);\n\n    long long* previous = malloc(sizeof(long long) * (n + 1));\n    for (int i = 0; i <= n; i++) previous[i] = (i == 0) ? 0 : INF;\n\n    Line* tree = malloc(sizeof(Line) * (4 * xs_count + 4));\n\n    for (int layer = 0; layer < groups; layer++) {\n        memset(tree, 0, sizeof(Line) * (4 * xs_count + 4));\n        long long* current = malloc(sizeof(long long) * (n + 1));\n        for (int i = 0; i <= n; i++) current[i] = INF;\n\n        if (previous[0] != INF) {\n            insert_line(tree, xs, (Line){0, previous[0], true}, 1, 0, xs_count - 1);\n        }\n\n        for (int end = 1; end <= n; end++) {\n            long long x = prefix[end] - target;\n            long long best_q = query_line(tree, xs, x, 1, 0, xs_count - 1);\n            if (best_q < INF / 2) {\n                current[end] = x * x + best_q;\n            }\n            if (previous[end] != INF) {\n                insert_line(tree, xs, (Line){-2 * prefix[end], previous[end] + prefix[end] * prefix[end], true}, 1, 0, xs_count - 1);\n            }\n        }\n        free(previous);\n        previous = current;\n    }\n\n    long long ans = previous[n];\n    free(previous);\n    free(prefix);\n    free(xs);\n    free(tree);\n    return (int)ans;\n}\n",
    "buggy_code": "#define INF (1LL << 60)\n\ntypedef struct {\n    long long m;\n    long long c;\n    bool has_line;\n} Line;\n\nstatic inline long long eval_line(Line l, long long x) {\n    return l.m * x + l.c;\n}\n\nstatic void insert_line(Line* tree, long long* xs, Line line, int node, int left, int right) {\n    if (!tree[node].has_line) {\n        tree[node] = line;\n        return;\n    }\n    int middle = (left + right) / 2;\n    bool better_left = eval_line(line, xs[left]) < eval_line(tree[node], xs[left]);\n    bool better_middle = eval_line(line, xs[middle]) < eval_line(tree[node], xs[middle]);\n    if (better_middle) {\n        Line tmp = tree[node];\n        tree[node] = line;\n        line = tmp;\n    }\n    if (left == right) return;\n    if (better_left != better_middle) {\n        insert_line(tree, xs, line, node * 2, left, middle);\n    } else {\n        insert_line(tree, xs, line, node * 2 + 1, middle + 1, right);\n    }\n}\n\nstatic long long query_line(Line* tree, long long* xs, long long x, int node, int left, int right) {\n    long long ans = tree[node].has_line ? eval_line(tree[node], x) : INF;\n    if (left == right) return ans;\n    int middle = (left + right) / 2;\n    if (x <= xs[middle]) {\n        long long res = query_line(tree, xs, x, node * 2, left, middle);\n        return res < ans ? res : ans;\n    } else {\n        long long res = query_line(tree, xs, x, node * 2 + 1, middle + 1, right);\n        return res < ans ? res : ans;\n    }\n}\n\nstatic int cmp_ll(const void* a, const void* b) {\n    long long ia = *(const long long*)a;\n    long long ib = *(const long long*)b;\n    return (ia > ib) - (ia < ib);\n}\n\nint entryPoint(int* values, int valuesSize, int groups, int target) {\n    int n = valuesSize;\n    long long* prefix = malloc(sizeof(long long) * (n + 1));\n    prefix[0] = 0;\n    for (int i = 0; i < n; i++) prefix[i + 1] = prefix[i] + values[i];\n\n    long long* raw_xs = malloc(sizeof(long long) * n);\n    for (int i = 1; i <= n; i++) raw_xs[i - 1] = prefix[i] - target;\n    qsort(raw_xs, n, sizeof(long long), cmp_ll);\n\n    int xs_count = 0;\n    long long* xs = malloc(sizeof(long long) * n);\n    for (int i = 0; i < n; i++) {\n        if (i == 0 || raw_xs[i] != raw_xs[i - 1]) {\n            xs[xs_count++] = raw_xs[i];\n        }\n    }\n    free(raw_xs);\n\n    long long* previous = malloc(sizeof(long long) * (n + 1));\n    for (int i = 0; i <= n; i++) previous[i] = (i == 0) ? 0 : INF;\n\n    Line* tree = malloc(sizeof(Line) * (4 * xs_count + 4));\n    memset(tree, 0, sizeof(Line) * (4 * xs_count + 4));\n\n    for (int layer = 0; layer < groups; layer++) {\n        long long* current = malloc(sizeof(long long) * (n + 1));\n        for (int i = 0; i <= n; i++) current[i] = INF;\n\n        if (previous[0] != INF) {\n            insert_line(tree, xs, (Line){0, previous[0], true}, 1, 0, xs_count - 1);\n        }\n\n        for (int end = 1; end <= n; end++) {\n            long long x = prefix[end] - target;\n            if (previous[end] != INF) {\n                insert_line(tree, xs, (Line){-2 * prefix[end], previous[end] + prefix[end] * prefix[end], true}, 1, 0, xs_count - 1);\n            }\n            long long best_q = query_line(tree, xs, x, 1, 0, xs_count - 1);\n            if (best_q < INF / 2) {\n                current[end] = x * x + best_q;\n            }\n        }\n        free(previous);\n        previous = current;\n    }\n\n    long long ans = previous[n];\n    free(previous);\n    free(prefix);\n    free(xs);\n    free(tree);\n    return (int)ans;\n}\n",
    "tests": [
      {
        "args": [
          [
            1,
            2
          ],
          1,
          3
        ],
        "expected": 0
      },
      {
        "args": [
          [
            1,
            2
          ],
          2,
          2
        ],
        "expected": 1
      },
      {
        "args": [
          [
            -3
          ],
          1,
          2
        ],
        "expected": 25
      },
      {
        "args": [
          [
            0,
            0,
            0
          ],
          2,
          0
        ],
        "expected": 0
      },
      {
        "args": [
          [
            3,
            -3,
            3,
            -3
          ],
          2,
          0
        ],
        "expected": 0
      },
      {
        "args": [
          [
            2,
            -5,
            4,
            1
          ],
          2,
          1
        ],
        "expected": 0
      },
      {
        "args": [
          [
            1,
            1,
            1
          ],
          3,
          2
        ],
        "expected": 3
      },
      {
        "args": [
          [
            5,
            -2,
            4,
            -1
          ],
          2,
          3
        ],
        "expected": 0
      },
      {
        "args": [
          [
            2,
            2,
            2
          ],
          2,
          3
        ],
        "expected": 2
      },
      {
        "args": [
          [
            5,
            -5
          ],
          2,
          0
        ],
        "expected": 50
      }
    ]
  }
]
$questions$::jsonb) AS q(title text, description text, difficulty text, topic text, language text,
                         signature jsonb, entry_point text, buggy_code text, fixed_code text, tests jsonb);
