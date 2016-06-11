#!/bin/bash

#   FBI - 10.06.2016
#   Basic script to dynamically update home IP address in particular Openstack SecurityGroup based on dynamicDNS result
#   Only TCP ports for now

LOG=/tmp/`basename $0`.log

# BEGIN defaults VARIABLES ###
SECGROUP_ACTION="list"
PORTS=( )

### END VARIABLES ###

function show_help() {
cat << EOH
Usage: ${0##*/} [-s SECGROUP_NAME] [ [-d DNSNAME] or [-i IPADDR]] [-f OPENRC_FILE] [-p PORTS] [-arl]

    -a add to SECGROUP_NAME
    -r remove from SECGROUP_NAME
    -l list from SECGROUP_NAME [default]

    -s Security group to act on
    -i Single IP address to act on
    -d DNS domain to resolve (will be converted to single IP)
    -f OPENRC_FILE to source
    -p Ports to open, as array (e.g. -p "22,80,443")

EOH
}

function valid_ip() {
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

source_openrc() {
    source $OPENRC_FILE
}


### MAIN STARTS ###

opt_ip=false
opt_dns=false
while getopts "s:d:i:f:p:arlh" opt; do
    case $opt in
        s)
            SECGROUP_NAME=$OPTARG
            echo "Security group passed in : $SECGROUP_NAME"
            ;;
        d)
            opt_dns=true
            $opt_ip && echo "IP option already specified. Specify either an IP or DNS." && exit 3
            DNS2WL=$OPTARG
            echo "DNS domain passed in : $DNS2WL"
            ;;
        i)
            opt_ip=true
            $opt_dns && echo "DNS option already specified. Specify either an IP or DNS." && exit 3
            if valid_ip $OPTARG; then
                IP2WL=$OPTARG
                echo "IP ipassed in : $IP2WL"
            else
                echo "IP given for override not valid. Exiting."
                exit 2
            fi
            ;;
        a)
            SECGROUP_ACTION="add"
            ;;
        r)
            SECGROUP_ACTION="delete"
            ;;
        l)
            SECGROUP_ACTION="list"
            ;;
        f)
            OPENRC_FILE=$OPTARG
            echo "Will source file $OPENRC_FILE"
            source $OPENRC_FILE
            ;;
        p)
            PORTS="$OPTARG"
            echo "Will act on ports \"$PORTS\""
            ;;
        h)
            show_help
            exit 1
            ;;
        :)
            echo "Option -$OPTARG needs an argument"
            exit 1
            ;;
        *)
            echo "Not an option here"
            exit 1
            ;;
    esac
done

[[ ! -z $DNS2WL ]] && IP2WL=`host ${DNS2WL} | awk '/has address/ { print $4 }'`
cat << EOC
--
Sourced file: $OPENRC_FILE
SecGroup: $SECGROUP_NAME
Current IP: $IP2WL
Action: $SECGROUP_ACTION
--
EOC

case $SECGROUP_ACTION in
    list)
        nova secgroup-list-rules $SECGROUP_NAME
        ;;

    delete)
        echo "Deleting rules in security group $SECGROUP_NAME in 5 seconds. Ctrl-C to stop."
        sleep 5
        # will delete all existing rules, clear table. only 1 home right?
        RAW_RULES=$(nova secgroup-list-rules $SECGROUP_NAME)
        while read -r line; do
            read from_port to_port ip_addr <<< `echo "$line"`
            nova secgroup-delete-rule $SECGROUP_NAME tcp $from_port $to_port $ip_addr
        done <<< "$(echo -e "$RAW_RULES" | awk '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ {print $4,$6,$8}')"
        ;;

    add)
        for port in ${PORTS[@]}; do
            nova secgroup-add-rule $SECGROUP_NAME tcp $port $port ${IP2WL}/32
        done
        ;;
esac
