"""CLI setup; source operations and terminal application remain separate."""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

from . import app, registry
from .auth import AUTH_METHODS, input_auth
from .common import ReaderError
from .migration import migrate


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Read configured sources in an fzf terminal reader."
    )
    parser.add_argument("--preview", type=Path, help=argparse.SUPPRESS)
    action = parser.add_mutually_exclusive_group()
    action.add_argument(
        "--url",
        nargs="?",
        const="",
        metavar="URL",
        help="Add or update a source; omit URL to prompt",
    )
    action.add_argument(
        "--remove", metavar="URL", help="Remove a source and unused credentials"
    )
    parser.add_argument(
        "--source",
        choices=tuple(registry.ADAPTERS),
        help="Adapter override; does not subscribe feeds in NewsBlur",
    )
    parser.add_argument("--name", help="Source display name")
    parser.add_argument(
        "--auth",
        choices=AUTH_METHODS,
        metavar="METHOD",
        help="token (auto), basic, bearer, header, query or none",
    )
    parser.add_argument(
        "--auth-name", metavar="NAME", help="Header or query parameter name"
    )
    parser.add_argument(
        "--auth-env",
        metavar="VAR",
        help="Read the password/token from an environment variable",
    )
    parser.add_argument("--username", help="Account or HTTP Basic username")
    parser.add_argument(
        "--no-prompt", action="store_true", help="Never prompt for setup input"
    )
    parser.add_argument(
        "--no-check", action="store_true", help="Save without validating the source"
    )
    args = parser.parse_args(argv)
    if (
        any(
            (
                args.source,
                args.name,
                args.auth,
                args.auth_name,
                args.auth_env,
                args.username,
                args.no_check,
            )
        )
        and args.url is None
    ):
        parser.error("setup options require --url")
    if any((args.auth_name, args.auth_env, args.username)) and args.auth is None:
        parser.error("authentication options require --auth")
    if args.auth_name and args.auth not in {"header", "query"}:
        parser.error("--auth-name requires --auth header or query")
    if args.username and args.auth != "basic":
        parser.error("--username requires --auth basic")
    if args.auth == "none" and args.auth_env:
        parser.error("--auth none does not accept --auth-env")
    if args.no_prompt and (args.url is None or args.url == ""):
        parser.error("--no-prompt requires an explicit URL")
    try:
        if args.preview is None:
            migrate()
        if args.preview is not None:
            print(app.lazy_preview(args.preview))
        elif args.remove:
            registry.remove_source(args.remove)
        elif args.url is not None:
            url = args.url or input("Source URL: ")
            auth = None
            if args.auth is not None:
                secret = None
                if args.auth_env:
                    secret = os.environ.get(args.auth_env)
                    if not secret:
                        raise ReaderError(
                            f"Authentication environment variable {args.auth_env} is not set"
                        )
                auth = input_auth(
                    args.auth,
                    name=args.auth_name,
                    username=args.username,
                    secret=secret,
                    no_prompt=args.no_prompt,
                )
            registry.add_source(
                url,
                args.name,
                kind=args.source,
                auth=auth,
                no_prompt=args.no_prompt,
                no_check=args.no_check,
            )
        else:
            app.run()
    except (ReaderError, OSError, KeyboardInterrupt, EOFError) as exc:
        print(f"\n{exc or 'Cancelled'}", file=sys.stderr)
        return 1
    return 0
