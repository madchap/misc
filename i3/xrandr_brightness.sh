#!/bin/bash
##

BRIGHTNESS="$HOME/.config/mon-brightness.rc"

if [[ -f $BRIGHTNESS ]]; then
	VAL=$(<$BRIGHTNESS)
else
	VAL=1.0
	echo $VAL > $BRIGHTNESS
fi

if [[ $1 = plus ]]; then
	VAL=$(awk -v "VAL=$VAL" 'BEGIN { print VAL + 0.1 }')
	notify-send -u low -i /usr/share/notify-osd/icons/hicolor/scalable/status/notification-display-brightness.svg "xrandr Brightness" "Brightness now up to $VAL"
elif [[ $1 = minus ]]; then
	VAL=$(awk -v "VAL=$VAL" 'BEGIN { print VAL - 0.1 }')
	notify-send -u low -i /usr/share/notify-osd/icons/hicolor/scalable/status/notification-display-brightness.svg "xrandr Brightness" "Brightness now down to $VAL"
else
	notify-send -t 3000 "Use 'brightness plus/minus'"
	exit 1
fi

echo $VAL > $BRIGHTNESS

XCMND="xrandr --output eDP1 --brightness"

$XCMND $VAL
