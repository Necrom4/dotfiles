"""Shared errors, paging metadata and private application storage."""

from __future__ import annotations

import html
import json
import os
import re
import tempfile
import urllib.parse
from pathlib import Path

DATA_DIR = (
    Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share")) / "rss-fzf"
)
STATE_DIR = (
    Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "rss-fzf"
)
SOURCES_FILE = DATA_DIR / "sources.json"
AUTH_FILE = DATA_DIR / "auth.json"
READ_FILE = STATE_DIR / "read.json"
LAUNCHER = Path(__file__).resolve().parents[2] / "tasks/rss"
USER_AGENT = "rss-fzf/1.0 (personal terminal reader)"
SECRET_QUERY_KEYS = frozenset(
    {"feed_token", "rss_token", "token", "access_token", "key", "api_key"}
)


class ReaderError(Exception):
    pass


class AuthenticationError(ReaderError):
    def __init__(self, message: str, challenge: str = ""):
        super().__init__(message)
        self.challenge = challenge


class MarkError(ReaderError):
    def __init__(self, message: str, confirmed: list[str]):
        super().__init__(message)
        self.confirmed = confirmed


class StoryBatch(list):
    """Canonical stories plus whether the source can supply another page."""

    def __init__(
        self,
        stories: list[dict],
        hidden_count: int = 0,
        *,
        has_more: bool | None = None,
    ):
        super().__init__(stories)
        self.has_more = (
            bool(stories) or bool(hidden_count) if has_more is None else has_more
        )


def has_more(batch: list[dict]) -> bool:
    return getattr(batch, "has_more", bool(batch))


def clean(value: object) -> str:
    return re.sub(r"\s+", " ", html.unescape(str(value or ""))).strip()


def private_directory(path: Path) -> None:
    path.mkdir(mode=0o700, parents=True, exist_ok=True)
    if path.is_symlink() or path.stat().st_mode & 0o077:
        raise ReaderError(f"Unsafe state directory permissions: {path} (expected 0700)")


def atomic_write(path: Path, text: str) -> None:
    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        dir=path.parent,
        prefix=path.name + ".",
        delete=False,
    ) as temporary:
        pending = Path(temporary.name)
        try:
            temporary.write(text)
            temporary.close()
            pending.replace(path)
        finally:
            pending.unlink(missing_ok=True)


def private_json(path: Path, default):
    if not path.exists():
        return default
    if path.is_symlink() or path.stat().st_mode & 0o077:
        raise ReaderError(f"Unsafe file permissions: {path} (expected 0600)")
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError) as exc:
        raise ReaderError(f"Could not read {path.name}") from exc


def save_private_json(path: Path, data) -> None:
    private_directory(path.parent)
    if path.is_symlink():
        raise ReaderError(f"Refusing to replace a symlinked file: {path}")
    atomic_write(path, json.dumps(data, indent=2) + "\n")


def url_origin(url: str) -> tuple[str, str, int]:
    parts = urllib.parse.urlsplit(url)
    return (
        parts.scheme.lower(),
        (parts.hostname or "").lower(),
        parts.port
        if parts.port is not None
        else (443 if parts.scheme == "https" else 80),
    )


def auth_key(url: str) -> str:
    scheme, host, port = url_origin(url)
    return f"{scheme}://{host}:{port}"


def validate_url(url: str) -> None:
    try:
        parts = urllib.parse.urlsplit(url)
        valid = (
            parts.scheme in {"http", "https"}
            and parts.hostname
            and not parts.username
            and not parts.password
        )
        _ = parts.port
    except ValueError:
        valid = False
    if not valid or any(character.isspace() for character in url):
        raise ReaderError(
            "Provide a complete HTTP(S) URL without embedded username/password"
        )
