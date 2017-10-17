#!/bin/bash
set -eux

[[ "$#" -ne 2 ]] && echo "Enter a username and domain to proceed, in this order, separated by space." && exit 1

USERNAME=$1
DOMAIN=$2
OVPN_DATA=ovpndata
CIPHER=AES-256-CBC
CONTAINER_NAME=openvpn

# create docker volume
docker volume create --name $OVPN_DATA

# gen server config
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://$DOMAIN -2 -C $CIPHER

# init
docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

# run server
docker run --name "$CONTAINER_NAME" -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn

# gen client certificate
docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full $USERNAME nopass

# get client config
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient $USERNAME > $USERNAME.ovpn

# gen auth config for client
docker run -v $OVPN_DATA:/etc/openvpn --rm -t kylemanna/openvpn ovpn_otp_user $USERNAME

# generate OTP -- will be shown in terminal, and will have a link too.
google-authenticator --time-based --disallow-reuse --force --rate-limit=3 --rate-time=30 --window-size=3 \
    -l "${USERNAME}@${DOMAIN}" -s ${USERNAME}.google_authenticator
docker cp ${USERNAME}.google_authenticator ${CONTAINER_NAME}:/etc/openvpn/otp/

# append duplicate-cn to be able to logon with cell and laptop using the same cn..
echo "duplicate-cn" >> /var/lib/docker/volumes/${OVPN_DATA}/_data/openvpn.conf
