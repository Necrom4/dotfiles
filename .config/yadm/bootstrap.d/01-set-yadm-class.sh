#!/usr/bin/env bash
set -e

echo "Select this machine's yadm class:"
select choice in Personal Work 42; do
  case "$choice" in
  Personal | Work | 42)
    yadm config local.class "$choice"
    echo "Set yadm class to '$choice'."
    break
    ;;
  *)
    echo "Invalid choice. Try again."
    ;;
  esac
done
