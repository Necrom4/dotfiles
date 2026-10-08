"""RSS reader app regressions; no account or network required."""

import io
import sys
import tempfile
import threading
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).parents[2] / "lib"))
from rss_reader import app as reader
from rss_reader.common import StoryBatch

CONFIG = {
    "id": "account",
    "type": "newsblur",
    "title": "NewsBlur",
    "url": "https://www.newsblur.com",
}
ATOM = b"""<feed xmlns="http://www.w3.org/2005/Atom"><title>Activity</title><entry><id>event-1</id><title>New event</title><published>2026-10-09T12:00:00Z</published><link href="/events/1"/><summary>Fallback</summary><content type="html">&lt;p&gt;Hello&lt;/p&gt;</content></entry></feed>"""
RSS = b"""<rss version="2.0"><channel><title>News</title><item><guid>item-1</guid><title>News item</title><link>https://example.com/news</link><description>News body</description></item></channel></rss>"""


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
        self.assertEqual(
            reader.html_text("<p>Hello <b>reader</b></p><script>secret</script>"),
            "Hello reader",
        )
        source = "<nav>Menu</nav><main><h1>Title</h1><p>Article text</p></main><footer>Ad</footer>"
        self.assertEqual(
            reader.html_text(source, article_only=True), "Title\n\nArticle text"
        )

    def test_folder_groups_keep_top_level_and_nested_paths_distinct(self):
        data = {
            "feeds": {"2": {"id": 2}, "3": {"id": 3}, "4": {"id": 4}},
            "folders": [{"Tech": [2, {"Deep": [3]}]}],
        }
        self.assertEqual(
            [
                (folder, [feed["id"] for feed in feeds])
                for folder, feeds in reader.rows_for_folders(data)
            ],
            [("", [4]), ("Tech", [2]), ("Tech/Deep", [3])],
        )

    def test_folder_picker_previews_feeds_and_back_returns_to_folders(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {
                "2": {"id": 2, "feed_title": "Tech Blog", "unread": 2},
                "3": {"id": 3, "feed_title": "Other Blog", "unread": 1},
                "4": {"id": 4, "feed_title": "Unfiled Blog"},
            },
            "folders": [{"Tech": [2, 3]}, 4],
        }
        actions = iter([("enter", 1), ("escape", None), ("enter", 0), ("ctrl-q", None)])
        screens = []
        previews = []

        def choose(lines, **kwargs):
            screens.append((lines, kwargs["header"]))
            if kwargs["preview"]:
                previews.append(
                    [Path(line.split("\t", 1)[0]).read_text() for line in lines]
                )
            key, index = next(actions)
            return key, [lines[index]] if index is not None else []

        with (
            patch.object(reader, "create", return_value=api),
            patch.object(reader, "chooser", side_effect=choose),
        ):
            reader.run_source(CONFIG)
        self.assertIn("Top Level", screens[0][0][0])
        self.assertIn("Tech  (3 unread)", screens[0][0][1])
        self.assertIn("Tech Blog  (2 unread)", previews[0][1])
        self.assertIn("Other Blog  (1 unread)", previews[0][1])
        self.assertEqual(
            screens[1][0], ["0\tTech Blog  (2 unread)", "1\tOther Blog  (1 unread)"]
        )
        self.assertEqual(screens[2][1].splitlines()[0], "NewsBlur · folders")
        self.assertEqual(screens[3][0], ["0\tUnfiled Blog  (0 unread)"])
        api.stories.assert_not_called()
        api.mark.assert_not_called()

    def test_article_fragment_preserves_links_and_void_tags(self):
        fragment = reader.ArticleFragment()
        fragment.feed(
            '<nav>Skip</nav><article><h1>Story</h1><p><a href="https://example.com">Link</a><br>Next</p></article><footer>Skip</footer>'
        )
        result = "".join(fragment.parts)
        self.assertIn('href="https://example.com"', result)
        self.assertIn("<br>", result)
        self.assertNotIn("Skip", result)

    def test_full_collection_includes_older_unread_and_deduplicates_batches(self):
        api = Mock()
        api.stories.side_effect = [
            [{"story_hash": "4:new"}, {"story_hash": "4:older", "read_status": 0}],
            [{"story_hash": "4:oldest", "read_status": 0}],
            [],
        ]
        collection = reader.StoryCollection(api, "4", [{"story_hash": "4:new"}])
        collection.load()
        self.assertEqual(
            [s["story_hash"] for s in collection.stories],
            ["4:new", "4:older", "4:oldest"],
        )
        self.assertTrue(collection.complete)
        self.assertEqual(
            [call.args for call in api.stories.call_args_list],
            [("4", 2, "all"), ("4", 3, "all"), ("4", 4, "all")],
        )

    def test_empty_initial_batch_does_not_fetch_more(self):
        api = Mock()
        collection = reader.StoryCollection(api, "4", [])
        collection.start()
        self.assertTrue(collection.complete)
        api.stories.assert_not_called()

    def test_hidden_only_batches_do_not_end_visible_history(self):
        api = Mock()
        api.stories.side_effect = [
            StoryBatch([], hidden_count=5),
            StoryBatch([{"story_hash": "4:older"}]),
            StoryBatch([]),
        ]
        collection = reader.StoryCollection(api, "4", StoryBatch([], hidden_count=6))
        self.assertFalse(collection.complete)
        collection.load()
        self.assertTrue(collection.complete)
        self.assertEqual([s["story_hash"] for s in collection.stories], ["4:older"])

    def test_stream_shows_initial_batch_before_network_finishes(self):
        requested, release = threading.Event(), threading.Event()
        api = Mock()

        def fetch(*args):
            requested.set()
            release.wait(2)
            return []

        api.stories.side_effect = fetch
        collection = reader.StoryCollection(
            api, "4", [{"story_hash": "4:a", "story_title": "Now"}]
        )
        with tempfile.TemporaryDirectory() as directory:
            stream = reader.StoryStream(collection, Path(directory), "all")
            live = reader.LivePicker(stream, 80)
            with patch.object(reader, "feed_preview") as render:
                self.assertIn("Now", live.list_file.read_text())
                collection.start()
                self.assertTrue(requested.wait(1))
                render.assert_not_called()
                release.set()
                collection.worker.join(1)
                live.refresh()
            self.assertIn(
                "1 story · Available history loaded", live.header_file.read_text()
            )
            live.close()
        collection.close()
        collection.worker.join(1)

    def test_partial_error_keeps_loaded_stories_and_is_visible(self):
        api = Mock()
        api.stories.side_effect = reader.ReaderError("timed out")
        collection = reader.StoryCollection(api, "4", [{"story_hash": "4:a"}])
        collection.load()
        self.assertFalse(collection.complete)
        self.assertIn("timed out", collection.error)
        with tempfile.TemporaryDirectory() as directory:
            # No second loader: this collection already attempted its load.
            collection.worker = Mock()
            stream = reader.StoryStream(collection, Path(directory), "all")
            live = reader.LivePicker(stream, 80)
            self.assertEqual(len(live.list_file.read_text().splitlines()), 1)
            self.assertIn("Partial history", live.header_file.read_text())
            live.close()

    def test_repeating_server_batches_stop_instead_of_looping(self):
        api = Mock()
        api.stories.return_value = [{"story_hash": "4:a"}]
        collection = reader.StoryCollection(api, "4", [{"story_hash": "4:a"}])
        collection.load()
        self.assertEqual(api.stories.call_count, 2)
        self.assertEqual(len(collection.stories), 1)
        self.assertIn("repeated", collection.error)

    def test_batch_with_only_duplicates_can_precede_more_history(self):
        api = Mock()
        api.stories.side_effect = [[{"story_hash": "4:a"}], [{"story_hash": "4:b"}], []]
        collection = reader.StoryCollection(api, "4", [{"story_hash": "4:a"}])
        collection.load()
        self.assertTrue(collection.complete)
        self.assertEqual(len(collection.stories), 2)

    def test_cancelled_fetch_does_not_append_results(self):
        api = Mock()
        collection = reader.StoryCollection(api, "4", [{"story_hash": "4:a"}])

        def fetch(*args):
            collection.close()
            return [{"story_hash": "4:b"}]

        api.stories.side_effect = fetch
        collection.load()
        self.assertEqual(len(collection.stories), 1)
        self.assertEqual(api.stories.call_count, 1)

    def test_unread_filter_keeps_stable_ids_and_does_not_refetch(self):
        api = Mock()
        stories = [
            {"story_hash": "4:a", "read_status": 1},
            {"story_hash": "4:b", "read_status": 0},
        ]
        collection = reader.StoryCollection(api, "4", stories)
        collection.complete = True
        with tempfile.TemporaryDirectory() as directory:
            stream = reader.StoryStream(collection, Path(directory), "unread")
            live = reader.LivePicker(stream, 80)
            rows = live.list_file.read_text().splitlines()
            self.assertEqual(len(rows), 1)
            self.assertEqual(Path(rows[0].split("\t")[0]).name, "1")
            collection.mark([stories[1]], unread=False)
            live.refresh()
            self.assertEqual(live.list_file.read_text(), "")
            live.close()
        api.stories.assert_not_called()

    def test_lazy_preview_is_rendered_once_and_cached(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "0"
            path.write_text('{"story_hash": "4:a", "story_title": "Post"}')
            with patch.object(
                reader, "feed_preview", return_value="Rendered"
            ) as render:
                self.assertEqual(reader.lazy_preview(path), "Rendered")
                self.assertEqual(reader.lazy_preview(path), "Rendered")
                render.assert_called_once()

    def test_chooser_preserves_query_without_changing_action_output(self):
        state = {"query": "old"}
        with patch.object(
            reader.subprocess,
            "run",
            return_value=Mock(
                returncode=0, stdout="new query\nctrl-r\n0\tPost\n", stderr=""
            ),
        ) as run:
            self.assertEqual(
                reader.chooser(["0\tPost"], header="Pick", state=state),
                ("ctrl-r", ["0\tPost"]),
            )
        self.assertEqual(state["query"], "new query")
        self.assertIn("--print-query", run.call_args.args[0])

    def test_mark_whole_feed_updates_incoming_batches_without_refetching(self):
        api = Mock()
        api.stories.side_effect = [[{"story_hash": "4:b", "read_status": 1}], []]
        first = {"story_hash": "4:a", "read_status": 0}
        collection = reader.StoryCollection(api, "4", [first])
        collection.mark_all_read()
        collection.mark([first], unread=True)  # a later individual action wins
        collection.load()
        self.assertEqual([s["read_status"] for s in collection.stories], [0, 1])

    def test_pause_and_resume_keep_the_same_paging_worker(self):
        first_request, release, second_request = (threading.Event() for _ in range(3))
        api = Mock()

        def fetch(feed, page, read_filter):
            if page == 2:
                first_request.set()
                release.wait(2)
                return [{"story_hash": "4:b"}]
            second_request.set()
            return []

        api.stories.side_effect = fetch
        collection = reader.StoryCollection(api, "4", [{"story_hash": "4:a"}])
        try:
            collection.start()
            self.assertTrue(first_request.wait(1))
            worker = collection.worker
            collection.pause()
            release.set()
            self.assertFalse(second_request.wait(0.25))
            collection.start()
            self.assertIs(collection.worker, worker)
            self.assertTrue(second_request.wait(1))
            worker.join(1)
            self.assertTrue(collection.complete)
            self.assertEqual(len(collection.stories), 2)
        finally:
            release.set()
            collection.close()
            collection.worker.join(1)

    def test_final_status_wraps_to_list_width(self):
        collection = reader.StoryCollection(Mock(), "4", [{"story_hash": "4:a"}])
        collection.complete = True
        with tempfile.TemporaryDirectory() as directory:
            stream = reader.StoryStream(collection, Path(directory), "all")
            live = reader.LivePicker(stream, 30)
            status = live.header_file.read_text()
            self.assertTrue(all(len(line) <= 30 for line in status.splitlines()))
            self.assertIn("Available history loaded", " ".join(status.split()))
            live.close()

    def test_failed_story_sync_preserves_current_collection(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog"}},
            "folders": [4],
        }
        api.stories.side_effect = [
            [{"story_hash": "4:a"}],
            reader.ReaderError("offline"),
        ]
        choices = iter(
            [
                ("enter", ["0\tTop Level"]),
                ("enter", ["0\tBlog"]),
                ("ctrl-s", []),
                ("escape", []),
                ("ctrl-q", []),
            ]
        )
        collections = []

        def choose(*args, **kwargs):
            if kwargs.get("stream"):
                collections.append(kwargs["stream"].collection)
            return next(choices)

        with (
            patch.object(reader, "create", return_value=api),
            patch.object(reader, "chooser", side_effect=choose),
            patch.object(reader, "show_message") as message,
        ):
            reader.run_source(CONFIG)
        self.assertIs(collections[0], collections[1])
        self.assertEqual(len(collections[1].stories), 1)
        self.assertIn("still available", message.call_args.args[0])
        api.mark.assert_not_called()

    def test_rejects_private_or_non_http_story_urls(self):
        for url in (
            "file:///etc/passwd",
            "http://127.0.0.1/",
            "http://user:pass@example.com/",
        ):
            with self.subTest(url=url), self.assertRaises(reader.ReaderError):
                reader.safe_page_url(url)

    def test_chooser_handles_cancel_and_selected_action(self):
        with patch.object(
            reader.subprocess,
            "run",
            return_value=Mock(returncode=1, stdout="", stderr=""),
        ):
            self.assertEqual(
                reader.chooser(["0\tFirst"], header="Pick"), ("escape", [])
            )
        with patch.object(
            reader.subprocess,
            "run",
            return_value=Mock(returncode=0, stdout="ctrl-r\n0\tFirst\n", stderr=""),
        ):
            self.assertEqual(
                reader.chooser(["0\tFirst"], header="Pick"), ("ctrl-r", ["0\tFirst"])
            )

    def test_chooser_keeps_fzf_config_and_height(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / "fzfrc"
            config.write_text(
                '--bind "tab:down,ctrl-space:toggle"\n--color=dark\n--height="30%"\n--style full\n'
            )
            with (
                patch.dict(
                    reader.os.environ,
                    {
                        "FZF_DEFAULT_OPTS": "--ignore-case --height 40%",
                        "FZF_DEFAULT_OPTS_FILE": str(config),
                    },
                ),
                patch.object(
                    reader.subprocess,
                    "run",
                    return_value=Mock(returncode=1, stdout="", stderr=""),
                ) as run,
            ):
                reader.chooser(["0\tFirst"], header="Pick")
                self.assertEqual(
                    reader.os.environ["FZF_DEFAULT_OPTS"],
                    "--ignore-case --height 40%",
                )
                self.assertEqual(
                    reader.os.environ["FZF_DEFAULT_OPTS_FILE"], str(config)
                )
        self.assertNotIn("env", run.call_args.kwargs)
        self.assertFalse(
            any(arg.startswith("--height") for arg in run.call_args.args[0])
        )

    def test_chooser_wraps_hints_to_list_width(self):
        with (
            patch.object(
                reader.shutil,
                "get_terminal_size",
                return_value=reader.os.terminal_size((120, 40)),
            ),
            patch.object(
                reader.subprocess,
                "run",
                return_value=Mock(returncode=1, stdout="", stderr=""),
            ) as run,
        ):
            reader.chooser(
                ["0\tFirst"],
                header="ctrl-t RSS · ctrl-o browser · ctrl-r/u read/unread",
                preview="cat {1}",
            )
        args = run.call_args.args[0]
        header = args[args.index("--header") + 1]
        self.assertTrue(all(len(line) <= 42 for line in header.splitlines()))
        self.assertIn("ctrl-r/u read/unread", " ".join(header.split()))

    def test_html_view_preserves_links_and_escapes_title(self):
        document = reader.article_document(
            "News <Today>",
            "https://example.com/a?x=1&y=2",
            '<p><a href="/read">Article</a></p>',
        )
        self.assertIn("News &lt;Today&gt;", document)
        self.assertIn('href="/read"', document)
        self.assertIn("<base href=", document)
        self.assertIn("x=1&amp;y=2", document)

    def test_full_page_preserves_article_links_not_navigation(self):
        response = io.BytesIO(
            b'<nav>Skip</nav><article><p>Read the <a href="/post">entire original story</a>.</p></article>'
        )
        response.headers = Mock()
        response.headers.get_content_type.return_value = "text/html"
        response.headers.get_content_charset.return_value = "utf-8"
        opener = Mock()
        opener.open.return_value = response
        with (
            patch.object(reader, "safe_page_url"),
            patch.object(reader.urllib.request, "build_opener", return_value=opener),
        ):
            article = reader.page_text("https://example.com/post")
        self.assertIn('href="/post"', article)
        self.assertNotIn("Skip", article)

    def test_open_marks_read_but_preview_does_not(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog", "unread": 1}},
            "folders": [4],
        }
        api.stories.return_value = [
            {"story_hash": "4:a", "story_title": "Post", "story_content": "<p>Body</p>"}
        ]
        choices = iter(
            [
                ("enter", ["0\tTop Level"]),
                ("enter", ["0\tBlog"]),
                ("ctrl-o", ["0\tPost"]),
                ("escape", []),
                ("ctrl-q", []),
            ]
        )
        with (
            patch.object(reader, "create", return_value=api),
            patch.object(
                reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)
            ),
            patch.object(
                reader, "page_text", return_value="<p>Full original story</p>"
            ),
            patch.object(reader, "article_viewer") as viewer,
            patch.object(
                reader.tempfile, "TemporaryDirectory", wraps=tempfile.TemporaryDirectory
            ),
        ):
            reader.run_source(CONFIG)
        api.mark.assert_called_once_with(["4:a"], unread=False)
        viewer.assert_called_once_with("Post", "", "<p>Full original story</p>")

    def test_enter_opens_rss_html_in_elinks(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog"}},
            "folders": [4],
        }
        api.stories.return_value = [
            {
                "story_hash": "4:a",
                "story_title": "Post",
                "story_content": "<a href='/link'>Read more</a>",
            }
        ]
        choices = iter(
            [
                ("enter", ["0\tTop Level"]),
                ("enter", ["0\tBlog"]),
                ("enter", ["0\tPost"]),
                ("escape", []),
                ("ctrl-q", []),
            ]
        )
        with (
            patch.object(reader, "create", return_value=api),
            patch.object(
                reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)
            ),
            patch.object(reader, "page_text") as fetch,
            patch.object(reader, "article_viewer") as viewer,
        ):
            reader.run_source(CONFIG)
        fetch.assert_not_called()
        viewer.assert_called_once_with("Post", "", "<a href='/link'>Read more</a>")

    def test_alt_o_opens_only_article_url_in_browser(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog"}},
            "folders": [4],
        }
        api.stories.return_value = [
            {
                "story_hash": "4:a",
                "story_title": "Post",
                "story_permalink": "https://example.com/post",
            }
        ]
        choices = iter(
            [
                ("enter", ["0\tTop Level"]),
                ("enter", ["0\tBlog"]),
                ("alt-o", ["0\tPost"]),
                ("escape", []),
                ("ctrl-q", []),
            ]
        )
        with (
            patch.object(reader, "create", return_value=api),
            patch.object(
                reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)
            ),
            patch.object(reader.webbrowser, "open", return_value=True) as open_browser,
            patch.object(reader, "page_text") as fetch,
        ):
            reader.run_source(CONFIG)
        open_browser.assert_called_once_with("https://example.com/post")
        fetch.assert_not_called()

    def test_fzf_preview_renders_links_with_elinks(self):
        with tempfile.TemporaryDirectory() as directory:
            preview = Path(directory) / "article.html"
            result = reader.feed_preview(
                {
                    "story_title": "Post",
                    "story_permalink": "https://example.com/post",
                    "story_content": '<p><a href="https://example.com/link">Linked text</a></p>',
                },
                preview,
            )
        self.assertIn("Linked text", result)
        if reader.shutil.which("elinks"):
            self.assertIn("\x1b[", result)
            self.assertNotIn("\x1b[48;", result)

    def test_preview_strips_background_but_preserves_foreground_and_style(self):
        for background in ("40", "49", "107", "48;5;16", "48;2;0;0;0"):
            with self.subTest(background=background):
                source = f"\x1b[1;38;2;40;48;100;{background}mLink\x1b[0m"
                self.assertEqual(
                    reader.without_background(source),
                    "\x1b[1;38;2;40;48;100mLink\x1b[0m",
                )

    def test_elinks_uses_portable_clipboard_launcher(self):
        with (
            patch.object(reader.shutil, "which", return_value="/usr/bin/tool"),
            patch.object(reader.subprocess, "run") as run,
        ):
            reader.article_viewer(
                "Post", "https://example.com/post", '<a href="/link">Link</a>'
            )
        command = run.call_args.args[0]
        self.assertEqual(
            command[:2], [str(Path.home() / ".config/elinks/clipboard"), "open"]
        )
        self.assertNotIn("-eval", command)

    def test_mark_read_keeps_story_visible_without_refetching(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog", "unread": 1}},
            "folders": [4],
        }
        api.stories.return_value = [
            {
                "story_hash": "4:a",
                "story_title": "Post",
                "story_content": "<p>Body</p>",
                "read_status": 0,
            }
        ]
        choices = iter(
            [
                ("enter", ["0\tTop Level"]),
                ("enter", ["0\tBlog"]),
                ("ctrl-r", ["0\tPost"]),
                ("escape", []),
                ("ctrl-q", []),
            ]
        )
        headers = []

        def choose(*args, **kwargs):
            headers.append(kwargs["header"])
            key, picked = next(choices)
            if key == "ctrl-r":
                # Real fzf dispatches this in place; it no longer returns ctrl-r.
                live = reader.LivePicker(kwargs["stream"], 80)
                live.actions.apply(key, [0])
                live.close()
                return choose(*args, **kwargs)
            return key, picked

        with (
            patch.object(reader, "create", return_value=api),
            patch.object(reader, "chooser", side_effect=choose),
        ):
            reader.run_source(CONFIG)
        api.stories.assert_called_once_with("4", 1, "all")
        self.assertEqual(api.stories.return_value[0]["read_status"], 1)
        self.assertEqual(headers[2].splitlines()[0], "Blog · all · Loading more…")
        self.assertNotIn("Enter story", headers[2])
        self.assertNotIn("ctrl-q", headers[2])
        self.assertNotIn("Esc", headers[2])
        self.assertNotIn("ctrl-space", headers[2])
        self.assertIn("ctrl-r/u read/unread", headers[2])

    def test_ctrl_s_refreshes_feed_picker_and_ctrl_q_exits(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog"}},
            "folders": [4],
        }
        choices = iter([("ctrl-s", []), ("ctrl-q", [])])
        with (
            patch.object(reader, "create", return_value=api),
            patch.object(
                reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)
            ),
        ):
            reader.run_source(CONFIG)
        self.assertEqual(api.feeds.call_count, 2)

    def test_ctrl_f_toggles_unread_filter(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog"}},
            "folders": [4],
        }
        api.stories.return_value = []
        choices = iter(
            [
                ("enter", ["0\tTop Level"]),
                ("enter", ["0\tBlog"]),
                ("ctrl-f", []),
                ("ctrl-f", []),
                ("ctrl-q", []),
            ]
        )
        headers = []

        def choose(*args, **kwargs):
            headers.append(kwargs["header"])
            return next(choices)

        with (
            patch.object(reader, "create", return_value=api),
            patch.object(reader, "chooser", side_effect=choose),
        ):
            reader.run_source(CONFIG)
        api.stories.assert_called_once_with("4", 1, "all")
        self.assertEqual(
            headers[3].splitlines()[0], "Blog · unread · Available history loaded"
        )
        self.assertEqual(
            headers[4].splitlines()[0], "Blog · all · Available history loaded"
        )
        api.mark_feed.assert_not_called()

    def test_alt_r_marks_whole_feed_only_after_confirmation(self):
        for answer in ("n", "y"):
            with self.subTest(answer=answer):
                api = Mock()
                api.login.return_value = None
                api.feeds.return_value = {
                    "feeds": {"4": {"id": 4, "feed_title": "Blog"}},
                    "folders": [4],
                }
                api.stories.return_value = []
                choices = iter(
                    [
                        ("enter", ["0\tTop Level"]),
                        ("enter", ["0\tBlog"]),
                        ("alt-r", []),
                        ("ctrl-q", []),
                    ]
                )
                with (
                    patch.object(reader, "create", return_value=api),
                    patch.object(
                        reader,
                        "chooser",
                        side_effect=lambda *args, choices=choices, **kwargs: next(
                            choices
                        ),
                    ),
                    patch("builtins.input", return_value=answer),
                ):
                    reader.run_source(CONFIG)
                if answer == "y":
                    api.mark_feed.assert_called_once_with("4")
                else:
                    api.mark_feed.assert_not_called()

    def test_story_picker_has_no_manual_pages_and_reuses_collection(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog"}},
            "folders": [4],
        }
        api.stories.return_value = []
        choices = iter(
            [
                ("enter", ["0\tTop Level"]),
                ("enter", ["0\tBlog"]),
                ("ctrl-f", []),
                ("ctrl-f", []),
                ("ctrl-q", []),
            ]
        )
        screens = []

        def choose(*args, **kwargs):
            screens.append(kwargs)
            return next(choices)

        with (
            patch.object(reader, "create", return_value=api),
            patch.object(reader, "chooser", side_effect=choose),
        ):
            reader.run_source(CONFIG)
        api.stories.assert_called_once_with("4", 1, "all")
        for screen in screens[2:]:
            self.assertNotIn("alt-n", screen["keys"])
            self.assertNotIn("page 1", screen["header"])
        self.assertIs(screens[2]["stream"].collection, screens[4]["stream"].collection)

    def test_returning_to_feeds_updates_counts_without_marking_read(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog", "unread": 2}},
            "folders": [4],
        }
        api.stories.return_value = [
            {"story_hash": "4:a", "story_title": "Post", "read_status": 1}
        ]
        choices = iter(
            [
                ("enter", ["0\tTop Level"]),
                ("enter", ["0\tBlog"]),
                ("escape", []),
                ("ctrl-q", []),
            ]
        )
        with (
            patch.object(reader, "create", return_value=api),
            patch.object(
                reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)
            ),
            patch.object(reader, "feed_preview", return_value="Body"),
        ):
            reader.run_source(CONFIG)
        self.assertEqual(api.feeds.call_count, 2)
        api.mark.assert_not_called()

    def test_ctrl_q_exits_straight_from_story_picker(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Blog"}},
            "folders": [4],
        }
        api.stories.return_value = [{"story_hash": "4:a", "story_title": "Post"}]
        choices = iter(
            [("enter", ["0\tTop Level"]), ("enter", ["0\tBlog"]), ("ctrl-q", [])]
        )
        with (
            patch.object(reader, "create", return_value=api),
            patch.object(
                reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)
            ),
        ):
            reader.run_source(CONFIG)

    def test_feed_api_timeout_returns_to_feed_picker_without_marking_read(self):
        api = Mock()
        api.login.return_value = None
        api.feeds.return_value = {
            "feeds": {"4": {"id": 4, "feed_title": "Slow site", "unread": 2}},
            "folders": [4],
        }
        api.stories.side_effect = reader.ReaderError("Network error: timed out")
        choices = iter(
            [("enter", ["0\tTop Level"]), ("enter", ["0\tSlow site"]), ("ctrl-q", [])]
        )
        with (
            patch.object(reader, "create", return_value=api),
            patch.object(
                reader, "chooser", side_effect=lambda *args, **kwargs: next(choices)
            ),
            patch.object(reader, "show_message") as message,
        ):
            reader.run_source(CONFIG)
        self.assertIn("timed out", message.call_args.args[0])
        api.mark.assert_not_called()
