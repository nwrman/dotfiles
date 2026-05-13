#!/usr/bin/env bash
# bootstrap.sh — Idempotent setup dispatcher for macOS, WSL2 Ubuntu, and bare Ubuntu.
# Safe to re-run at any time. Skips steps that are already done.
#
# Usage:
#   bash scripts/bootstrap.sh              # prompts interactively (works over SSH too)
#   bash scripts/bootstrap.sh personal     # skip prompt, set role directly
#   bash scripts/bootstrap.sh work         # skip prompt, set role directly
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="${DOTFILES_DIR}/scripts"
export DOTFILES_DIR SCRIPTS_DIR

echo "========================================"
echo "  Dotfiles Bootstrap"
echo "  Repo: ${DOTFILES_DIR}"
echo "  OS:   $(uname -s)"
echo "========================================"
echo

# ==============================================================================
# Step 1: Machine role
# ==============================================================================
ROLE_FILE="$HOME/.machine-role"

if [[ -f "$ROLE_FILE" ]]; then
  ROLE="$(cat "$ROLE_FILE")"
  echo "==> Machine role: ${ROLE} (from ${ROLE_FILE})"
elif [[ -n "${1:-}" ]]; then
  case "$1" in
    personal|work) ROLE="$1" ;;
    *)
      echo "ERROR: Invalid role '$1'. Must be 'personal' or 'work'."
      exit 1
      ;;
  esac
  echo "$ROLE" > "$ROLE_FILE"
  echo "==> Machine role: ${ROLE} (set via argument, saved to ${ROLE_FILE})"
else
  echo "==> No machine role found."
  echo "    What role is this machine?"
  echo "    1) personal"
  echo "    2) work"
  read -rp "    Enter 1 or 2: " choice < /dev/tty
  case "$choice" in
    1) ROLE="personal" ;;
    2) ROLE="work" ;;
    *)
      echo "    Invalid choice. Defaulting to 'personal'."
      ROLE="personal"
      ;;
  esac
  echo "$ROLE" > "$ROLE_FILE"
  echo "    Saved '${ROLE}' to ${ROLE_FILE}"
fi
export ROLE
echo

# ==============================================================================
# Step 2: Homeshick clone + link (shared; brewless prereqs)
# ==============================================================================
HOMESHICK_DIR="$HOME/.homesick/repos/homeshick"

if [[ -d "$HOMESHICK_DIR" ]]; then
  echo "==> Homeshick: already installed."
else
  echo "==> Installing Homeshick..."
  git clone https://github.com/andsens/homeshick.git "$HOMESHICK_DIR"
fi

# shellcheck disable=SC1091
source "${HOMESHICK_DIR}/homeshick.sh"
echo "==> Linking dotfiles..."
homeshick --batch --force link dotfiles
echo

# ==============================================================================
# Step 3: Dispatch to OS-specific bootstrap
# ==============================================================================
case "$(uname -s)" in
  Darwin)
    bash "${SCRIPTS_DIR}/bootstrap-darwin.sh"
    ;;
  Linux)
    bash "${SCRIPTS_DIR}/bootstrap-linux.sh"
    ;;
  *)
    echo "ERROR: Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac
echo

# ==============================================================================
# Step 4: Reminders
# ==============================================================================
echo "========================================"
echo "  Bootstrap complete!"
echo "========================================"
echo
if [[ ! -f "$HOME/.secrets" ]]; then
  echo "  REMINDER: Create ~/.secrets with your API keys and tokens."
  echo "  A template is available at: ${DOTFILES_DIR}/home/.secrets.example"
  echo "    cp ${DOTFILES_DIR}/home/.secrets.example ~/.secrets"
  echo "    # Then edit ~/.secrets with your actual values"
  echo
fi
echo "  You may need to restart your terminal for all changes to take effect."
echo
