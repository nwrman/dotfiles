#!/bin/zsh
# Usage: $> curl -o- https://raw.githubusercontent.com/nwrman/dotfiles/master/install.sh | zsh
#        $> chsh -s /usr/bin/zsh
set -e

# Installing homeshick
if [[ ! -s "$HOME/.homesick/repos/homeshick" ]]; then
  git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
fi

source "$HOME/.homesick/repos/homeshick/homeshick.sh"

if [[ ! -e "$HOME/.homesick/repos/dotfiles" ]]; then
  yes | homeshick clone nwrman/dotfiles
else
  homeshick pull dotfiles
  yes | homeshick link dotfiles || true
fi

# Run the bootstrap script for full machine setup
DOTFILES_DIR="$HOME/.homesick/repos/dotfiles"
if [[ -f "${DOTFILES_DIR}/scripts/bootstrap.sh" ]]; then
  echo ""
  echo "==> Running bootstrap script..."
  bash "${DOTFILES_DIR}/scripts/bootstrap.sh" "$@"
fi
