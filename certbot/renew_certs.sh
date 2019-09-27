#!/bin/bash

set -ex
 
cleanup() {
        # kill http server
        kill $pypid
        _restart_container start nginx-rp
}

_restart_container() {
	# $1 action
	# $2 container name

	if [ "$1" == "stop" ]; then
		docker stop $2
	elif [ "$1" == "start" ]; then
		docker start $2
	fi
}

send_alert() {
        to="xxx@gmail.com"
        echo "Sending alert to $to"

        subject="Problem with cert renewal"
        body="The $0 had issues with some certs renewal. Please check.\r\n\r\n"
        body+=$(cat $log)

        echo "$body" |mail -s "$subject" $to
}

trap cleanup INT TERM EXIT
 
wwwdir=/var/www/html
log=/tmp/cert_renewal.log
exec > >(tee $log) 2>&1

_restart_container stop nginx-rp
 
# Start python simple server on port 80 for letsencrypt check
[[ -d $wwwdir ]] || mkdir -p $wwwdir
cd $wwwdir
python -m SimpleHTTPServer 80 &
pypid=$!
 
sleep 5
 
# invoking certbot
# full -- not done automatically. Do the initial certs at least once.
# certbot certonly --webroot -w $wwwdir -d logstash.cyberfusion.center
# renew
/usr/bin/certbot renew --post-hook "/root/certbot/cp_certs.sh" || send_alert

