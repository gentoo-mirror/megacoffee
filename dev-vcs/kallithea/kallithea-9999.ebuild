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

installBasePath="/opt/kallithea"
virtualenvActivationPath="bin/activate"

src_compile() {
	# not really compiling anything
	
	realWorkDir=$(pwd)
	
	# create new virtual environment
	virtualenv --no-site-packages dist/v
	
	# activate environment
	source "dist/v/${virtualenvActivationPath}"
	
	# WORKAROUND:
	# pylonshq.com is dead, remove from config
	sed -e 's/\(find_links\s*=\s*http:\/\/www.pylonshq.com\/\)/;\1/' -i setup.cfg
	
	# perform automatic installation, includes dependencies
	echo
	echo "===> output by Kallithea's setup.py"
	python setup.py install || die "Automatic installation failed, please check above output."
	echo "<=== Kallithea's setup.py is done, resuming ebuild code"
	echo
	
	# rewrite virtualenv directory to later installation directory
	oldIFS="${IFS}"
	IFS="
	"
	echo "Searching files that need to have paths replaced when leaving portage sandbox..."
	dirtyFiles=$(grep -Ri "${realWorkDir}/dist/v" ${realWorkDir}/dist/v | grep -vE '^Binary' | cut -d':' -f1 | sort | uniq)
	for dirtyFile in ${dirtyFiles}; do
		echo "    patching ${dirtyFile}"
		sed -e "s#${realWorkDir}/dist/v#${installBasePath}#" -i "${dirtyFile}"
	done
	IFS="${oldIFS}"
}

src_install() {
	# QA: no need to have anything world-writable...
	chmod o-w -R dist/v/lib/python2.7/site-packages/setuptools-0.9.8-py2.7.egg-info
	
	# just copy the virtualenv directory to /opt/kallithea
	dodir /opt
	cp -aR "${S}/dist/v" "${D}${installBasePath}"
}

pkg_postinst() {
	#               1         2         3         4         5         6         7         8
	#      12345678901234567890123456789012345678901234567890123456789012345678901234567890
	einfo "You need to setup Kallithea according to the instructions at:"
	einfo "    https://pythonhosted.org/Kallithea/setup.html"
	einfo ""
	einfo "When doing so, please mind that Kallithea was installed into a Python virtual"
	einfo "environment that has to be \"activated\" before it can be used. To do so,"
	einfo "you will have to run a dedicated shell and initialize the environment by running"
	einfo ""
	einfo "    source ${D}/dist/v/bin/activate"
	einfo ""
	einfo "We can wrap those commands for you if you run:"
	einfo "    emerge --config =${CATEGORY}/${PF}"
	einfo ""
	einfo "Kallithea also provides a way to migrate your database if you"
	einfo "are coming from RhodeCode. Instructions can be found at:"
	einfo "https://pythonhosted.org/Kallithea/index.html#converting-from-rhodecode"
}

my_read_line() {
	# BASH function 'read' cannot write input back to variable in correct environment
	# when run by emerge so we have to do *this* instead... great... :/
	# (at least this works...)

	python -c 'import sys; print(sys.stdin.readline().strip())'
}

config_menu() {
	choice=""
	
	oldIFS="${IFS}"
	IFS="
	"
	
	#              1         2         3         4         5         6         7         8
	#     12345678901234567890123456789012345678901234567890123456789012345678901234567890
	echo "==============================================================================="
	echo
	echo "Your options:"
	echo
	echo "  1) create production config from template (paster make-config ...)"
	echo "  2) edit production config"
	echo "  3) initialize Kallithea (paster setup-db)"
	echo "     This will also ask for repository location and create an admin account."
	echo "  0) quit"
	echo "     Kallithea should be able to run now, check documentation for more options"
	echo "     such as setting up a task queue or full text search if you need it."
	echo
	
	while [[ ! "${choice}" =~ ^[0-3]$ ]]; do
		echo -n "Your choice? "
		choice=$(my_read_line)
	done
	
	IFS="${oldIFS}"
	
	return ${choice}
}

pkg_config() {
	#              1         2         3         4         5         6         7         8
	#     12345678901234567890123456789012345678901234567890123456789012345678901234567890
	
	echo "Kallithea setup requires following multiple steps, some of which need to be run"
	echo "in the correct virtual Python environment. This script helps you running those"
	echo "commands by wrapping the commands to be run inside the correct virtualenv."
	echo "You may still want to read the setup instructions while running this script:"
	echo
	echo "  https://pythonhosted.org/Kallithea/setup.html"
	
	# activate virtualenv
	cd ${installBasePath} || die "installation is gone? (${installBasePath})"
	source "${virtualenvActivationPath}" || die "failed to activate virtualenv (${installBasePath}/${virtualenvActivationPath})"
	
	while true; do
		config_menu
		choice=$?
		echo
		
		case "${choice}" in
			0) 	break
				;;
			
			1)	mkdir -p "${installBasePath}/etc"
				cd "${installBasePath}/etc"
				paster make-config Kallithea production.ini
				;;
			
			2)	iniPath="${installBasePath}/etc/production.ini"
				
				if [ ! -e "${iniPath}" ]; then
					echo "config not found at ${iniPath}; did you follow step 1?"
					continue
				fi
				
				# terminal and shell need a reset or editor will be screwed up
				source /etc/profile
				reset
				
				# open editor
				if [[ "${EDITOR}" != "" ]] && [ -e "${EDITOR}" ]; then
					${EDITOR} "${iniPath}"
				else
					nano -w "${iniPath}"
				fi

				# we better reset again...
				source /etc/profile
				reset
				;;
			
			*)	echo "invalid choice ${choice}"
				;;
		esac
	done
}
