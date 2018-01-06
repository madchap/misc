#!/bin/bash
set -eux

# base dir for backlight class
basedir="/sys/class/backlight/intel_backlight/"

# get the backlight basedir
#basedir=$(ls $basedir)/

# get current brightness
old_brightness=$(cat $basedir/"brightness")

# get max brightness
max_brightness=$(cat $basedir/"max_brightness")

# get current brightness %
old_brightness_p=$(( 100 * $old_brightness / $max_brightness ))

# calculate new brightness % 
new_brightness_p=$(($old_brightness_p $1))

# calculate new brightness value
new_brightness=$(( $max_brightness * $new_brightness_p / 100 ))
if [ "$new_brightness" -gt "$max_brightness" ]; then
	new_brightness=$max_brightness
fi

notify-send -u low -i /usr/share/notify-osd/icons/hicolor/scalable/status/notification-display-brightness.svg "Brightness" "Brightness now at $new_brightness (max: $max_brightness)"

# set the new brightness value
sudo chmod 666 $basedir"brightness"
echo $new_brightness > $basedir"brightness"
