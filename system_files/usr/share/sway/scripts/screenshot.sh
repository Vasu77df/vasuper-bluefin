#!/usr/bin/env bash
set -euo pipefail

mode="${1:-area}"
directory="${HOME}/Pictures/Screenshots"
filename="$(date +'%Y-%m-%d_%H-%M-%S').png"
output="${directory}/${filename}"

mkdir -p "$directory"

case "$mode" in
    full)
        grim "$output"
        ;;
    area)
        geometry="$(slurp)" || exit 0
        [[ -n "$geometry" ]] || exit 0
        grim -g "$geometry" "$output"
        ;;
    window)
        geometry="$(
            swaymsg -t get_tree -r |
                jq -r '.. | objects | select(.focused? == true and .type? == "con") |
                    "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' |
                head -n 1
        )"
        [[ -n "$geometry" ]] || exit 1
        grim -g "$geometry" "$output"
        ;;
    *)
        printf 'Usage: %s {full|area|window}\n' "$0" >&2
        exit 2
        ;;
esac

wl-copy --type image/png < "$output"
notify-send --app-name "Sway" --icon "$output" "Screenshot saved" "$output"
