#!/bin/bash
set -x

if [[ "$1" == "laptop" ]]; then
    xrandr --auto
    exit 0
fi

if xrandr | grep -wq "DP2 connected"; then
    echo "laptop monitor + 2 4K"
    # laptop is on the left
    # xrandr --output "$1" --mode 2560x1440 \
    #     --output "$2" --mode 3840x2160 --pos 3200x0 --rate 60.00 \
    #    --output "$3" --mode 3840x2160 --pos 7040x0 --rate 60.00

    # laptop is on the right
    xrandr --output "$3" --mode 3840x2160 --rate 60.00 \
        --output "$2" --mode 3840x2160 --pos 3840x0 --rate 60.00 --primary \
        --output "$1" --mode 2560x1440 --pos 7680x0


elif xrandr | grep -qw "DP1 connected"; then
	echo "laptop monitor + 1 4K"

    # laptop is on the right
	# xrandr --output "$1" --mode 2560x1440 \
    #       --output "$2" --mode 3840x2160 --pos 3200x0 --rate 60.00

    # laptop is on the left
	xrandr --output "$2" --mode 3840x2160 --rate 60.00 \
           --output "$1" --mode 2560x1440 --pos 3840x0 --rate 60.00 --primary

	# sleep 1
	# xrandr --output "${3%-*}" --off

else
	echo "Default: laptop monitor only"
	# xrandr --output "$1" --primary --output "$2" --off --output "$3" --off
    # xrandr --output "$1" --mode 2560x1440 --primary --auto
    xrandr --auto
fi
