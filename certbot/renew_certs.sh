#!/bin/bash

set -ex
 
cleanup() {
        # kill http server
        kill $pypid
	# _owncloud start
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

trap cleanup INT TERM EXIT
 
wwwdir=/var/www/html

_restart_container stop nginx
 
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
/usr/bin/certbot renew --post-hook "/root/certbot/cp_owncloud_certs.sh"

_restart_container start nginx
