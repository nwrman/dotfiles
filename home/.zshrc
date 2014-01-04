# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
ZSH_THEME="bira"

# Red dots will be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"


# Shown in the command execution time stamp in the history command output.
HIST_STAMPS="dd.mm.yyyy"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(profiles git git-extras gitignore history-substring-search ssh-agent command-not-found extract rvm z)

# Detect if we have oh-my-zsh and source it
if [ -f $ZSH/oh-my-zsh.sh ]
then
  source $ZSH/oh-my-zsh.sh
fi

# User configuration

export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:~/bin"

# ssh-agent config
zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent lifetime 8h

# Detect if we have homeshick (we always should, but anyways)
if [ -f $HOME/.homesick/repos/homeshick/homeshick.sh ]
then
  source "$HOME/.homesick/repos/homeshick/homeshick.sh"
  fpath=($HOME/.homesick/repos/homeshick/completions $fpath)
fi

# Load common config if exists
if [ -f $HOME/.commonrc ]
then
  source "$HOME/.commonrc"
fi
