# darwin.zsh — sourced from .zshrc when uname -s = Darwin

# Homebrew (Apple Silicon, then Intel fallback)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# mysql-client is keg-only; add its bin to PATH so `mysql` resolves.
if [[ -d "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/mysql-client/bin" ]]; then
  export PATH="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/mysql-client/bin:$PATH"
fi

# Sublime Text CLI
if [[ -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin" ]]; then
  export PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin"
fi

# SmartGit launcher
if [[ -s "/Applications/SmartGit.app/Contents/MacOS/" ]]; then
  sg() {
    if (( $# == 0 )); then
      open -a SmartGit
    else
      local -a paths
      local arg
      for arg in "$@"; do
        paths+=("${arg:a}")
      done
      open -a SmartGit --args --open "${paths[@]}"
    fi
  }
fi

alias pbc=pbcopy
alias pbp=pbpaste
