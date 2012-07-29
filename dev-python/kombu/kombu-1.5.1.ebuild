# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="AMQP Messaging Framework for Python"
HOMEPAGE="http://kombu.readthedocs.org/ https://github.com/ask/kombu"

SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
# dependencies are likely to be incomplete or not restrictive enough
# this library ebuild has been added for rhodecode which may have restricted them in    
# another way, you are encouraged to submit corrections to gentoo-overlay@megacoffee.net
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
DEPEND="dev-python/setuptools"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT_PYTHON_ABIS="3.*"

# NOTE: the official ebuilds for later versions of Celery contain some more steps

