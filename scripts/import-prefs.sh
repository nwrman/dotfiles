#!/usr/bin/env bash
# import-prefs.sh — Import saved app preferences on a new machine
# Called by bootstrap.sh or run manually.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PREFS_DIR="${DOTFILES_DIR}/prefs"

if [[ ! -d "$PREFS_DIR" ]]; then
  echo "==> No prefs/ directory found. Skipping preference import."
  exit 0
fi

echo "==> Importing app preferences..."

# Plist-based apps (defaults domains)
DOMAINS=(
  "com.lwouis.alt-tab-macos:alttab"
  "com.surteesstudios.Bartender:bartender"
  "cc.ffitch.shottr:shottr"
  "com.0804Team.KeyClu:keyclu"
  "com.superultra.Homerow:homerow"
  "com.apple.symbolichotkeys:symbolichotkeys"
  "com.apple.HIToolbox:hitoolbox"
)

for entry in "${DOMAINS[@]}"; do
  domain="${entry%%:*}"
  filename="${entry##*:}"
  plist="${PREFS_DIR}/${filename}.plist"
  if [[ -f "$plist" ]]; then
    defaults import "$domain" "$plist"
    echo "    Imported ${filename}.plist -> ${domain}"
  else
    echo "    Skipped ${filename}.plist (not found in prefs/)"
  fi
done

# iTerm2 — configure to load preferences from the homeshick-managed folder
if defaults read com.googlecode.iterm2 &>/dev/null 2>&1 || [[ -d "/Applications/iTerm.app" ]]; then
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.config/iterm2-prefs"
  echo "    Configured iTerm2 to load prefs from ~/.config/iterm2-prefs/"
fi

echo
echo "==> Preferences imported. Restart apps for changes to take effect."
echo
echo "    NOTE: Raycast preferences must be imported manually:"
echo "      1. Open Raycast > Settings > Advanced > Import Settings"
echo "      2. Select: ${PREFS_DIR}/raycast.rayconfig"
