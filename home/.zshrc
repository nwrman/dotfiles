# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Source Homeshick
if [[ -s "$HOME/.homesick/repos/homeshick/homeshick.sh" ]]; then
  source "$HOME/.homesick/repos/homeshick/homeshick.sh"
  fpath=($HOME/.homesick/repos/homeshick/completions $fpath)
fi

# Source local .zshrc
if [[ -s $HOME/.zsh ]]; then
  for file in $HOME/.zsh/*; do
    source "$file"
  done
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
# bindkey '^p' history-search-backward
# bindkey '^n' history-search-forward
# bindkey '^[w' kill-region

# Navigation keys
bindkey '^[[H' beginning-of-line     # Home
bindkey '^[[F' end-of-line           # End
bindkey '^[[1~' beginning-of-line    # Home (alternative)
bindkey '^[[4~' end-of-line          # End (alternative)

# Word navigation
bindkey '^[[1;5C' forward-word       # Ctrl+Right
bindkey '^[[1;5D' backward-word      # Ctrl+Left
bindkey '^[^[[C' forward-word        # Alt+Right  
bindkey '^[^[[D' backward-word       # Alt+Left

# Delete operations
bindkey '^[[3~' delete-char          # Delete
bindkey '^H' backward-delete-char    # Backspace
bindkey '^W' backward-kill-word      # Ctrl+W
bindkey '^[[3;5~' kill-word          # Ctrl+Delete

# Line operations
bindkey '^A' beginning-of-line       # Ctrl+A
bindkey '^E' end-of-line             # Ctrl+E
bindkey '^K' kill-line               # Ctrl+K
bindkey '^U' backward-kill-line      # Ctrl+U

# History navigation
bindkey '^[[5~' history-search-backward  # Page Up
bindkey '^[[6~' history-search-forward   # Page Down

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

# Shell integrations

if type fzf &>/dev/null; then
    eval "$(fzf --zsh)"
fi

if type zoxide &>/dev/null; then
    eval "$(zoxide init --cmd cd zsh)"
fi