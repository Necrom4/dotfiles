"""One registry and setup flow for all source types."""

from __future__ import annotations

import hashlib
import urllib.parse

from . import common
from .auth import authenticated, saved_auth, without_auth_query
from .common import SECRET_QUERY_KEYS, ReaderError, auth_key
from .sources import ADAPTERS, create, source_type


def sources() -> list[dict]:
    configured = common.private_json(common.SOURCES_FILE, {"sources": []})
    values = configured.get("sources") if isinstance(configured, dict) else None
    if not isinstance(values, list):
        raise ReaderError("Invalid source registry")
    for value in values:
        if (
            not isinstance(value, dict)
            or value.get("type") not in ADAPTERS
            or any(
                not isinstance(value.get(key), str) or not value[key]
                for key in ("id", "title", "url")
            )
        ):
            raise ReaderError("Sources require a type, id, title and URL")
        common.validate_url(value["url"])
    return values


def save_sources(values: list[dict]) -> None:
    common.save_private_json(common.SOURCES_FILE, {"sources": values})


def subscription_key(url: str) -> str:
    parts = urllib.parse.urlsplit(url)
    query = sorted(
        (key, value)
        for key, value in urllib.parse.parse_qsl(parts.query, keep_blank_values=True)
        if key.lower() not in SECRET_QUERY_KEYS
    )
    return urllib.parse.urlunsplit(
        (
            parts.scheme.lower(),
            parts.netloc.lower(),
            parts.path.rstrip("/") or "/",
            urllib.parse.urlencode(query),
            "",
        )
    )


def descriptor(url: str, kind: str | None = None, name: str | None = None) -> dict:
    url = url.strip()
    common.validate_url(url)
    kind = kind or source_type(url)
    if kind not in ADAPTERS:
        raise ReaderError("Unknown source type")
    key = kind + ":" + subscription_key(url)
    title = name or (
        "NewsBlur" if kind == "newsblur" else urllib.parse.urlsplit(url).hostname
    )
    return {
        "id": hashlib.sha256(key.encode()).hexdigest()[:24],
        "type": kind,
        "title": title,
        "url": url,
    }


def add_source(
    url: str,
    name: str | None = None,
    *,
    kind: str | None = None,
    auth: dict | None = None,
    no_prompt: bool = False,
    no_check: bool = False,
) -> None:
    values = sources()
    config = descriptor(url, kind, name)
    effective = (
        auth
        if auth is not None
        else saved_auth().get(auth_key(config["url"]), {"kind": "none"})
    )
    key = subscription_key(without_auth_query(config["url"], effective))
    existing = next(
        (
            value
            for value in values
            if value["type"] == config["type"]
            and subscription_key(without_auth_query(value["url"], effective)) == key
        ),
        None,
    )
    if existing:
        config = dict(existing, url=config["url"], title=name or existing["title"])
    config.pop("pagination", None)
    source = create(config, auth=auth)
    source.prepare()
    if no_check:
        info = {"title": config["title"], "details": "not checked"}
        if source.auth_changed:
            source.commit_auth(validated=False)
    else:
        info = authenticated(source, source.validate, no_prompt=no_prompt)
    config["title"] = name or (existing["title"] if existing else info["title"])
    config["url"] = without_auth_query(config["url"], source.auth)
    if existing:
        values[values.index(existing)] = config
    else:
        values.append(config)
    save_sources(values)
    print(
        f"{'Updated' if existing else 'Added'} {common.clean(config['title'])} ({info['details']})."
    )


def remove_source(url: str) -> None:
    values = sources()
    key = subscription_key(url)
    removed = [value for value in values if subscription_key(value["url"]) == key]
    if not removed:
        raise ReaderError("Source is not registered")
    remaining = [value for value in values if value not in removed]
    if remaining:
        save_sources(remaining)
    else:
        common.SOURCES_FILE.unlink(missing_ok=True)
    from .auth import save_auth

    for value in removed:
        if not any(
            auth_key(other["url"]) == auth_key(value["url"]) for other in remaining
        ):
            save_auth(value["url"], {"kind": "none"})
        session = common.STATE_DIR / f"session-{value['id']}.cookies"
        session.unlink(missing_ok=True)
    state = common.private_json(common.READ_FILE, {})
    if isinstance(state, dict):
        for value in removed:
            state.pop(value["id"], None)
        if state:
            common.save_private_json(common.READ_FILE, state)
        else:
            common.READ_FILE.unlink(missing_ok=True)
    print(f"Removed {len(removed)} source(s).")
