"""The contract implemented by every source adapter."""

from __future__ import annotations

import urllib.request

from ..auth import attach_auth, save_auth, saved_auth, validate_auth
from ..common import auth_key


class Source:
    def __init__(self, config: dict, *, auth: dict | None = None):
        self.config = config
        self.title = config["title"]
        self.auth = (
            auth
            if auth is not None
            else saved_auth().get(auth_key(config["url"]), {"kind": "none"})
        )
        self.auth_changed = auth is not None

    def authenticate(self, auth: dict) -> None:
        validate_auth(auth)
        self.auth = auth
        self.auth_changed = True
        self.prepare()

    def prepare(self) -> None:
        attach_auth(urllib.request.Request(self.config["url"]), self.auth)

    def commit_auth(self, *, validated: bool) -> None:
        save_auth(self.config["url"], self.auth)
        self.auth_changed = False

    def validate(self) -> dict:
        library = self.feeds()
        return {"title": self.title, "details": f"{len(library['feeds'])} feeds"}

    def feeds(self) -> dict:
        raise NotImplementedError

    def stories(self, feed_id: str, page: int, read_filter: str):
        raise NotImplementedError

    def body(self, story: dict) -> str:
        raise NotImplementedError

    def mark(self, hashes: list[str], unread: bool) -> list[str]:
        raise NotImplementedError

    def mark_feed(self, feed_id: str) -> None:
        raise NotImplementedError
