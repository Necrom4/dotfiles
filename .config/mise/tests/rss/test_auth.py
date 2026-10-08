"""RSS reader auth regressions; no account or network required."""

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

    def test_auth_error_has_trace_without_secret_url(self):
        api = FeedSource(dict(self.config, url=self.config["url"] + "?token=secret"))
        with (
            patch.object(api, "open", side_effect=self.http_error()),
            self.assertRaises(common.AuthenticationError) as caught,
        ):
            api.stories("example", 1, "all")
        self.assertIn("trace-123", str(caught.exception))
        self.assertNotIn("secret", str(caught.exception))

    def test_symlinked_auth_file_is_rejected(self):
        common.private_directory(common.DATA_DIR)
        target = Path(self.scratch.name) / "target"
        target.write_text("{}")
        target.chmod(0o600)
        common.AUTH_FILE.symlink_to(target)
        with self.assertRaises(reader.ReaderError):
            credentials.save_auth(
                self.config["url"], credentials.make_auth("bearer", "secret")
            )

    def test_token_auto_detects_feed_token_pat_and_bearer(self):
        for token, kind, name in [
            ("glft-test", "query", "feed_token"),
            ("glpat-test", "header", "PRIVATE-TOKEN"),
            ("other-token", "bearer", None),
        ]:
            auth = credentials.make_auth("token", token)
            self.assertEqual(auth["kind"], kind)
            self.assertEqual(auth.get("name"), name)

    def test_basic_auth(self):
        api = FeedSource(
            self.config,
            auth=credentials.make_auth("basic", "password", username="user"),
        )
        self.assertEqual(
            api.request().get_header("Authorization"), "Basic dXNlcjpwYXNzd29yZA=="
        )

    def test_custom_header_auth(self):
        api = FeedSource(
            self.config,
            auth=credentials.make_auth("header", "secret", name="X-API-Key"),
        )
        self.assertEqual(api.request().get_header("X-api-key"), "secret")

    def test_query_auth_replaces_secret_and_keeps_filters(self):
        config = dict(
            self.config, url=self.config["url"] + "?category=one&credential=old"
        )
        api = FeedSource(
            config, auth=credentials.make_auth("query", "new", name="credential")
        )
        query = reader.urllib.parse.parse_qs(
            reader.urllib.parse.urlsplit(api.request().full_url).query
        )
        self.assertEqual(query, {"category": ["one"], "credential": ["new"]})

    def test_credentials_are_scoped_to_exact_https_origin(self):
        credentials.save_auth(
            self.config["url"], credentials.make_auth("bearer", "secret")
        )
        self.assertEqual(
            FeedSource(self.config).request().get_header("Authorization"),
            "Bearer secret",
        )
        for url in [
            "https://other.example/feed",
            "https://sub.example.com/feed",
            "http://example.com/feed",
            "https://example.com:8443/feed",
        ]:
            with self.subTest(url=url):
                self.assertIsNone(
                    FeedSource(dict(self.config, url=url))
                    .request()
                    .get_header("Authorization")
                )

    def test_invalid_credentials_and_header_injection_are_rejected(self):
        for kind, secret, options in [
            ("bearer", "", {}),
            ("header", "one\nInjected: header", {"name": "X-API-Key"}),
            ("basic", "password", {"username": "invalid:name"}),
            ("header", "secret", {"name": "Cookie"}),
        ]:
            with (
                self.subTest(kind=kind, options=options),
                self.assertRaises(reader.ReaderError),
            ):
                credentials.make_auth(kind, secret, **options)

    def test_redirects_cannot_forward_any_auth_off_origin(self):
        for kind, options in [
            ("basic", {"username": "user"}),
            ("bearer", {}),
            ("header", {"name": "X-API-Key"}),
            ("query", {"name": "credential"}),
        ]:
            auth = credentials.make_auth(kind, "secret", **options)
            request = FeedSource(self.config, auth=auth).request()
            for url in [
                "https://other.example/feed",
                "https://sub.example.com/feed",
                "http://example.com/feed",
                "https://example.com:8443/feed",
            ]:
                with (
                    self.subTest(kind=kind, url=url),
                    self.assertRaisesRegex(reader.ReaderError, "Refusing to forward"),
                ):
                    credentials.FeedRedirect().redirect_request(
                        request, None, 302, "Found", {}, url
                    )

    def test_same_origin_redirect_reapplies_query_auth(self):
        request = FeedSource(
            self.config,
            auth=credentials.make_auth("query", "secret", name="credential"),
        ).request()
        redirected = credentials.FeedRedirect().redirect_request(
            request,
            None,
            302,
            "Found",
            {},
            "https://example.com:443/new-feed?category=one",
        )
        query = reader.urllib.parse.parse_qs(
            reader.urllib.parse.urlsplit(redirected.full_url).query
        )
        self.assertEqual(query, {"category": ["one"], "credential": ["secret"]})

    def test_public_redirects_still_work(self):
        request = FeedSource(self.config).request()
        redirected = credentials.FeedRedirect().redirect_request(
            request, None, 302, "Found", {}, "https://other.example/feed"
        )
        self.assertEqual(redirected.full_url, "https://other.example/feed")

    def test_embedded_url_tokens_cannot_redirect_off_origin(self):
        request = reader.urllib.request.Request(
            self.config["url"] + "?feed_token=secret"
        )
        with self.assertRaisesRegex(reader.ReaderError, "Refusing to forward"):
            credentials.FeedRedirect().redirect_request(
                request, None, 302, "Found", {}, "https://other.example/feed"
            )

    def test_401_prompts_hidden_auth_and_saves_only_after_success(self):
        with (
            patch.object(
                FeedSource,
                "open",
                side_effect=[self.http_error(), io.BytesIO(ATOM)],
            ),
            patch("builtins.input", return_value="token"),
            patch.object(credentials.getpass, "getpass", return_value="glft-secret"),
        ):
            self.add(self.config["url"] + "?feed_token=old")
        feed = registry.sources()[0]
        self.assertEqual(feed["url"], self.config["url"])
        self.assertNotIn("glft-secret", common.SOURCES_FILE.read_text())
        self.assertEqual(common.AUTH_FILE.stat().st_mode & 0o777, 0o600)
        self.assertEqual(FeedSource(feed).auth["secret"], "glft-secret")

    def test_basic_challenge_prompts_username_and_password(self):
        with (
            patch.object(
                FeedSource,
                "open",
                side_effect=[
                    self.http_error(challenge='Basic realm="Feeds"'),
                    io.BytesIO(ATOM),
                ],
            ),
            patch("builtins.input", return_value="user"),
            patch.object(credentials.getpass, "getpass", return_value="password"),
        ):
            self.add()
        auth = credentials.saved_auth()[common.auth_key(self.config["url"])]
        self.assertEqual(auth["kind"], "basic")
        self.assertEqual(auth["username"], "user")

    def test_rejected_credentials_are_never_persisted(self):
        with (
            patch.object(
                FeedSource,
                "open",
                side_effect=lambda *args, **kwargs: (_ for _ in ()).throw(
                    self.http_error()
                ),
            ),
            patch("builtins.input", return_value="token"),
            patch.object(credentials.getpass, "getpass", return_value="bad-token"),
            self.assertRaises(common.AuthenticationError),
        ):
            self.add()
        self.assertFalse(common.AUTH_FILE.exists())
        self.assertFalse(common.SOURCES_FILE.exists())

    def test_no_check_can_store_explicit_auth(self):
        with patch.object(FeedSource, "open") as opened:
            self.add(
                auth=credentials.make_auth("header", "secret", name="X-API-Key"),
                no_check=True,
            )
        opened.assert_not_called()
        self.assertEqual(
            credentials.saved_auth()[common.auth_key(self.config["url"])]["secret"],
            "secret",
        )

    def test_failed_replacement_preserves_credentials(self):
        credentials.save_auth(
            self.config["url"], credentials.make_auth("bearer", "working")
        )
        before = common.AUTH_FILE.read_bytes()
        with (
            patch.object(FeedSource, "open", side_effect=self.http_error()),
            self.assertRaises(common.AuthenticationError),
        ):
            self.add(auth=credentials.make_auth("bearer", "bad"), no_prompt=True)
        self.assertEqual(common.AUTH_FILE.read_bytes(), before)

    def test_none_clears_saved_site_auth(self):
        credentials.save_auth(
            self.config["url"], credentials.make_auth("bearer", "secret")
        )
        self.add(auth=credentials.make_auth("none"), no_check=True)
        self.assertEqual(credentials.saved_auth(), {})

    def test_foreground_browsing_can_refresh_expired_auth(self):
        api = FeedSource(self.config)
        with (
            patch.object(
                api, "open", side_effect=[self.http_error(), io.BytesIO(ATOM)]
            ),
            patch("builtins.input", return_value="token"),
            patch.object(credentials.getpass, "getpass", return_value="new-token"),
            patch("sys.stdout", new_callable=io.StringIO),
        ):
            stories = reader.foreground_stories(api, "example")
        self.assertEqual(len(stories), 1)
        self.assertEqual(
            credentials.saved_auth()[common.auth_key(self.config["url"])]["secret"],
            "new-token",
        )
