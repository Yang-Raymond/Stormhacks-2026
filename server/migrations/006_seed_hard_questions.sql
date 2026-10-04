-- Applied once by the migration runner, in the same transaction as its tracking record.
-- The first two tests are public examples; remaining tests stay hidden.
INSERT INTO problems (title, description, difficulty, topic, entry_point,
                      buggy_code, fixed_code, tests, visible_test_count)
SELECT title, description, difficulty, topic, entry_point,
       buggy_code, fixed_code, tests, 2
FROM jsonb_to_recordset($questions$
[
  {
    "title": "Audit Temporary Network Links",
    "topic": "offline dynamic connectivity and rollback",
    "description": "A network contains `n` devices numbered from `0` to `n - 1`. Its undirected links are available only during specified time windows.\n\nEach record `[u, v, start, end]` in `links` makes a link available throughout the half-open interval `[start, end)`. Multiple records may describe the same pair of devices; the link is available whenever any corresponding record is active.\n\nEach query `[time, u, v]` asks whether the devices are connected by a path of links that are all available at that time. A device is always connected to itself.\n\nImplement `entry_point(n, links, queries)` to return a list of booleans in the original query order. Neither links nor queries are necessarily sorted.\n\n### Examples\n- Input: `n = 3`, `links = [[0,1,0,5],[1,2,2,4]]`, `queries = [[1,0,2],[3,0,2]]`\n  Output: `[false,true]`\n- Input: `n = 2`, `links = [[0,1,1,3]]`, `queries = [[1,0,1],[3,0,1]]`\n  Output: `[true,false]`\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= len(links), len(queries) <= 30000`\n- All device numbers are valid.\n- Link endpoints are distinct.\n- `0 <= start < end <= 1000000000`\n- Query times are integers between `0` and `1000000000`.",
    "difficulty": "hard",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(n, links, queries):\n    from bisect import bisect_left\n    if not queries:\n        return []\n    times = sorted({q[0] for q in queries})\n    base = 1 << (len(times) - 1).bit_length()\n    tree = [[] for _ in range(2 * base)]\n    for u, v, start, end in links:\n        left = bisect_left(times, start) + base\n        right = bisect_left(times, end) + base\n        while left < right:\n            if left & 1:\n                tree[left].append((u, v))\n                left += 1\n            if right & 1:\n                right -= 1\n                tree[right].append((u, v))\n            left //= 2\n            right //= 2\n    buckets = [[] for _ in range(base)]\n    for i, (time, u, v) in enumerate(queries):\n        buckets[bisect_left(times, time)].append((i, u, v))\n    parent, size, history = list(range(n)), [1] * n, []\n    answer = [False] * len(queries)\n    def find(x):\n        while parent[x] != x:\n            x = parent[x]\n        return x\n    def visit(node):\n        snapshot = len(history)\n        for u, v in tree[node]:\n            a, b = find(u), find(v)\n            if a != b:\n                if size[a] < size[b]:\n                    a, b = b, a\n                history.append((b, a, size[a]))\n                parent[b] = a\n                size[a] += size[b]\n        if node >= base:\n            for i, u, v in buckets[node - base]:\n                answer[i] = find(u) == find(v)\n        else:\n            visit(2 * node)\n            visit(2 * node + 1)\n        while len(history) > snapshot:\n            b, a, old_size = history.pop()\n            parent[b], size[a] = b, old_size\n    visit(1)\n    return answer",
    "buggy_code": "def entry_point(n, links, queries):\n    from bisect import bisect_left, bisect_right\n    if not queries:\n        return []\n    times = sorted({q[0] for q in queries})\n    base = 1 << (len(times) - 1).bit_length()\n    tree = [[] for _ in range(2 * base)]\n    for u, v, start, end in links:\n        left = bisect_left(times, start) + base\n        right = bisect_right(times, end) + base\n        while left < right:\n            if left & 1:\n                tree[left].append((u, v))\n                left += 1\n            if right & 1:\n                right -= 1\n                tree[right].append((u, v))\n            left //= 2\n            right //= 2\n    buckets = [[] for _ in range(base)]\n    for i, (time, u, v) in enumerate(queries):\n        buckets[bisect_left(times, time)].append((i, u, v))\n    parent, size, history = list(range(n)), [1] * n, []\n    answer = [False] * len(queries)\n    def find(x):\n        while parent[x] != x:\n            parent[x] = parent[parent[x]]\n            x = parent[x]\n        return x\n    def visit(node):\n        snapshot = len(history)\n        for u, v in tree[node]:\n            a, b = find(u), find(v)\n            if a != b:\n                if size[a] < size[b]:\n                    a, b = b, a\n                history.append((b, a, size[a]))\n                parent[b] = a\n                size[a] += size[b]\n        if node >= base:\n            for i, u, v in buckets[node - base]:\n                answer[i] = find(u) == find(v)\n        else:\n            visit(2 * node)\n            visit(2 * node + 1)\n        while len(history) > snapshot:\n            b, a, old_size = history.pop()\n            parent[b], size[a] = b, old_size\n    visit(1)\n    return answer",
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
    "description": "A shipment starts at depot `0` at `start_time` and must reach depot `n - 1`.\n\nEach directed route is `[u, v, offset, period, duration]`. Regular vehicles depart depot `u` at times `offset + k * period` for every integer `k >= 0`, and take `duration` time units to reach depot `v`. A shipment arriving exactly at a departure time may board that vehicle. Waiting at depots is allowed.\n\nThe shipment has one express dispatch voucher. At most once during the entire journey, it may traverse any listed route immediately, ignoring its departure schedule but still taking that route's full travel duration. This is allowed even before the route's first regular departure.\n\nImplement `entry_point(n, routes, start_time)` to return the earliest absolute arrival time at depot `n - 1`, or `-1` if it is unreachable. The voucher does not need to be used.\n\n### Examples\n- Input: `n = 2`, `routes = [[0,1,10,5,3]]`, `start_time = 0`\n  Output: `3`\n  Explanation: An express dispatch leaves immediately.\n- Input: `n = 3`, `routes = [[0,1,0,10,2],[1,2,5,10,2]]`, `start_time = 0`\n  Output: `4`\n  Explanation: Take the first regular departure, then use the voucher.\n\n### Constraints\n- `1 <= n <= 20000`\n- `0 <= len(routes) <= 50000`\n- Routes use valid, distinct endpoints. Parallel routes and directed cycles are allowed.\n- `0 <= offset, start_time <= 1000000000`\n- `1 <= period, duration <= 1000000`",
    "difficulty": "hard",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(n, routes, start_time):\n    import heapq\n    graph = [[] for _ in range(n)]\n    for u, v, offset, period, duration in routes:\n        graph[u].append((v, offset, period, duration))\n    best = [[float('inf')] * 2 for _ in range(n)]\n    best[0][0] = start_time\n    queue = [(start_time, 0, 0)]\n    while queue:\n        time, node, used = heapq.heappop(queue)\n        if time != best[node][used]:\n            continue\n        if node == n - 1:\n            return time\n        for target, offset, period, duration in graph[node]:\n            if time <= offset:\n                departure = offset\n            else:\n                departure = offset + ((time - offset + period - 1) // period) * period\n            arrival = departure + duration\n            if arrival < best[target][used]:\n                best[target][used] = arrival\n                heapq.heappush(queue, (arrival, target, used))\n            if used == 0:\n                express_arrival = time + duration\n                if express_arrival < best[target][1]:\n                    best[target][1] = express_arrival\n                    heapq.heappush(queue, (express_arrival, target, 1))\n    return -1",
    "buggy_code": "def entry_point(n, routes, start_time):\n    import heapq\n    graph = [[] for _ in range(n)]\n    for u, v, offset, period, duration in routes:\n        graph[u].append((v, offset, period, duration))\n    best = [[float('inf')] * 2 for _ in range(n)]\n    best[0][0] = start_time\n    queue = [(start_time, 0, 0)]\n    while queue:\n        time, node, used = heapq.heappop(queue)\n        if time != best[node][used]:\n            continue\n        if node == n - 1:\n            return time\n        for target, offset, period, duration in graph[node]:\n            if time <= offset:\n                departure = offset\n            else:\n                departure = offset + ((time - offset + period) // period) * period\n            arrival = departure + duration\n            if arrival < best[target][0]:\n                best[target][0] = arrival\n                heapq.heappush(queue, (arrival, target, 0))\n            if used == 0:\n                express_arrival = time + duration\n                if express_arrival < best[target][1]:\n                    best[target][1] = express_arrival\n                    heapq.heappush(queue, (express_arrival, target, 1))\n    return -1",
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
    "description": "An encoding service must cover a text using a sequence of catalog entries. Each entry in `patterns` is `[pattern, cost]`.\n\nA pattern contains lowercase English letters and may contain `?`, which matches exactly one lowercase letter. Applying an entry consumes a consecutive portion of the text whose length equals the pattern's length. Entries must cover the entire text in order, without gaps or overlaps. Every catalog entry may be reused any number of times.\n\nImplement `entry_point(text, patterns)` to return `[minimum_cost, optimal_encoding_count]`. Count optimal encodings modulo `1000000007`.\n\nAn encoding is identified by its ordered sequence of catalog indices. Duplicate catalog rows are distinct choices. Different matching characters for a wildcard do not create additional choices because the text is fixed.\n\nReturn `[-1, 0]` if the text cannot be covered. The empty text has cost `0` and exactly one encoding: the empty sequence.\n\n### Examples\n- Input: `text = \"ab\"`, `patterns = [[\"a\",2],[\"b\",3],[\"ab\",4]]`\n  Output: `[4,1]`\n- Input: `text = \"ab\"`, `patterns = [[\"a\",1],[\"b\",1],[\"??\",2]]`\n  Output: `[2,2]`\n  Explanation: Using the first two entries or the third entry gives the same minimum cost.\n\n### Constraints\n- `0 <= len(text) <= 2000`\n- `text` contains only lowercase English letters.\n- `0 <= len(patterns) <= 200`\n- Each pattern has length between `1` and `30`.\n- `0 <= cost <= 1000000`",
    "difficulty": "hard",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(text, patterns):\n    children = [{}]\n    terminals = [[]]\n    for pattern, cost in patterns:\n        node = 0\n        for character in pattern:\n            if character not in children[node]:\n                children[node][character] = len(children)\n                children.append({})\n                terminals.append([])\n            node = children[node][character]\n        terminals[node].append(cost)\n    n = len(text)\n    infinity = float('inf')\n    best, ways = [infinity] * (n + 1), [0] * (n + 1)\n    best[0], ways[0] = 0, 1\n    modulus = 1000000007\n    for start in range(n):\n        if best[start] == infinity:\n            continue\n        active = [0]\n        for end in range(start, n):\n            following = []\n            for node in active:\n                for character in (text[end], '?'):\n                    if character in children[node]:\n                        following.append(children[node][character])\n            active = following\n            if not active:\n                break\n            for node in active:\n                for cost in terminals[node]:\n                    candidate = best[start] + cost\n                    if candidate < best[end + 1]:\n                        best[end + 1] = candidate\n                        ways[end + 1] = ways[start]\n                    elif candidate == best[end + 1]:\n                        ways[end + 1] = (ways[end + 1] + ways[start]) % modulus\n    return [-1, 0] if best[n] == infinity else [best[n], ways[n]]",
    "buggy_code": "def entry_point(text, patterns):\n    children = [{}]\n    terminals = [[]]\n    for pattern, cost in patterns:\n        node = 0\n        for character in pattern:\n            if character not in children[node]:\n                children[node][character] = len(children)\n                children.append({})\n                terminals.append([])\n            node = children[node][character]\n        terminals[node].append(cost)\n    n = len(text)\n    infinity = float('inf')\n    best, ways = [infinity] * (n + 1), [0] * (n + 1)\n    best[0], ways[0] = 0, 1\n    modulus = 1000000007\n    for start in range(n):\n        if best[start] == infinity:\n            continue\n        active = [0]\n        for end in range(start, n):\n            following = []\n            for node in active:\n                for character in (text[end], '?'):\n                    if character in children[node]:\n                        following.append(children[node][character])\n            active = following\n            if not active:\n                break\n            for node in active:\n                for cost in terminals[node]:\n                    candidate = best[start] + cost\n                    if candidate < best[end + 1]:\n                        best[end + 1] = candidate\n                        ways[end + 1] = (ways[end + 1] + ways[start]) % modulus\n                    elif candidate == best[end + 1]:\n                        ways[end + 1] = ways[start]\n    return [-1, 0] if best[n] == infinity else [best[n], ways[n]]",
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
    "description": "A laboratory owns `capacity` interchangeable pieces of equipment. Each requested job is `[start, end, profit]` and requires one piece of equipment continuously throughout the half-open interval `[start, end)`.\n\nThe laboratory may accept or reject each job. Accepted jobs cannot be interrupted, and no more than `capacity` accepted jobs may be active at any time. A piece of equipment may be reused immediately when a job ends.\n\nImplement `entry_point(jobs, capacity)` to return the maximum total profit obtainable.\n\nEach list position represents a separate request, even when multiple requests have identical values. Each request may be accepted at most once. Accepting no jobs is allowed.\n\n### Examples\n- Input: `jobs = [[0,2,5],[1,3,7]]`, `capacity = 1`\n  Output: `7`\n- Input: `jobs = [[0,2,5],[1,3,7]]`, `capacity = 2`\n  Output: `12`\n\n### Constraints\n- `0 <= len(jobs) <= 500`\n- `1 <= capacity <= 20`\n- `0 <= start < end <= 1000000000`\n- `1 <= profit <= 1000000`\n- Jobs may be unsorted, duplicated, nested, or adjacent.",
    "difficulty": "hard",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(jobs, capacity):\n    from collections import deque\n    if not jobs:\n        return 0\n    times = sorted({time for start, end, profit in jobs for time in (start, end)})\n    index = {time: i for i, time in enumerate(times)}\n    graph = [[] for _ in times]\n    def add(u, v, limit, cost):\n        graph[u].append([v, limit, cost, len(graph[v])])\n        graph[v].append([u, 0, -cost, len(graph[u]) - 1])\n    for i in range(len(times) - 1):\n        add(i, i + 1, capacity, 0)\n    for start, end, profit in jobs:\n        add(index[start], index[end], 1, -profit)\n    total = 0\n    remaining = capacity\n    while remaining:\n        distance = [float('inf')] * len(times)\n        previous = [None] * len(times)\n        distance[0] = 0\n        queue, queued = deque([0]), {0}\n        while queue:\n            u = queue.popleft()\n            queued.remove(u)\n            for edge_id, (v, limit, cost, reverse) in enumerate(graph[u]):\n                if limit and distance[u] + cost < distance[v]:\n                    distance[v] = distance[u] + cost\n                    previous[v] = (u, edge_id)\n                    if v not in queued:\n                        queue.append(v)\n                        queued.add(v)\n        pushed, node = remaining, len(times) - 1\n        while node:\n            u, edge_id = previous[node]\n            pushed = min(pushed, graph[u][edge_id][1])\n            node = u\n        node = len(times) - 1\n        while node:\n            u, edge_id = previous[node]\n            edge = graph[u][edge_id]\n            edge[1] -= pushed\n            graph[node][edge[3]][1] += pushed\n            node = u\n        remaining -= pushed\n        total -= pushed * distance[-1]\n    return total",
    "buggy_code": "def entry_point(jobs, capacity):\n    from collections import deque\n    if not jobs:\n        return 0\n    times = sorted({time for start, end, profit in jobs for time in (start, end)})\n    index = {time: i for i, time in enumerate(times)}\n    graph = [[] for _ in times]\n    def add(u, v, limit, cost):\n        graph[u].append([v, limit, cost, len(graph[v])])\n        graph[v].append([u, 0, -cost, len(graph[u]) - 1])\n    for i in range(len(times) - 1):\n        add(i, i + 1, capacity, 0)\n    for start, end, profit in set(map(tuple, jobs)):\n        add(index[start], index[end], 1, -profit)\n    total = 0\n    remaining = capacity\n    while remaining:\n        distance = [float('inf')] * len(times)\n        previous = [None] * len(times)\n        distance[0] = 0\n        queue, queued = deque([0]), {0}\n        while queue:\n            u = queue.popleft()\n            queued.remove(u)\n            for edge_id, (v, limit, cost, reverse) in enumerate(graph[u]):\n                if limit and distance[u] + cost < distance[v]:\n                    distance[v] = distance[u] + cost\n                    previous[v] = (u, edge_id)\n                    if v not in queued:\n                        queue.append(v)\n                        queued.add(v)\n        pushed, node = remaining, len(times) - 1\n        while node:\n            u, edge_id = previous[node]\n            pushed = min(pushed, graph[u][edge_id][1])\n            node = u\n        node = len(times) - 1\n        while node:\n            u, edge_id = previous[node]\n            edge = graph[u][edge_id]\n            edge[1] -= pushed\n            node = u\n        remaining -= pushed\n        total -= pushed * distance[-1]\n    return total",
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
    "description": "A financial reconciliation system receives an ordered list of signed adjustments. It must partition the entire list into exactly `groups` nonempty, consecutive batches without changing their order.\n\nFor a batch whose adjustments sum to `s`, its penalty is `(s - target)\u00b2`. Positive and negative adjustments may cancel within a batch.\n\nImplement `entry_point(values, groups, target)` to return the minimum possible sum of batch penalties. Every adjustment must belong to exactly one batch.\n\n### Examples\n- Input: `values = [1,2]`, `groups = 1`, `target = 3`\n  Output: `0`\n  Explanation: The single batch sums to the target.\n- Input: `values = [1,2]`, `groups = 2`, `target = 2`\n  Output: `1`\n  Explanation: The required batches are `[1]` and `[2]`, with penalties `1` and `0`.\n\n### Constraints\n- `1 <= len(values) <= 5000`\n- `1 <= groups <= min(30, len(values))`\n- `-10000 <= values[i], target <= 10000`\n- All inputs are integers.",
    "difficulty": "hard",
    "entry_point": "entry_point",
    "fixed_code": "def entry_point(values, groups, target):\n    prefix = [0]\n    for value in values:\n        prefix.append(prefix[-1] + value)\n    xs = sorted({value - target for value in prefix[1:]})\n    infinity = float('inf')\n    def evaluate(line, x):\n        return line[0] * x + line[1]\n    def insert(line, node, left, right):\n        if tree[node] is None:\n            tree[node] = line\n            return\n        middle = (left + right) // 2\n        better_left = evaluate(line, xs[left]) < evaluate(tree[node], xs[left])\n        better_middle = evaluate(line, xs[middle]) < evaluate(tree[node], xs[middle])\n        if better_middle:\n            tree[node], line = line, tree[node]\n        if left == right:\n            return\n        if better_left != better_middle:\n            insert(line, node * 2, left, middle)\n        else:\n            insert(line, node * 2 + 1, middle + 1, right)\n    def query(x, node, left, right):\n        answer = infinity if tree[node] is None else evaluate(tree[node], x)\n        if left == right:\n            return answer\n        middle = (left + right) // 2\n        if x <= xs[middle]:\n            return min(answer, query(x, node * 2, left, middle))\n        return min(answer, query(x, node * 2 + 1, middle + 1, right))\n    previous = [0] + [infinity] * len(values)\n    for layer in range(groups):\n        tree = [None] * (4 * len(xs))\n        current = [infinity] * len(prefix)\n        if previous[0] != infinity:\n            insert((0, previous[0]), 1, 0, len(xs) - 1)\n        for end in range(1, len(prefix)):\n            x = prefix[end] - target\n            current[end] = x * x + query(x, 1, 0, len(xs) - 1)\n            if previous[end] != infinity:\n                insert((-2 * prefix[end], previous[end] + prefix[end] ** 2), 1, 0, len(xs) - 1)\n        previous = current\n    return previous[-1]",
    "buggy_code": "def entry_point(values, groups, target):\n    prefix = [0]\n    for value in values:\n        prefix.append(prefix[-1] + value)\n    xs = sorted({value - target for value in prefix[1:]})\n    infinity = float('inf')\n    def evaluate(line, x):\n        return line[0] * x + line[1]\n    def insert(line, node, left, right):\n        if tree[node] is None:\n            tree[node] = line\n            return\n        middle = (left + right) // 2\n        better_left = evaluate(line, xs[left]) < evaluate(tree[node], xs[left])\n        better_middle = evaluate(line, xs[middle]) < evaluate(tree[node], xs[middle])\n        if better_middle:\n            tree[node], line = line, tree[node]\n        if left == right:\n            return\n        if better_left != better_middle:\n            insert(line, node * 2, left, middle)\n        else:\n            insert(line, node * 2 + 1, middle + 1, right)\n    def query(x, node, left, right):\n        answer = infinity if tree[node] is None else evaluate(tree[node], x)\n        if left == right:\n            return answer\n        middle = (left + right) // 2\n        if x <= xs[middle]:\n            return min(answer, query(x, node * 2, left, middle))\n        return min(answer, query(x, node * 2 + 1, middle + 1, right))\n    previous = [0] + [infinity] * len(values)\n    tree = [None] * (4 * len(xs))\n    for layer in range(groups):\n        current = [infinity] * len(prefix)\n        if previous[0] != infinity:\n            insert((0, previous[0]), 1, 0, len(xs) - 1)\n        for end in range(1, len(prefix)):\n            x = prefix[end] - target\n            if previous[end] != infinity:\n                insert((-2 * prefix[end], previous[end] + prefix[end] ** 2), 1, 0, len(xs) - 1)\n            current[end] = x * x + query(x, 1, 0, len(xs) - 1)\n        previous = current\n    return previous[-1]",
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
$questions$::jsonb) AS question(
  title text, topic text, description text, difficulty text, entry_point text,
  fixed_code text, buggy_code text, tests jsonb
);
