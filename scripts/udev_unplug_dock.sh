#!/usr/bin/env bash

# wait for the system to stabilize
sleep 3
export DISPLAY=:0

/home/fblaise/.i3/scripts/xrandr.sh eDP1 && sh /home/fblaise/gitrepos/misc/setxkbmap && xmodmap /home/fblaise/.Xmodmap
