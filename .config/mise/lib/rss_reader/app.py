"""Source-independent application: paging, read actions, rendering and fzf UI."""

from __future__ import annotations

import html
import ipaddress
import json
import os
import queue
import re
import shlex
import shutil
import socket
import subprocess
import sys
import tempfile
import textwrap
import threading
import urllib.error
import urllib.parse
import urllib.request
import webbrowser
from html.parser import HTMLParser
from pathlib import Path
from typing import NamedTuple, Self

from . import registry
from .auth import authenticated
from .common import (
    LAUNCHER,
    USER_AGENT,
    MarkError,
    ReaderError,
    atomic_write,
    clean,
    has_more,
)
from .sources import create

POLL_INTERVAL = 0.1
STORY_KEYS = "enter,ctrl-o,alt-o,ctrl-f,alt-r,ctrl-s,ctrl-q"
STORY_HINTS = (
    "ctrl-o original page · alt-o browser · ctrl-r/u read/unread · "
    "ctrl-f all/unread · alt-r feed read · ctrl-s sync"
)


def foreground_stories(api, feed_id: str) -> list[dict]:
    return authenticated(api, lambda: api.stories(feed_id, 1, "all"))


def story_count(count: int) -> str:
    return f"{count} {'story' if count == 1 else 'stories'}"


def wrap_header(header: str, width: int) -> str:
    return "\n".join(
        textwrap.fill(line, width=width, break_long_words=False, break_on_hyphens=False)
        for line in header.splitlines()
    )


class ArticleHTML(HTMLParser):
    """Small HTML-to-text fallback for feed bodies and locally fetched pages."""

    BREAKS = frozenset(
        {
            "p",
            "div",
            "section",
            "article",
            "main",
            "br",
            "li",
            "h1",
            "h2",
            "h3",
            "h4",
            "blockquote",
            "pre",
            "tr",
        }
    )
    SKIP = frozenset(
        {"script", "style", "svg", "nav", "footer", "header", "aside", "form"}
    )

    def __init__(self, article_only: bool = False):
        super().__init__(convert_charrefs=True)
        self.chunks: list[str] = []
        self.skipped: list[str] = []
        self.depth = 0
        self.article_only = article_only

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag in self.SKIP:
            self.skipped.append(tag)
        if tag in {"article", "main"}:
            self.depth += 1
        if tag in self.BREAKS and not self.skipped:
            self.chunks.append("\n" if tag != "li" else "\n• ")

    def handle_endtag(self, tag: str) -> None:
        if tag in {"article", "main"}:
            self.depth = max(0, self.depth - 1)
        if tag in self.BREAKS and not self.skipped:
            self.chunks.append("\n")
        if self.skipped and self.skipped[-1] == tag:
            self.skipped.pop()

    def handle_data(self, data: str) -> None:
        if not self.skipped and (not self.article_only or self.depth):
            self.chunks.append(data)

    def text(self) -> str:
        text = "".join(self.chunks).replace("\xa0", " ")
        text = re.sub(r"[ \t]+", " ", text)
        text = re.sub(r" *\n *", "\n", text)
        return re.sub(r"\n{3,}", "\n\n", text).strip()


def html_text(source: str, article_only: bool = False) -> str:
    parser = ArticleHTML(article_only=article_only)
    parser.feed(source)
    return parser.text()


class ArticleFragment(HTMLParser):
    """Keep the first <article> or <main> fragment so links and formatting survive."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=False)
        self.depth = 0
        self.found = False
        self.parts: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if self.depth or (not self.found and tag in ("article", "main")):
            self.found = True
            self.parts.append(self.get_starttag_text())
            if tag not in {
                "area",
                "base",
                "br",
                "col",
                "embed",
                "hr",
                "img",
                "input",
                "link",
                "meta",
                "source",
                "wbr",
            }:
                self.depth += 1

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if self.depth:
            self.parts.append(self.get_starttag_text())

    def handle_endtag(self, tag: str) -> None:
        if self.depth:
            self.parts.append(f"</{tag}>")
            self.depth -= 1

    def handle_data(self, data: str) -> None:
        if self.depth:
            self.parts.append(data)

    def handle_entityref(self, name: str) -> None:
        if self.depth:
            self.parts.append(f"&{name};")

    def handle_charref(self, name: str) -> None:
        if self.depth:
            self.parts.append(f"&#{name};")


def article_document(title: str, url: str, body_html: str) -> str:
    safe_url = html.escape(url, quote=True)
    return (
        "<!doctype html><html><head><meta charset='utf-8'>"
        f"<base href='{safe_url}'><title>{html.escape(title)}</title></head>"
        f"<body><main><h1>{html.escape(title)}</h1><p><a href='{safe_url}'>{safe_url}</a></p>"
        f"<hr>{body_html}</main></body></html>"
    )


def chooser(
    lines: list[str],
    *,
    header: str,
    preview: str | None = None,
    multi: bool = False,
    keys: str = "",
    stream: StoryStream | None = None,
    state: dict | None = None,
) -> tuple[str, list[str]]:
    columns = shutil.get_terminal_size().columns
    # The right-hand preview leaves 40% of the width for fzf's header/list.
    width = max(1, (int(columns * 0.4) if preview else columns) - 6)
    header = wrap_header(header, width)
    args = [
        "fzf",
        "--delimiter=\t",
        "--with-nth=2..",
        "--no-sort",
        "--header",
        header,
        "--expect",
        keys,
    ]
    if multi:
        args.append("--multi")
    if preview:
        args.extend(["--preview", preview, "--preview-window", "right,60%,wrap"])
    if state is not None:
        args.extend(["--print-query", "--query", state.get("query", "")])
    # Let fzf load the user's defaults unchanged, including height and config file.
    if stream is None:
        result = subprocess.run(
            args,
            input="\n".join(lines) + "\n",
            text=True,
            capture_output=True,
            check=False,
        )
    else:
        live = LivePicker(stream, width)
        result = live.run(args, keys, state)
    if result.returncode not in (0, 1, 130):
        raise ReaderError(result.stderr.strip() or "fzf failed")
    # With no matching rows fzf returns 1 even for an --expect action. Preserve
    # actions such as Ctrl-Q rather than confusing them with Back.
    if result.returncode == 130:
        return "escape", []
    output = result.stdout.splitlines()
    if state is not None and output:
        state["query"] = output.pop(0)
    if not output:
        return "escape", []
    return output[0] or "enter", output[1:]


class StorySnapshot(NamedTuple):
    revision: int
    complete: bool
    error: str
    stories: tuple[tuple[int, dict], ...]

    @property
    def status(self) -> str:
        if self.error:
            return self.error
        return "Available history loaded" if self.complete else "Loading more…"


class StoryCollection:
    """Fresh, append-only feed history with one sequential background loader.

    Stable indexes identify stories throughout one visit. All shared story/read
    state belongs here; the picker works from snapshots rather than holding this
    lock while rendering files or sending socket requests.
    """

    def __init__(self, api, feed_id: str, initial: list[dict]) -> None:
        self.api = api
        self.feed_id = feed_id
        self.stories: list[dict] = []
        self.hashes: set[str] = set()
        self.overrides: dict[str, int] = {}
        self.all_read_revision = 0
        self.condition = threading.Condition()
        self.cancel = threading.Event()
        self.paused = threading.Event()
        self.worker = None
        self.error = ""
        self.complete = not has_more(initial)
        self.next_page = 2
        self.last_batch = None
        self.revision = 0
        self.add(initial)

    def add(self, batch: list[dict]) -> int:
        with self.condition:
            added = 0
            for story in batch:
                key = story.get("story_hash")
                if not key or key in self.hashes:
                    continue
                if key in self.overrides:
                    story["read_status"] = self.overrides[key]
                self.hashes.add(key)
                self.stories.append(story)
                added += 1
            if added:
                self.revision += 1
            return added

    def snapshot(self, read_filter: str) -> StorySnapshot:
        """Copy shared state under the lock; consumers do I/O after releasing it."""
        with self.condition:
            stories = tuple(
                (index, dict(story))
                for index, story in enumerate(self.stories)
                if read_filter == "all" or story.get("read_status") == 0
            )
            return StorySnapshot(self.revision, self.complete, self.error, stories)

    def select(self, indexes: list[int]) -> list[dict]:
        with self.condition:
            return [
                self.stories[index]
                for index in dict.fromkeys(indexes)
                if 0 <= index < len(self.stories)
            ]

    def mark_confirmed(self, selected: list[dict], *, unread: bool) -> None:
        """The API owns batching; even partial acknowledgments update local state."""
        try:
            self.api.mark([story["story_hash"] for story in selected], unread=unread)
        except MarkError as exc:
            confirmed = set(exc.confirmed)
            self.mark(
                [story for story in selected if story["story_hash"] in confirmed],
                unread=unread,
            )
            raise
        self.mark(selected, unread=unread)

    def start(self) -> None:
        with self.condition:
            if self.cancel.is_set():
                return
            self.resume()
            if self.worker is None and not self.complete and not self.error:
                self.worker = threading.Thread(target=self.load, daemon=True)
                self.worker.start()

    def load(self) -> None:
        try:
            while not self.cancel.is_set():
                with self.condition:
                    while self.paused.is_set() and not self.cancel.is_set():
                        self.condition.wait()
                    read_revision = self.all_read_revision
                if self.cancel.is_set():
                    return
                batch = self.api.stories(self.feed_id, self.next_page, "all")
                with self.condition:
                    if self.cancel.is_set():
                        return
                    signature = tuple(story.get("story_hash") for story in batch)
                    repeated = bool(batch) and signature == self.last_batch
                    self.last_batch = signature
                    # Only a request already in flight when "mark feed read"
                    # happened can have stale flags. Later requests are authoritative
                    # and may legitimately contain a newly published unread story.
                    if read_revision != self.all_read_revision:
                        for story in batch:
                            story["read_status"] = 1
                    self.add(batch)
                    self.next_page += 1
                    if not has_more(batch):
                        self.complete = True
                    elif repeated:
                        self.error = (
                            "Server repeated a batch; partial history · ctrl-s retry"
                        )
                    self.condition.notify_all()
                    self.revision += 1
                    if self.complete or self.error:
                        return
                # Pace requests while filling small batches quickly.
                if self.cancel.wait(POLL_INTERVAL):
                    return
        except (ReaderError, OSError) as exc:
            with self.condition:
                self.error = f"Partial history: {label(exc)} · ctrl-s retry"
                self.revision += 1
                self.condition.notify_all()

    def mark(self, selected: list[dict], *, unread: bool) -> None:
        with self.condition:
            for story in selected:
                self.overrides[story["story_hash"]] = 0 if unread else 1
                story["read_status"] = 0 if unread else 1
            if selected:
                self.revision += 1

    def close(self) -> None:
        # urllib requests cannot be interrupted. The loader may finish its current
        # bounded request, but cancellation prevents it from publishing results.
        self.cancel.set()
        with self.condition:
            self.condition.notify_all()

    def mark_all_read(self) -> None:
        with self.condition:
            self.all_read_revision += 1
            self.overrides.clear()
            for story in self.stories:
                story["read_status"] = 1
            self.revision += 1

    def pause(self) -> None:
        """Pause paging while a refresh is being attempted; start() resumes it."""
        self.paused.set()

    def resume(self) -> None:
        with self.condition:
            self.paused.clear()
            self.condition.notify_all()


class StoryStream:
    """Present one collection as stable fzf rows and temporary preview payloads."""

    def __init__(
        self,
        collection: StoryCollection,
        directory: Path,
        read_filter: str,
        title: str = "Stories",
        hints: str = STORY_HINTS,
    ):
        self.collection = collection
        self.directory = directory
        self.read_filter = read_filter
        self.title = title
        self.hints = hints
        directory.mkdir(exist_ok=True)

    def row(self, number: int, story: dict) -> str:
        path = self.directory / str(number)
        if not path.exists():
            atomic_write(path, json.dumps(story))
        status_mark = "●" if story.get("read_status") == 0 else " "
        date = label(story.get("story_date", ""))[:10]
        return f"{path}\t{status_mark} {story_title(story)}  {date}"

    def header(self, status: str, count: int | None = None, message: str = "") -> str:
        details = status if count is None else f"{story_count(count)} · {status}"
        lines = [f"{self.title} · {self.read_filter} · {details}"]
        if message:
            lines.append(message)
        lines.append(self.hints)
        return "\n".join(lines)


class FeedSession:
    """Own one visit's history and previews; replace both only after successful sync."""

    def __init__(self, api, feed_id: str, initial: list[dict], scratch: Path):
        self.api = api
        self.feed_id = feed_id
        self.scratch = scratch
        self.previews = tempfile.TemporaryDirectory(prefix="feed-", dir=scratch)
        self.collection = StoryCollection(api, feed_id, initial)

    @property
    def directory(self) -> Path:
        return Path(self.previews.name)

    def refresh(self) -> None:
        # Preserve usable history/previews until the request and allocation of
        # the replacement's files have both succeeded.
        self.collection.pause()
        try:
            initial = foreground_stories(self.api, self.feed_id)
            previews = tempfile.TemporaryDirectory(prefix="feed-", dir=self.scratch)
        except (ReaderError, OSError):
            self.collection.resume()
            raise
        previous_collection = self.collection
        previous_previews = self.previews
        self.collection = StoryCollection(self.api, self.feed_id, initial)
        self.previews = previews
        previous_collection.close()
        previous_previews.cleanup()

    def __enter__(self) -> Self:
        return self

    def __exit__(self, *exc) -> None:
        self.collection.close()
        self.previews.cleanup()


class ReadStateActions:
    """Serialize accepted mutations without blocking the picker or its updater."""

    def __init__(self, collection: StoryCollection):
        self.collection = collection
        self.commands: queue.Queue = queue.Queue()
        self.lock = threading.Lock()
        self.message = ""
        self.failed = False
        self.worker: threading.Thread | None = None

    def status(self) -> tuple[str, bool]:
        with self.lock:
            return self.message, self.failed

    def set_status(self, message: str, *, failed: bool = False) -> None:
        with self.lock:
            self.message = message
            self.failed = failed

    def apply(self, key: str, indexes: list[int]) -> None:
        selected = self.collection.select(indexes)
        if not selected:
            return
        unread = key == "ctrl-u"
        action = "unread" if unread else "read"
        self.set_status(f"Saving {story_count(len(selected))} as {action}…")
        try:
            self.collection.mark_confirmed(selected, unread=unread)
        except MarkError as exc:
            selected_hashes = {story["story_hash"] for story in selected}
            count = len(selected_hashes.intersection(exc.confirmed))
            message = (
                f"{count} confirmed; could not finish: {label(exc)}"
                if count
                else f"Could not save read state: {label(exc)}"
            )
            self.set_status(message, failed=True)
        except (ReaderError, OSError) as exc:
            self.set_status(f"Could not save read state: {label(exc)}", failed=True)
        else:
            self.set_status(f"Marked {story_count(len(selected))} {action}")

    def work(self) -> None:
        while True:
            command = self.commands.get()
            try:
                if command is None:
                    return
                try:
                    self.apply(*command)
                except Exception as exc:  # noqa: BLE001 - worker boundary reports failures
                    # A failed action must not kill the worker and strand later
                    # accepted commands. Keep failures visible rather than silent.
                    self.set_status(
                        f"Could not finish read-state change: {label(exc)}", failed=True
                    )
            finally:
                self.commands.task_done()

    def start(self) -> None:
        if self.worker is None:
            self.worker = threading.Thread(target=self.work, daemon=True)
            self.worker.start()

    def close(self) -> None:
        if self.worker is None:
            return
        pending = bool(self.commands.unfinished_tasks)
        self.commands.put(None)
        if pending:
            print("Finishing pending read-state changes…", flush=True)
        self.worker.join()
        message, failed = self.status()
        if pending and failed:
            print(message, file=sys.stderr)
        self.worker = None


class LivePicker:
    """Keep one fzf process alive; queue mutations and reload local snapshots only."""

    def __init__(self, stream: StoryStream, width: int):
        self.stream = stream
        self.width = width
        self.directory = Path(tempfile.mkdtemp(prefix="live-", dir=stream.directory))
        self.socket = self.directory / "fzf.sock"
        self.list_file = self.directory / "stories"
        self.header_file = self.directory / "header"
        self.stop = threading.Event()
        self.actions = ReadStateActions(stream.collection)
        self.signature = None
        self.updater = None
        self.closed = False
        self.error = ""
        self.refresh()

    def run(
        self, args: list[str], keys: str, state: dict | None
    ) -> subprocess.CompletedProcess:
        """Own fzf, its workers, and cleanup for one uninterrupted picker session."""
        live_keys = {"ctrl-r", "ctrl-u", "ctrl-f"}
        expected = ",".join(key for key in keys.split(",") if key not in live_keys)
        args = [
            *args,
            "--no-sync",
            "--no-select-1",
            "--no-exit-0",
            "--track",
            "--id-nth=1",
            "--no-expect",
            "--expect",
            expected,
            "--listen",
            str(self.socket),
            "--bind",
            f"load:transform-header:cat {shlex.quote(str(self.header_file))}",
        ]
        for key in sorted(live_keys):
            args.extend(["--bind", self.binding(key)])
        focus_file = self.stream.directory / "focus"
        if state is not None:
            args.extend(
                [
                    "--bind",
                    f"focus:execute-silent:printf '%s' \"$FZF_POS\" > {shlex.quote(str(focus_file))}",
                ]
            )
            if state.get("position"):
                args.extend(
                    ["--bind", f"result:pos({int(state['position'])})+unbind(result)"]
                )

        process = None
        try:
            with self.list_file.open() as source:
                process = subprocess.Popen(
                    args,
                    stdin=source,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                )
            self.start()
            stdout, stderr = process.communicate()
            result = subprocess.CompletedProcess(args, process.wait(), stdout, stderr)
        finally:
            try:
                if process is not None and process.poll() is None:
                    process.terminate()
                    process.wait()
                self.close()
            finally:
                if process is not None:
                    process.stdout.close()
                    process.stderr.close()

        if self.error:
            raise ReaderError(self.error)
        if state is not None and focus_file.exists():
            try:
                state["position"] = int(focus_file.read_text())
            except ValueError:
                pass
        return result

    def binding(self, key: str) -> str:
        # The shell does only an atomic queue write, never a network request.
        # {+1} is safely quoted by fzf and includes selected rows or the focus.
        # Row placeholders prevent execution on an empty list. Filtering must
        # remain available there, so its command deliberately has none.
        template = shlex.quote(str(self.directory / "action.XXXXXX"))
        values = shlex.quote(key)
        if key != "ctrl-f":
            values += " {+1}"
        return (
            f"{key}:execute-silent:event=$(mktemp {template}) && "
            f"printf '%s\\n' {values} > \"$event\" && "
            'mv "$event" "$event.ready"'
        )

    def gather(self) -> None:
        for path in sorted(
            self.directory.glob("action.*.ready"), key=lambda p: p.stat().st_mtime_ns
        ):
            lines = path.read_text().splitlines()
            path.unlink()
            if not lines:
                continue
            if lines[0] == "ctrl-f":
                self.stream.read_filter = (
                    "unread" if self.stream.read_filter == "all" else "all"
                )
                continue
            if lines[0] not in ("ctrl-r", "ctrl-u"):
                continue
            indexes = []
            for value in lines[1:]:
                story_path = Path(value)
                if (
                    story_path.parent == self.stream.directory
                    and story_path.name.isdigit()
                ):
                    indexes.append(int(story_path.name))
            if indexes:
                self.actions.commands.put((lines[0], indexes))

    def refresh(self) -> bool:
        collection = self.stream.collection
        message, _ = self.actions.status()
        with collection.condition:
            signature = (
                collection.revision,
                collection.complete,
                collection.error,
                self.stream.read_filter,
                message,
            )
            if signature == self.signature:
                return False
            snapshot = collection.snapshot(self.stream.read_filter)
        rows = [self.stream.row(index, story) for index, story in snapshot.stories]
        header = self.stream.header(snapshot.status, count=len(rows), message=message)
        atomic_write(self.list_file, "\n".join(rows) + ("\n" if rows else ""))
        atomic_write(self.header_file, wrap_header(header, self.width))
        self.signature = signature
        return True

    def notify(self, action: str | None = None) -> bool:
        # Private Unix socket; no listening TCP port, daemon or clipboard access.
        if action is None:
            action = (
                f"reload-sync(cat {shlex.quote(str(self.list_file))})+"
                f"transform-header(cat {shlex.quote(str(self.header_file))})"
            )
        payload = action.encode()
        key = os.environ.get("FZF_API_KEY", "")
        auth = (
            f"x-api-key: {key}\r\n"
            if key and "\n" not in key and "\r" not in key
            else ""
        )
        request = (
            f"POST / HTTP/1.1\r\nHost: localhost\r\n{auth}"
            f"Content-Length: {len(payload)}\r\nConnection: close\r\n\r\n"
        ).encode() + payload
        try:
            with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
                sock.settimeout(0.5)
                sock.connect(str(self.socket))
                sock.sendall(request)
                return b" 200 " in sock.recv(4096).split(b"\r\n", 1)[0]
        except OSError:
            return False

    def update(self) -> None:
        try:
            pending = True
            while not self.stop.is_set():
                self.gather()
                pending = self.refresh() or pending
                if pending and self.notify():
                    pending = False
                self.stop.wait(POLL_INTERVAL)
        except Exception as exc:  # noqa: BLE001 - worker boundary aborts the stale UI
            # A dead updater would leave an apparently healthy but stale UI.
            # Abort fzf and report the failure in the foreground after cleanup.
            self.error = f"Could not update the story picker: {label(exc)}"
            while not self.stop.is_set():
                if self.notify("abort"):
                    return
                self.stop.wait(POLL_INTERVAL)

    def start(self) -> None:
        self.stream.collection.start()
        self.actions.start()
        self.updater = threading.Thread(target=self.update, daemon=True)
        self.updater.start()

    def close(self) -> None:
        if self.closed:
            return
        self.closed = True
        self.stop.set()
        if self.updater:
            self.updater.join()
        # Explicit exit must not silently discard accepted read-state changes.
        try:
            self.gather()
        except (OSError, ValueError) as exc:
            self.error = (
                self.error or f"Could not collect pending actions: {label(exc)}"
            )
        finally:
            try:
                self.actions.close()
            finally:
                shutil.rmtree(self.directory)


def lazy_preview(path: Path) -> str:
    """Render on demand and reuse output only within this feed visit."""
    rendered = path.with_suffix(".preview")
    if rendered.exists():
        return rendered.read_text()
    story = json.loads(path.read_text())
    text = feed_preview(story, path.with_suffix(".html"))
    atomic_write(rendered, text)
    return text


def rows_for_feeds(data: dict) -> list[tuple[str, dict]]:
    feeds = data.get("feeds", {})
    if isinstance(feeds, list):
        feeds = {str(feed["id"]): feed for feed in feeds}
    found: list[tuple[str, dict]] = []
    seen: set[tuple[str, str]] = set()

    def descend(children: list, prefix: str = "") -> None:
        for item in children:
            if isinstance(item, dict):
                for folder, entries in item.items():
                    descend(entries, f"{prefix}/{folder}" if prefix else folder)
            else:
                feed_id = str(item)
                if feed_id in feeds and (prefix, feed_id) not in seen:
                    found.append((prefix, feeds[feed_id]))
                    seen.add((prefix, feed_id))

    descend(data.get("folders", []))
    for feed_id, feed in feeds.items():
        if not any(existing == feed_id for _, existing in seen):
            found.append(("", feed))
    return found


def label(value: object) -> str:
    return clean(value).replace("\t", " ")[:160]


def unread_count(feed: dict) -> int:
    return int(feed.get("unread") or 0)


def feed_label(feed: dict) -> str:
    return f"{label(feed.get('feed_title') or feed.get('title'))}  ({unread_count(feed)} unread)"


def rows_for_folders(data: dict) -> list[tuple[str, list[dict]]]:
    """Group feeds by folder path, keeping unfiled feeds in Top Level."""
    folders: dict[str, list[dict]] = {}
    for folder, feed in rows_for_feeds(data):
        folders.setdefault(folder, []).append(feed)
    if "" in folders:
        return [("", folders.pop("")), *folders.items()]
    return list(folders.items())


def show_message(message: str) -> None:
    print(f"\n{message}")
    input("Press Enter to continue...")


def article_viewer(title: str, url: str, body_html: str) -> None:
    if not shutil.which("elinks"):
        pager(f"{title}\n{url}\n\n{html_text(body_html)}")
        return
    with tempfile.TemporaryDirectory(prefix="rss-page-") as directory:
        page = Path(directory) / "article.html"
        page.write_text(article_document(title, url, body_html))
        command = [
            str(Path.home() / ".config" / "elinks" / "clipboard"),
            "open",
            "-no-connect",
            "-force-html",
        ]
        subprocess.run([*command, page.as_uri()], check=False)


def pager(text: str) -> None:
    with tempfile.TemporaryDirectory(prefix="rss-page-") as directory:
        page = Path(directory) / "article.txt"
        page.write_text(text + "\n")
        env = os.environ.copy()
        env["LESS"] = ""
        subprocess.run(["less", "-R", "-+F", "-+e", str(page)], check=False, env=env)


def story_title(story: dict) -> str:
    return clean(story.get("story_title")) or "(untitled)"


def without_background(text: str) -> str:
    """Keep ELinks' foreground colors but inherit the terminal background."""

    def strip(match: re.Match) -> str:
        codes = match.group(1).split(";")
        kept = []
        index = 0
        while index < len(codes):
            code = codes[index]
            if code in {"38", "48", "58"} and index + 1 < len(codes):
                length = {"2": 5, "5": 3}.get(codes[index + 1], 1)
                if code != "48":
                    kept.extend(codes[index : index + length])
                index += length
                continue
            if not (
                code.isdigit() and (40 <= int(code) <= 49 or 100 <= int(code) <= 107)
            ):
                kept.append(code)
            index += 1
        return f"\x1b[{';'.join(kept)}m" if kept else ""

    return re.sub(r"\x1b\[([\d;]*)m", strip, text)


def feed_preview(story: dict, html_file: Path | None = None) -> str:
    title = story_title(story)
    url = story.get("story_permalink", "")
    body = story.get("story_content") or "<p>(No RSS body supplied)</p>"
    if html_file and shutil.which("elinks"):
        html_file.write_text(article_document(title, url, body))
        result = subprocess.run(
            [
                "elinks",
                "-no-connect",
                "-force-html",
                "-dump",
                "-dump-color-mode",
                "4",
                "-dump-width",
                "72",
                "-no-numbering",
                "-no-references",
                html_file.as_uri(),
            ],
            text=True,
            capture_output=True,
            check=False,
        )
        if result.returncode == 0 and result.stdout.strip():
            return without_background(result.stdout)
    content = html_text(body)
    return f"{title}\n{url}\n\n{content}"


def safe_page_url(url: str) -> None:
    parts = urllib.parse.urlsplit(url)
    if (
        parts.scheme not in {"https", "http"}
        or not parts.hostname
        or parts.username
        or parts.password
    ):
        raise ReaderError("Story does not have a usable HTTP(S) URL")
    try:
        addresses = socket.getaddrinfo(
            parts.hostname, parts.port or (443 if parts.scheme == "https" else 80)
        )
    except (OSError, ValueError) as exc:
        raise ReaderError(f"Could not resolve story URL: {exc}") from exc
    if not addresses or any(
        not ipaddress.ip_address(address[4][0]).is_global for address in addresses
    ):
        raise ReaderError("Refusing to fetch a private or local network address")


class SafeRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        safe_page_url(newurl)
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def page_text(url: str) -> str:
    safe_page_url(url)
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.build_opener(SafeRedirect()).open(
            request, timeout=15
        ) as response:
            content_type = response.headers.get_content_type()
            if content_type not in ("text/html", "application/xhtml+xml"):
                raise ReaderError(
                    f"Page is {content_type}, not HTML; open in a browser instead"
                )
            data = response.read(3_000_001)
            if len(data) > 3_000_000:
                raise ReaderError(
                    "Page too large for text mode; open in a browser instead"
                )
            source = data.decode(
                response.headers.get_content_charset() or "utf-8", errors="replace"
            )
    except (urllib.error.URLError, TimeoutError) as exc:
        raise ReaderError(f"Could not fetch page: {exc}") from exc
    fragment = ArticleFragment()
    fragment.feed(source)
    article = "".join(fragment.parts)
    if len(html_text(article)) >= 20:
        return article
    text = html_text(source)
    if len(text) < 20:
        raise ReaderError(
            "Could not extract readable page text; open in a browser instead"
        )
    return f"<pre>{html.escape(text)}</pre>"


def open_story(api, story: dict, key: str) -> None:
    """Display content; the caller confirms and records the subsequent read action."""
    url = story.get("story_permalink", "")
    if key == "alt-o":
        if not url or not webbrowser.open(url):
            raise ReaderError("Could not open the story in a browser")
    else:
        if key == "ctrl-o":
            print("Fetching the story page...", flush=True)
            body = page_text(url)
        else:
            body = (
                story.get("story_content")
                if "story_content" in story
                else api.body(story)
            )
        article_viewer(story_title(story), url, body or "<p>(No RSS body supplied)</p>")


def browse_feed(api, feed: dict, scratch: Path) -> str:
    """Browse fresh feed history; all preview files belong to this visit."""
    feed_id = str(feed["id"])
    title = label(feed.get("feed_title") or feed.get("title"))
    try:
        print(f"Loading {title}...", flush=True)
        initial = foreground_stories(api, feed_id)
    except ReaderError as exc:
        show_message(f"Could not load {title}: {exc}. Try this feed again later.")
        return "load-error"
    with FeedSession(api, feed_id, initial, scratch) as session:
        read_filter = "all"
        state: dict = {}
        preview = shlex.join([sys.executable, str(LAUNCHER), "--preview"]) + " {1}"
        while True:
            collection = session.collection
            stream = StoryStream(
                collection, session.directory, read_filter, title=title
            )
            status = collection.snapshot(read_filter).status
            key, picked = chooser(
                [],
                header=stream.header(status),
                preview=preview,
                multi=True,
                keys=STORY_KEYS,
                stream=stream,
                state=state,
            )
            read_filter = stream.read_filter
            if key in ("escape", "ctrl-q"):
                return key
            try:
                if key == "ctrl-s":
                    session.refresh()
                elif key == "ctrl-f":
                    read_filter = "all" if read_filter == "unread" else "unread"
                elif key == "alt-r":
                    if (
                        input(
                            f"Mark ALL unread stories in {title} read? [y/N] "
                        ).casefold()
                        == "y"
                    ):
                        api.mark_feed(feed_id)
                        collection.mark_all_read()
                elif picked and key in ("enter", "ctrl-o", "alt-o"):
                    indexes = [int(Path(picked[0].split("\t", 1)[0]).name)]
                    selected = collection.select(indexes)
                    if not selected:
                        continue
                    story = selected[0]
                    open_story(api, story, key)
                    collection.mark_confirmed([story], unread=False)
            except (ReaderError, OSError) as exc:
                show_message(f"{exc}. Your current stories are still available.")


def run_source(config: dict) -> str:
    api = create(config)
    feeds_data = authenticated(api, api.feeds)
    with tempfile.TemporaryDirectory(prefix="rss-fzf-") as scratch:
        scratch = Path(scratch)
        if feeds_data.get("standalone") is True:
            return browse_feed(api, next(iter(feeds_data["feeds"].values())), scratch)
        selected_folder: str | None = None
        while True:
            folder_rows = rows_for_folders(feeds_data)
            if not folder_rows:
                show_message("No subscribed feeds found in this source.")
                return "escape"
            folders = dict(folder_rows)
            if selected_folder not in folders:
                selected_folder = None
            options = []
            if selected_folder is None:
                for index, (folder, feeds) in enumerate(folder_rows):
                    path = scratch / str(index)
                    name = label(folder or "Top Level")
                    path.write_text(
                        name + "\n\n" + "\n".join(feed_label(f) for f in feeds) + "\n"
                    )
                    options.append(
                        f"{path}\t{name}  ({sum(unread_count(f) for f in feeds)} unread)"
                    )
                header = f"{label(config['title'])} · folders\nctrl-s sync"
                preview = "cat {1}"
            else:
                feeds = folders[selected_folder]
                options = [
                    f"{index}\t{feed_label(feed)}" for index, feed in enumerate(feeds)
                ]
                header = f"{label(config['title'])} · {label(selected_folder or 'Top Level')} · feeds\nctrl-s sync"
                preview = None
            key, selected = chooser(
                options, header=header, preview=preview, keys="enter,ctrl-s,ctrl-q"
            )
            if key == "ctrl-q" or (key == "escape" and selected_folder is None):
                return key
            if key == "escape":
                selected_folder = None
            elif key == "ctrl-s":
                try:
                    feeds_data = authenticated(api, api.feeds)
                except ReaderError as exc:
                    show_message(
                        f"Could not sync feeds: {exc}. Your current list is still available."
                    )
            elif selected:
                index = int(Path(selected[0].split("\t", 1)[0]).name)
                if selected_folder is None:
                    selected_folder = folder_rows[index][0]
                    continue
                result = browse_feed(api, feeds[index], scratch)
                if result == "ctrl-q":
                    return result
                if result == "escape":
                    try:
                        feeds_data = authenticated(api, api.feeds)
                    except ReaderError as exc:
                        show_message(
                            f"Could not update feed counts: {exc}. Ctrl-S will retry."
                        )


def run() -> None:
    configured = registry.sources()
    if not configured:
        print("No sources configured. Add one with mise rss --url.")
        return
    while True:
        options = [
            f"{index}\t{label(source['title'])}"
            for index, source in enumerate(configured)
        ]
        key, selected = chooser(
            options,
            header="RSS sources\nctrl-q quit",
            keys="enter,ctrl-q",
        )
        if key in ("escape", "ctrl-q") or not selected:
            return
        try:
            result = run_source(configured[int(selected[0].split("\t", 1)[0])])
        except ReaderError as exc:
            show_message(str(exc))
            continue
        if result == "ctrl-q":
            return
