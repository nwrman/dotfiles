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

# ==============================================================================
# Spicetify
# ==============================================================================
if ! command -v spicetify &>/dev/null; then
  echo "==> Spicetify: not installed (run brew bundle first). Skipping."
else
  echo "==> Configuring Spicetify..."

  # Ensure Spicetify Marketplace is installed (needed for themes/extensions)
  SPICETIFY_CONFIG_DIR="$(spicetify -c 2>/dev/null | xargs dirname 2>/dev/null || echo "$HOME/.config/spicetify")"
  THEMES_DIR="${SPICETIFY_CONFIG_DIR}/Themes"
  CUSTOM_APPS_DIR="${SPICETIFY_CONFIG_DIR}/CustomApps"

  # Install catppuccin theme if not present
  if [[ ! -d "${THEMES_DIR}/catppuccin" ]]; then
    echo "    Installing catppuccin theme..."
    mkdir -p "$THEMES_DIR"
    git clone --depth 1 https://github.com/catppuccin/spicetify.git /tmp/catppuccin-spicetify 2>/dev/null || true
    if [[ -d /tmp/catppuccin-spicetify ]]; then
      cp -r /tmp/catppuccin-spicetify/catppuccin "$THEMES_DIR/"
      rm -rf /tmp/catppuccin-spicetify
    fi
  else
    echo "    catppuccin theme: already installed."
  fi

  # Set theme and color scheme
  spicetify config current_theme catppuccin 2>/dev/null || true
  spicetify config color_scheme mocha 2>/dev/null || true

  # Install spicetify-marketplace custom app if not present
  if [[ ! -d "${CUSTOM_APPS_DIR}/marketplace" ]]; then
    echo "    Installing Spicetify Marketplace..."
    mkdir -p "$CUSTOM_APPS_DIR"
    git clone --depth 1 https://github.com/spicetify/marketplace.git /tmp/spicetify-marketplace 2>/dev/null || true
    if [[ -d /tmp/spicetify-marketplace/packages/marketplace ]]; then
      cp -r /tmp/spicetify-marketplace/packages/marketplace "$CUSTOM_APPS_DIR/"
      rm -rf /tmp/spicetify-marketplace
    fi
  else
    echo "    Spicetify Marketplace: already installed."
  fi

  # Enable extensions
  EXTENSIONS="shuffle.js,hidePodcasts.js,goToSong.js,showQueueDuration.js,history.js,playNext.js,playingSource.js,addToQueueTop.js,oldLikeButton.js"
  spicetify config extensions "$EXTENSIONS" 2>/dev/null || true

  # Enable custom apps
  spicetify config custom_apps marketplace 2>/dev/null || true
  spicetify config custom_apps newReleases 2>/dev/null || true

  # Apply (backup first if needed)
  spicetify backup apply 2>/dev/null || spicetify apply 2>/dev/null || {
    echo "    Warning: spicetify apply failed. Spotify may not be installed yet."
  }

  echo "==> Spicetify configured."
fi
