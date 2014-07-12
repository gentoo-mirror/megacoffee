# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit mercurial

DESCRIPTION="a web-based frontend and middleware to Mercurial and Git repositories"
HOMEPAGE="https://kallithea-scm.org/"

#EHG_REPO_URI="https://kallithea-scm.org/repos/kallithea"
EHG_REPO_URI="https://bitbucket.org/conservancy/kallithea"

RDEPEND="dev-python/virtualenv"

DEPEND="${RDEPEND}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT_PYTHON_ABIS="3.*"

src_compile() {
	# not really compiling anything
	
	# create new virtual environment
	virtualenv --no-site-packages dist/v
	
	# activate environment
	source dist/v/bin/activate
	
	# WORKAROUND:
	# pylonshq.com is dead, remove from config
	sed -e 's/\(find_links\s*=\s*http:\/\/www.pylonshq.com\/\)/;\1/' -i setup.cfg
	
	# perform automatic installation, includes dependencies
	python setup.py install || die "Automatic installation failed, please check above output."
	
	# rewrite virtualenv directory to later installation directory
	sed -e 's/^\(VIRTUAL_ENV\s*=\s*\).*/\1"\/opt\/kallithea\/"/' -i dist/v/bin/activate
}

src_install() {
	# QA: no need to have anything world-writable...
	chmod o-w -R dist/v/lib/python2.7/site-packages/setuptools-0.9.8-py2.7.egg-info
	
	# just copy the virtualenv directory to /opt/kallithea
	dodir /opt
	cp -aR "${S}/dist/v" "${D}/opt/kallithea"
}

pkg_postinst() {
	einfo "You need to setup Kallithea according to the instructions at:"
	einfo "    https://pythonhosted.org/Kallithea/setup.html"
	einfo ""
	einfo "Kallithea also provides a way to migrate your database if you"
	einfo "are coming from RhodeCode. Instructions can be found at:"
	einfo "https://pythonhosted.org/Kallithea/index.html#converting-from-rhodecode"
}
