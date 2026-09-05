#!/bin/bash
# build.sh — runs inside the container at image-build time.
# All changes baked in here are immutable in the final OSTree commit.
#
# Packages already present in ghcr.io/ublue-os/bluefin-dx:stable-daily are NOT
# listed here — dnf5 errors on already-installed packages and we want the build
# to fail fast on any real missing/misspelled package name.

set -ouex pipefail

###############################################################################
# 1. Copy system_files tree into the image root
###############################################################################
cp -avf "/ctx/system_files"/. /

###############################################################################
# 2. External repositories
###############################################################################
dnf5 copr enable -y scottames/ghostty

###############################################################################
# 3. Package installation
#
# Only packages NOT already in the bluefin-dx base image are listed here.
# Pre-installed in base (confirmed from build output):
#   wl-clipboard, xorg-x11-server-Xwayland, xdg-desktop-portal,
#   xdg-desktop-portal-gtk, pipewire, wireplumber, libnotify,
#   tmux, jetbrains-mono-fonts, jq, rsync
###############################################################################
dnf5 install -y \
    \
    `# ── Sway compositor and core WM tools ──` \
    sway \
    swaybg \
    swayidle \
    swaylock \
    swaynag \
    \
    `# ── Wayland bar and notification daemon ──` \
    waybar \
    mako \
    \
    `# ── App launcher ──` \
    wofi \
    \
    `# ── Output / display management ──` \
    kanshi \
    wdisplays \
    \
    `# ── Screenshot tools ──` \
    grim \
    slurp \
    \
    `# ── Desktop portal for wlroots compositors ──` \
    xdg-desktop-portal-wlr \
    \
    `# ── PolicyKit daemon ──` \
    polkit \
    \
    `# ── Audio control tools ──` \
    pamixer \
    pavucontrol \
    \
    `# ── Backlight control ──` \
    brightnessctl \
    \
    `# ── System tray applets ──` \
    network-manager-applet \
    blueman \
    \
    `# ── Terminal emulator (via COPR) ──` \
    ghostty \
    \
    `# ── Dev / quality-of-life ──` \
    shellcheck

# Disable COPR repos so they don't remain enabled in the image
dnf5 copr disable -y scottames/ghostty

###############################################################################
# 4. Clean dnf cache — keeps the image layer as small as possible
###############################################################################
dnf5 clean all

###############################################################################
# 5. System-wide environment variables
###############################################################################
grep -qxF 'XDG_CURRENT_DESKTOP=sway'       /etc/environment \
    || echo 'XDG_CURRENT_DESKTOP=sway'       >> /etc/environment
grep -qxF 'XDG_SESSION_TYPE=wayland'        /etc/environment \
    || echo 'XDG_SESSION_TYPE=wayland'       >> /etc/environment
grep -qxF 'MOZ_ENABLE_WAYLAND=1'            /etc/environment \
    || echo 'MOZ_ENABLE_WAYLAND=1'           >> /etc/environment
grep -qxF 'QT_QPA_PLATFORM=wayland'         /etc/environment \
    || echo 'QT_QPA_PLATFORM=wayland'        >> /etc/environment
grep -qxF '_JAVA_AWT_WM_NONREPARENTING=1'   /etc/environment \
    || echo '_JAVA_AWT_WM_NONREPARENTING=1'  >> /etc/environment

###############################################################################
# 6. Seed /etc/skel with the default home config tree
###############################################################################
cp -avf /ctx/homefiles/. /etc/skel/

###############################################################################
# 7. Enable system-level services
###############################################################################
systemctl enable podman.socket
