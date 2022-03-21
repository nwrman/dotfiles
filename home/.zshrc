# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Source Homeshick
if [[ -s "$HOME/.homesick/repos/homeshick/homeshick.sh" ]]; then
  source "$HOME/.homesick/repos/homeshick/homeshick.sh"
  fpath=($HOME/.homesick/repos/homeshick/completions $fpath)
fi

# Source nvm
[[ ! -f $HOME/.nvm/nvm.sh ]] || source $HOME/.nvm/nvm.sh

# Handle rvm
[[ ! -f $HOME/.rvm/bin ]] || export PATH=$PATH:$HOME/.rvm/bin

# Custom PATH
export PATH=$PATH:~/.composer/vendor/bin

# Aliases
alias agent='eval `ssh-agent` && ssh-add'
alias t="./vendor/bin/phpunit"
alias ct="composer test"
alias cut="composer test:unit"
alias ctt="composer test:types"
alias cl="composer lint"
alias a="php artisan"
alias pt="./vendor/bin/pest"
alias nah="git reset --hard && git clean -df"
alias dcu="docker-compose up -d"
alias dcs="docker-compose stop"
alias dcr="dcs && dcu"
alias gp="git pull --rebase --autostash"
alias gu="git reset --soft HEAD~1"
alias magento="php -d memory_limit=2048M ./bin/magento"

# Source local .zshrc
[[ ! -f $HOME/.local.zshrc ]] || source $HOME/.local.zshrc

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
