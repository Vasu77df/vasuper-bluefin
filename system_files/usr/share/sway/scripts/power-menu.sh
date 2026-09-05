#!/usr/bin/env bash
set -euo pipefail

# Prevent duplicate swaynag instances.
if pgrep -u "$UID" -x swaynag >/dev/null 2>&1; then
    exit 0
fi

action="/usr/share/sway/scripts/session-action.sh"

exec swaynag \
    --type warning \
    --message "Session controls" \
    --dismiss-button "Cancel" \
    --background         1e1e2e \
    --border             313244 \
    --border-bottom      89b4fa \
    --button-background  313244 \
    --button-text        cdd6f4 \
    --text               cdd6f4 \
    --button-border-size 1 \
    --button-padding     8 \
    --button-gap         6 \
    --button-dismiss-no-terminal "Lock"      "$action lock"    \
    --button-dismiss-no-terminal "Suspend"   "$action suspend" \
    --button-dismiss-no-terminal "Logout"    "$action logout"  \
    --button-dismiss-no-terminal "Reboot"    "$action reboot"  \
    --button-dismiss-no-terminal "Power off" "$action poweroff"
