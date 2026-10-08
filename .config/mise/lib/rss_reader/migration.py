"""One-time migration of the former subscription registry and account session."""

from pathlib import Path

from . import common

LEGACY_COOKIE = Path.home() / ".local/state/newsblur-fzf/cookies.txt"


def migrate() -> None:
    from .registry import descriptor, save_sources

    legacy = common.DATA_DIR / "subscriptions.json"
    cookie = LEGACY_COOKIE
    # Do not resurrect removed sources or disturb an already initialized registry.
    if common.SOURCES_FILE.exists():
        return
    values = []
    if legacy.exists():
        stored = common.private_json(legacy, {})
        feeds = stored.get("feeds") if isinstance(stored, dict) else None
        if not isinstance(feeds, list):
            raise common.ReaderError("Invalid legacy subscription registry")
        values.extend(dict(feed, type="feed") for feed in feeds)
    if cookie.exists():
        if cookie.is_symlink() or cookie.stat().st_mode & 0o077:
            raise common.ReaderError(
                "Unsafe legacy session permissions (expected 0600)"
            )
        config = descriptor("https://www.newsblur.com", "newsblur", "NewsBlur")
        values.append(config)
        common.private_directory(common.STATE_DIR)
        common.atomic_write(
            common.STATE_DIR / f"session-{config['id']}.cookies", cookie.read_text()
        )
    if values:
        save_sources(values)
        state = common.private_json(common.READ_FILE, {})
        if state:
            common.save_private_json(
                common.READ_FILE,
                {
                    key: [value.removeprefix("direct:") for value in hashes]
                    for key, hashes in state.items()
                },
            )
        legacy.unlink(missing_ok=True)
        cookie.unlink(missing_ok=True)
