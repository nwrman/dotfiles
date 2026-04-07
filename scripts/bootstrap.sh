#!/usr/bin/env bash
# bootstrap.sh — Idempotent setup for a new (or existing) Mac
# Safe to re-run at any time. Skips steps that are already done.
#
# Usage:
#   bash scripts/bootstrap.sh              # prompts interactively (works over SSH too)
#   bash scripts/bootstrap.sh personal     # skip prompt, set role directly
#   bash scripts/bootstrap.sh work         # skip prompt, set role directly
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="${DOTFILES_DIR}/scripts"

echo "========================================"
echo "  Dotfiles Bootstrap"
echo "  Repo: ${DOTFILES_DIR}"
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
  # Accept role as CLI argument (for CI / fully headless)
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
  # Prompt via /dev/tty — works even when stdin is piped (curl | bash, SSH pipe)
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

echo

# ==============================================================================
# Step 2: Install Homebrew (if missing)
# ==============================================================================
if command -v brew &>/dev/null; then
  echo "==> Homebrew: already installed."
else
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for the rest of this script
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

echo "==> Updating Homebrew..."
brew update

echo

# ==============================================================================
# Step 3: Install packages from Brewfile
# ==============================================================================
# Accept Microsoft EULA for msodbcsql18 (ODBC driver)
export HOMEBREW_ACCEPT_EULA=Y

echo "==> Installing shared packages from Brewfile..."
brew bundle --verbose --file="${DOTFILES_DIR}/Brewfile"

if [[ "$ROLE" == "work" && -f "${DOTFILES_DIR}/Brewfile.work" ]]; then
  echo "==> Installing work-only packages from Brewfile.work..."
  brew bundle --verbose --file="${DOTFILES_DIR}/Brewfile.work"
fi

echo

# ==============================================================================
# Step 4: Install Homeshick (if missing) and link dotfiles
# ==============================================================================
HOMESHICK_DIR="$HOME/.homesick/repos/homeshick"

if [[ -d "$HOMESHICK_DIR" ]]; then
  echo "==> Homeshick: already installed."
else
  echo "==> Installing Homeshick..."
  git clone https://github.com/andsens/homeshick.git "$HOMESHICK_DIR"
fi

source "${HOMESHICK_DIR}/homeshick.sh"
echo "==> Linking dotfiles..."
yes | homeshick link dotfiles || true

echo

# ==============================================================================
# Step 5: Apply macOS defaults
# ==============================================================================
bash "${SCRIPTS_DIR}/macos-defaults.sh"

echo

# ==============================================================================
# Step 6: Setup extras (Touch ID, Spicetify, etc.)
# ==============================================================================
bash "${SCRIPTS_DIR}/setup-extras.sh"

echo

# ==============================================================================
# Step 7: Import app preferences
# ==============================================================================
bash "${SCRIPTS_DIR}/import-prefs.sh"

echo

# ==============================================================================
# Step 8: Reminders
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
