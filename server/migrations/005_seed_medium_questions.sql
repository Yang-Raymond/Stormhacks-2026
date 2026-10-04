-- Applied once by the migration runner, in the same transaction as its tracking record.
-- The first two tests are public examples; remaining tests stay hidden.
INSERT INTO problems (title, description, difficulty, topic, entry_point,
                      buggy_code, fixed_code, tests, visible_test_count)
SELECT title, description, difficulty, topic, entry_point,
       buggy_code, fixed_code, tests, 2
FROM jsonb_to_recordset($questions$
[
  {
    "title": "Select a Contiguous Audit Sample",
    "topic": "sliding window and hash maps",
    "description": "An audit system stores events in chronological order. Each event has a category and a nonnegative review cost.\n\nImplement entry_point(categories, costs, budget, category_limit) to return the maximum number of consecutive events that can be selected while satisfying both rules:\n\n- Their total review cost is at most budget.\n- No category appears more than category_limit times.\n\nReturn 0 if no nonempty selection is valid. The input lists have equal lengths, and their matching positions describe the same event.\n\n### Examples\n- Input: categories = [\"a\", \"b\", \"a\"], costs = [2, 1, 2], budget = 5, category_limit = 2\n  Output: 3\n- Input: categories = [\"a\", \"a\", \"b\"], costs = [1, 1, 1], budget = 3, category_limit = 1\n  Output: 2\n\n### Constraints\n- 0 <= len(categories) == len(costs) <= 100000\n- Categories are nonempty lowercase English strings of length at most 20.\n- 0 <= costs[i] <= 10000\n- 0 <= budget <= 1000000000\n- 1 <= category_limit <= 100000",
    "difficulty": "medium",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(categories, costs, budget, category_limit):\n    counts = {}\n    left = 0\n    total = 0\n    best = 0\n    for right, category in enumerate(categories):\n        counts[category] = counts.get(category, 0) + 1\n        total += costs[right]\n        while total > budget or counts[category] > category_limit:\n            departing = categories[left]\n            counts[departing] -= 1\n            total -= costs[left]\n            left += 1\n        length = right - left + 1\n        best = max(best, length)\n    return best",
    "buggy_code": "def entry_point(categories, costs, budget, category_limit):\n    counts = {}\n    left = 0\n    total = 0\n    best = 0\n    for right, category in enumerate(categories):\n        counts[category] = counts.get(category, 0) + 1\n        total += costs[right]\n        if total > budget or counts[category] > category_limit:\n            departing = categories[left]\n            counts[departing] -= 1\n            total -= costs[left]\n            left += 1\n        length = right - left + 1\n        best = max(best, length)\n    return best",
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
    "description": "A search box accepts a small query language. Implement entry_point(query) to return its tokens in order according to these rules:\n\n- Ordinary ASCII spaces separate tokens when outside double quotes.\n- Double quotes toggle quoted mode and are omitted from the token. Spaces inside quotes are preserved.\n- A backslash escapes the next character, inside or outside quotes. The escaped character is added literally, and the backslash is omitted.\n- Adjacent quoted and unquoted portions belong to the same token unless separated by an unquoted, unescaped space.\n- Empty quoted portions count as a token when standing alone.\n- Leading, trailing, and repeated separator spaces do not create tokens.\n\n### Examples\n- Input: query = 'red \"blue sky\"'\n  Output: [\"red\", \"blue sky\"]\n- Input: query = 'a\"b c\"d'\n  Output: [\"ab cd\"]\n\n### Constraints\n- 0 <= len(query) <= 100000\n- The query contains printable ASCII characters.\n- Every backslash has a following character.\n- Unescaped double quotes are balanced.",
    "difficulty": "medium",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(query):\n    tokens = []\n    current = []\n    quoted = False\n    active = False\n    i = 0\n    while i < len(query):\n        character = query[i]\n        if character == '\\\\':\n            i += 1\n            current.append(query[i])\n            active = True\n        elif character == '\"':\n            quoted = not quoted\n            active = True\n        elif character == ' ' and not quoted:\n            if active:\n                tokens.append(''.join(current))\n                current = []\n                active = False\n        else:\n            current.append(character)\n            active = True\n        i += 1\n    if active:\n        tokens.append(''.join(current))\n    return tokens",
    "buggy_code": "def entry_point(query):\n    tokens = []\n    current = []\n    quoted = False\n    active = False\n    i = 0\n    while i < len(query):\n        character = query[i]\n        if character == '\\\\' and quoted:\n            i += 1\n            current.append(query[i])\n            active = True\n        elif character == '\"':\n            quoted = not quoted\n            active = True\n        elif character == ' ' and not quoted:\n            if active:\n                tokens.append(''.join(current))\n                current = []\n                active = False\n        else:\n            current.append(character)\n            active = True\n        i += 1\n    if active:\n        tokens.append(''.join(current))\n    return tokens",
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
    "description": "A data platform must run n export jobs, numbered from 0 to n - 1. Job i takes durations[i] time units and cannot start before time release_times[i].\n\nEach dependency [before, after] means that job after must wait until job before finishes. A job must wait for all its prerequisites. Unlimited workers are available, so unrelated jobs may run simultaneously. Jobs begin as soon as their release times and dependencies permit.\n\nImplement entry_point(durations, release_times, dependencies) to return a list containing the earliest finish time of every job, in job-number order. The dependency graph is guaranteed to have no cycles.\n\n### Examples\n- Input: durations = [2, 3], release_times = [0, 0], dependencies = [[0, 1]]\n  Output: [2, 5]\n- Input: durations = [2, 1], release_times = [5, 0], dependencies = []\n  Output: [7, 1]\n\n### Constraints\n- 0 <= n <= 10000\n- len(durations) == len(release_times) == n\n- 1 <= durations[i] <= 1000000\n- 0 <= release_times[i] <= 1000000000\n- There are at most 50000 dependencies.\n- Dependencies use valid, distinct job numbers, and duplicate dependency pairs do not occur.",
    "difficulty": "medium",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(durations, release_times, dependencies):\n    from collections import deque\n    n = len(durations)\n    outgoing = [[] for _ in range(n)]\n    remaining = [0] * n\n    for before, after in dependencies:\n        outgoing[before].append(after)\n        remaining[after] += 1\n    starts = list(release_times)\n    finishes = [0] * n\n    ready = deque(i for i in range(n) if remaining[i] == 0)\n    while ready:\n        job = ready.popleft()\n        finishes[job] = starts[job] + durations[job]\n        for child in outgoing[job]:\n            starts[child] = max(starts[child], finishes[job])\n            remaining[child] -= 1\n            if remaining[child] == 0:\n                ready.append(child)\n    return finishes",
    "buggy_code": "def entry_point(durations, release_times, dependencies):\n    from collections import deque\n    n = len(durations)\n    outgoing = [[] for _ in range(n)]\n    remaining = [0] * n\n    for before, after in dependencies:\n        outgoing[before].append(after)\n        remaining[after] += 1\n    starts = list(release_times)\n    finishes = [0] * n\n    ready = deque(i for i in range(n) if remaining[i] == 0)\n    while ready:\n        job = ready.popleft()\n        finishes[job] = starts[job] + durations[job]\n        for child in outgoing[job]:\n            starts[child] = max(release_times[child], finishes[job])\n            remaining[child] -= 1\n            if remaining[child] == 0:\n                ready.append(child)\n    return finishes",
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
    "description": "A facility receives resource reservations. Each reservation is [start, end, units] and uses units resources throughout the half-open time interval [start, end). Simultaneous reservations add their resource usage.\n\nImplement entry_point(reservations, threshold) to return the total duration during which combined resource usage is at least threshold.\n\nCount elapsed time only once, regardless of how many reservations overlap. Reservations may be unsorted, duplicated, nested, or adjacent. Usage is zero outside all reservations.\n\n### Examples\n- Input: reservations = [[0, 4, 2], [2, 6, 3]], threshold = 4\n  Output: 2\n  Explanation: Usage reaches at least 4 only during [2, 4).\n- Input: reservations = [[1, 5, 3]], threshold = 3\n  Output: 4\n\n### Constraints\n- 0 <= len(reservations) <= 100000\n- 0 <= start < end <= 1000000000\n- 1 <= units <= 1000000\n- 1 <= threshold <= 100000000000",
    "difficulty": "medium",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(reservations, threshold):\n    changes = {}\n    for start, end, units in reservations:\n        changes[start] = changes.get(start, 0) + units\n        changes[end] = changes.get(end, 0) - units\n    active = 0\n    previous = None\n    duration = 0\n    for time in sorted(changes):\n        if previous is not None and active >= threshold:\n            duration += time - previous\n        active += changes[time]\n        previous = time\n    return duration",
    "buggy_code": "def entry_point(reservations, threshold):\n    changes = {}\n    for start, end, units in reservations:\n        changes[start] = changes.get(start, 0) + units\n        changes[end] = changes.get(end, 0) - units\n    active = 0\n    previous = None\n    duration = 0\n    for time in sorted(changes):\n        if previous is not None and active > threshold:\n            duration += time - previous\n        active += changes[time]\n        previous = time\n    return duration",
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
    "description": "A print shop must process jobs in their existing order. Each job has a positive intensity value. The shop partitions the jobs into nonempty, consecutive batches containing at most max_batch jobs each.\n\nThe cost of a batch is:\n\nsetup_cost + (number of jobs in the batch) * (maximum intensity in the batch)\n\nEvery job must belong to exactly one batch. Jobs cannot be reordered.\n\nImplement entry_point(intensities, max_batch, setup_cost) to return the minimum total cost. Return 0 when there are no jobs.\n\n### Examples\n- Input: intensities = [2, 2], max_batch = 2, setup_cost = 3\n  Output: 7\n  Explanation: One batch costs 3 + 2 * 2 = 7.\n- Input: intensities = [1, 10], max_batch = 2, setup_cost = 2\n  Output: 15\n  Explanation: Separate batches cost (2 + 1) + (2 + 10) = 15.\n\n### Constraints\n- 0 <= len(intensities) <= 1000\n- 1 <= intensities[i] <= 10000\n- 1 <= max_batch <= 100\n- 0 <= setup_cost <= 10000",
    "difficulty": "medium",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(intensities, max_batch, setup_cost):\n    n = len(intensities)\n    dp = [0] * (n + 1)\n    for end in range(1, n + 1):\n        peak = intensities[end - 1]\n        best = dp[end - 1] + setup_cost + peak\n        for length in range(1, min(max_batch, end) + 1):\n            peak = max(peak, intensities[end - length])\n            candidate = dp[end - length] + setup_cost + length * peak\n            best = min(best, candidate)\n        dp[end] = best\n    return dp[n]",
    "buggy_code": "def entry_point(intensities, max_batch, setup_cost):\n    n = len(intensities)\n    dp = [0] * (n + 1)\n    for end in range(1, n + 1):\n        peak = intensities[end - 1]\n        best = dp[end - 1] + setup_cost + peak\n        for length in range(1, min(max_batch, end)):\n            peak = max(peak, intensities[end - length])\n            candidate = dp[end - length] + setup_cost + length * peak\n            best = min(best, candidate)\n        dp[end] = best\n    return dp[n]",
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
  }
]
$questions$::jsonb) AS question(
  title text, topic text, description text, difficulty text, entry_point text,
  fixed_code text, buggy_code text, tests jsonb
);
