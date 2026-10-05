"""Offline checks for the NewsBlur fzf reader; no account is needed."""

import importlib.util
from importlib.machinery import SourceFileLoader
import io
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch


task_path = Path(__file__).parents[1] / "tasks" / "rss"
spec = importlib.util.spec_from_loader("newsblur_reader", SourceFileLoader("newsblur_reader", str(task_path)))
reader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reader)

class ReaderTests(unittest.TestCase):
    def test_folder_tree_and_unfiled_feeds(self):
        data = {
            "feeds": {"2": {"id": 2}, "3": {"id": 3}, "4": {"id": 4}},
            "folders": [{"Tech": [2, {"Deep": [3]}]}],
        }
        self.assertEqual(
            [(folder, feed["id"]) for folder, feed in reader.rows_for_feeds(data)],
            [("Tech", 2), ("Tech/Deep", 3), ("", 4)],
        )

    def test_feed_and_article_extraction(self):
        self.assertEqual(reader.html_text("<p>Hello <b>reader</b></p><script>secret</script>"), "Hello reader")
        source = "<nav>Menu</nav><main><h1>Title</h1><p>Article text</p></main><footer>Ad</footer>"
        self.assertEqual(reader.html_text(source, article_only=True), "Title\n\nArticle text")


    def test_story_page_request(self):
        api = object.__new__(reader.NewsBlur)
        api.request = Mock(return_value={"stories": [{"story_hash": "4:a"}]})
        self.assertEqual(api.stories("4", 2, "all"), [{"story_hash": "4:a"}])
        api.request.assert_called_once_with("/reader/feed/4", params={
            "page": 2, "read_filter": "all", "include_hidden": "false"
        })


    def test_api_response_parses_json(self):
        api = object.__new__(reader.NewsBlur)
        response = io.BytesIO(b'{"feeds": {"4": {"id": 4}}}')
        response.url = "https://www.newsblur.com/reader/feeds"
        opener = Mock()
        opener.open.return_value = response
        api.opener = opener
        self.assertEqual(api.feeds()["feeds"]["4"]["id"], 4)


    def test_chooser_handles_cancel_and_selected_action(self):
        with patch.object(reader.subprocess, "run", return_value=Mock(returncode=1, stdout="", stderr="")):
            self.assertEqual(reader.chooser(["0\tFirst"], header="Pick"), ("escape", []))
        with patch.object(reader.subprocess, "run", return_value=Mock(returncode=0, stdout="ctrl-r\n0\tFirst\n", stderr="")):
            self.assertEqual(reader.chooser(["0\tFirst"], header="Pick"), ("ctrl-r", ["0\tFirst"]))

    def test_chooser_keeps_fzf_config_and_height(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / "fzfrc"
            config.write_text('--bind "tab:down,ctrl-space:toggle"\n--color=dark\n--height="30%"\n--style full\n')
            with patch.dict(reader.os.environ, {"FZF_DEFAULT_OPTS": "--ignore-case --height 40%", "FZF_DEFAULT_OPTS_FILE": str(config)}):
                with patch.object(reader.subprocess, "run", return_value=Mock(returncode=1, stdout="", stderr="")) as run:
                    reader.chooser(["0\tFirst"], header="Pick")
                    self.assertEqual(reader.os.environ["FZF_DEFAULT_OPTS"], "--ignore-case --height 40%")
                    self.assertEqual(reader.os.environ["FZF_DEFAULT_OPTS_FILE"], str(config))
        self.assertNotIn("env", run.call_args.kwargs)
        self.assertFalse(any(arg.startswith("--height") for arg in run.call_args.args[0]))


    def test_enter_opens_rss_html_in_elinks(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog"}}, "folders": [4]}
        api.stories.return_value = [{"story_hash": "4:a", "story_title": "Post", "story_content": "<a href='/link'>Read more</a>"}]
        api.stories.return_value = api.stories.return_value
        choices = iter([("enter", ["0\tBlog"]),
                        ("enter", ["0\tPost"]), ("escape", []), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)), \
             patch.object(reader, "page_text", create=True) as fetch, \
             patch.object(reader, "article_viewer") as viewer:
            reader.run()
        fetch.assert_not_called()
        viewer.assert_called_once_with("Post", "", "<a href='/link'>Read more</a>")


    def test_ctrl_s_refreshes_feed_picker_and_ctrl_q_exits(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog"}}, "folders": [4]}
        choices = iter([("ctrl-s", []), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)):
            reader.run()
        self.assertEqual(api.feeds.call_count, 2)


    def test_ctrl_q_exits_straight_from_story_picker(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog"}}, "folders": [4]}
        api.stories.return_value = [{"story_hash": "4:a", "story_title": "Post"}]
        choices = iter([("enter", ["0\tBlog"]), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)):
            reader.run()

    def test_feed_api_timeout_returns_to_feed_picker_without_marking_read(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Slow site", "nt": 2}}, "folders": [4]}
        api.stories.side_effect = reader.ReaderError("Network error: timed out")
        choices = iter([("enter", ["0\tSlow site"]), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)), \
             patch.object(reader, "show_message") as message:
            reader.run()
        self.assertIn("timed out", message.call_args.args[0])
        api.mark.assert_not_called()


if __name__ == "__main__":
    unittest.main()
