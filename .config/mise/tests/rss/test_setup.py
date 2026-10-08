"""RSS reader setup regressions; no account or network required."""

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
from rss_reader import cli, common, registry
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
        migration = patch.object(cli, "migrate")
        migration.start()
        self.addCleanup(migration.stop)
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

    def test_add_stores_private_metadata(self):
        with self.response():
            self.add()
        self.assertEqual(registry.sources()[0]["title"], "Activity")
        self.assertEqual(common.SOURCES_FILE.stat().st_mode & 0o777, 0o600)
        self.assertEqual(common.DATA_DIR.stat().st_mode & 0o777, 0o700)
        self.assertFalse(common.AUTH_FILE.exists())

    def test_readding_feed_updates_without_duplicate(self):
        with self.response():
            self.add(name="First")
            original_id = registry.sources()[0]["id"]
            self.add(name="Updated")
        self.assertEqual(len(registry.sources()), 1)
        self.assertEqual(registry.sources()[0]["id"], original_id)
        self.assertEqual(registry.sources()[0]["title"], "Updated")

    def test_private_storage_rejects_world_readable_file(self):
        registry.save_sources([self.config])
        common.SOURCES_FILE.chmod(0o644)
        with self.assertRaisesRegex(reader.ReaderError, "0600"):
            registry.sources()

    def test_no_prompt_fails_cleanly_on_401(self):
        with (
            patch.object(FeedSource, "open", side_effect=self.http_error()),
            patch("builtins.input") as prompt,
            patch.object(credentials.getpass, "getpass") as secret,
            self.assertRaises(common.AuthenticationError),
        ):
            self.add(no_prompt=True)
        prompt.assert_not_called()
        secret.assert_not_called()

    def test_no_check_does_not_fetch_or_prompt(self):
        with (
            patch.object(FeedSource, "open") as opened,
            patch("builtins.input") as prompt,
        ):
            self.add(no_check=True, no_prompt=True)
        opened.assert_not_called()
        prompt.assert_not_called()
        self.assertEqual(registry.sources()[0]["title"], "example.com")

    def test_cli_url_prompt_is_not_hidden(self):
        with (
            patch("builtins.input", return_value=self.config["url"]) as prompt,
            patch.object(credentials.getpass, "getpass") as hidden,
            patch.object(registry, "add_source") as add,
        ):
            self.assertEqual(cli.main(["--url"]), 0)
        prompt.assert_called_once_with("Source URL: ")
        hidden.assert_not_called()
        self.assertEqual(add.call_args.args, (self.config["url"], None))

    def test_cli_auth_env_avoids_secret_prompt(self):
        with (
            patch.dict(reader.os.environ, {"FEED_SECRET": "glft-secret"}),
            patch.object(credentials.getpass, "getpass") as hidden,
            patch.object(registry, "add_source") as add,
        ):
            self.assertEqual(
                cli.main(
                    [
                        "--url",
                        self.config["url"],
                        "--auth",
                        "token",
                        "--auth-env",
                        "FEED_SECRET",
                        "--no-prompt",
                        "--no-check",
                    ]
                ),
                0,
            )
        hidden.assert_not_called()
        self.assertEqual(
            add.call_args.kwargs["auth"], credentials.make_auth("token", "glft-secret")
        )
        self.assertTrue(add.call_args.kwargs["no_prompt"])
        self.assertTrue(add.call_args.kwargs["no_check"])

    def test_cli_rejects_incomplete_noninteractive_auth(self):
        with (
            patch("sys.stderr", new_callable=io.StringIO),
            patch.object(credentials.getpass, "getpass") as hidden,
        ):
            self.assertEqual(
                cli.main(
                    ["--url", self.config["url"], "--auth", "basic", "--no-prompt"]
                ),
                1,
            )
        hidden.assert_not_called()

    def test_cli_setup_flags_require_url(self):
        with (
            patch("sys.stderr", new_callable=io.StringIO),
            self.assertRaises(SystemExit) as error,
        ):
            cli.main(["--auth", "bearer"])
        self.assertEqual(error.exception.code, 2)

    def test_help_is_short(self):
        with (
            patch("sys.stdout", new_callable=io.StringIO) as output,
            self.assertRaises(SystemExit),
        ):
            cli.main(["--help"])
        self.assertLess(len(output.getvalue().splitlines()), 40)
        self.assertNotIn("GITLAB_", output.getvalue())

    def test_source_picker_opens_source_and_ctrl_q_exits(self):
        with (
            patch.object(registry, "sources", return_value=[self.config]),
            patch.object(reader, "chooser", return_value=("enter", ["0\tExample"])),
            patch.object(reader, "run_source", return_value="ctrl-q") as browse,
        ):
            reader.run()
        browse.assert_called_once_with(self.config)
