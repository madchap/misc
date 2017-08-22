ssh-add -l
if [[ $? -eq 0 ]]; then

	echo "Killing existing tunnels"
	ps -ef |grep -E '\-tunnel|\-jump' |awk {'print $2'} |xargs kill -9

	for h in $(grep -E '\-jump$|\-tunnel$' ~/.ssh/config |cut -d' ' -f2); do
		echo "-> Creating $h tunnel"
		autossh -M0 -f -N -T $h
	done

	networksetup -setautoproxyurl "Wi-Fi" "file:///Users/fblaise/proxy.pac"
	networksetup -setautoproxystate "Wi-Fi" on
	networksetup -setautoproxyurl "Thunderbolt Ethernet" "file:///Users/fblaise/proxy.pac"
	networksetup -setautoproxystate "Thunderbolt Ethernet" on

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
netstat -an|grep "LISTEN" |grep -E '2244|339'

# Launch google chrome with proxy pac if it refuses it...
# /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --proxy-pac-url=file:///Users/fblaise/proxy.pac
