#!/bin/bash

#   FBI - 10.06.2016
#   Basic script to dynamically update home IP address in particular Openstack SecurityGroup based on dynamicDNS result
#   Only TCP ports for now, single IP.

LOG=/tmp/`basename $0`.log
echo > $LOG

# BEGIN defaults VARIABLES ###
SECGROUP_ACTION="list"
PORTS=( )

### END VARIABLES ###

function show_help() {
cat << EOH
Usage: ${0##*/} [-s SECGROUP_NAME] [ [-d DNSNAME] or [-i IPADDR]] [-f OPENRC_FILE] [-p PORTS] [-n EMAIL] [-arlu]

    -a Add to SECGROUP_NAME
    -r Remove from SECGROUP_NAME
    -l List from SECGROUP_NAME [default]
    -u Reads current rules, checks the IP, and updates it if needed

    -s Security group to act on
    -i Single IP address to act on
    -d DNS domain to resolve (will be converted to single IP)
    -f OPENRC_FILE to source
    -p Ports to open, as array (e.g. -p "22,80,443")
    -n Email address to notify upon changes when updating (via mailx). Several can be specified, separated by commas, no space.

EOH
}

function get_raw_rules() {
    echo -e "$(nova secgroup-list-rules $SECGROUP_NAME)"
}

function log() {
    echo -e "$(date) $1" |tee -a $LOG
}

function send_email() {
    cat $LOG | mail -s "$1" "$EMAIL"
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
while getopts "s:d:i:f:p:n:arluh" opt; do
    case $opt in
        s)
            SECGROUP_NAME=$OPTARG
            log "Security group passed in : $SECGROUP_NAME"
            ;;
        d)
            opt_dns=true
            $opt_ip && log "IP option already specified. Specify either an IP or DNS." && exit 3
            DNS2WL=$OPTARG
            log "DNS domain passed in : $DNS2WL"
            ;;
        i)
            opt_ip=true
            $opt_dns && log "DNS option already specified. Specify either an IP or DNS." && exit 3
            IP2WL=$OPTARG
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
        u)
            SECGROUP_ACTION="update"
            ;;
        f)
            OPENRC_FILE=$OPTARG
            log "Will source file $OPENRC_FILE"
            source $OPENRC_FILE
            ;;
        p)
            PORTS="$OPTARG"
            log "Will act on ports \"$PORTS\""
            ;;
        n)
            EMAIL="$OPTARG"
            log "Will send notification to $EMAIL"
            ;;
        h)
            show_help
            exit 1
            ;;
        :)
            log "Option -$OPTARG needs an argument"
            exit 1
            ;;
        *)
            log "Not an option here"
            exit 1
            ;;
    esac
done

[[ ! -z $DNS2WL ]] && IP2WL=`host ${DNS2WL} | awk '/has address/ { print $4 }'`
IP2WL=${IP2WL}/32
[[ ! -z $DNS2WL ]] && IPv6WL=`host ${DNS2WL} | awk '/has IPv6 address/ { print $5 }'`
IPv6WL=${IPv6WL}/64
log "\n--\nSourced file: $OPENRC_FILE\nSecGroup: $SECGROUP_NAME\nIPv4 to whitelist: $IP2WL\nIPv6 to whitelist: $IPv6WL\nAction: $SECGROUP_ACTION\n--\n"

case $SECGROUP_ACTION in
    list)
        log "$(get_raw_rules)"
        ;;

    delete)
        log "Deleting rules in security group $SECGROUP_NAME in 5 seconds. Ctrl-C to stop."
        sleep 5
        # will delete all existing rules, clear table. only 1 home right?
        RAW_RULES="$(get_raw_rules)"
        while read -r line; do
            read from_port to_port ip_addr <<< $(echo "$line")
            nova secgroup-delete-rule $SECGROUP_NAME tcp $from_port $to_port $ip_addr |tee -a $LOG
        done <<< "$(echo -e "$RAW_RULES" | awk '/\| tcp/ {print $4,$6,$8}')"
        ;;

    add)
        for port in ${PORTS[@]}; do
            nova secgroup-add-rule $SECGROUP_NAME tcp $port $port ${IP2WL} |tee -a $LOG
            if [ ! -z $IPv6WL ]; then
                nova secgroup-add-rule $SECGROUP_NAME tcp $port $port ${IPv6WL} |tee -a $LOG
            fi
        done
        ;;

    update)
        RAW_RULES="$(get_raw_rules)"
        IS_CHANGED=false

        log "Going over rules to detect change in IP address..."
        while read -r line; do
            read from_port to_port ip_addr <<< `echo "$line"`
            if [ "$ip_addr" != "" ] && [ [ "$ip_addr" != "$IP2WL" ] || [ "$ip_addr" != "$IPv6WL" ] ]; then
                IS_CHANGED=true
                log "IP in security group ($ip_addr) is different than IP to whitelist ($IP2WL). Deleting and re-adding rule."
                nova secgroup-delete-rule $SECGROUP_NAME tcp $from_port $to_port $ip_addr |tee -a $LOG
                nova secgroup-add-rule $SECGROUP_NAME tcp $from_port $to_port ${IP2WL} |tee -a $LOG
            fi
        done <<< "$(echo -e "$RAW_RULES" | awk '/\| tcp}/ {print $4,$6,$8}')"
        log "Done updating rules."
        $IS_CHANGED && send_email "$SECGROUP_NAME rules updated" 
        ;;
esac
