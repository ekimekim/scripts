
_fab_completion() {
    local current=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
	if egrep -qe '-[^=]*R' <<<"$prev"; then
		options="$(run-fab print_roles)"
	else
		options="$(run-fab --shortlist)"
	fi
    COMPREPLY=( $(compgen -W "$options" -- "$current") )
}

complete -F _fab_completion run-fab
