-- 009_seed_java_questions.sql
-- Java translations of the seeded questions; the first two tests are public examples.
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
    "language": "java",
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
    "description": "A machine records one temperature reading each minute. A reading is overheating when it is **greater than or equal to** a given threshold.\n\nImplement `Solution.entryPoint(int[] readings, int threshold)` to return the longest consecutive streak of overheating readings. Return `0` if no reading qualifies.\n\n### Examples\n- Input: `readings = [70, 80, 85, 60], threshold = 80`\n  Output: `2`\n- Input: `readings = [40, 50], threshold = 60`\n  Output: `0`\n\n### Constraints\n- `0 <= readings.length <= 10000`\n- Each reading and `threshold` is an integer between `-100` and `1000`.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public int entryPoint(int[] readings, int threshold) {\n        int longest = 0;\n        int current = 0;\n        for (int reading : readings) {\n            if (reading >= threshold) {\n                current++;\n                longest = Math.max(longest, current);\n            } else {\n                current = 0;\n            }\n        }\n        return longest;\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public int entryPoint(int[] readings, int threshold) {\n        int longest = 0;\n        int current = 0;\n        for (int reading : readings) {\n            if (reading > threshold) {\n                current++;\n                longest = Math.max(longest, current);\n            } else {\n                current = 0;\n            }\n        }\n        return longest;\n    }\n}",
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
    "language": "java",
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
    "description": "A label imported from a text file may contain extra spaces. Clean it by removing leading and trailing spaces and replacing every consecutive group of internal spaces with one space. Preserve all other characters and their capitalization.\n\nImplement `Solution.entryPoint(String label)` to return the cleaned label. A label containing only spaces becomes an empty string.\n\n### Examples\n- Input: `label = \"  Main   Office  \"`\n  Output: `\"Main Office\"`\n- Input: `label = \"Desk 7\"`\n  Output: `\"Desk 7\"`\n\n### Constraints\n- `0 <= label.length() <= 10000`\n- `label` contains only English letters, digits, and ordinary ASCII spaces.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public String entryPoint(String label) {\n        StringBuilder result = new StringBuilder();\n        for (int i = 0; i < label.length(); i++) {\n            char character = label.charAt(i);\n            if (character != ' ') {\n                result.append(character);\n            } else if (result.length() > 0 && result.charAt(result.length() - 1) != ' ') {\n                result.append(' ');\n            }\n        }\n        int len = result.length();\n        while (len > 0 && result.charAt(len - 1) == ' ') {\n            len--;\n        }\n        return result.substring(0, len);\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public String entryPoint(String label) {\n        StringBuilder result = new StringBuilder();\n        for (int i = 0; i < label.length(); i++) {\n            char character = label.charAt(i);\n            if (character != ' ') {\n                result.append(character);\n            } else if (result.length() > 0 && result.charAt(result.length() - 1) != ' ') {\n                result.append(' ');\n            }\n        }\n        int start = 0;\n        while (start < result.length() && result.charAt(start) == ' ') {\n            start++;\n        }\n        return result.substring(start);\n    }\n}",
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
    "language": "java",
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
    "description": "A warehouse receives delivery records represented by parallel arrays `items` and `quantities`, where `quantities[i]` is the quantity delivered for `items[i]`. The same item may appear multiple times.\n\nImplement `Solution.entryPoint(String[] items, int[] quantities)` to return an array of the total quantity delivered for each distinct item, in order of each item's first appearance. Include every item that appears, even if its total is zero. Item names are case-sensitive.\n\n### Examples\n- Input: `items = [\"bolts\", \"bolts\"], quantities = [3, 4]`\n  Output: `[7]`\n- Input: `items = [\"tape\", \"glue\"], quantities = [2, 5]`\n  Output: `[2, 5]`\n\n### Constraints\n- `items.length == quantities.length`\n- `0 <= items.length <= 10000`\n- Item names contain between `1` and `30` English letters.\n- `0 <= quantities[i] <= 100000`.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public int[] entryPoint(String[] items, int[] quantities) {\n        Map<String, Integer> totals = new LinkedHashMap<>();\n        for (int i = 0; i < items.length; i++) {\n            String item = items[i];\n            int qty = quantities[i];\n            if (!totals.containsKey(item)) {\n                totals.put(item, 0);\n            }\n            totals.put(item, totals.get(item) + qty);\n        }\n        int[] result = new int[totals.size()];\n        int idx = 0;\n        for (int total : totals.values()) {\n            result[idx++] = total;\n        }\n        return result;\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public int[] entryPoint(String[] items, int[] quantities) {\n        Map<String, Integer> totals = new LinkedHashMap<>();\n        for (int i = 0; i < items.length; i++) {\n            String item = items[i];\n            int qty = quantities[i];\n            if (!totals.containsKey(item)) {\n                totals.put(item, 0);\n            }\n            totals.put(item, qty);\n        }\n        int[] result = new int[totals.size()];\n        int idx = 0;\n        for (int total : totals.values()) {\n            result[idx++] = total;\n        }\n        return result;\n    }\n}",
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
    "language": "java",
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
    "description": "A small drafting tool processes an array of string actions. An action equal to `\"UNDO\"` removes the most recently added line that is still present. If no lines remain, `\"UNDO\"` does nothing. Every other action adds that string as a new line, including an empty string.\n\nImplement `Solution.entryPoint(String[] actions)` to return the remaining lines in their original insertion order as an array of strings. The reserved action `\"UNDO\"` cannot be added as ordinary text.\n\n### Examples\n- Input: `actions = [\"Title\", \"Draft\", \"UNDO\"]`\n  Output: `[\"Title\"]`\n- Input: `actions = [\"UNDO\", \"Hello\"]`\n  Output: `[\"Hello\"]`\n\n### Constraints\n- `0 <= actions.length <= 10000`\n- Each action is a string containing at most `100` characters.\n- Actions are case-sensitive.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public String[] entryPoint(String[] actions) {\n        List<String> lines = new ArrayList<>();\n        for (String action : actions) {\n            if (\"UNDO\".equals(action)) {\n                if (!lines.isEmpty()) {\n                    lines.remove(lines.size() - 1);\n                }\n            } else {\n                lines.add(action);\n            }\n        }\n        return lines.toArray(new String[0]);\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public String[] entryPoint(String[] actions) {\n        List<String> lines = new ArrayList<>();\n        for (String action : actions) {\n            if (\"UNDO\".equals(action)) {\n                if (!lines.isEmpty()) {\n                    lines.remove(0);\n                }\n            } else {\n                lines.add(action);\n            }\n        }\n        return lines.toArray(new String[0]);\n    }\n}",
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
    "language": "java",
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
    "description": "A service publishes maintenance windows as pairs `[start, end]`. Each window includes its start time and excludes its end time. A customer's session follows the same rule.\n\nImplement `Solution.entryPoint(int[][] windows, int sessionStart, int sessionEnd)` to count how many maintenance windows overlap the session for a positive amount of time. A window that ends exactly when the session starts, or starts exactly when the session ends, does not overlap. Count each listed window separately, including duplicate windows.\n\n### Examples\n- Input: `windows = [[1, 4], [6, 9]], sessionStart = 3, sessionEnd = 7`\n  Output: `2`\n- Input: `windows = [[1, 3], [7, 9]], sessionStart = 3, sessionEnd = 7`\n  Output: `0`\n\n### Constraints\n- `0 <= windows.length <= 10000`\n- Each window contains two integers satisfying `0 <= start < end <= 1000000`.\n- `0 <= sessionStart < sessionEnd <= 1000000`\n- Windows may appear in any order and may overlap one another.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public int entryPoint(int[][] windows, int sessionStart, int sessionEnd) {\n        int count = 0;\n        for (int[] window : windows) {\n            int start = window[0];\n            int end = window[1];\n            int overlapStart = Math.max(start, sessionStart);\n            int overlapEnd = Math.min(end, sessionEnd);\n            if (overlapStart < overlapEnd) {\n                count++;\n            }\n        }\n        return count;\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public int entryPoint(int[][] windows, int sessionStart, int sessionEnd) {\n        int count = 0;\n        for (int[] window : windows) {\n            int start = window[0];\n            int end = window[1];\n            int overlapStart = Math.max(start, sessionStart);\n            int overlapEnd = Math.min(end, sessionEnd);\n            if (overlapStart <= overlapEnd) {\n                count++;\n            }\n        }\n        return count;\n    }\n}",
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
    "language": "java",
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
    "description": "An audit system stores events in chronological order. Each event has a category and a nonnegative review cost.\n\nImplement `Solution.entryPoint(String[] categories, int[] costs, int budget, int categoryLimit)` to return the maximum number of consecutive events that can be selected while satisfying both rules:\n\n- Their total review cost is at most `budget`.\n- No category appears more than `categoryLimit` times.\n\nReturn `0` if no nonempty selection is valid. The input arrays have equal lengths, and their matching positions describe the same event.\n\n### Examples\n- Input: `categories = [\"a\", \"b\", \"a\"], costs = [2, 1, 2], budget = 5, categoryLimit = 2`\n  Output: `3`\n- Input: `categories = [\"a\", \"a\", \"b\"], costs = [1, 1, 1], budget = 3, categoryLimit = 1`\n  Output: `2`\n\n### Constraints\n- `0 <= categories.length == costs.length <= 100000`\n- Categories are nonempty lowercase English strings of length at most 20.\n- `0 <= costs[i] <= 10000`\n- `0 <= budget <= 1000000000`\n- `1 <= categoryLimit <= 100000`.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public int entryPoint(String[] categories, int[] costs, int budget, int categoryLimit) {\n        Map<String, Integer> counts = new HashMap<>();\n        int left = 0;\n        long total = 0;\n        int best = 0;\n        for (int right = 0; right < categories.length; right++) {\n            String category = categories[right];\n            counts.put(category, counts.getOrDefault(category, 0) + 1);\n            total += costs[right];\n            while (total > budget || counts.get(category) > categoryLimit) {\n                String departing = categories[left];\n                counts.put(departing, counts.get(departing) - 1);\n                total -= costs[left];\n                left++;\n            }\n            int length = right - left + 1;\n            best = Math.max(best, length);\n        }\n        return best;\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public int entryPoint(String[] categories, int[] costs, int budget, int categoryLimit) {\n        Map<String, Integer> counts = new HashMap<>();\n        int left = 0;\n        long total = 0;\n        int best = 0;\n        for (int right = 0; right < categories.length; right++) {\n            String category = categories[right];\n            counts.put(category, counts.getOrDefault(category, 0) + 1);\n            total += costs[right];\n            if (total > budget || counts.get(category) > categoryLimit) {\n                String departing = categories[left];\n                counts.put(departing, counts.get(departing) - 1);\n                total -= costs[left];\n                left++;\n            }\n            int length = right - left + 1;\n            best = Math.max(best, length);\n        }\n        return best;\n    }\n}",
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
    "language": "java",
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
    "description": "A search box accepts a small query language. Implement `Solution.entryPoint(String query)` to return its tokens in order according to these rules:\n\n- Ordinary ASCII spaces separate tokens when outside double quotes.\n- Double quotes toggle quoted mode and are omitted from the token. Spaces inside quotes are preserved.\n- A backslash escapes the next character, inside or outside quotes. The escaped character is added literally, and the backslash is omitted.\n- Adjacent quoted and unquoted portions belong to the same token unless separated by an unquoted, unescaped space.\n- Empty quoted portions count as a token when standing alone.\n- Leading, trailing, and repeated separator spaces do not create tokens.\n\n### Examples\n- Input: `query = \"red \\\"blue sky\\\"\"`\n  Output: `[\"red\", \"blue sky\"]`\n- Input: `query = \"a\\\"b c\\\"d\"`\n  Output: `[\"ab cd\"]`\n\n### Constraints\n- `0 <= query.length() <= 100000`\n- The query contains printable ASCII characters.\n- Every backslash has a following character.\n- Unescaped double quotes are balanced.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public String[] entryPoint(String query) {\n        List<String> tokens = new ArrayList<>();\n        StringBuilder current = new StringBuilder();\n        boolean quoted = false;\n        boolean active = false;\n        int i = 0;\n        while (i < query.length()) {\n            char character = query.charAt(i);\n            if (character == '\\\\') {\n                i++;\n                current.append(query.charAt(i));\n                active = true;\n            } else if (character == '\"') {\n                quoted = !quoted;\n                active = true;\n            } else if (character == ' ' && !quoted) {\n                if (active) {\n                    tokens.add(current.toString());\n                    current.setLength(0);\n                    active = false;\n                }\n            } else {\n                current.append(character);\n                active = true;\n            }\n            i++;\n        }\n        if (active) {\n            tokens.add(current.toString());\n        }\n        return tokens.toArray(new String[0]);\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public String[] entryPoint(String query) {\n        List<String> tokens = new ArrayList<>();\n        StringBuilder current = new StringBuilder();\n        boolean quoted = false;\n        boolean active = false;\n        int i = 0;\n        while (i < query.length()) {\n            char character = query.charAt(i);\n            if (character == '\\\\' && quoted) {\n                i++;\n                current.append(query.charAt(i));\n                active = true;\n            } else if (character == '\"') {\n                quoted = !quoted;\n                active = true;\n            } else if (character == ' ' && !quoted) {\n                if (active) {\n                    tokens.add(current.toString());\n                    current.setLength(0);\n                    active = false;\n                }\n            } else {\n                current.append(character);\n                active = true;\n            }\n            i++;\n        }\n        if (active) {\n            tokens.add(current.toString());\n        }\n        return tokens.toArray(new String[0]);\n    }\n}",
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
    "language": "java",
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
    "description": "A data platform must run `n` export jobs, numbered from `0` to `n - 1`. Job `i` takes `durations[i]` time units and cannot start before time `releaseTimes[i]`.\n\nEach dependency `[before, after]` in `dependencies` means that job `after` must wait until job `before` finishes. A job must wait for all its prerequisites. Unlimited workers are available, so unrelated jobs may run simultaneously. Jobs begin as soon as their release times and dependencies permit.\n\nImplement `Solution.entryPoint(int[] durations, int[] releaseTimes, int[][] dependencies)` to return an array containing the earliest finish time of every job, in job-number order. The dependency graph is guaranteed to have no cycles.\n\n### Examples\n- Input: `durations = [2, 3], releaseTimes = [0, 0], dependencies = [[0, 1]]`\n  Output: `[2, 5]`\n- Input: `durations = [2, 1], releaseTimes = [5, 0], dependencies = []`\n  Output: `[7, 1]`\n\n### Constraints\n- `0 <= n <= 10000` where `n = durations.length == releaseTimes.length`\n- `1 <= durations[i] <= 1000000`\n- `0 <= releaseTimes[i] <= 1000000000`\n- There are at most `50000` dependencies.\n- Dependencies use valid, distinct job numbers, and duplicate dependency pairs do not occur.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public int[] entryPoint(int[] durations, int[] releaseTimes, int[][] dependencies) {\n        int n = durations.length;\n        List<List<Integer>> outgoing = new ArrayList<>(n);\n        for (int i = 0; i < n; i++) {\n            outgoing.add(new ArrayList<>());\n        }\n        int[] remaining = new int[n];\n        for (int[] dep : dependencies) {\n            int before = dep[0];\n            int after = dep[1];\n            outgoing.get(before).add(after);\n            remaining[after]++;\n        }\n        int[] starts = Arrays.copyOf(releaseTimes, n);\n        int[] finishes = new int[n];\n        Queue<Integer> ready = new ArrayDeque<>();\n        for (int i = 0; i < n; i++) {\n            if (remaining[i] == 0) {\n                ready.offer(i);\n            }\n        }\n        while (!ready.isEmpty()) {\n            int job = ready.poll();\n            finishes[job] = starts[job] + durations[job];\n            for (int child : outgoing.get(job)) {\n                starts[child] = Math.max(starts[child], finishes[job]);\n                remaining[child]--;\n                if (remaining[child] == 0) {\n                    ready.offer(child);\n                }\n            }\n        }\n        return finishes;\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public int[] entryPoint(int[] durations, int[] releaseTimes, int[][] dependencies) {\n        int n = durations.length;\n        List<List<Integer>> outgoing = new ArrayList<>(n);\n        for (int i = 0; i < n; i++) {\n            outgoing.add(new ArrayList<>());\n        }\n        int[] remaining = new int[n];\n        for (int[] dep : dependencies) {\n            int before = dep[0];\n            int after = dep[1];\n            outgoing.get(before).add(after);\n            remaining[after]++;\n        }\n        int[] starts = Arrays.copyOf(releaseTimes, n);\n        int[] finishes = new int[n];\n        Queue<Integer> ready = new ArrayDeque<>();\n        for (int i = 0; i < n; i++) {\n            if (remaining[i] == 0) {\n                ready.offer(i);\n            }\n        }\n        while (!ready.isEmpty()) {\n            int job = ready.poll();\n            finishes[job] = starts[job] + durations[job];\n            for (int child : outgoing.get(job)) {\n                starts[child] = Math.max(releaseTimes[child], finishes[job]);\n                remaining[child]--;\n                if (remaining[child] == 0) {\n                    ready.offer(child);\n                }\n            }\n        }\n        return finishes;\n    }\n}",
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
    "language": "java",
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
    "description": "A resource scheduler logs reservation intervals as `[start, end, units]`. Each reservation adds `units` of demand throughout `[start, end)` and `0` demand outside that window.\n\nImplement `Solution.entryPoint(int[][] reservations, int threshold)` to return the total duration across all time during which aggregate demand is **greater than or equal to** `threshold`.\n\n### Examples\n- Input: `reservations = [[0, 4, 2], [2, 6, 3]], threshold = 4`\n  Output: `2`\n- Input: `reservations = [[1, 5, 2], [3, 7, 2]], threshold = 3`\n  Output: `4`\n\n### Constraints\n- `0 <= reservations.length <= 100000`\n- `0 <= start < end <= 1000000000`\n- `1 <= units <= 1000000`\n- `1 <= threshold <= 100000000000`.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public int entryPoint(int[][] reservations, int threshold) {\n        Map<Integer, Long> changes = new TreeMap<>();\n        for (int[] r : reservations) {\n            int start = r[0];\n            int end = r[1];\n            long units = r[2];\n            changes.put(start, changes.getOrDefault(start, 0L) + units);\n            changes.put(end, changes.getOrDefault(end, 0L) - units);\n        }\n        long active = 0;\n        Integer previous = null;\n        long duration = 0;\n        for (Map.Entry<Integer, Long> entry : changes.entrySet()) {\n            int time = entry.getKey();\n            if (previous != null && active >= threshold) {\n                duration += time - previous;\n            }\n            active += entry.getValue();\n            previous = time;\n        }\n        return (int) duration;\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public int entryPoint(int[][] reservations, int threshold) {\n        Map<Integer, Long> changes = new TreeMap<>();\n        for (int[] r : reservations) {\n            int start = r[0];\n            int end = r[1];\n            long units = r[2];\n            changes.put(start, changes.getOrDefault(start, 0L) + units);\n            changes.put(end, changes.getOrDefault(end, 0L) - units);\n        }\n        long active = 0;\n        Integer previous = null;\n        long duration = 0;\n        for (Map.Entry<Integer, Long> entry : changes.entrySet()) {\n            int time = entry.getKey();\n            if (previous != null && active > threshold) {\n                duration += time - previous;\n            }\n            active += entry.getValue();\n            previous = time;\n        }\n        return (int) duration;\n    }\n}",
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
    "language": "java",
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
    "description": "A print shop must process jobs in their existing order. Each job has a positive intensity value. The shop partitions the jobs into nonempty, consecutive batches containing at most `maxBatch` jobs each.\n\nThe cost of a batch is:\n`setupCost + (number of jobs in the batch) * (maximum intensity in the batch)`\n\nEvery job must belong to exactly one batch. Jobs cannot be reordered.\n\nImplement `Solution.entryPoint(int[] intensities, int maxBatch, int setupCost)` to return the minimum total cost. Return `0` when there are no jobs.\n\n### Examples\n- Input: `intensities = [2, 2], maxBatch = 2, setupCost = 3`\n  Output: `7`\n  Explanation: One batch costs `3 + 2 * 2 = 7`.\n- Input: `intensities = [1, 10], maxBatch = 2, setupCost = 2`\n  Output: `15`\n  Explanation: Separate batches cost `(2 + 1) + (2 + 10) = 15`.\n\n### Constraints\n- `0 <= intensities.length <= 1000`\n- `1 <= intensities[i] <= 10000`\n- `1 <= maxBatch <= 100`\n- `0 <= setupCost <= 10000`.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public int entryPoint(int[] intensities, int maxBatch, int setupCost) {\n        int n = intensities.length;\n        int[] dp = new int[n + 1];\n        for (int end = 1; end <= n; end++) {\n            int peak = intensities[end - 1];\n            int best = dp[end - 1] + setupCost + peak;\n            int limit = Math.min(maxBatch, end);\n            for (int length = 1; length <= limit; length++) {\n                peak = Math.max(peak, intensities[end - length]);\n                int candidate = dp[end - length] + setupCost + length * peak;\n                best = Math.min(best, candidate);\n            }\n            dp[end] = best;\n        }\n        return dp[n];\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public int entryPoint(int[] intensities, int maxBatch, int setupCost) {\n        int n = intensities.length;\n        int[] dp = new int[n + 1];\n        for (int end = 1; end <= n; end++) {\n            int peak = intensities[end - 1];\n            int best = dp[end - 1] + setupCost + peak;\n            int limit = Math.min(maxBatch, end);\n            for (int length = 1; length < limit; length++) {\n                peak = Math.max(peak, intensities[end - length]);\n                int candidate = dp[end - length] + setupCost + length * peak;\n                best = Math.min(best, candidate);\n            }\n            dp[end] = best;\n        }\n        return dp[n];\n    }\n}",
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
    "language": "java",
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
    "description": "A network contains `n` devices numbered from `0` to `n - 1`. Its undirected links are available only during specified time windows.\n\nEach record `[u, v, start, end]` in `links` makes a link available throughout the half-open interval `[start, end)`. Multiple records may describe the same pair of devices; the link is available whenever any corresponding record is active.\n\nEach query `[time, u, v]` in `queries` asks whether the devices are connected by a path of links that are all available at that time. A device is always connected to itself.\n\nImplement `Solution.entryPoint(int n, int[][] links, int[][] queries)` to return a boolean array representing answers in the original query order. Neither links nor queries are necessarily sorted.\n\n### Examples\n- Input: `n = 3, links = [[0, 1, 0, 5], [1, 2, 2, 4]], queries = [[1, 0, 2], [3, 0, 2]]`\n  Output: `[false, true]`\n- Input: `n = 2, links = [[0, 1, 1, 3]], queries = [[1, 0, 1], [3, 0, 1]]`\n  Output: `[true, false]`\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= links.length, queries.length <= 30000`\n- All device numbers are valid.\n- Link endpoints are distinct.\n- `0 <= start < end <= 1000000000`\n- Query times are integers between `0` and `1000000000`.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    private static int bisectLeft(int[] a, int x) {\n        int lo = 0, hi = a.length;\n        while (lo < hi) {\n            int mid = (lo + hi) >>> 1;\n            if (a[mid] < x) lo = mid + 1;\n            else hi = mid;\n        }\n        return lo;\n    }\n\n    private static class Link {\n        int u, v;\n        Link(int u, int v) { this.u = u; this.v = v; }\n    }\n\n    private static class QueryItem {\n        int idx, u, v;\n        QueryItem(int idx, int u, int v) { this.idx = idx; this.u = u; this.v = v; }\n    }\n\n    private static class HistoryItem {\n        int b, a, oldSize;\n        HistoryItem(int b, int a, int oldSize) { this.b = b; this.a = a; this.oldSize = oldSize; }\n    }\n\n    private int[] parent;\n    private int[] size;\n    private List<HistoryItem> history;\n\n    private int find(int x) {\n        while (parent[x] != x) {\n            x = parent[x];\n        }\n        return x;\n    }\n\n    public boolean[] entryPoint(int n, int[][] links, int[][] queries) {\n        if (queries == null || queries.length == 0) {\n            return new boolean[0];\n        }\n        TreeSet<Integer> uniqueTimes = new TreeSet<>();\n        for (int[] q : queries) {\n            uniqueTimes.add(q[0]);\n        }\n        int[] times = new int[uniqueTimes.size()];\n        int tIdx = 0;\n        for (int t : uniqueTimes) {\n            times[tIdx++] = t;\n        }\n\n        int base = 1;\n        while (base < times.length) {\n            base <<= 1;\n        }\n\n        List<List<Link>> tree = new ArrayList<>(2 * base);\n        for (int i = 0; i < 2 * base; i++) {\n            tree.add(new ArrayList<>());\n        }\n\n        for (int[] link : links) {\n            int u = link[0];\n            int v = link[1];\n            int start = link[2];\n            int end = link[3];\n            int left = bisectLeft(times, start) + base;\n            int right = bisectLeft(times, end) + base;\n            while (left < right) {\n                if ((left & 1) == 1) {\n                    tree.get(left).add(new Link(u, v));\n                    left++;\n                }\n                if ((right & 1) == 1) {\n                    right--;\n                    tree.get(right).add(new Link(u, v));\n                }\n                left >>= 1;\n                right >>= 1;\n            }\n        }\n\n        List<List<QueryItem>> buckets = new ArrayList<>(base);\n        for (int i = 0; i < base; i++) {\n            buckets.add(new ArrayList<>());\n        }\n        for (int i = 0; i < queries.length; i++) {\n            int time = queries[i][0];\n            int u = queries[i][1];\n            int v = queries[i][2];\n            int bIdx = bisectLeft(times, time);\n            buckets.get(bIdx).add(new QueryItem(i, u, v));\n        }\n\n        parent = new int[n];\n        size = new int[n];\n        for (int i = 0; i < n; i++) {\n            parent[i] = i;\n            size[i] = 1;\n        }\n        history = new ArrayList<>();\n        boolean[] answer = new boolean[queries.length];\n\n        visit(1, base, tree, buckets, answer);\n        return answer;\n    }\n\n    private void visit(int node, int base, List<List<Link>> tree, List<List<QueryItem>> buckets, boolean[] answer) {\n        int snapshot = history.size();\n        for (Link link : tree.get(node)) {\n            int a = find(link.u);\n            int b = find(link.v);\n            if (a != b) {\n                if (size[a] < size[b]) {\n                    int tmp = a; a = b; b = tmp;\n                }\n                history.add(new HistoryItem(b, a, size[a]));\n                parent[b] = a;\n                size[a] += size[b];\n            }\n        }\n        if (node >= base) {\n            int bucketIdx = node - base;\n            if (bucketIdx < buckets.size()) {\n                for (QueryItem q : buckets.get(bucketIdx)) {\n                    answer[q.idx] = (find(q.u) == find(q.v));\n                }\n            }\n        } else {\n            visit(2 * node, base, tree, buckets, answer);\n            visit(2 * node + 1, base, tree, buckets, answer);\n        }\n        while (history.size() > snapshot) {\n            HistoryItem h = history.remove(history.size() - 1);\n            parent[h.b] = h.b;\n            size[h.a] = h.oldSize;\n        }\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    private static int bisectLeft(int[] a, int x) {\n        int lo = 0, hi = a.length;\n        while (lo < hi) {\n            int mid = (lo + hi) >>> 1;\n            if (a[mid] < x) lo = mid + 1;\n            else hi = mid;\n        }\n        return lo;\n    }\n\n    private static int bisectRight(int[] a, int x) {\n        int lo = 0, hi = a.length;\n        while (lo < hi) {\n            int mid = (lo + hi) >>> 1;\n            if (a[mid] <= x) lo = mid + 1;\n            else hi = mid;\n        }\n        return lo;\n    }\n\n    private static class Link {\n        int u, v;\n        Link(int u, int v) { this.u = u; this.v = v; }\n    }\n\n    private static class QueryItem {\n        int idx, u, v;\n        QueryItem(int idx, int u, int v) { this.idx = idx; this.u = u; this.v = v; }\n    }\n\n    private static class HistoryItem {\n        int b, a, oldSize;\n        HistoryItem(int b, int a, int oldSize) { this.b = b; this.a = a; this.oldSize = oldSize; }\n    }\n\n    private int[] parent;\n    private int[] size;\n    private List<HistoryItem> history;\n\n    private int find(int x) {\n        while (parent[x] != x) {\n            parent[x] = parent[parent[x]];\n            x = parent[x];\n        }\n        return x;\n    }\n\n    public boolean[] entryPoint(int n, int[][] links, int[][] queries) {\n        if (queries == null || queries.length == 0) {\n            return new boolean[0];\n        }\n        TreeSet<Integer> uniqueTimes = new TreeSet<>();\n        for (int[] q : queries) {\n            uniqueTimes.add(q[0]);\n        }\n        int[] times = new int[uniqueTimes.size()];\n        int tIdx = 0;\n        for (int t : uniqueTimes) {\n            times[tIdx++] = t;\n        }\n\n        int base = 1;\n        while (base < times.length) {\n            base <<= 1;\n        }\n\n        List<List<Link>> tree = new ArrayList<>(2 * base);\n        for (int i = 0; i < 2 * base; i++) {\n            tree.add(new ArrayList<>());\n        }\n\n        for (int[] link : links) {\n            int u = link[0];\n            int v = link[1];\n            int start = link[2];\n            int end = link[3];\n            int left = bisectLeft(times, start) + base;\n            int right = bisectRight(times, end) + base;\n            while (left < right) {\n                if ((left & 1) == 1) {\n                    tree.get(left).add(new Link(u, v));\n                    left++;\n                }\n                if ((right & 1) == 1) {\n                    right--;\n                    tree.get(right).add(new Link(u, v));\n                }\n                left >>= 1;\n                right >>= 1;\n            }\n        }\n\n        List<List<QueryItem>> buckets = new ArrayList<>(base);\n        for (int i = 0; i < base; i++) {\n            buckets.add(new ArrayList<>());\n        }\n        for (int i = 0; i < queries.length; i++) {\n            int time = queries[i][0];\n            int u = queries[i][1];\n            int v = queries[i][2];\n            int bIdx = bisectLeft(times, time);\n            buckets.get(bIdx).add(new QueryItem(i, u, v));\n        }\n\n        parent = new int[n];\n        size = new int[n];\n        for (int i = 0; i < n; i++) {\n            parent[i] = i;\n            size[i] = 1;\n        }\n        history = new ArrayList<>();\n        boolean[] answer = new boolean[queries.length];\n\n        visit(1, base, tree, buckets, answer);\n        return answer;\n    }\n\n    private void visit(int node, int base, List<List<Link>> tree, List<List<QueryItem>> buckets, boolean[] answer) {\n        int snapshot = history.size();\n        for (Link link : tree.get(node)) {\n            int a = find(link.u);\n            int b = find(link.v);\n            if (a != b) {\n                if (size[a] < size[b]) {\n                    int tmp = a; a = b; b = tmp;\n                }\n                history.add(new HistoryItem(b, a, size[a]));\n                parent[b] = a;\n                size[a] += size[b];\n            }\n        }\n        if (node >= base) {\n            int bucketIdx = node - base;\n            if (bucketIdx < buckets.size()) {\n                for (QueryItem q : buckets.get(bucketIdx)) {\n                    answer[q.idx] = (find(q.u) == find(q.v));\n                }\n            }\n        } else {\n            visit(2 * node, base, tree, buckets, answer);\n            visit(2 * node + 1, base, tree, buckets, answer);\n        }\n        while (history.size() > snapshot) {\n            HistoryItem h = history.remove(history.size() - 1);\n            parent[h.b] = h.b;\n            size[h.a] = h.oldSize;\n        }\n    }\n}",
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
    "language": "java",
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
    "description": "A shipping network has `n` depots numbered `0` to `n - 1`. A shipment starts at depot `0` at time `startTime` and must reach depot `n - 1`.\n\nEach route in `routes` is `[u, v, offset, period, duration]`. Departs from depot `u` toward `v`. Regular departures happen at times `offset + k * period` for all non-negative integers `k`. Once departing, arrival at `v` occurs after `duration`. Multiple routes may exist between the same depots.\n\nThe shipper possesses one express dispatch voucher. It can be used once on any single leg to depart immediately at the arrival time at depot `u` on that route, without waiting for the scheduled departure, still taking `duration`.\n\nImplement `Solution.entryPoint(int n, int[][] routes, int startTime)` to return the earliest absolute arrival time at depot `n - 1`, or `-1` if it is unreachable. The voucher does not need to be used.\n\n### Examples\n- Input: `n = 2, routes = [[0, 1, 10, 5, 3]], startTime = 0`\n  Output: `3`\n  Explanation: An express dispatch leaves immediately.\n- Input: `n = 3, routes = [[0, 1, 0, 10, 2], [1, 2, 5, 10, 2]], startTime = 0`\n  Output: `4`\n  Explanation: Take the first regular departure, then use the voucher.\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= routes.length <= 50000`\n- Routes use valid, distinct endpoints. Parallel routes and directed cycles are allowed.\n- `0 <= offset, startTime <= 1000000000`\n- `1 <= period, duration <= 1000000`.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    private static class Route {\n        int v, offset, period, duration;\n        Route(int v, int offset, int period, int duration) {\n            this.v = v;\n            this.offset = offset;\n            this.period = period;\n            this.duration = duration;\n        }\n    }\n\n    private static class State implements Comparable<State> {\n        long time;\n        int node, used;\n        State(long time, int node, int used) {\n            this.time = time;\n            this.node = node;\n            this.used = used;\n        }\n        public int compareTo(State o) {\n            return Long.compare(this.time, o.time);\n        }\n    }\n\n    public int entryPoint(int n, int[][] routes, int startTime) {\n        List<List<Route>> graph = new ArrayList<>(n);\n        for (int i = 0; i < n; i++) {\n            graph.add(new ArrayList<>());\n        }\n        for (int[] r : routes) {\n            int u = r[0], v = r[1], offset = r[2], period = r[3], duration = r[4];\n            graph.get(u).add(new Route(v, offset, period, duration));\n        }\n\n        long[][] best = new long[n][2];\n        for (int i = 0; i < n; i++) {\n            best[i][0] = Long.MAX_VALUE;\n            best[i][1] = Long.MAX_VALUE;\n        }\n        best[0][0] = startTime;\n        PriorityQueue<State> queue = new PriorityQueue<>();\n        queue.offer(new State(startTime, 0, 0));\n\n        while (!queue.isEmpty()) {\n            State cur = queue.poll();\n            long time = cur.time;\n            int node = cur.node;\n            int used = cur.used;\n\n            if (time != best[node][used]) continue;\n            if (node == n - 1) return (int) time;\n\n            for (Route r : graph.get(node)) {\n                long departure;\n                if (time <= r.offset) {\n                    departure = r.offset;\n                } else {\n                    departure = r.offset + ((time - r.offset + r.period - 1) / r.period) * r.period;\n                }\n                long arrival = departure + r.duration;\n                if (arrival < best[r.v][used]) {\n                    best[r.v][used] = arrival;\n                    queue.offer(new State(arrival, r.v, used));\n                }\n                if (used == 0) {\n                    long expressArrival = time + r.duration;\n                    if (expressArrival < best[r.v][1]) {\n                        best[r.v][1] = expressArrival;\n                        queue.offer(new State(expressArrival, r.v, 1));\n                    }\n                }\n            }\n        }\n        return -1;\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    private static class Route {\n        int v, offset, period, duration;\n        Route(int v, int offset, int period, int duration) {\n            this.v = v;\n            this.offset = offset;\n            this.period = period;\n            this.duration = duration;\n        }\n    }\n\n    private static class State implements Comparable<State> {\n        long time;\n        int node, used;\n        State(long time, int node, int used) {\n            this.time = time;\n            this.node = node;\n            this.used = used;\n        }\n        public int compareTo(State o) {\n            return Long.compare(this.time, o.time);\n        }\n    }\n\n    public int entryPoint(int n, int[][] routes, int startTime) {\n        List<List<Route>> graph = new ArrayList<>(n);\n        for (int i = 0; i < n; i++) {\n            graph.add(new ArrayList<>());\n        }\n        for (int[] r : routes) {\n            int u = r[0], v = r[1], offset = r[2], period = r[3], duration = r[4];\n            graph.get(u).add(new Route(v, offset, period, duration));\n        }\n\n        long[][] best = new long[n][2];\n        for (int i = 0; i < n; i++) {\n            best[i][0] = Long.MAX_VALUE;\n            best[i][1] = Long.MAX_VALUE;\n        }\n        best[0][0] = startTime;\n        PriorityQueue<State> queue = new PriorityQueue<>();\n        queue.offer(new State(startTime, 0, 0));\n\n        while (!queue.isEmpty()) {\n            State cur = queue.poll();\n            long time = cur.time;\n            int node = cur.node;\n            int used = cur.used;\n\n            if (time != best[node][used]) continue;\n            if (node == n - 1) return (int) time;\n\n            for (Route r : graph.get(node)) {\n                long departure;\n                if (time <= r.offset) {\n                    departure = r.offset;\n                } else {\n                    departure = r.offset + ((time - r.offset + r.period) / r.period) * r.period;\n                }\n                long arrival = departure + r.duration;\n                if (arrival < best[r.v][0]) {\n                    best[r.v][0] = arrival;\n                    queue.offer(new State(arrival, r.v, 0));\n                }\n                if (used == 0) {\n                    long expressArrival = time + r.duration;\n                    if (expressArrival < best[r.v][1]) {\n                        best[r.v][1] = expressArrival;\n                        queue.offer(new State(expressArrival, r.v, 1));\n                    }\n                }\n            }\n        }\n        return -1;\n    }\n}",
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
    "language": "java",
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
    "description": "An encoding service must cover a text using a sequence of catalog entries. The catalog entries are represented by parallel arrays `patterns` and `costs`, where `costs[i]` is the cost of using `patterns[i]`.\n\nA pattern contains lowercase English letters and may contain `?`, which matches exactly one lowercase letter. Applying an entry consumes a consecutive portion of the text whose length equals the pattern's length. Entries must cover the entire text in order, without gaps or overlaps. Every catalog entry may be reused any number of times.\n\nImplement `Solution.entryPoint(String text, String[] patterns, int[] costs)` to return an array `[minimumCost, optimalEncodingCount]`. Count optimal encodings modulo `1000000007`.\n\nAn encoding is identified by its ordered sequence of catalog indices. Duplicate catalog entries are distinct choices. Different matching characters for a wildcard do not create additional choices because the text is fixed.\n\nReturn `[-1, 0]` if the text cannot be covered. The empty text has cost `0` and exactly one encoding: the empty sequence.\n\n### Examples\n- Input: `text = \"ab\", patterns = [\"a\", \"b\", \"ab\"], costs = [2, 3, 4]`\n  Output: `[4, 1]`\n- Input: `text = \"ab\", patterns = [\"a\", \"b\", \"??\"], costs = [1, 1, 2]`\n  Output: `[2, 2]`\n  Explanation: Using the first two entries or the third entry gives the same minimum cost.\n\n### Constraints\n- `0 <= text.length() <= 2000`\n- `text` contains only lowercase English letters.\n- `0 <= patterns.length == costs.length <= 200`\n- Each pattern has length between `1` and `30`.\n- `0 <= costs[i] <= 1000000`.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    public int[] entryPoint(String text, String[] patterns, int[] costs) {\n        List<Map<Character, Integer>> children = new ArrayList<>();\n        List<List<Integer>> terminals = new ArrayList<>();\n        children.add(new HashMap<>());\n        terminals.add(new ArrayList<>());\n\n        for (int i = 0; i < patterns.length; i++) {\n            String pattern = patterns[i];\n            int cost = costs[i];\n            int node = 0;\n            for (int j = 0; j < pattern.length(); j++) {\n                char ch = pattern.charAt(j);\n                Map<Character, Integer> childMap = children.get(node);\n                if (!childMap.containsKey(ch)) {\n                    int nextNode = children.size();\n                    childMap.put(ch, nextNode);\n                    children.add(new HashMap<>());\n                    terminals.add(new ArrayList<>());\n                }\n                node = childMap.get(ch);\n            }\n            terminals.get(node).add(cost);\n        }\n\n        int n = text.length();\n        long infinity = Long.MAX_VALUE / 2;\n        long[] best = new long[n + 1];\n        long[] ways = new long[n + 1];\n        Arrays.fill(best, infinity);\n        best[0] = 0;\n        ways[0] = 1;\n        long modulus = 1000000007L;\n\n        for (int start = 0; start < n; start++) {\n            if (best[start] == infinity) continue;\n            List<Integer> active = new ArrayList<>();\n            active.add(0);\n            for (int end = start; end < n; end++) {\n                List<Integer> following = new ArrayList<>();\n                char curChar = text.charAt(end);\n                for (int node : active) {\n                    Map<Character, Integer> childMap = children.get(node);\n                    Integer nxt = childMap.get(curChar);\n                    if (nxt != null) following.add(nxt);\n                    Integer nxtWild = childMap.get('?');\n                    if (nxtWild != null) following.add(nxtWild);\n                }\n                active = following;\n                if (active.isEmpty()) break;\n                for (int node : active) {\n                    for (int cost : terminals.get(node)) {\n                        long candidate = best[start] + cost;\n                        if (candidate < best[end + 1]) {\n                            best[end + 1] = candidate;\n                            ways[end + 1] = ways[start];\n                        } else if (candidate == best[end + 1]) {\n                            ways[end + 1] = (ways[end + 1] + ways[start]) % modulus;\n                        }\n                    }\n                }\n            }\n        }\n        if (best[n] == infinity) {\n            return new int[]{-1, 0};\n        }\n        return new int[]{(int) best[n], (int) ways[n]};\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    public int[] entryPoint(String text, String[] patterns, int[] costs) {\n        List<Map<Character, Integer>> children = new ArrayList<>();\n        List<List<Integer>> terminals = new ArrayList<>();\n        children.add(new HashMap<>());\n        terminals.add(new ArrayList<>());\n\n        for (int i = 0; i < patterns.length; i++) {\n            String pattern = patterns[i];\n            int cost = costs[i];\n            int node = 0;\n            for (int j = 0; j < pattern.length(); j++) {\n                char ch = pattern.charAt(j);\n                Map<Character, Integer> childMap = children.get(node);\n                if (!childMap.containsKey(ch)) {\n                    int nextNode = children.size();\n                    childMap.put(ch, nextNode);\n                    children.add(new HashMap<>());\n                    terminals.add(new ArrayList<>());\n                }\n                node = childMap.get(ch);\n            }\n            terminals.get(node).add(cost);\n        }\n\n        int n = text.length();\n        long infinity = Long.MAX_VALUE / 2;\n        long[] best = new long[n + 1];\n        long[] ways = new long[n + 1];\n        Arrays.fill(best, infinity);\n        best[0] = 0;\n        ways[0] = 1;\n        long modulus = 1000000007L;\n\n        for (int start = 0; start < n; start++) {\n            if (best[start] == infinity) continue;\n            List<Integer> active = new ArrayList<>();\n            active.add(0);\n            for (int end = start; end < n; end++) {\n                List<Integer> following = new ArrayList<>();\n                char curChar = text.charAt(end);\n                for (int node : active) {\n                    Map<Character, Integer> childMap = children.get(node);\n                    Integer nxt = childMap.get(curChar);\n                    if (nxt != null) following.add(nxt);\n                    Integer nxtWild = childMap.get('?');\n                    if (nxtWild != null) following.add(nxtWild);\n                }\n                active = following;\n                if (active.isEmpty()) break;\n                for (int node : active) {\n                    for (int cost : terminals.get(node)) {\n                        long candidate = best[start] + cost;\n                        if (candidate < best[end + 1]) {\n                            best[end + 1] = candidate;\n                            ways[end + 1] = (ways[end + 1] + ways[start]) % modulus;\n                        } else if (candidate == best[end + 1]) {\n                            ways[end + 1] = ways[start];\n                        }\n                    }\n                }\n            }\n        }\n        if (best[n] == infinity) {\n            return new int[]{-1, 0};\n        }\n        return new int[]{(int) best[n], (int) ways[n]};\n    }\n}",
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
    "language": "java",
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
    "description": "A laboratory owns `capacity` interchangeable pieces of equipment. Each requested job is `[start, end, profit]`, reserving one piece of equipment throughout the half-open interval `[start, end)` to earn `profit`.\n\nNo piece of equipment can be used by overlapping jobs. The same job request may appear multiple times; duplicate requests represent separate identical opportunities.\n\nImplement `Solution.entryPoint(int[][] jobs, int capacity)` to return the maximum total profit that can be obtained without exceeding equipment capacity. Return `0` if there are no jobs or capacity is `0`.\n\n### Examples\n- Input: `jobs = [[0, 2, 5], [1, 3, 7]], capacity = 1`\n  Output: `7`\n- Input: `jobs = [[0, 2, 5], [1, 3, 7]], capacity = 2`\n  Output: `12`\n\n### Constraints\n- `0 <= jobs.length <= 100000`\n- `0 <= capacity <= 100000`\n- `0 <= start < end <= 1000000000`\n- `0 <= profit <= 1000000`.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    private static class Edge {\n        int v, limit, cost, reverse;\n        Edge(int v, int limit, int cost, int reverse) {\n            this.v = v;\n            this.limit = limit;\n            this.cost = cost;\n            this.reverse = reverse;\n        }\n    }\n\n    private static class EdgeRef {\n        int u, edgeId;\n        EdgeRef(int u, int edgeId) {\n            this.u = u;\n            this.edgeId = edgeId;\n        }\n    }\n\n    private void add(List<List<Edge>> graph, int u, int v, int limit, int cost) {\n        graph.get(u).add(new Edge(v, limit, cost, graph.get(v).size()));\n        graph.get(v).add(new Edge(u, 0, -cost, graph.get(u).size() - 1));\n    }\n\n    public int entryPoint(int[][] jobs, int capacity) {\n        if (jobs == null || jobs.length == 0 || capacity <= 0) {\n            return 0;\n        }\n        TreeSet<Integer> uniqueTimes = new TreeSet<>();\n        for (int[] job : jobs) {\n            uniqueTimes.add(job[0]);\n            uniqueTimes.add(job[1]);\n        }\n        Map<Integer, Integer> index = new HashMap<>();\n        int timeIdx = 0;\n        for (int t : uniqueTimes) {\n            index.put(t, timeIdx++);\n        }\n        int numTimes = uniqueTimes.size();\n        List<List<Edge>> graph = new ArrayList<>(numTimes);\n        for (int i = 0; i < numTimes; i++) {\n            graph.add(new ArrayList<>());\n        }\n        for (int i = 0; i < numTimes - 1; i++) {\n            add(graph, i, i + 1, capacity, 0);\n        }\n        for (int[] job : jobs) {\n            add(graph, index.get(job[0]), index.get(job[1]), 1, -job[2]);\n        }\n\n        int total = 0;\n        int remaining = capacity;\n        while (remaining > 0) {\n            long[] distance = new long[numTimes];\n            Arrays.fill(distance, Long.MAX_VALUE);\n            EdgeRef[] previous = new EdgeRef[numTimes];\n            distance[0] = 0;\n            Queue<Integer> queue = new ArrayDeque<>();\n            boolean[] queued = new boolean[numTimes];\n            queue.offer(0);\n            queued[0] = true;\n\n            while (!queue.isEmpty()) {\n                int u = queue.poll();\n                queued[u] = false;\n                List<Edge> edges = graph.get(u);\n                for (int edgeId = 0; edgeId < edges.size(); edgeId++) {\n                    Edge e = edges.get(edgeId);\n                    if (e.limit > 0 && distance[u] != Long.MAX_VALUE && distance[u] + e.cost < distance[e.v]) {\n                        distance[e.v] = distance[u] + e.cost;\n                        previous[e.v] = new EdgeRef(u, edgeId);\n                        if (!queued[e.v]) {\n                            queue.offer(e.v);\n                            queued[e.v] = true;\n                        }\n                    }\n                }\n            }\n\n            int pushed = remaining;\n            int node = numTimes - 1;\n            while (node != 0) {\n                EdgeRef p = previous[node];\n                pushed = Math.min(pushed, graph.get(p.u).get(p.edgeId).limit);\n                node = p.u;\n            }\n\n            node = numTimes - 1;\n            while (node != 0) {\n                EdgeRef p = previous[node];\n                Edge edge = graph.get(p.u).get(p.edgeId);\n                edge.limit -= pushed;\n                graph.get(node).get(edge.reverse).limit += pushed;\n                node = p.u;\n            }\n\n            remaining -= pushed;\n            total -= pushed * distance[numTimes - 1];\n        }\n        return total;\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    private static class Edge {\n        int v, limit, cost, reverse;\n        Edge(int v, int limit, int cost, int reverse) {\n            this.v = v;\n            this.limit = limit;\n            this.cost = cost;\n            this.reverse = reverse;\n        }\n    }\n\n    private static class EdgeRef {\n        int u, edgeId;\n        EdgeRef(int u, int edgeId) {\n            this.u = u;\n            this.edgeId = edgeId;\n        }\n    }\n\n    private void add(List<List<Edge>> graph, int u, int v, int limit, int cost) {\n        graph.get(u).add(new Edge(v, limit, cost, graph.get(v).size()));\n        graph.get(v).add(new Edge(u, 0, -cost, graph.get(u).size() - 1));\n    }\n\n    public int entryPoint(int[][] jobs, int capacity) {\n        if (jobs == null || jobs.length == 0 || capacity <= 0) {\n            return 0;\n        }\n        TreeSet<Integer> uniqueTimes = new TreeSet<>();\n        for (int[] job : jobs) {\n            uniqueTimes.add(job[0]);\n            uniqueTimes.add(job[1]);\n        }\n        Map<Integer, Integer> index = new HashMap<>();\n        int timeIdx = 0;\n        for (int t : uniqueTimes) {\n            index.put(t, timeIdx++);\n        }\n        int numTimes = uniqueTimes.size();\n        List<List<Edge>> graph = new ArrayList<>(numTimes);\n        for (int i = 0; i < numTimes; i++) {\n            graph.add(new ArrayList<>());\n        }\n        for (int i = 0; i < numTimes - 1; i++) {\n            add(graph, i, i + 1, capacity, 0);\n        }\n        Set<String> seen = new HashSet<>();\n        List<int[]> uniqueJobs = new ArrayList<>();\n        for (int[] job : jobs) {\n            String key = job[0] + \",\" + job[1] + \",\" + job[2];\n            if (seen.add(key)) {\n                uniqueJobs.add(job);\n            }\n        }\n        for (int[] job : uniqueJobs) {\n            add(graph, index.get(job[0]), index.get(job[1]), 1, -job[2]);\n        }\n\n        int total = 0;\n        int remaining = capacity;\n        while (remaining > 0) {\n            long[] distance = new long[numTimes];\n            Arrays.fill(distance, Long.MAX_VALUE);\n            EdgeRef[] previous = new EdgeRef[numTimes];\n            distance[0] = 0;\n            Queue<Integer> queue = new ArrayDeque<>();\n            boolean[] queued = new boolean[numTimes];\n            queue.offer(0);\n            queued[0] = true;\n\n            while (!queue.isEmpty()) {\n                int u = queue.poll();\n                queued[u] = false;\n                List<Edge> edges = graph.get(u);\n                for (int edgeId = 0; edgeId < edges.size(); edgeId++) {\n                    Edge e = edges.get(edgeId);\n                    if (e.limit > 0 && distance[u] != Long.MAX_VALUE && distance[u] + e.cost < distance[e.v]) {\n                        distance[e.v] = distance[u] + e.cost;\n                        previous[e.v] = new EdgeRef(u, edgeId);\n                        if (!queued[e.v]) {\n                            queue.offer(e.v);\n                            queued[e.v] = true;\n                        }\n                    }\n                }\n            }\n\n            int pushed = remaining;\n            int node = numTimes - 1;\n            while (node != 0) {\n                EdgeRef p = previous[node];\n                pushed = Math.min(pushed, graph.get(p.u).get(p.edgeId).limit);\n                node = p.u;\n            }\n\n            node = numTimes - 1;\n            while (node != 0) {\n                EdgeRef p = previous[node];\n                Edge edge = graph.get(p.u).get(p.edgeId);\n                edge.limit -= pushed;\n                node = p.u;\n            }\n\n            remaining -= pushed;\n            total -= pushed * distance[numTimes - 1];\n        }\n        return total;\n    }\n}",
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
    "language": "java",
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
    "description": "A financial reconciliation system receives an ordered list of signed adjustments. It must partition the entire array into exactly `groups` nonempty consecutive batches.\n\nThe score of a batch is `(batchSum - target)^2`, where `batchSum` is the sum of adjustments in that batch. The total score is the sum of the batch scores.\n\nImplement `Solution.entryPoint(int[] values, int groups, int target)` to return the minimum possible total score.\n\n### Examples\n- Input: `values = [1, 2], groups = 1, target = 3`\n  Output: `0`\n  Explanation: A single batch `[1, 2]` has sum `3`, and `(3 - 3)^2 = 0`.\n- Input: `values = [1, 2], groups = 2, target = 2`\n  Output: `1`\n  Explanation: Batches `[1]` and `[2]` give `(1 - 2)^2 + (2 - 2)^2 = 1 + 0 = 1`.\n\n### Constraints\n- `1 <= groups <= values.length <= 1000`\n- `-100000 <= values[i], target <= 100000`.",
    "fixed_code": "import java.util.*;\n\nclass Solution {\n    private static class Line {\n        long m, b;\n        Line(long m, long b) {\n            this.m = m;\n            this.b = b;\n        }\n    }\n\n    private static final long INF = Long.MAX_VALUE / 4;\n\n    private long evaluate(Line line, long x) {\n        return line.m * x + line.b;\n    }\n\n    private void insert(Line[] tree, Line line, int node, int left, int right, long[] xs) {\n        if (tree[node] == null) {\n            tree[node] = line;\n            return;\n        }\n        int middle = (left + right) / 2;\n        boolean betterLeft = evaluate(line, xs[left]) < evaluate(tree[node], xs[left]);\n        boolean betterMiddle = evaluate(line, xs[middle]) < evaluate(tree[node], xs[middle]);\n        if (betterMiddle) {\n            Line temp = tree[node];\n            tree[node] = line;\n            line = temp;\n        }\n        if (left == right) {\n            return;\n        }\n        if (betterLeft != betterMiddle) {\n            insert(tree, line, node * 2, left, middle, xs);\n        } else {\n            insert(tree, line, node * 2 + 1, middle + 1, right, xs);\n        }\n    }\n\n    private long query(Line[] tree, long x, int node, int left, int right, long[] xs) {\n        long answer = (tree[node] == null) ? INF : evaluate(tree[node], x);\n        if (left == right) {\n            return answer;\n        }\n        int middle = (left + right) / 2;\n        if (x <= xs[middle]) {\n            return Math.min(answer, query(tree, x, node * 2, left, middle, xs));\n        }\n        return Math.min(answer, query(tree, x, node * 2 + 1, middle + 1, right, xs));\n    }\n\n    public int entryPoint(int[] values, int groups, int target) {\n        int n = values.length;\n        long[] prefix = new long[n + 1];\n        for (int i = 0; i < n; i++) {\n            prefix[i + 1] = prefix[i] + values[i];\n        }\n\n        TreeSet<Long> uniqueXs = new TreeSet<>();\n        for (int i = 1; i <= n; i++) {\n            uniqueXs.add(prefix[i] - target);\n        }\n        long[] xs = new long[uniqueXs.size()];\n        int xIdx = 0;\n        for (long x : uniqueXs) {\n            xs[xIdx++] = x;\n        }\n\n        long[] previous = new long[n + 1];\n        Arrays.fill(previous, INF);\n        previous[0] = 0;\n\n        for (int layer = 0; layer < groups; layer++) {\n            Line[] tree = new Line[4 * xs.length];\n            long[] current = new long[n + 1];\n            Arrays.fill(current, INF);\n            if (previous[0] != INF) {\n                insert(tree, new Line(0, previous[0]), 1, 0, xs.length - 1, xs);\n            }\n            for (int end = 1; end <= n; end++) {\n                long x = prefix[end] - target;\n                current[end] = x * x + query(tree, x, 1, 0, xs.length - 1, xs);\n                if (previous[end] != INF) {\n                    insert(tree, new Line(-2 * prefix[end], previous[end] + prefix[end] * prefix[end]), 1, 0, xs.length - 1, xs);\n                }\n            }\n            previous = current;\n        }\n        return (int) previous[n];\n    }\n}",
    "buggy_code": "import java.util.*;\n\nclass Solution {\n    private static class Line {\n        long m, b;\n        Line(long m, long b) {\n            this.m = m;\n            this.b = b;\n        }\n    }\n\n    private static final long INF = Long.MAX_VALUE / 4;\n\n    private long evaluate(Line line, long x) {\n        return line.m * x + line.b;\n    }\n\n    private void insert(Line[] tree, Line line, int node, int left, int right, long[] xs) {\n        if (tree[node] == null) {\n            tree[node] = line;\n            return;\n        }\n        int middle = (left + right) / 2;\n        boolean betterLeft = evaluate(line, xs[left]) < evaluate(tree[node], xs[left]);\n        boolean betterMiddle = evaluate(line, xs[middle]) < evaluate(tree[node], xs[middle]);\n        if (betterMiddle) {\n            Line temp = tree[node];\n            tree[node] = line;\n            line = temp;\n        }\n        if (left == right) {\n            return;\n        }\n        if (betterLeft != betterMiddle) {\n            insert(tree, line, node * 2, left, middle, xs);\n        } else {\n            insert(tree, line, node * 2 + 1, middle + 1, right, xs);\n        }\n    }\n\n    private long query(Line[] tree, long x, int node, int left, int right, long[] xs) {\n        long answer = (tree[node] == null) ? INF : evaluate(tree[node], x);\n        if (left == right) {\n            return answer;\n        }\n        int middle = (left + right) / 2;\n        if (x <= xs[middle]) {\n            return Math.min(answer, query(tree, x, node * 2, left, middle, xs));\n        }\n        return Math.min(answer, query(tree, x, node * 2 + 1, middle + 1, right, xs));\n    }\n\n    public int entryPoint(int[] values, int groups, int target) {\n        int n = values.length;\n        long[] prefix = new long[n + 1];\n        for (int i = 0; i < n; i++) {\n            prefix[i + 1] = prefix[i] + values[i];\n        }\n\n        TreeSet<Long> uniqueXs = new TreeSet<>();\n        for (int i = 1; i <= n; i++) {\n            uniqueXs.add(prefix[i] - target);\n        }\n        long[] xs = new long[uniqueXs.size()];\n        int xIdx = 0;\n        for (long x : uniqueXs) {\n            xs[xIdx++] = x;\n        }\n\n        long[] previous = new long[n + 1];\n        Arrays.fill(previous, INF);\n        previous[0] = 0;\n        Line[] tree = new Line[4 * xs.length];\n\n        for (int layer = 0; layer < groups; layer++) {\n            long[] current = new long[n + 1];\n            Arrays.fill(current, INF);\n            if (previous[0] != INF) {\n                insert(tree, new Line(0, previous[0]), 1, 0, xs.length - 1, xs);\n            }\n            for (int end = 1; end <= n; end++) {\n                long x = prefix[end] - target;\n                if (previous[end] != INF) {\n                    insert(tree, new Line(-2 * prefix[end], previous[end] + prefix[end] * prefix[end]), 1, 0, xs.length - 1, xs);\n                }\n                current[end] = x * x + query(tree, x, 1, 0, xs.length - 1, xs);\n            }\n            previous = current;\n        }\n        return (int) previous[n];\n    }\n}",
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
