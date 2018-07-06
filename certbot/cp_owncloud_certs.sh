# weechat relay
cat /etc/letsencrypt/live/q.darthgibus.net/privkey.pem /etc/letsencrypt/live/q.darthgibus.net/fullchain.pem > /home/fblaise/.weechat/ssl/relay.pem
# fifo into weechat
su - fblaise -c "echo '*/relay sslcertkey'" > /home/fblaise/.weechat/weechat_fifo
su - fblaise -c "echo '*/reload relay'" > /home/fblaise/.weechat/weechat_fifo

# owncloud.. 
cp -f /etc/letsencrypt/live/q.darthgibus.net/fullchain.pem /mnt/pydio/shares/owncloud/certs/ssl-cert.crt
cp -f /etc/letsencrypt/live/q.darthgibus.net/privkey.pem /mnt/pydio/shares/owncloud/certs/ssl-cert.key
docker exec owncloud /usr/sbin/apachectl restart
