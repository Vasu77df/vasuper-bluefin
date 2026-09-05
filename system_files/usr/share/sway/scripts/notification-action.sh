#!/usr/bin/env bash
set -euo pipefail

exec makoctl menu wofi --dmenu --prompt "Notification action"
