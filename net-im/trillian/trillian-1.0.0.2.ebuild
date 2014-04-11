# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="2"

URI_PRE="http://www.trillian.im/get/linux/beta/apt/dists/stable/main/binary-"
SRC_URI="x86? ( ${URI_PRE}i386/trillian_${PV}_i386.deb )
	amd64? ( ${URI_PRE}amd64/trillian_${PV}_amd64.deb )"

DESCRIPTION="Trillian is a multi-platform multi-protocol chat client."
HOMEPAGE="http://www.trillian.im"
KEYWORDS="-* ~x86 ~amd64"
SLOT="0"
LICENSE="Closed Source"
IUSE=""
RESTRICT="mirror"

RDEPEND=""
DEPEND=">=sys-libs/glibc-2.13.0
	>=dev-libs/glib-2.30.0
	>=x11-libs/cairo-1.12.0
	>=dev-cpp/cairomm-1.10.0
	>=x11-libs/gdk-pixbuf-2.26.0
	>=x11-libs/pango-1.30.0
	>=dev-cpp/pangomm-2.28.0
	>=dev-cpp/gtkmm-3.4.0
	>=net-libs/webkit-gtk-1.8.0
	>=dev-libs/libzip-0.10.0
	>=x11-libs/libnotify-0.7.5
	>=sys-libs/zlib-1.2.0
	>=media-sound/pulseaudio-1
	>=dev-libs/openssl-1.0.0
	x11-themes/gtk-engines-unico
	x11-themes/gtk-engines-murrine
	gnome-base/librsvg"

pkg_preinst() {
	cd ${WORKDIR}
	mkdir data
	tar -xzf data.tar.gz -C data
	cp -R data/* ${D}
}
