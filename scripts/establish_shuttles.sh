#!/bin/bash

# Fred Blaise
# 2017-11-06
# Minimalist script to establish connections with sshuttle

USER=

if [[ "$1" == "emea" ]]; then
	JUMPHOST=
elif [[ "$1" == "us" ]]; then
	JUMPHOST=
else
	echo "Wrong parameter" && exit -1
fi

[[ -z $USER ]] && echo "Please fill in the variables." && exit -1

# Kill shuttles if exists, to keep things clean.
pkill sshuttle

# for docker
# sshuttle -l 172.17.0.1 -r ${USER}@${JUMPHOST} 10.36.0.0/16 &

NETS="10.36.0.0/16 192.168.168.0/24 192.168.172.0/24 192.168.182.0/24 192.168.178.0/24 10.37.0.0/16 10.40.0.0/16 6.0.0.0/8 10.3.28.0/24 10.1.254.0/24 172.29.0.0/16"
sshuttle --pidfile=/tmp/sshuttle.pid -D -r ${USER}@${JUMPHOST} $NETS
# NETS=( 10.36.0.0/16 192.168.168.0/24 192.168.172.0/24 10.37.0.0/16 10.40.0.0/16 6.0.0.0/8 10.3.28.0/24 10.1.254.0/24 172.29.0.0/16 )
# for i in ${NETS[@]}; do 
# 	cmd="sshuttle -D -r ${USER}@${JUMPHOST} $i"
# 	echo "Launching $cmd"
# 	$($cmd)
# done
