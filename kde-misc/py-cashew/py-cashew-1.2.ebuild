# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Plasmoid for KDE 4.6+ to remove the so-called Cashew (desktop configuration icon) - replacement for abandoned plasmoid \"I HATE the cashew\"."
HOMEPAGE="http://kde-look.org/content/show.php/Py-Cashew?content=147892"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

inherit git-2
#inherit kde4-base

EGIT_REPO_URI="https://github.com/benoit-monin/Py-Cashew.git"
EGIT_COMMIT="226e0352785f14323f787b65a3673abf4b8ce4f2"

#src_unpack() {
#	cd ${WORKDIR}
#	git clone ${EGIT_REPO_URI} py-cashew-1.2
#	cd py-cashew-1.2
#	git checkout -b TMP-ebuild ${EGIT_COMMIT}
#	cd ..
#}

#pkg_postinst() {
#	plasmapkg --packageroot /usr/share/apps/plasma/plasmoids -i py-cashew-1.2.plasmoid
#}

src_install() {
	# we try to mimic plasmapkg which does not work in sandbox
	
	insinto /usr/share/apps/plasma/plasmoids/py-cashew
	doins metadata.desktop
	
	# no idea where icons should go, nothing seems to fit PNGs...
	#insinto /usr/share/apps/desktoptheme/default/icons/
	#doins py-cashew.png

	insinto /usr/share/apps/plasma/plasmoids/py-cashew/contents/code
	doins contents/code/main.py
	
	cp -a metadata.desktop plasma-applet-py-cashew.desktop
	insinto /usr/share/kde4/services
	doins plasma-applet-py-cashew.desktop
}
