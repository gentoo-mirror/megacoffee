# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils
inherit git-2

DESCRIPTION="an AMQP interface for python"
HOMEPAGE="http://kombu.readthedocs.org/"

# tarball exists (kind of...) but we get a messy filename from it
# so instead we pull the github repository (not ideal but works)
#SRC_URI="https://github.com/celery/kombu/tarball/v1.5.1"

EGIT_REPO_URI="https://github.com/celery/kombu.git"
EGIT_COMMIT="63284ce01fef6e644e0f4679dbd0376975e5d17f"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT_PYTHON_ABIS="3.*"
