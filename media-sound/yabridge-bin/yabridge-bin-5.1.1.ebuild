# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A bridge to use Windows VST and CLAP plugins on Linux via wine; binary release."
HOMEPAGE="https://github.com/robbert-vdh/yabridge"

SRC_URI="https://github.com/robbert-vdh/yabridge/releases/download/${PV}/yabridge-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}
	app-crypt/libmd
	dev-libs/libbsd
	sys-devel/gcc
	sys-libs/glibc
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXdmcp
	virtual/wine
"

S="${WORKDIR}"

QA_PREBUILT="/usr/*"
QA_TEXTRELS="usr/bin/yabridge-host-32.exe.so"

src_compile() { :; }

src_install() {
	# to avoid issues with linking etc. we install to default locations; see Arch Linux repository for reference:
	# https://archlinux.org/packages/multilib/x86_64/yabridge/
	# https://archlinux.org/packages/multilib/x86_64/yabridgectl/

	exeinto /usr/bin
	doexe yabridge/yabridgectl
	doexe yabridge/*.exe
	doexe yabridge/*.exe.so

	dolib.so yabridge/*-clap.so
	dolib.so yabridge/*-vst2.so
	dolib.so yabridge/*-vst3.so

	dodoc yabridge/*.md
}

pkg_postinst() {
        #      12345678901234567890123456789012345678901234567890123456789012345678901234567890
	einfo "wine 9.22 and later have known compatibility issues, such as the mouse cursor"
	einfo "being offset. You probably want to stick with wine 9.21 or below until a fix is"
	einfo "available."
	einfo ""
        einfo "See: https://github.com/robbert-vdh/yabridge/issues/382"
}
