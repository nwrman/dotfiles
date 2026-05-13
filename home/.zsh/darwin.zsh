# darwin.zsh — sourced from .zshrc when uname -s = Darwin

# Homebrew (Apple Silicon, then Intel fallback)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Sublime Text CLI
if [[ -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin" ]]; then
  export PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin"
fi

# SmartGit launcher
if [[ -s "/Applications/SmartGit.app/Contents/MacOS/" ]]; then
  alias sg="/Applications/SmartGit.app/Contents/MacOS/SmartGit --open . &"
fi

alias pbc=pbcopy
alias pbp=pbpaste
