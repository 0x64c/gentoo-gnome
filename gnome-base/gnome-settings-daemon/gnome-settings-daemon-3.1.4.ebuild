# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-settings-daemon/gnome-settings-daemon-2.32.1.ebuild,v 1.1 2010/12/04 16:50:12 pacho Exp $

EAPI="4"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit eutils gnome2
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="Gnome Settings Daemon"
HOMEPAGE="http://www.gnome.org"

LICENSE="GPL-2"
SLOT="0"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
fi
IUSE="+cups debug packagekit policykit short-touchpad-timeout smartcard +udev"

# Latest gsettings-desktop-schemas is needed due to commit e8d1de92
COMMON_DEPEND=">=dev-libs/dbus-glib-0.74
	>=dev-libs/glib-2.26.0:2
	>=x11-libs/gtk+-2.99.3:3
	>=gnome-base/gconf-2.6.1:2
	>=gnome-base/libgnomekbd-2.91.1
	>=gnome-base/gnome-desktop-3.1.4:3
	>=gnome-base/gsettings-desktop-schemas-0.1.7.1
	media-fonts/cantarell
	media-libs/fontconfig
	>=media-libs/lcms-2.2:2
	media-libs/libcanberra[gtk3]
	>=media-sound/pulseaudio-0.9.16
	>=sys-power/upower-0.9.1
	>=x11-libs/libnotify-0.7.3
	x11-libs/libXi
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXxf86misc
	>=x11-libs/libxklavier-5.0
	>=x11-misc/colord-0.1.9
	>=media-sound/pulseaudio-0.9.16

	cups? ( >=net-print/cups-1.4[dbus] )
	packagekit? (
		|| ( sys-fs/udev[gudev]
			sys-fs/udev[extras] )
		>=app-admin/packagekit-base-0.6.4 )
	policykit? (
		>=sys-auth/polkit-0.97
		>=sys-apps/dbus-1.1.2 )
	smartcard? ( >=dev-libs/nss-3.11.2 )
	udev? ( || ( sys-fs/udev[gudev]
		sys-fs/udev[extras] ) )"
# Themes needed by g-s-d, gnome-shell, gtk+:3 apps to work properly
# <gnome-color-manager-3.1.1 has file collisions with g-s-d-3.1.x
# <gnome-power-manager-3.1.4 has file collisions with g-s-d-3.1.x
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	>=x11-themes/gnome-themes-standard-2.91
	>=x11-themes/gnome-icon-theme-2.91
	>=x11-themes/gnome-icon-theme-symbolic-2.91
	!<gnome-base/gnome-control-center-2.22
	!!<gnome-extra/gnome-color-manager-3.1.1
	!!<gnome-extra/gnome-power-manager-3.1.3"
# xproto-7.0.15 needed for power plugin
DEPEND="${COMMON_DEPEND}
	cups? ( sys-apps/sed )
	sys-devel/gettext
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.19
	x11-proto/inputproto
	x11-proto/kbproto
	x11-proto/xf86miscproto
	>=x11-proto/xproto-7.0.15"

pkg_setup() {
	# README is empty
	DOCS="AUTHORS NEWS ChangeLog MAINTAINERS"
	G2CONF="${G2CONF}
		--disable-static
		--disable-schemas-compile
		--enable-gconf-bridge
		--with-pnpids=${EROOT}usr/share/libgnome-desktop-3.0/pnp.ids
		$(use_enable cups)
		$(use_enable debug)
		$(use_enable debug more-warnings)
		$(use_enable packagekit)
		$(use_enable policykit polkit)
		$(use_enable smartcard smartcard-support)
		$(use_enable udev gudev)"
}

src_prepare() {
	# https://bugzilla.gnome.org/show_bug.cgi?id=621836
	# Apparently this change severely affects touchpad usability for some
	# people, so revert it if USE=short-touchpad-timeout.
	# Revisit if/when upstream adds a setting for customizing the timeout.
	use short-touchpad-timeout &&
		epatch "${FILESDIR}/${PN}-3.0.2-short-touchpad-timeout.patch"

	gnome2_src_prepare
}

src_install() {
	gnome2_src_install

	echo 'GSETTINGS_BACKEND="dconf"' >> 51gsettings-dconf
	doenvd 51gsettings-dconf || die "doenvd failed"
}
