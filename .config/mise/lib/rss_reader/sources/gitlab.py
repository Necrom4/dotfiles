"""GitLab activity Atom feeds expose offset pagination without next links."""

import urllib.parse

from ..common import ReaderError, StoryBatch
from .feed import FeedSource


def is_activity_feed(url: str) -> bool:
    # Recognizable GitLab endpoints, including instances hosted below a URL prefix.
    path = urllib.parse.urlsplit(url).path.rstrip("/")
    return path.endswith(("/dashboard/projects.atom", "/dashboard/activity.atom"))


class GitLabFeedSource(FeedSource):
    def __init__(self, config: dict, *, auth: dict | None = None):
        offsets = [
            value
            for key, value in urllib.parse.parse_qsl(
                urllib.parse.urlsplit(config["url"]).query
            )
            if key == "offset"
        ]
        if len(offsets) > 1 or any(
            not value.isascii() or not value.isdecimal() for value in offsets
        ):
            raise ReaderError("GitLab activity offset must be a non-negative integer")
        super().__init__(config, auth=auth)

    def stories(self, feed_id: str, page: int, read_filter: str) -> StoryBatch:
        batch = super().stories(feed_id, page, read_filter)
        if str(feed_id) != self.feed_id or not batch:
            return StoryBatch(batch, has_more=False)
        current = urllib.parse.urlsplit(self.page_urls[page])
        query = urllib.parse.parse_qsl(current.query, keep_blank_values=True)
        offset = next((int(value) for key, value in query if key == "offset"), 0)
        query = [(key, value) for key, value in query if key != "offset"]
        query.append(("offset", str(offset + len(batch))))
        self.page_urls[page + 1] = urllib.parse.urlunsplit(
            (
                current.scheme,
                current.netloc,
                current.path,
                urllib.parse.urlencode(query),
                "",
            )
        )
        return StoryBatch(batch, has_more=True)
