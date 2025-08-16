# Subl
if [[ -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin" ]]; then
  export PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin"
fi

# SmartGit
if [[ -s "/Applications/SmartGit.app/Contents/MacOS/" ]]; then
  export PATH="$PATH:/Applications/SmartGit.app/Contents/MacOS/"
fi

export PATH="~/.bin:./vendor/bin:./node_modules/bin:$PATH"

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

alias gst='git status --ignore-submodules=$_git_status_ignore_submodules'
alias gdiff='git diff --no-ext-diff'
alias grs='git reset --soft'
alias grh='git reset --hard'
