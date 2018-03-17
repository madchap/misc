# allow synergy to connect thru firewalld                       
sudo firewall-cmd --zone=public --add-port=24800/udp --permanent
sudo firewall-cmd --zone=public --add-port=24800/tcp --permanent
