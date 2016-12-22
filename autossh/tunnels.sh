#!/bin/bash

P="SSH tunnels: "

case "$1" in
        "start")
                logger "$P Reverse 3000:localhost:3000 autossh@jh"
                /usr/bin/autossh -M 0 -f -NR 3000:localhost:3000 autossh@jh
                logger "$P Reverse 3001:localhost:8080 autossh@jh"
                /usr/bin/autossh -M 0 -f -NR 3001:localhost:8080 autossh@jh
                logger "$P Reverse 3002:localhost:8083 autossh@jh"
                /usr/bin/autossh -M 0 -f -NR 3002:localhost:8083 autossh@jh
                logger "$P Reverse 3003:localhost:8086 autossh@jh"
                /usr/bin/autossh -M 0 -f -NR 3003:localhost:8086 autossh@jh
                logger "$P Reverse 3004:localhost:9090 autossh@jh"
                /usr/bin/autossh -M 0 -f -NR 3004:localhost:9090 autossh@jh
                ;;
        "stop")
                logger "$P Killing all autossh tunnels"
                /usr/bin/pkill -9 autossh
                ;;
        "*")
                logger "$P Unrecognized parameter"
                ;;
esac

