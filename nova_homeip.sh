#!/bin/bash
#LOG=/Users/fblaise/openstack_client_tools/venv_openstack/log/`basename $0`.log
LOG=/tmp/`basename $0`.log

function myhelp () {
	echo
	echo "$0 [add|delete] [ip|dns]"
	echo "Default lists last actions based on local log file"
	echo
	echo " 1. Make sure you have sourced your openstack environment. You can find this file on the web interface under 'Access and Security > API Access tab --> Download Openstack RC file'"
	echo " 2. You have to be at work or connected via VPN to connect to the nova API"
	echo " 3. You will obviously need to install the python-nova client"
	echo
	echo " This script was written way too quickly in a place that I will not name..."
}

function valid_ip()
{
    local  ip=$1
    local  stat=1

    re='^[0-9]+'
    if [[ ! $1 =~ $re ]]; then
	return $stat
    fi 

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function recent_actions() {
    echo "List of recent actions:"
    tail -n10 $LOG
    echo
}

function list_rules() {
    echo "Fetching nova secgroup rules for FBI-home"
    nova secgroup-list-rules FBI-home
}

[[ -z $1 ]] && recent_actions && exit -1

# add or delete
if [ -z $2 ]; then
    echo "--> No IP/DNS provided. Using current public IP"
    GIVEN_IP=`wget http://ipinfo.io/ip -qO -`
else
    GIVEN_IP=$2
fi
ACTION=$1

# validate IP
if valid_ip $GIVEN_IP ; then 
	MY_IP=$GIVEN_IP
else
	# potentially a dns name
	# echo "Not a valid IP, trying to look it up.."
	MY_IP=$(host $GIVEN_IP | awk {'print $4'})
	if ! valid_ip ${MY_IP} ; then
		echo "Could not resolve name to an IP address."
		myhelp
		exit -1
	else
		echo "Resolved $GIVEN_IP to $MY_IP."
	fi
fi

echo "$(date): ${ACTION} ${MY_IP}" | tee -a $LOG

# FBI-home
nova secgroup-${ACTION}-rule FBI-home tcp 8080 8080 ${MY_IP}/32
nova secgroup-${ACTION}-rule FBI-home tcp 8888 8888 ${MY_IP}/32
nova secgroup-${ACTION}-rule FBI-home tcp 8000 8000 ${MY_IP}/32
nova secgroup-${ACTION}-rule FBI-home tcp 8088 8088 ${MY_IP}/32
nova secgroup-${ACTION}-rule FBI-home tcp 80 80 ${MY_IP}/32
nova secgroup-${ACTION}-rule FBI-home tcp 443 443 ${MY_IP}/32
nova secgroup-${ACTION}-rule FBI-home tcp 8443 8443 ${MY_IP}/32
nova secgroup-${ACTION}-rule FBI-home tcp 22 22 ${MY_IP}/32

echo "Getting summary of rules.."
echo
list_rules
