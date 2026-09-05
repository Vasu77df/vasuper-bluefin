#!/usr/bin/env bash
set -euo pipefail

exec swaylock -f \
    --config "${HOME}/.config/swaylock/config" \
    --image  "${HOME}/.config/sway/wallpaper.png" \
    --scaling fill
