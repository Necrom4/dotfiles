"""RSS/Atom adapter: XML, next-link pagination and local read state."""

from __future__ import annotations

import copy
import hashlib
import html
import urllib.error
import urllib.parse
import urllib.request
from xml.etree import ElementTree

from .. import common
from ..auth import FeedRedirect, attach_auth
from ..common import (
    USER_AGENT,
    AuthenticationError,
    ReaderError,
    StoryBatch,
    url_origin,
)
from .base import Source


class FeedSource(Source):
    def __init__(self, config: dict, *, auth: dict | None = None):
        super().__init__(config, auth=auth)
        self.feed_id = config["id"]
        self.opener = urllib.request.build_opener(FeedRedirect())
        self.page_urls = {1: config["url"]}

    def feeds(self) -> dict:
        return {
            "feeds": {
                self.feed_id: {
                    "id": self.feed_id,
                    "feed_title": self.title,
                    "unread": 0,
                }
            },
            "folders": [],
            "standalone": True,
        }

    def validate(self) -> dict:
        stories = self.stories(self.feed_id, 1, "all")
        return {"title": self.title, "details": f"{len(stories)} stories"}

    def open(self, request, *, timeout: int):
        return self.opener.open(request, timeout=timeout)

    def request(self, page: int = 1):
        url = self.page_urls.get(page)
        if url is None:
            return None
        if self.auth["kind"] != "none" and url_origin(url) != url_origin(
            self.config["url"]
        ):
            raise ReaderError(
                "Refusing to forward source credentials to a pagination link on another origin"
            )
        common.validate_url(url)
        request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        attach_auth(request, self.auth)
        return request

    def read_state(self) -> dict:
        stored = common.private_json(common.READ_FILE, {})
        if not isinstance(stored, dict) or any(
            not isinstance(values, list)
            or any(not isinstance(value, str) for value in values)
            for values in stored.values()
        ):
            raise ReaderError("Invalid local read state")
        return stored

    def read_hashes(self) -> set[str]:
        return set(self.read_state().get(self.feed_id, []))

    def save_hashes(self, hashes: set[str]) -> None:
        stored = self.read_state()
        stored[self.feed_id] = sorted(hashes)
        common.save_private_json(common.READ_FILE, stored)

    @staticmethod
    def child_text(entry, names: tuple[str, ...]) -> str:
        for name in names:
            for child in entry:
                if child.tag.rsplit("}", 1)[-1] != name:
                    continue
                if child.get("type") == "xhtml":
                    fragment = copy.deepcopy(child)
                    for node in fragment.iter():
                        node.tag = node.tag.rsplit("}", 1)[-1]
                    return "".join(
                        ElementTree.tostring(node, encoding="unicode", method="html")
                        for node in fragment
                    )
                return "".join(child.itertext()).strip()
        return ""

    @staticmethod
    def link(entry, relation: str = "alternate") -> str:
        for child in entry:
            if child.tag.rsplit("}", 1)[-1] != "link":
                continue
            if child.get("href") and child.get("rel", "alternate") == relation:
                return child.get("href", "")
            if relation == "alternate" and child.text:
                return child.text.strip()
        return ""

    def stories(self, feed_id: str, page: int, read_filter: str) -> StoryBatch:
        if str(feed_id) != self.feed_id:
            return StoryBatch([], has_more=False)
        if page == 1:
            self.page_urls = {1: self.config["url"]}
        request = self.request(page)
        if request is None:
            return StoryBatch([], has_more=False)
        try:
            with self.open(request, timeout=20) as response:
                data = response.read(3_000_001)
                response_url = getattr(response, "url", request.full_url)
        except urllib.error.HTTPError as exc:
            request_id = exc.headers.get("X-Request-Id", "")
            challenge = exc.headers.get("WWW-Authenticate", "")
            trace = f" (server request ID: {request_id})" if request_id else ""
            exc.close()
            if exc.code in (401, 403):
                raise AuthenticationError(
                    f"HTTP {exc.code}: {self.title} rejected authentication{trace}",
                    challenge,
                ) from exc
            raise ReaderError(f"HTTP {exc.code} fetching {self.title}{trace}") from exc
        except (urllib.error.URLError, OSError, TimeoutError) as exc:
            raise ReaderError(
                f"Could not reach {self.title} ({type(exc).__name__})"
            ) from exc
        if len(data) > 3_000_000:
            raise ReaderError(f"{self.title} feed is too large")
        try:
            root = ElementTree.fromstring(data)
        except ElementTree.ParseError as exc:
            raise ReaderError(f"{self.title} did not return valid Atom/RSS") from exc
        if root.tag.rsplit("}", 1)[-1] not in {"feed", "rss", "RDF"}:
            raise ReaderError(
                f"{self.title} returned a document that is not Atom/RSS (possibly a login page)"
            )
        channel = next(
            (item for item in root if item.tag.rsplit("}", 1)[-1] == "channel"), root
        )
        self.title = self.child_text(channel, ("title",)) or self.title
        next_url = self.link(root, "next") or self.link(channel, "next")
        if next_url:
            self.page_urls[page + 1] = urllib.parse.urljoin(response_url, next_url)
        read = self.read_hashes()
        entries = [
            entry
            for entry in root.iter()
            if entry.tag.rsplit("}", 1)[-1] in {"entry", "item"}
        ]
        stories = []
        for entry in entries:
            title = self.child_text(entry, ("title",))
            link = self.link(entry)
            url = urllib.parse.urljoin(response_url, link) if link else ""
            identity = (
                self.child_text(entry, ("id", "guid"))
                or url
                or title + self.child_text(entry, ("published", "pubDate"))
            )
            story_hash = (
                f"{self.feed_id}:{hashlib.sha256(identity.encode()).hexdigest()}"
            )
            body = self.child_text(
                entry, ("content", "encoded", "description", "summary")
            )
            stories.append(
                {
                    "story_hash": story_hash,
                    "story_title": title,
                    "story_permalink": url,
                    "story_content": body
                    if "<" in body
                    else f"<p>{html.escape(body)}</p>",
                    "story_date": self.child_text(
                        entry, ("updated", "published", "pubDate")
                    ),
                    "read_status": int(story_hash in read),
                }
            )
        return StoryBatch(stories, has_more=bool(next_url))

    def body(self, story: dict) -> str:
        return story.get("story_content", "")

    def mark(self, hashes: list[str], unread: bool) -> list[str]:
        read = self.read_hashes()
        if unread:
            read.difference_update(hashes)
        else:
            read.update(hashes)
        self.save_hashes(read)
        return hashes

    def mark_feed(self, feed_id: str) -> None:
        # This scan can run while the picker fetches later pages. Its cursor must
        # not reset or overwrite the browsing history's pagination links.
        history = copy.copy(self)
        history.page_urls = {1: self.config["url"]}
        hashes = set()
        page = 1
        while True:
            batch = history.stories(feed_id, page, "all")
            identities = {story["story_hash"] for story in batch}
            if batch.has_more and identities and identities <= hashes:
                raise ReaderError(
                    "Server repeated a batch; not all stories could be marked read"
                )
            hashes.update(identities)
            if not batch.has_more:
                self.mark(sorted(hashes), unread=False)
                return
            page += 1
