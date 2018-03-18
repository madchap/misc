#!/bin/bash
# ACCEPT or DROP from countries on certain ports.

set -x

[[ $UID -ne 0 ]] && echo "Please run as root or sudo." && exit 1

IPSET_LIST=geoAllowIP
# allow only CH to access my port 443. Destination ports.
PORTS=443
# comma separated countries
COUNTRIES="ch"
# If you want to protest a destination port that ends in a docker container, DOCKER-USER is actually called before INPUT.
IPTABLES_CHAIN="DOCKER-USER"
#IPTABLES_CHAIN="INPUT"
IPTABLES_ACTION="ACCEPT"

if [[ ! -z "$1" ]]; then
	case "$1" in 
		"delete" ) 	ACTION="D";;
		"add" ) 	ACTION="I";;
		"list" ) 	ipset list $IPSET_LIST; exit 0;;
		"*" ) 		echo "add, delete or list." && exit 1;;
	esac
fi

ipset -N $IPSET_LIST nethash

# get IPs from the countries
if [[ "$ACTION" == "I" ]]; then
	for country in ${COUNTRIES[@]}; do
		for IP in $(wget -qO- http://www.ipdeny.com/ipblocks/data/countries/$country.zone); do
			ipset -A $IPSET_LIST $IP
		done
	done
fi

ipset save $IPSET_LIST

# Add a rule for each destination ports
for port in ${PORTS[@]}; do
	if [[ $ACTION == "D" ]]; then
		iptables -${ACTION} $IPTABLES_CHAIN -p tcp -m state --state NEW -m tcp --dport $port -m set --match-set $IPSET_LIST src -j $IPTABLES_ACTION
		sudo ipset destroy $IPSET_LIST
	elif [[ $ACTION == "I" ]]; then
		iptables -${ACTION} $IPTABLES_CHAIN 1 -p tcp -m state --state NEW -m tcp --dport $port -m set --match-set $IPSET_LIST src -j $IPTABLES_ACTION
	fi
done
