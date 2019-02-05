#!/usr/bin/env sh
# run through 'at' coming from udev

# wait for the system to stabilize
sleep 3

export XAUTHORITY=/home/fblaise/.Xauthority
export DISPLAY=:0

/home/fblaise/.i3/scripts/xrandr.sh eDP1 DP2-2 DP1-2 && sh /home/fblaise/gitrepos/misc/setxkbmap && xmodmap /home/fblaise/.Xmodmap && xrandr --output eDP1 --off
