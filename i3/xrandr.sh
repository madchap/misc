#!/bin/bash

# First argument: Primary monitor
# Second argument: Secondary monitor
xrandr --auto
if  xrandr | grep -q "$2 d"; then
    xrandr --output "$1" --scale 0.8x0.8 --output "$2" --off
else
    xrandr --output "$1" --scale 0.8x0.8 --output "$2" --primary --scale 1x1 --panning 2560x1440 --right-of "$1"
fi
