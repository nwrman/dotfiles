#!/usr/bin/env bash
# bootstrap-linux.sh — Unified setup for WSL2 Ubuntu and bare Ubuntu (e.g. DO droplet).
# Invoked by scripts/bootstrap.sh after shared steps; receives DOTFILES_DIR,
# SCRIPTS_DIR, and ROLE via the environment.
set -euo pipefail

: "${DOTFILES_DIR:?DOTFILES_DIR must be set by parent bootstrap.sh}"
: "${SCRIPTS_DIR:=${DOTFILES_DIR}/scripts}"
: "${ROLE:=personal}"

# ---- 1. apt prerequisites ----
bash "${SCRIPTS_DIR}/linux-apt-packages.sh"

# ---- 2. Linuxbrew ----
if ! command -v brew &>/dev/null \
   && [[ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]] \
   && [[ ! -x "$HOME/.linuxbrew/bin/brew" ]]; then
  echo "==> Installing Linuxbrew (non-interactive)..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
  eval "$($HOME/.linuxbrew/bin/brew shellenv)"
fi

# ---- 3. brew bundle ----
echo "==> Installing shared CLI tools from Brewfile.linux..."
brew bundle --verbose --file="${DOTFILES_DIR}/Brewfile.linux"

if [[ "$ROLE" == "work" && -f "${DOTFILES_DIR}/Brewfile.work.linux" ]]; then
  echo "==> Installing work-only CLI tools from Brewfile.work.linux..."
  brew bundle --verbose --file="${DOTFILES_DIR}/Brewfile.work.linux"
fi

# ---- 4. Set zsh as login shell ----
if [[ "$(id -u)" -eq 0 ]]; then SUDO=""; else SUDO="sudo"; fi
ZSH_BIN="$(command -v zsh || true)"
CURRENT_LOGIN_SHELL="$(getent passwd "$(id -un)" | cut -d: -f7)"

if [[ -z "$ZSH_BIN" ]]; then
  echo "WARN: zsh not found in PATH; skipping default shell change."
elif [[ "$CURRENT_LOGIN_SHELL" == "$ZSH_BIN" ]]; then
  echo "==> Default shell already zsh ($ZSH_BIN)."
else
  if ! grep -qxF "$ZSH_BIN" /etc/shells 2>/dev/null; then
    echo "$ZSH_BIN" | $SUDO tee -a /etc/shells >/dev/null
  fi
  echo "==> Setting login shell to $ZSH_BIN (was: $CURRENT_LOGIN_SHELL)..."
  # `sudo chsh -s … <user>` doesn't prompt for the user's password
  # (sudo already authenticated earlier in apt-get).
  $SUDO chsh -s "$ZSH_BIN" "$(id -un)" \
    || echo "WARN: chsh failed; run manually: chsh -s $ZSH_BIN"
fi

echo "==> Linux bootstrap complete."
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  echo "    Detected WSL2: $WSL_DISTRO_NAME"
fi
