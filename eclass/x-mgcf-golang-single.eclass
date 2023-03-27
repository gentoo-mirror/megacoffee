# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: x-mgcf-golang-single.eclass
# @MAINTAINER:
# MegaCoffee Overlay <gentoo-overlay@megacoffee.net>
# @AUTHOR:
# Mauro Toffanin <toffanin.mauro@gmail.com>
# @BLURB: An eclass for GoLang packages not installed inside GOPATH/GOBIN.
# @DESCRIPTION:
# This eclass allows to install arbitrary packages written in GoLang which
# don't support being installed inside the Go environment.
# This mostly includes traditional packages (C/C++/GUI) embedding tools written
# in GoLang, and GoLang packages that need to be compiled with GCC instead of
# the standard Go interpreter.
#
# @EXAMPLE:
# Typical ebuild using golang-single.eclass:
#
# @CODE
# EAPI=5
#
# GOLANG_PKG_IMPORTPATH="github.com/captObvious"
# GOLANG_PKG_ARCHIVESUFFIX=".zip"
# GOLANG_PKG_HAVE_TEST
# inherit golang-single qt4-r2
#
# DESCRIPTION="Foo bar application"
# HOMEPAGE="http://example.org/foo/"
#
# LICENSE="MIT"
# KEYWORDS="~amd64 ~x86"
# SLOT="0"
# IUSE="doc qt4"
#
# CDEPEND="
#   qt4? (
#       dev-qt/qtcore:4
#       dev-qt/qtgui:4
#   )"
# RDEPEND="${CDEPEND}
#   !media-gfx/bar"
# DEPEND="${CDEPEND}
#   doc? ( app-doc/doxygen )"
#
# DOCS=(AUTHORS ChangeLog README "Read me.txt" TODO)
#
# PATCHES=(
#   "${FILESDIR}/${P}-qt4.patch" # bug 123458
#   "${FILESDIR}/${P}-as-needed.patch"
# )
#
# src_install() {
#   use doc && HTML_DOCS=("${BUILD_DIR}/apidocs/html/")
#   autotools-utils_src_install
#   if use examples; then
#       dobin "${BUILD_DIR}"/foo_example{1,2,3} \\
#           || die 'dobin examples failed'
#   fi
# }
#
# @CODE

inherit x-mgcf-golang-common

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!                                                             !!!
# !!!                L E G A C Y    E C L A S S                   !!!
# !!!                                                             !!!
# !!!         DO NOT USE OUTSIDE OF MEGACOFFEE OVERLAY            !!!
# !!!                                                             !!!
# !!!                DO NOT USE FOR NEW EBUILDS                   !!!
# !!!                                                             !!!
# !!! This eclass has only been copied to megacoffee overlay from !!!
# !!! go-overlay: https://github.com/Dr-Terrible/go-overlay       !!!
# !!!                                                             !!!
# !!! The only purpose is to keep currently depending ebuilds     !!!
# !!! until they could be migrated to standard eclasses for Go,   !!!
# !!! if suitable.                                                !!!
# !!!                                                             !!!
# !!! go-overlay was previously imported by megacoffee until it   !!!
# !!! got removed from Gentoo overlay index in March 2023,        !!!
# !!! rendering megacoffee overlay unreachable as a result.       !!!
# !!!                                                             !!!
# !!! Related bugs: https://bugs.gentoo.org/864653                !!!
# !!!               https://bugs.gentoo.org/903167                !!!
# !!!                                                             !!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


EXPORT_FUNCTIONS src_prepare src_unpack src_configure src_compile src_install src_test

if [[ -z ${_GOLANG_SINGLE_ECLASS} ]]; then
_GOLANG_SINGLE_ECLASS=1


# This eclass uses GOLANG_PKG_IMPORTPATH to populate SRC_URI.
SRC_URI="${SRC_URI:="https://${GOLANG_PKG_IMPORTPATH}/${GOLANG_PKG_NAME}/archive/${GOLANG_PKG_ARCHIVEPREFIX}${GOLANG_PKG_VERSION}${GOLANG_PKG_ARCHIVESUFFIX} -> ${P}${GOLANG_PKG_ARCHIVESUFFIX}"}"

# This eclass uses GOLANG_PKG_DEPENDENCIES associative array to populate SRC_URI
# with the required snapshots of the supplied GoLang dependencies.
if [[ ${#GOLANG_PKG_DEPENDENCIES[@]} -gt 0 ]]; then

	for i in ${!GOLANG_PKG_DEPENDENCIES[@]} ; do

		# Collects all the tokens of the dependency.
		local -A DEPENDENCY=()
		while read -d $'\n' key value; do
			[[ -z ${key} ]] && continue
			DEPENDENCY[$key]="${value}"
		done <<-EOF
			$( _factorize_dependency_entities "${GOLANG_PKG_DEPENDENCIES[$i]}" )
		EOF

		# Debug
		debug-print "${FUNCNAME}: DEPENDENCY = ${GOLANG_PKG_DEPENDENCIES[$i]}"
		debug-print "${FUNCNAME}: importpath = ${DEPENDENCY[importpath]}"
		debug-print "${FUNCNAME}: revision   = ${DEPENDENCY[revision]}"

		# Downloads the archive.
		case ${DEPENDENCY[importpath]} in
			github*)
				SRC_URI+=" https://${DEPENDENCY[importpath]}/archive/${DEPENDENCY[revision]}${GOLANG_PKG_ARCHIVESUFFIX} -> ${DEPENDENCY[importpath]//\//-}-${DEPENDENCY[revision]}${GOLANG_PKG_ARCHIVESUFFIX}"
				;;
			bitbucket*)
				SRC_URI+=" https://${DEPENDENCY[importpath]}/get/${DEPENDENCY[revision]}.zip -> ${DEPENDENCY[importpath]//\//-}-${DEPENDENCY[revision]}.zip"
				;;
			code.google*)
				SRC_URI+=" https://${DEPENDENCY[project_name]}.googlecode.com/archive/${DEPENDENCY[revision]}.tar.gz -> ${DEPENDENCY[importpath]//\//-}-${DEPENDENCY[revision]}.tar.gz"
				;;
			*) die "This eclass doesn't support '${DEPENDENCY[importpath]}'" ;;
		esac

	done
fi


# @FUNCTION: x-mgcf-golang-single_src_unpack
# @DESCRIPTION:
# Unpack the source archive.
x-mgcf-golang-single_src_unpack() {
	debug-print-function ${FUNCNAME} "${@}"

	default

	# Creates S.
	mkdir -p "${S%/*}" || die

	# Moves main GoLang package from WORKDIR into GOPATH.
	if [[ "${GOLANG_PKG_IMPORTPATH}" != "${GOLANG_PKG_IMPORTPATH_ALIAS}" ]]; then
		local alias_abspath="${WORKDIR}/gopath/src/${GOLANG_PKG_IMPORTPATH_ALIAS}/${GOLANG_PKG_NAME}"
		mkdir -p "${alias_abspath%/*}" || die
		mv "${GOLANG_PKG_NAME}-${GOLANG_PKG_VERSION}" "${alias_abspath}"/ || die
	else
		mv "${GOLANG_PKG_NAME}-${GOLANG_PKG_VERSION}" "${S}"/ || die
	fi
}


# @FUNCTION: x-mgcf-golang-single_src_prepare
# @DESCRIPTION:
# Prepare source code.
x-mgcf-golang-single_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	# Sets up GoLang build environment.
	x-mgcf-golang_setup

	x-mgcf-golang-common_src_prepare
}

# @FUNCTION: x-mgcf-golang-single_src_configure
# @DESCRIPTION:
# Configure the package.
x-mgcf-golang-single_src_configure() {
	debug-print-function ${FUNCNAME} "$@"

	x-mgcf-golang-common_src_configure
}

# @FUNCTION: x-mgcf-golang-single_src_compile
# @DESCRIPTION:
# Compiles the package.
x-mgcf-golang-single_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	x-mgcf-golang-common_src_compile
}

# @FUNCTION: x-mgcf-golang-single_src_install
# @DESCRIPTION:
# Installs binaries and documents from DOCS or HTML_DOCS arrays.
x-mgcf-golang-single_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	x-mgcf-golang-common_src_install
}

# @FUNCTION: x-mgcf-golang-single_src_test
# @DESCRIPTION:
# Runs the unit tests for the main package.
x-mgcf-golang-single_src_test() {
	debug-print-function ${FUNCNAME} "$@"

	x-mgcf-golang-common_src_test
}

fi
