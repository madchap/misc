#!/bin/bash

echo "This will create a 512M swapfile under /... you have 10 seconds to Ctrl-C out of this... No check will be done."
sleep 10
echo "Let's go."

SWAPFILE=/swapfile

echo "Zero'ing swapfile."
dd if=/dev/zero of=$SWAPFILE bs=1024 count=524288
echo "Adjusting permissions."
chown root:root $SWAPFILE
chmod 0600 $SWAPFILE
echo "Turning on swap."
mkswap $SWAPFILE
swapon $SWAPFILE

echo "Including in fstab"
echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab

echo
echo "Done. Checking now."
swapon -s
