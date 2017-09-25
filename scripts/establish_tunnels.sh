#!/usr/bin/env bash

X=$(ssh-add -l |wc -l)
if [[ $X -ge 2 ]]; then

	echo "Killing existing tunnels"
	ps -ef |grep -E '\-tunnel|\-jump' |awk {'print $2'} |xargs kill -9

	for h in $(grep -E '\-jump$|\-tunnel$' ~/.ssh/config |cut -d' ' -f2); do
		echo "-> Creating $h tunnel"
		autossh -M0 -f -N -T $h
	done

	echo
	echo "Setting gnome proxy settings to auto (proxy.pac)"
	gsettings set org.gnome.system.proxy mode 'auto'
	# gsettings set org.gnome.system.proxy autoconfig-url file:///home/fblaise/proxy.pac
	sed -i 's!ProxyType=0!ProxyType=2!' ~/.config/kioslaverc
else
	echo "Not going to establish tunnels unless the ssh-agent has keys attached to it!"
fi

echo
echo "SUMMARY"
echo "Processes"
ps -ef |grep -E '\-tunnel|\-jump' |grep -v grep

sleep 1
echo
echo "netstat"
sudo netstat -anp| grep LISTEN| grep ssh
