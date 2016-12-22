#!/bin/bash

#   FBI - 10.06.2016
#   Basic script to dynamically update home IP address in particular Openstack SecurityGroup based on dynamicDNS result
#   Only TCP ports for now, single IP.

#   tag v0.1 uses nova client
#   tag v0.2 uses openstack client

export SHELL=/bin/bash
export PATH=$PATH:/usr/local/bin

LOG=/tmp/`basename $0`.log
echo > $LOG

# BEGIN defaults VARIABLES ###
SECGROUP_ACTION="list"
PORTS=( )

### END VARIABLES ###

function show_help() {
cat << EOH
Usage: ${0##*/} [-s SECGROUP_NAME] [ [-d DNSNAME] or [-i IPADDR]] [-f OPENRC_FILE] [-p PORTS] [-n EMAIL] [-arlu]

This script works with IPv4 (/32) and IPv6 (/64). It was written for a home usage, with a single IPv4 and single IPv6 in mind and dynamic DNS. Use at your own risk, I am a sh*! programmer ^^

    -a Add to SECGROUP_NAME
    -r Remove from SECGROUP_NAME
    -l List from SECGROUP_NAME [default]
    -u Reads current rules and updates it if needed. It will delete a rule if it cannot find a correspondance, but never add.

    -s Security group to act on
    -i Single IP address to act on (v4 or v6, do not specify mask)
    -d DNS domain to resolve (will be converted to single IPv4 and single IPv6 if any)
    -f OPENRC_FILE to source
    -p Ports to open, as array (e.g. -p "22 80 443")
    -n Email address to notify upon changes when updating (via mailx). Several can be specified, separated by commas, no space.

EOH
}

function get_raw_rules() {
    echo -e "$(openstack security group rule list $SECGROUP_NAME)"
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

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
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
            if valid_ip $OPTARG; then
                IP2WL=$OPTARG
            else
                IPv6WL=$OPTARG
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
        u)
            SECGROUP_ACTION="update"
            ;;
        f)
            OPENRC_FILE=$OPTARG
            log "Will source file $OPENRC_FILE"
            source $OPENRC_FILE
            ;;
        p)
            PORTS=( $OPTARG )
            log "Will act on ports \"${PORTS[*]}\""
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

[[ ! -z $DNS2WL ]] && HOSTOUTPUT=$(host ${DNS2WL})
[[ ! -z $DNS2WL ]] && IP2WL=$(echo "$HOSTOUTPUT" | awk '/has address/ { print $4 }')
[[ ! -z $IP2WL ]] && IP2WL=${IP2WL}/32
[[ ! -z $DNS2WL ]] && IPv6WL=$(echo "$HOSTOUTPUT" | awk '/has IPv6 address/ { print $5 }')
[[ ! -z $IPv6WL ]] && IPv6WL=${IPv6WL}/64

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
            read rule_id <<< $(echo "$line")
            openstack security group rule delete  |tee -a $LOG
        done <<< "$(echo -e "$RAW_RULES" | awk '/tcp/ {print $2}')"
        ;;

    add)
        for port in "${PORTS[@]}"; do
	    openstack security group rule create FBI-home --proto tcp --src-ip ${IP2WL} --dst-port $port |tee -a $LOG
            if [ ! -z $IPv6WL ]; then
                openstack security group rule create FBI-home --proto tcp --src-ip ${IPv6WL} --dst-port $port |tee -a $LOG
            fi
        done
        ;;

    update)
        RAW_RULES="$(get_raw_rules)"
        IS_CHANGED=false

        log "Going over existing rules to detect change in IP address... will not add new ports. Use 'add' for that."
        while read -r line; do
            # sometimes empty.. ?
            [[ -z $line ]] && continue

            read rule_id ip_addr ports <<< `echo "$line"`
            target_port=${ports#:*}

            # Dealing with ipv4
            if valid_ip "$ip_addr"; then
                NEWIP=$IP2WL
            
            # dirty, must be IPv6 .. any of them can be empty if override with -i
            else
                NEWIP=$IPv6WL
            fi

            if [ "$NEWIP" != "" ]; then
                if [ "$ip_addr" != "$NEWIP" ]; then
                    IS_CHANGED=true
                    log "IP in security group ($ip_addr) is different than IP to whitelist ($NEWIP). Deleting and re-adding rule."
                    openstack security group rule delete $rule_id |tee -a $LOG
                    openstack security group rule create FBI-home --proto tcp --src-ip ${NEWIP} --dst-port $target_port |tee -a $LOG
                fi
            else
                # prevent deletion if -i switch was used
                if ! $opt_ip; then
                    log "IP $ip_addr not found anymore. Deleting from the ruleset."
                    openstack security group rule delete $rule_id |tee -a $LOG
                fi
            fi
        done <<< "$(echo -e "$RAW_RULES" | awk '/tcp/ {print $2,$6,$8}')"
        log "Done updating rules."
        $IS_CHANGED && send_email "$SECGROUP_NAME rules updated"
        ;;
esac
