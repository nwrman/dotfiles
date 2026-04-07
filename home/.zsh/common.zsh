# Subl
if [[ -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin" ]]; then
  export PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin"
fi

# SmartGit
if [[ -s "/Applications/SmartGit.app/Contents/MacOS/" ]]; then
  alias sg="/Applications/SmartGit.app/Contents/MacOS/SmartGit --open . &"
fi

# Composer
if [[ -s "~/.composer/vendor/bin" ]]; then
  export PATH=$PATH:~/.composer/vendor/bin
fi

# nvm
[[ ! -f $HOME/.nvm/nvm.sh ]] || source $HOME/.nvm/nvm.sh

# Local .bin directory for random binaries
if [[ -d "$HOME/.bin" ]]; then
  export PATH="$HOME/.bin:$PATH"
fi

# Add current directory bin folders for Composer and Node
export PATH="./vendor/bin:./node_modules/bin:$PATH"

export HOMEBREW_NO_AUTO_UPDATE=1

alias t="./vendor/bin/pest"
alias tb="./vendor/bin/pest --bail"
alias ct="composer test"
alias cut="composer test:unit"
alias ctt="composer test:types"
alias cl="composer lint"
alias a="php artisan"
alias dcu="docker-compose up -d"
alias dcs="docker-compose stop"
alias dcr="dcs && dcu"
alias gp="git pull --rebase --autostash"
alias gu="git reset --soft HEAD~1"
alias magento="php -d memory_limit=2048M ./bin/magento"
alias d="npm run dev"
alias nr="npm run"
alias pn="pnpm"
alias pnx="pnpm --dlx"
alias pd="pnpm run dev"
alias c="composer"
alias pbc=pbcopy
alias pbp=pbpaste
alias y=yazi

# Git log formats (from Prezto)
_git_log_medium_format='%C(bold)Commit:%C(reset) %C(green)%H%C(reset)%n%C(bold)Author:%C(reset) %C(bold blue)%an <%ae>%C(reset)%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'
_git_log_oneline_format='%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n'
_git_log_brief_format='%C(green)%h%C(reset) %s%n%C(blue)(%ar by %an)%C(red)%d%C(reset)%n'

# GIT

alias nah="git reset --hard && git clean -df"

alias g='git'

alias gsw='git switch -'

alias gco='git checkout'
alias gc='git commit --verbose'
alias gcp='git cherry-pick --ff'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gfc='git clone'
alias gp='git pull --rebase --autostash'

alias gl='git log --topo-order --pretty=format:"$_git_log_medium_format"'
alias gls='git log --topo-order --stat --pretty=format:"$_git_log_medium_format"'
alias gld='git log --topo-order --stat --patch --full-diff --pretty=format:"$_git_log_medium_format"'
alias glo='git log --topo-order --pretty=format:"$_git_log_oneline_format"'
alias glg='git log --topo-order --graph --pretty=format:"$_git_log_oneline_format"'
alias glb='git log --topo-order --pretty=format:"$_git_log_brief_format"'
alias glc='git shortlog --summary --numbered'

alias gpu='git push'
alias gpuF='git push --force'

alias gr='git rebase'
alias gra='git rebase --abort'
alias grc='git rebase --continue'

alias gR='git remote --verbose'
alias gRa='git remote add'
alias gRx='git remote rm'
alias gRm='git remote rename'
alias gRu='git remote update'

alias gst='git status --ignore-submodules=dirty'
alias gdiff='git diff --no-ext-diff'
alias grs='git reset --soft'
alias grh='git reset --hard'

# ls

alias l='ls -1A'
alias la='ll -A'
alias lc='lt -c'
alias lk='ll -Sr'
alias ll='ls -lh'
alias lm='la | "$PAGER"'
alias ln='nocorrect ln -i'
alias lni='nocorrect ln -i'
alias locate='noglob locate'
alias lr='ll -R'
alias ls='ls -G'
alias lt='ll -tr'
alias lu='lt -u'

# Better command defaults

alias cp='nocorrect cp -i'
alias grep='nocorrect grep --color=auto'
alias man='nocorrect man'
alias mkdir='nocorrect mkdir -p'
alias mv='nocorrect mv -i'
alias rm='nocorrect rm -i'
alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'

# Secrets (API keys, tokens) are loaded from ~/.secrets
# See ~/.secrets.example for the template.
