
_git_with() {
	__gitcomp_nl "$(__git_heads)"
}

_git_archive_branch() {
	__gitcomp_nl "$(__git_heads | grep -v '^archive/')"
}
