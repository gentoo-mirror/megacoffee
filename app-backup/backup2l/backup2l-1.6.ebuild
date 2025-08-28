# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# note by megacoffee.net overlay repository:

# source of ebuild is bug 167249 on Gentoo Bugzilla
# https://bugs.gentoo.org/show_bug.cgi?id=167249
# original author: bugzilla user "Will"
# posted on: 2007-02-16 19:01:20 UTC

# minimal modifications have been made:

# < KEYWORDS="~x86"
# ---
# > KEYWORDS="~x86 ~amd64"

# < 	exeinto /usr/local
# ---
# > 	#exeinto /usr/local
# > 	exeinto /usr/bin

# added EAPI, description, dependency to bash, changed homepage and download to GitHub without mirroring

EAPI="8"

DESCRIPTION="light-weight versatile backup tool written in Bash"
HOMEPAGE="https://github.com/gkiefer/backup2l"
SRC_URI="https://github.com/gkiefer/backup2l/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="mirror"

DEPEND=""
RDEPEND="app-shells/bash"

src_install() {
	
	PREFIX=/usr
	PREFIX_BIN=/usr/bin
	PREFIX_CONF=/etc

	dodir $PREFIX_CONF/cron.daily
	CRON_FILE=$PREFIX_CONF/cron.daily
	
	PROG_FILES="$PREFIX_BIN/backup2l $PREFIX/man/man8/backup2l.8.gz"
	CONF_FILES="$PREFIX_CONF/backup2l.conf $CRON_FILE"

	elog "Installing program"
	#exeinto /usr/local
	exeinto /usr/bin
	doexe backup2l #$PREFIX_BIN
	
	elog "Installing manual"
	doman backup2l.8 
	
	elog "Installing sample configuration file"
	insinto $PREFIX_CONF
	newins first-time.conf backup2l.conf

	elog "Installing sample cron task"
	insinto $CRON_FILE
	doins zz-backup2l 
	elog "Configuration files installed."
}

pkg_postinst() {
	ewarn "Make sure you edit /etc/backupl.conf prior doing anything else..."
	ewarn "You will have to define what to backup and where at least."
	ewarn "Read the entire configuration file, one line must be uncommented."
}
