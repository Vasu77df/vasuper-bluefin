#!/usr/bin/env bash
set -euo pipefail

lock_script="${HOME}/.config/sway/scripts/lock.sh"

case "${1:-}" in
    lock)
        exec "$lock_script"
        ;;
    suspend)
        "$lock_script"
        exec systemctl suspend
        ;;
    logout)
        exec swaymsg exit
        ;;
    reboot)
        exec systemctl reboot
        ;;
    poweroff)
        exec systemctl poweroff
        ;;
    *)
        printf 'Usage: %s {lock|suspend|logout|reboot|poweroff}\n' "$0" >&2
        exit 2
        ;;
esac
