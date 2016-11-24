#!/bin/bash

# Fred Blaise & Marc Rumo
# switch windows automatically -- use on 4K monitoring screen

base_search_cmd="xdotool search --name"
time_between_window=6 # in seconds
idle_time_ms=$(($time_between_window*1000-10))  # in ms

windows_id[0]=$($base_search_cmd "zabbix Dashboard") # zabbix
windows_id[1]=$($base_search_cmd Overview)                      # katello
windows_id[2]=$($base_search_cmd "IDE Kanban")                  # leankit
windows_id[3]=$($base_search_cmd "Events")              # datadog evente
windows_id[4]=$($base_search_cmd "Host Map")            # datadog infra hostmap
windows_id[5]=$($base_search_cmd "Kafka")       # datadog kafka overview
windows_id[6]=$($base_search_cmd "ZooKeeper")   # zk overview

while :; do
        for window in "${windows_id[@]}"; do
                if [[ $(xprintidle) -gt $idle_time_ms ]]; then
                        echo "Showing ID $window"
                        xdotool windowactivate $window
                        sleep $time_between_window
                fi
        done
done

