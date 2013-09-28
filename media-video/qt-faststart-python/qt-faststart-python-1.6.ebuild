# ebuild from gentoo-overlay.megacoffee.net, author: dneuge
# Distributed under the terms of the GNU General Public License v2
# feel free to use, modify and upload somewhere else without naming

EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils
inherit git-2

DESCRIPTION="Quicktime atom positioning in Python for fast streaming"
HOMEPAGE="https://github.com/danielgtaylor/qtfaststart"

EGIT_REPO_URI="https://github.com/danielgtaylor/qtfaststart.git"
EGIT_COMMIT="eb8594dd206d7ca175420aea397bba1cb8e5300f"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_prepare() {
	distutils_src_prepare
}

src_install() {
	distutils_src_install
}
