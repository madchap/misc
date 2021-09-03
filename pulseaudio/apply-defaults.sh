#!/usr/bin/env bash
# hacky script bound to keyboard shortcut to reset source and sink
set -ex

boseqc_headset_bt_id=bluez_card.28_11_A5_74_6A_B8

# set yeti with echo cancellation as the default source
# this should be the one selected in the app too, otherwise..
pactl set-default-source alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8_2018_4_12_17945-00.analog-stereo.echo-cancel
# muting built-in audio, not even sure what that is.
pactl set-source-mute alsa_input.pci-0000_00_1f.3.analog-stereo on

# switch bose qcii back to a2dp sound profile
pactl set-card-profile ${boseqc_headset_bt_id} a2dp_sink

# set it as default sink for all apps, but MSTeams won't give a crap.
pactl set-default-sink ${boseqc_headset_bt_id}.a2dp_sink

# set MSteams to use bose QCii, no telling what that app is doing
# shaky for now, waiting on pactl json output coming soon..
sink_id=$(pactl list sink-inputs | grep -B 16 skype |awk '/Sink Input/ {print substr($3,2)}')
pactl move-sink-input $sink_id ${boseqc_headset_bt_id}.a2dp_sink
