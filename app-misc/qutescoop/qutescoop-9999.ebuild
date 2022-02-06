# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

inherit git-r3
inherit qmake-utils

# Note: GitHub page only states VATSIM as of January 2021 although other networks
#       are currently still supported.
DESCRIPTION="A status monitor for VATSIM and other online flight simulation networks."
HOMEPAGE="https://qutescoop.github.io/qutescoop/"

EGIT_REPO_URI="https://github.com/qutescoop/qutescoop.git"

LICENSE="GPL-3"
SLOT="0"

# empty keywords for 9999 dev version = hardmask
KEYWORDS=""

# only 64 bits because at least paths ("unix64") would need to be changed
#KEYWORDS="~amd64"

# bash is needed for our wrapper script
DEPEND="
	app-shells/bash
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtopengl:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	media-libs/libglvnd
	sys-libs/glibc
	virtual/glu
"

RDEPEND="${DEPEND}"

src_prepare() {
	eapply_user
	eqmake5 QuteScoop.pro
}

src_compile() {
	emake
}

src_install() {
	# instead of using QuteScoop directly install a wrapper script
	# this is needed because QuteScoop needs write permissions to a data directory
	# for every user and does not create the necessary directories which need to
	# contain specific data
	# TODO: script should somehow handle updates
	cp -a ${FILESDIR}/execution-wrapper.sh QuteScoop
	dobin QuteScoop
	
	dodoc CHANGELOG
	dodoc COPYING
	dodoc README.html
	
	into /usr/share/QuteScoop
	dobin DIST-unix64/QuteScoop
	
	insinto /usr/share/applications
	doins ${FILESDIR}/QuteScoop.desktop
	
	insinto /usr/share/icons/hicolor/32x32/apps
	doins src/qutescoop.png

	insinto /usr/share/QuteScoop/data-template
	doins -r data
	doins -r downloaded
	doins -r screenshots
	doins -r textures

	# all directories may currently have a "notes" file but in case those should
	# ever get removed, better add our own "keep" file to the otherwise empty directories
	keepdir /usr/share/QuteScoop/data-template/downloaded
	keepdir /usr/share/QuteScoop/data-template/screenshots
	keepdir /usr/share/QuteScoop/data-template/textures/clouds
}

pkg_postinst() {
	#      12345678901234567890123456789012345678901234567890123456789012345678901234567890
	einfo "QuteScoop expects a fully prepared user-writable directory. Such a directory"
	einfo "cannot be provisioned by this ebuild directly. Instead a wrapper script is used"
	einfo "in place of the original binary which creates a template in the user's home"
	einfo "directory on first run. Future updates to this package may require the user"
	einfo "to delete that directory manually in order to have it re-created:"
	einfo ""
	einfo "    ~/.local/share/QuteScoop"
	einfo ""
	einfo "Please report any issues with the wrapper script to the ebuild author, not"
	einfo "QuteScoop."
}
