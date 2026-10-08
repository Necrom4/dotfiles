"""NewsBlur API adapter. Session login, library and read-state sync stay here."""

from __future__ import annotations

import http.cookiejar
import json
import urllib.error
import urllib.parse
import urllib.request

from .. import common
from ..auth import FeedRedirect, attach_auth, save_auth
from ..common import USER_AGENT, AuthenticationError, MarkError, ReaderError, StoryBatch
from .base import Source

MARK_BATCH_SIZE = 50


class NewsBlurSource(Source):
    def __init__(self, config: dict, *, auth: dict | None = None):
        super().__init__(config, auth=auth)
        self.base_url = config["url"].rstrip("/")
        self.cookie_file = common.STATE_DIR / f"session-{config['id']}.cookies"
        self.cookies = http.cookiejar.MozillaCookieJar(str(self.cookie_file))
        if self.cookie_file.exists():
            if self.cookie_file.is_symlink() or self.cookie_file.stat().st_mode & 0o077:
                raise ReaderError("Unsafe session file permissions (expected 0600)")
            self.cookies.load(ignore_discard=True, ignore_expires=True)
        self.opener = urllib.request.build_opener(
            FeedRedirect(), urllib.request.HTTPCookieProcessor(self.cookies)
        )
        self.login_pending = self.auth["kind"] == "basic"

    def authenticate(self, auth: dict) -> None:
        super().authenticate(auth)
        self.login_pending = auth["kind"] == "basic"

    def commit_auth(self, *, validated: bool) -> None:
        if validated and self.auth["kind"] == "basic":
            common.private_directory(common.STATE_DIR)
            # Save the session, not the account password, after API validation.
            temporary = common.STATE_DIR / f"session-{self.config['id']}.pending"
            common.atomic_write(temporary, "")
            try:
                self.cookies.save(
                    str(temporary), ignore_discard=True, ignore_expires=True
                )
                temporary.replace(self.cookie_file)
            finally:
                temporary.unlink(missing_ok=True)
            save_auth(self.config["url"], {"kind": "none"})
            self.auth_changed = False
        else:
            super().commit_auth(validated=validated)

    def ensure_session(self) -> None:
        if self.login_pending:
            self.cookies.clear()
            self.request(
                "/api/login",
                data=[
                    ("username", self.auth["username"]),
                    ("password", self.auth["secret"]),
                ],
            )
            if not any(
                cookie.name == "newsblur_sessionid" and not cookie.is_expired()
                for cookie in self.cookies
            ):
                raise AuthenticationError(
                    "Login did not return a session cookie", "Basic"
                )
            self.login_pending = False
            self.auth_changed = True
        elif self.auth["kind"] == "none" and not any(
            cookie.name == "newsblur_sessionid" and not cookie.is_expired()
            for cookie in self.cookies
        ):
            raise AuthenticationError("Sign-in required", "Basic")

    def request(
        self,
        path: str,
        *,
        params: dict | None = None,
        data: list[tuple[str, str]] | None = None,
    ) -> object:
        url = self.base_url + path
        if params:
            url += "?" + urllib.parse.urlencode(params)
        body = urllib.parse.urlencode(data).encode() if data is not None else None
        request = urllib.request.Request(
            url, data=body, headers={"User-Agent": USER_AGENT}
        )
        # Keep API passwords and cookie sessions on this exact HTTPS origin.
        request.rss_auth = {"kind": "none"}
        # Basic here means an API login, not an HTTP Basic request.
        if self.auth["kind"] != "basic":
            attach_auth(request, self.auth)
        try:
            with self.opener.open(request, timeout=20) as response:
                if (
                    urllib.parse.urlsplit(response.url).path in {"/", "/login"}
                    and path != "/api/login"
                ):
                    raise AuthenticationError("Session expired", "Basic")
                result = json.load(response)
        except urllib.error.HTTPError as exc:
            exc.close()
            if exc.code in (401, 403):
                raise AuthenticationError(
                    "Session or credentials rejected", "Basic"
                ) from exc
            raise ReaderError(f"HTTP {exc.code} on {path}") from exc
        except (OSError, TimeoutError) as exc:
            raise ReaderError(f"Network error: {type(exc).__name__}") from exc
        except (ValueError, UnicodeError) as exc:
            raise ReaderError(
                f"Unexpected API response on {path} (possibly expired session)"
            ) from exc
        if isinstance(result, dict) and result.get("code") in (-1, -2):
            if path == "/api/login":
                raise AuthenticationError("Credentials rejected", "Basic")
            raise ReaderError(str(result.get("message") or "API rejected the request"))
        return result

    def feeds(self) -> dict:
        self.ensure_session()
        result = self.request(
            "/reader/feeds",
            params={"include_favicons": "false", "update_counts": "true"},
        )
        if not isinstance(result, dict) or not isinstance(
            result.get("feeds"), (dict, list)
        ):
            raise ReaderError("API returned an invalid library")
        feeds = (
            result["feeds"].values()
            if isinstance(result["feeds"], dict)
            else result["feeds"]
        )
        normalized = {}
        for feed in feeds:
            if not isinstance(feed, dict) or "id" not in feed:
                raise ReaderError("API returned invalid feed metadata")
            normalized[str(feed["id"])] = {
                "id": feed["id"],
                "feed_title": feed.get("feed_title") or feed.get("title"),
                "unread": sum(int(feed.get(key) or 0) for key in ("ps", "nt")),
            }
        if not isinstance(result.get("folders", []), list):
            raise ReaderError("API returned an invalid folder layout")
        return {"feeds": normalized, "folders": result.get("folders", [])}

    def body(self, story: dict) -> str:
        if "story_content" in story:
            return story["story_content"] or ""
        response = self.request(
            "/reader/river_stories", params={"h": story["story_hash"]}
        )
        matches = response.get("stories", []) if isinstance(response, dict) else []
        if not isinstance(matches, list):
            raise ReaderError("API returned invalid story content")
        match = next(
            (
                value
                for value in matches
                if isinstance(value, dict)
                and value.get("story_hash") == story["story_hash"]
            ),
            None,
        )
        if match is None or not isinstance(match.get("story_content"), str):
            raise ReaderError(
                "Story content is no longer available; Ctrl-S will refresh the list"
            )
        return match["story_content"]

    def stories(self, feed_id: str, page: int, read_filter: str) -> StoryBatch:
        self.ensure_session()
        response = self.request(
            f"/reader/feed/{feed_id}",
            params={
                "page": page,
                "read_filter": read_filter,
                "include_hidden": "false",
            },
        )
        if not isinstance(response, dict) or not isinstance(
            response.get("stories"), list
        ):
            raise ReaderError("API returned an invalid story batch")
        if any(
            not isinstance(story, dict)
            or not isinstance(story.get("story_hash"), str)
            or not story["story_hash"]
            for story in response["stories"]
        ):
            raise ReaderError("API returned a story without a usable identity")
        try:
            hidden = max(0, int(response.get("hidden_stories_count") or 0))
        except (TypeError, ValueError) as exc:
            raise ReaderError("API returned invalid paging metadata") from exc
        return StoryBatch(response["stories"], hidden)

    def mark(self, hashes: list[str], unread: bool) -> list[str]:
        endpoint = (
            "/reader/mark_story_hash_as_unread"
            if unread
            else "/reader/mark_story_hashes_as_read"
        )
        hashes = list(dict.fromkeys(hashes))
        confirmed = []
        for start in range(0, len(hashes), MARK_BATCH_SIZE):
            batch = hashes[start : start + MARK_BATCH_SIZE]
            try:
                result = self.request(
                    endpoint, data=[("story_hash", value) for value in batch]
                )
            except ReaderError as exc:
                raise MarkError(str(exc), confirmed) from exc
            accepted, error = self.mark_acknowledgments(result, batch)
            confirmed.extend(accepted)
            if error:
                raise MarkError(error, confirmed)
        return confirmed

    @staticmethod
    def mark_acknowledgments(
        result: object, requested: list[str]
    ) -> tuple[list[str], str]:
        fallback = "Server did not confirm every read-state change"
        if isinstance(result, dict) and result.get("code") == 1:
            return requested, ""
        if not isinstance(result, list):
            return [], fallback
        requested_hashes = set(requested)
        succeeded, failed = set(), set()
        error = ""
        for row in result:
            if not isinstance(row, dict):
                error = error or fallback
                continue
            story_hash = row.get("story_hash")
            if not isinstance(story_hash, str) or story_hash not in requested_hashes:
                error = error or fallback
                continue
            if row.get("code") == 1:
                succeeded.add(story_hash)
            else:
                failed.add(story_hash)
                error = error or str(row.get("message") or fallback)
        accepted = [key for key in requested if key in succeeded and key not in failed]
        if len(accepted) != len(requested):
            error = error or fallback
        return accepted, error

    def mark_feed(self, feed_id: str) -> None:
        result = self.request("/reader/mark_feed_as_read", data=[("feed_id", feed_id)])
        if not isinstance(result, dict) or result.get("code") != 1:
            raise ReaderError("Server did not confirm marking the feed read")
