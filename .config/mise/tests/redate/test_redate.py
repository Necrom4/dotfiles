"""Offline checks for complexity-based commit spacing; never rewrite history."""

import importlib.util
import random
import unittest
from importlib.machinery import SourceFileLoader
from pathlib import Path
from unittest.mock import patch

task_path = Path(__file__).parents[2] / "tasks/git/redate"
spec = importlib.util.spec_from_loader(
    "redate", SourceFileLoader("redate", str(task_path))
)
redate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(redate)


class ComplexityTests(unittest.TestCase):
    def points(self, adds=0, dels=0, path="src/main.py", words=0):
        return redate.complexity([(str(adds), str(dels), path)], words)[0]

    def test_substantial_changes_get_far_more_time_than_one_line(self):
        tiny = self.points(adds=1)
        self.assertGreater(self.points(adds=100), tiny * 25)
        self.assertGreater(self.points(adds=500), tiny * 100)

    def test_size_is_monotonic_but_sublinear(self):
        small = self.points(adds=20)
        large = self.points(adds=2000)
        self.assertGreater(large, small * 30)
        self.assertLess(large, small * 100)

    def test_rewrites_cost_more_than_additions_and_deletions(self):
        self.assertGreater(self.points(adds=20, dels=20), self.points(adds=20))
        self.assertGreater(self.points(adds=20), self.points(dels=20))

    def test_message_body_cannot_dominate_a_tiny_edit(self):
        plain = self.points(adds=1)
        verbose = self.points(adds=1, words=10000)
        self.assertGreater(verbose, plain)
        self.assertLessEqual(verbose, plain * 1.3)
        self.assertLess(verbose, self.points(adds=10))

    def test_generated_changes_are_capped_and_have_little_file_overhead(self):
        generated = self.points(adds=100000, path="package-lock.json")
        self.assertLess(generated, self.points(adds=1))
        self.assertEqual(generated, self.points(adds=1000000, path="package-lock.json"))
        code = [("10", "0", "src/main.py")]
        with_lock = code + [("100000", "0", "package-lock.json")]
        self.assertLess(
            redate.complexity(with_lock)[0], redate.complexity(code)[0] * 1.1
        )

    def test_real_files_still_add_context_switching_cost(self):
        one_file = redate.complexity([("20", "0", "main.py")])[0]
        two_files = redate.complexity([("10", "0", "a.py"), ("10", "0", "b.py")])[0]
        self.assertGreater(two_files, one_file)

    def test_empty_binary_and_merge_scores_stay_positive(self):
        self.assertGreater(redate.complexity([])[0], 0)
        self.assertGreater(redate.complexity([("-", "-", "image.png")])[0], 0)
        self.assertGreater(redate.complexity([], merge=True)[0], 0)

    def test_jitter_cannot_make_a_one_line_edit_look_like_a_large_change(self):
        rng = random.Random(42)
        scores = [self.points(adds=1), self.points(adds=500)]
        gaps = [s * rng.uniform(1 - redate.JITTER, 1 + redate.JITTER) for s in scores]
        allocated = [gap / sum(gaps) * (3 * 3600) for gap in gaps]
        self.assertLess(allocated[0], 180)
        self.assertGreater(allocated[1], allocated[0] * 60)

    def test_score_reads_git_stats_and_message_body(self):
        with patch.object(
            redate,
            "git",
            side_effect=[
                "abc parent",
                "Explain the new behavior",
                "1\t0\tconfig.toml\n10000\t0\tpackage-lock.json",
            ],
        ) as git:
            result = redate.score("abc")
        self.assertEqual(
            result,
            redate.complexity(
                [("1", "0", "config.toml"), ("10000", "0", "package-lock.json")],
                words=4,
            ),
        )
        self.assertEqual(git.call_count, 3)

    def test_gap_labels_make_seconds_visible(self):
        self.assertEqual(redate.gap_label(32), "+32s")
        self.assertEqual(redate.gap_label(61), "+1m01s")
        self.assertEqual(redate.gap_label(3661), "+1h01m")


if __name__ == "__main__":
    unittest.main()
