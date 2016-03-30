#!/bin/sh

#   Fred on 28.03.2016
#   Since the swisscom router IP passthrough is not dynamic (on certain fw versions anyway), need a way to update the WAN IP from the inside.
#   Allows DDWRT to update its WAN IP based on the swisscom router information.
#   This script was made using the following router:
#   General Information for "Centro_piccolo"
#            Hardware: Motorola Netopia Model 7640-47 Annex A VDSL2 IAD
#   You can cron that every 10 minutes for example

WANINFO=/opt/bin/wan.out
EMAIL=xxxxxx@gmail.com
SMTPGW=aspmx.l.google.com

send_email() {
    # sendmail is still segfaulting, so need an alternative way.
        (
        sleep 5
    echo "helo r7000.home"
    sleep 2
    echo "mail from: $EMAIL"
    sleep 2
    echo "rcpt to: $EMAIL"
    sleep 2
    echo "data"
    sleep 1
    echo "From: <$EMAIL>"
    sleep 1
    echo "Subject: WAN IP has changed"
    sleep 1
    echo "Hello, the WAN IP has changed from $1 to $2. Thank you!"
    echo "."
    sleep 3
    echo "quit"
    sleep 1
    ) | telnet $SMTPGW 25
}

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
echo "ISP WAN IP is : $WANIP"

WANGW=`grep "Default Gateway" $WANINFO | grep -v "192.168." |awk {'print $3'}`
WANMASK=`grep "Default Gateway" $WANINFO | grep -v "192.168." |awk {'print $5'}`

echo
CUR_WANIP=`nvram get wan_ipaddr`
echo "Current NVRAM WAN IP value is $CUR_WANIP"

if [ "$WANIP" == "$CUR_WANIP" ]; then
    echo "WAN IP is still the same. Not doing anything."
else
    echo "WAN IP has changed. Updating NVRAM with new values."
    nvram set wan_ipaddr=$WANIP
    nvram set wan_ipaddr_buf=$WANIP
    nvram set wan_gateway=$WANGW
    nvram set wan_netmask=$WANMASK
    nvram commit
    echo "Committed."
    echo "Restarting WAN service"
    stopservice wan
    sleep 5
    startservice wan

    # do we need to wait a bit to send the email? maybe...
    sleep 15
    send_email $CUR_WANIP $WANIP
fi

echo
echo "<== Ending at `date`"
echo
