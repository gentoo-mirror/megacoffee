# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python3_{8..11} )

inherit git-r3
inherit distutils-r1
inherit python-r1

DESCRIPTION="GUI for PNG and JPEG optimization via optipng, pngcrush, advpng and jpegoptim"
HOMEPAGE="http://trimage.org/"

#SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
EGIT_REPO_URI="https://github.com/Kilian/Trimage.git"
EGIT_COMMIT="8376c4a238ff725c29b435bdd5627e8e22a8d07a"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-python/pyqt5[${PYTHON_USEDEP}]
	
	>=media-gfx/optipng-0.7
	<media-gfx/optipng-0.8
	
	>=media-gfx/pngcrush-1
	<media-gfx/pngcrush-2
	
	>=app-arch/advancecomp-2
	<app-arch/advancecomp-3
	
	>=media-gfx/jpegoptim-1.4
	<media-gfx/jpegoptim-1.6
"

PATCHES="${FILESDIR}/${P}_*.patch"
