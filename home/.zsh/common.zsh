# Subl
if [[ -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin" ]]; then
  export PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin"
fi

alias t="/.vendor/bin/phpunit"
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

