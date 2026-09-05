#!/usr/bin/env bash
# session-start.sh — called by Sway's exec on startup and on config reload.
# Starts managed services exactly once, or restarts them if --restart-managed
# is passed (e.g. after swaymsg reload).
set -u

scripts_dir="${HOME}/.config/sway/scripts"
restart_managed=false

if [[ "${1:-}" == "--restart-managed" ]]; then
    restart_managed=true
fi

# ── Ensure portal services are running ────────────────────────────────────────
if ! systemctl --user is-active --quiet xdg-desktop-portal-wlr.service; then
    systemctl --user restart xdg-desktop-portal.service
    systemctl --user start xdg-desktop-portal-wlr.service
fi

# ── Helper: start a process by exact name only if not already running ─────────
start_once() {
    local process_name=$1
    shift
    if ! pgrep -u "$UID" -x "$process_name" >/dev/null 2>&1; then
        nohup "$@" </dev/null >/dev/null 2>&1 &
    fi
}

# ── Helper: start a process matched by a broader pattern ─────────────────────
start_pattern_once() {
    local process_pattern=$1
    shift
    if ! pgrep -u "$UID" -f "$process_pattern" >/dev/null 2>&1; then
        nohup "$@" </dev/null >/dev/null 2>&1 &
    fi
}

# ── Restart managed daemons if requested (e.g. after kanshi config change) ───
if $restart_managed; then
    pkill -u "$UID" -x swayidle >/dev/null 2>&1 || true
    pkill -u "$UID" -x kanshi   >/dev/null 2>&1 || true
    sleep 0.2
fi

# ── Launch user-space daemons ─────────────────────────────────────────────────
start_once mako mako
start_once nm-applet nm-applet --indicator
start_pattern_once '(^|/)blueman-applet($| )' blueman-applet
start_pattern_once '/polkit-gnome-authentication-agent-1($| )' \
    /usr/libexec/polkit-gnome-authentication-agent-1
start_once kanshi kanshi

# ── swayidle: lock after 9.5 min, screen off after 10 min ─────────────────────
if ! pgrep -u "$UID" -x swayidle >/dev/null 2>&1; then
    nohup swayidle -w \
        timeout 570 "${scripts_dir}/lock.sh" \
        timeout 600 'swaymsg "output * power off"' \
        resume      'swaymsg "output * power on"' \
        before-sleep "${scripts_dir}/lock.sh" \
        </dev/null >/dev/null 2>&1 &
fi
