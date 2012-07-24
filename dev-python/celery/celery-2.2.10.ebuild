# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils
inherit git-2

DESCRIPTION="a task queue implementation"
HOMEPAGE="http://www.celeryproject.org/"

# tarball exists (kind of...) but we get a messy filename from it
# so instead we pull the github repository (not ideal but works)
#SRC_URI="https://github.com/celery/celery/tarball/v2.2.10"

EGIT_REPO_URI="https://github.com/celery/celery.git"
EGIT_COMMIT="c4f068483bb2600c36d31da352f43f6dc3ea3dc7"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT_PYTHON_ABIS="3.*"
