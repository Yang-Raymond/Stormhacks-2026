-- 011_seed_cpp_questions.sql
-- C++ translations of the seeded questions; the first two tests are public examples.
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
    "language": "cpp",
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
    "description": "A machine records one temperature reading each minute. A reading is overheating when it is **greater than or equal to** a given threshold.\n\nImplement `class Solution` and method `entryPoint(vector<int>& readings, int threshold)` to return the longest consecutive streak of overheating readings. Return `0` if no reading qualifies.\n\n### Examples\n- Input: `readings = [70, 80, 85, 60], threshold = 80`\n  Output: `2`\n- Input: `readings = [40, 50], threshold = 60`\n  Output: `0`\n\n### Constraints\n- `0 <= readings.size() <= 10000`\n- Each reading and `threshold` is an integer between `-100` and `1000`.",
    "fixed_code": "class Solution {\npublic:\n    int entryPoint(vector<int>& readings, int threshold) {\n        int longest = 0;\n        int current = 0;\n        for (int reading : readings) {\n            if (reading >= threshold) {\n                current++;\n                longest = max(longest, current);\n            } else {\n                current = 0;\n            }\n        }\n        return longest;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    int entryPoint(vector<int>& readings, int threshold) {\n        int longest = 0;\n        int current = 0;\n        for (int reading : readings) {\n            if (reading > threshold) {\n                current++;\n                longest = max(longest, current);\n            } else {\n                current = 0;\n            }\n        }\n        return longest;\n    }\n};",
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
    "language": "cpp",
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
    "description": "A label imported from a text file may contain extra spaces. Clean it by removing leading and trailing spaces and replacing every consecutive group of internal spaces with one space. Preserve all other characters and their capitalization.\n\nImplement `class Solution` and method `entryPoint(string label)` to return the cleaned label. A label containing only spaces becomes an empty string.\n\n### Examples\n- Input: `label = \"  Main   Office  \"`\n  Output: `\"Main Office\"`\n- Input: `label = \"Desk 7\"`\n  Output: `\"Desk 7\"`\n\n### Constraints\n- `0 <= label.size() <= 10000`\n- `label` contains only English letters, digits, and ordinary ASCII spaces.",
    "fixed_code": "class Solution {\npublic:\n    string entryPoint(string label) {\n        string result = \"\";\n        for (char character : label) {\n            if (character != ' ') {\n                result += character;\n            } else if (!result.empty() && result.back() != ' ') {\n                result += ' ';\n            }\n        }\n        while (!result.empty() && result.back() == ' ') {\n            result.pop_back();\n        }\n        return result;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    string entryPoint(string label) {\n        string result = \"\";\n        for (char character : label) {\n            if (character != ' ') {\n                result += character;\n            } else if (!result.empty() && result.back() != ' ') {\n                result += ' ';\n            }\n        }\n        while (!result.empty() && result.front() == ' ') {\n            result.erase(0, 1);\n        }\n        return result;\n    }\n};",
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
    "language": "cpp",
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
    "description": "A warehouse receives delivery records given as parallel arrays `items` and `quantities`. Each pair `(items[i], quantities[i])` indicates that item `items[i]` arrived with quantity `quantities[i]`. The same item may appear in multiple records.\n\nImplement `class Solution` and method `entryPoint(vector<string>& items, vector<int>& quantities)` to return a list of total quantities for each distinct item, ordered by the item's first appearance in `items`. Include every item that appears, even if its total is zero. Item names are case-sensitive.\n\n### Examples\n- Input: `items = [\"bolts\", \"bolts\"], quantities = [3, 4]`\n  Output: `[7]`\n- Input: `items = [\"tape\", \"glue\"], quantities = [2, 5]`\n  Output: `[2, 5]`\n\n### Constraints\n- `items.size() == quantities.size()`\n- `0 <= items.size() <= 10000`\n- Item names contain between `1` and `30` English letters.\n- `0 <= quantities[i] <= 100000`.",
    "fixed_code": "class Solution {\npublic:\n    vector<int> entryPoint(vector<string>& items, vector<int>& quantities) {\n        unordered_map<string, int> totals;\n        vector<string> order;\n        for (size_t i = 0; i < items.size(); ++i) {\n            const string& item = items[i];\n            int quantity = quantities[i];\n            if (totals.find(item) == totals.end()) {\n                totals[item] = 0;\n                order.push_back(item);\n            }\n            totals[item] += quantity;\n        }\n        vector<int> result;\n        for (const string& item : order) {\n            result.push_back(totals[item]);\n        }\n        return result;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    vector<int> entryPoint(vector<string>& items, vector<int>& quantities) {\n        unordered_map<string, int> totals;\n        vector<string> order;\n        for (size_t i = 0; i < items.size(); ++i) {\n            const string& item = items[i];\n            int quantity = quantities[i];\n            if (totals.find(item) == totals.end()) {\n                totals[item] = 0;\n                order.push_back(item);\n            }\n            totals[item] = quantity;\n        }\n        vector<int> result;\n        for (const string& item : order) {\n            result.push_back(totals[item]);\n        }\n        return result;\n    }\n};",
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
    "language": "cpp",
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
    "description": "A small drafting tool processes a list of string actions. An action equal to `\"UNDO\"` removes the most recently added line that is still present. If no lines remain, `\"UNDO\"` does nothing. Every other action adds that string as a new line, including an empty string.\n\nImplement `class Solution` and method `entryPoint(vector<string>& actions)` to return the remaining lines in their original insertion order. The reserved action `\"UNDO\"` cannot be added as ordinary text.\n\n### Examples\n- Input: `actions = [\"Title\", \"Draft\", \"UNDO\"]`\n  Output: `[\"Title\"]`\n- Input: `actions = [\"UNDO\", \"Hello\"]`\n  Output: `[\"Hello\"]`\n\n### Constraints\n- `0 <= actions.size() <= 10000`\n- Each action is a string containing at most `100` characters.\n- Actions are case-sensitive.",
    "fixed_code": "class Solution {\npublic:\n    vector<string> entryPoint(vector<string>& actions) {\n        vector<string> lines;\n        for (const string& action : actions) {\n            if (action == \"UNDO\") {\n                if (!lines.empty()) {\n                    lines.pop_back();\n                }\n            } else {\n                lines.push_back(action);\n            }\n        }\n        return lines;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    vector<string> entryPoint(vector<string>& actions) {\n        vector<string> lines;\n        for (const string& action : actions) {\n            if (action == \"UNDO\") {\n                if (!lines.empty()) {\n                    lines.erase(lines.begin());\n                }\n            } else {\n                lines.push_back(action);\n            }\n        }\n        return lines;\n    }\n};",
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
    "language": "cpp",
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
    "description": "A service publishes maintenance windows as pairs `[start, end]`. Each window includes its start time and excludes its end time. A customer's session follows the same rule.\n\nImplement `class Solution` and method `entryPoint(vector<vector<int>>& windows, int session_start, int session_end)` to count how many maintenance windows overlap the session for a positive amount of time. A window that ends exactly when the session starts, or starts exactly when the session ends, does not overlap. Count each listed window separately, including duplicate windows.\n\n### Examples\n- Input: `windows = [[1, 4], [6, 9]], session_start = 3, session_end = 7`\n  Output: `2`\n- Input: `windows = [[1, 3], [7, 9]], session_start = 3, session_end = 7`\n  Output: `0`\n\n### Constraints\n- `0 <= windows.size() <= 10000`\n- Each window contains two integers satisfying `0 <= start < end <= 1000000`.\n- `0 <= session_start < session_end <= 1000000`\n- Windows may appear in any order and may overlap one another.",
    "fixed_code": "class Solution {\npublic:\n    int entryPoint(vector<vector<int>>& windows, int session_start, int session_end) {\n        int count = 0;\n        for (const auto& w : windows) {\n            int start = w[0];\n            int end = w[1];\n            int overlap_start = max(start, session_start);\n            int overlap_end = min(end, session_end);\n            if (overlap_start < overlap_end) {\n                count++;\n            }\n        }\n        return count;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    int entryPoint(vector<vector<int>>& windows, int session_start, int session_end) {\n        int count = 0;\n        for (const auto& w : windows) {\n            int start = w[0];\n            int end = w[1];\n            int overlap_start = max(start, session_start);\n            int overlap_end = min(end, session_end);\n            if (overlap_start <= overlap_end) {\n                count++;\n            }\n        }\n        return count;\n    }\n};",
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
    "language": "cpp",
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
    "description": "An audit system stores events in chronological order. Each event has a category and a nonnegative review cost.\n\nImplement `class Solution` and method `entryPoint(vector<string>& categories, vector<int>& costs, int budget, int category_limit)` to return the maximum number of consecutive events that can be selected while satisfying both rules:\n\n- Their total review cost is at most `budget`.\n- No category appears more than `category_limit` times.\n\nReturn `0` if no nonempty selection is valid. The input lists have equal lengths, and their matching positions describe the same event.\n\n### Examples\n- Input: `categories = [\"a\", \"b\", \"a\"], costs = [2, 1, 2], budget = 5, category_limit = 2`\n  Output: `3`\n- Input: `categories = [\"a\", \"a\", \"b\"], costs = [1, 1, 1], budget = 3, category_limit = 1`\n  Output: `2`\n\n### Constraints\n- `categories.size() == costs.size()`\n- `0 <= categories.size() <= 100000`\n- Categories are nonempty lowercase English strings of length at most `20`.\n- `0 <= costs[i] <= 10000`\n- `0 <= budget <= 1000000000`\n- `1 <= category_limit <= 100000`.",
    "fixed_code": "class Solution {\npublic:\n    int entryPoint(vector<string>& categories, vector<int>& costs, int budget, int category_limit) {\n        unordered_map<string, int> counts;\n        int left = 0;\n        int total = 0;\n        int best = 0;\n        for (int right = 0; right < (int)categories.size(); ++right) {\n            const string& category = categories[right];\n            counts[category]++;\n            total += costs[right];\n            while (total > budget || counts[category] > category_limit) {\n                const string& departing = categories[left];\n                counts[departing]--;\n                total -= costs[left];\n                left++;\n            }\n            int length = right - left + 1;\n            best = max(best, length);\n        }\n        return best;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    int entryPoint(vector<string>& categories, vector<int>& costs, int budget, int category_limit) {\n        unordered_map<string, int> counts;\n        int left = 0;\n        int total = 0;\n        int best = 0;\n        for (int right = 0; right < (int)categories.size(); ++right) {\n            const string& category = categories[right];\n            counts[category]++;\n            total += costs[right];\n            if (total > budget || counts[category] > category_limit) {\n                const string& departing = categories[left];\n                counts[departing]--;\n                total -= costs[left];\n                left++;\n            }\n            int length = right - left + 1;\n            best = max(best, length);\n        }\n        return best;\n    }\n};",
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
    "language": "cpp",
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
    "description": "A search box accepts a small query language. Implement `class Solution` and method `entryPoint(string query)` to return its tokens in order according to these rules:\n\n- Ordinary ASCII spaces separate tokens when outside double quotes.\n- Double quotes toggle quoted mode and are omitted from the token. Spaces inside quotes are preserved.\n- A backslash escapes the next character, inside or outside quotes. The escaped character is added literally, and the backslash is omitted.\n- Adjacent quoted and unquoted portions belong to the same token unless separated by an unquoted, unescaped space.\n- Empty quoted portions count as a token when standing alone.\n- Leading, trailing, and repeated separator spaces do not create tokens.\n\n### Examples\n- Input: `query = \"red \\\"blue sky\\\"\"`\n  Output: `[\"red\", \"blue sky\"]`\n- Input: `query = \"a\\\"b c\\\"d\"`\n  Output: `[\"ab cd\"]`\n\n### Constraints\n- `0 <= query.size() <= 100000`\n- The query contains printable ASCII characters.\n- Every backslash has a following character.\n- Unescaped double quotes are balanced.",
    "fixed_code": "class Solution {\npublic:\n    vector<string> entryPoint(string query) {\n        vector<string> tokens;\n        string current = \"\";\n        bool quoted = false;\n        bool active = false;\n        int i = 0;\n        int n = query.size();\n        while (i < n) {\n            char character = query[i];\n            if (character == '\\\\') {\n                i++;\n                current += query[i];\n                active = true;\n            } else if (character == '\"') {\n                quoted = !quoted;\n                active = true;\n            } else if (character == ' ' && !quoted) {\n                if (active) {\n                    tokens.push_back(current);\n                    current = \"\";\n                    active = false;\n                }\n            } else {\n                current += character;\n                active = true;\n            }\n            i++;\n        }\n        if (active) {\n            tokens.push_back(current);\n        }\n        return tokens;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    vector<string> entryPoint(string query) {\n        vector<string> tokens;\n        string current = \"\";\n        bool quoted = false;\n        bool active = false;\n        int i = 0;\n        int n = query.size();\n        while (i < n) {\n            char character = query[i];\n            if (character == '\\\\' && quoted) {\n                i++;\n                current += query[i];\n                active = true;\n            } else if (character == '\"') {\n                quoted = !quoted;\n                active = true;\n            } else if (character == ' ' && !quoted) {\n                if (active) {\n                    tokens.push_back(current);\n                    current = \"\";\n                    active = false;\n                }\n            } else {\n                current += character;\n                active = true;\n            }\n            i++;\n        }\n        if (active) {\n            tokens.push_back(current);\n        }\n        return tokens;\n    }\n};",
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
    "language": "cpp",
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
    "description": "A data platform must run `n` export jobs, numbered from `0` to `n - 1`. Job `i` takes `durations[i]` time units and cannot start before time `release_times[i]`.\n\nEach dependency `[before, after]` means that job `after` must wait until job `before` finishes. A job must wait for all its prerequisites. Unlimited workers are available, so unrelated jobs may run simultaneously. Jobs begin as soon as their release times and dependencies permit.\n\nImplement `class Solution` and method `entryPoint(vector<int>& durations, vector<int>& release_times, vector<vector<int>>& dependencies)` to return a list containing the earliest finish time of every job, in job-number order. The dependency graph is guaranteed to have no cycles.\n\n### Examples\n- Input: `durations = [2, 3], release_times = [0, 0], dependencies = [[0, 1]]`\n  Output: `[2, 5]`\n- Input: `durations = [2, 1], release_times = [5, 0], dependencies = []`\n  Output: `[7, 1]`\n\n### Constraints\n- `0 <= n <= 10000` where `n = durations.size() == release_times.size()`\n- `1 <= durations[i] <= 1000000`\n- `0 <= release_times[i] <= 1000000000`\n- There are at most `50000` dependencies.\n- Dependencies use valid, distinct job numbers, and duplicate dependency pairs do not occur.",
    "fixed_code": "class Solution {\npublic:\n    vector<int> entryPoint(vector<int>& durations, vector<int>& release_times, vector<vector<int>>& dependencies) {\n        int n = durations.size();\n        vector<vector<int>> outgoing(n);\n        vector<int> remaining(n, 0);\n        for (const auto& dep : dependencies) {\n            int before = dep[0];\n            int after = dep[1];\n            outgoing[before].push_back(after);\n            remaining[after]++;\n        }\n        vector<int> starts = release_times;\n        vector<int> finishes(n, 0);\n        queue<int> ready;\n        for (int i = 0; i < n; ++i) {\n            if (remaining[i] == 0) {\n                ready.push(i);\n            }\n        }\n        while (!ready.empty()) {\n            int job = ready.front();\n            ready.pop();\n            finishes[job] = starts[job] + durations[job];\n            for (int child : outgoing[job]) {\n                starts[child] = max(starts[child], finishes[job]);\n                remaining[child]--;\n                if (remaining[child] == 0) {\n                    ready.push(child);\n                }\n            }\n        }\n        return finishes;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    vector<int> entryPoint(vector<int>& durations, vector<int>& release_times, vector<vector<int>>& dependencies) {\n        int n = durations.size();\n        vector<vector<int>> outgoing(n);\n        vector<int> remaining(n, 0);\n        for (const auto& dep : dependencies) {\n            int before = dep[0];\n            int after = dep[1];\n            outgoing[before].push_back(after);\n            remaining[after]++;\n        }\n        vector<int> starts = release_times;\n        vector<int> finishes(n, 0);\n        queue<int> ready;\n        for (int i = 0; i < n; ++i) {\n            if (remaining[i] == 0) {\n                ready.push(i);\n            }\n        }\n        while (!ready.empty()) {\n            int job = ready.front();\n            ready.pop();\n            finishes[job] = starts[job] + durations[job];\n            for (int child : outgoing[job]) {\n                starts[child] = max(release_times[child], finishes[job]);\n                remaining[child]--;\n                if (remaining[child] == 0) {\n                    ready.push(child);\n                }\n            }\n        }\n        return finishes;\n    }\n};",
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
    "language": "cpp",
    "entry_point": "entryPoint",
    "signature": {
      "params": [
        {
          "name": "reservations",
          "type": "int[][]"
        },
        {
          "name": "threshold",
          "type": "int"
        }
      ],
      "returns": "int"
    },
    "description": "A facility receives resource reservations. Each reservation is `[start, end, units]` and uses `units` resources throughout the half-open time interval `[start, end)`. Simultaneous reservations add their resource usage.\n\nImplement `class Solution` and method `entryPoint(vector<vector<int>>& reservations, int threshold)` to return the total duration during which combined resource usage is at least `threshold`.\n\nCount elapsed time only once, regardless of how many reservations overlap. Reservations may be unsorted, duplicated, nested, or adjacent. Usage is zero outside all reservations.\n\n### Examples\n- Input: `reservations = [[0, 4, 2], [2, 6, 3]], threshold = 4`\n  Output: `2`\n  Explanation: Usage reaches at least 4 only during [2, 4).\n- Input: `reservations = [[1, 5, 3]], threshold = 3`\n  Output: `4`\n\n### Constraints\n- `0 <= reservations.size() <= 100000`\n- `0 <= start < end <= 1000000000`\n- `1 <= units <= 1000000`\n- `1 <= threshold <= 100000000000`.",
    "fixed_code": "class Solution {\npublic:\n    int entryPoint(vector<vector<int>>& reservations, int threshold) {\n        map<int, int> changes;\n        for (const auto& res : reservations) {\n            int start = res[0];\n            int end = res[1];\n            int units = res[2];\n            changes[start] += units;\n            changes[end] -= units;\n        }\n        int active = 0;\n        bool has_previous = false;\n        int previous = 0;\n        int duration = 0;\n        for (const auto& [time, change] : changes) {\n            if (has_previous && active >= threshold) {\n                duration += time - previous;\n            }\n            active += change;\n            previous = time;\n            has_previous = true;\n        }\n        return duration;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    int entryPoint(vector<vector<int>>& reservations, int threshold) {\n        map<int, int> changes;\n        for (const auto& res : reservations) {\n            int start = res[0];\n            int end = res[1];\n            int units = res[2];\n            changes[start] += units;\n            changes[end] -= units;\n        }\n        int active = 0;\n        bool has_previous = false;\n        int previous = 0;\n        int duration = 0;\n        for (const auto& [time, change] : changes) {\n            if (has_previous && active > threshold) {\n                duration += time - previous;\n            }\n            active += change;\n            previous = time;\n            has_previous = true;\n        }\n        return duration;\n    }\n};",
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
    "language": "cpp",
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
    "description": "A print shop must process jobs in their existing order. Each job has a positive intensity value. The shop partitions the jobs into nonempty, consecutive batches containing at most `max_batch` jobs each.\n\nThe cost of a batch is:\n`setup_cost + (number of jobs in the batch) * (maximum intensity in the batch)`\n\nEvery job must belong to exactly one batch. Jobs cannot be reordered.\n\nImplement `class Solution` and method `entryPoint(vector<int>& intensities, int max_batch, int setup_cost)` to return the minimum total cost. Return `0` when there are no jobs.\n\n### Examples\n- Input: `intensities = [2, 2], max_batch = 2, setup_cost = 3`\n  Output: `7`\n  Explanation: One batch costs 3 + 2 * 2 = 7.\n- Input: `intensities = [1, 10], max_batch = 2, setup_cost = 2`\n  Output: `15`\n  Explanation: Separate batches cost (2 + 1) + (2 + 10) = 15.\n\n### Constraints\n- `0 <= intensities.size() <= 1000`\n- `1 <= intensities[i] <= 10000`\n- `1 <= max_batch <= 100`\n- `0 <= setup_cost <= 10000`.",
    "fixed_code": "class Solution {\npublic:\n    int entryPoint(vector<int>& intensities, int max_batch, int setup_cost) {\n        int n = intensities.size();\n        vector<int> dp(n + 1, 0);\n        for (int end = 1; end <= n; ++end) {\n            int peak = intensities[end - 1];\n            int best = dp[end - 1] + setup_cost + peak;\n            int limit = min(max_batch, end);\n            for (int length = 1; length <= limit; ++length) {\n                peak = max(peak, intensities[end - length]);\n                int candidate = dp[end - length] + setup_cost + length * peak;\n                best = min(best, candidate);\n            }\n            dp[end] = best;\n        }\n        return dp[n];\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    int entryPoint(vector<int>& intensities, int max_batch, int setup_cost) {\n        int n = intensities.size();\n        vector<int> dp(n + 1, 0);\n        for (int end = 1; end <= n; ++end) {\n            int peak = intensities[end - 1];\n            int best = dp[end - 1] + setup_cost + peak;\n            int limit = min(max_batch, end);\n            for (int length = 1; length < limit; ++length) {\n                peak = max(peak, intensities[end - length]);\n                int candidate = dp[end - length] + setup_cost + length * peak;\n                best = min(best, candidate);\n            }\n            dp[end] = best;\n        }\n        return dp[n];\n    }\n};",
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
    "language": "cpp",
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
    "description": "A network contains `n` devices numbered from `0` to `n - 1`. Its undirected links are available only during specified time windows.\n\nEach record `[u, v, start, end]` in `links` makes a link available throughout the half-open interval `[start, end)`. Multiple records may describe the same pair of devices; the link is available whenever any corresponding record is active.\n\nEach query `[time, u, v]` asks whether the devices are connected by a path of links that are all available at that time. A device is always connected to itself.\n\nImplement `class Solution` and method `entryPoint(int n, vector<vector<int>>& links, vector<vector<int>>& queries)` to return a list of booleans in the original query order. Neither links nor queries are necessarily sorted.\n\n### Examples\n- Input: `n = 3, links = [[0,1,0,5],[1,2,2,4]], queries = [[1,0,2],[3,0,2]]`\n  Output: `[false, true]`\n- Input: `n = 2, links = [[0,1,1,3]], queries = [[1,0,1],[3,0,1]]`\n  Output: `[true, false]`\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= links.size(), queries.size() <= 30000`\n- All device numbers are valid.\n- Link endpoints are distinct.\n- `0 <= start < end <= 1000000000`\n- Query times are integers between `0` and `1000000000`.",
    "fixed_code": "class Solution {\npublic:\n    vector<bool> entryPoint(int n, vector<vector<int>>& links, vector<vector<int>>& queries) {\n        if (queries.empty()) return {};\n        set<int> time_set;\n        for (const auto& q : queries) {\n            time_set.insert(q[0]);\n        }\n        vector<int> times(time_set.begin(), time_set.end());\n        int base = 1;\n        while (base < (int)times.size()) {\n            base <<= 1;\n        }\n        vector<vector<pair<int, int>>> tree(2 * base);\n        for (const auto& l : links) {\n            int u = l[0], v = l[1], start = l[2], end = l[3];\n            int left = (lower_bound(times.begin(), times.end(), start) - times.begin()) + base;\n            int right = (lower_bound(times.begin(), times.end(), end) - times.begin()) + base;\n            while (left < right) {\n                if (left & 1) {\n                    tree[left].push_back({u, v});\n                    left++;\n                }\n                if (right & 1) {\n                    right--;\n                    tree[right].push_back({u, v});\n                }\n                left /= 2;\n                right /= 2;\n            }\n        }\n        struct QueryItem { int id, u, v; };\n        vector<vector<QueryItem>> buckets(base);\n        for (int i = 0; i < (int)queries.size(); ++i) {\n            int t = queries[i][0];\n            int u = queries[i][1];\n            int v = queries[i][2];\n            int t_idx = lower_bound(times.begin(), times.end(), t) - times.begin();\n            buckets[t_idx].push_back({i, u, v});\n        }\n        vector<int> parent(n);\n        vector<int> sz(n, 1);\n        for (int i = 0; i < n; ++i) parent[i] = i;\n        struct Rollback { int b, a, old_size; };\n        vector<Rollback> history;\n        vector<bool> answer(queries.size(), false);\n\n        auto find = [&](auto& self, int x) -> int {\n            while (parent[x] != x) {\n                x = parent[x];\n            }\n            return x;\n        };\n\n        auto visit = [&](auto& self, int node) -> void {\n            int snapshot = history.size();\n            for (const auto& edge : tree[node]) {\n                int a = find(find, edge.first);\n                int b = find(find, edge.second);\n                if (a != b) {\n                    if (sz[a] < sz[b]) swap(a, b);\n                    history.push_back({b, a, sz[a]});\n                    parent[b] = a;\n                    sz[a] += sz[b];\n                }\n            }\n            if (node >= base) {\n                int idx = node - base;\n                if (idx < (int)buckets.size()) {\n                    for (const auto& q : buckets[idx]) {\n                        answer[q.id] = (find(find, q.u) == find(find, q.v));\n                    }\n                }\n            } else {\n                self(self, 2 * node);\n                self(self, 2 * node + 1);\n            }\n            while ((int)history.size() > snapshot) {\n                auto h = history.back();\n                history.pop_back();\n                parent[h.b] = h.b;\n                sz[h.a] = h.old_size;\n            }\n        };\n\n        visit(visit, 1);\n        return answer;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    vector<bool> entryPoint(int n, vector<vector<int>>& links, vector<vector<int>>& queries) {\n        if (queries.empty()) return {};\n        set<int> time_set;\n        for (const auto& q : queries) {\n            time_set.insert(q[0]);\n        }\n        vector<int> times(time_set.begin(), time_set.end());\n        int base = 1;\n        while (base < (int)times.size()) {\n            base <<= 1;\n        }\n        vector<vector<pair<int, int>>> tree(2 * base);\n        for (const auto& l : links) {\n            int u = l[0], v = l[1], start = l[2], end = l[3];\n            int left = (lower_bound(times.begin(), times.end(), start) - times.begin()) + base;\n            int right = (upper_bound(times.begin(), times.end(), end) - times.begin()) + base;\n            while (left < right) {\n                if (left & 1) {\n                    tree[left].push_back({u, v});\n                    left++;\n                }\n                if (right & 1) {\n                    right--;\n                    tree[right].push_back({u, v});\n                }\n                left /= 2;\n                right /= 2;\n            }\n        }\n        struct QueryItem { int id, u, v; };\n        vector<vector<QueryItem>> buckets(base);\n        for (int i = 0; i < (int)queries.size(); ++i) {\n            int t = queries[i][0];\n            int u = queries[i][1];\n            int v = queries[i][2];\n            int t_idx = lower_bound(times.begin(), times.end(), t) - times.begin();\n            buckets[t_idx].push_back({i, u, v});\n        }\n        vector<int> parent(n);\n        vector<int> sz(n, 1);\n        for (int i = 0; i < n; ++i) parent[i] = i;\n        struct Rollback { int b, a, old_size; };\n        vector<Rollback> history;\n        vector<bool> answer(queries.size(), false);\n\n        auto find = [&](auto& self, int x) -> int {\n            while (parent[x] != x) {\n                parent[x] = parent[parent[x]];\n                x = parent[x];\n            }\n            return x;\n        };\n\n        auto visit = [&](auto& self, int node) -> void {\n            int snapshot = history.size();\n            for (const auto& edge : tree[node]) {\n                int a = find(find, edge.first);\n                int b = find(find, edge.second);\n                if (a != b) {\n                    if (sz[a] < sz[b]) swap(a, b);\n                    history.push_back({b, a, sz[a]});\n                    parent[b] = a;\n                    sz[a] += sz[b];\n                }\n            }\n            if (node >= base) {\n                int idx = node - base;\n                if (idx < (int)buckets.size()) {\n                    for (const auto& q : buckets[idx]) {\n                        answer[q.id] = (find(find, q.u) == find(find, q.v));\n                    }\n                }\n            } else {\n                self(self, 2 * node);\n                self(self, 2 * node + 1);\n            }\n            while ((int)history.size() > snapshot) {\n                auto h = history.back();\n                history.pop_back();\n                parent[h.b] = h.b;\n                sz[h.a] = h.old_size;\n            }\n        };\n\n        visit(visit, 1);\n        return answer;\n    }\n};",
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
    "language": "cpp",
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
    "description": "A shipment starts at depot `0` at `start_time` and must reach depot `n - 1`.\n\nEach directed route is `[u, v, offset, period, duration]`. Regular vehicles depart depot `u` at times `offset + k * period` for every integer `k >= 0`, and take `duration` time units to reach depot `v`. A shipment arriving exactly at a departure time may board that vehicle. Waiting at depots is allowed.\n\nThe shipment has one express dispatch voucher. At most once during the entire journey, it may traverse any listed route immediately, ignoring its departure schedule but still taking that route's full travel duration. This is allowed even before the route's first regular departure.\n\nImplement `class Solution` and method `entryPoint(int n, vector<vector<int>>& routes, int start_time)` to return the earliest absolute arrival time at depot `n - 1`, or `-1` if it is unreachable. The voucher does not need to be used.\n\n### Examples\n- Input: `n = 2, routes = [[0,1,10,5,3]], start_time = 0`\n  Output: `3`\n  Explanation: An express dispatch leaves immediately.\n- Input: `n = 3, routes = [[0,1,0,10,2],[1,2,5,10,2]], start_time = 0`\n  Output: `4`\n  Explanation: Take the first regular departure, then use the voucher.\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= routes.size() <= 50000`\n- Routes use valid, distinct endpoints. Parallel routes and directed cycles are allowed.\n- `0 <= offset, start_time <= 1000000000`\n- `1 <= period, duration <= 1000000`.",
    "fixed_code": "class Solution {\npublic:\n    int entryPoint(int n, vector<vector<int>>& routes, int start_time) {\n        struct Edge {\n            int target;\n            long long offset;\n            long long period;\n            long long duration;\n        };\n        vector<vector<Edge>> graph(n);\n        for (const auto& r : routes) {\n            graph[r[0]].push_back({r[1], (long long)r[2], (long long)r[3], (long long)r[4]});\n        }\n        const long long INF = 1e18;\n        vector<vector<long long>> best(n, vector<long long>(2, INF));\n        best[0][0] = start_time;\n        using State = tuple<long long, int, int>;\n        priority_queue<State, vector<State>, greater<State>> pq;\n        pq.push({start_time, 0, 0});\n        while (!pq.empty()) {\n            auto [time, node, used] = pq.top();\n            pq.pop();\n            if (time != best[node][used]) continue;\n            if (node == n - 1) return (int)time;\n            for (const auto& e : graph[node]) {\n                long long departure;\n                if (time <= e.offset) {\n                    departure = e.offset;\n                } else {\n                    departure = e.offset + ((time - e.offset + e.period - 1) / e.period) * e.period;\n                }\n                long long arrival = departure + e.duration;\n                if (arrival < best[e.target][used]) {\n                    best[e.target][used] = arrival;\n                    pq.push({arrival, e.target, used});\n                }\n                if (used == 0) {\n                    long long express_arrival = time + e.duration;\n                    if (express_arrival < best[e.target][1]) {\n                        best[e.target][1] = express_arrival;\n                        pq.push({express_arrival, e.target, 1});\n                    }\n                }\n            }\n        }\n        return -1;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    int entryPoint(int n, vector<vector<int>>& routes, int start_time) {\n        struct Edge {\n            int target;\n            long long offset;\n            long long period;\n            long long duration;\n        };\n        vector<vector<Edge>> graph(n);\n        for (const auto& r : routes) {\n            graph[r[0]].push_back({r[1], (long long)r[2], (long long)r[3], (long long)r[4]});\n        }\n        const long long INF = 1e18;\n        vector<vector<long long>> best(n, vector<long long>(2, INF));\n        best[0][0] = start_time;\n        using State = tuple<long long, int, int>;\n        priority_queue<State, vector<State>, greater<State>> pq;\n        pq.push({start_time, 0, 0});\n        while (!pq.empty()) {\n            auto [time, node, used] = pq.top();\n            pq.pop();\n            if (time != best[node][used]) continue;\n            if (node == n - 1) return (int)time;\n            for (const auto& e : graph[node]) {\n                long long departure;\n                if (time <= e.offset) {\n                    departure = e.offset;\n                } else {\n                    departure = e.offset + ((time - e.offset + e.period) / e.period) * e.period;\n                }\n                long long arrival = departure + e.duration;\n                if (arrival < best[e.target][0]) {\n                    best[e.target][0] = arrival;\n                    pq.push({arrival, e.target, 0});\n                }\n                if (used == 0) {\n                    long long express_arrival = time + e.duration;\n                    if (express_arrival < best[e.target][1]) {\n                        best[e.target][1] = express_arrival;\n                        pq.push({express_arrival, e.target, 1});\n                    }\n                }\n            }\n        }\n        return -1;\n    }\n};",
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
    "language": "cpp",
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
    "description": "An encoding service must cover a text using a sequence of catalog entries. The catalog entries are given as parallel arrays `patterns` and `costs`, where `patterns[i]` has cost `costs[i]`.\n\nA pattern contains lowercase English letters and may contain `?`, which matches exactly one lowercase letter. Applying an entry consumes a consecutive portion of the text whose length equals the pattern's length. Entries must cover the entire text in order, without gaps or overlaps. Every catalog entry may be reused any number of times.\n\nImplement `class Solution` and method `entryPoint(string text, vector<string>& patterns, vector<int>& costs)` to return `[minimum_cost, optimal_encoding_count]`. Count optimal encodings modulo `1000000007`.\n\nAn encoding is identified by its ordered sequence of catalog indices. Duplicate catalog rows are distinct choices. Different matching characters for a wildcard do not create additional choices because the text is fixed.\n\nReturn `[-1, 0]` if the text cannot be covered. The empty text has cost `0` and exactly one encoding: the empty sequence.\n\n### Examples\n- Input: `text = \"ab\", patterns = [\"a\", \"b\", \"ab\"], costs = [2, 3, 4]`\n  Output: `[4, 1]`\n- Input: `text = \"ab\", patterns = [\"a\", \"b\", \"??\"], costs = [1, 1, 2]`\n  Output: `[2, 2]`\n  Explanation: Using the first two entries or the third entry gives the same minimum cost.\n\n### Constraints\n- `0 <= text.size() <= 2000`\n- `text` contains only lowercase English letters.\n- `patterns.size() == costs.size()`\n- `0 <= patterns.size() <= 200`\n- Each pattern has length between `1` and `30`.\n- `0 <= costs[i] <= 1000000`.",
    "fixed_code": "class Solution {\npublic:\n    vector<int> entryPoint(string text, vector<string>& patterns, vector<int>& costs) {\n        struct TrieNode {\n            int next[27];\n            TrieNode() {\n                memset(next, -1, sizeof(next));\n            }\n        };\n        vector<TrieNode> trie;\n        trie.emplace_back();\n        vector<vector<int>> terminals;\n        terminals.emplace_back();\n\n        auto char_to_idx = [](char c) -> int {\n            if (c == '?') return 26;\n            return c - 'a';\n        };\n\n        for (size_t i = 0; i < patterns.size(); ++i) {\n            const string& pat = patterns[i];\n            int cost = costs[i];\n            int node = 0;\n            for (char c : pat) {\n                int idx = char_to_idx(c);\n                if (trie[node].next[idx] == -1) {\n                    trie[node].next[idx] = trie.size();\n                    trie.emplace_back();\n                    terminals.emplace_back();\n                }\n                node = trie[node].next[idx];\n            }\n            terminals[node].push_back(cost);\n        }\n\n        int n = text.size();\n        const long long INF = 1e18;\n        vector<long long> best(n + 1, INF);\n        vector<long long> ways(n + 1, 0);\n        best[0] = 0;\n        ways[0] = 1;\n        long long modulus = 1000000007;\n\n        for (int start = 0; start < n; ++start) {\n            if (best[start] == INF) continue;\n            vector<int> active = {0};\n            for (int end = start; end < n; ++end) {\n                vector<int> following;\n                char c = text[end];\n                int c_idx = char_to_idx(c);\n                int q_idx = char_to_idx('?');\n                for (int node : active) {\n                    if (trie[node].next[c_idx] != -1) {\n                        following.push_back(trie[node].next[c_idx]);\n                    }\n                    if (trie[node].next[q_idx] != -1) {\n                        following.push_back(trie[node].next[q_idx]);\n                    }\n                }\n                active = following;\n                if (active.empty()) break;\n                for (int node : active) {\n                    for (int cost : terminals[node]) {\n                        long long candidate = best[start] + cost;\n                        if (candidate < best[end + 1]) {\n                            best[end + 1] = candidate;\n                            ways[end + 1] = ways[start];\n                        } else if (candidate == best[end + 1]) {\n                            ways[end + 1] = (ways[end + 1] + ways[start]) % modulus;\n                        }\n                    }\n                }\n            }\n        }\n        if (best[n] == INF) return {-1, 0};\n        return {(int)best[n], (int)ways[n]};\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    vector<int> entryPoint(string text, vector<string>& patterns, vector<int>& costs) {\n        struct TrieNode {\n            int next[27];\n            TrieNode() {\n                memset(next, -1, sizeof(next));\n            }\n        };\n        vector<TrieNode> trie;\n        trie.emplace_back();\n        vector<vector<int>> terminals;\n        terminals.emplace_back();\n\n        auto char_to_idx = [](char c) -> int {\n            if (c == '?') return 26;\n            return c - 'a';\n        };\n\n        for (size_t i = 0; i < patterns.size(); ++i) {\n            const string& pat = patterns[i];\n            int cost = costs[i];\n            int node = 0;\n            for (char c : pat) {\n                int idx = char_to_idx(c);\n                if (trie[node].next[idx] == -1) {\n                    trie[node].next[idx] = trie.size();\n                    trie.emplace_back();\n                    terminals.emplace_back();\n                }\n                node = trie[node].next[idx];\n            }\n            terminals[node].push_back(cost);\n        }\n\n        int n = text.size();\n        const long long INF = 1e18;\n        vector<long long> best(n + 1, INF);\n        vector<long long> ways(n + 1, 0);\n        best[0] = 0;\n        ways[0] = 1;\n        long long modulus = 1000000007;\n\n        for (int start = 0; start < n; ++start) {\n            if (best[start] == INF) continue;\n            vector<int> active = {0};\n            for (int end = start; end < n; ++end) {\n                vector<int> following;\n                char c = text[end];\n                int c_idx = char_to_idx(c);\n                int q_idx = char_to_idx('?');\n                for (int node : active) {\n                    if (trie[node].next[c_idx] != -1) {\n                        following.push_back(trie[node].next[c_idx]);\n                    }\n                    if (trie[node].next[q_idx] != -1) {\n                        following.push_back(trie[node].next[q_idx]);\n                    }\n                }\n                active = following;\n                if (active.empty()) break;\n                for (int node : active) {\n                    for (int cost : terminals[node]) {\n                        long long candidate = best[start] + cost;\n                        if (candidate < best[end + 1]) {\n                            best[end + 1] = candidate;\n                            ways[end + 1] = (ways[end + 1] + ways[start]) % modulus;\n                        } else if (candidate == best[end + 1]) {\n                            ways[end + 1] = ways[start];\n                        }\n                    }\n                }\n            }\n        }\n        if (best[n] == INF) return {-1, 0};\n        return {(int)best[n], (int)ways[n]};\n    }\n};",
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
    "language": "cpp",
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
    "description": "A laboratory owns `capacity` interchangeable pieces of equipment. Each requested job is `[start, end, profit]` and requires one piece of equipment continuously throughout the half-open interval `[start, end)`.\n\nThe laboratory may accept or reject each job. Accepted jobs cannot be interrupted, and no more than `capacity` accepted jobs may be active at any time. A piece of equipment may be reused immediately when a job ends.\n\nImplement `class Solution` and method `entryPoint(vector<vector<int>>& jobs, int capacity)` to return the maximum total profit obtainable.\n\nEach list position represents a separate request, even when multiple requests have identical values. Each request may be accepted at most once. Accepting no jobs is allowed.\n\n### Examples\n- Input: `jobs = [[0,2,5],[1,3,7]], capacity = 1`\n  Output: `7`\n- Input: `jobs = [[0,2,5],[1,3,7]], capacity = 2`\n  Output: `12`\n\n### Constraints\n- `0 <= jobs.size() <= 500`\n- `1 <= capacity <= 20`\n- `0 <= start < end <= 1000000000`\n- `1 <= profit <= 1000000`\n- Jobs may be unsorted, duplicated, nested, or adjacent.",
    "fixed_code": "class Solution {\npublic:\n    int entryPoint(vector<vector<int>>& jobs, int capacity) {\n        if (jobs.empty()) return 0;\n        set<int> time_set;\n        for (const auto& job : jobs) {\n            time_set.insert(job[0]);\n            time_set.insert(job[1]);\n        }\n        vector<int> times(time_set.begin(), time_set.end());\n        unordered_map<int, int> index;\n        for (int i = 0; i < (int)times.size(); ++i) {\n            index[times[i]] = i;\n        }\n        struct Edge {\n            int to;\n            int limit;\n            int cost;\n            int reverse_id;\n        };\n        int num_nodes = times.size();\n        vector<vector<Edge>> graph(num_nodes);\n        auto add = [&](int u, int v, int limit, int cost) {\n            int u_idx = graph[u].size();\n            int v_idx = graph[v].size();\n            graph[u].push_back({v, limit, cost, v_idx});\n            graph[v].push_back({u, 0, -cost, u_idx});\n        };\n        for (int i = 0; i < num_nodes - 1; ++i) {\n            add(i, i + 1, capacity, 0);\n        }\n        for (const auto& job : jobs) {\n            add(index[job[0]], index[job[1]], 1, -job[2]);\n        }\n        int total = 0;\n        int remaining = capacity;\n        while (remaining > 0) {\n            const int INF = 1e9;\n            vector<int> distance(num_nodes, INF);\n            vector<pair<int, int>> previous(num_nodes, {-1, -1});\n            vector<bool> queued(num_nodes, false);\n            deque<int> q;\n            distance[0] = 0;\n            q.push_back(0);\n            queued[0] = true;\n            while (!q.empty()) {\n                int u = q.front();\n                q.pop_front();\n                queued[u] = false;\n                for (int edge_id = 0; edge_id < (int)graph[u].size(); ++edge_id) {\n                    const auto& edge = graph[u][edge_id];\n                    if (edge.limit > 0 && distance[u] + edge.cost < distance[edge.to]) {\n                        distance[edge.to] = distance[u] + edge.cost;\n                        previous[edge.to] = {u, edge_id};\n                        if (!queued[edge.to]) {\n                            q.push_back(edge.to);\n                            queued[edge.to] = true;\n                        }\n                    }\n                }\n            }\n            if (previous[num_nodes - 1].first == -1) break;\n            int pushed = remaining;\n            int node = num_nodes - 1;\n            while (node != 0) {\n                auto [u, edge_id] = previous[node];\n                pushed = min(pushed, graph[u][edge_id].limit);\n                node = u;\n            }\n            node = num_nodes - 1;\n            while (node != 0) {\n                auto [u, edge_id] = previous[node];\n                auto& edge = graph[u][edge_id];\n                edge.limit -= pushed;\n                graph[node][edge.reverse_id].limit += pushed;\n                node = u;\n            }\n            remaining -= pushed;\n            total -= pushed * distance[num_nodes - 1];\n        }\n        return total;\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    int entryPoint(vector<vector<int>>& jobs, int capacity) {\n        if (jobs.empty()) return 0;\n        set<int> time_set;\n        for (const auto& job : jobs) {\n            time_set.insert(job[0]);\n            time_set.insert(job[1]);\n        }\n        vector<int> times(time_set.begin(), time_set.end());\n        unordered_map<int, int> index;\n        for (int i = 0; i < (int)times.size(); ++i) {\n            index[times[i]] = i;\n        }\n        struct Edge {\n            int to;\n            int limit;\n            int cost;\n            int reverse_id;\n        };\n        int num_nodes = times.size();\n        vector<vector<Edge>> graph(num_nodes);\n        auto add = [&](int u, int v, int limit, int cost) {\n            int u_idx = graph[u].size();\n            int v_idx = graph[v].size();\n            graph[u].push_back({v, limit, cost, v_idx});\n            graph[v].push_back({u, 0, -cost, u_idx});\n        };\n        for (int i = 0; i < num_nodes - 1; ++i) {\n            add(i, i + 1, capacity, 0);\n        }\n        set<vector<int>> unique_jobs(jobs.begin(), jobs.end());\n        for (const auto& job : unique_jobs) {\n            add(index[job[0]], index[job[1]], 1, -job[2]);\n        }\n        int total = 0;\n        int remaining = capacity;\n        while (remaining > 0) {\n            const int INF = 1e9;\n            vector<int> distance(num_nodes, INF);\n            vector<pair<int, int>> previous(num_nodes, {-1, -1});\n            vector<bool> queued(num_nodes, false);\n            deque<int> q;\n            distance[0] = 0;\n            q.push_back(0);\n            queued[0] = true;\n            while (!q.empty()) {\n                int u = q.front();\n                q.pop_front();\n                queued[u] = false;\n                for (int edge_id = 0; edge_id < (int)graph[u].size(); ++edge_id) {\n                    const auto& edge = graph[u][edge_id];\n                    if (edge.limit > 0 && distance[u] + edge.cost < distance[edge.to]) {\n                        distance[edge.to] = distance[u] + edge.cost;\n                        previous[edge.to] = {u, edge_id};\n                        if (!queued[edge.to]) {\n                            q.push_back(edge.to);\n                            queued[edge.to] = true;\n                        }\n                    }\n                }\n            }\n            if (previous[num_nodes - 1].first == -1) break;\n            int pushed = remaining;\n            int node = num_nodes - 1;\n            while (node != 0) {\n                auto [u, edge_id] = previous[node];\n                pushed = min(pushed, graph[u][edge_id].limit);\n                node = u;\n            }\n            node = num_nodes - 1;\n            while (node != 0) {\n                auto [u, edge_id] = previous[node];\n                auto& edge = graph[u][edge_id];\n                edge.limit -= pushed;\n                node = u;\n            }\n            remaining -= pushed;\n            total -= pushed * distance[num_nodes - 1];\n        }\n        return total;\n    }\n};",
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
    "language": "cpp",
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
    "description": "A financial reconciliation system receives an ordered list of signed adjustments. It must partition the entire list into exactly `groups` nonempty, consecutive batches without changing their order.\n\nFor a batch whose adjustments sum to `s`, its penalty is `(s - target)²`. Positive and negative adjustments may cancel within a batch.\n\nImplement `class Solution` and method `entryPoint(vector<int>& values, int groups, int target)` to return the minimum possible sum of batch penalties. Every adjustment must belong to exactly one batch.\n\n### Examples\n- Input: `values = [1, 2], groups = 1, target = 3`\n  Output: `0`\n  Explanation: The single batch sums to the target.\n- Input: `values = [1, 2], groups = 2, target = 2`\n  Output: `1`\n  Explanation: The required batches are `[1]` and `[2]`, with penalties `1` and `0`.\n\n### Constraints\n- `1 <= values.size() <= 5000`\n- `1 <= groups <= min(30, (int)values.size())`\n- `-10000 <= values[i], target <= 10000`\n- All inputs are integers.",
    "fixed_code": "class Solution {\npublic:\n    int entryPoint(vector<int>& values, int groups, int target) {\n        int n = values.size();\n        vector<long long> prefix = {0};\n        for (int v : values) {\n            prefix.push_back(prefix.back() + v);\n        }\n        set<long long> xs_set;\n        for (size_t i = 1; i < prefix.size(); ++i) {\n            xs_set.insert(prefix[i] - target);\n        }\n        vector<long long> xs(xs_set.begin(), xs_set.end());\n        int num_xs = xs.size();\n        const long long INF = 1e18;\n\n        struct Line {\n            long long m;\n            long long c;\n        };\n\n        struct LiChaoTree {\n            vector<bool> has_line;\n            vector<Line> tree;\n            const vector<long long>& xs;\n            const long long INF_VAL = 1e18;\n\n            LiChaoTree(int num_xs, const vector<long long>& xs_ref) : xs(xs_ref) {\n                has_line.assign(4 * num_xs + 5, false);\n                tree.assign(4 * num_xs + 5, {0, 0});\n            }\n\n            void insert(Line line, int node, int left, int right) {\n                if (!has_line[node]) {\n                    tree[node] = line;\n                    has_line[node] = true;\n                    return;\n                }\n                int middle = (left + right) / 2;\n                bool better_left = (line.m * xs[left] + line.c) < (tree[node].m * xs[left] + tree[node].c);\n                bool better_middle = (line.m * xs[middle] + line.c) < (tree[node].m * xs[middle] + tree[node].c);\n                if (better_middle) {\n                    swap(tree[node], line);\n                }\n                if (left == right) return;\n                if (better_left != better_middle) {\n                    insert(line, node * 2, left, middle);\n                } else {\n                    insert(line, node * 2 + 1, middle + 1, right);\n                }\n            }\n\n            long long query(long long x, int node, int left, int right) {\n                if (!has_line[node]) return INF_VAL;\n                long long answer = tree[node].m * x + tree[node].c;\n                if (left == right) return answer;\n                int middle = (left + right) / 2;\n                if (x <= xs[middle]) {\n                    return min(answer, query(x, node * 2, left, middle));\n                }\n                return min(answer, query(x, node * 2 + 1, middle + 1, right));\n            }\n        };\n\n        vector<long long> previous(n + 1, INF);\n        previous[0] = 0;\n\n        for (int layer = 0; layer < groups; ++layer) {\n            LiChaoTree lct(num_xs, xs);\n            vector<long long> current(prefix.size(), INF);\n            if (previous[0] != INF) {\n                lct.insert({0, previous[0]}, 1, 0, num_xs - 1);\n            }\n            for (size_t end = 1; end < prefix.size(); ++end) {\n                long long x = prefix[end] - target;\n                long long q = lct.query(x, 1, 0, num_xs - 1);\n                if (q != INF) {\n                    current[end] = x * x + q;\n                }\n                if (previous[end] != INF) {\n                    lct.insert({-2 * prefix[end], previous[end] + prefix[end] * prefix[end]}, 1, 0, num_xs - 1);\n                }\n            }\n            previous = current;\n        }\n        return (int)previous.back();\n    }\n};",
    "buggy_code": "class Solution {\npublic:\n    int entryPoint(vector<int>& values, int groups, int target) {\n        int n = values.size();\n        vector<long long> prefix = {0};\n        for (int v : values) {\n            prefix.push_back(prefix.back() + v);\n        }\n        set<long long> xs_set;\n        for (size_t i = 1; i < prefix.size(); ++i) {\n            xs_set.insert(prefix[i] - target);\n        }\n        vector<long long> xs(xs_set.begin(), xs_set.end());\n        int num_xs = xs.size();\n        const long long INF = 1e18;\n\n        struct Line {\n            long long m;\n            long long c;\n        };\n\n        struct LiChaoTree {\n            vector<bool> has_line;\n            vector<Line> tree;\n            const vector<long long>& xs;\n            const long long INF_VAL = 1e18;\n\n            LiChaoTree(int num_xs, const vector<long long>& xs_ref) : xs(xs_ref) {\n                has_line.assign(4 * num_xs + 5, false);\n                tree.assign(4 * num_xs + 5, {0, 0});\n            }\n\n            void insert(Line line, int node, int left, int right) {\n                if (!has_line[node]) {\n                    tree[node] = line;\n                    has_line[node] = true;\n                    return;\n                }\n                int middle = (left + right) / 2;\n                bool better_left = (line.m * xs[left] + line.c) < (tree[node].m * xs[left] + tree[node].c);\n                bool better_middle = (line.m * xs[middle] + line.c) < (tree[node].m * xs[middle] + tree[node].c);\n                if (better_middle) {\n                    swap(tree[node], line);\n                }\n                if (left == right) return;\n                if (better_left != better_middle) {\n                    insert(line, node * 2, left, middle);\n                } else {\n                    insert(line, node * 2 + 1, middle + 1, right);\n                }\n            }\n\n            long long query(long long x, int node, int left, int right) {\n                if (!has_line[node]) return INF_VAL;\n                long long answer = tree[node].m * x + tree[node].c;\n                if (left == right) return answer;\n                int middle = (left + right) / 2;\n                if (x <= xs[middle]) {\n                    return min(answer, query(x, node * 2, left, middle));\n                }\n                return min(answer, query(x, node * 2 + 1, middle + 1, right));\n            }\n        };\n\n        vector<long long> previous(n + 1, INF);\n        previous[0] = 0;\n        LiChaoTree lct(num_xs, xs);\n\n        for (int layer = 0; layer < groups; ++layer) {\n            vector<long long> current(prefix.size(), INF);\n            if (previous[0] != INF) {\n                lct.insert({0, previous[0]}, 1, 0, num_xs - 1);\n            }\n            for (size_t end = 1; end < prefix.size(); ++end) {\n                if (previous[end] != INF) {\n                    lct.insert({-2 * prefix[end], previous[end] + prefix[end] * prefix[end]}, 1, 0, num_xs - 1);\n                }\n                long long x = prefix[end] - target;\n                long long q = lct.query(x, 1, 0, num_xs - 1);\n                if (q != INF) {\n                    current[end] = x * x + q;\n                }\n            }\n            previous = current;\n        }\n        return (int)previous.back();\n    }\n};",
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
