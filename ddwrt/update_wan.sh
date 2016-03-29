#!/bin/sh

#   Fred on 28.03.2016
#   Since the swisscom router IP passthrough is not dynamic, need a way to update the WAN IP from the inside.
#   Allows DDWRT to update its WAN IP based on the swisscom router information
#   You can cron that every 10 minutes for example

# Change to whereever you need
WANINFO=/opt/bin/wan.out

echo "==> Starting at `date`"
echo
echo "Retrieving IP summary from Piccolo..."
(
sleep 2
echo "admin"
sleep 1
echo "PASSWORD_HERE"
sleep 1
echo "show summary"
sleep 1
echo "exit"
sleep 1
) |telnet 192.168.1.1 > $WANINFO

WANIP=`grep "IP Address" $WANINFO | grep -v "192.168." |awk {'print $3'}`
echo "WAN IP is : $WANIP"

WANGW=`grep "Default Gateway" $WANINFO | grep -v "192.168." |awk {'print $3'}`
echo "WAN GW is : $WANGW"

echo
CUR_WANIP=`nvram get wan_ipaddr`
CUR_WANGW=`nvram get wan_gateway`
echo "Current NVRAM WAN IP value is $CUR_WANIP"
echo "Current NVRAM WAN GW value is $CUR_WANGW"

if [ "$WANIP" == "$CUR_WANIP" ]; then
    echo "WAN IP is still the same. Not doing anything."
else
    echo "WAN IP has changed. Updating NVRAM with new values."
    nvram set wan_ipaddr=$WANIP
    nvram set wan_ipaddr_buf=$WANIP
    nvram set wan_gateway=$WANGW
    nvram commit
    echo "Committed."
    echo "Restarting WAN service"
    stopservice wan
    sleep 5
    startservice wan
fi

echo
echo "<== Ending at `date`"
echo
