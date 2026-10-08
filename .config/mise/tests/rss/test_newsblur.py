"""RSS reader newsblur regressions; no account or network required."""

import io
import sys
import unittest
from pathlib import Path
from unittest.mock import Mock

sys.path.insert(0, str(Path(__file__).parents[2] / "lib"))
from rss_reader import app as reader
from rss_reader.sources.newsblur import NewsBlurSource

CONFIG = {
    "id": "account",
    "type": "newsblur",
    "title": "NewsBlur",
    "url": "https://www.newsblur.com",
}
ATOM = b"""<feed xmlns="http://www.w3.org/2005/Atom"><title>Activity</title><entry><id>event-1</id><title>New event</title><published>2026-10-09T12:00:00Z</published><link href="/events/1"/><summary>Fallback</summary><content type="html">&lt;p&gt;Hello&lt;/p&gt;</content></entry></feed>"""
RSS = b"""<rss version="2.0"><channel><title>News</title><item><guid>item-1</guid><title>News item</title><link>https://example.com/news</link><description>News body</description></item></channel></rss>"""


class ReaderTests(unittest.TestCase):
    def test_mark_batches_read_and_unread(self):
        api = NewsBlurSource(CONFIG, auth={"kind": "none"})
        api.ensure_session = Mock()
        api.request = Mock(return_value={"code": 1})
        hashes = [f"1:{i}" for i in range(51)]
        api.mark(hashes, unread=False)
        self.assertEqual(api.request.call_count, 2)
        self.assertEqual(len(api.request.call_args_list[0].kwargs["data"]), 50)
        api.mark(["1:0", "1:1"], unread=True)
        self.assertEqual(
            api.request.call_args.args[0], "/reader/mark_story_hash_as_unread"
        )

    def test_story_page_request(self):
        api = NewsBlurSource(CONFIG, auth={"kind": "none"})
        api.ensure_session = Mock()
        api.request = Mock(return_value={"stories": [{"story_hash": "4:a"}]})
        self.assertEqual(api.stories("4", 2, "all"), [{"story_hash": "4:a"}])
        api.request.assert_called_once_with(
            "/reader/feed/4",
            params={"page": 2, "read_filter": "all", "include_hidden": "false"},
        )

    def test_story_api_preserves_hidden_metadata_and_rejects_malformed_batches(self):
        api = NewsBlurSource(CONFIG, auth={"kind": "none"})
        api.ensure_session = Mock()
        api.request = Mock(return_value={"stories": [], "hidden_stories_count": 6})
        self.assertEqual(api.stories("4", 1, "all").has_more, True)
        for response in (
            {"stories": None},
            {"stories": [{}]},
            {"stories": [], "hidden_stories_count": "invalid"},
        ):
            api.request.return_value = response
            with self.assertRaises(reader.ReaderError):
                api.stories("4", 1, "all")

    def test_api_response_parses_json(self):
        api = NewsBlurSource(CONFIG, auth={"kind": "none"})
        api.ensure_session = Mock()
        response = io.BytesIO(b'{"feeds": {"4": {"id": 4}}}')
        response.url = "https://www.newsblur.com/reader/feeds"
        opener = Mock()
        opener.open.return_value = response
        api.opener = opener
        self.assertEqual(api.feeds()["feeds"]["4"]["id"], 4)

    def test_feed_counts_are_recalculated(self):
        api = NewsBlurSource(CONFIG, auth={"kind": "none"})
        api.ensure_session = Mock()
        api.request = Mock(return_value={"feeds": {}})
        api.feeds()
        api.request.assert_called_once_with(
            "/reader/feeds",
            params={"include_favicons": "false", "update_counts": "true"},
        )


class ApiAndPreviewTests(unittest.TestCase):
    def test_mixed_acknowledgments_cannot_be_mistaken_for_success(self):
        api = NewsBlurSource(CONFIG, auth={"kind": "none"})
        api.ensure_session = Mock()
        api.request = Mock(
            return_value=[
                {"code": 1, "story_hash": "4:a"},
                {"code": -1, "story_hash": "4:b", "message": "Too old"},
            ]
        )
        with self.assertRaises(reader.MarkError) as result:
            api.mark(["4:a", "4:b"], unread=True)
        self.assertEqual(result.exception.confirmed, ["4:a"])
        self.assertIn("Too old", str(result.exception))

    def test_partial_failure_after_first_api_batch_preserves_confirmed_ids(self):
        api = NewsBlurSource(CONFIG, auth={"kind": "none"})
        api.ensure_session = Mock()
        api.request = Mock(side_effect=[{"code": 1}, reader.ReaderError("timeout")])
        hashes = [f"4:{index}" for index in range(51)]
        with self.assertRaises(reader.MarkError) as result:
            api.mark(hashes, unread=False)
        self.assertEqual(result.exception.confirmed, hashes[:50])

    def test_whole_feed_mark_requires_confirmation(self):
        api = NewsBlurSource(CONFIG, auth={"kind": "none"})
        api.ensure_session = Mock()
        api.request = Mock(return_value={"code": 0})
        with self.assertRaises(reader.ReaderError):
            api.mark_feed("4")

    def test_missing_body_cannot_be_replaced_with_an_unrelated_story(self):
        api = NewsBlurSource(CONFIG, auth={"kind": "none"})
        api.ensure_session = Mock()
        api.request = Mock(
            return_value={
                "stories": [{"story_hash": "4:other", "story_content": "Wrong"}]
            }
        )
        with self.assertRaises(reader.ReaderError):
            api.body({"story_hash": "4:a"})
