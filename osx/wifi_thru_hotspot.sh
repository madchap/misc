#!/usr/bin/env bash
# macos specific commands

set -euo pipefail

hotspot_ssid="blazer"
darth_ip=$(dig +short q.darthgibus.net |tail -1)
echo "IP for darthgibus is $darth_ip"

wifi_ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')

if [[ "$wifi_ssid" == "$hotspot_ssid" ]]; then
    echo "We are connected to ssid $hotspot_ssid, continuing."
    en0_gw=$(netstat -rn |grep en0 |awk '/default/ {print $2}')
    echo -n "Gateway from hotspot is $en0_gw"
    echo "Adding route.."

    sudo route -n add -net ${darth_ip}/32 192.168.43.1

    echo
    echo "route for $darth_ip:"
    netstat -rn |grep "$darth_ip"
fi
