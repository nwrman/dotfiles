#compdef artisan a

# Dynamic artisan completions via Symfony Console.
# Calls `./artisan _complete` at runtime to discover all commands
# including app-specific ones (boost:update, deploy:*, etc.)
#
# Based on: php artisan completion zsh (Symfony Console)
# Modified: uses ./artisan directly instead of `php artisan` two-word pattern

_sf_artisan() {
    local lastParam flagPrefix requestComp out comp
    local -a completions

    words=("${=words[1,CURRENT]}") lastParam=${words[-1]}

    setopt local_options BASH_REMATCH
    if [[ "${lastParam}" =~ '-.*=' ]]; then
        flagPrefix="-P ${BASH_REMATCH}"
    fi

    # Use ./artisan directly (not the two-word `php artisan` pattern)
    requestComp="./artisan _complete --no-interaction -szsh -a1 -c$((CURRENT-1))" i=""
    for w in ${words[@]}; do
        w=$(printf -- '%b' "$w")
        quote="${w:0:1}"
        if [ "$quote" = \' ]; then
            w="${w%\'}"
            w="${w#\'}"
        elif [ "$quote" = \" ]; then
            w="${w%\"}"
            w="${w#\"}"
        fi
        if [ ! -z "$w" ]; then
            i="${i}-i${w} "
        fi
    done

    if [ "${i}" = "" ]; then
        requestComp="${requestComp} -i\" \""
    else
        requestComp="${requestComp} ${i}"
    fi

    out=$(eval ${requestComp} 2>/dev/null)

    while IFS='\n' read -r comp; do
        if [ -n "$comp" ]; then
            comp=${comp//:/\\:}
            local tab=$(printf '\t')
            comp=${comp//$tab/:}
            completions+=${comp}
        fi
    done < <(printf "%s\n" "${out[@]}")

    eval _describe "completions" completions $flagPrefix
    return $?
}

compdef _sf_artisan artisan
