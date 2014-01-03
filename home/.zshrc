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
plugins=(git)

# Detect if we have oh-my-zsh and source it
if [ -f $ZSH/oh-my-zsh.sh ]
then
  source $ZSH/oh-my-zsh.sh
fi

# User configuration

export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:~/bin"

# Detect if we are using RVM and if so, add to the path
if [ -f $HOME/.rvm/bin ]
then
  PATH=$PATH:$HOME/.rvm/bin
fi

# Detect if we have homeshick (we always should, but anyways)
if [ -f $HOME/.homesick/repos/homeshick/homeshick.sh ]
then
  source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fi
