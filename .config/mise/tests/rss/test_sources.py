"""Source contracts, pagination and migration, using isolated private storage."""

import http.cookiejar
import io
import sys
import tempfile
import threading
import unittest
from pathlib import Path
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).parents[2] / "lib"))
from rss_reader import app, auth, common, migration, registry
from rss_reader.sources import create, source_type
from rss_reader.sources.feed import FeedSource
from rss_reader.sources.newsblur import NewsBlurSource


def atom(identity, next_link=""):
    return f'<feed xmlns="http://www.w3.org/2005/Atom"><title>Events</title>{next_link}<entry><id>{identity}</id><title>{identity}</title></entry></feed>'.encode()


class SourceContractTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        root = Path(directory.name)
        storage = patch.multiple(
            common,
            DATA_DIR=root / "data",
            STATE_DIR=root / "state",
            SOURCES_FILE=root / "data/sources.json",
            AUTH_FILE=root / "data/auth.json",
            READ_FILE=root / "state/read.json",
        )
        storage.start()
        self.addCleanup(storage.stop)
        legacy = patch.object(migration, "LEGACY_COOKIE", root / "old/cookies.txt")
        legacy.start()
        self.addCleanup(legacy.stop)
        self.config = registry.descriptor("https://example.com/feed", "feed", "Events")

    def test_detection_does_not_treat_newsblur_shared_rss_as_api(self):
        self.assertEqual(source_type("https://www.newsblur.com"), "newsblur")
        self.assertEqual(
            source_type("https://www.newsblur.com/social/rss/example"), "feed"
        )

    def test_factory_provides_same_contract_for_each_adapter(self):
        for kind in ("feed", "newsblur"):
            source = create(dict(self.config, type=kind))
            for name in (
                "feeds",
                "stories",
                "body",
                "mark",
                "mark_feed",
                "authenticate",
                "validate",
            ):
                self.assertTrue(callable(getattr(source, name)))

    def test_gitlab_pagination_automatically_advances_by_received_entries(self):
        source = create(
            dict(
                self.config,
                url="https://example.com/dashboard/projects.atom?offset=99&scope=all",
            )
        )
        with patch.object(
            source,
            "open",
            side_effect=[io.BytesIO(atom("one")), io.BytesIO(atom("two"))],
        ):
            source.stories(source.feed_id, 1, "all")
            source.stories(source.feed_id, 2, "all")
        self.assertIn("offset=101", source.request(3).full_url)
        self.assertIn("scope=all", source.request(3).full_url)
        self.assertEqual(source.request(3).full_url.count("offset="), 1)

    def test_last_partial_offset_batch_is_retained_and_completes_collection(self):
        source = create(
            dict(self.config, url="https://example.com/dashboard/projects.atom")
        )
        with patch.object(
            source,
            "open",
            side_effect=[
                io.BytesIO(atom("one")),
                io.BytesIO(b'<feed xmlns="http://www.w3.org/2005/Atom"/>'),
            ],
        ):
            initial = source.stories(source.feed_id, 1, "all")
            collection = app.StoryCollection(source, source.feed_id, initial)
            collection.load()
        self.assertTrue(collection.complete)
        self.assertEqual(len(collection.stories), 1)

    def test_standalone_feed_opens_stories_without_folder_or_feed_picker(self):
        source = FeedSource(self.config)
        with (
            patch.object(app, "create", return_value=source),
            patch.object(app, "chooser") as chooser,
            patch.object(app, "browse_feed", return_value="escape") as browse,
        ):
            self.assertEqual(app.run_source(self.config), "escape")
        chooser.assert_not_called()
        self.assertEqual(browse.call_args.args[1]["id"], self.config["id"])

    def test_gitlab_mark_all_read_fetches_until_empty(self):
        source = create(
            dict(self.config, url="https://example.com/dashboard/projects.atom")
        )
        with patch.object(
            source,
            "open",
            side_effect=[
                io.BytesIO(atom("one")),
                io.BytesIO(atom("two")),
                io.BytesIO(b'<feed xmlns="http://www.w3.org/2005/Atom"/>'),
            ],
        ) as opened:
            source.mark_feed(source.feed_id)
        self.assertEqual(opened.call_count, 3)
        self.assertEqual(len(source.read_hashes()), 2)

    def test_gitlab_repeated_page_does_not_loop_while_marking_all_read(self):
        source = create(
            dict(self.config, url="https://example.com/dashboard/projects.atom")
        )
        with (
            patch.object(
                source,
                "open",
                side_effect=lambda *args, **kwargs: io.BytesIO(atom("one")),
            ) as opened,
            self.assertRaises(common.ReaderError),
        ):
            source.mark_feed(source.feed_id)
        self.assertEqual(opened.call_count, 2)
        self.assertEqual(source.read_hashes(), set())

    def test_history_keeps_fetching_beyond_old_400_page_limit(self):
        source = Mock()
        source.stories.side_effect = lambda feed, page, read_filter: common.StoryBatch(
            [{"story_hash": str(page)}], has_more=page < 402
        )
        initial = common.StoryBatch([{"story_hash": "1"}], has_more=True)
        collection = app.StoryCollection(source, "feed", initial)
        with patch.object(app, "POLL_INTERVAL", 0):
            while not collection.complete and not collection.error:
                collection.load()
        self.assertTrue(collection.complete)
        self.assertFalse(collection.error)
        self.assertEqual(len(collection.stories), 402)

    def test_mark_all_read_does_not_reset_inflight_browsing_cursor(self):
        for url in (
            "https://example.com/dashboard/projects.atom",
            "https://example.com/feed",
        ):
            with self.subTest(url=url):
                source = create(dict(self.config, url=url))
                source.page_urls[4] = url + "?offset=3&page=4"
                started, release = threading.Event(), threading.Event()
                results, errors = [], []

                def response(request, *, started=started, release=release, **kwargs):
                    if threading.current_thread() is not threading.main_thread():
                        started.set()
                        if not release.wait(3):
                            raise AssertionError(
                                "Mark-all did not finish while browsing was in flight"
                            )
                        return io.BytesIO(
                            atom("four", '<link rel="next" href="?page=5"/>')
                        )
                    return io.BytesIO(b'<feed xmlns="http://www.w3.org/2005/Atom"/>')

                def load(source=source, results=results, errors=errors):
                    try:
                        results.append(source.stories(source.feed_id, 4, "all"))
                    except (
                        KeyError,
                        common.ReaderError,
                        AssertionError,
                        OSError,
                    ) as exc:
                        errors.append(exc)

                worker = threading.Thread(target=load)
                with patch.object(source, "open", side_effect=response):
                    worker.start()
                    try:
                        self.assertTrue(started.wait(2))
                        source.mark_feed(source.feed_id)
                        self.assertIn(4, source.page_urls)
                    finally:
                        release.set()
                        worker.join(4)
                self.assertFalse(worker.is_alive())
                self.assertEqual(errors, [])
                self.assertEqual(len(results[0]), 1)
                self.assertIn(5, source.page_urls)

    def test_rss_channel_next_link_is_followed(self):
        source = FeedSource(self.config)
        xml = b'<rss xmlns:atom="http://www.w3.org/2005/Atom"><channel><atom:link rel="next" href="?page=2"/><item><guid>one</guid></item></channel></rss>'
        with patch.object(source, "open", return_value=io.BytesIO(xml)):
            batch = source.stories(source.feed_id, 1, "all")
        self.assertTrue(batch.has_more)
        self.assertIn("page=2", source.request(2).full_url)

    def test_atom_next_links_load_final_nonempty_page_without_extra_fetch(self):
        source = FeedSource(self.config)
        with patch.object(
            source,
            "open",
            side_effect=[
                io.BytesIO(atom("one", '<link rel="next" href="?page=2"/>')),
                io.BytesIO(atom("two")),
            ],
        ) as opened:
            collection = app.StoryCollection(
                source, source.feed_id, source.stories(source.feed_id, 1, "all")
            )
            collection.load()
        self.assertTrue(collection.complete)
        self.assertEqual(len(collection.stories), 2)
        self.assertEqual(opened.call_count, 2)

    def test_plain_feed_does_not_probe_nonexistent_pages(self):
        source = FeedSource(self.config)
        with patch.object(
            source, "open", return_value=io.BytesIO(atom("one"))
        ) as opened:
            collection = app.StoryCollection(
                source, source.feed_id, source.stories(source.feed_id, 1, "all")
            )
            collection.load()
        self.assertTrue(collection.complete)
        self.assertFalse(hasattr(collection, "worker"))
        self.assertEqual(opened.call_count, 1)

    def test_authenticated_next_link_cannot_cross_origin(self):
        source = FeedSource(self.config, auth=auth.make_auth("bearer", "secret"))
        with patch.object(
            source,
            "open",
            return_value=io.BytesIO(
                atom("one", '<link rel="next" href="https://other.example/feed"/>')
            ),
        ):
            source.stories(source.feed_id, 1, "all")
        with self.assertRaises(common.ReaderError):
            source.request(2)

    def test_newsblur_normalizes_unread_metadata_for_application(self):
        source = NewsBlurSource(dict(self.config, type="newsblur"))
        source.ensure_session = Mock()
        source.request = Mock(
            return_value={
                "feeds": {"2": {"id": 2, "feed_title": "Blog", "ps": 3, "nt": 2}},
                "folders": [2],
            }
        )
        data = source.feeds()
        self.assertEqual(data["feeds"]["2"]["unread"], 5)
        self.assertEqual(app.unread_count(data["feeds"]["2"]), 5)
        self.assertNotIn("ps", data["feeds"]["2"])

    def test_newsblur_setup_uses_common_registry(self):
        with patch("sys.stdout", io.StringIO()):
            registry.add_source("https://www.newsblur.com", no_check=True)
        self.assertEqual(registry.sources()[0]["type"], "newsblur")

    def test_newsblur_feed_requests_include_bodies_without_old_cache(self):
        common.private_directory(common.STATE_DIR)
        old_cache = common.STATE_DIR / "library.sqlite3"
        old_cache.write_bytes(b"Existing cache must remain untouched")
        source = NewsBlurSource(dict(self.config, type="newsblur"))
        source.ensure_session = Mock()
        source.request = Mock(return_value={"stories": [{"story_hash": "4:a"}]})
        source.stories("4", 1, "all")
        self.assertNotIn(
            "include_story_content", source.request.call_args.kwargs["params"]
        )
        self.assertEqual(
            old_cache.read_bytes(), b"Existing cache must remain untouched"
        )
        self.assertFalse(hasattr(source, "cache"))

    def test_newsblur_login_saves_session_not_password(self):
        config = registry.descriptor("https://www.newsblur.com")
        source = NewsBlurSource(
            config, auth=auth.make_auth("basic", "password", username="user")
        )

        def request(path, **kwargs):
            if path == "/api/login":
                source.cookies.set_cookie(
                    http.cookiejar.Cookie(
                        0,
                        "newsblur_sessionid",
                        "session",
                        None,
                        False,
                        "www.newsblur.com",
                        False,
                        False,
                        "/",
                        True,
                        True,
                        None,
                        True,
                        None,
                        None,
                        {},
                    )
                )
                return {"code": 1}
            return {"feeds": {}, "folders": []}

        source.request = Mock(side_effect=request)
        auth.authenticated(source, source.validate)
        self.assertTrue(source.cookie_file.exists())
        self.assertEqual(source.cookie_file.stat().st_mode & 0o777, 0o600)
        self.assertEqual(auth.saved_auth(), {})
        restored = NewsBlurSource(config)
        self.assertFalse(restored.login_pending)
        restored.ensure_session()

    def test_rejected_newsblur_login_does_not_save_password_or_session(self):
        source = NewsBlurSource(
            registry.descriptor("https://www.newsblur.com"),
            auth=auth.make_auth("basic", "bad", username="user"),
        )
        source.request = Mock(
            side_effect=common.AuthenticationError("Rejected", "Basic")
        )
        with self.assertRaises(common.AuthenticationError):
            auth.authenticated(source, source.validate, no_prompt=True)
        self.assertFalse(source.cookie_file.exists())
        self.assertEqual(auth.saved_auth(), {})

    def test_source_removal_cleans_private_state_but_preserves_shared_auth(self):
        other = registry.descriptor("https://example.com/other")
        registry.save_sources([self.config, other])
        auth.save_auth(self.config["url"], auth.make_auth("bearer", "secret"))
        common.save_private_json(
            common.READ_FILE, {self.config["id"]: ["one"], other["id"]: ["two"]}
        )
        with patch("sys.stdout", io.StringIO()):
            registry.remove_source(self.config["url"])
        self.assertEqual(registry.sources(), [other])
        self.assertTrue(auth.saved_auth())
        self.assertEqual(
            common.private_json(common.READ_FILE, {}), {other["id"]: ["two"]}
        )

    def test_legacy_subscription_and_read_identity_migration(self):
        config = dict(self.config)
        config.pop("type")
        common.save_private_json(
            common.DATA_DIR / "subscriptions.json", {"feeds": [config]}
        )
        common.save_private_json(common.READ_FILE, {config["id"]: ["direct:hash"]})
        migration.migrate()
        self.assertEqual(registry.sources()[0]["id"], config["id"])
        self.assertEqual(
            common.private_json(common.READ_FILE, {}), {config["id"]: ["hash"]}
        )
        self.assertFalse((common.DATA_DIR / "subscriptions.json").exists())

    def test_legacy_cookie_moves_once_without_exposing_contents(self):
        common.private_directory(migration.LEGACY_COOKIE.parent)
        common.atomic_write(migration.LEGACY_COOKIE, "# Netscape HTTP Cookie File\n")
        migration.migrate()
        config = registry.sources()[0]
        self.assertEqual(config["type"], "newsblur")
        session = common.STATE_DIR / f"session-{config['id']}.cookies"
        self.assertEqual(session.stat().st_mode & 0o777, 0o600)
        self.assertFalse(migration.LEGACY_COOKIE.exists())
        with patch("sys.stdout", io.StringIO()):
            registry.remove_source(config["url"])
        migration.migrate()
        self.assertEqual(registry.sources(), [])
