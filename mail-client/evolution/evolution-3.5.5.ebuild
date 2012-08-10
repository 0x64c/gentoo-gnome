# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit eutils flag-o-matic gnome2
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="Integrated mail, addressbook and calendaring functionality"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

LICENSE="GPL-2 LGPL-2 OPENLDAP"
SLOT="2.0"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86 ~x86-fbsd"
fi
IUSE="clutter crypt doc +gnome-online-accounts gstreamer kerberos ldap map ssl"

# We need a graphical pinentry frontend to be able to ask for the GPG
# password from inside evolution, bug 160302
PINENTRY_DEPEND="|| ( app-crypt/pinentry[gtk] app-crypt/pinentry-qt app-crypt/pinentry[qt4] )"

# glade-3 support is for maintainers only per configure.ac
# pst is not mature enough and changes API/ABI frequently
COMMON_DEPEND=">=dev-libs/glib-2.32:2
	>=x11-libs/cairo-1.9.15[glib]
	>=x11-libs/gtk+-3.2.0:3
	>=gnome-base/gnome-desktop-2.91.3:3
	>=gnome-base/gsettings-desktop-schemas-2.91.92
	>=dev-libs/libgweather-3.5.0:2
	>=media-libs/libcanberra-0.25[gtk3]
	>=x11-libs/libnotify-0.7
	>=gnome-extra/evolution-data-server-${PV}[gnome-online-accounts?,weather]
	>=gnome-extra/gtkhtml-4.5.2:4.0
	dev-libs/atk
	>=dev-libs/dbus-glib-0.6
	>=dev-libs/libxml2-2.7.3:2
	>=net-libs/libsoup-gnome-2.38.1:2.4
	>=x11-misc/shared-mime-info-0.22
	>=x11-themes/gnome-icon-theme-2.30.2.1
	>=dev-libs/libgdata-0.10
	>=net-libs/webkit-gtk-1.8.0

	x11-libs/libSM
	x11-libs/libICE

	clutter? (
		>=media-libs/clutter-1.0.0:1.0
		>=media-libs/clutter-gtk-0.90:1.0
		x11-libs/mx:1.0 )
	crypt? ( || (
		( >=app-crypt/gnupg-2.0.1-r2 ${PINENTRY_DEPEND} )
		=app-crypt/gnupg-1.4* ) )
	gnome-online-accounts? ( >=net-libs/gnome-online-accounts-3.2 )
	gstreamer? (
		>=media-libs/gstreamer-0.10:0.10
		>=media-libs/gst-plugins-base-0.10:0.10 )
	kerberos? ( virtual/krb5 )
	ldap? ( >=net-nds/openldap-2 )
	map? (
		>=app-misc/geoclue-0.12.0
		>=media-libs/libchamplain-0.12:0.12 )
	ssl? (
		>=dev-libs/nspr-4.6.1
		>=dev-libs/nss-3.11 )"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.1.2
	>=app-text/gnome-doc-utils-0.20.10
	app-text/scrollkeeper
	>=dev-util/intltool-0.40.0
	sys-devel/bison
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	doc? ( >=dev-util/gtk-doc-1.14 )"
# eautoreconf needs:
#	>=gnome-base/gnome-common-2.12
#	>=dev-util/gtk-doc-am-1.9
RDEPEND="${COMMON_DEPEND}
	!<gnome-extra/evolution-exchange-2.32"

# contact maps require clutter
REQUIRED_USE="map? ( clutter )"

pkg_setup() {
	ELTCONF="--reverse-deps"
	DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS* README"
	# image-inline plugin needs a gtk+:3 gtkimageview, which does not exist yet
	G2CONF="${G2CONF}
		--disable-schemas-compile
		--without-glade-catalog
		--without-kde-applnk-path
		--disable-image-inline
		--disable-pst-import
		--enable-canberra
		--enable-weather
		$(use_enable ssl nss)
		$(use_enable ssl smime)
		$(use_enable gnome-online-accounts goa)
		$(use_enable gstreamer audio-inline)
		$(use_enable map contact-maps)
		$(use_with clutter)
		$(use_with ldap openldap)
		$(use_with kerberos krb5 ${EPREFIX}/usr)"

	# Use NSS/NSPR only if 'ssl' is enabled.
	if use ssl ; then
		G2CONF="${G2CONF} --enable-nss=yes"
	else
		G2CONF="${G2CONF}
			--without-nspr-libs
			--without-nspr-includes
			--without-nss-libs
			--without-nss-includes"
	fi
}

src_prepare() {
	# Fix paths for Gentoo spamassassin executables
	epatch "${FILESDIR}/${PN}-3.3.91-spamassassin-paths.patch"

	epatch "${FILESDIR}/${P}-redefinition-of-typedef-causing-build-error-with-gcc.patch"

	sed -e "s:@EPREFIX@:${EPREFIX}:g" \
		-i data/org.gnome.evolution.spamassassin.gschema.xml.in \
		-i modules/spamassassin/evolution-spamassassin.c || die "sed failed"

	gnome2_src_prepare

	# Fix compilation flags crazyness
	sed -e 's/\(AM_CPPFLAGS="\)$WARNING_FLAGS/\1/' \
		-i configure || die "CPPFLAGS sed failed"
}

pkg_postinst() {
	gnome2_pkg_postinst

	elog "To change the default browser if you are not using GNOME, edit"
	elog "~/.local/share/applications/mimeapps.list so it includes the"
	elog "following content:"
	elog ""
	elog "[Default Applications]"
	elog "x-scheme-handler/http=firefox.desktop"
	elog "x-scheme-handler/https=firefox.desktop"
	elog ""
	elog "(replace firefox.desktop with the name of the appropriate .desktop"
	elog "file from /usr/share/applications if you use a different browser)."
	elog ""
	elog "Junk filters are now a run-time choice. You will get a choice of"
	elog "bogofilter or spamassassin based on which you have installed"
	elog ""
	elog "You have to install one of these for the spam filtering to actually work"
}
