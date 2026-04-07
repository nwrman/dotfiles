#!/usr/bin/env bash
# setup-extras.sh — Spicetify, Touch ID sudo, and other extras
# Idempotent: safe to re-run at any time.
set -euo pipefail

# ==============================================================================
# Touch ID for sudo
# ==============================================================================
SUDO_LOCAL="/etc/pam.d/sudo_local"

if [[ -f "$SUDO_LOCAL" ]] && grep -q "pam_tid.so" "$SUDO_LOCAL"; then
  echo "==> Touch ID for sudo: already configured."
else
  echo "==> Enabling Touch ID for sudo..."
  sudo bash -c 'cat > /etc/pam.d/sudo_local <<EOF
# sudo_local: local config file which survives system updates
auth       sufficient     pam_tid.so
EOF'
  echo "    Done. Touch ID is now enabled for sudo."
fi

# Also enable Touch ID when connected to external monitors
if defaults read ~/Library/Preferences/com.apple.security.authorization.plist ignoreArd 2>/dev/null | grep -q "1"; then
  echo "==> Touch ID external monitor fix: already configured."
else
  echo "==> Enabling Touch ID for external monitor sessions..."
  defaults write ~/Library/Preferences/com.apple.security.authorization.plist ignoreArd -bool TRUE
  echo "    Done."
fi
