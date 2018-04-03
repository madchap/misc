#!/bin/bash

set -eux
 
cleanup() {
        # kill http server
        kill $pypid
	# _owncloud start
}

_owncloud() {
	if [ "$1" == "stop" ]; then
		docker stop owncloud
	elif [ "$1" == "start" ]; then
		docker start owncloud
	fi
}

trap cleanup INT TERM EXIT
 
wwwdir=/var/www/html

# _owncloud stop
 
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
certbot renew --post-hook "/root/certbot/cp_owncloud_certs.sh"

# _owncloud start
