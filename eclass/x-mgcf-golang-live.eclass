# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: x-mgcf-golang-live.eclass
# @MAINTAINER:
# MegaCoffee Overlay <gentoo-overlay@megacoffee.net>
# @AUTHOR:
# Mauro Toffanin <toffanin.mauro@gmail.com>
# @BLURB: Eclass for fetching and unpacking HEAD shapshot of go repositories
# @DESCRIPTION:
# This eclass is written to ease the maintenance of live ebuilds
# of software written in the Go programming language.

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

if [[ -z ${_GOLANG_LIVE_ECLASS} ]]; then
_GOLANG_LIVE_ECLASS=1


# @ECLASS-VARIABLE: EGO_LIVESTORE_DIR
# @INTERNAL
# @DESCRIPTION:
# Storage directory for Go sources.
# Ebuilds must not set it.

# @ECLASS-VARIABLE: EVCS_UMASK
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set this variable to a custom umask. This is intended to be set by
# users. By setting this to something like 002, it can make life easier
# for people who do development as non-root (but are in the portage
# group), and then switch over to building with FEATURES=userpriv.
# Or vice-versa. Shouldn't be a security issue here as anyone who has
# portage group write access already can screw the system over in more
# creative ways.


# Validates use of GOLANG_PKG_DEPENDENCIES.
# NOTE: a live ebuild should not have go dependencies.
# TODO: check also if GOLANG_PKG_DEPENDENCIES is an array
if [[ -n ${GOLANG_PKG_DEPENDENCIES} ]]; then
	eerror "Ebuild ${CATEGORY}/${PF} specifies GOLANG_PKG_DEPENDENCIES."
	eerror "Please, fix it by removing GOLANG_PKG_DEPENDENCIES entirely."
	die "Banned variable GOLANG_PKG_DEPENDENCIES is set"
fi


# @FUNCTION: x-mgcf-golang-live_src_fetch
# @DESCRIPTION:
# Fetch a go package along with its dependencies.
x-mgcf-golang-live_src_fetch() {
	debug-print-function ${FUNCTION} "$@"

	[[ -z ${EGO_LIVESTORE_DIR} ]] && die "No EGO_LIVESTORE_DIR set (x-mgcf-golang-live_src_unpack not called?)."

	# Fetch the go package
	[[ -n ${EVCS_UMASK} ]] && eumask_push ${EVCS_UMASK}

	set -- env \
		GOPATH="${EGO_LIVESTORE_DIR}" \
		go get -d -u -v -t -tags="${GOLANG_PKG_TAGS}" ${@}
	echo "$@"
	"$@" || die

	[[ -n ${EVCS_UMASK} ]] && eumask_pop
}

# @FUNCTION: x-mgcf-golang-live_src_unpack
# @DESCRIPTION:
# Unpack the source archive.
x-mgcf-golang-live_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	# Creates EGO_LIVESTORE_DIR if necessary.
	local distdir=${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}
	: EGO_LIVESTORE_DIR=${EGO_LIVESTORE_DIR:=${distdir}/go-${PN}-livesrc}

	[[ -n ${EVCS_UMASK} ]] && eumask_push ${EVCS_UMASK}

	if [[ ! -d ${EGO_LIVESTORE_DIR} ]]; then
		(
			addwrite /
			mkdir -p "${EGO_LIVESTORE_DIR}"
		) || die "${ECLASS}: unable to create ${EGO_LIVESTORE_DIR}"
	fi

	addwrite "${EGO_LIVESTORE_DIR}"

	[[ -n ${EVCS_UMASK} ]] && eumask_pop

	# Retrieves the GOLANG_PKG_IMPORTPATH go package.
	x-mgcf-golang-live_src_fetch "${GOLANG_PKG_IMPORTPATH}/${GOLANG_PKG_NAME}"/...

	# Creates SOURCE directory.
	mkdir -p "${S}" || die
}


# @FUNCTION: x-mgcf-golang-live_src_prepare
# @DESCRIPTION:
# Prepare source code.
x-mgcf-golang-live_src_prepare() {
	debug-print-function ${FUNCNAME} "${@}"

	# Sets up GoLang build environment.
	x-mgcf-golang_setup

	# Imports all go dependencies
	ebegin "Importing all the sources in ${GOPATH}"
		cp -r "${EGO_LIVESTORE_DIR}/src" "${GOPATH}" || die "Unable to copy sources to ${GOPATH}"
	eend

	x-mgcf-golang-common_src_prepare
}


# @FUNCTION: x-mgcf-golang-live_src_configure
# @DESCRIPTION:
# Configure the package.
x-mgcf-golang-live_src_configure() {
	debug-print-function ${FUNCNAME} "$@"

	x-mgcf-golang-common_src_configure
}

# @FUNCTION: x-mgcf-golang-live_src_compile
# @DESCRIPTION:
# Compiles the package.
x-mgcf-golang-live_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	x-mgcf-golang-common_src_compile
}

# @FUNCTION: x-mgcf-golang-live_src_install
# @DESCRIPTION:
# Installs binaries and documents from DOCS or HTML_DOCS arrays.
x-mgcf-golang-live_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	x-mgcf-golang-common_src_install
}

# @FUNCTION: x-mgcf-golang-live_src_test
# @DESCRIPTION:
# Runs the unit tests for the main package.
x-mgcf-golang-live_src_test() {
	debug-print-function ${FUNCNAME} "$@"

	x-mgcf-golang-common_src_test
}


fi
