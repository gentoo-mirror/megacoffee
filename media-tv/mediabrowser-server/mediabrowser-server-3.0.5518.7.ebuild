# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils user

DESCRIPTION="MediaBrowser Server is a software that indexes a lot of different kinds of media and allows for them to be retrieved and played through the DLNA protocol on any device capable of processing them."
HOMEPAGE="http://mediabrowser.tv/"
KEYWORDS="-* ~arm ~amd64 ~x86"
SRC_URI="https://github.com/MediaBrowser/MediaBrowser/archive/${PV}.zip"
SLOT="0"
LICENSE="GPL-2"
IUSE=""
RESTRICT="mirror test"

RDEPEND=">=dev-lang/mono-3.2.7
	>=dev-dotnet/libgdiplus-2.10
	>=media-video/ffmpeg-2[vpx]
	>=media-libs/libmediainfo-0.7
	>=media-libs/libwebp-0.4.1[jpeg]"
DEPEND="app-arch/unzip ${RDEPEND}"

INSTALL_DIR="/opt/mediabrowser-server"
DATA_DIR="/usr/lib/mediabrowser-server"
STARTUP_LOG="/var/log/mediabrowser_start.log"
INIT_SCRIPT="${ROOT}/etc/init.d/mediabrowser-server"

# gentoo expects a specific subfolder in the working directory for the extracted source, so simply extracting won't work here
src_unpack() {
	unpack ${A}
	mv MediaBrowser-${PV} mediabrowser-server-${PV}
}

# we don't want to use the third party drivers, so we patch the config files to use system ones instead
# attention: do NOT remove the third party libraries before compiling as the build process might fail!
#src_prepare() {
#	epatch "${FILESDIR}/system_libraries_2.patch"
#}

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
	dodir ${INSTALL_DIR}
	cp -R ${S}/MediaBrowser.Server.Mono/bin/Release\ Mono/* ${D}${INSTALL_DIR}/ || die "install failed, possibly compile did not succeed earlier?"
	chown mediabrowser:mediabrowser -R ${D}${INSTALL_DIR}

	# as we use the system libraries, we delete the local ones now as we couldn't do it before
	rm -R ${D}${INSTALL_DIR}/libwebp
	rm -R ${D}${INSTALL_DIR}/MediaInfo

	einfo "prepare data directory"
	dodir ${DATA_DIR}
}

pkg_setup() {
	einfo "creating user for MediaBrowser"
	enewgroup mediabrowser
	enewuser mediabrowser -1 /bin/bash ${INSTALL_DIR} "mediabrowser" --system
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
	einfo "MediaBrowser-server was installed to ${INSTALL_DIR}, to start please use the init script provided."
	einfo "All data generated and used by MediaBrowser can be found at ${DATA_DIR} after the first start."
	einfo ""
	einfo "If you just updated from an earlier version make sure to restart the service!"
}
