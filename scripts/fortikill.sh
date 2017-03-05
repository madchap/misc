#!/bin/bash

ps ax |grep forticlientsslvpn |grep -v -E 'grep|pppd' | awk {'print $1'} |xargs kill -15

# finish off one that remains for whatever reason.
ps ax |grep forticlientsslvpn |grep -v -E 'grep|pppd' | awk {'print $1'} |xargs kill -9

# kill tunnels
ps -ef |grep -E '\-tunnel|\-jump' |awk {'print $2'} |xargs kill 


# show procs
echo
echo "forticlient procs remaining:"
ps ax |grep forticlientsslvpn |grep -v -E 'grep|pppd' 
echo
echo "autossh procs remaining:"
ps -ef |grep -v grep | grep -E '\-tunnel|\-jump' 
echo

# reset proxy
gsettings set org.gnome.system.proxy mode 'none'
