-- Preserve supplied topics; existing/generated problems may have no topic.
ALTER TABLE problems ADD COLUMN topic text;

-- Applied once by the migration runner, in the same transaction as its tracking record.
-- The first two tests are public examples; remaining tests stay hidden.
INSERT INTO problems (title, description, difficulty, topic, entry_point,
                      buggy_code, fixed_code, tests, visible_test_count)
SELECT title, description, difficulty, topic, entry_point,
       buggy_code, fixed_code, tests, 2
FROM jsonb_to_recordset($questions$
[
  {
    "title": "Longest Overheating Streak",
    "topic": "arrays",
    "description": "A machine records one temperature reading each minute. A reading is overheating when it is **greater than or equal to** a given threshold.\n\nImplement `entry_point(readings, threshold)` to return the longest consecutive streak of overheating readings. Return `0` if no reading qualifies.\n\n### Examples\n- Input: `readings = [70, 80, 85, 60], threshold = 80`\n  Output: `2`\n- Input: `readings = [40, 50], threshold = 60`\n  Output: `0`\n\n### Constraints\n- `0 <= len(readings) <= 10000`\n- Each reading and `threshold` is an integer between `-100` and `1000`.",
    "difficulty": "easy",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(readings, threshold):\n    longest = 0\n    current = 0\n    for reading in readings:\n        if reading >= threshold:\n            current += 1\n            longest = max(longest, current)\n        else:\n            current = 0\n    return longest",
    "buggy_code": "def entry_point(readings, threshold):\n    longest = 0\n    current = 0\n    for reading in readings:\n        if reading > threshold:\n            current += 1\n            longest = max(longest, current)\n        else:\n            current = 0\n    return longest",
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
    "description": "A label imported from a text file may contain extra spaces. Clean it by removing leading and trailing spaces and replacing every consecutive group of internal spaces with one space. Preserve all other characters and their capitalization.\n\nImplement `entry_point(label)` to return the cleaned label. A label containing only spaces becomes an empty string.\n\n### Examples\n- Input: `label = \"  Main   Office  \"`\n  Output: `\"Main Office\"`\n- Input: `label = \"Desk 7\"`\n  Output: `\"Desk 7\"`\n\n### Constraints\n- `0 <= len(label) <= 10000`\n- `label` contains only English letters, digits, and ordinary ASCII spaces.",
    "difficulty": "easy",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(label):\n    result = []\n    for character in label:\n        if character != ' ':\n            result.append(character)\n        elif result and result[-1] != ' ':\n            result.append(' ')\n    return ''.join(result).rstrip(' ')",
    "buggy_code": "def entry_point(label):\n    result = []\n    for character in label:\n        if character != ' ':\n            result.append(character)\n        elif result and result[-1] != ' ':\n            result.append(' ')\n    return ''.join(result).lstrip(' ')",
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
    "description": "A warehouse receives delivery records. Each record is a two-element list `[item, quantity]`. The same item may appear in multiple records.\n\nImplement `entry_point(deliveries)` to return an object mapping each item to the total quantity delivered. Include every item that appears, even if its total is zero. Item names are case-sensitive. Object key order does not matter.\n\n### Examples\n- Input: `deliveries = [[\"bolts\", 3], [\"bolts\", 4]]`\n  Output: `{\"bolts\": 7}`\n- Input: `deliveries = [[\"tape\", 2], [\"glue\", 5]]`\n  Output: `{\"tape\": 2, \"glue\": 5}`\n\n### Constraints\n- `0 <= len(deliveries) <= 10000`\n- Each record contains an item name followed by an integer quantity.\n- Item names contain between `1` and `30` English letters.\n- `0 <= quantity <= 100000`.",
    "difficulty": "easy",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(deliveries):\n    totals = {}\n    for item, quantity in deliveries:\n        if item not in totals:\n            totals[item] = 0\n        totals[item] += quantity\n    return totals",
    "buggy_code": "def entry_point(deliveries):\n    totals = {}\n    for item, quantity in deliveries:\n        if item not in totals:\n            totals[item] = 0\n        totals[item] = quantity\n    return totals",
    "tests": [
      {
        "args": [
          [
            [
              "bolts",
              3
            ],
            [
              "bolts",
              4
            ]
          ]
        ],
        "expected": {
          "bolts": 7
        }
      },
      {
        "args": [
          [
            [
              "tape",
              2
            ],
            [
              "glue",
              5
            ]
          ]
        ],
        "expected": {
          "tape": 2,
          "glue": 5
        }
      },
      {
        "args": [
          []
        ],
        "expected": {}
      },
      {
        "args": [
          [
            [
              "washers",
              0
            ]
          ]
        ],
        "expected": {
          "washers": 0
        }
      },
      {
        "args": [
          [
            [
              "nuts",
              5
            ],
            [
              "nuts",
              0
            ]
          ]
        ],
        "expected": {
          "nuts": 5
        }
      },
      {
        "args": [
          [
            [
              "Tape",
              2
            ],
            [
              "tape",
              3
            ],
            [
              "Tape",
              4
            ]
          ]
        ],
        "expected": {
          "Tape": 6,
          "tape": 3
        }
      },
      {
        "args": [
          [
            [
              "a",
              1
            ],
            [
              "b",
              2
            ],
            [
              "a",
              3
            ],
            [
              "b",
              4
            ],
            [
              "a",
              5
            ]
          ]
        ],
        "expected": {
          "a": 9,
          "b": 6
        }
      }
    ]
  },
  {
    "title": "Undo Draft Lines",
    "topic": "stacks",
    "description": "A small drafting tool processes a list of string actions. An action equal to `\"UNDO\"` removes the most recently added line that is still present. If no lines remain, `\"UNDO\"` does nothing. Every other action adds that string as a new line, including an empty string.\n\nImplement `entry_point(actions)` to return the remaining lines in their original insertion order. The reserved action `\"UNDO\"` cannot be added as ordinary text.\n\n### Examples\n- Input: `actions = [\"Title\", \"Draft\", \"UNDO\"]`\n  Output: `[\"Title\"]`\n- Input: `actions = [\"UNDO\", \"Hello\"]`\n  Output: `[\"Hello\"]`\n\n### Constraints\n- `0 <= len(actions) <= 10000`\n- Each action is a string containing at most `100` characters.\n- Actions are case-sensitive.",
    "difficulty": "easy",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(actions):\n    lines = []\n    for action in actions:\n        if action == 'UNDO':\n            if lines:\n                lines.pop()\n        else:\n            lines.append(action)\n    return lines",
    "buggy_code": "def entry_point(actions):\n    lines = []\n    for action in actions:\n        if action == 'UNDO':\n            if lines:\n                lines.pop(0)\n        else:\n            lines.append(action)\n    return lines",
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
    "description": "A service publishes maintenance windows as pairs `[start, end]`. Each window includes its start time and excludes its end time. A customer's session follows the same rule.\n\nImplement `entry_point(windows, session_start, session_end)` to count how many maintenance windows overlap the session for a positive amount of time. A window that ends exactly when the session starts, or starts exactly when the session ends, does not overlap. Count each listed window separately, including duplicate windows.\n\n### Examples\n- Input: `windows = [[1, 4], [6, 9]], session_start = 3, session_end = 7`\n  Output: `2`\n- Input: `windows = [[1, 3], [7, 9]], session_start = 3, session_end = 7`\n  Output: `0`\n\n### Constraints\n- `0 <= len(windows) <= 10000`\n- Each window contains two integers satisfying `0 <= start < end <= 1000000`.\n- `0 <= session_start < session_end <= 1000000`\n- Windows may appear in any order and may overlap one another.",
    "difficulty": "easy",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(windows, session_start, session_end):\n    count = 0\n    for start, end in windows:\n        overlap_start = max(start, session_start)\n        overlap_end = min(end, session_end)\n        if overlap_start < overlap_end:\n            count += 1\n    return count",
    "buggy_code": "def entry_point(windows, session_start, session_end):\n    count = 0\n    for start, end in windows:\n        overlap_start = max(start, session_start)\n        overlap_end = min(end, session_end)\n        if overlap_start <= overlap_end:\n            count += 1\n    return count",
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
  }
]
$questions$::jsonb) AS question(
  title text, topic text, description text, difficulty text, entry_point text,
  fixed_code text, buggy_code text, tests jsonb
);
