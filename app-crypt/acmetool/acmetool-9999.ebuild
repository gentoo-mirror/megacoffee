# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$
EAPI=7

GOLANG_PKG_IMPORTPATH="github.com/hlandau"
GOLANG_PKG_BUILDPATH="/cmd/acmetool"
GOLANG_PKG_ARCHIVEPREFIX="v"
GOLANG_PKG_NAME="acmetool"
#GOLANG_PKG_IS_MULTIPLE="1"
# Without this, dropping privs is non-functional, which (generally) breaks
# redirector
#GOLANG_PKG_USE_CGO=1

# How to update dependency list:
# 1. Checkout the wanted tag.
# 2. Find all dependencies via:
#    for file in $(find . -iname \*.go); do grep -Poz '(?s)import\s*\((.*?)\)' "$file" | tr '\0' '\n' | grep -Pv '^\s*(import\s*\(|\))\s*$'; done | sed -e 's/^\s*//' | sort | uniq
# 3. For all external dependencies visit the repos and check what version was current at time of acmetool tagging.
#    ... yes, this will take a while
# 4. Try to compile and go through all missing dependencies in the same way but base dependencies on the date of each parent dependency this time
#    ... yes, this may take even longer

DESCRIPTION="command line tool for automatically acquiring certificates from ACME servers"
HOMEPAGE="https://github.com/hlandau/acmetool"
if [[ "${PV}" = 9999 ]]; then
	inherit x-mgcf-golang-live
	KEYWORDS=""
else
	GOLANG_PKG_DEPENDENCIES=(
		"github.com/alecthomas/kingpin:947dcec5ba9c011838740e680966fd7087a71d0d -> gopkg.in/alecthomas/kingpin.v2" # v2.2.6 (2017-12-17)
		"github.com/alecthomas/template:a0175ee3bccc567396460bf5acd36800cb10c49c" # 2016-04-05, wanted by alecthomas/kingpin.v2
		"github.com/alecthomas/units:2efee857e7cfd4f3d0138cc3cbb1b4966962b93a" # 2015-10-22, wanted by alecthomas/kingpin.v2
		"github.com/cheggaaa/pb:5784bcc95a1741c2ca2b46b19f1f3d398557300c -> gopkg.in/cheggaaa/pb.v1" # v1.0.29 (2020-08-06)
		"github.com/coreos/go-systemd:a9a7ef127534245b9e83cfd9d5d0b09164af7ae9" # 2022-02-03, wanted by hlandau/dexlogconfig
		"github.com/gofrs/uuid:9363593625d72b57a14e20172547979b02b4aab2" # 2023-01-07
		"github.com/golang/crypto:642fcc37f5043eadb2509c84b2769e729e7d27ef -> golang.org/x" # v0.1.0 (2022-10-19); did not exist back when wanted by hlandau/acmeapi and square/go-jose.v2 ?!
		"github.com/golang/net:8e2b117aee74f6b86c207a808b0255de45c0a18a -> golang.org/x" # v0.7.0 (2023-02-14); at time of acmetool-0.2.2 v0.5.0 was active but it has known DoS issues
		"github.com/golang/sys:95e765b1cc43ac521bd4fd501e00774e34401449 -> golang.org/x" # v0.1.0 (2022-10-13); did not exist back when wanted by mattn/go-isatty ?!
		"github.com/golang/text:71a9c9afc4cd710b9412f7f99f0d8e35b10e488a -> golang.org/x" # v0.7.0 (2023-01-31), missing deps wanted by golang/net
		"github.com/go-yaml/yaml:7649d4548cb53a614db133b2a8ac1f31859dda8c -> gopkg.in/yaml.v2" # v2.4.0
		"github.com/hlandau/acmeapi:2f4c7d86d6266dcd2702933b44c8a5822f163134 -> gopkg.in/hlandau/acmeapi.v2" # v2.0.2 (2021-03-23)
		"github.com/hlandau/buildinfo:337a29b5499734e584d4630ce535af64c5fe7813" # 2016-11-12, wanted by hlandau/dexlogconfig
		"github.com/hlandau/configurable:41496864a1fe3e0fef2973f22372b755d2897402 -> gopkg.in/hlandau/configurable.v1" # v1.0.1 (2015-10-29), wanted by hlandau/easyconfig
		"github.com/hlandau/dexlogconfig:86a3fc314fe7a8d9d58005220de8e2a85dd5744f" # 2022-03-19
		"github.com/hlandau/easyconfig:30db2856f1fc2e9494aae5f96b57ad1a22029a03 -> gopkg.in/hlandau/easyconfig.v1" # v1.0.18 (2021-12-12)
		"github.com/hlandau/goutils:0cdb66aea5b843822af6fdffc21286b8fe8379c4" # 2016-07-22
		"github.com/hlandau/service:0e0d7e650dbdeaa82b606a6afc0b5f38a9e77b37 -> gopkg.in/hlandau/service.v2" # v2.0.17
		"github.com/hlandau/svcutils:6e7e875ab1a2f881e8bc757c1b2c1a779bcd57ee -> gopkg.in/hlandau/svcutils.v1" # v1.0.11
		"github.com/hlandau/xlog:5c67351975541184f98d42d2163f76bbd7330374" # 2021-03-23
		"github.com/hlandauf/dbus:b24e1c7d19a5fc589597f8abbf32a2b3688a4eb8 -> gopkg.in/hlandauf/dbus.v5" # v5.990.1 (2021-03-17), wanted by hlandauf/go-systemd
		"github.com/hlandauf/go-systemd:d4cbd5bfbd436076dfb05aa42689bcff67950a47" # 2021-03-17
		"github.com/jmhodges/clock:8a401d017099427a3a22abf2b14a49d9a069f433" # 2022-06-05
		"github.com/mattn/go-isatty:3751eb45e68b73541370d508d59323eaa44c0de2" # 2021-01-18, wanted by hlandau/xlog
		"github.com/mattn/go-runewidth:f1f639b53e80fe40abd644a702ed196880b0b345" # 2020-07-12, wanted by cheggaaa/pb
		"github.com/mitchellh/go-wordwrap:ecf0936a077a4bd73a1cc2ac5c370f2b55618d62" # 2020-09-25
		"github.com/ogier/pflag:73e519546fc0bce0c395610afcf6aa4e5aec88eb" # 2020-10-25, wanted by hlandau/easyconfig
		"github.com/peterhellberg/link:7d8125c3085c14bd320d898c73b78ef2c5320f31" # 2019-11-13, wanted by hlandau/acmeapi
		"github.com/rivo/uniseg:f8f8f751c732fdcd5e158c13c28f8863ad80e9a5" # 2019-07-06, wanted by mattn/go-runewidth
		"github.com/square/go-jose:56062818b5e15ee405eb8363f9498c7113e98337 -> gopkg.in/square/go-jose.v1" # v1.1.2
		"github.com/square/go-jose:3a5ee095dcb5030a9de84fb92c222ac652fff176 -> gopkg.in/square/go-jose.v2" # v2.5.1 (2020-05-01), wanted by hlandau/acmeapi.v2
		"github.com/shiena/ansicolor:c7312218db184c554578219828d6c9498d02dcb1" # 2020-09-04, wanted by hlandau/xlog
		"github.com/tylerstillwater/graceful:4654dfbb6ad53cb5e27f37d99b02e16c1872fbbb -> gopkg.in/tylerb/graceful.v1" # v1.2.15
	)
	inherit x-mgcf-golang-single
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="doc"

DEPEND="dev-lang/go sys-libs/libcap"
RDEPEND="${DEPEND}"
