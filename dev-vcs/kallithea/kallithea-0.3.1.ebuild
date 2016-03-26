# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

### NOTES ##########################################################################
#
# When updating this ebuild, comment out all workarounds and try without them first.
# Only re-enable them if they are still required.
#
# Also check that documentation URLs are still correct.
#
####################################################################################

EAPI="5"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit user

DESCRIPTION="a web-based frontend and middleware to Mercurial and Git repositories"
HOMEPAGE="https://kallithea-scm.org/"
SRC_URI="https://pypi.python.org/packages/source/K/Kallithea/Kallithea-${PV}.tar.bz2"

RDEPEND="dev-python/virtualenv"

DEPEND="${RDEPEND}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT_PYTHON_ABIS="3.*"

installDataPath="/var/lib/kallithea"
installBasePath="/opt/kallithea"
installConfigPath="/etc/kallithea"
virtualenvActivationPath="bin/activate"

urlDocumentationSetup="http://kallithea.readthedocs.org/en/${PV}/setup.html"
urlDocumentationRhodeCode="http://kallithea.readthedocs.org/en/${PV}/readme.html#converting-from-rhodecode"

pkg_setup() {
	# create user and group
	enewgroup kallithea
	enewuser kallithea -1 -1 "${installDataPath}" kallithea 
}

src_unpack() {
	unpack ${A}
	mv Kallithea-${PV} kallithea-${PV} || die "Unexpected directory structure, aborting..."
}

src_compile() {
	# not really compiling anything
	
	realWorkDir=$(pwd)
	
	# create new virtual environment
	virtualenv --no-site-packages dist/v
	
	# activate environment
	source "dist/v/${virtualenvActivationPath}"
	
	# WORKAROUND:
	# we need to make sure we have a current version of setuptools to install Kallithea's dependencies
	pip install 'setuptools>=17.1'

	# WORKAROUND:
	# _after_ installation on --config we need a certain version of paster to create the initial config file...
	pip install 'PasteScript==2.0.2'
	
	# WORKAROUND:
	# Kallithea's attempt to install Mercurial fails, so we do it first
	pip install 'mercurial>=2.9,<3.8'
	
	# perform automatic installation, includes dependencies
	echo
	echo "===> output by Kallithea's setup.py"
	python setup.py install
	retval=$?
	echo "<=== Kallithea's setup.py is done, resuming ebuild code"
	echo
	
	# quit now if failed
	if [ ${retval} -ne 0 ]; then
		echo "Bad return value ${retval} from setup.py install"
		exit 1
	fi
	
	# unzip all eggs
	echo 'Unzipping all eggs...'
	cd dist/v/lib/python2.7/site-packages/ || die "site-packages not found"
	for eggname in *.egg; do
		if [ -f "${eggname}" ]; then
			mv "${eggname}" tmp.extract.zip
			unzip -d "${eggname}" tmp.extract.zip
			rm tmp.extract.zip
		fi
	done
	
	# TODO: remove dummy config & directory
	
	# create config
	mkdir "${realWorkDir}/etc"
	cd "${realWorkDir}/etc"
	paster make-config Kallithea production.ini || die "unable to create configuration file"
	
	# rewrite config to refer to correct default paths
	sed -i -e "s/%(here)s\(\/\(tarballcache\|data\)\)/${installDataPath//\//\\/}\1/" production.ini
	sed -i -e "s/%(here)s\(\/kallithea.db\)/${installDataPath//\//\\/}\1/" production.ini
	
	# TODO: only log WARN by default?
	
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
	
	# create WSGI file
	cd "${realWorkDir}/etc"
	cp "${FILESDIR}/production.wsgi" .
	sed -e "s:###BASEDIR###:${installBasePath}:" -i production.wsgi
	sed -e "s:###DATADIR###:${installDataPath}:" -i production.wsgi
	sed -e "s:###CONFDIR###:${installConfigPath}:" -i production.wsgi
}

src_install() {
	# QA: no need to have anything world-writable...
	chmod o-w -R dist/v/lib/python2.7/site-packages/
	
	# just copy the virtualenv directory to /opt/kallithea
	dodir /opt
	cp -aR "${S}/dist/v" "${D}${installBasePath}"
	
	# install configuration files to /etc/kallithea
	diropts -m750 -oroot -gkallithea
	insopts -m640 -oroot -gkallithea
	insinto "${installConfigPath}"
	doins "${S}/etc/production.ini"
	insopts -m644 -oroot -gkallithea
	doins "${S}/etc/production.wsgi"
	
	# create data directory
	diropts -m2770 -okallithea -gkallithea
	keepdir "${installDataPath}"
}

pkg_postinst() {
	#               1         2         3         4         5         6         7         8
	#      12345678901234567890123456789012345678901234567890123456789012345678901234567890
	einfo "An example configuration file has already been created so you don't need to run"
	einfo "make-config again, see:"
	einfo "    ${installConfigPath}/production.ini"
	einfo ""
	einfo "You still need to follow Kallithea's other setup steps according to the"
	einfo "instructions at:"
	einfo "    ${urlDocumentationSetup}"
	einfo ""
	einfo "When doing so, please mind that Kallithea was installed into a Python virtual"
	einfo "environment that has to be \"activated\" before it can be used. To do so,"
	einfo "you will have to run a dedicated shell and initialize the environment by running"
	einfo ""
	einfo "    source ${installBasePath}/${virtualenvActivationPath}"
	einfo ""
	#einfo "We can wrap those commands for you if you run (no prior activation needed):"
	#einfo "    emerge --config =${CATEGORY}/${PF}"
	#einfo ""
	einfo "Kallithea also provides a way to migrate your database if you are coming from"
	einfo "RhodeCode 2.2 or below. Instructions can be found at:"
	einfo "${urlDocumentationRhodeCode}"
	einfo ""
	ewarn "Bear in mind that the whole purpose of a Python virtual environment is to"
	ewarn "isolate complex dependency installations from other instances installed on the"
	ewarn "same system so you will have to remember to re-emerge this ebuild when"
	ewarn "Kallithea's dependencies received bug and in particular security fixes (assuming"
	ewarn "it allows any more recent versions to be installed)."
}





#################################################################################################
### EVERYTHING BELOW WAS AN ATTEMPT TO ASSIST USERS ON SETUP BUT CALLING EDITORS NEVER WORKED ###
### SHOULD STAY DEACTIVATED FOR NOW                                                           ###
#################################################################################################


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
	echo
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
	
	echo "TERM is ${TERM}"
	
	while [[ ! "${choice}" =~ ^[0-3]$ ]]; do
		echo -n "Your choice? "
		choice=$(my_read_line)
	done
	
	IFS="${oldIFS}"
	
	return ${choice}
}

pkg_config() {
	echo "Erm... You are not supposed to call --config as it has not been completed."
	echo "Sorry, you will have to follow the docs yourself for now, see:"
	echo "  ${urlDocumentationSetup}"
	echo
	echo
	exit 1
	
	#              1         2         3         4         5         6         7         8
	#     12345678901234567890123456789012345678901234567890123456789012345678901234567890
	
	echo "Kallithea setup requires following multiple steps, some of which need to be run"
	echo "in the correct virtual Python environment. This script helps you running those"
	echo "commands by wrapping the commands to be run inside the correct virtualenv."
	echo "You may still want to read the setup instructions while running this script:"
	echo
	echo "  ${urlDocumentationSetup}"
	
	# activate virtualenv
	cd ${installBasePath} || die "installation is gone? (${installBasePath})"
	source "${virtualenvActivationPath}" || die "failed to activate virtualenv (${installBasePath}/${virtualenvActivationPath})"
	
	configFileName='production.ini'
	
	while true; do
		config_menu
		choice=$?
		echo
		
		case "${choice}" in
			0) 	break
				;;
			
			1)	mkdir -p "${installBasePath}/etc"
				cd "${installBasePath}/etc"
				
				shouldCreate="y"
				if [ -e "${configFileName}" ]; then
					shouldCreate=""
					while true; do
						echo "${configFileName} already exists, overwrite?"
					        while [[ ! "${shouldCreate}" =~ ^[yn]$ ]]; do
					                echo -n "Enter y to overwrite, n to abort: "
					                shouldCreate=$(my_read_line)
					        done
					done
				fi

				if [ "${shouldCreate}" == 'y' ]; then
					echo 'Creating configuration file...'
					paster make-config Kallithea ${configFileName}
				else
					echo 'Aborted, configuration file has not been overwritten.'
				fi
				;;
			
			2)	iniPath="${installBasePath}/etc/${configFileName}"
				
				if [ ! -e "${iniPath}" ]; then
					echo "config not found at ${iniPath}; did you follow step 1?"
					continue
				fi
				
				# terminal and shell need a reset or editor will be screwed up
				source /etc/profile
				reset
				stty sane
				
				# open editor
				if [[ "${EDITOR}" != "" ]] && [ -e "${EDITOR}" ]; then
					TERM="xterm" ${EDITOR} "${iniPath}"
				else
					TERM="xterm" nano -w "${iniPath}"
				fi

				# we better reset again...
				source /etc/profile
				reset
				stty sane
				;;
			
			*)	echo "invalid choice ${choice}"
				;;
		esac
	done
}
