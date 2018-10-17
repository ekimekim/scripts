
# Prefixes current PS1 with a blank space
# This blank space changes to a number if any command
# given in the ALERTS array exits non-zero.
# (additionally, a ? character is an error state - this shouldn't happen)
# Tip: ALERTS may be appended to thusly: ALERTS+=('mycommand myarg')
# Note: Commands in ALERTS are run every time PS1 is printed.
# However, if any command fails (indicates an alert), no further commands will be run.

# Defines the function alerts() which will run and print results verbosely

declare -a ALERTS[0]

_alerts_check() {
	local failed=0
	for command in "${ALERTS[@]}"; do
		if ! $command; then
			failed=$((failed+1))
		fi
	done
	if [ "$failed" -gt 0 ]; then
		echo -en "\b$failed"
	else
		echo -en '\b '
	fi
	return "$failed"
}

alerts() {
	local verbose="$1"
	for command in "${ALERTS[@]}"; do
		if [ -n "$verbose" ]; then
			echo "Alert: $command"
			$command
			echo "Exit status: $?"
			echo
		else
			if ! $command; then
				echo "$command"
			fi
		fi
	done
}

PS1='?\[$(_alerts_check)\]'"${PS1}"
