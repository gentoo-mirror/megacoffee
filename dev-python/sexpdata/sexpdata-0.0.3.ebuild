# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
PYTHON_COMPAT=( python{ 2_6, 2_7, 3_2 } )

inherit distutils

DESCRIPTION="S-expression parser/serializer for Python"
HOMEPAGE="http://sexpdata.readthedocs.org/en/latest/ https://pypi.python.org/pypi/sexpdata"

SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
