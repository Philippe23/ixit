# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit webapp eutils

MY_PN=${PN}mail
MY_P=${MY_PN}-${PV/_/-}

DESCRIPTION="A browser-based multilingual IMAP client with an application-like user interface"
HOMEPAGE="http://roundcube.net"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"

# roundcube is GPL-licensed, the rest of the licenses here are
# for bundled PEAR components, googiespell and utf8.class.php
LICENSE="GPL-3 BSD PHP-2.02 PHP-3 MIT public-domain"
KEYWORDS="amd64 ~arm ~hppa ~ppc ~ppc64 ~sparc ~x86"
IUSE="ldap +mysql postgres sqlite ssl spell"

RDEPEND="virtual/httpd-php
	>=dev-lang/php-5.3[crypt,gd,iconv,json,ldap?,pdo,postgres?,session,sockets,ssl?,xml,unicode]
	mysql? ( || ( dev-lang/php[mysql] dev-lang/php[mysqli] ) )
	spell? ( dev-lang/php[curl,spell] )
	sqlite? ( || ( dev-lang/php[sqlite] dev-lang/php[sqlite3] ) )
	>=dev-php/PEAR-Mail_Mime-1.8.1
	>=dev-php/PEAR-Net_SMTP-1.4.2
	>=dev-php/PEAR-Net_IDNA2-0.1.1
	>=dev-php/PEAR-Auth_SASL-1.0.3"

need_httpd_cgi

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/roundcube-1.0.0-compose-fix.patch
	rm -r program/js/app.min.js

	# Remove bundled PEAR packages
	rm -r program/lib/{Auth,Mail,Net,PEAR*} || die
}

src_install() {
	webapp_src_preinst
	dodoc CHANGELOG INSTALL README.md UPGRADING

	insinto "${MY_HTDOCSDIR}"
	doins -r [[:lower:]]* SQL
	doins .htaccess

	webapp_serverowned "${MY_HTDOCSDIR}"/logs
	webapp_serverowned "${MY_HTDOCSDIR}"/temp

	webapp_configfile "${MY_HTDOCSDIR}"/config/defaults.inc.php
	webapp_postupgrade_txt en UPGRADING
	webapp_src_install
}

pkg_postinst() {
	ewarn "When upgrading from <= 0.9 the old configuration files named"
	ewarn "main.inc.php and db.inc.php are now deprecated and should be"
	ewarn "replaced with one single config.inc.php file."
	ewarn "Run the ./bin/update.sh script to get this conversion done"
	ewarn "or manually merge the files."
	ewarn "NOTE: the new config.inc.php should only contain options that"
	ewarn "differ from the ones listed in defaults.inc.php."

	ewarn "If you have problem with"
	ewarn "unexpected redirects to inbox after auto-saving a draft (#1489789)"
	ewarn "remove app.min.js file from program/js/app.min.js"
}