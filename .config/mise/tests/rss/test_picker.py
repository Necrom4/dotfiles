"""RSS reader picker regressions; no account or network required."""

import io
import json
import sys
import tempfile
import threading
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).parents[2] / "lib"))
from rss_reader import app as reader
from rss_reader import cli
from rss_reader.sources.newsblur import NewsBlurSource

CONFIG = {
    "id": "account",
    "type": "newsblur",
    "title": "NewsBlur",
    "url": "https://www.newsblur.com",
}
ATOM = b"""<feed xmlns="http://www.w3.org/2005/Atom"><title>Activity</title><entry><id>event-1</id><title>New event</title><published>2026-10-09T12:00:00Z</published><link href="/events/1"/><summary>Fallback</summary><content type="html">&lt;p&gt;Hello&lt;/p&gt;</content></entry></feed>"""
RSS = b"""<rss version="2.0"><channel><title>News</title><item><guid>item-1</guid><title>News item</title><link>https://example.com/news</link><description>News body</description></item></channel></rss>"""


class LivePickerTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory()
        self.addCleanup(self.scratch.cleanup)
        self.api = Mock()
        self.story = {"story_hash": "4:a", "story_title": "Post", "read_status": 0}
        self.collection = reader.StoryCollection(self.api, "4", [self.story])
        self.collection.complete = True
        self.stream = reader.StoryStream(
            self.collection, Path(self.scratch.name), "all", title="Blog"
        )
        self.live = reader.LivePicker(self.stream, 80)
        self.addCleanup(self.live.close)

    def test_read_action_is_queued_without_accepting_or_calling_network(self):
        binding = self.live.binding("ctrl-r")
        self.assertIn("execute-silent", binding)
        self.assertNotIn("accept", binding)
        self.assertNotIn("--expect", binding)
        self.assertNotIn("python", binding)
        path = self.live.directory / "action.queued.ready"
        path.write_text(f"ctrl-r\n{self.stream.directory / '0'}\n")
        self.live.gather()
        self.api.mark.assert_not_called()
        self.assertEqual(self.live.actions.commands.get_nowait(), ("ctrl-r", [0]))
        self.live.actions.commands.task_done()

    def test_start_does_not_prefetch_history(self):
        self.collection.complete = False
        with patch.object(self.live, "notify", return_value=True):
            self.live.start()
            self.live.close()
        self.api.stories.assert_not_called()

    def test_scroll_only_requests_one_page_when_near_bottom(self):
        self.collection.complete = False
        path = self.live.directory / "action.scroll.ready"
        path.write_text("page\n2\n20\n")
        self.live.gather()
        self.assertFalse(self.live.page_requested.is_set())
        for _ in range(3):
            path.write_text("page\n18\n20\n")
            self.live.gather()
        self.assertTrue(self.live.page_requested.is_set())
        self.api.stories.assert_not_called()

    def test_scroll_during_fetch_or_after_exhaustion_does_not_request_more(self):
        self.collection.complete = False
        self.live.loading.set()
        path = self.live.directory / "action.scroll.ready"
        path.write_text("page\n20\n20\n")
        self.live.gather()
        self.assertFalse(self.live.page_requested.is_set())
        self.live.loading.clear()
        self.collection.complete = True
        path.write_text("page\n20\n20\n")
        self.live.gather()
        self.assertFalse(self.live.page_requested.is_set())

    def test_empty_unread_or_search_results_can_request_more_on_scroll(self):
        self.collection.complete = False
        path = self.live.directory / "action.scroll.ready"
        path.write_text("page\n0\n0\n")
        self.live.gather()
        self.assertTrue(self.live.page_requested.is_set())

    def test_scroll_binding_does_not_require_a_row_or_accept_fzf(self):
        binding = self.live.page_binding("down", "down")
        self.assertIn("down:down+execute-silent", binding)
        self.assertIn("FZF_MATCH_COUNT", binding)
        self.assertNotIn("{1}", binding)
        self.assertNotIn("accept", binding)

    def test_foreground_pump_loads_one_page_and_disables_wraparound(self):
        self.collection.complete = False
        self.api.stories.return_value = [{"story_hash": "4:b", "read_status": 0}]
        self.live.page_requested.set()
        process = Mock()
        process.communicate.side_effect = [
            reader.subprocess.TimeoutExpired("fzf", 0.1),
            ("ctrl-q\n", ""),
        ]
        process.wait.return_value = 0
        process.poll.return_value = 0
        with (
            patch.object(reader.subprocess, "Popen", return_value=process) as launch,
            patch.object(self.live, "start"),
        ):
            self.live.run(["fzf"], "enter,ctrl-q", {})
        self.api.stories.assert_called_once_with("4", 2, "all")
        self.assertEqual(len(self.collection.stories), 2)
        self.assertFalse(self.live.page_requested.is_set())
        args = launch.call_args.args[0]
        self.assertIn("--no-cycle", args)
        self.assertIn("--layout=reverse", args)
        self.assertIn("--no-tac", args)
        self.assertFalse(any("focus:" in arg and "page" in arg for arg in args))

    def test_confirmed_mark_updates_snapshot_without_refetching(self):
        self.live.actions.apply("ctrl-r", [0])
        self.api.mark.assert_called_once_with(["4:a"], unread=False)
        self.assertEqual(self.story["read_status"], 1)
        self.assertTrue(self.live.refresh())
        self.assertNotIn("●", self.live.list_file.read_text())
        self.api.stories.assert_not_called()

    def test_failed_mark_preserves_status_and_displays_error(self):
        self.api.mark.side_effect = reader.ReaderError("timed out")
        self.live.actions.apply("ctrl-r", [0])
        self.assertEqual(self.story["read_status"], 0)
        self.live.refresh()
        self.assertIn("●", self.live.list_file.read_text())
        self.assertIn("timed out", self.live.header_file.read_text())

    def test_slow_request_does_not_block_snapshot_updater(self):
        started, release = threading.Event(), threading.Event()

        def mark(*args, **kwargs):
            started.set()
            release.wait(2)

        self.api.mark.side_effect = mark
        actor = threading.Thread(target=self.live.actions.apply, args=("ctrl-r", [0]))
        actor.start()
        try:
            self.assertTrue(started.wait(1))
            self.assertTrue(self.live.refresh())
            self.assertIn("Saving", self.live.header_file.read_text())
            self.assertIn("●", self.live.list_file.read_text())
        finally:
            release.set()
            actor.join(2)
        self.assertEqual(self.story["read_status"], 1)

    def test_filter_changes_without_requests_or_changed_ids(self):
        self.live.actions.apply("ctrl-r", [0])
        path = self.live.directory / "action.filter.ready"
        path.write_text("ctrl-f\n")
        self.live.gather()
        self.live.refresh()
        self.assertEqual(self.stream.read_filter, "unread")
        self.assertEqual(self.live.list_file.read_text(), "")
        self.api.stories.assert_not_called()

    def test_filter_binding_does_not_require_a_matching_row(self):
        self.assertNotIn("{+1}", self.live.binding("ctrl-f"))
        self.assertIn("{+1}", self.live.binding("ctrl-r"))

    def test_partial_failure_updates_only_confirmed_stories(self):
        self.collection.add([{"story_hash": "4:b", "read_status": 0}])
        self.api.mark.side_effect = reader.MarkError("Story too old", ["4:a"])
        self.live.actions.apply("ctrl-u", [0, 1])
        message, failed = self.live.actions.status()
        self.assertTrue(failed)
        self.assertIn("1 confirmed", message)
        self.assertIn("Story too old", message)
        self.assertEqual(self.collection.overrides, {"4:a": 0})

    def test_api_owns_batching_instead_of_the_action_worker(self):
        self.collection.add(
            [{"story_hash": f"4:{index}", "read_status": 0} for index in range(51)]
        )
        self.live.actions.apply("ctrl-r", list(range(52)))
        self.assertEqual(self.api.mark.call_count, 1)
        self.assertEqual(len(self.api.mark.call_args.args[0]), 52)

    def test_invalid_indexes_are_ignored_and_duplicates_are_marked_once(self):
        self.live.actions.apply("ctrl-r", [-1, 0, 0, 99])
        self.api.mark.assert_called_once_with(["4:a"], unread=False)

    def test_unfinished_action_files_and_foreign_paths_are_ignored(self):
        (self.live.directory / "action.incomplete").write_text("ctrl-r\n")
        (self.live.directory / "action.foreign.ready").write_text("ctrl-r\n/other/0\n")
        self.live.gather()
        self.assertTrue(self.live.actions.commands.empty())

    def test_snapshot_file_io_does_not_hold_collection_lock(self):
        self.collection.mark([self.story], unread=False)
        acquired = threading.Event()

        def render(index, story):
            def check_lock():
                with self.collection.condition:
                    acquired.set()

            worker = threading.Thread(target=check_lock)
            worker.start()
            try:
                self.assertTrue(acquired.wait(1))
            finally:
                worker.join(1)
            return "0\tPost"

        with patch.object(self.stream, "row", side_effect=render):
            self.live.refresh()

    def test_snapshot_is_independent_of_subsequent_read_state_changes(self):
        snapshot = self.collection.snapshot("all")
        self.collection.mark([self.story], unread=False)
        self.assertEqual(snapshot.stories[0][1]["read_status"], 0)

    def test_unchanged_refresh_does_not_copy_or_render_stories(self):
        with (
            patch.object(self.collection, "snapshot") as snapshot,
            patch.object(self.stream, "row") as render,
        ):
            self.assertFalse(self.live.refresh())
        snapshot.assert_not_called()
        render.assert_not_called()

    def test_header_uses_explicit_title_not_parsed_display_text(self):
        self.stream.title = "Blog · unread · Special"
        self.collection.mark([self.story], unread=False)
        self.live.refresh()
        header = " ".join(self.live.header_file.read_text().split())
        self.assertIn("Blog · unread · Special · all ·", header)

    def test_close_waits_for_accepted_mutations(self):
        started, release, finished = (threading.Event() for _ in range(3))

        def mark(*args, **kwargs):
            started.set()
            release.wait(2)

        self.api.mark.side_effect = mark
        self.live.actions.commands.put(("ctrl-r", [0]))
        self.live.start()
        self.assertTrue(started.wait(1))

        def close():
            self.live.close()
            finished.set()

        closer = threading.Thread(target=close)
        closer.start()
        try:
            self.assertFalse(finished.wait(0.1))
        finally:
            release.set()
            closer.join(2)
        self.assertTrue(finished.is_set())
        self.assertEqual(self.story["read_status"], 1)
        self.assertFalse(self.live.directory.exists())

    def test_worker_survives_unexpected_action_failure(self):
        self.api.mark.side_effect = [RuntimeError("unexpected"), None]
        self.live.actions.commands.put(("ctrl-u", [0]))
        self.live.actions.commands.put(("ctrl-r", [0]))
        self.live.actions.start()
        self.live.actions.close()
        self.assertEqual(self.api.mark.call_count, 2)
        self.assertEqual(self.story["read_status"], 1)

    def test_updater_failure_aborts_instead_of_leaving_a_stale_picker(self):
        with (
            patch.object(self.live, "gather", side_effect=OSError("disk error")),
            patch.object(self.live, "notify", return_value=True) as notify,
        ):
            self.live.update()
        self.assertIn("disk error", self.live.error)
        notify.assert_called_once_with("abort")

    def test_close_cleans_files_and_drains_actions_even_if_gather_fails(self):
        self.live.actions.commands.put(("ctrl-r", [0]))
        self.live.actions.start()
        with patch.object(self.live, "gather", side_effect=OSError("disk error")):
            self.live.close()
        self.api.mark.assert_called_once_with(["4:a"], unread=False)
        self.assertFalse(self.live.directory.exists())
        self.assertIn("disk error", self.live.error)

    def test_mark_loaded_preserves_newly_published_unread_stories(self):
        self.collection.complete = False
        self.collection.mark_loaded_read()
        self.api.stories.side_effect = [[{"story_hash": "4:new", "read_status": 0}], []]
        self.collection.load()
        self.assertEqual(self.collection.stories[1]["read_status"], 0)

    def test_mark_loaded_read_leaves_later_history_unread(self):
        self.collection.complete = False
        self.collection.mark_loaded_read()
        self.api.mark.assert_called_once_with(["4:a"], unread=False)
        self.api.stories.assert_not_called()
        self.api.stories.return_value = [{"story_hash": "4:older", "read_status": 0}]
        self.collection.load()
        self.assertEqual(self.collection.stories[1]["read_status"], 0)

    def test_mark_loaded_read_only_sends_unread_loaded_ids(self):
        self.collection.add([{"story_hash": "4:read", "read_status": 1}])
        self.collection.mark_loaded_read()
        self.api.mark.assert_called_once_with(["4:a"], unread=False)
        self.api.stories.assert_not_called()
        self.api.mark_feed.assert_not_called()
        self.collection.mark_loaded_read()
        self.assertEqual(self.api.mark.call_count, 1)

    def test_mark_loaded_read_retains_only_confirmed_changes_on_failure(self):
        self.collection.add([{"story_hash": "4:b", "read_status": 0}])
        self.api.mark.side_effect = reader.MarkError("Rejected second story", ["4:a"])
        with self.assertRaises(reader.MarkError):
            self.collection.mark_loaded_read()
        self.assertEqual(
            [story["read_status"] for story in self.collection.stories], [1, 0]
        )


class ApiAndPreviewTests(unittest.TestCase):
    def test_expected_actions_survive_fzf_no_match_exit_status(self):
        for key in ("ctrl-q", "ctrl-o"):
            with (
                self.subTest(key=key),
                patch.object(
                    reader.subprocess,
                    "run",
                    return_value=Mock(
                        returncode=1, stdout=f"query\n{key}\n", stderr=""
                    ),
                ),
            ):
                state = {}
                self.assertEqual(
                    reader.chooser([], header="Pick", state=state), (key, [])
                )
                self.assertEqual(state["query"], "query")

    def test_conflicting_acknowledgments_do_not_confirm_rejected_ids(self):
        accepted, error = NewsBlurSource.mark_acknowledgments(
            [
                {"code": 1, "story_hash": "4:a"},
                {"code": -1, "story_hash": "4:a", "message": "Rejected"},
            ],
            ["4:a"],
        )
        self.assertEqual(accepted, [])
        self.assertEqual(error, "Rejected")

    def test_malformed_acknowledgments_fail_without_crashing(self):
        for result in ([None], [{"code": 1, "story_hash": []}], [], None):
            with self.subTest(result=result):
                accepted, error = NewsBlurSource.mark_acknowledgments(result, ["4:a"])
                self.assertEqual(accepted, [])
                self.assertTrue(error)

    def test_foreground_marks_also_record_partial_acknowledgments(self):
        api = Mock()
        stories = [
            {"story_hash": "4:a", "read_status": 0},
            {"story_hash": "4:b", "read_status": 0},
        ]
        collection = reader.StoryCollection(api, "4", stories)
        api.mark.side_effect = reader.MarkError("Partial", ["4:a"])
        with self.assertRaises(reader.MarkError):
            collection.mark_confirmed(stories, unread=False)
        self.assertEqual([story["read_status"] for story in stories], [1, 0])

    def test_offline_option_is_rejected_before_any_login(self):
        with (
            patch.object(cli.app, "run") as run,
            patch.object(reader.sys, "stderr", io.StringIO()),
            self.assertRaises(SystemExit) as result,
        ):
            cli.main(["--offline"])
        self.assertEqual(result.exception.code, 2)
        run.assert_not_called()

    def test_revisiting_feed_revalidates_membership(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog"}},
            "folders": [4],
        }
        api.stories.side_effect = [[{"story_hash": "4:old"}], [{"story_hash": "4:new"}]]
        choices = iter(
            [
                ("enter", ["0\tTop Level"]),
                ("enter", ["0\tBlog"]),
                ("escape", []),
                ("enter", ["0\tBlog"]),
                ("ctrl-q", []),
            ]
        )
        visible = []
        directories = []

        def choose(*args, **kwargs):
            if kwargs.get("stream"):
                stream = kwargs["stream"]
                visible.append(
                    [story["story_hash"] for story in stream.collection.stories]
                )
                directories.append(stream.directory)
            return next(choices)

        with (
            patch.object(reader, "create", return_value=api),
            patch.object(reader, "chooser", side_effect=choose),
        ):
            reader.run_source(CONFIG)
        self.assertEqual(visible, [["4:old"], ["4:new"]])
        self.assertEqual(api.stories.call_count, 2)
        self.assertTrue(all(not path.exists() for path in directories))

    def test_preview_reuse_is_limited_to_one_visit(self):
        story = {"story_hash": "4:a", "story_content": "Body"}
        with patch.object(reader, "feed_preview", return_value="Rendered") as render:
            for _ in range(2):
                with tempfile.TemporaryDirectory() as directory:
                    path = Path(directory) / "0"
                    path.write_text(json.dumps(story))
                    self.assertEqual(reader.lazy_preview(path), "Rendered")
                    self.assertEqual(reader.lazy_preview(path), "Rendered")
            self.assertEqual(render.call_count, 2)

    def test_atomic_write_leaves_original_file_intact_on_publication_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "snapshot"
            path.write_text("Original")
            with (
                patch.object(Path, "replace", side_effect=OSError("disk error")),
                self.assertRaises(OSError),
            ):
                reader.atomic_write(path, "Replacement")
            self.assertEqual(path.read_text(), "Original")
            self.assertEqual(list(Path(directory).iterdir()), [path])


class FeedSessionTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory()
        self.addCleanup(self.scratch.cleanup)
        self.api = Mock()
        self.session = reader.FeedSession(
            self.api, "4", [{"story_hash": "4:a"}], Path(self.scratch.name)
        )
        self.addCleanup(self.session.__exit__)

    def test_successful_refresh_replaces_history_and_discards_old_previews(self):
        previous = self.session.collection
        directory = self.session.directory
        (directory / "0.preview").write_text("Old preview")
        self.api.stories.return_value = [{"story_hash": "4:new"}]
        self.session.refresh()
        self.assertTrue(previous.cancel.is_set())
        self.assertFalse(directory.exists())
        self.assertNotEqual(self.session.directory, directory)
        self.assertEqual(self.session.collection.stories, [{"story_hash": "4:new"}])

    def test_failed_refresh_preserves_history_and_previews(self):
        previous = self.session.collection
        directory = self.session.directory
        preview = directory / "0.preview"
        preview.write_text("Usable preview")
        self.api.stories.side_effect = reader.ReaderError("timeout")
        with self.assertRaises(reader.ReaderError):
            self.session.refresh()
        self.assertIs(self.session.collection, previous)
        self.assertFalse(previous.cancel.is_set())
        self.assertEqual(preview.read_text(), "Usable preview")

    def test_preview_allocation_failure_does_not_discard_usable_history(self):
        previous = self.session.collection
        self.api.stories.return_value = [{"story_hash": "4:new"}]
        with (
            patch.object(
                reader.tempfile, "TemporaryDirectory", side_effect=OSError("disk full")
            ),
            self.assertRaises(OSError),
        ):
            self.session.refresh()
        self.assertIs(self.session.collection, previous)
        self.assertTrue(self.session.directory.exists())

    def test_exit_closes_history_and_removes_visit_files(self):
        directory = self.session.directory
        self.session.__exit__()
        self.assertTrue(self.session.collection.cancel.is_set())
        self.assertFalse(directory.exists())
