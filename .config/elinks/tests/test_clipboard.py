"""Offline checks for ELinks' system clipboard adapter."""

import importlib.util
from importlib.machinery import SourceFileLoader
from pathlib import Path
import unittest
from unittest.mock import patch


clipboard_path = Path(__file__).parents[1] / "clipboard"
spec = importlib.util.spec_from_loader("elinks_clipboard", SourceFileLoader("elinks_clipboard", str(clipboard_path)))
clipboard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(clipboard)


class ClipboardTests(unittest.TestCase):
    def test_windows_clipboard_receives_unicode_not_utf8(self):
        text = "übersetzen – français 日本語"
        with patch.object(clipboard.sys, "platform", "linux"), \
             patch.object(clipboard.shutil, "which", side_effect=lambda name: name if name == "clip.exe" else None), \
             patch.object(clipboard.subprocess, "run") as run:
            clipboard.copy(text.encode())
        self.assertEqual(run.call_args.args[0], ["clip.exe"])
        self.assertEqual(run.call_args.kwargs["input"].decode("utf-16"), text)

    def test_mac_clipboard_receives_utf8(self):
        with patch.object(clipboard.sys, "platform", "darwin"), \
             patch.object(clipboard.shutil, "which", return_value="/usr/bin/pbcopy"), \
             patch.object(clipboard.subprocess, "run") as run:
            clipboard.copy(b"text")
        self.assertEqual(run.call_args.args[0], ["pbcopy"])
        self.assertEqual(run.call_args.kwargs["input"], b"text")

    def test_linux_and_tmux_clipboard_backends(self):
        cases = [
            ({"WAYLAND_DISPLAY": "wayland-0"}, "wl-copy", ["wl-copy"]),
            ({"DISPLAY": ":0"}, "xclip", ["xclip", "-selection", "clipboard", "-in"]),
            ({"DISPLAY": ":0"}, "xsel", ["xsel", "--clipboard", "--input"]),
            ({"TMUX": "/tmp/tmux/session"}, "tmux", ["tmux", "load-buffer", "-w", "-"]),
        ]
        for env, backend, command in cases:
            with self.subTest(backend=backend), \
                 patch.dict(clipboard.os.environ, env, clear=True), \
                 patch.object(clipboard.sys, "platform", "linux"), \
                 patch.object(clipboard.shutil, "which", side_effect=lambda name: name if name == backend else None), \
                 patch.object(clipboard.subprocess, "run") as run:
                clipboard.copy("übersetzen".encode())
            self.assertEqual(run.call_args.args[0], command)
            self.assertEqual(run.call_args.kwargs["input"], "übersetzen".encode())

    def test_clipboard_reports_missing_backend(self):
        with patch.object(clipboard.shutil, "which", return_value=None), self.assertRaises(RuntimeError):
            clipboard.copy(b"text")


if __name__ == "__main__":
    unittest.main()
