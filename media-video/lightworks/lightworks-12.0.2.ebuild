# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

# ToDo list:
#
# - figure out runtime dependencies
# - try to move Lightworks to /opt as it is only available as a pre-compiled binary
#   (not sure if possible since it is intended to be installed to /usr)
# - try to silence QA notices
# - figure out if high load/memory usage (memleak?) of ntcardvt process are specific to Gentoo

inherit font

DESCRIPTION="feature-rich non-linear video editor (NLE)"
HOMEPAGE="http://www.lwks.com/"
SRC_URI="lwks-12.0.2-amd64.deb"

LICENSE="Lightworks"
RESTRICT="fetch"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="app-arch/dpkg sys-apps/sed"
RDEPEND=""

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please visit ${HOMEPAGE} to download Lightworks ${PV} and place ${SRC_URI} in ${DISTDIR}."
}

src_unpack() {
	/usr/bin/dpkg-deb -x ${DISTDIR}/${SRC_URI} ${WORKDIR}
}

src_prepare() {
	# .desktop entry: "Version" attribute is invalid (must be specification version, not app version number)
	# see: http://standards.freedesktop.org/desktop-entry-spec/latest/ar01s05.html
	/bin/sed -i -e 's/^Version=/X-Version=/' usr/share/applications/lightworks.desktop || die 'failed to fix lightworks.desktop'
}

src_install() {
	insinto /lib/udev/rules.d
	doins lib/udev/rules.d/20-lightworks.rules
	
	exeinto /usr/bin
	doexe usr/bin/lightworks
	
	insinto /usr/lib64/lightworks
	doins -r usr/lib/lightworks/*
	
	exeinto /usr/lib64/lightworks
	doexe usr/lib/lightworks/spawn
	doexe usr/lib/lightworks/ntcardvt
	
	insinto /usr/share/applications
	doins usr/share/applications/lightworks.desktop
	
	insinto /usr/share/doc/lightworks
	doins -r usr/share/doc/lightworks/*
	
	insinto /usr/share/fonts/truetype
	doins usr/share/fonts/truetype/lw2.ttf
	doins usr/share/fonts/truetype/lw3.ttf
	
	insinto /usr/share/lightworks
	doins -r usr/share/lightworks/*
}

pkg_postinst() {
	# update font cache because we installed font files
	font_pkg_postinst
	
	#               1         2         3         4         5         6         7         8
	#      12345678901234567890123456789012345678901234567890123456789012345678901234567890
	einfo ""
	einfo "Please ignore all QA notices printed above."
	einfo ""
	einfo "You will need to register an account at ${HOMEPAGE} in order to use Lightworks."
	einfo "Some features are restricted on free accounts but can be unlocked for a fee if"
	einfo "needed."
	einfo ""
	einfo "If you are running PulseAudio, you may want to use pasuspender around Lightworks"
	einfo "if you experience high audio latency."
	einfo ""
	ewarn "Please monitor memory usage and CPU load during your first sessions with"
	ewarn "Lightworks as ntcardvt *may* run wild and cause your system to fall into swap."
	ewarn "If you can spare a few moments of your time and want to help, please contact us"
	ewarn "at gentoo-overlay@megacoffee.net for trying to identify the cause of that"
	ewarn "behaviour (reports about everything running fine are welcome as well). :)"
}
