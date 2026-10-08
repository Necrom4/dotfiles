"""Adapter factory. Application code only uses the common Source interface."""

from urllib.parse import urlsplit

from .feed import FeedSource
from .gitlab import GitLabFeedSource, is_activity_feed
from .newsblur import NewsBlurSource

ADAPTERS = {"feed": FeedSource, "newsblur": NewsBlurSource}


def source_type(url: str) -> str:
    parts = urlsplit(url)
    if parts.hostname in {"newsblur.com", "www.newsblur.com"} and parts.path in {
        "",
        "/",
    }:
        return "newsblur"
    return "feed"


def create(config: dict, *, auth: dict | None = None):
    if config["type"] == "feed" and is_activity_feed(config["url"]):
        return GitLabFeedSource(config, auth=auth)
    return ADAPTERS[config["type"]](config, auth=auth)
