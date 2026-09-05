#!/usr/bin/env bash
set -euo pipefail

if makoctl mode | grep -qx 'do-not-disturb'; then
    makoctl mode -r do-not-disturb
    notify-send --app-name "Mako" "Notifications enabled"
else
    notify-send --app-name "Mako" "Do not disturb enabled" \
        "Critical notifications will remain visible."
    sleep 0.2
    makoctl mode -a do-not-disturb
fi

# Signal waybar to refresh the notification indicator (signal 9 → SIGRTMIN+9)
pkill -RTMIN+9 -x waybar >/dev/null 2>&1 || true
