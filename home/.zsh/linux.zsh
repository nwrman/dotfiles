# linux.zsh — sourced from .zshrc when uname -s = Linux

# Linuxbrew shellenv (system-wide install first, per-user fallback)
if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
  eval "$($HOME/.linuxbrew/bin/brew shellenv)"
fi

# `open` shim — wslview on WSL, xdg-open elsewhere
if [[ -n "${WSL_DISTRO_NAME:-}" ]] && command -v wslview >/dev/null 2>&1; then
  alias open=wslview
elif command -v xdg-open >/dev/null 2>&1; then
  alias open=xdg-open
fi

# pbcopy / pbpaste shims
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  alias pbcopy='clip.exe'
  alias pbpaste='powershell.exe -NoProfile -Command Get-Clipboard | tr -d "\r"'
elif command -v wl-copy >/dev/null 2>&1; then
  alias pbcopy='wl-copy'
  alias pbpaste='wl-paste'
elif command -v xclip >/dev/null 2>&1; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
elif command -v xsel >/dev/null 2>&1; then
  alias pbcopy='xsel --clipboard --input'
  alias pbpaste='xsel --clipboard --output'
fi
alias pbc=pbcopy
alias pbp=pbpaste

# WSL-only conveniences
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  alias cdwin='cd /mnt/c/Users/'
  alias explorer='explorer.exe .'
fi
