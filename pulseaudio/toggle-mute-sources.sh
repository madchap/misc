#!/usr/bin/env bash

sources=$(pacmd list-sources | awk '/name:/ {print $2}' |tr -d '<>')

for s in ${sources[@]}; do
    # echo "Toggling source mute state: $s"
    pactl set-source-mute "$s" toggle
done
notify-send "Toggled source mute state"
