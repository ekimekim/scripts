
# Prefixes current PS1 with a blank space
# This blank space changes to a ! character if any command
# given in the ALERTS array exits non-zero.
# (additionally, a ? character is an error state - this shouldn't happen)
# Tip: ALERTS may be appended to thusly: ALERTS+=('mycommand myarg')
# Note: Commands in ALERTS are run every time PS1 is printed.
# However, if any command fails (indicates an alert), no further commands will be run.

# Defines the function alerts() which will run and print results verbosely

declare -a ALERTS[0]

_alerts_check() {
	for command in "${ALERTS[@]}"; do
		if ! $command; then
			echo -en '\b!'
			return 1
		fi
	done
	echo -en '\b '
	return 0
}

alerts() {
	for command in "${ALERTS[@]}"; do
		echo "Alert: $command"
		$command
		echo "Exit status: $?"
		echo
	done
}

PS1='?\[$(_alerts_check)\]'"${PS1}"
