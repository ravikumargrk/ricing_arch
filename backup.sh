#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/ricing_arch"
DATE="$(date +%Y%m%d)"

mkdir -p "$REPO/history" "$REPO/kitty" "$REPO/hypr"

cp "$HOME/.local/share/fish/fish_history" \
   "$REPO/history/fish_history_$DATE"

cp "$HOME/install-log.csv" \
   "$REPO/install-log.csv"

cp "$HOME/.config/kitty/kitty.conf" \
   "$REPO/kitty/kitty.conf"

cp "$HOME/.config/hypr/hyprland.lua" \
   "$REPO/hypr/hyprland.lua"

echo "Backup completed: $REPO"
