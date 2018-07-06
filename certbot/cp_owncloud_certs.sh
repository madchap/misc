cp -f /etc/letsencrypt/live/q.darthgibus.net/fullchain.pem ssl-cert.crt
cp -f /etc/letsencrypt/live/q.darthgibus.net/privkey.pem ssl-cert.key

docker exec owncloud /usr/sbin/apachectl restart
