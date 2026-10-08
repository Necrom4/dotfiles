"""Shared credential handling; adapters decide how authentication is applied."""

from __future__ import annotations

import base64
import getpass
import re
import urllib.parse
import urllib.request

from . import common
from .common import (
    SECRET_QUERY_KEYS,
    AuthenticationError,
    ReaderError,
    auth_key,
    url_origin,
)

AUTH_METHODS = ("token", "basic", "bearer", "header", "query", "none")


def validate_auth(auth: dict) -> None:
    if not isinstance(auth, dict) or auth.get("kind") not in AUTH_METHODS[1:]:
        raise ReaderError("Invalid saved authentication method")
    kind = auth["kind"]
    if kind == "none":
        return
    secret = auth.get("secret")
    if not isinstance(secret, str) or not secret or "\r" in secret or "\n" in secret:
        raise ReaderError(
            "Authentication requires a non-empty password/token without line breaks"
        )
    if kind == "basic":
        username = auth.get("username")
        if (
            not isinstance(username, str)
            or not username
            or any(c in username for c in ":\r\n")
        ):
            raise ReaderError("Basic authentication requires a valid username")
    if kind in {"header", "query"}:
        name = auth.get("name")
        if not isinstance(name, str) or not name or any(c in name for c in "\r\n"):
            raise ReaderError("Authentication requires a valid header/parameter name")
        if kind == "header" and not re.fullmatch(r"[!#$%&'*+\-.^_`|~0-9A-Za-z]+", name):
            raise ReaderError("Invalid authentication header name")
        if kind == "header" and name.lower() in {
            "host",
            "cookie",
            "referer",
            "content-length",
            "proxy-authorization",
        }:
            raise ReaderError(
                "Use a dedicated authentication header, not a routing or cookie header"
            )


def saved_auth() -> dict:
    stored = common.private_json(common.AUTH_FILE, {})
    if not isinstance(stored, dict):
        raise ReaderError("Invalid saved authentication")
    for value in stored.values():
        validate_auth(value)
    return stored


def save_auth(url: str, auth: dict) -> None:
    validate_auth(auth)
    stored = saved_auth()
    if auth["kind"] == "none":
        stored.pop(auth_key(url), None)
    else:
        stored[auth_key(url)] = auth
    if stored:
        common.save_private_json(common.AUTH_FILE, stored)
    elif common.AUTH_FILE.exists():
        common.AUTH_FILE.unlink()


def make_auth(
    kind: str, secret: str = "", *, name: str | None = None, username: str | None = None
) -> dict:
    if kind == "token":
        if secret.startswith("glft-"):
            kind, name = "query", "feed_token"
        elif secret.startswith("glpat-"):
            kind, name = "header", "PRIVATE-TOKEN"
        else:
            kind = "bearer"
    auth = {"kind": kind}
    if kind != "none":
        auth["secret"] = secret
    if kind in {"header", "query"}:
        auth["name"] = name
    if kind == "basic":
        auth["username"] = username
    validate_auth(auth)
    return auth


def input_auth(
    kind: str | None = None,
    *,
    name: str | None = None,
    username: str | None = None,
    secret: str | None = None,
    no_prompt: bool = False,
) -> dict:
    if kind is None:
        if no_prompt:
            raise ReaderError("Non-interactive authentication requires --auth")
        kind = (
            input("Authentication [token/basic/bearer/header/query] (token): ").strip()
            or "token"
        )
    if kind not in AUTH_METHODS:
        raise ReaderError("Unknown authentication method")
    if kind == "none":
        return make_auth(kind)
    if no_prompt and (
        secret is None
        or (kind == "basic" and not username)
        or (kind in {"header", "query"} and not name)
    ):
        raise ReaderError(
            "Non-interactive authentication requires --auth-env and any --username/--auth-name"
        )
    if kind == "basic" and not username:
        username = input("Username: ").strip()
    if kind in {"header", "query"} and not name:
        name = input(
            "Header name: " if kind == "header" else "Query parameter name: "
        ).strip()
    if secret is None:
        secret = getpass.getpass(
            "Password: " if kind == "basic" else "Token (hidden): "
        )
    return make_auth(kind, secret, name=name, username=username)


def without_auth_query(url: str, auth: dict) -> str:
    names = {auth["name"].lower()} if auth["kind"] == "query" else set()
    if auth.get("name", "").lower() in {"feed_token", "private-token"}:
        names.update({"feed_token", "rss_token"})
    if not names:
        return url
    parts = urllib.parse.urlsplit(url)
    query = [
        (key, value)
        for key, value in urllib.parse.parse_qsl(parts.query, keep_blank_values=True)
        if key.lower() not in names
    ]
    return urllib.parse.urlunsplit(
        (parts.scheme, parts.netloc, parts.path, urllib.parse.urlencode(query), "")
    )


def attach_auth(request, auth: dict) -> None:
    validate_auth(auth)
    if auth["kind"] == "none":
        return
    if urllib.parse.urlsplit(request.full_url).scheme != "https":
        raise ReaderError("Saved authentication requires HTTPS")
    request.full_url = without_auth_query(request.full_url, auth)
    kind, secret = auth["kind"], auth["secret"]
    if kind == "query":
        parts = urllib.parse.urlsplit(request.full_url)
        query = urllib.parse.parse_qsl(parts.query, keep_blank_values=True) + [
            (auth["name"], secret)
        ]
        request.full_url = urllib.parse.urlunsplit(
            (parts.scheme, parts.netloc, parts.path, urllib.parse.urlencode(query), "")
        )
    elif kind == "basic":
        value = base64.b64encode(f"{auth['username']}:{secret}".encode()).decode()
        request.add_header("Authorization", "Basic " + value)
    elif kind == "bearer":
        request.add_header("Authorization", "Bearer " + secret)
    else:
        request.add_header(auth["name"], secret)
    request.rss_auth = auth


def authenticated(source, operation, *, no_prompt: bool = False):
    """Run any source operation, handling authentication through the same interface."""
    try:
        result = operation()
    except AuthenticationError as error:
        if no_prompt:
            raise
        for attempt in range(3):
            print(
                f"Authentication required for {urllib.parse.urlsplit(source.config['url']).netloc}."
            )
            method = "basic" if error.challenge.lower().startswith("basic") else None
            source.authenticate(input_auth(method))
            try:
                result = operation()
            except AuthenticationError as exc:
                error = exc
                if attempt < 2:
                    print("Authentication rejected; try again.")
            else:
                break
        else:
            raise error  # noqa: TRY201 -- report the most recent rejected attempt
    if source.auth_changed:
        source.commit_auth(validated=True)
    return result


class FeedRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        auth = getattr(req, "rss_auth", None)
        sensitive = auth is not None or any(
            key.lower() in SECRET_QUERY_KEYS
            for key, _ in urllib.parse.parse_qsl(
                urllib.parse.urlsplit(req.full_url).query
            )
        )
        if sensitive and url_origin(req.full_url) != url_origin(newurl):
            raise ReaderError(
                "Refusing to forward source credentials to a different host, port or insecure URL"
            )
        redirected = super().redirect_request(req, fp, code, msg, headers, newurl)
        if redirected is not None and auth is not None:
            attach_auth(redirected, auth)
            redirected.rss_auth = auth
        return redirected
