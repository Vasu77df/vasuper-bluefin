#!/usr/bin/env bash
set -euo pipefail

left_output="${1:?left output name required}"
focused_workspace="$(
    swaymsg -t get_workspaces -r |
        jq -r '.[] | select(.focused == true) | .num'
)"
workspaces="$(swaymsg -t get_workspaces -r)"

move_existing_workspace() {
    local number=$1
    local output=$2

    if jq -e --argjson number "$number" \
        '.[] | select(.num == $number)' <<<"$workspaces" >/dev/null; then
        swaymsg --quiet "workspace number ${number}, move workspace to output ${output}"
    fi
}

# Column layout: left external → DP-1 → laptop (eDP-1)
move_existing_workspace 1 "$left_output"
move_existing_workspace 4 "$left_output"
move_existing_workspace 7 "$left_output"
move_existing_workspace 2 DP-1
move_existing_workspace 5 DP-1
move_existing_workspace 8 DP-1
move_existing_workspace 3 eDP-1
move_existing_workspace 6 eDP-1
move_existing_workspace 9 eDP-1

if [[ "$focused_workspace" =~ ^[0-9]+$ ]]; then
    swaymsg --quiet "workspace number ${focused_workspace}"
fi
