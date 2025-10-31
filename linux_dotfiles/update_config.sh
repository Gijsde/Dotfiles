#!/usr/bin/env bash

# === Load your color palette ===
source ~/.config/system-variables.sh

# === Paths ===
GHOSTTY_TPL="$HOME/.config/ghostty/config.tpl"
GHOSTTY_CFG="$HOME/.config/ghostty/config"

HYPRPAPER_TPL="$HOME/.config/hypr/hyprpaper.tpl.conf"
HYPRPAPER_CFG="$HOME/.config/hypr/hyprpaper.conf"

WAYBAR_TPL="$HOME/.config/waybar/style.tpl.css"
WAYBAR_CFG="$HOME/.config/waybar/style.css"

WOFI_TPL="$HOME/.config/wofi/style.tpl.css"
WOFI_CFG="$HOME/.config/wofi/style.css"

ALACRITTY_TPL="$HOME/.config/alacritty/alacritty.tpl.yml"
ALACRITTY_CFG="$HOME/.config/alacritty/alacritty.yml"

# === Generate Ghostty config ===
if [[ -f "$GHOSTTY_TPL" ]]; then
    envsubst <"$GHOSTTY_TPL" >"$GHOSTTY_CFG"
    echo "Ghostty config updated: $GHOSTTY_CFG"
fi

# === Generate Waybar config ===
if [[ -f "$WAYBAR_TPL" ]]; then
    envsubst <"$WAYBAR_TPL" >"$WAYBAR_CFG"
    killall waybar && waybar &
    echo "Waybar config updated: $WAYBAR_CFG"
fi

if [[ -f "$WOFI_TPL" ]]; then
    envsubst <"$WOFI_TPL" >"$WOFI_CFG"
    echo "Wofi config updated: $WOFI_CFG"
fi

if [[ -f "$HYPRPAPER_TPL" ]]; then
    envsubst <"$HYPRPAPER_TPL" >"$HYPRPAPER_CFG"
    killall hyprpaper && hyprpaper &
    echo "Hyprpaper config updated: $HYPRPAPER_CFG"
fi

if [[ -f "$ALACRITTY_TPL" ]]; then
    envsubst <"$ALACRITTY_TPL" >"$ALACRITTY_CFG"
    echo "Alacritty config updated: $ALACRITTY_CFG"
fi

echo "All configs regenerated from colors.sh!"
