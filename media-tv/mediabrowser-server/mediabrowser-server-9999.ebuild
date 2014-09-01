# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils user

DESCRIPTION="MediaBrowser Server is a software that indexes a lot of different kinds of media and allows for them to be retrieved and played through the DLNA protocol on any device capable of processing them."
HOMEPAGE="http://mediabrowser.tv/"
KEYWORDS="-* ~9999"
SRC_URI="https://github.com/MediaBrowser/MediaBrowser/archive/master.zip"
#SRC_URI="https://github.com/gsnerf/MediaBrowser/archive/master.zip"
SLOT="0"
LICENSE="GPL-2"
IUSE=""
RESTRICT="mirror test"

RDEPEND=">=dev-lang/mono-3.2.0 >=dev-dotnet/libgdiplus-2.10"
DEPEND="app-arch/unzip ${RDEPEND}"

INSTALL_DIR="/opt/mediabrowser-server"
DATA_DIR="/usr/lib/mediabrowser-server"
STARTUP_LOG="/var/log/mediabrowser_start.log"

INIT_SCRIPT="${ROOT}/etc/init.d/mediabrowser-server"

# gentoo expects a specific subfolder in the working directory for the extracted source, so simply extracting won't work here
src_unpack() {
	unpack ${A}
	mv MediaBrowser-master mediabrowser-server-9999
}

src_compile() {
	einfo "updating root certificates for mono certificate store"
	mozroots --import --sync
	einfo "now actually compile"
	xbuild /p:Configuration="Release Mono" /p:Platform="Any CPU" MediaBrowser.Mono.sln || die "building failed"
}

src_install() {
	einfo "preparing startup scripts"
	newinitd "${FILESDIR}"/initd_1  ${PN}
	dodir /var/log/
	touch ${D}${STARTUP_LOG}
	chown mediabrowser:mediabrowser ${D}${STARTUP_LOG}

	einfo "installing compiled files"
	diropts -omediabrowser -gmediabrowser
	#insopts -omediabrowser -gmediabrowser
	dodir ${INSTALL_DIR}
	#insinto ${INSTALL_DIR}
	#doins -r "${S}/MediaBrowser.Server.Mono/bin/Release Mono/*"
	cp -R ${S}/MediaBrowser.Server.Mono/bin/Release\ Mono/* ${D}${INSTALL_DIR}/ || die "install failed, possibly compile did not succeed earlier?"
	chown mediabrowser:mediabrowser -R ${D}${INSTALL_DIR}

	einfo "prepare data directory"
	dodir ${DATA_DIR}
}

pkg_setup() {
	einfo "creating user for MediaBrowser"
	enewgroup mediabrowser
	enewuser mediabrowser -1 /bin/bash /opt/mediabrowser "mediabrowser" --system
}

#pkg_preinst() {
	#cd ${D}
	#einfo "preparing compiled package for install"
	#mkdir -p opt/mediabrowser-server
	#cp -R  ${WORKDIR}/${P}/MediaBrowser.Server.Mono/bin/Release\ Mono/* opt/mediabrowser-server/ || die
	#cp ${FILESDIR}/start.sh opt/mediabrowser-server/start.sh
	#chown mediabrowser:mediabrowser -R opt/mediabrowser-server
	#chmod 755 opt/mediabrowser-server/start.sh

	#einfo "adding init script"
	#mkdir -p etc/init.d
	#cp "${FILESDIR}"/initd_1 etc/init.d/mediabrowser-server
	#chmod 755 etc/init.d/mediabrowser-server
	#mkdir -p var/log
	#touch var/log/mediabrowser_start.log
	#chown mediabrowser:mediabrowser var/log/mediabrowser_start.log

	#einfo "preparing data directory"
	#mkdir -p usr/lib/mediabrowser-server
	#chown mediabrowser:mediabrowser usr/lib/mediabrowser-server

	#einfo "Stopping running instances of MediaBrowser Server for actual install"
	#if [ -e "${INIT_SCRIPT}" ]; then
	#	${INIT_SCRIPT} stop
	#fi
#}

pkg_prerm() {
	einfo "Stopping running instances of Media Server"
	if [ -e "${INIT_SCRIPT}" ]; then
		${INIT_SCRIPT} stop
	fi
}

pkg_postinst() {
	einfo "MediaBrowser-server was installed to /opt/mediabrowser, to start please use the init script provided."
	einfo "All data generated and used by MediaBrowser can be found at /var/opt/mediabrowser after the first start."
	einfo ""
	einfo "If you just updated from an earlier version make sure to restart the service!"
}
