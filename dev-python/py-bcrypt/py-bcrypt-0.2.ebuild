# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="a Python wrapper to bcrypt"
HOMEPAGE="http://code.google.com/p/py-bcrypt/"

SRC_URI="http://py-bcrypt.googlecode.com/files/py-bcrypt-0.2.tar.gz"

DEPEND="dev-python/setuptools"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT_PYTHON_ABIS="3.*"
