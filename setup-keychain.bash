
# Runs the nessecary magic to setup keys in keychain
# You SHOULD pass in -Q unless you want an explicit check that all keys really are present

KEYS=(
	id_rsa
	id_rsa-cloudscaling
)

eval $(keychain --eval --agents ssh --quiet "$@" "${KEYS[@]}")
