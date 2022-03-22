#!/bin/zsh
# Usage: $> curl -o- https://raw.githubusercontent.com/nwrman/dotfiles/master/install.sh | zsh
#        $> chsh -s /usr/bin/zsh
set -e

if [[ ! -s "${ZDOTDIR:-$HOME}/.zprezto" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

current_date_time="`date -u "+%Y-%m-%d_%H_%M"`";

# Create backup folder
#
if [[ -f "$HOME/.zshrc" ]]; then
  mkdir "$HOME/.zsh_$current_date_time.bak"
fi

setopt EXTENDED_GLOB

  for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do

    if [ -f "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]
      then
      cp -L "${ZDOTDIR:-$HOME}/.${rcfile:t}" "${ZDOTDIR:-$HOME}/.zsh_$current_date_time.bak/"
      rm -f "${ZDOTDIR:-$HOME}/.${rcfile:t}"
      echo "${ZDOTDIR:-$HOME}/.${rcfile:t} is backed up"
    fi

    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"


  done

# Installing homeshick
if [[ ! -s "$HOME/.homesick/repos/homeshick" ]]; then
  git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
fi

if [[ -s "$HOME/.homesick/repos/dotfiles" ]]; then
  rm -rf "$HOME/.homesick/repos/dotfiles"
fi

source "$HOME/.homesick/repos/homeshick/homeshick.sh"

yes | homeshick clone nwrman/dotfiles
