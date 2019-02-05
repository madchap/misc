#!/bin/bash
set -x
# First argument: Primary monitor
# Second argument: Secondary monitor
xrandr --auto

if [[ -z $2 ]] && [[ -z $3 ]]; then
	echo "laptop monitor only"
	# Xft.dpi instead of scaling
	xrandr --output "$1" --primary 

elif xrandr | grep -q "$3 connected"; then
	echo "home 3 monitors setup"
	# rotation normal
    xrandr --output "$1" --mode 3200x1800 \
           --output "$2" --mode 3840x2160 --pos 3200x0 --rate 60.00 \
           --output "$3" --mode 3840x2160 --pos 7040x0 --rate 60.00
	
	# vertical rotation
	# xrandr --output "$3" --rotate left --mode 1920x1200 --pos 1360x0 --rate 59.95 --output "$1" --scale 0.8x0.8 --pos 0x1920 --output "$2" --primary --mode 3840x2160 --pos 2560x0 --rate 60.00

else
	echo "Default: laptop monitor only"
	xrandr --output "$1" --primary --output "$2" --off --output "$3" --off
fi
