#!/usr/bin/env bash
# run through 'at' coming from udev

# wait for the system to stabilize
sleep 3

export XAUTHORITY=/home/fblaise/.Xauthority
export DISPLAY=:0

XRANDRNOW_FILE=/tmp/xrandr-current.txt
REFERENCE_XRANDR=/home/fblaise/wrong_4k_order.txt

xrandr --prop | grep -A2 EDID > "$XRANDRNOW_FILE"
# "wrong" file currently has 4k monitors the wrong way
if [[ -e "$REFERENCE_XRANDR" ]]; then
    if diff -q "$XRANDRNOW_FILE" "$XRANDRNOW_FILE"; then
        if [[ $(wc -l "$XRANDRNOW_FILE" |cut -d' ' -f1) -lt 8 ]]; then
            echo "DP2 is not showing as connected..."
            /home/fblaise/.i3/scripts/xrandr.sh eDP1 DP1
        else
            echo "Monitors are inverted."
            /home/fblaise/.i3/scripts/xrandr.sh eDP1 DP2 DP1
        fi
    else
        echo "All is good."
        /home/fblaise/.i3/scripts/xrandr.sh eDP1 DP1 DP2
    fi
    # xrandr --output eDP1 --off
    sh /home/fblaise/gitrepos/misc/setxkbmap
    xmodmap /home/fblaise/.Xmodmap
fi
