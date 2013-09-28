# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Plasmoid for KDE 4.6+ to remove the so-called Cashew (desktop configuration icon) - replacement for abandoned plasmoid \"I HATE the cashew\"."
HOMEPAGE="http://kde-look.org/content/show.php/Py-Cashew?content=147892"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

inherit git-2

EGIT_REPO_URI="https://github.com/benoit-monin/Py-Cashew.git"
EGIT_COMMIT="226e0352785f14323f787b65a3673abf4b8ce4f2"

#S=${WORKDIR}

#src_unpack() {
#	unpack ${A}
#}

#src_compile() {
#	m
#	cd build
#	cmake -DCMAKE_INSTALL_PREFIX=/usr .. || die "CMake failed!"
#	emake || die "Make failed!"
#}

src_install() {
	#plasmapkg --global --packageroot ${WORKDIR}/usr/share/apps/plasma/plasmoids -i py-cashew-1.1.plasmoid
	plasmapkg --packageroot ${WORKDIR}/usr/share/apps/plasma/plasmoids -i py-cashew-1.1.plasmoid
}
