-- 008_seed_typescript_questions.sql
-- TypeScript translations of the seeded questions; the first two tests are public examples.
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A machine records one temperature reading each minute. A reading is overheating when it is **greater than or equal to** a given threshold.\n\nImplement `entryPoint(readings, threshold)` to return the longest consecutive streak of overheating readings. Return `0` if no reading qualifies.\n\n### Examples\n- Input: `readings = [70, 80, 85, 60], threshold = 80`\n  Output: `2`\n- Input: `readings = [40, 50], threshold = 60`\n  Output: `0`\n\n### Constraints\n- `0 <= readings.length <= 10000`\n- Each reading and `threshold` is an integer between `-100` and `1000`.",
    "fixed_code": "function entryPoint(readings: number[], threshold: number): number {\n    let longest = 0;\n    let current = 0;\n    for (const reading of readings) {\n        if (reading >= threshold) {\n            current += 1;\n            longest = Math.max(longest, current);\n        } else {\n            current = 0;\n        }\n    }\n    return longest;\n}",
    "buggy_code": "function entryPoint(readings: number[], threshold: number): number {\n    let longest = 0;\n    let current = 0;\n    for (const reading of readings) {\n        if (reading > threshold) {\n            current += 1;\n            longest = Math.max(longest, current);\n        } else {\n            current = 0;\n        }\n    }\n    return longest;\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A label imported from a text file may contain extra spaces. Clean it by removing leading and trailing spaces and replacing every consecutive group of internal spaces with one space. Preserve all other characters and their capitalization.\n\nImplement `entryPoint(label)` to return the cleaned label. A label containing only spaces becomes an empty string.\n\n### Examples\n- Input: `label = \"  Main   Office  \"`\n  Output: `\"Main Office\"`\n- Input: `label = \"Desk 7\"`\n  Output: `\"Desk 7\"`\n\n### Constraints\n- `0 <= label.length <= 10000`\n- `label` contains only English letters, digits, and ordinary ASCII spaces.",
    "fixed_code": "function entryPoint(label: string): string {\n    const result: string[] = [];\n    for (const character of label) {\n        if (character !== ' ') {\n            result.push(character);\n        } else if (result.length > 0 && result[result.length - 1] !== ' ') {\n            result.push(' ');\n        }\n    }\n    return result.join('').trimEnd();\n}",
    "buggy_code": "function entryPoint(label: string): string {\n    const result: string[] = [];\n    for (const character of label) {\n        if (character !== ' ') {\n            result.push(character);\n        } else if (result.length > 0 && result[result.length - 1] !== ' ') {\n            result.push(' ');\n        }\n    }\n    return result.join('').trimStart();\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A warehouse receives delivery records. Each record is a two-element array `[item, quantity]`. The same item may appear in multiple records.\n\nImplement `entryPoint(deliveries)` to return an object mapping each item to the total quantity delivered. Include every item that appears, even if its total is zero. Item names are case-sensitive. Object key order does not matter.\n\n### Examples\n- Input: `deliveries = [[\"bolts\", 3], [\"bolts\", 4]]`\n  Output: `{\"bolts\": 7}`\n- Input: `deliveries = [[\"tape\", 2], [\"glue\", 5]]`\n  Output: `{\"tape\": 2, \"glue\": 5}`\n\n### Constraints\n- `0 <= deliveries.length <= 10000`\n- Each record contains an item name followed by an integer quantity.\n- Item names contain between `1` and `30` English letters.\n- `0 <= quantity <= 100000`.",
    "fixed_code": "function entryPoint(deliveries: [string, number][]): Record<string, number> {\n    const totals: Record<string, number> = {};\n    for (const [item, quantity] of deliveries) {\n        if (!(item in totals)) {\n            totals[item] = 0;\n        }\n        totals[item] += quantity;\n    }\n    return totals;\n}",
    "buggy_code": "function entryPoint(deliveries: [string, number][]): Record<string, number> {\n    const totals: Record<string, number> = {};\n    for (const [item, quantity] of deliveries) {\n        if (!(item in totals)) {\n            totals[item] = 0;\n        }\n        totals[item] = quantity;\n    }\n    return totals;\n}",
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
    "difficulty": "easy",
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A small drafting tool processes an array of string actions. An action equal to `\"UNDO\"` removes the most recently added line that is still present. If no lines remain, `\"UNDO\"` does nothing. Every other action adds that string as a new line, including an empty string.\n\nImplement `entryPoint(actions)` to return the remaining lines in their original insertion order. The reserved action `\"UNDO\"` cannot be added as ordinary text.\n\n### Examples\n- Input: `actions = [\"Title\", \"Draft\", \"UNDO\"]`\n  Output: `[\"Title\"]`\n- Input: `actions = [\"UNDO\", \"Hello\"]`\n  Output: `[\"Hello\"]`\n\n### Constraints\n- `0 <= actions.length <= 10000`\n- Each action is a string containing at most `100` characters.\n- Actions are case-sensitive.",
    "fixed_code": "function entryPoint(actions: string[]): string[] {\n    const lines: string[] = [];\n    for (const action of actions) {\n        if (action === 'UNDO') {\n            if (lines.length > 0) {\n                lines.pop();\n            }\n        } else {\n            lines.push(action);\n        }\n    }\n    return lines;\n}",
    "buggy_code": "function entryPoint(actions: string[]): string[] {\n    const lines: string[] = [];\n    for (const action of actions) {\n        if (action === 'UNDO') {\n            if (lines.length > 0) {\n                lines.shift();\n            }\n        } else {\n            lines.push(action);\n        }\n    }\n    return lines;\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A service publishes maintenance windows as pairs `[start, end]`. Each window includes its start time and excludes its end time. A customer's session follows the same rule.\n\nImplement `entryPoint(windows, sessionStart, sessionEnd)` to count how many maintenance windows overlap the session for a positive amount of time. A window that ends exactly when the session starts, or starts exactly when the session ends, does not overlap. Count each listed window separately, including duplicate windows.\n\n### Examples\n- Input: `windows = [[1, 4], [6, 9]], sessionStart = 3, sessionEnd = 7`\n  Output: `2`\n- Input: `windows = [[1, 3], [7, 9]], sessionStart = 3, sessionEnd = 7`\n  Output: `0`\n\n### Constraints\n- `0 <= windows.length <= 10000`\n- Each window contains two integers satisfying `0 <= start < end <= 1000000`.\n- `0 <= sessionStart < sessionEnd <= 1000000`\n- Windows may appear in any order and may overlap one another.",
    "fixed_code": "function entryPoint(windows: number[][], sessionStart: number, sessionEnd: number): number {\n    let count = 0;\n    for (const [start, end] of windows) {\n        const overlapStart = Math.max(start, sessionStart);\n        const overlapEnd = Math.min(end, sessionEnd);\n        if (overlapStart < overlapEnd) {\n            count += 1;\n        }\n    }\n    return count;\n}",
    "buggy_code": "function entryPoint(windows: number[][], sessionStart: number, sessionEnd: number): number {\n    let count = 0;\n    for (const [start, end] of windows) {\n        const overlapStart = Math.max(start, sessionStart);\n        const overlapEnd = Math.min(end, sessionEnd);\n        if (overlapStart <= overlapEnd) {\n            count += 1;\n        }\n    }\n    return count;\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "An audit system stores events in chronological order. Each event has a category and a nonnegative review cost.\n\nImplement `entryPoint(categories, costs, budget, categoryLimit)` to return the maximum number of consecutive events that can be selected while satisfying both rules:\n\n- Their total review cost is at most `budget`.\n- No category appears more than `categoryLimit` times.\n\nReturn `0` if no nonempty selection is valid. The input arrays have equal lengths, and their matching positions describe the same event.\n\n### Examples\n- Input: `categories = [\"a\", \"b\", \"a\"], costs = [2, 1, 2], budget = 5, categoryLimit = 2`\n  Output: `3`\n- Input: `categories = [\"a\", \"a\", \"b\"], costs = [1, 1, 1], budget = 3, categoryLimit = 1`\n  Output: `2`\n\n### Constraints\n- `0 <= categories.length == costs.length <= 100000`\n- Categories are nonempty lowercase English strings of length at most `20`.\n- `0 <= costs[i] <= 10000`\n- `0 <= budget <= 1000000000`\n- `1 <= categoryLimit <= 100000`",
    "fixed_code": "function entryPoint(categories: string[], costs: number[], budget: number, categoryLimit: number): number {\n    const counts: Record<string, number> = {};\n    let left = 0;\n    let total = 0;\n    let best = 0;\n    for (let right = 0; right < categories.length; right++) {\n        const category = categories[right];\n        counts[category] = (counts[category] || 0) + 1;\n        total += costs[right];\n        while (total > budget || counts[category] > categoryLimit) {\n            const departing = categories[left];\n            counts[departing] -= 1;\n            total -= costs[left];\n            left += 1;\n        }\n        const length = right - left + 1;\n        best = Math.max(best, length);\n    }\n    return best;\n}",
    "buggy_code": "function entryPoint(categories: string[], costs: number[], budget: number, categoryLimit: number): number {\n    const counts: Record<string, number> = {};\n    let left = 0;\n    let total = 0;\n    let best = 0;\n    for (let right = 0; right < categories.length; right++) {\n        const category = categories[right];\n        counts[category] = (counts[category] || 0) + 1;\n        total += costs[right];\n        if (total > budget || counts[category] > categoryLimit) {\n            const departing = categories[left];\n            counts[departing] -= 1;\n            total -= costs[left];\n            left += 1;\n        }\n        const length = right - left + 1;\n        best = Math.max(best, length);\n    }\n    return best;\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A search box accepts a small query language. Implement `entryPoint(query)` to return its tokens in order according to these rules:\n\n- Ordinary ASCII spaces separate tokens when outside double quotes.\n- Double quotes toggle quoted mode and are omitted from the token. Spaces inside quotes are preserved.\n- A backslash escapes the next character, inside or outside quotes. The escaped character is added literally, and the backslash is omitted.\n- Adjacent quoted and unquoted portions belong to the same token unless separated by an unquoted, unescaped space.\n- Empty quoted portions count as a token when standing alone.\n- Leading, trailing, and repeated separator spaces do not create tokens.\n\n### Examples\n- Input: `query = \"red \\\"blue sky\\\"\"`\n  Output: `[\"red\", \"blue sky\"]`\n- Input: `query = \"a\\\"b c\\\"d\"`\n  Output: `[\"ab cd\"]`\n\n### Constraints\n- `0 <= query.length <= 100000`\n- The query contains printable ASCII characters.\n- Every backslash has a following character.\n- Unescaped double quotes are balanced.",
    "fixed_code": "function entryPoint(query: string): string[] {\n    const tokens: string[] = [];\n    const current: string[] = [];\n    let quoted = false;\n    let active = false;\n    let i = 0;\n    while (i < query.length) {\n        const character = query[i];\n        if (character === '\\\\') {\n            i += 1;\n            current.push(query[i]);\n            active = true;\n        } else if (character === '\"') {\n            quoted = !quoted;\n            active = true;\n        } else if (character === ' ' && !quoted) {\n            if (active) {\n                tokens.push(current.join(''));\n                current.length = 0;\n                active = false;\n            }\n        } else {\n            current.push(character);\n            active = true;\n        }\n        i += 1;\n    }\n    if (active) {\n        tokens.push(current.join(''));\n    }\n    return tokens;\n}",
    "buggy_code": "function entryPoint(query: string): string[] {\n    const tokens: string[] = [];\n    const current: string[] = [];\n    let quoted = false;\n    let active = false;\n    let i = 0;\n    while (i < query.length) {\n        const character = query[i];\n        if (character === '\\\\' && quoted) {\n            i += 1;\n            current.push(query[i]);\n            active = true;\n        } else if (character === '\"') {\n            quoted = !quoted;\n            active = true;\n        } else if (character === ' ' && !quoted) {\n            if (active) {\n                tokens.push(current.join(''));\n                current.length = 0;\n                active = false;\n            }\n        } else {\n            current.push(character);\n            active = true;\n        }\n        i += 1;\n    }\n    if (active) {\n        tokens.push(current.join(''));\n    }\n    return tokens;\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A data platform must run `n` export jobs, numbered from `0` to `n - 1`. Job `i` takes `durations[i]` time units and cannot start before time `releaseTimes[i]`.\n\nEach dependency `[before, after]` means that job `after` must wait until job `before` finishes. A job must wait for all its prerequisites. Unlimited workers are available, so unrelated jobs may run simultaneously. Jobs begin as soon as their release times and dependencies permit.\n\nImplement `entryPoint(durations, releaseTimes, dependencies)` to return an array containing the earliest finish time of every job, in job-number order. The dependency graph is guaranteed to have no cycles.\n\n### Examples\n- Input: `durations = [2, 3], releaseTimes = [0, 0], dependencies = [[0, 1]]`\n  Output: `[2, 5]`\n- Input: `durations = [2, 1], releaseTimes = [5, 0], dependencies = []`\n  Output: `[7, 1]`\n\n### Constraints\n- `0 <= n <= 10000`\n- `durations.length == releaseTimes.length == n`\n- `1 <= durations[i] <= 1000000`\n- `0 <= releaseTimes[i] <= 1000000000`\n- There are at most `50000` dependencies.\n- Dependencies use valid, distinct job numbers, and duplicate dependency pairs do not occur.",
    "fixed_code": "function entryPoint(durations: number[], releaseTimes: number[], dependencies: number[][]): number[] {\n    const n = durations.length;\n    const outgoing: number[][] = Array.from({ length: n }, () => []);\n    const remaining: number[] = new Array(n).fill(0);\n    for (const [before, after] of dependencies) {\n        outgoing[before].push(after);\n        remaining[after] += 1;\n    }\n    const starts: number[] = [...releaseTimes];\n    const finishes: number[] = new Array(n).fill(0);\n    const ready: number[] = [];\n    for (let i = 0; i < n; i++) {\n        if (remaining[i] === 0) {\n            ready.push(i);\n        }\n    }\n    let head = 0;\n    while (head < ready.length) {\n        const job = ready[head++];\n        finishes[job] = starts[job] + durations[job];\n        for (const child of outgoing[job]) {\n            starts[child] = Math.max(starts[child], finishes[job]);\n            remaining[child] -= 1;\n            if (remaining[child] === 0) {\n                ready.push(child);\n            }\n        }\n    }\n    return finishes;\n}",
    "buggy_code": "function entryPoint(durations: number[], releaseTimes: number[], dependencies: number[][]): number[] {\n    const n = durations.length;\n    const outgoing: number[][] = Array.from({ length: n }, () => []);\n    const remaining: number[] = new Array(n).fill(0);\n    for (const [before, after] of dependencies) {\n        outgoing[before].push(after);\n        remaining[after] += 1;\n    }\n    const starts: number[] = [...releaseTimes];\n    const finishes: number[] = new Array(n).fill(0);\n    const ready: number[] = [];\n    for (let i = 0; i < n; i++) {\n        if (remaining[i] === 0) {\n            ready.push(i);\n        }\n    }\n    let head = 0;\n    while (head < ready.length) {\n        const job = ready[head++];\n        finishes[job] = starts[job] + durations[job];\n        for (const child of outgoing[job]) {\n            starts[child] = Math.max(releaseTimes[child], finishes[job]);\n            remaining[child] -= 1;\n            if (remaining[child] === 0) {\n                ready.push(child);\n            }\n        }\n    }\n    return finishes;\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A facility receives resource reservations. Each reservation is `[start, end, units]` and uses `units` resources throughout the half-open time interval `[start, end)`. Simultaneous reservations add their resource usage.\n\nImplement `entryPoint(reservations, threshold)` to return the total duration during which combined resource usage is at least `threshold`.\n\nCount elapsed time only once, regardless of how many reservations overlap. Reservations may be unsorted, duplicated, nested, or adjacent. Usage is zero outside all reservations.\n\n### Examples\n- Input: `reservations = [[0, 4, 2], [2, 6, 3]], threshold = 4`\n  Output: `2`\n  Explanation: Usage reaches at least 4 only during [2, 4).\n- Input: `reservations = [[1, 5, 3]], threshold = 3`\n  Output: `4`\n\n### Constraints\n- `0 <= reservations.length <= 100000`\n- `0 <= start < end <= 1000000000`\n- `1 <= units <= 1000000`\n- `1 <= threshold <= 100000000000`",
    "fixed_code": "function entryPoint(reservations: number[][], threshold: number): number {\n    const changes: Map<number, number> = new Map();\n    for (const [start, end, units] of reservations) {\n        changes.set(start, (changes.get(start) || 0) + units);\n        changes.set(end, (changes.get(end) || 0) - units);\n    }\n    const times = Array.from(changes.keys()).sort((a, b) => a - b);\n    let active = 0;\n    let previous: number | null = null;\n    let duration = 0;\n    for (const time of times) {\n        if (previous !== null && active >= threshold) {\n            duration += time - previous;\n        }\n        active += changes.get(time)!;\n        previous = time;\n    }\n    return duration;\n}",
    "buggy_code": "function entryPoint(reservations: number[][], threshold: number): number {\n    const changes: Map<number, number> = new Map();\n    for (const [start, end, units] of reservations) {\n        changes.set(start, (changes.get(start) || 0) + units);\n        changes.set(end, (changes.get(end) || 0) - units);\n    }\n    const times = Array.from(changes.keys()).sort((a, b) => a - b);\n    let active = 0;\n    let previous: number | null = null;\n    let duration = 0;\n    for (const time of times) {\n        if (previous !== null && active > threshold) {\n            duration += time - previous;\n        }\n        active += changes.get(time)!;\n        previous = time;\n    }\n    return duration;\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A print shop must process jobs in their existing order. Each job has a positive intensity value. The shop partitions the jobs into nonempty, consecutive batches containing at most `maxBatch` jobs each.\n\nThe cost of a batch is:\n\n`setupCost + (number of jobs in the batch) * (maximum intensity in the batch)`\n\nEvery job must belong to exactly one batch. Jobs cannot be reordered.\n\nImplement `entryPoint(intensities, maxBatch, setupCost)` to return the minimum total cost. Return `0` when there are no jobs.\n\n### Examples\n- Input: `intensities = [2, 2], maxBatch = 2, setupCost = 3`\n  Output: `7`\n  Explanation: One batch costs 3 + 2 * 2 = 7.\n- Input: `intensities = [1, 10], maxBatch = 2, setupCost = 2`\n  Output: `15`\n  Explanation: Separate batches cost (2 + 1) + (2 + 10) = 15.\n\n### Constraints\n- `0 <= intensities.length <= 1000`\n- `1 <= intensities[i] <= 10000`\n- `1 <= maxBatch <= 100`\n- `0 <= setupCost <= 10000`",
    "fixed_code": "function entryPoint(intensities: number[], maxBatch: number, setupCost: number): number {\n    const n = intensities.length;\n    const dp: number[] = new Array(n + 1).fill(0);\n    for (let end = 1; end <= n; end++) {\n        let peak = intensities[end - 1];\n        let best = dp[end - 1] + setupCost + peak;\n        for (let length = 1; length <= Math.min(maxBatch, end); length++) {\n            peak = Math.max(peak, intensities[end - length]);\n            const candidate = dp[end - length] + setupCost + length * peak;\n            best = Math.min(best, candidate);\n        }\n        dp[end] = best;\n    }\n    return dp[n];\n}",
    "buggy_code": "function entryPoint(intensities: number[], maxBatch: number, setupCost: number): number {\n    const n = intensities.length;\n    const dp: number[] = new Array(n + 1).fill(0);\n    for (let end = 1; end <= n; end++) {\n        let peak = intensities[end - 1];\n        let best = dp[end - 1] + setupCost + peak;\n        for (let length = 1; length < Math.min(maxBatch, end); length++) {\n            peak = Math.max(peak, intensities[end - length]);\n            const candidate = dp[end - length] + setupCost + length * peak;\n            best = Math.min(best, candidate);\n        }\n        dp[end] = best;\n    }\n    return dp[n];\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A network contains `n` devices numbered from `0` to `n - 1`. Its undirected links are available only during specified time windows.\n\nEach record `[u, v, start, end]` in `links` makes a link available throughout the half-open interval `[start, end)`. Multiple records may describe the same pair of devices; the link is available whenever any corresponding record is active.\n\nEach query `[time, u, v]` asks whether the devices are connected by a path of links that are all available at that time. A device is always connected to itself.\n\nImplement `entryPoint(n, links, queries)` to return an array of booleans in the original query order. Neither links nor queries are necessarily sorted.\n\n### Examples\n- Input: `n = 3, links = [[0, 1, 0, 5], [1, 2, 2, 4]], queries = [[1, 0, 2], [3, 0, 2]]`\n  Output: `[false, true]`\n- Input: `n = 2, links = [[0, 1, 1, 3]], queries = [[1, 0, 1], [3, 0, 1]]`\n  Output: `[true, false]`\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= links.length, queries.length <= 30000`\n- All device numbers are valid.\n- Link endpoints are distinct.\n- `0 <= start < end <= 1000000000`\n- Query times are integers between `0` and `1000000000`.",
    "fixed_code": "function entryPoint(n: number, links: number[][], queries: number[][]): boolean[] {\n    if (queries.length === 0) {\n        return [];\n    }\n    const times = Array.from(new Set(queries.map(q => q[0]))).sort((a, b) => a - b);\n    let base = 1;\n    while (base < times.length) {\n        base <<= 1;\n    }\n    const tree: [number, number][][] = Array.from({ length: 2 * base }, () => []);\n\n    function bisectLeft(arr: number[], x: number): number {\n        let low = 0, high = arr.length;\n        while (low < high) {\n            const mid = (low + high) >> 1;\n            if (arr[mid] < x) low = mid + 1;\n            else high = mid;\n        }\n        return low;\n    }\n\n    for (const [u, v, start, end] of links) {\n        let left = bisectLeft(times, start) + base;\n        let right = bisectLeft(times, end) + base;\n        while (left < right) {\n            if (left & 1) {\n                tree[left].push([u, v]);\n                left += 1;\n            }\n            if (right & 1) {\n                right -= 1;\n                tree[right].push([u, v]);\n            }\n            left >>= 1;\n            right >>= 1;\n        }\n    }\n\n    const buckets: [number, number, number][][] = Array.from({ length: base }, () => []);\n    for (let i = 0; i < queries.length; i++) {\n        const [time, u, v] = queries[i];\n        buckets[bisectLeft(times, time)].push([i, u, v]);\n    }\n\n    const parent: number[] = Array.from({ length: n }, (_, i) => i);\n    const size: number[] = new Array(n).fill(1);\n    const history: [number, number, number][] = [];\n    const answer: boolean[] = new Array(queries.length).fill(false);\n\n    function find(x: number): number {\n        while (parent[x] !== x) {\n            x = parent[x];\n        }\n        return x;\n    }\n\n    function visit(node: number): void {\n        const snapshot = history.length;\n        for (const [u, v] of tree[node]) {\n            let a = find(u);\n            let b = find(v);\n            if (a !== b) {\n                if (size[a] < size[b]) {\n                    const temp = a;\n                    a = b;\n                    b = temp;\n                }\n                history.push([b, a, size[a]]);\n                parent[b] = a;\n                size[a] += size[b];\n            }\n        }\n        if (node >= base) {\n            for (const [i, u, v] of buckets[node - base]) {\n                answer[i] = find(u) === find(v);\n            }\n        } else {\n            visit(2 * node);\n            visit(2 * node + 1);\n        }\n        while (history.length > snapshot) {\n            const [b, a, oldSize] = history.pop()!;\n            parent[b] = b;\n            size[a] = oldSize;\n        }\n    }\n\n    visit(1);\n    return answer;\n}",
    "buggy_code": "function entryPoint(n: number, links: number[][], queries: number[][]): boolean[] {\n    if (queries.length === 0) {\n        return [];\n    }\n    const times = Array.from(new Set(queries.map(q => q[0]))).sort((a, b) => a - b);\n    let base = 1;\n    while (base < times.length) {\n        base <<= 1;\n    }\n    const tree: [number, number][][] = Array.from({ length: 2 * base }, () => []);\n\n    function bisectLeft(arr: number[], x: number): number {\n        let low = 0, high = arr.length;\n        while (low < high) {\n            const mid = (low + high) >> 1;\n            if (arr[mid] < x) low = mid + 1;\n            else high = mid;\n        }\n        return low;\n    }\n\n    function bisectRight(arr: number[], x: number): number {\n        let low = 0, high = arr.length;\n        while (low < high) {\n            const mid = (low + high) >> 1;\n            if (arr[mid] <= x) low = mid + 1;\n            else high = mid;\n        }\n        return low;\n    }\n\n    for (const [u, v, start, end] of links) {\n        let left = bisectLeft(times, start) + base;\n        let right = bisectRight(times, end) + base;\n        while (left < right) {\n            if (left & 1) {\n                tree[left].push([u, v]);\n                left += 1;\n            }\n            if (right & 1) {\n                right -= 1;\n                tree[right].push([u, v]);\n            }\n            left >>= 1;\n            right >>= 1;\n        }\n    }\n\n    const buckets: [number, number, number][][] = Array.from({ length: base }, () => []);\n    for (let i = 0; i < queries.length; i++) {\n        const [time, u, v] = queries[i];\n        buckets[bisectLeft(times, time)].push([i, u, v]);\n    }\n\n    const parent: number[] = Array.from({ length: n }, (_, i) => i);\n    const size: number[] = new Array(n).fill(1);\n    const history: [number, number, number][] = [];\n    const answer: boolean[] = new Array(queries.length).fill(false);\n\n    function find(x: number): number {\n        while (parent[x] !== x) {\n            parent[x] = parent[parent[x]];\n            x = parent[x];\n        }\n        return x;\n    }\n\n    function visit(node: number): void {\n        const snapshot = history.length;\n        for (const [u, v] of tree[node]) {\n            let a = find(u);\n            let b = find(v);\n            if (a !== b) {\n                if (size[a] < size[b]) {\n                    const temp = a;\n                    a = b;\n                    b = temp;\n                }\n                history.push([b, a, size[a]]);\n                parent[b] = a;\n                size[a] += size[b];\n            }\n        }\n        if (node >= base) {\n            for (const [i, u, v] of buckets[node - base]) {\n                answer[i] = find(u) === find(v);\n            }\n        } else {\n            visit(2 * node);\n            visit(2 * node + 1);\n        }\n        while (history.length > snapshot) {\n            const [b, a, oldSize] = history.pop()!;\n            parent[b] = b;\n            size[a] = oldSize;\n        }\n    }\n\n    visit(1);\n    return answer;\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A shipment starts at depot `0` at `startTime` and must reach depot `n - 1`.\n\nEach directed route is `[u, v, offset, period, duration]`. Regular vehicles depart depot `u` at times `offset + k * period` for every integer `k >= 0`, and take `duration` time units to reach depot `v`. A shipment arriving exactly at a departure time may board that vehicle. Waiting at depots is allowed.\n\nThe shipment has one express dispatch voucher. At most once during the entire journey, it may traverse any listed route immediately, ignoring its departure schedule but still taking that route's full travel duration. This is allowed even before the route's first regular departure.\n\nImplement `entryPoint(n, routes, startTime)` to return the earliest absolute arrival time at depot `n - 1`, or `-1` if it is unreachable. The voucher does not need to be used.\n\n### Examples\n- Input: `n = 2, routes = [[0, 1, 10, 5, 3]], startTime = 0`\n  Output: `3`\n  Explanation: An express dispatch leaves immediately.\n- Input: `n = 3, routes = [[0, 1, 0, 10, 2], [1, 2, 5, 10, 2]], startTime = 0`\n  Output: `4`\n  Explanation: Take the first regular departure, then use the voucher.\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= routes.length <= 50000`\n- Routes use valid, distinct endpoints. Parallel routes and directed cycles are allowed.\n- `0 <= offset, startTime <= 1000000000`\n- `1 <= period, duration <= 1000000`",
    "fixed_code": "function entryPoint(n: number, routes: number[][], startTime: number): number {\n    const graph: [number, number, number, number][][] = Array.from({ length: n }, () => []);\n    for (const [u, v, offset, period, duration] of routes) {\n        graph[u].push([v, offset, period, duration]);\n    }\n    const best: number[][] = Array.from({ length: n }, () => [Infinity, Infinity]);\n    best[0][0] = startTime;\n\n    const heap: [number, number, number][] = [[startTime, 0, 0]];\n    function push(item: [number, number, number]): void {\n        heap.push(item);\n        let idx = heap.length - 1;\n        while (idx > 0) {\n            const p = (idx - 1) >> 1;\n            if (heap[idx][0] < heap[p][0]) {\n                const temp = heap[idx];\n                heap[idx] = heap[p];\n                heap[p] = temp;\n                idx = p;\n            } else {\n                break;\n            }\n        }\n    }\n    function pop(): [number, number, number] | undefined {\n        if (heap.length === 0) return undefined;\n        const top = heap[0];\n        const last = heap.pop()!;\n        if (heap.length > 0) {\n            heap[0] = last;\n            let idx = 0;\n            const len = heap.length;\n            while (true) {\n                let left = (idx << 1) + 1;\n                let right = left + 1;\n                let smallest = idx;\n                if (left < len && heap[left][0] < heap[smallest][0]) smallest = left;\n                if (right < len && heap[right][0] < heap[smallest][0]) smallest = right;\n                if (smallest !== idx) {\n                    const temp = heap[idx];\n                    heap[idx] = heap[smallest];\n                    heap[smallest] = temp;\n                    idx = smallest;\n                } else {\n                    break;\n                }\n            }\n        }\n        return top;\n    }\n\n    while (heap.length > 0) {\n        const [time, node, used] = pop()!;\n        if (time !== best[node][used]) {\n            continue;\n        }\n        if (node === n - 1) {\n            return time;\n        }\n        for (const [target, offset, period, duration] of graph[node]) {\n            let departure: number;\n            if (time <= offset) {\n                departure = offset;\n            } else {\n                departure = offset + Math.floor((time - offset + period - 1) / period) * period;\n            }\n            const arrival = departure + duration;\n            if (arrival < best[target][used]) {\n                best[target][used] = arrival;\n                push([arrival, target, used]);\n            }\n            if (used === 0) {\n                const expressArrival = time + duration;\n                if (expressArrival < best[target][1]) {\n                    best[target][1] = expressArrival;\n                    push([expressArrival, target, 1]);\n                }\n            }\n        }\n    }\n    return -1;\n}",
    "buggy_code": "function entryPoint(n: number, routes: number[][], startTime: number): number {\n    const graph: [number, number, number, number][][] = Array.from({ length: n }, () => []);\n    for (const [u, v, offset, period, duration] of routes) {\n        graph[u].push([v, offset, period, duration]);\n    }\n    const best: number[][] = Array.from({ length: n }, () => [Infinity, Infinity]);\n    best[0][0] = startTime;\n\n    const heap: [number, number, number][] = [[startTime, 0, 0]];\n    function push(item: [number, number, number]): void {\n        heap.push(item);\n        let idx = heap.length - 1;\n        while (idx > 0) {\n            const p = (idx - 1) >> 1;\n            if (heap[idx][0] < heap[p][0]) {\n                const temp = heap[idx];\n                heap[idx] = heap[p];\n                heap[p] = temp;\n                idx = p;\n            } else {\n                break;\n            }\n        }\n    }\n    function pop(): [number, number, number] | undefined {\n        if (heap.length === 0) return undefined;\n        const top = heap[0];\n        const last = heap.pop()!;\n        if (heap.length > 0) {\n            heap[0] = last;\n            let idx = 0;\n            const len = heap.length;\n            while (true) {\n                let left = (idx << 1) + 1;\n                let right = left + 1;\n                let smallest = idx;\n                if (left < len && heap[left][0] < heap[smallest][0]) smallest = left;\n                if (right < len && heap[right][0] < heap[smallest][0]) smallest = right;\n                if (smallest !== idx) {\n                    const temp = heap[idx];\n                    heap[idx] = heap[smallest];\n                    heap[smallest] = temp;\n                    idx = smallest;\n                } else {\n                    break;\n                }\n            }\n        }\n        return top;\n    }\n\n    while (heap.length > 0) {\n        const [time, node, used] = pop()!;\n        if (time !== best[node][used]) {\n            continue;\n        }\n        if (node === n - 1) {\n            return time;\n        }\n        for (const [target, offset, period, duration] of graph[node]) {\n            let departure: number;\n            if (time <= offset) {\n                departure = offset;\n            } else {\n                departure = offset + Math.floor((time - offset + period) / period) * period;\n            }\n            const arrival = departure + duration;\n            if (arrival < best[target][0]) {\n                best[target][0] = arrival;\n                push([arrival, target, 0]);\n            }\n            if (used === 0) {\n                const expressArrival = time + duration;\n                if (expressArrival < best[target][1]) {\n                    best[target][1] = expressArrival;\n                    push([expressArrival, target, 1]);\n                }\n            }\n        }\n    }\n    return -1;\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "An encoding service must cover a text using a sequence of catalog entries. Each entry in `patterns` is `[pattern, cost]`.\n\nA pattern contains lowercase English letters and may contain `?`, which matches exactly one lowercase letter. Applying an entry consumes a consecutive portion of the text whose length equals the pattern's length. Entries must cover the entire text in order, without gaps or overlaps. Every catalog entry may be reused any number of times.\n\nImplement `entryPoint(text, patterns)` to return `[minimumCost, optimalEncodingCount]`. Count optimal encodings modulo `1000000007`.\n\nAn encoding is identified by its ordered sequence of catalog indices. Duplicate catalog rows are distinct choices. Different matching characters for a wildcard do not create additional choices because the text is fixed.\n\nReturn `[-1, 0]` if the text cannot be covered. The empty text has cost `0` and exactly one encoding: the empty sequence.\n\n### Examples\n- Input: `text = \"ab\", patterns = [[\"a\", 2], [\"b\", 3], [\"ab\", 4]]`\n  Output: `[4, 1]`\n- Input: `text = \"ab\", patterns = [[\"a\", 1], [\"b\", 1], [\"??\", 2]]`\n  Output: `[2, 2]`\n  Explanation: Using the first two entries or the third entry gives the same minimum cost.\n\n### Constraints\n- `0 <= text.length <= 2000`\n- `text` contains only lowercase English letters.\n- `0 <= patterns.length <= 200`\n- Each pattern has length between `1` and `30`.\n- `0 <= cost <= 1000000`",
    "fixed_code": "function entryPoint(text: string, patterns: [string, number][]): [number, number] {\n    const children: Record<string, number>[] = [{}];\n    const terminals: number[][] = [[]];\n    for (const [pattern, cost] of patterns) {\n        let node = 0;\n        for (const character of pattern) {\n            if (!(character in children[node])) {\n                children[node][character] = children.length;\n                children.push({});\n                terminals.push([]);\n            }\n            node = children[node][character];\n        }\n        terminals[node].push(cost);\n    }\n    const n = text.length;\n    const best: number[] = new Array(n + 1).fill(Infinity);\n    const ways: number[] = new Array(n + 1).fill(0);\n    best[0] = 0;\n    ways[0] = 1;\n    const modulus = 1000000007;\n\n    for (let start = 0; start < n; start++) {\n        if (best[start] === Infinity) {\n            continue;\n        }\n        let active: number[] = [0];\n        for (let end = start; end < n; end++) {\n            const following: number[] = [];\n            for (const node of active) {\n                for (const character of [text[end], '?']) {\n                    if (character in children[node]) {\n                        following.push(children[node][character]);\n                    }\n                }\n            }\n            active = following;\n            if (active.length === 0) {\n                break;\n            }\n            for (const node of active) {\n                for (const cost of terminals[node]) {\n                    const candidate = best[start] + cost;\n                    if (candidate < best[end + 1]) {\n                        best[end + 1] = candidate;\n                        ways[end + 1] = ways[start];\n                    } else if (candidate === best[end + 1]) {\n                        ways[end + 1] = (ways[end + 1] + ways[start]) % modulus;\n                    }\n                }\n            }\n        }\n    }\n\n    return best[n] === Infinity ? [-1, 0] : [best[n], ways[n]];\n}",
    "buggy_code": "function entryPoint(text: string, patterns: [string, number][]): [number, number] {\n    const children: Record<string, number>[] = [{}];\n    const terminals: number[][] = [[]];\n    for (const [pattern, cost] of patterns) {\n        let node = 0;\n        for (const character of pattern) {\n            if (!(character in children[node])) {\n                children[node][character] = children.length;\n                children.push({});\n                terminals.push([]);\n            }\n            node = children[node][character];\n        }\n        terminals[node].push(cost);\n    }\n    const n = text.length;\n    const best: number[] = new Array(n + 1).fill(Infinity);\n    const ways: number[] = new Array(n + 1).fill(0);\n    best[0] = 0;\n    ways[0] = 1;\n    const modulus = 1000000007;\n\n    for (let start = 0; start < n; start++) {\n        if (best[start] === Infinity) {\n            continue;\n        }\n        let active: number[] = [0];\n        for (let end = start; end < n; end++) {\n            const following: number[] = [];\n            for (const node of active) {\n                for (const character of [text[end], '?']) {\n                    if (character in children[node]) {\n                        following.push(children[node][character]);\n                    }\n                }\n            }\n            active = following;\n            if (active.length === 0) {\n                break;\n            }\n            for (const node of active) {\n                for (const cost of terminals[node]) {\n                    const candidate = best[start] + cost;\n                    if (candidate < best[end + 1]) {\n                        best[end + 1] = candidate;\n                        ways[end + 1] = (ways[end + 1] + ways[start]) % modulus;\n                    } else if (candidate === best[end + 1]) {\n                        ways[end + 1] = ways[start];\n                    }\n                }\n            }\n        }\n    }\n\n    return best[n] === Infinity ? [-1, 0] : [best[n], ways[n]];\n}",
    "tests": [
      {
        "args": [
          "ab",
          [
            [
              "a",
              2
            ],
            [
              "b",
              3
            ],
            [
              "ab",
              4
            ]
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
            [
              "a",
              1
            ],
            [
              "b",
              1
            ],
            [
              "??",
              2
            ]
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
            [
              "?",
              5
            ]
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
            [
              "a",
              1
            ],
            [
              "b",
              1
            ]
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
            [
              "a",
              5
            ],
            [
              "?",
              2
            ]
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
            [
              "a",
              1
            ],
            [
              "a",
              1
            ]
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
            [
              "a",
              1
            ],
            [
              "b",
              1
            ],
            [
              "ab",
              5
            ],
            [
              "??",
              2
            ]
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
            [
              "a",
              0
            ],
            [
              "aa",
              0
            ],
            [
              "?",
              0
            ]
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A laboratory owns `capacity` interchangeable pieces of equipment. Each requested job is `[start, end, profit]` and requires one piece of equipment continuously throughout the half-open interval `[start, end)`.\n\nThe laboratory may accept or reject each job. Accepted jobs cannot be interrupted, and no more than `capacity` accepted jobs may be active at any time. A piece of equipment may be reused immediately when a job ends.\n\nImplement `entryPoint(jobs, capacity)` to return the maximum total profit obtainable.\n\nEach array position represents a separate request, even when multiple requests have identical values. Each request may be accepted at most once. Accepting no jobs is allowed.\n\n### Examples\n- Input: `jobs = [[0, 2, 5], [1, 3, 7]], capacity = 1`\n  Output: `7`\n- Input: `jobs = [[0, 2, 5], [1, 3, 7]], capacity = 2`\n  Output: `12`\n\n### Constraints\n- `0 <= jobs.length <= 500`\n- `1 <= capacity <= 20`\n- `0 <= start < end <= 1000000000`\n- `1 <= profit <= 1000000`\n- Jobs may be unsorted, duplicated, nested, or adjacent.",
    "fixed_code": "function entryPoint(jobs: number[][], capacity: number): number {\n    if (jobs.length === 0) {\n        return 0;\n    }\n    const timeSet = new Set<number>();\n    for (const [start, end] of jobs) {\n        timeSet.add(start);\n        timeSet.add(end);\n    }\n    const times = Array.from(timeSet).sort((a, b) => a - b);\n    const index = new Map<number, number>();\n    times.forEach((time, i) => index.set(time, i));\n\n    const graph: [number, number, number, number][][] = Array.from({ length: times.length }, () => []);\n    function add(u: number, v: number, limit: number, cost: number): void {\n        graph[u].push([v, limit, cost, graph[v].length]);\n        graph[v].push([u, 0, -cost, graph[u].length - 1]);\n    }\n\n    for (let i = 0; i < times.length - 1; i++) {\n        add(i, i + 1, capacity, 0);\n    }\n    for (const [start, end, profit] of jobs) {\n        add(index.get(start)!, index.get(end)!, 1, -profit);\n    }\n\n    let total = 0;\n    let remaining = capacity;\n\n    while (remaining > 0) {\n        const distance: number[] = new Array(times.length).fill(Infinity);\n        const previous: ([number, number] | null)[] = new Array(times.length).fill(null);\n        distance[0] = 0;\n        const queue: number[] = [0];\n        const queued: Set<number> = new Set([0]);\n\n        while (queue.length > 0) {\n            const u = queue.shift()!;\n            queued.delete(u);\n            for (let edgeId = 0; edgeId < graph[u].length; edgeId++) {\n                const [v, limit, cost] = graph[u][edgeId];\n                if (limit > 0 && distance[u] + cost < distance[v]) {\n                    distance[v] = distance[u] + cost;\n                    previous[v] = [u, edgeId];\n                    if (!queued.has(v)) {\n                        queue.push(v);\n                        queued.add(v);\n                    }\n                }\n            }\n        }\n\n        let pushed = remaining;\n        let node = times.length - 1;\n        while (node > 0) {\n            const [u, edgeId] = previous[node]!;\n            pushed = Math.min(pushed, graph[u][edgeId][1]);\n            node = u;\n        }\n\n        node = times.length - 1;\n        while (node > 0) {\n            const [u, edgeId] = previous[node]!;\n            const edge = graph[u][edgeId];\n            edge[1] -= pushed;\n            graph[node][edge[3]][1] += pushed;\n            node = u;\n        }\n\n        remaining -= pushed;\n        total -= pushed * distance[times.length - 1];\n    }\n\n    return total;\n}",
    "buggy_code": "function entryPoint(jobs: number[][], capacity: number): number {\n    if (jobs.length === 0) {\n        return 0;\n    }\n    const timeSet = new Set<number>();\n    for (const [start, end] of jobs) {\n        timeSet.add(start);\n        timeSet.add(end);\n    }\n    const times = Array.from(timeSet).sort((a, b) => a - b);\n    const index = new Map<number, number>();\n    times.forEach((time, i) => index.set(time, i));\n\n    const graph: [number, number, number, number][][] = Array.from({ length: times.length }, () => []);\n    function add(u: number, v: number, limit: number, cost: number): void {\n        graph[u].push([v, limit, cost, graph[v].length]);\n        graph[v].push([u, 0, -cost, graph[u].length - 1]);\n    }\n\n    for (let i = 0; i < times.length - 1; i++) {\n        add(i, i + 1, capacity, 0);\n    }\n    const seen = new Set<string>();\n    const uniqueJobs: number[][] = [];\n    for (const job of jobs) {\n        const key = job.join(',');\n        if (!seen.has(key)) {\n            seen.add(key);\n            uniqueJobs.push(job);\n        }\n    }\n    for (const [start, end, profit] of uniqueJobs) {\n        add(index.get(start)!, index.get(end)!, 1, -profit);\n    }\n\n    let total = 0;\n    let remaining = capacity;\n\n    while (remaining > 0) {\n        const distance: number[] = new Array(times.length).fill(Infinity);\n        const previous: ([number, number] | null)[] = new Array(times.length).fill(null);\n        distance[0] = 0;\n        const queue: number[] = [0];\n        const queued: Set<number> = new Set([0]);\n\n        while (queue.length > 0) {\n            const u = queue.shift()!;\n            queued.delete(u);\n            for (let edgeId = 0; edgeId < graph[u].length; edgeId++) {\n                const [v, limit, cost] = graph[u][edgeId];\n                if (limit > 0 && distance[u] + cost < distance[v]) {\n                    distance[v] = distance[u] + cost;\n                    previous[v] = [u, edgeId];\n                    if (!queued.has(v)) {\n                        queue.push(v);\n                        queued.add(v);\n                    }\n                }\n            }\n        }\n\n        let pushed = remaining;\n        let node = times.length - 1;\n        while (node > 0) {\n            const [u, edgeId] = previous[node]!;\n            pushed = Math.min(pushed, graph[u][edgeId][1]);\n            node = u;\n        }\n\n        node = times.length - 1;\n        while (node > 0) {\n            const [u, edgeId] = previous[node]!;\n            const edge = graph[u][edgeId];\n            edge[1] -= pushed;\n            node = u;\n        }\n\n        remaining -= pushed;\n        total -= pushed * distance[times.length - 1];\n    }\n\n    return total;\n}",
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
    "language": "typescript",
    "entry_point": "entryPoint",
    "signature": null,
    "description": "A financial reconciliation system receives an ordered list of signed adjustments. It must partition the entire list into exactly `groups` nonempty, consecutive batches without changing their order.\n\nFor a batch whose adjustments sum to `s`, its penalty is `(s - target)²`. Positive and negative adjustments may cancel within a batch.\n\nImplement `entryPoint(values, groups, target)` to return the minimum possible sum of batch penalties. Every adjustment must belong to exactly one batch.\n\n### Examples\n- Input: `values = [1, 2], groups = 1, target = 3`\n  Output: `0`\n  Explanation: The single batch sums to the target.\n- Input: `values = [1, 2], groups = 2, target = 2`\n  Output: `1`\n  Explanation: The required batches are [1] and [2], with penalties 1 and 0.\n\n### Constraints\n- `1 <= values.length <= 5000`\n- `1 <= groups <= Math.min(30, values.length)`\n- `-10000 <= values[i], target <= 10000`\n- All inputs are integers.",
    "fixed_code": "function entryPoint(values: number[], groups: number, target: number): number {\n    const prefix: number[] = [0];\n    for (const value of values) {\n        prefix.push(prefix[prefix.length - 1] + value);\n    }\n    const xs = Array.from(new Set(prefix.slice(1).map(value => value - target))).sort((a, b) => a - b);\n    const infinity = Infinity;\n\n    function evaluate(line: [number, number], x: number): number {\n        return line[0] * x + line[1];\n    }\n\n    let tree: ([number, number] | null)[] = [];\n\n    function insert(line: [number, number], node: number, left: number, right: number): void {\n        if (tree[node] === null) {\n            tree[node] = line;\n            return;\n        }\n        const middle = Math.floor((left + right) / 2);\n        const betterLeft = evaluate(line, xs[left]) < evaluate(tree[node]!, xs[left]);\n        const betterMiddle = evaluate(line, xs[middle]) < evaluate(tree[node]!, xs[middle]);\n        if (betterMiddle) {\n            const temp = tree[node]!;\n            tree[node] = line;\n            line = temp;\n        }\n        if (left === right) {\n            return;\n        }\n        if (betterLeft !== betterMiddle) {\n            insert(line, node * 2, left, middle);\n        } else {\n            insert(line, node * 2 + 1, middle + 1, right);\n        }\n    }\n\n    function query(x: number, node: number, left: number, right: number): number {\n        const answer = tree[node] === null ? infinity : evaluate(tree[node]!, x);\n        if (left === right) {\n            return answer;\n        }\n        const middle = Math.floor((left + right) / 2);\n        if (x <= xs[middle]) {\n            return Math.min(answer, query(x, node * 2, left, middle));\n        }\n        return Math.min(answer, query(x, node * 2 + 1, middle + 1, right));\n    }\n\n    let previous: number[] = [0, ...new Array(values.length).fill(infinity)];\n\n    for (let layer = 0; layer < groups; layer++) {\n        tree = new Array(4 * xs.length).fill(null);\n        const current: number[] = new Array(prefix.length).fill(infinity);\n        if (previous[0] !== infinity) {\n            insert([0, previous[0]], 1, 0, xs.length - 1);\n        }\n        for (let end = 1; end < prefix.length; end++) {\n            const x = prefix[end] - target;\n            current[end] = x * x + query(x, 1, 0, xs.length - 1);\n            if (previous[end] !== infinity) {\n                insert([-2 * prefix[end], previous[end] + prefix[end] ** 2], 1, 0, xs.length - 1);\n            }\n        }\n        previous = current;\n    }\n\n    return previous[previous.length - 1];\n}",
    "buggy_code": "function entryPoint(values: number[], groups: number, target: number): number {\n    const prefix: number[] = [0];\n    for (const value of values) {\n        prefix.push(prefix[prefix.length - 1] + value);\n    }\n    const xs = Array.from(new Set(prefix.slice(1).map(value => value - target))).sort((a, b) => a - b);\n    const infinity = Infinity;\n\n    function evaluate(line: [number, number], x: number): number {\n        return line[0] * x + line[1];\n    }\n\n    let tree: ([number, number] | null)[] = [];\n\n    function insert(line: [number, number], node: number, left: number, right: number): void {\n        if (tree[node] === null) {\n            tree[node] = line;\n            return;\n        }\n        const middle = Math.floor((left + right) / 2);\n        const betterLeft = evaluate(line, xs[left]) < evaluate(tree[node]!, xs[left]);\n        const betterMiddle = evaluate(line, xs[middle]) < evaluate(tree[node]!, xs[middle]);\n        if (betterMiddle) {\n            const temp = tree[node]!;\n            tree[node] = line;\n            line = temp;\n        }\n        if (left === right) {\n            return;\n        }\n        if (betterLeft !== betterMiddle) {\n            insert(line, node * 2, left, middle);\n        } else {\n            insert(line, node * 2 + 1, middle + 1, right);\n        }\n    }\n\n    function query(x: number, node: number, left: number, right: number): number {\n        const answer = tree[node] === null ? infinity : evaluate(tree[node]!, x);\n        if (left === right) {\n            return answer;\n        }\n        const middle = Math.floor((left + right) / 2);\n        if (x <= xs[middle]) {\n            return Math.min(answer, query(x, node * 2, left, middle));\n        }\n        return Math.min(answer, query(x, node * 2 + 1, middle + 1, right));\n    }\n\n    let previous: number[] = [0, ...new Array(values.length).fill(infinity)];\n    tree = new Array(4 * xs.length).fill(null);\n\n    for (let layer = 0; layer < groups; layer++) {\n        const current: number[] = new Array(prefix.length).fill(infinity);\n        if (previous[0] !== infinity) {\n            insert([0, previous[0]], 1, 0, xs.length - 1);\n        }\n        for (let end = 1; end < prefix.length; end++) {\n            const x = prefix[end] - target;\n            if (previous[end] !== infinity) {\n                insert([-2 * prefix[end], previous[end] + prefix[end] ** 2], 1, 0, xs.length - 1);\n            }\n            current[end] = x * x + query(x, 1, 0, xs.length - 1);\n        }\n        previous = current;\n    }\n\n    return previous[previous.length - 1];\n}",
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
