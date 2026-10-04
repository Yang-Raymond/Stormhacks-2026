-- 012_seed_csharp_questions.sql
-- C# translations of the seeded questions; the first two tests are public examples.
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "A machine records one temperature reading each minute. A reading is overheating when it is **greater than or equal to** a given threshold.\n\nImplement `Solution.EntryPoint(readings, threshold)` to return the longest consecutive streak of overheating readings. Return `0` if no reading qualifies.\n\n### Examples\n- Input: `readings = [70, 80, 85, 60], threshold = 80`\n  Output: `2`\n- Input: `readings = [40, 50], threshold = 60`\n  Output: `0`\n\n### Constraints\n- `0 <= readings.Length <= 10000`\n- Each reading and `threshold` is an integer between `-100` and `1000`.",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int EntryPoint(int[] readings, int threshold) {\n        int longest = 0;\n        int current = 0;\n        foreach (int reading in readings) {\n            if (reading >= threshold) {\n                current++;\n                longest = Math.Max(longest, current);\n            } else {\n                current = 0;\n            }\n        }\n        return longest;\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int EntryPoint(int[] readings, int threshold) {\n        int longest = 0;\n        int current = 0;\n        foreach (int reading in readings) {\n            if (reading > threshold) {\n                current++;\n                longest = Math.Max(longest, current);\n            } else {\n                current = 0;\n            }\n        }\n        return longest;\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
    "signature": {
      "params": [
        {
          "name": "label",
          "type": "string"
        }
      ],
      "returns": "string"
    },
    "description": "A label imported from a text file may contain extra spaces. Clean it by removing leading and trailing spaces and replacing every consecutive group of internal spaces with one space. Preserve all other characters and their capitalization.\n\nImplement `Solution.EntryPoint(label)` to return the cleaned label. A label containing only spaces becomes an empty string.\n\n### Examples\n- Input: `label = \"  Main   Office  \"`\n  Output: `\"Main Office\"`\n- Input: `label = \"Desk 7\"`\n  Output: `\"Desk 7\"`\n\n### Constraints\n- `0 <= label.Length <= 10000`\n- `label` contains only English letters, digits, and ordinary ASCII spaces.",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\nusing System.Text;\n\npublic class Solution {\n    public string EntryPoint(string label) {\n        var result = new StringBuilder();\n        foreach (char character in label) {\n            if (character != ' ') {\n                result.Append(character);\n            } else if (result.Length > 0 && result[result.Length - 1] != ' ') {\n                result.Append(' ');\n            }\n        }\n        return result.ToString().TrimEnd(' ');\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\nusing System.Text;\n\npublic class Solution {\n    public string EntryPoint(string label) {\n        var result = new StringBuilder();\n        foreach (char character in label) {\n            if (character != ' ') {\n                result.Append(character);\n            } else if (result.Length > 0 && result[result.Length - 1] != ' ') {\n                result.Append(' ');\n            }\n        }\n        return result.ToString().TrimStart(' ');\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "A warehouse receives delivery records represented as two parallel arrays: `items` and `quantities`, where `items[i]` is delivered with quantity `quantities[i]`. The same item may appear multiple times.\n\nImplement `Solution.EntryPoint(items, quantities)` to return an array of integers representing the total quantity delivered for each distinct item, ordered by each item's **first appearance** in `items`. Include every item that appears, even if its total is zero. Item names are case-sensitive.\n\n### Examples\n- Input: `items = [\"bolts\", \"bolts\"], quantities = [3, 4]`\n  Output: `[7]`\n- Input: `items = [\"tape\", \"glue\"], quantities = [2, 5]`\n  Output: `[2, 5]`\n\n### Constraints\n- `items.Length == quantities.Length`\n- `0 <= items.Length <= 10000`\n- Item names contain between `1` and `30` English letters.\n- `0 <= quantities[i] <= 100000`",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int[] EntryPoint(string[] items, int[] quantities) {\n        var order = new List<string>();\n        var totals = new Dictionary<string, int>();\n        for (int i = 0; i < items.Length; i++) {\n            string item = items[i];\n            int quantity = quantities[i];\n            if (!totals.ContainsKey(item)) {\n                totals[item] = 0;\n                order.Add(item);\n            }\n            totals[item] += quantity;\n        }\n        int[] result = new int[order.Count];\n        for (int i = 0; i < order.Count; i++) {\n            result[i] = totals[order[i]];\n        }\n        return result;\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int[] EntryPoint(string[] items, int[] quantities) {\n        var order = new List<string>();\n        var totals = new Dictionary<string, int>();\n        for (int i = 0; i < items.Length; i++) {\n            string item = items[i];\n            int quantity = quantities[i];\n            if (!totals.ContainsKey(item)) {\n                totals[item] = 0;\n                order.Add(item);\n            }\n            totals[item] = quantity;\n        }\n        int[] result = new int[order.Count];\n        for (int i = 0; i < order.Count; i++) {\n            result[i] = totals[order[i]];\n        }\n        return result;\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
    "signature": {
      "params": [
        {
          "name": "actions",
          "type": "string[]"
        }
      ],
      "returns": "string[]"
    },
    "description": "A small drafting tool processes a list of string actions. An action equal to `\"UNDO\"` removes the most recently added line that is still present. If no lines remain, `\"UNDO\"` does nothing. Every other action adds that string as a new line, including an empty string.\n\nImplement `Solution.EntryPoint(actions)` to return the remaining lines in their original insertion order as an array of strings. The reserved action `\"UNDO\"` cannot be added as ordinary text.\n\n### Examples\n- Input: `actions = [\"Title\", \"Draft\", \"UNDO\"]`\n  Output: `[\"Title\"]`\n- Input: `actions = [\"UNDO\", \"Hello\"]`\n  Output: `[\"Hello\"]`\n\n### Constraints\n- `0 <= actions.Length <= 10000`\n- Each action is a string containing at most `100` characters.\n- Actions are case-sensitive.",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public string[] EntryPoint(string[] actions) {\n        var lines = new List<string>();\n        foreach (string action in actions) {\n            if (action == \"UNDO\") {\n                if (lines.Count > 0) {\n                    lines.RemoveAt(lines.Count - 1);\n                }\n            } else {\n                lines.Add(action);\n            }\n        }\n        return lines.ToArray();\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public string[] EntryPoint(string[] actions) {\n        var lines = new List<string>();\n        foreach (string action in actions) {\n            if (action == \"UNDO\") {\n                if (lines.Count > 0) {\n                    lines.RemoveAt(0);\n                }\n            } else {\n                lines.Add(action);\n            }\n        }\n        return lines.ToArray();\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "A service publishes maintenance windows as pairs `[start, end]`. Each window includes its start time and excludes its end time. A customer's session follows the same rule.\n\nImplement `Solution.EntryPoint(windows, session_start, session_end)` to count how many maintenance windows overlap the session for a positive amount of time. A window that ends exactly when the session starts, or starts exactly when the session ends, does not overlap. Count each listed window separately, including duplicate windows.\n\n### Examples\n- Input: `windows = [[1, 4], [6, 9]], session_start = 3, session_end = 7`\n  Output: `2`\n- Input: `windows = [[1, 3], [7, 9]], session_start = 3, session_end = 7`\n  Output: `0`\n\n### Constraints\n- `0 <= windows.Length <= 10000`\n- Each window contains two integers satisfying `0 <= start < end <= 1000000`.\n- `0 <= session_start < session_end <= 1000000`\n- Windows may appear in any order and may overlap one another.",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int EntryPoint(int[][] windows, int session_start, int session_end) {\n        int count = 0;\n        foreach (var window in windows) {\n            int start = window[0];\n            int end = window[1];\n            int overlap_start = Math.Max(start, session_start);\n            int overlap_end = Math.Min(end, session_end);\n            if (overlap_start < overlap_end) {\n                count++;\n            }\n        }\n        return count;\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int EntryPoint(int[][] windows, int session_start, int session_end) {\n        int count = 0;\n        foreach (var window in windows) {\n            int start = window[0];\n            int end = window[1];\n            int overlap_start = Math.Max(start, session_start);\n            int overlap_end = Math.Min(end, session_end);\n            if (overlap_start <= overlap_end) {\n                count++;\n            }\n        }\n        return count;\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "An audit system stores events in chronological order. Each event has a category and a nonnegative review cost.\n\nImplement `Solution.EntryPoint(categories, costs, budget, category_limit)` to return the maximum number of consecutive events that can be selected while satisfying both rules:\n\n- Their total review cost is at most `budget`.\n- No category appears more than `category_limit` times.\n\nReturn `0` if no nonempty selection is valid. The input arrays have equal lengths, and their matching positions describe the same event.\n\n### Examples\n- Input: `categories = [\"a\", \"b\", \"a\"], costs = [2, 1, 2], budget = 5, category_limit = 2`\n  Output: `3`\n- Input: `categories = [\"a\", \"a\", \"b\"], costs = [1, 1, 1], budget = 3, category_limit = 1`\n  Output: `2`\n\n### Constraints\n- `0 <= categories.Length == costs.Length <= 100000`\n- Categories are nonempty lowercase English strings of length at most `20`.\n- `0 <= costs[i] <= 10000`\n- `0 <= budget <= 1000000000`\n- `1 <= category_limit <= 100000`",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int EntryPoint(string[] categories, int[] costs, int budget, int category_limit) {\n        var counts = new Dictionary<string, int>();\n        int left = 0;\n        long total = 0;\n        int best = 0;\n        for (int right = 0; right < categories.Length; right++) {\n            string category = categories[right];\n            int currentCount;\n            counts.TryGetValue(category, out currentCount);\n            counts[category] = currentCount + 1;\n            total += costs[right];\n            while (total > budget || counts[category] > category_limit) {\n                string departing = categories[left];\n                counts[departing]--;\n                total -= costs[left];\n                left++;\n            }\n            int length = right - left + 1;\n            best = Math.Max(best, length);\n        }\n        return best;\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int EntryPoint(string[] categories, int[] costs, int budget, int category_limit) {\n        var counts = new Dictionary<string, int>();\n        int left = 0;\n        long total = 0;\n        int best = 0;\n        for (int right = 0; right < categories.Length; right++) {\n            string category = categories[right];\n            int currentCount;\n            counts.TryGetValue(category, out currentCount);\n            counts[category] = currentCount + 1;\n            total += costs[right];\n            if (total > budget || counts[category] > category_limit) {\n                string departing = categories[left];\n                counts[departing]--;\n                total -= costs[left];\n                left++;\n            }\n            int length = right - left + 1;\n            best = Math.Max(best, length);\n        }\n        return best;\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
    "signature": {
      "params": [
        {
          "name": "query",
          "type": "string"
        }
      ],
      "returns": "string[]"
    },
    "description": "A search box accepts a small query language. Implement `Solution.EntryPoint(query)` to return its tokens in order as an array of strings according to these rules:\n\n- Ordinary ASCII spaces separate tokens when outside double quotes.\n- Double quotes toggle quoted mode and are omitted from the token. Spaces inside quotes are preserved.\n- A backslash escapes the next character, inside or outside quotes. The escaped character is added literally, and the backslash is omitted.\n- Adjacent quoted and unquoted portions belong to the same token unless separated by an unquoted, unescaped space.\n- Empty quoted portions count as a token when standing alone.\n- Leading, trailing, and repeated separator spaces do not create tokens.\n\n### Examples\n- Input: `query = \"red \\\"blue sky\\\"\"`\n  Output: `[\"red\", \"blue sky\"]`\n- Input: `query = \"a\\\"b c\\\"d\"`\n  Output: `[\"ab cd\"]`\n\n### Constraints\n- `0 <= query.Length <= 100000`\n- The query contains printable ASCII characters.\n- Every backslash has a following character.\n- Unescaped double quotes are balanced.",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\nusing System.Text;\n\npublic class Solution {\n    public string[] EntryPoint(string query) {\n        var tokens = new List<string>();\n        var current = new StringBuilder();\n        bool quoted = false;\n        bool active = false;\n        int i = 0;\n        while (i < query.Length) {\n            char character = query[i];\n            if (character == '\\\\') {\n                i++;\n                current.Append(query[i]);\n                active = true;\n            } else if (character == '\"') {\n                quoted = !quoted;\n                active = true;\n            } else if (character == ' ' && !quoted) {\n                if (active) {\n                    tokens.Add(current.ToString());\n                    current.Clear();\n                    active = false;\n                }\n            } else {\n                current.Append(character);\n                active = true;\n            }\n            i++;\n        }\n        if (active) {\n            tokens.Add(current.ToString());\n        }\n        return tokens.ToArray();\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\nusing System.Text;\n\npublic class Solution {\n    public string[] EntryPoint(string query) {\n        var tokens = new List<string>();\n        var current = new StringBuilder();\n        bool quoted = false;\n        bool active = false;\n        int i = 0;\n        while (i < query.Length) {\n            char character = query[i];\n            if (character == '\\\\' && quoted) {\n                i++;\n                current.Append(query[i]);\n                active = true;\n            } else if (character == '\"') {\n                quoted = !quoted;\n                active = true;\n            } else if (character == ' ' && !quoted) {\n                if (active) {\n                    tokens.Add(current.ToString());\n                    current.Clear();\n                    active = false;\n                }\n            } else {\n                current.Append(character);\n                active = true;\n            }\n            i++;\n        }\n        if (active) {\n            tokens.Add(current.ToString());\n        }\n        return tokens.ToArray();\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "A data platform must run `n` export jobs, numbered from `0` to `n - 1`. Job `i` takes `durations[i]` time units and cannot start before time `release_times[i]`.\n\nEach dependency `[before, after]` means that job `after` must wait until job `before` finishes. A job must wait for all its prerequisites. Unlimited workers are available, so unrelated jobs may run simultaneously. Jobs begin as soon as their release times and dependencies permit.\n\nImplement `Solution.EntryPoint(durations, release_times, dependencies)` to return an array of integers containing the earliest finish time of every job, in job-number order. The dependency graph is guaranteed to have no cycles.\n\n### Examples\n- Input: `durations = [2, 3], release_times = [0, 0], dependencies = [[0, 1]]`\n  Output: `[2, 5]`\n- Input: `durations = [2, 1], release_times = [5, 0], dependencies = []`\n  Output: `[7, 1]`\n\n### Constraints\n- `durations.Length == release_times.Length`\n- `0 <= durations.Length <= 10000`\n- `1 <= durations[i] <= 1000000`\n- `0 <= release_times[i] <= 1000000000`\n- There are at most `50000` dependencies.\n- Dependencies use valid, distinct job numbers, and duplicate dependency pairs do not occur.",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int[] EntryPoint(int[] durations, int[] release_times, int[][] dependencies) {\n        int n = durations.Length;\n        var outgoing = new List<int>[n];\n        for (int i = 0; i < n; i++) {\n            outgoing[i] = new List<int>();\n        }\n        int[] remaining = new int[n];\n        foreach (var dep in dependencies) {\n            int before = dep[0];\n            int after = dep[1];\n            outgoing[before].Add(after);\n            remaining[after]++;\n        }\n        int[] starts = (int[])release_times.Clone();\n        int[] finishes = new int[n];\n        var ready = new Queue<int>();\n        for (int i = 0; i < n; i++) {\n            if (remaining[i] == 0) {\n                ready.Enqueue(i);\n            }\n        }\n        while (ready.Count > 0) {\n            int job = ready.Dequeue();\n            finishes[job] = starts[job] + durations[job];\n            foreach (int child in outgoing[job]) {\n                starts[child] = Math.Max(starts[child], finishes[job]);\n                remaining[child]--;\n                if (remaining[child] == 0) {\n                    ready.Enqueue(child);\n                }\n            }\n        }\n        return finishes;\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int[] EntryPoint(int[] durations, int[] release_times, int[][] dependencies) {\n        int n = durations.Length;\n        var outgoing = new List<int>[n];\n        for (int i = 0; i < n; i++) {\n            outgoing[i] = new List<int>();\n        }\n        int[] remaining = new int[n];\n        foreach (var dep in dependencies) {\n            int before = dep[0];\n            int after = dep[1];\n            outgoing[before].Add(after);\n            remaining[after]++;\n        }\n        int[] starts = (int[])release_times.Clone();\n        int[] finishes = new int[n];\n        var ready = new Queue<int>();\n        for (int i = 0; i < n; i++) {\n            if (remaining[i] == 0) {\n                ready.Enqueue(i);\n            }\n        }\n        while (ready.Count > 0) {\n            int job = ready.Dequeue();\n            finishes[job] = starts[job] + durations[job];\n            foreach (int child in outgoing[job]) {\n                starts[child] = Math.Max(release_times[child], finishes[job]);\n                remaining[child]--;\n                if (remaining[child] == 0) {\n                    ready.Enqueue(child);\n                }\n            }\n        }\n        return finishes;\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "A facility receives resource reservations. Each reservation is `[start, end, units]` and uses `units` resources throughout the half-open time interval `[start, end)`. Simultaneous reservations add their resource usage.\n\nImplement `Solution.EntryPoint(reservations, threshold)` to return the total duration during which combined resource usage is at least `threshold`.\n\nCount elapsed time only once, regardless of how many reservations overlap. Reservations may be unsorted, duplicated, nested, or adjacent. Usage is zero outside all reservations.\n\n### Examples\n- Input: `reservations = [[0, 4, 2], [2, 6, 3]], threshold = 4`\n  Output: `2`\n  Explanation: Usage reaches at least 4 only during [2, 4).\n- Input: `reservations = [[1, 5, 3]], threshold = 3`\n  Output: `4`\n\n### Constraints\n- `0 <= reservations.Length <= 100000`\n- `0 <= start < end <= 1000000000`\n- `1 <= units <= 1000000`\n- `1 <= threshold <= 1000000000`",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int EntryPoint(int[][] reservations, int threshold) {\n        var changes = new SortedDictionary<int, long>();\n        foreach (var res in reservations) {\n            int start = res[0];\n            int end = res[1];\n            int units = res[2];\n            long currentStart;\n            changes.TryGetValue(start, out currentStart);\n            changes[start] = currentStart + units;\n\n            long currentEnd;\n            changes.TryGetValue(end, out currentEnd);\n            changes[end] = currentEnd - units;\n        }\n        long active = 0;\n        int? previous = null;\n        long duration = 0;\n        foreach (var kvp in changes) {\n            int time = kvp.Key;\n            if (previous.HasValue && active >= threshold) {\n                duration += time - previous.Value;\n            }\n            active += kvp.Value;\n            previous = time;\n        }\n        return (int)duration;\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int EntryPoint(int[][] reservations, int threshold) {\n        var changes = new SortedDictionary<int, long>();\n        foreach (var res in reservations) {\n            int start = res[0];\n            int end = res[1];\n            int units = res[2];\n            long currentStart;\n            changes.TryGetValue(start, out currentStart);\n            changes[start] = currentStart + units;\n\n            long currentEnd;\n            changes.TryGetValue(end, out currentEnd);\n            changes[end] = currentEnd - units;\n        }\n        long active = 0;\n        int? previous = null;\n        long duration = 0;\n        foreach (var kvp in changes) {\n            int time = kvp.Key;\n            if (previous.HasValue && active > threshold) {\n                duration += time - previous.Value;\n            }\n            active += kvp.Value;\n            previous = time;\n        }\n        return (int)duration;\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "A print shop must process jobs in their existing order. Each job has a positive intensity value. The shop partitions the jobs into nonempty, consecutive batches containing at most `max_batch` jobs each.\n\nThe cost of a batch is:\n\n`setup_cost + (number of jobs in the batch) * (maximum intensity in the batch)`\n\nEvery job must belong to exactly one batch. Jobs cannot be reordered.\n\nImplement `Solution.EntryPoint(intensities, max_batch, setup_cost)` to return the minimum total cost. Return `0` when there are no jobs.\n\n### Examples\n- Input: `intensities = [2, 2], max_batch = 2, setup_cost = 3`\n  Output: `7`\n  Explanation: One batch costs 3 + 2 * 2 = 7.\n- Input: `intensities = [1, 10], max_batch = 2, setup_cost = 2`\n  Output: `15`\n  Explanation: Separate batches cost (2 + 1) + (2 + 10) = 15.\n\n### Constraints\n- `0 <= intensities.Length <= 1000`\n- `1 <= intensities[i] <= 10000`\n- `1 <= max_batch <= 100`\n- `0 <= setup_cost <= 10000`",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int EntryPoint(int[] intensities, int max_batch, int setup_cost) {\n        int n = intensities.Length;\n        int[] dp = new int[n + 1];\n        for (int end = 1; end <= n; end++) {\n            int peak = intensities[end - 1];\n            int best = dp[end - 1] + setup_cost + peak;\n            int limit = Math.Min(max_batch, end);\n            for (int length = 1; length <= limit; length++) {\n                peak = Math.Max(peak, intensities[end - length]);\n                int candidate = dp[end - length] + setup_cost + length * peak;\n                best = Math.Min(best, candidate);\n            }\n            dp[end] = best;\n        }\n        return dp[n];\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int EntryPoint(int[] intensities, int max_batch, int setup_cost) {\n        int n = intensities.Length;\n        int[] dp = new int[n + 1];\n        for (int end = 1; end <= n; end++) {\n            int peak = intensities[end - 1];\n            int best = dp[end - 1] + setup_cost + peak;\n            int limit = Math.Min(max_batch, end);\n            for (int length = 1; length < limit; length++) {\n                peak = Math.Max(peak, intensities[end - length]);\n                int candidate = dp[end - length] + setup_cost + length * peak;\n                best = Math.Min(best, candidate);\n            }\n            dp[end] = best;\n        }\n        return dp[n];\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "A network contains `n` devices numbered from `0` to `n - 1`. Its undirected links are available only during specified time windows.\n\nEach record `[u, v, start, end]` in `links` makes a link available throughout the half-open interval `[start, end)`. Multiple records may describe the same pair of devices; the link is available whenever any corresponding record is active.\n\nEach query `[time, u, v]` asks whether the devices are connected by a path of links that are all available at that time. A device is always connected to itself.\n\nImplement `Solution.EntryPoint(n, links, queries)` to return an array of booleans in the original query order. Neither links nor queries are necessarily sorted.\n\n### Examples\n- Input: `n = 3, links = [[0,1,0,5],[1,2,2,4]], queries = [[1,0,2],[3,0,2]]`\n  Output: `[false, true]`\n- Input: `n = 2, links = [[0,1,1,3]], queries = [[1,0,1],[3,0,1]]`\n  Output: `[true, false]`\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= links.Length, queries.Length <= 30000`\n- All device numbers are valid.\n- Link endpoints are distinct.\n- `0 <= start < end <= 1000000000`\n- Query times are integers between `0` and `1000000000`.",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    struct Rollback {\n        public int b;\n        public int a;\n        public int oldSize;\n        public Rollback(int b, int a, int oldSize) {\n            this.b = b;\n            this.a = a;\n            this.oldSize = oldSize;\n        }\n    }\n\n    static int LowerBound(List<int> list, int val) {\n        int l = 0, r = list.Count;\n        while (l < r) {\n            int m = l + (r - l) / 2;\n            if (list[m] < val) l = m + 1;\n            else r = m;\n        }\n        return l;\n    }\n\n    private int[] parent;\n    private int[] size;\n    private List<Rollback> history;\n    private bool[] answer;\n    private List<Tuple<int, int>>[] tree;\n    private List<Tuple<int, int, int>>[] buckets;\n    private int baseVal;\n\n    private int Find(int x) {\n        while (parent[x] != x) {\n            x = parent[x];\n        }\n        return x;\n    }\n\n    private void Visit(int node) {\n        int snapshot = history.Count;\n        foreach (var edge in tree[node]) {\n            int a = Find(edge.Item1);\n            int b = Find(edge.Item2);\n            if (a != b) {\n                if (size[a] < size[b]) {\n                    int tmp = a; a = b; b = tmp;\n                }\n                history.Add(new Rollback(b, a, size[a]));\n                parent[b] = a;\n                size[a] += size[b];\n            }\n        }\n        if (node >= baseVal) {\n            int bIdx = node - baseVal;\n            if (bIdx < baseVal) {\n                foreach (var q in buckets[bIdx]) {\n                    answer[q.Item1] = (Find(q.Item2) == Find(q.Item3));\n                }\n            }\n        } else {\n            Visit(2 * node);\n            Visit(2 * node + 1);\n        }\n        while (history.Count > snapshot) {\n            var rb = history[history.Count - 1];\n            history.RemoveAt(history.Count - 1);\n            parent[rb.b] = rb.b;\n            size[rb.a] = rb.oldSize;\n        }\n    }\n\n    public bool[] EntryPoint(int n, int[][] links, int[][] queries) {\n        if (queries.Length == 0) return new bool[0];\n        var timesSet = new SortedSet<int>();\n        foreach (var q in queries) timesSet.Add(q[0]);\n        var times = new List<int>(timesSet);\n\n        baseVal = 1;\n        while (baseVal < times.Count) baseVal <<= 1;\n\n        tree = new List<Tuple<int, int>>[2 * baseVal];\n        for (int i = 0; i < 2 * baseVal; i++) tree[i] = new List<Tuple<int, int>>();\n\n        foreach (var link in links) {\n            int u = link[0];\n            int v = link[1];\n            int start = link[2];\n            int end = link[3];\n            int left = LowerBound(times, start) + baseVal;\n            int right = LowerBound(times, end) + baseVal;\n            while (left < right) {\n                if ((left & 1) == 1) {\n                    tree[left].Add(Tuple.Create(u, v));\n                    left++;\n                }\n                if ((right & 1) == 1) {\n                    right--;\n                    tree[right].Add(Tuple.Create(u, v));\n                }\n                left /= 2;\n                right /= 2;\n            }\n        }\n\n        buckets = new List<Tuple<int, int, int>>[baseVal];\n        for (int i = 0; i < baseVal; i++) buckets[i] = new List<Tuple<int, int, int>>();\n        for (int i = 0; i < queries.Length; i++) {\n            int time = queries[i][0];\n            int u = queries[i][1];\n            int v = queries[i][2];\n            buckets[LowerBound(times, time)].Add(Tuple.Create(i, u, v));\n        }\n\n        parent = new int[n];\n        size = new int[n];\n        for (int i = 0; i < n; i++) {\n            parent[i] = i;\n            size[i] = 1;\n        }\n        history = new List<Rollback>();\n        answer = new bool[queries.Length];\n\n        Visit(1);\n        return answer;\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    struct Rollback {\n        public int b;\n        public int a;\n        public int oldSize;\n        public Rollback(int b, int a, int oldSize) {\n            this.b = b;\n            this.a = a;\n            this.oldSize = oldSize;\n        }\n    }\n\n    static int LowerBound(List<int> list, int val) {\n        int l = 0, r = list.Count;\n        while (l < r) {\n            int m = l + (r - l) / 2;\n            if (list[m] < val) l = m + 1;\n            else r = m;\n        }\n        return l;\n    }\n\n    static int UpperBound(List<int> list, int val) {\n        int l = 0, r = list.Count;\n        while (l < r) {\n            int m = l + (r - l) / 2;\n            if (list[m] <= val) l = m + 1;\n            else r = m;\n        }\n        return l;\n    }\n\n    private int[] parent;\n    private int[] size;\n    private List<Rollback> history;\n    private bool[] answer;\n    private List<Tuple<int, int>>[] tree;\n    private List<Tuple<int, int, int>>[] buckets;\n    private int baseVal;\n\n    private int Find(int x) {\n        while (parent[x] != x) {\n            parent[x] = parent[parent[x]];\n            x = parent[x];\n        }\n        return x;\n    }\n\n    private void Visit(int node) {\n        int snapshot = history.Count;\n        foreach (var edge in tree[node]) {\n            int a = Find(edge.Item1);\n            int b = Find(edge.Item2);\n            if (a != b) {\n                if (size[a] < size[b]) {\n                    int tmp = a; a = b; b = tmp;\n                }\n                history.Add(new Rollback(b, a, size[a]));\n                parent[b] = a;\n                size[a] += size[b];\n            }\n        }\n        if (node >= baseVal) {\n            int bIdx = node - baseVal;\n            if (bIdx < baseVal) {\n                foreach (var q in buckets[bIdx]) {\n                    answer[q.Item1] = (Find(q.Item2) == Find(q.Item3));\n                }\n            }\n        } else {\n            Visit(2 * node);\n            Visit(2 * node + 1);\n        }\n        while (history.Count > snapshot) {\n            var rb = history[history.Count - 1];\n            history.RemoveAt(history.Count - 1);\n            parent[rb.b] = rb.b;\n            size[rb.a] = rb.oldSize;\n        }\n    }\n\n    public bool[] EntryPoint(int n, int[][] links, int[][] queries) {\n        if (queries.Length == 0) return new bool[0];\n        var timesSet = new SortedSet<int>();\n        foreach (var q in queries) timesSet.Add(q[0]);\n        var times = new List<int>(timesSet);\n\n        baseVal = 1;\n        while (baseVal < times.Count) baseVal <<= 1;\n\n        tree = new List<Tuple<int, int>>[2 * baseVal];\n        for (int i = 0; i < 2 * baseVal; i++) tree[i] = new List<Tuple<int, int>>();\n\n        foreach (var link in links) {\n            int u = link[0];\n            int v = link[1];\n            int start = link[2];\n            int end = link[3];\n            int left = LowerBound(times, start) + baseVal;\n            int right = UpperBound(times, end) + baseVal;\n            while (left < right) {\n                if ((left & 1) == 1) {\n                    tree[left].Add(Tuple.Create(u, v));\n                    left++;\n                }\n                if ((right & 1) == 1) {\n                    right--;\n                    tree[right].Add(Tuple.Create(u, v));\n                }\n                left /= 2;\n                right /= 2;\n            }\n        }\n\n        buckets = new List<Tuple<int, int, int>>[baseVal];\n        for (int i = 0; i < baseVal; i++) buckets[i] = new List<Tuple<int, int, int>>();\n        for (int i = 0; i < queries.Length; i++) {\n            int time = queries[i][0];\n            int u = queries[i][1];\n            int v = queries[i][2];\n            buckets[LowerBound(times, time)].Add(Tuple.Create(i, u, v));\n        }\n\n        parent = new int[n];\n        size = new int[n];\n        for (int i = 0; i < n; i++) {\n            parent[i] = i;\n            size[i] = 1;\n        }\n        history = new List<Rollback>();\n        answer = new bool[queries.Length];\n\n        Visit(1);\n        return answer;\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "A shipment starts at depot `0` at `start_time` and must reach depot `n - 1`.\n\nEach directed route is `[u, v, offset, period, duration]`. Regular vehicles depart depot `u` at times `offset + k * period` for every integer `k >= 0`, and take `duration` time units to reach depot `v`. A shipment arriving exactly at a departure time may board that vehicle. Waiting at depots is allowed.\n\nThe shipment has one express dispatch voucher. At most once during the entire journey, it may traverse any listed route immediately, ignoring its departure schedule but still taking that route's full travel duration. This is allowed even before the route's first regular departure.\n\nImplement `Solution.EntryPoint(n, routes, start_time)` to return the earliest absolute arrival time at depot `n - 1`, or `-1` if it is unreachable. The voucher does not need to be used.\n\n### Examples\n- Input: `n = 2, routes = [[0,1,10,5,3]], start_time = 0`\n  Output: `3`\n  Explanation: An express dispatch leaves immediately.\n- Input: `n = 3, routes = [[0,1,0,10,2],[1,2,5,10,2]], start_time = 0`\n  Output: `4`\n  Explanation: Take the first regular departure, then use the voucher.\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= routes.Length <= 50000`\n- Routes use valid, distinct endpoints. Parallel routes and directed cycles are allowed.\n- `0 <= offset, start_time <= 1000000000`\n- `1 <= period, duration <= 1000000`",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    class MinHeap {\n        struct Item {\n            public long Time;\n            public int Node;\n            public int Used;\n            public Item(long time, int node, int used) {\n                Time = time; Node = node; Used = used;\n            }\n        }\n        private List<Item> heap = new List<Item>();\n        public int Count { get { return heap.Count; } }\n\n        public void Push(long time, int node, int used) {\n            heap.Add(new Item(time, node, used));\n            int i = heap.Count - 1;\n            while (i > 0) {\n                int p = (i - 1) / 2;\n                if (heap[p].Time <= heap[i].Time) break;\n                var tmp = heap[p]; heap[p] = heap[i]; heap[i] = tmp;\n                i = p;\n            }\n        }\n\n        public void Pop(out long time, out int node, out int used) {\n            var top = heap[0];\n            time = top.Time; node = top.Node; used = top.Used;\n            int last = heap.Count - 1;\n            heap[0] = heap[last];\n            heap.RemoveAt(last);\n            int i = 0;\n            while (true) {\n                int left = 2 * i + 1;\n                int right = 2 * i + 2;\n                int smallest = i;\n                if (left < heap.Count && heap[left].Time < heap[smallest].Time) smallest = left;\n                if (right < heap.Count && heap[right].Time < heap[smallest].Time) smallest = right;\n                if (smallest == i) break;\n                var tmp = heap[i]; heap[i] = heap[smallest]; heap[smallest] = tmp;\n                i = smallest;\n            }\n        }\n    }\n\n    struct Route {\n        public int Target;\n        public long Offset;\n        public long Period;\n        public long Duration;\n    }\n\n    public int EntryPoint(int n, int[][] routes, int start_time) {\n        var graph = new List<Route>[n];\n        for (int i = 0; i < n; i++) graph[i] = new List<Route>();\n        foreach (var r in routes) {\n            graph[r[0]].Add(new Route { Target = r[1], Offset = r[2], Period = r[3], Duration = r[4] });\n        }\n\n        long INF = long.MaxValue;\n        long[,] best = new long[n, 2];\n        for (int i = 0; i < n; i++) {\n            best[i, 0] = INF;\n            best[i, 1] = INF;\n        }\n\n        var pq = new MinHeap();\n        best[0, 0] = start_time;\n        pq.Push(start_time, 0, 0);\n\n        while (pq.Count > 0) {\n            long time;\n            int node;\n            int used;\n            pq.Pop(out time, out node, out used);\n\n            if (time != best[node, used]) continue;\n            if (node == n - 1) return (int)time;\n\n            foreach (var route in graph[node]) {\n                long departure;\n                if (time <= route.Offset) {\n                    departure = route.Offset;\n                } else {\n                    departure = route.Offset + ((time - route.Offset + route.Period - 1) / route.Period) * route.Period;\n                }\n                long arrival = departure + route.Duration;\n                if (arrival < best[route.Target, used]) {\n                    best[route.Target, used] = arrival;\n                    pq.Push(arrival, route.Target, used);\n                }\n                if (used == 0) {\n                    long express_arrival = time + route.Duration;\n                    if (express_arrival < best[route.Target, 1]) {\n                        best[route.Target, 1] = express_arrival;\n                        pq.Push(express_arrival, route.Target, 1);\n                    }\n                }\n            }\n        }\n        return -1;\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    class MinHeap {\n        struct Item {\n            public long Time;\n            public int Node;\n            public int Used;\n            public Item(long time, int node, int used) {\n                Time = time; Node = node; Used = used;\n            }\n        }\n        private List<Item> heap = new List<Item>();\n        public int Count { get { return heap.Count; } }\n\n        public void Push(long time, int node, int used) {\n            heap.Add(new Item(time, node, used));\n            int i = heap.Count - 1;\n            while (i > 0) {\n                int p = (i - 1) / 2;\n                if (heap[p].Time <= heap[i].Time) break;\n                var tmp = heap[p]; heap[p] = heap[i]; heap[i] = tmp;\n                i = p;\n            }\n        }\n\n        public void Pop(out long time, out int node, out int used) {\n            var top = heap[0];\n            time = top.Time; node = top.Node; used = top.Used;\n            int last = heap.Count - 1;\n            heap[0] = heap[last];\n            heap.RemoveAt(last);\n            int i = 0;\n            while (true) {\n                int left = 2 * i + 1;\n                int right = 2 * i + 2;\n                int smallest = i;\n                if (left < heap.Count && heap[left].Time < heap[smallest].Time) smallest = left;\n                if (right < heap.Count && heap[right].Time < heap[smallest].Time) smallest = right;\n                if (smallest == i) break;\n                var tmp = heap[i]; heap[i] = heap[smallest]; heap[smallest] = tmp;\n                i = smallest;\n            }\n        }\n    }\n\n    struct Route {\n        public int Target;\n        public long Offset;\n        public long Period;\n        public long Duration;\n    }\n\n    public int EntryPoint(int n, int[][] routes, int start_time) {\n        var graph = new List<Route>[n];\n        for (int i = 0; i < n; i++) graph[i] = new List<Route>();\n        foreach (var r in routes) {\n            graph[r[0]].Add(new Route { Target = r[1], Offset = r[2], Period = r[3], Duration = r[4] });\n        }\n\n        long INF = long.MaxValue;\n        long[,] best = new long[n, 2];\n        for (int i = 0; i < n; i++) {\n            best[i, 0] = INF;\n            best[i, 1] = INF;\n        }\n\n        var pq = new MinHeap();\n        best[0, 0] = start_time;\n        pq.Push(start_time, 0, 0);\n\n        while (pq.Count > 0) {\n            long time;\n            int node;\n            int used;\n            pq.Pop(out time, out node, out used);\n\n            if (time != best[node, used]) continue;\n            if (node == n - 1) return (int)time;\n\n            foreach (var route in graph[node]) {\n                long departure;\n                if (time <= route.Offset) {\n                    departure = route.Offset;\n                } else {\n                    departure = route.Offset + ((time - route.Offset + route.Period) / route.Period) * route.Period;\n                }\n                long arrival = departure + route.Duration;\n                if (arrival < best[route.Target, 0]) {\n                    best[route.Target, 0] = arrival;\n                    pq.Push(arrival, route.Target, 0);\n                }\n                if (used == 0) {\n                    long express_arrival = time + route.Duration;\n                    if (express_arrival < best[route.Target, 1]) {\n                        best[route.Target, 1] = express_arrival;\n                        pq.Push(express_arrival, route.Target, 1);\n                    }\n                }\n            }\n        }\n        return -1;\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "An encoding service must cover a text using a sequence of catalog entries. The catalog entries are given as two parallel arrays: `patterns` and `costs`, where `patterns[i]` costs `costs[i]`.\n\nA pattern contains lowercase English letters and may contain `?`, which matches exactly one lowercase letter. Applying an entry consumes a consecutive portion of the text whose length equals the pattern's length. Entries must cover the entire text in order, without gaps or overlaps. Every catalog entry may be reused any number of times.\n\nImplement `Solution.EntryPoint(text, patterns, costs)` to return an array of two integers `[minimum_cost, optimal_encoding_count]`. Count optimal encodings modulo `1000000007`.\n\nAn encoding is identified by its ordered sequence of catalog indices. Duplicate catalog rows are distinct choices. Different matching characters for a wildcard do not create additional choices because the text is fixed.\n\nReturn `[-1, 0]` if the text cannot be covered. The empty text has cost `0` and exactly one encoding: the empty sequence.\n\n### Examples\n- Input: `text = \"ab\", patterns = [\"a\", \"b\", \"ab\"], costs = [2, 3, 4]`\n  Output: `[4, 1]`\n- Input: `text = \"ab\", patterns = [\"a\", \"b\", \"??\"], costs = [1, 1, 2]`\n  Output: `[2, 2]`\n  Explanation: Using the first two entries or the third entry gives the same minimum cost.\n\n### Constraints\n- `0 <= text.Length <= 2000`\n- `text` contains only lowercase English letters.\n- `patterns.Length == costs.Length`\n- `0 <= patterns.Length <= 200`\n- Each pattern has length between `1` and `30`.\n- `0 <= costs[i] <= 1000000`",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int[] EntryPoint(string text, string[] patterns, int[] costs) {\n        var children = new List<Dictionary<char, int>>();\n        var terminals = new List<List<int>>();\n        children.Add(new Dictionary<char, int>());\n        terminals.Add(new List<int>());\n\n        for (int p = 0; p < patterns.Length; p++) {\n            string pattern = patterns[p];\n            int cost = costs[p];\n            int node = 0;\n            foreach (char character in pattern) {\n                if (!children[node].ContainsKey(character)) {\n                    children[node][character] = children.Count;\n                    children.Add(new Dictionary<char, int>());\n                    terminals.Add(new List<int>());\n                }\n                node = children[node][character];\n            }\n            terminals[node].Add(cost);\n        }\n\n        int n = text.Length;\n        long INF = 1000000000000000L;\n        long[] best = new long[n + 1];\n        long[] ways = new long[n + 1];\n        for (int i = 0; i <= n; i++) best[i] = INF;\n        best[0] = 0;\n        ways[0] = 1;\n        long modulus = 1000000007L;\n\n        for (int start = 0; start < n; start++) {\n            if (best[start] == INF) continue;\n            var active = new List<int> { 0 };\n            for (int end = start; end < n; end++) {\n                var following = new List<int>();\n                char ch = text[end];\n                foreach (int node in active) {\n                    int nxt;\n                    if (children[node].TryGetValue(ch, out nxt)) following.Add(nxt);\n                    if (children[node].TryGetValue('?', out nxt)) following.Add(nxt);\n                }\n                active = following;\n                if (active.Count == 0) break;\n                foreach (int node in active) {\n                    foreach (int cost in terminals[node]) {\n                        long candidate = best[start] + cost;\n                        if (candidate < best[end + 1]) {\n                            best[end + 1] = candidate;\n                            ways[end + 1] = ways[start];\n                        } else if (candidate == best[end + 1]) {\n                            ways[end + 1] = (ways[end + 1] + ways[start]) % modulus;\n                        }\n                    }\n                }\n            }\n        }\n\n        if (best[n] == INF) return new int[] { -1, 0 };\n        return new int[] { (int)best[n], (int)ways[n] };\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    public int[] EntryPoint(string text, string[] patterns, int[] costs) {\n        var children = new List<Dictionary<char, int>>();\n        var terminals = new List<List<int>>();\n        children.Add(new Dictionary<char, int>());\n        terminals.Add(new List<int>());\n\n        for (int p = 0; p < patterns.Length; p++) {\n            string pattern = patterns[p];\n            int cost = costs[p];\n            int node = 0;\n            foreach (char character in pattern) {\n                if (!children[node].ContainsKey(character)) {\n                    children[node][character] = children.Count;\n                    children.Add(new Dictionary<char, int>());\n                    terminals.Add(new List<int>());\n                }\n                node = children[node][character];\n            }\n            terminals[node].Add(cost);\n        }\n\n        int n = text.Length;\n        long INF = 1000000000000000L;\n        long[] best = new long[n + 1];\n        long[] ways = new long[n + 1];\n        for (int i = 0; i <= n; i++) best[i] = INF;\n        best[0] = 0;\n        ways[0] = 1;\n        long modulus = 1000000007L;\n\n        for (int start = 0; start < n; start++) {\n            if (best[start] == INF) continue;\n            var active = new List<int> { 0 };\n            for (int end = start; end < n; end++) {\n                var following = new List<int>();\n                char ch = text[end];\n                foreach (int node in active) {\n                    int nxt;\n                    if (children[node].TryGetValue(ch, out nxt)) following.Add(nxt);\n                    if (children[node].TryGetValue('?', out nxt)) following.Add(nxt);\n                }\n                active = following;\n                if (active.Count == 0) break;\n                foreach (int node in active) {\n                    foreach (int cost in terminals[node]) {\n                        long candidate = best[start] + cost;\n                        if (candidate < best[end + 1]) {\n                            best[end + 1] = candidate;\n                            ways[end + 1] = (ways[end + 1] + ways[start]) % modulus;\n                        } else if (candidate == best[end + 1]) {\n                            ways[end + 1] = ways[start];\n                        }\n                    }\n                }\n            }\n        }\n\n        if (best[n] == INF) return new int[] { -1, 0 };\n        return new int[] { (int)best[n], (int)ways[n] };\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "A laboratory owns `capacity` interchangeable pieces of equipment. Each requested job is `[start, end, profit]` and requires one piece of equipment continuously throughout the half-open interval `[start, end)`.\n\nThe laboratory may accept or reject each job. Accepted jobs cannot be interrupted, and no more than `capacity` accepted jobs may be active at any time. A piece of equipment may be reused immediately when a job ends.\n\nImplement `Solution.EntryPoint(jobs, capacity)` to return the maximum total profit obtainable.\n\nEach array row represents a separate request, even when multiple requests have identical values. Each request may be accepted at most once. Accepting no jobs is allowed.\n\n### Examples\n- Input: `jobs = [[0,2,5],[1,3,7]], capacity = 1`\n  Output: `7`\n- Input: `jobs = [[0,2,5],[1,3,7]], capacity = 2`\n  Output: `12`\n\n### Constraints\n- `0 <= jobs.Length <= 500`\n- `1 <= capacity <= 20`\n- `0 <= start < end <= 1000000000`\n- `1 <= profit <= 1000000`\n- Jobs may be unsorted, duplicated, nested, or adjacent.",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    class Edge {\n        public int V;\n        public int Limit;\n        public int Cost;\n        public int Reverse;\n        public Edge(int v, int limit, int cost, int reverse) {\n            V = v; Limit = limit; Cost = cost; Reverse = reverse;\n        }\n    }\n\n    private void AddEdge(List<Edge>[] graph, int u, int v, int limit, int cost) {\n        graph[u].Add(new Edge(v, limit, cost, graph[v].Count));\n        graph[v].Add(new Edge(u, 0, -cost, graph[u].Count - 1));\n    }\n\n    public int EntryPoint(int[][] jobs, int capacity) {\n        if (jobs.Length == 0) return 0;\n        var timesSet = new SortedSet<int>();\n        foreach (var job in jobs) {\n            timesSet.Add(job[0]);\n            timesSet.Add(job[1]);\n        }\n        var times = new List<int>(timesSet);\n        var index = new Dictionary<int, int>();\n        for (int i = 0; i < times.Count; i++) {\n            index[times[i]] = i;\n        }\n\n        var graph = new List<Edge>[times.Count];\n        for (int i = 0; i < times.Count; i++) graph[i] = new List<Edge>();\n\n        for (int i = 0; i < times.Count - 1; i++) {\n            AddEdge(graph, i, i + 1, capacity, 0);\n        }\n        foreach (var job in jobs) {\n            AddEdge(graph, index[job[0]], index[job[1]], 1, -job[2]);\n        }\n\n        int total = 0;\n        int remaining = capacity;\n        int nNodes = times.Count;\n\n        while (remaining > 0) {\n            int[] distance = new int[nNodes];\n            for (int i = 0; i < nNodes; i++) distance[i] = int.MaxValue;\n            int[] prevNode = new int[nNodes];\n            int[] prevEdge = new int[nNodes];\n            distance[0] = 0;\n\n            var queue = new Queue<int>();\n            var inQueue = new HashSet<int>();\n            queue.Enqueue(0);\n            inQueue.Add(0);\n\n            while (queue.Count > 0) {\n                int u = queue.Dequeue();\n                inQueue.Remove(u);\n                for (int edgeId = 0; edgeId < graph[u].Count; edgeId++) {\n                    var edge = graph[u][edgeId];\n                    if (edge.Limit > 0 && distance[u] != int.MaxValue && distance[u] + edge.Cost < distance[edge.V]) {\n                        distance[edge.V] = distance[u] + edge.Cost;\n                        prevNode[edge.V] = u;\n                        prevEdge[edge.V] = edgeId;\n                        if (!inQueue.Contains(edge.V)) {\n                            queue.Enqueue(edge.V);\n                            inQueue.Add(edge.V);\n                        }\n                    }\n                }\n            }\n\n            int pushed = remaining;\n            int node = nNodes - 1;\n            while (node != 0) {\n                int u = prevNode[node];\n                int edgeId = prevEdge[node];\n                pushed = Math.Min(pushed, graph[u][edgeId].Limit);\n                node = u;\n            }\n\n            node = nNodes - 1;\n            while (node != 0) {\n                int u = prevNode[node];\n                int edgeId = prevEdge[node];\n                var edge = graph[u][edgeId];\n                edge.Limit -= pushed;\n                graph[node][edge.Reverse].Limit += pushed;\n                node = u;\n            }\n\n            remaining -= pushed;\n            total -= pushed * distance[nNodes - 1];\n        }\n\n        return total;\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    class Edge {\n        public int V;\n        public int Limit;\n        public int Cost;\n        public int Reverse;\n        public Edge(int v, int limit, int cost, int reverse) {\n            V = v; Limit = limit; Cost = cost; Reverse = reverse;\n        }\n    }\n\n    private void AddEdge(List<Edge>[] graph, int u, int v, int limit, int cost) {\n        graph[u].Add(new Edge(v, limit, cost, graph[v].Count));\n        graph[v].Add(new Edge(u, 0, -cost, graph[u].Count - 1));\n    }\n\n    public int EntryPoint(int[][] jobs, int capacity) {\n        if (jobs.Length == 0) return 0;\n        var timesSet = new SortedSet<int>();\n        foreach (var job in jobs) {\n            timesSet.Add(job[0]);\n            timesSet.Add(job[1]);\n        }\n        var times = new List<int>(timesSet);\n        var index = new Dictionary<int, int>();\n        for (int i = 0; i < times.Count; i++) {\n            index[times[i]] = i;\n        }\n\n        var graph = new List<Edge>[times.Count];\n        for (int i = 0; i < times.Count; i++) graph[i] = new List<Edge>();\n\n        for (int i = 0; i < times.Count - 1; i++) {\n            AddEdge(graph, i, i + 1, capacity, 0);\n        }\n\n        var seen = new HashSet<string>();\n        foreach (var job in jobs) {\n            string key = job[0] + \",\" + job[1] + \",\" + job[2];\n            if (seen.Add(key)) {\n                AddEdge(graph, index[job[0]], index[job[1]], 1, -job[2]);\n            }\n        }\n\n        int total = 0;\n        int remaining = capacity;\n        int nNodes = times.Count;\n\n        while (remaining > 0) {\n            int[] distance = new int[nNodes];\n            for (int i = 0; i < nNodes; i++) distance[i] = int.MaxValue;\n            int[] prevNode = new int[nNodes];\n            int[] prevEdge = new int[nNodes];\n            distance[0] = 0;\n\n            var queue = new Queue<int>();\n            var inQueue = new HashSet<int>();\n            queue.Enqueue(0);\n            inQueue.Add(0);\n\n            while (queue.Count > 0) {\n                int u = queue.Dequeue();\n                inQueue.Remove(u);\n                for (int edgeId = 0; edgeId < graph[u].Count; edgeId++) {\n                    var edge = graph[u][edgeId];\n                    if (edge.Limit > 0 && distance[u] != int.MaxValue && distance[u] + edge.Cost < distance[edge.V]) {\n                        distance[edge.V] = distance[u] + edge.Cost;\n                        prevNode[edge.V] = u;\n                        prevEdge[edge.V] = edgeId;\n                        if (!inQueue.Contains(edge.V)) {\n                            queue.Enqueue(edge.V);\n                            inQueue.Add(edge.V);\n                        }\n                    }\n                }\n            }\n\n            int pushed = remaining;\n            int node = nNodes - 1;\n            while (node != 0) {\n                int u = prevNode[node];\n                int edgeId = prevEdge[node];\n                pushed = Math.Min(pushed, graph[u][edgeId].Limit);\n                node = u;\n            }\n\n            node = nNodes - 1;\n            while (node != 0) {\n                int u = prevNode[node];\n                int edgeId = prevEdge[node];\n                var edge = graph[u][edgeId];\n                edge.Limit -= pushed;\n                node = u;\n            }\n\n            remaining -= pushed;\n            total -= pushed * distance[nNodes - 1];\n        }\n\n        return total;\n    }\n}",
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
    "language": "csharp",
    "entry_point": "EntryPoint",
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
    "description": "A financial reconciliation system receives an ordered list of signed adjustments. It must partition the entire list into exactly `groups` nonempty, consecutive batches without changing their order.\n\nFor a batch whose adjustments sum to `s`, its penalty is `(s - target)²`. Positive and negative adjustments may cancel within a batch.\n\nImplement `Solution.EntryPoint(values, groups, target)` to return the minimum possible sum of batch penalties. Every adjustment must belong to exactly one batch.\n\n### Examples\n- Input: `values = [1, 2], groups = 1, target = 3`\n  Output: `0`\n  Explanation: The single batch sums to the target.\n- Input: `values = [1, 2], groups = 2, target = 2`\n  Output: `1`\n  Explanation: The required batches are `[1]` and `[2]`, with penalties `1` and `0`.\n\n### Constraints\n- `1 <= values.Length <= 5000`\n- `1 <= groups <= Math.Min(30, values.Length)`\n- `-10000 <= values[i], target <= 10000`\n- All inputs are integers.",
    "fixed_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    struct Line {\n        public long M;\n        public long C;\n        public Line(long m, long c) { M = m; C = c; }\n    }\n\n    private static long Evaluate(Line line, long x) {\n        return line.M * x + line.C;\n    }\n\n    private Line?[] tree;\n    private long[] xs;\n    private const long INF = 1000000000000000000L;\n\n    private void Insert(Line line, int node, int left, int right) {\n        if (!tree[node].HasValue) {\n            tree[node] = line;\n            return;\n        }\n        int middle = left + (right - left) / 2;\n        Line curr = tree[node].Value;\n        bool betterLeft = Evaluate(line, xs[left]) < Evaluate(curr, xs[left]);\n        bool betterMiddle = Evaluate(line, xs[middle]) < Evaluate(curr, xs[middle]);\n        if (betterMiddle) {\n            tree[node] = line;\n            line = curr;\n        }\n        if (left == right) return;\n        if (betterLeft != betterMiddle) {\n            Insert(line, node * 2, left, middle);\n        } else {\n            Insert(line, node * 2 + 1, middle + 1, right);\n        }\n    }\n\n    private long Query(long x, int node, int left, int right) {\n        if (!tree[node].HasValue) return INF;\n        long answer = Evaluate(tree[node].Value, x);\n        if (left == right) return answer;\n        int middle = left + (right - left) / 2;\n        if (x <= xs[middle]) {\n            return Math.Min(answer, Query(x, node * 2, left, middle));\n        }\n        return Math.Min(answer, Query(x, node * 2 + 1, middle + 1, right));\n    }\n\n    public int EntryPoint(int[] values, int groups, int target) {\n        long[] prefix = new long[values.Length + 1];\n        for (int i = 0; i < values.Length; i++) {\n            prefix[i + 1] = prefix[i] + values[i];\n        }\n\n        var xsSet = new SortedSet<long>();\n        for (int i = 1; i <= values.Length; i++) {\n            xsSet.Add(prefix[i] - target);\n        }\n        xs = xsSet.ToArray();\n\n        long[] previous = new long[values.Length + 1];\n        for (int i = 1; i <= values.Length; i++) previous[i] = INF;\n        previous[0] = 0;\n\n        for (int layer = 0; layer < groups; layer++) {\n            tree = new Line?[4 * xs.Length];\n            long[] current = new long[values.Length + 1];\n            for (int i = 0; i <= values.Length; i++) current[i] = INF;\n            if (previous[0] != INF) {\n                Insert(new Line(0, previous[0]), 1, 0, xs.Length - 1);\n            }\n            for (int end = 1; end <= values.Length; end++) {\n                long x = prefix[end] - target;\n                current[end] = x * x + Query(x, 1, 0, xs.Length - 1);\n                if (previous[end] != INF) {\n                    Insert(new Line(-2 * prefix[end], previous[end] + prefix[end] * prefix[end]), 1, 0, xs.Length - 1);\n                }\n            }\n            previous = current;\n        }\n\n        return (int)previous[values.Length];\n    }\n}",
    "buggy_code": "using System;\nusing System.Collections.Generic;\nusing System.Linq;\n\npublic class Solution {\n    struct Line {\n        public long M;\n        public long C;\n        public Line(long m, long c) { M = m; C = c; }\n    }\n\n    private static long Evaluate(Line line, long x) {\n        return line.M * x + line.C;\n    }\n\n    private Line?[] tree;\n    private long[] xs;\n    private const long INF = 1000000000000000000L;\n\n    private void Insert(Line line, int node, int left, int right) {\n        if (!tree[node].HasValue) {\n            tree[node] = line;\n            return;\n        }\n        int middle = left + (right - left) / 2;\n        Line curr = tree[node].Value;\n        bool betterLeft = Evaluate(line, xs[left]) < Evaluate(curr, xs[left]);\n        bool betterMiddle = Evaluate(line, xs[middle]) < Evaluate(curr, xs[middle]);\n        if (betterMiddle) {\n            tree[node] = line;\n            line = curr;\n        }\n        if (left == right) return;\n        if (betterLeft != betterMiddle) {\n            Insert(line, node * 2, left, middle);\n        } else {\n            Insert(line, node * 2 + 1, middle + 1, right);\n        }\n    }\n\n    private long Query(long x, int node, int left, int right) {\n        if (!tree[node].HasValue) return INF;\n        long answer = Evaluate(tree[node].Value, x);\n        if (left == right) return answer;\n        int middle = left + (right - left) / 2;\n        if (x <= xs[middle]) {\n            return Math.Min(answer, Query(x, node * 2, left, middle));\n        }\n        return Math.Min(answer, Query(x, node * 2 + 1, middle + 1, right));\n    }\n\n    public int EntryPoint(int[] values, int groups, int target) {\n        long[] prefix = new long[values.Length + 1];\n        for (int i = 0; i < values.Length; i++) {\n            prefix[i + 1] = prefix[i] + values[i];\n        }\n\n        var xsSet = new SortedSet<long>();\n        for (int i = 1; i <= values.Length; i++) {\n            xsSet.Add(prefix[i] - target);\n        }\n        xs = xsSet.ToArray();\n\n        long[] previous = new long[values.Length + 1];\n        for (int i = 1; i <= values.Length; i++) previous[i] = INF;\n        previous[0] = 0;\n\n        tree = new Line?[4 * xs.Length];\n\n        for (int layer = 0; layer < groups; layer++) {\n            long[] current = new long[values.Length + 1];\n            for (int i = 0; i <= values.Length; i++) current[i] = INF;\n            if (previous[0] != INF) {\n                Insert(new Line(0, previous[0]), 1, 0, xs.Length - 1);\n            }\n            for (int end = 1; end <= values.Length; end++) {\n                long x = prefix[end] - target;\n                if (previous[end] != INF) {\n                    Insert(new Line(-2 * prefix[end], previous[end] + prefix[end] * prefix[end]), 1, 0, xs.Length - 1);\n                }\n                current[end] = x * x + Query(x, 1, 0, xs.Length - 1);\n            }\n            previous = current;\n        }\n\n        return (int)previous[values.Length];\n    }\n}",
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
