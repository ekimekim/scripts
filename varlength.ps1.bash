
PS1='\[`random_colour``plain_if_git`\][\t] \[`ttyname`\]\[`maybe_git`\] \u@\h:\w\$ \[\e[m\]'

ttyname() {
	if tty | grep '^/dev/' > /dev/null
	then
		tty | tail -c+6
	else
		tty
	fi
}

random_colour() {
	echo -e "\e[$[$RANDOM*2/32268]m\e[3$[$RANDOM*7/32268+1]m"
}

maybe_git() {
	if git status > /dev/null 2>&1
	then
		# Check if clean
		if git status | tail -n+2 | awk 'BEGIN {val=1}; $0 == "# Untracked files:" || $0 == "nothing to commit (working directory clean)" {exit(val)}; $0 ~ /^#\t/ {val=0}'
		then
			echo -en '\e[31m\e[1m' # Bold red
		else
			echo -en '\e[m' # Clear
		fi  
		echo -en ' (git)\e[m'
	fi
}

plain_if_git() {
	if git status >/dev/null 2>&1
	then
		echo -en '\e[m'
	fi
}

