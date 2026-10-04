import tempfile
import unittest

import harness
import languages
import server


class GradingTests(unittest.TestCase):
    def test_integer_comparison_is_exact(self):
        for actual, expected in [(1000001, 1000000), (2**60 + 1, 2**60)]:
            self.assertFalse(languages.matches(actual, expected))
            self.assertFalse(languages.matches([actual], [expected]))
        self.assertTrue(languages.matches(1.0000001, 1.0))
        self.assertTrue(languages.matches(1, 1.0))

    def test_python_booleans_are_not_numbers(self):
        for actual, expected in [(True, 1), (False, 0), ([True], [1]), ({'x': False}, {'x': 0})]:
            self.assertFalse(harness.matches(actual, expected))
        result = server.run({'code': 'def f(): return {"x": [True]}', 'entry_point': 'f',
                             'tests': [{'args': [], 'expected': {'x': [1]}}]})
        self.assertEqual(result['status'], 'ok')
        self.assertFalse(result['results'][0]['passed'])
        self.assertTrue(harness.matches({'x': [True, 1]}, {'x': [True, 1]}))

    def test_output_flood_is_bounded(self):
        for fd in (1, 2):
            with tempfile.NamedTemporaryFile(mode='w', suffix='.py') as script:
                script.write(f'import os\nwhile True: os.write({fd}, b"x" * 65536)\n')
                script.flush()
                report, failure = server.spawn(script.name, {}, 4096)
            self.assertIsNone(report)
            self.assertEqual(failure['status'], 'error')
            self.assertLessEqual(len(failure['error']), 2000)

    def test_trace_output_can_exceed_old_file_limit(self):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py') as script:
            script.write('import json\nprint(json.dumps({"value": "x" * (2 * 1024 * 1024)}))\n')
            script.flush()
            report, failure = server.spawn(script.name, {}, server.MAX_TRACE_OUTPUT_BYTES)
        self.assertIsNone(failure)
        self.assertEqual(len(report['value']), 2 * 1024 * 1024)


if __name__ == '__main__':
    unittest.main()
