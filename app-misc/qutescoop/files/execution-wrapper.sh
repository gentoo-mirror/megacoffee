#!/bin/bash

echo "=== messages below come from a wrapper script installed by the ebuild ==="

destdir="${HOME}/.local/share/QuteScoop/QuteScoop"
templatedir="/usr/share/QuteScoop/data-template"
actualbin="/usr/share/QuteScoop/bin/QuteScoop"

function die {
	echo $@ >&2
	exit 1
}

[[ $EUID -ne 0 ]] || die "Refusing to run as root."

if [[ ! -e "$destdir" ]]; then
	echo "User is missing ${destdir}, copying from template ${templatedir} for first run..."

	[[ -d "$templatedir" ]] || die "QuteScoop data template directory ${templatedir} does not exist"
	
	mkdir -p "$destdir" || die "Failed to create destination directory ${destdir}"
	cp -R $templatedir/* "$destdir/" || die "Failed to copy from template ${templatedir} to destination ${destdir}"
	
	echo "Done."
fi

echo "=== messages below come from the original QuteScoop binary ==="

${actualbin} $@
