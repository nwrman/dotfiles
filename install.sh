#!/usr/bin/env bash
# install.sh — One-shot entry point for macOS, WSL2 Ubuntu, and bare Ubuntu.
# Usage: curl -fsSL https://raw.githubusercontent.com/nwrman/dotfiles/master/install.sh | bash
set -euo pipefail

OS="$(uname -s)"

# On Linux, ensure git/curl/zsh exist before doing anything else (fresh droplets).
if [[ "$OS" == "Linux" ]]; then
  if [[ "$(id -u)" -eq 0 ]]; then SUDO=""; else SUDO="sudo"; fi
  need_apt=0
  for c in git curl zsh; do
    command -v "$c" >/dev/null 2>&1 || need_apt=1
  done
  if [[ $need_apt -eq 1 ]]; then
    echo "==> Installing prerequisites (git, curl, zsh, ca-certificates)..."
    export DEBIAN_FRONTEND=noninteractive
    $SUDO apt-get update -y
    $SUDO apt-get install -y --no-install-recommends git curl zsh ca-certificates
  fi
fi

# Clone homeshick
if [[ ! -d "$HOME/.homesick/repos/homeshick" ]]; then
  git clone https://github.com/andsens/homeshick.git "$HOME/.homesick/repos/homeshick"
fi
# shellcheck disable=SC1091
source "$HOME/.homesick/repos/homeshick/homeshick.sh"

# Clone (or update) the dotfiles castle
if [[ ! -e "$HOME/.homesick/repos/dotfiles" ]]; then
  yes | homeshick clone nwrman/dotfiles
else
  homeshick pull dotfiles
fi
yes | homeshick link dotfiles || true

# Run bootstrap (bash, not zsh — zsh may not be the login shell yet)
DOTFILES_DIR="$HOME/.homesick/repos/dotfiles"
if [[ -f "${DOTFILES_DIR}/scripts/bootstrap.sh" ]]; then
  echo ""
  echo "==> Running bootstrap script..."
  bash "${DOTFILES_DIR}/scripts/bootstrap.sh" "$@"
fi
