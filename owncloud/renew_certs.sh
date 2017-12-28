#!/bin/bash
set -eux

# Start python simple server on port 80 for letsencrypt check
cd /var/www/html
python -m SimpleHTTPServer 80 &
pypid=$!

# invoking certbot
# full
# certbot certonly --webroot -w /var/www/html -d domain_name
# renew
certbot renew --post-hook "/root/certbot/cp_owncloud_certs.sh" 

# kill http server
kill $pypid
