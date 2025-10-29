#!/usr/bin/env bash

# Disable Apple Music so that the Play button isn't hijacked by it
launchctl unload /System/Library/LaunchAgents/com.apple.rcd.plist 2>/dev/null || echo
