# i3 setup - opensuse tumbleweed

.. after having installed all gnome and kde crap...

## get rid of the login manager

Boot into runlevel 3

`sudo systemctl disable display-manager.service`
`sudo systemctl set-default multi-user.target`

## Notifications
KDE's plasma5-workspace will enter in conflict, and you may get may time-out stuff on org.freedesktop.Notifications.

`rpm -qf /usr/share/dbus-1/services/org.kde.plasma.Notifications.service`

I removed that package entirely and starting xfce4-notifyd instead.

## PAM
Using gnome-keyring for secrets and such.

### /etc/pam.d/passwd
Appended `password optional  pam_gnome_keyring.so`

## xrandr
For my dell xps 13 QHD+ and 4k monitor on right side, this works well.
You can call this from the i3 config too.

```
#!/bin/bash

# First argument: Primary monitor
# Second argument: Secondary monitor
xrandr --auto
if  xrandr | grep -q "$2 d"; then
    xrandr --output "$1" --scale 0.8x0.8 --output "$2" --off
else
    xrandr --output "$1" --scale 0.8x0.8 --output "$2" --scale 1x1 --panning 2560x1440 --right-of "$1"
fi
```

### /etc/pam.d/login
Appended `session    optional     pam_gnome_keyring.so        auto_start`

## Some useful packages
* feh
* xkill
* xautolock
* d-feet
* parcellite
* scrot
* xev
* xf86-video-intel
* thunar

# Other notes
Pesky avahi for some my work .local domains...

`sudo sed -i 's!#domain-name=local!domain-name=here!' /etc/avahi/avahi-daemon.conf`
