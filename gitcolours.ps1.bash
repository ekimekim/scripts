
# Wraps your PS1 to change colour based on the git state, one of:
#  Not in git repo
#  No tracked changes
#  Changes found in working tree

PS1='\[`git_colour`\]'"${PS1}"'\[\e[m\]'

GITCOLOUR_CHANGES="\e[1m\e[31m" # bold red
GITCOLOUR_NOCHANGES="\e[1m\e[32m" # bold green
GITCOLOUR_PLAIN="\e[1m\e[34m" # bold blue

git_colour() {
	if git status > /dev/null 2>&1
	then
		# Check if clean
		if [ -n "$(git status --porcelain)" ]
		then
			echo -en "$GITCOLOUR_CHANGES"
		else
			echo -en "$GITCOLOUR_NOCHANGES"
		fi
	else
		echo -en "$GITCOLOUR_PLAIN"
	fi
}
