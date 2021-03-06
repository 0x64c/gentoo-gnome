Unofficial GNOME overlay
[![Build Status](https://travis-ci.org/Heather/gentoo-gnome.png?branch=master)](https://travis-ci.org/Heather/gentoo-gnome)
[![Twitter][]](http://www.twitter.com/Cynede)
[![Donate Bitcoin](https://img.shields.io/badge/donate-bitcoin-orange.svg)](http://heather.github.io/donate-bitcoin/)
------------------------

Versions
--------

 - GNOME `3.28.x`
 - Pantheon `live` ebuilds

Communication
-------------

 - Gentoo discord server: https://discord.gg/KEphgqH
 - issues: https://github.com/Heather/gentoo-gnome/issues

Major differences with main tree
-------------------------

 - if you want to use last vala versions, mask old vala version to see limitations (currently the only way to use new vala is to port everything to this overlay...)
 - removed gdbus-codegen (I have no idea why it was split but it's a pain to keep)

Information
-----------

 - use `compare.py` script to update this overlay on top of official
 - `list.py` to list packages inside overlay with versions
 - official gnome overlay: http://git.overlays.gentoo.org/gitweb/?p=proj/gnome.git;a=summary
 - contributors are still welcome.
 - For bugs use GitHub issues https://github.com/Heather/gentoo-gnome/issues?state=open
 - Please use `pull --rebase` to resolve conflicts or set `branch.autosetuprebase = always`
 - this script removes implemented upstream things from this overlay https://github.com/Heather/gentoo-gnome/blob/master/compare.py

Pantheon
--------

 - I used this fix for Super_L key: http://elementaryos.stackexchange.com/questions/1946/have-application-menu-open-up-with-only-windows-key/2083#2083
 - It loads stuff from /usr/share/gnome/autoload either (not sure if I should remove plank from there)

and here is `.xinitrc`

``` shell
#!/bin/sh
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

#not sure about block below
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/gnome-settings-daemon/gnome-settings-daemon &
/usr/lib/gnome-user-share/gnome-user-share &
eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)
export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK

#sometimes pantheon-session also will work
gsettings-data-convert &
xdg-user-dirs-gtk-update &
xrdb merge ~/.Xresources &&
wingpanel &
plank &
exec gala
```

Plank to autostart in GNOME
---------------------------

add `/usr/share/gnome/autostart/plank.desktop`
```
[Desktop Entry]
Type=Application
Name=Plank
Comment=Plank panel
Exec=/usr/bin/plank
OnlyShowIn=GNOME;
X-GNOME-Autostart-Phase=Application
```

same way you can add `conky -d`

Branches
--------

 - `stable` branch was targeting `Sabayon 14.01`
 - `3.16` branch is saved old master
 - `master` branch is for newer stuff based on portage

[Twitter]: http://mxtoolbox.com/Public/images/twitter-icon.png
