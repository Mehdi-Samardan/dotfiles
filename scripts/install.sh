#!/bin/bash
# Dotfiles install script
# Usage: ./scripts/install.sh
# Creates symlinks from this repo to your home directory

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "Installing dotfiles from: $DOTFILES_DIR"

# --- Shell ---
ln -sf "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"

# --- Git ---
ln -sf "$DOTFILES_DIR/git/config" "$HOME/.config/git/config"

# --- Terminals ---
ln -sf "$DOTFILES_DIR/terminals/ghostty/config" "$HOME/.config/ghostty/config"
ln -sf "$DOTFILES_DIR/terminals/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
ln -sf "$DOTFILES_DIR/terminals/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# --- Window Managers ---
mkdir -p "$HOME/.config/hypr"
for f in "$DOTFILES_DIR/window-managers/hyprland/"*.conf; do
    ln -sf "$f" "$HOME/.config/hypr/$(basename "$f")"
done

# --- Waybar ---
mkdir -p "$HOME/.config/waybar"
ln -sf "$DOTFILES_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
ln -sf "$DOTFILES_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"

# --- Mako ---
mkdir -p "$HOME/.config/mako"
ln -sf "$DOTFILES_DIR/mako/config" "$HOME/.config/mako/config"

# --- Walker ---
mkdir -p "$HOME/.config/walker"
ln -sf "$DOTFILES_DIR/launchers/walker/config.toml" "$HOME/.config/walker/config.toml"

# --- Prompt ---
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/prompts/starship.toml" "$HOME/.config/starship.toml"

# --- System Tools ---
mkdir -p "$HOME/.config/btop"
ln -sf "$DOTFILES_DIR/system/btop/btop.conf" "$HOME/.config/btop/btop.conf"

mkdir -p "$HOME/.config/fastfetch"
ln -sf "$DOTFILES_DIR/system/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"

# --- Editors ---
mkdir -p "$HOME/.config/Code/User"
ln -sf "$DOTFILES_DIR/editors/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

echo "Dotfiles installed!"
