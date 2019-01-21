#!/usr/bin/env bash
# macos specific commands

set -euo pipefail

state_file=$HOME/.$(basename ${0}).log
hotspot_ssid="blazer"
darth_ip=$(dig +short q.darthgibus.net |tail -1)
bb_ip=$(dig +short bitbucket.pmidce.com)
echo "IP for darthgibus is $darth_ip"
echo "IPs for BB pmi: $bb_ip"
IP_LIST="$darth_ip $bb_ip"

wifi_ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')


function add_route() {
    ip="$1"
    en0_gw=$(netstat -rn |grep en0 |awk '/default/ {print $2}')
    echo -n "Gateway from hotspot is $en0_gw. "
    echo "Adding route.."

    sudo route -n add -net ${ip}/32 $en0_gw

    echo "${ip} ${en0_gw}" >> $state_file
    netstat -rn |grep "$ip"
}

function remove_route() {
    # read from state file
    while read -r ip gw; do
        echo "Processing ip $ip with gw $gw"
        sudo route -n delete -net $ip/32 $gw
    done < $state_file
}

if [[ "$wifi_ssid" == "$hotspot_ssid" ]]; then
    echo "We are connected to ssid $hotspot_ssid, continuing."
    echo "Removing previously written route and clearing statefile $state_file, and re-adding."
    remove_route
    for ip in ${IP_LIST[@]}; do
        add_route $ip
    done
else
    echo "Removing routes that are going through hotspot"
    remove_route
fi
