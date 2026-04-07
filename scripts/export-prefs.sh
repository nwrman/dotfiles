#!/usr/bin/env bash
# export-prefs.sh — Export app preferences from the running system into prefs/
# Run this whenever you change an app's settings and want to save them to the repo.
# Automatically sanitizes exported plists (strips license keys, telemetry, etc.)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PREFS_DIR="${DOTFILES_DIR}/prefs"
mkdir -p "$PREFS_DIR"

echo "==> Exporting app preferences..."

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
  if defaults read "$domain" &>/dev/null; then
    defaults export "$domain" "$PREFS_DIR/${filename}.plist"
    echo "    Exported ${domain} -> prefs/${filename}.plist"
  else
    echo "    Skipped ${domain} (not found on this system)"
  fi
done

# iTerm2 — export into the homeshick-managed prefs folder
ITERM_PREFS_DIR="${DOTFILES_DIR}/home/.config/iterm2-prefs"
if defaults read com.googlecode.iterm2 &>/dev/null; then
  mkdir -p "$ITERM_PREFS_DIR"
  defaults export com.googlecode.iterm2 "$ITERM_PREFS_DIR/com.googlecode.iterm2.plist"
  echo "    Exported iTerm2 -> home/.config/iterm2-prefs/com.googlecode.iterm2.plist"
else
  echo "    Skipped iTerm2 (not found on this system)"
fi

# ==============================================================================
# Sanitize exported plists — strip license keys, telemetry, and PII
# ==============================================================================
echo
echo "==> Sanitizing exported plists..."

PB="/usr/libexec/PlistBuddy"

# Bartender: strip license key and holder name
if [[ -f "$PREFS_DIR/bartender.plist" ]]; then
  $PB -c "Delete :license5" "$PREFS_DIR/bartender.plist" 2>/dev/null || true
  $PB -c "Delete :license5HoldersName" "$PREFS_DIR/bartender.plist" 2>/dev/null || true
  echo "    Stripped license keys from bartender.plist"
fi

# AltTab: strip Microsoft AppCenter telemetry
if [[ -f "$PREFS_DIR/alttab.plist" ]]; then
  for key in MSAppCenter310AppCenterUserDefaultsMigratedKey \
             MSAppCenter310CrashesUserDefaultsMigratedKey \
             MSAppCenterAppDidReceiveMemoryWarning \
             MSAppCenterInstallId \
             MSAppCenterNetworkRequestsAllowed \
             MSAppCenterPastDevices \
             MSAppCenterSessionIdHistory \
             MSAppCenterUserIdHistory; do
    $PB -c "Delete :${key}" "$PREFS_DIR/alttab.plist" 2>/dev/null || true
  done
  echo "    Stripped telemetry from alttab.plist"
fi

# Shottr: strip Google Analytics telemetry
if [[ -f "$PREFS_DIR/shottr.plist" ]]; then
  $PB -c "Delete :GATelemetry" "$PREFS_DIR/shottr.plist" 2>/dev/null || true
  echo "    Stripped telemetry from shottr.plist"
fi

echo
echo "==> Done. Commit the changes to save them."
echo "    NOTE: Raycast must be exported manually via Settings > Advanced > Export Settings."
echo "          Save the .rayconfig file to: ${PREFS_DIR}/raycast.rayconfig"
