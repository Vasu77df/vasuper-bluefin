#!/usr/bin/env bash
set -euo pipefail

details="$(
    swaymsg -t get_tree -r |
        jq -r '
            .. | objects |
            select(.focused? == true and .type? == "con") |
            [
                "Title: \(.name // "-")",
                "App ID: \(.app_id // "-")",
                "Class: \(.window_properties.class // "-")",
                "Instance: \(.window_properties.instance // "-")",
                "Role: \(.window_properties.window_role // "-")",
                "Shell: \(.shell // "-")",
                "Window type: \(.window_properties.window_type // "-")"
            ] | join("\n")
        ' |
        head -n 7
)"

[[ -n "$details" ]] || {
    printf 'No focused application window found.\n' >&2
    exit 1
}

printf '%s\n' "$details"
printf '%s\n' "$details" | wl-copy

if [[ "${1:-}" == "--notify" ]]; then
    notify-send --app-name "Sway" "Focused window metadata" "$details"
fi
