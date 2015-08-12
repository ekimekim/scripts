
_fab_completion() {
    local current=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "$(run-fab --shortlist)" -- "$current") )
}

complete -F _fab_completion run-fab
