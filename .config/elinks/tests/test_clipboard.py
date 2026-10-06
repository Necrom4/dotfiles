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
    def test_copy_uses_omz_clipcopy_without_interactive_shell(self):
        data = "übersetzen – français 日本語".encode()
        with patch.object(clipboard.subprocess, "run") as run:
            clipboard.copy(data)
        command = run.call_args.args[0]
        self.assertEqual(command[:2], ["zsh", "-c"])
        self.assertIn('source "$HOME/.local/share/zinit/snippets/OMZL::clipboard.zsh/OMZL::clipboard.zsh"', command[2])
        self.assertTrue(command[2].endswith("clipcopy"))
        self.assertEqual(run.call_args.kwargs["input"], data)
        self.assertTrue(run.call_args.kwargs["check"])


if __name__ == "__main__":
    unittest.main()
