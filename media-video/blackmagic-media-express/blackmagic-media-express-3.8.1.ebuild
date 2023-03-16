# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# TODOs:
#  - fix QA notice about installing symlinks in /usr/lib

EAPI=8

inherit xdg-utils

DESKTOP_VIDEO_SHORT_VERSION="12.4.1"
DESKTOP_VIDEO_VERSION="12.4.1a15"
MEDIA_EXPRESS_VERSION="3.8.1a4"

DESCRIPTION="Media Express - Blackmagic Design's tool for media capture, organization and playback"
HOMEPAGE="http://www.blackmagicdesign.com/"
HOMEPAGE_DOWNLOAD_NAME="Desktop Video ${DESKTOP_VIDEO_SHORT_VERSION}"

SRC_URI="Blackmagic_Desktop_Video_Linux_${DESKTOP_VIDEO_SHORT_VERSION}.tar.gz"
UNPACKED_DIR="mediaexpress-${MEDIA_EXPRESS_VERSION}-x86_64"

LICENSE="BlackmagicDesktopVideo"
SLOT="0"
KEYWORDS="~amd64"
#IUSE="autostart"
RESTRICT="fetch splitdebug strip"

# dependencies for binaries found by commands: (ldd lists transitive dependencies as well which isn't what we want)
# for file in /usr/lib/blackmagic/MediaExpress/*; do objdump -p $file | grep NEEDED; done 2>/dev/null | cut -b24- | sort | uniq | grep -vE 'lib(Qt|MXF|DNxHDCodec)'
# equery belongs $(for file in /usr/lib/blackmagic/MediaExpress/*; do objdump -p $file | grep NEEDED; done 2>/dev/null | cut -b24- | sort | uniq | grep -vE 'lib(Qt|MXF|DNxHDCodec)')
# ... and repeat for plugins/*/* as well; provided .so files may be subtracted

DEPEND=""
RDEPEND="${DEPEND}
	 >=media-libs/blackmagic-desktop-video-12.4.1

	 dev-libs/glib:2
	 media-libs/alsa-lib
	 media-libs/fontconfig
	 media-libs/freetype
	 media-libs/libglvnd
	 sys-apps/dbus
	 sys-devel/gcc
	 sys-libs/glibc
	 sys-libs/libcxx
	 sys-libs/libcxxabi
	 virtual/glu
	 x11-libs/libICE
	 x11-libs/libSM
	 x11-libs/libX11
	 x11-libs/libXext
	 x11-libs/libXrender
	 x11-libs/libxcb
	"

# supress QA warnings about stripping etc., i.e. stuff we cannot change since we install prebuilt binaries
QA_PREBUILT="opt/blackmagic-media-express/usr/lib/*"

pkg_nofetch() {
	#               1         2         3         4         5         6         7
	#      123456789012345678901234567890123456789012345678901234567890123456789012
	einfo "Media Express is bundled with Desktop Video downloads."
	einfo ""
	einfo "Please visit ${HOMEPAGE} and download \"${HOMEPAGE_DOWNLOAD_NAME}\""
	einfo "for your product from the support section and move it to your DISTDIR"
	einfo "(/var/cache/distfiles or /usr/portage/distfiles unless you changed it)."
	einfo ""
	einfo "  expected filename: ${SRC_URI}"
	einfo ""
	einfo "If your browser downloads a .tar file you will need to rename it to .tar.gz"
}

src_unpack() {
	unpack ${A}
	
	cd ${WORKDIR}
	tar xfz Blackmagic_Desktop_Video_Linux_${DESKTOP_VIDEO_SHORT_VERSION}/other/x86_64/mediaexpress-${MEDIA_EXPRESS_VERSION}-x86_64.tar.gz
	
	# symlink to what is supposed to have been prepared
	ln -s ${UNPACKED_DIR} ${P}
}

src_install() {
	# all pre-built binaries should go into /opt and be symlinked to usr/bin etc.
	finalinstalldir="/opt/blackmagic-media-express"
	installdir="${D}${finalinstalldir}"
	
	mkdir -p ${installdir}
	cp -a ${WORKDIR}/${UNPACKED_DIR}/* ${installdir}/
	
	# NOTE: Not linking usr/lib/systemd as I do not use that and thus cannot test it...
	symlinks=(
			'usr/bin/MediaExpress'
			'usr/lib/blackmagic/MediaExpress'
			'usr/share/applications/MediaExpress.desktop'
			'usr/share/icons/hicolor/32x32/apps/MediaExpress.png'
			'usr/share/icons/hicolor/48x48/apps/MediaExpress.png'
			'usr/share/icons/hicolor/256x256/apps/MediaExpress.png'
                 )
	
	for path in "${symlinks[@]}"; do
		dosym ${finalinstalldir}/${path} ${path}
	done
	
	# copy but do not compress documentation
	# reason for having it twice (in /opt and /usr):
	# - symlinking as "mediaexpress" causes a QA notice as we should use our package name
	# - symlinking with our package name causes some weird sandbox violation
	docompress -x /usr/share/doc
	dodoc -r ${finalinstalldir}/usr/share/doc/mediaexpress/*
	
	# dneuge: no clue on how to use this...
	## QA notice says we should generate a linker script if we don't place libraries in /usr/lib
	## see: https://devmanual.gentoo.org/eclass-reference/toolchain-funcs.eclass/index.html
	#gen_usr_ldscript usr/lib/libDeckLinkAPI.so usr/lib/libDeckLinkPreviewAPI.so

	# don't symlink man-pages, install a copy instead
	doman usr/share/man/man1/*.1
}

pkg_postinst() {
	#      12345678901234567890123456789012345678901234567890123456789012345678901234567890
	einfo "Please do *NOT* report any QA errors to Gentoo or Blackmagic!"
	einfo ""
	einfo "License can be found in: ${finalinstalldir}/usr/share/doc/mediaexpress/License.txt"

	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
