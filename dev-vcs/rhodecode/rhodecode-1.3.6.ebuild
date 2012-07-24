# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils
#inherit mercurial

DESCRIPTION="a web-based frontend and middleware to Mercurial repositories"
HOMEPAGE="http://rhodecode.org/"

#SRC_URI="https://rhodecode.org/rhodecode/archive/edfff9f37916389144d3a3644d0a7d7adfd79b11.zip?subrepos=true"
SRC_URI="https://rhodecode.org/rhodecode/archive/edfff9f37916389144d3a3644d0a7d7adfd79b11.zip"

# removed from DEPEND for errors on emerge
#	>=dev-python/python-dateutil-1.5
#	!>=dev-python/python-dateutil-2.0
#	>=dev-python/kombu-1.1.2
#	!>=dev-python/kombu-2.0.0


DEPEND=">=dev-vcs/mercurial-2.2.1
        !>=dev-vcs/mercurial-2.3
        dev-python/pastescript
	
	=dev-python/pylons-1.0
	=dev-python/beaker-1.6.3
	=dev-python/webhelpers-1.3
	=dev-python/formencode-1.2.4
	=dev-python/sqlalchemy-0.7.6
	=dev-python/mako-0.7.0
	>=dev-python/pygments-1.4
	>=dev-python/whoosh-2.4.0
	!>=dev-python/whoosh-2.5
	dev-python/Babel
	=dev-python/python-dateutil-1.5
	>=dev-python/dulwich-0.8.5
	!>=dev-python/dulwich-0.9.0
	=dev-python/webob-1.0.8
	=dev-python/markdown-2.1.1
	=dev-python/docutils-0.8.1
	=dev-python/simplejson-2.5.2
	
	>=dev-python/pyparsing-1.5.0
	!>=dev-python/pyparsing-2.0.0
	
	dev-python/py-bcrypt
	=dev-python/celery-2.2.10
	!>=dev-python/celery-3
	=dev-python/kombu-1.5.1
	>=dev-python/anyjson-0.3.1
	>=dev-python/amqplib-1.0
"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT_PYTHON_ABIS="3.*"

ACTUALDIR="rhodecode-edfff9f37916"

distutils_src_compile_pre_hook() {
	cd ${ACTUALDIR}
}

distutils_src_install_pre_hook() {
	cd ${ACTUALDIR}
}

pkg_postinst() {
	einfo "You need to setup RhodeCode according to the instructions at:"
	einfo "    http://packages.python.org/RhodeCode/setup.html"
}
