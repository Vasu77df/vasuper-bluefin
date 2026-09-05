#!/usr/bin/env bash
set -euo pipefail

modes="$(makoctl mode 2>/dev/null || true)"

if [[ -z "$modes" ]]; then
    printf '{"text":"󰂛","class":"unavailable","tooltip":"Notification service unavailable"}\n'
elif grep -qx 'do-not-disturb' <<<"$modes"; then
    printf '{"text":"󰂛","class":"do-not-disturb","tooltip":"Do not disturb enabled"}\n'
else
    printf '{"text":"󰂚","class":"enabled","tooltip":"Notifications enabled"}\n'
fi
