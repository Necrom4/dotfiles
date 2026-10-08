"""RSS reader feed regressions; no account or network required."""

import io
import sys
import tempfile
import unittest
import urllib.error
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).parents[2] / "lib"))
from rss_reader import app as reader
from rss_reader import auth as credentials
from rss_reader import common, registry
from rss_reader.sources.feed import FeedSource

CONFIG = {
    "id": "account",
    "type": "newsblur",
    "title": "NewsBlur",
    "url": "https://www.newsblur.com",
}
ATOM = b"""<feed xmlns="http://www.w3.org/2005/Atom"><title>Activity</title><entry><id>event-1</id><title>New event</title><published>2026-10-09T12:00:00Z</published><link href="/events/1"/><summary>Fallback</summary><content type="html">&lt;p&gt;Hello&lt;/p&gt;</content></entry></feed>"""
RSS = b"""<rss version="2.0"><channel><title>News</title><item><guid>item-1</guid><title>News item</title><link>https://example.com/news</link><description>News body</description></item></channel></rss>"""


class SourceTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory()
        self.addCleanup(self.scratch.cleanup)
        root = Path(self.scratch.name)
        patches = patch.multiple(
            common,
            STATE_DIR=root / "state",
            DATA_DIR=root / "data",
            SOURCES_FILE=root / "data/sources.json",
            AUTH_FILE=root / "data/credentials.json",
            READ_FILE=root / "state/read.json",
        )
        patches.start()
        self.addCleanup(patches.stop)
        self.config = {
            "id": "example",
            "type": "feed",
            "title": "Example",
            "url": "https://example.com/feed.atom",
        }

    def response(self, body=None):
        return patch.object(
            FeedSource,
            "open",
            side_effect=lambda *args, **kwargs: io.BytesIO(
                ATOM if body is None else body
            ),
        )

    def http_error(self, code=401, challenge=""):
        return urllib.error.HTTPError(
            self.config["url"],
            code,
            "Rejected",
            {"X-Request-Id": "trace-123", "WWW-Authenticate": challenge},
            io.BytesIO(),
        )

    def add(self, url=None, **kwargs):
        with patch("sys.stdout", new_callable=io.StringIO):
            registry.add_source(url or self.config["url"], **kwargs)

    def test_atom_normalizes_content_links_and_dates(self):
        api = FeedSource(self.config)
        with self.response():
            story = api.stories("example", 1, "all")[0]
        self.assertEqual(api.title, "Activity")
        self.assertEqual(story["story_content"], "<p>Hello</p>")
        self.assertEqual(story["story_permalink"], "https://example.com/events/1")
        self.assertEqual(story["story_date"], "2026-10-09T12:00:00Z")
        self.assertEqual(story["read_status"], 0)
        self.assertEqual(api.stories("example", 2, "all"), [])

    def test_rss_links_and_plain_text(self):
        with self.response(RSS):
            story = FeedSource(self.config).stories("example", 1, "all")[0]
        self.assertEqual(story["story_permalink"], "https://example.com/news")
        self.assertEqual(story["story_content"], "<p>News body</p>")

    def test_atom_xhtml_preserves_markup(self):
        body = b'<feed xmlns="http://www.w3.org/2005/Atom"><entry><id>1</id><content type="xhtml"><div xmlns="http://www.w3.org/1999/xhtml"><a href="/one">Hello</a></div></content></entry></feed>'
        with self.response(body):
            story = FeedSource(self.config).stories("example", 1, "all")[0]
        self.assertIn('<a href="/one">Hello</a>', story["story_content"])
        self.assertNotIn("ns0:", story["story_content"])

    def test_empty_feed_is_valid(self):
        with self.response(
            b'<feed xmlns="http://www.w3.org/2005/Atom"><title>Empty</title></feed>'
        ):
            self.add()
        self.assertEqual(registry.sources()[0]["title"], "Empty")

    def test_login_document_is_not_a_feed(self):
        with (
            self.response(b"<html><body>Sign in</body></html>"),
            self.assertRaisesRegex(reader.ReaderError, "not Atom/RSS"),
        ):
            self.add()
        self.assertFalse(common.SOURCES_FILE.exists())

    def test_failed_validation_preserves_saved_configuration(self):
        registry.save_sources([self.config])
        before = common.SOURCES_FILE.read_bytes()
        with self.response(b"not XML"), self.assertRaises(reader.ReaderError):
            self.add(name="Broken")
        self.assertEqual(common.SOURCES_FILE.read_bytes(), before)

    def test_rejects_invalid_urls(self):
        for url in (
            "file:///etc/passwd",
            "https://user:password@example.com/feed",
            "not a URL",
            "https://example.com:99999/feed",
        ):
            with self.subTest(url=url), self.assertRaises(reader.ReaderError):
                self.add(url)

    def test_read_state_survives_reopening(self):
        api = FeedSource(self.config)
        with self.response():
            story = api.stories("example", 1, "all")[0]
        api.mark([story["story_hash"]], unread=False)
        with self.response():
            self.assertEqual(
                FeedSource(self.config).stories("example", 1, "all")[0]["read_status"],
                1,
            )
        api.mark([story["story_hash"]], unread=True)
        self.assertEqual(api.read_hashes(), set())

    def test_corrupt_state_is_not_overwritten(self):
        common.private_directory(common.STATE_DIR)
        api = FeedSource(self.config)
        common.READ_FILE.write_text("not JSON")
        common.READ_FILE.chmod(0o600)
        with self.assertRaises(reader.ReaderError):
            api.mark(["one"], unread=False)
        self.assertEqual(common.READ_FILE.read_text(), "not JSON")

    def test_https_is_required_even_without_validation(self):
        with self.assertRaisesRegex(reader.ReaderError, "HTTPS"):
            self.add(
                "http://example.com/feed",
                auth=credentials.make_auth("bearer", "secret"),
                no_check=True,
            )
        self.assertFalse(common.AUTH_FILE.exists())
