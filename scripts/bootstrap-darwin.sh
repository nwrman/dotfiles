#!/usr/bin/env bash
# bootstrap-darwin.sh — macOS-only setup steps.
# Invoked by scripts/bootstrap.sh after shared steps; receives DOTFILES_DIR,
# SCRIPTS_DIR, and ROLE via the environment.
set -euo pipefail

: "${DOTFILES_DIR:?DOTFILES_DIR must be set by parent bootstrap.sh}"
: "${SCRIPTS_DIR:=${DOTFILES_DIR}/scripts}"
: "${ROLE:=personal}"

echo "==> Requesting administrative privileges..."
sudo -v

# Keep sudo alive for the duration of this script
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ---- Homebrew ----
if command -v brew &>/dev/null; then
  echo "==> Homebrew: already installed."
else
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

echo "==> Updating Homebrew..."
brew update

# Accept Microsoft EULA for msodbcsql18 (ODBC driver)
export HOMEBREW_ACCEPT_EULA=Y

echo "==> Installing shared packages from Brewfile..."
brew bundle --verbose --file="${DOTFILES_DIR}/Brewfile"

if [[ "$ROLE" == "work" && -f "${DOTFILES_DIR}/Brewfile.work" ]]; then
  echo "==> Installing work-only packages from Brewfile.work..."
  brew bundle --verbose --file="${DOTFILES_DIR}/Brewfile.work"
fi

# ---- macOS defaults + extras + prefs ----
bash "${SCRIPTS_DIR}/macos-defaults.sh"
bash "${SCRIPTS_DIR}/setup-extras.sh"
bash "${SCRIPTS_DIR}/import-prefs.sh"

echo "==> Darwin bootstrap complete."
