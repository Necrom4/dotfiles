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

    def test_folder_groups_keep_top_level_and_nested_paths_distinct(self):
        data = {"feeds": {"2": {"id": 2}, "3": {"id": 3}, "4": {"id": 4}},
                "folders": [{"Tech": [2, {"Deep": [3]}]}]}
        self.assertEqual([(folder, [feed["id"] for feed in feeds])
                          for folder, feeds in reader.rows_for_folders(data)],
                         [("", [4]), ("Tech", [2]), ("Tech/Deep", [3])])

    def test_folder_picker_previews_feeds_and_back_returns_to_folders(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"2": {"id": 2, "feed_title": "Tech Blog", "nt": 2},
                      "3": {"id": 3, "feed_title": "Other Blog", "ps": 1},
                      "4": {"id": 4, "feed_title": "Unfiled Blog"}},
            "folders": [{"Tech": [2, 3]}, 4],
        }
        actions = iter([("enter", 1), ("escape", None), ("enter", 0), ("ctrl-q", None)])
        screens = []
        previews = []

        def choose(lines, **kwargs):
            screens.append((lines, kwargs["header"]))
            if kwargs["preview"]:
                previews.append([Path(line.split("\t", 1)[0]).read_text() for line in lines])
            key, index = next(actions)
            return key, [lines[index]] if index is not None else []

        with patch.object(reader, "NewsBlur", return_value=api), patch.object(reader, "chooser", side_effect=choose):
            reader.run()
        self.assertIn("Top Level", screens[0][0][0])
        self.assertIn("Tech  (3 unread)", screens[0][0][1])
        self.assertIn("Tech Blog  (2 unread)", previews[0][1])
        self.assertIn("Other Blog  (1 unread)", previews[0][1])
        self.assertEqual(screens[1][0], ["0\tTech Blog  (2 unread)", "1\tOther Blog  (1 unread)"])
        self.assertEqual(screens[2][1].splitlines()[0], "NewsBlur · folders")
        self.assertEqual(screens[3][0], ["0\tUnfiled Blog  (0 unread)"])
        api.first_page_with_unread.assert_not_called()
        api.mark.assert_not_called()

    def test_article_fragment_preserves_links_and_void_tags(self):
        fragment = reader.ArticleFragment()
        fragment.feed('<nav>Skip</nav><article><h1>Story</h1><p><a href="https://example.com">Link</a><br>Next</p></article><footer>Skip</footer>')
        result = "".join(fragment.parts)
        self.assertIn('href="https://example.com"', result)
        self.assertIn("<br>", result)
        self.assertNotIn("Skip", result)

    def test_mark_batches_read_and_unread(self):
        api = object.__new__(reader.NewsBlur)
        api.request = Mock(return_value={"code": 1})
        hashes = [f"1:{i}" for i in range(51)]
        api.mark(hashes, unread=False)
        self.assertEqual(api.request.call_count, 2)
        self.assertEqual(len(api.request.call_args_list[0].kwargs["data"]), 50)
        api.mark(["1:0", "1:1"], unread=True)
        self.assertEqual(api.request.call_args.args[0], "/reader/mark_story_hash_as_unread")

    def test_story_page_request(self):
        api = object.__new__(reader.NewsBlur)
        api.request = Mock(return_value={"stories": [{"story_hash": "4:a"}]})
        self.assertEqual(api.stories("4", 2, "all"), [{"story_hash": "4:a"}])
        api.request.assert_called_once_with("/reader/feed/4", params={
            "page": 2, "read_filter": "all", "include_hidden": "false"
        })

    def test_first_page_includes_older_unread_without_duplicate_recent_stories(self):
        api = object.__new__(reader.NewsBlur)
        api.stories = Mock(side_effect=[
            [{"story_hash": "4:read"}, {"story_hash": "4:new"}],
            [{"story_hash": "4:new"}, {"story_hash": "4:older"}, {"story_hash": "4:oldest"}],
        ])
        self.assertEqual([story["story_hash"] for story in api.first_page_with_unread("4", expected_unread=3)],
                         ["4:read", "4:new", "4:older", "4:oldest"])
        self.assertEqual(api.stories.call_args_list[1].args, ("4", 1, "unread"))

    def test_first_page_skips_extra_request_if_all_unread_are_present(self):
        api = object.__new__(reader.NewsBlur)
        api.stories = Mock(return_value=[{"story_hash": "4:new", "read_status": 0},
                                         {"story_hash": "4:older", "read_status": 0}])
        self.assertEqual(len(api.first_page_with_unread("4", expected_unread=2)), 2)
        api.stories.assert_called_once_with("4", 1, "all")

    def test_api_response_parses_json(self):
        api = object.__new__(reader.NewsBlur)
        response = io.BytesIO(b'{"feeds": {"4": {"id": 4}}}')
        response.url = "https://www.newsblur.com/reader/feeds"
        opener = Mock()
        opener.open.return_value = response
        api.opener = opener
        self.assertEqual(api.feeds()["feeds"]["4"]["id"], 4)

    def test_feed_counts_are_recalculated(self):
        api = object.__new__(reader.NewsBlur)
        api.request = Mock(return_value={"feeds": {}})
        api.feeds()
        api.request.assert_called_once_with("/reader/feeds", params={
            "include_favicons": "false", "update_counts": "true"
        })

    def test_rejects_private_or_non_http_story_urls(self):
        for url in ("file:///etc/passwd", "http://127.0.0.1/", "http://user:pass@example.com/"):
            with self.subTest(url=url), self.assertRaises(reader.ReaderError):
                reader.safe_page_url(url)

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

    def test_chooser_wraps_hints_to_list_width(self):
        with patch.object(reader.shutil, "get_terminal_size", return_value=reader.os.terminal_size((120, 40))), \
             patch.object(reader.subprocess, "run", return_value=Mock(returncode=1, stdout="", stderr="")) as run:
            reader.chooser(["0\tFirst"], header="ctrl-t RSS · ctrl-o browser · ctrl-r/u read/unread", preview="cat {1}")
        args = run.call_args.args[0]
        header = args[args.index("--header") + 1]
        self.assertTrue(all(len(line) <= 42 for line in header.splitlines()))
        self.assertIn("ctrl-r/u read/unread", " ".join(header.split()))

    def test_html_view_preserves_links_and_escapes_title(self):
        document = reader.article_document('News <Today>', 'https://example.com/a?x=1&y=2', '<p><a href="/read">Article</a></p>')
        self.assertIn('News &lt;Today&gt;', document)
        self.assertIn('href="/read"', document)
        self.assertIn('<base href=', document)
        self.assertIn('x=1&amp;y=2', document)

    def test_full_page_preserves_article_links_not_navigation(self):
        response = io.BytesIO(b'<nav>Skip</nav><article><p>Read the <a href="/post">entire original story</a>.</p></article>')
        response.headers = Mock()
        response.headers.get_content_type.return_value = "text/html"
        response.headers.get_content_charset.return_value = "utf-8"
        opener = Mock()
        opener.open.return_value = response
        with patch.object(reader, "safe_page_url"), patch.object(reader.urllib.request, "build_opener", return_value=opener):
            article = reader.page_text("https://example.com/post")
        self.assertIn('href="/post"', article)
        self.assertNotIn("Skip", article)

    def test_open_marks_read_but_preview_does_not(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog", "ps": 1}}, "folders": [4]}
        api.stories.return_value = [{"story_hash": "4:a", "story_title": "Post", "story_content": "<p>Body</p>"}]
        api.first_page_with_unread.return_value = api.stories.return_value
        choices = iter([("enter", ["0\tTop Level"]), ("enter", ["0\tBlog"]),
                        ("ctrl-o", ["0\tPost"]), ("escape", []), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)), \
             patch.object(reader, "page_text", return_value="<p>Full original story</p>"), \
             patch.object(reader, "article_viewer") as viewer, \
             patch.object(reader.tempfile, "TemporaryDirectory", wraps=tempfile.TemporaryDirectory):
            reader.run()
        api.mark.assert_called_once_with(["4:a"], unread=False)
        viewer.assert_called_once_with("Post", "", "<p>Full original story</p>")

    def test_enter_opens_rss_html_in_elinks(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog"}}, "folders": [4]}
        api.stories.return_value = [{"story_hash": "4:a", "story_title": "Post", "story_content": "<a href='/link'>Read more</a>"}]
        api.first_page_with_unread.return_value = api.stories.return_value
        choices = iter([("enter", ["0\tTop Level"]), ("enter", ["0\tBlog"]),
                        ("enter", ["0\tPost"]), ("escape", []), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)), \
             patch.object(reader, "page_text") as fetch, \
             patch.object(reader, "article_viewer") as viewer:
            reader.run()
        fetch.assert_not_called()
        viewer.assert_called_once_with("Post", "", "<a href='/link'>Read more</a>")

    def test_alt_o_opens_only_article_url_in_browser(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog"}}, "folders": [4]}
        api.stories.return_value = [{"story_hash": "4:a", "story_title": "Post", "story_permalink": "https://example.com/post"}]
        api.first_page_with_unread.return_value = api.stories.return_value
        choices = iter([("enter", ["0\tTop Level"]), ("enter", ["0\tBlog"]),
                        ("alt-o", ["0\tPost"]), ("escape", []), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)), \
             patch.object(reader.webbrowser, "open", return_value=True) as open_browser, \
             patch.object(reader, "page_text") as fetch:
            reader.run()
        open_browser.assert_called_once_with("https://example.com/post")
        fetch.assert_not_called()

    def test_fzf_preview_renders_links_with_elinks(self):
        with tempfile.TemporaryDirectory() as directory:
            preview = Path(directory) / "article.html"
            result = reader.feed_preview({"story_title": "Post", "story_permalink": "https://example.com/post",
                                          "story_content": '<p><a href="https://example.com/link">Linked text</a></p>'}, preview)
        self.assertIn("Linked text", result)
        if reader.shutil.which("elinks"):
            self.assertIn("\x1b[", result)


    def test_elinks_uses_portable_clipboard_launcher(self):
        with patch.object(reader.shutil, "which", return_value="/usr/bin/tool"), \
             patch.object(reader.subprocess, "run") as run:
            reader.article_viewer("Post", "https://example.com/post", '<a href="/link">Link</a>')
        command = run.call_args.args[0]
        self.assertEqual(command[:2], [str(Path.home() / ".config/elinks/clipboard"), "open"])
        self.assertNotIn("-eval", command)

    def test_mark_read_keeps_story_visible_without_refetching(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog", "ps": 1}}, "folders": [4]}
        api.stories.return_value = [{"story_hash": "4:a", "story_title": "Post", "story_content": "<p>Body</p>", "read_status": 0}]
        api.first_page_with_unread.return_value = api.stories.return_value
        choices = iter([("enter", ["0\tTop Level"]), ("enter", ["0\tBlog"]),
                        ("ctrl-r", ["0\tPost"]), ("escape", []), ("ctrl-q", [])])
        headers = []

        def choose(*args, **kwargs):
            headers.append(kwargs["header"])
            return next(choices)

        with patch.object(reader, "NewsBlur", return_value=api), patch.object(reader, "chooser", side_effect=choose):
            reader.run()
        api.first_page_with_unread.assert_called_once_with("4", expected_unread=1)
        self.assertEqual(api.stories.return_value[0]["read_status"], 1)
        self.assertEqual(headers[2].splitlines()[0], "Blog · all, page 1")
        self.assertNotIn("Enter story", headers[2])
        self.assertNotIn("ctrl-q", headers[2])
        self.assertNotIn("Esc", headers[2])
        self.assertNotIn("ctrl-space", headers[2])
        self.assertIn("ctrl-r/u read/unread", headers[2])

    def test_ctrl_s_refreshes_feed_picker_and_ctrl_q_exits(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog"}}, "folders": [4]}
        choices = iter([("ctrl-s", []), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)):
            reader.run()
        self.assertEqual(api.feeds.call_count, 2)

    def test_ctrl_f_toggles_unread_filter(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog"}}, "folders": [4]}
        api.first_page_with_unread.return_value = []
        api.stories.return_value = []
        choices = iter([("enter", ["0\tTop Level"]), ("enter", ["0\tBlog"]),
                        ("ctrl-f", []), ("ctrl-f", []), ("ctrl-q", [])])
        headers = []

        def choose(*args, **kwargs):
            headers.append(kwargs["header"])
            return next(choices)

        with patch.object(reader, "NewsBlur", return_value=api), patch.object(reader, "chooser", side_effect=choose):
            reader.run()
        api.stories.assert_called_once_with("4", 1, "unread")
        self.assertEqual(headers[3].splitlines()[0], "Blog · unread, page 1")
        self.assertEqual(headers[4].splitlines()[0], "Blog · all, page 1")
        api.mark_feed.assert_not_called()

    def test_alt_r_marks_whole_feed_only_after_confirmation(self):
        for answer in ("n", "y"):
            with self.subTest(answer=answer):
                api = Mock()
                api.login.return_value = None
                api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog"}}, "folders": [4]}
                api.first_page_with_unread.return_value = []
                choices = iter([("enter", ["0\tTop Level"]), ("enter", ["0\tBlog"]),
                                ("alt-r", []), ("ctrl-q", [])])
                with patch.object(reader, "NewsBlur", return_value=api), \
                     patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)), \
                     patch("builtins.input", return_value=answer):
                    reader.run()
                if answer == "y":
                    api.mark_feed.assert_called_once_with("4")
                else:
                    api.mark_feed.assert_not_called()

    def test_page_navigation_reuses_cached_pages_and_stops_at_page_one(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog"}}, "folders": [4]}
        api.first_page_with_unread.return_value = []
        api.stories.return_value = []
        choices = iter([("enter", ["0\tTop Level"]), ("enter", ["0\tBlog"]),
                        ("alt-n", []), ("alt-p", []), ("alt-p", []), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)):
            reader.run()
        api.first_page_with_unread.assert_called_once_with("4", expected_unread=0)
        api.stories.assert_called_once_with("4", 2, "all")

    def test_returning_to_feeds_updates_counts_without_marking_read(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog", "nt": 2}}, "folders": [4]}
        api.first_page_with_unread.return_value = [{"story_hash": "4:a", "story_title": "Post", "read_status": 1}]
        choices = iter([("enter", ["0\tTop Level"]), ("enter", ["0\tBlog"]), ("escape", []), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)), \
             patch.object(reader, "feed_preview", return_value="Body"):
            reader.run()
        self.assertEqual(api.feeds.call_count, 2)
        api.mark.assert_not_called()

    def test_ctrl_q_exits_straight_from_story_picker(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Blog"}}, "folders": [4]}
        api.first_page_with_unread.return_value = [{"story_hash": "4:a", "story_title": "Post"}]
        choices = iter([("enter", ["0\tTop Level"]), ("enter", ["0\tBlog"]), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)):
            reader.run()

    def test_feed_api_timeout_returns_to_feed_picker_without_marking_read(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {"feeds": {"4": {"id": 4, "feed_title": "Slow site", "nt": 2}}, "folders": [4]}
        api.first_page_with_unread.side_effect = reader.ReaderError("Network error: timed out")
        choices = iter([("enter", ["0\tTop Level"]), ("enter", ["0\tSlow site"]), ("ctrl-q", [])])
        with patch.object(reader, "NewsBlur", return_value=api), \
             patch.object(reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)), \
             patch.object(reader, "show_message") as message:
            reader.run()
        self.assertIn("timed out", message.call_args.args[0])
        api.mark.assert_not_called()


if __name__ == "__main__":
    unittest.main()
