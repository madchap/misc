#!/bin/bash
set -x
# First argument: Primary monitor
# Second argument: Secondary monitor
xrandr --auto
sleep 1

if [[ -z $2 ]] && [[ -z $3 ]]; then
	echo "Default: laptop monitor only"
	xrandr --output "$1" --scale 0.8x0.8 --primary 

elif xrandr | grep -q "$3 connected"; then
	echo "home 3 monitors setup"
	xrandr --output "$3" --mode 1920x1200 --pos 640x0 --rate 59.95 --output "$1" --scale 0.8x0.8 --pos 0x1200 --output "$2" --primary --mode 3840x2160 --pos 2560x0

elif xrandr | grep -q "$2 connected"; then
	echo "2 monitors setup"
	xrandr --output "$1" --scale 0.8x0.8 --output "$2" --primary --scale 1x1 --panning 2560x1440 --right-of "$1"

else
	echo "Default: laptop monitor only"
	xrandr --output "$1" --scale 0.8x0.8 --primary --output "$2" --off --output "$3" --off
fi
