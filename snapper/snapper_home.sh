echo "Moving ~/.cache to its own subvol"
sudo btrfs sub create /home/fblaise/.cache-sub
sudo chown fblaise: /home/fblaise/.cache-sub
rsync -a ~/.cache/* /home/fblaise/.cache-sub/
mv /home/fblaise/.cache /home/fblaise/.cache-old
mv /home/fblaise/.cache-sub /home/fblaise/.cache
sudo btrfs sub list /home

echo
echo "Setting up snapper for /home"
sudo snapper -c home create-config /home
sudo snapper -c home set-config "NUMBER_CLEANUP=no"
sudo snapper -c home set-config "NUMBER_LIMIT=0"
sudo snapper -c home set-config "NUMBER_LIMIT_IMPORTANT=0"
sudo snapper -c home set-config "TIMELINE_LIMIT_DAILY=7"
sudo snapper -c home set-config "TIMELINE_LIMIT_HOURLY=24"
sudo snapper -c home set-config "TIMELINE_LIMIT_WEEKLY=0"
sudo snapper -c home set-config "TIMELINE_LIMIT_MONTHLY=0"
sudo snapper -c home set-config "TIMELINE_LIMIT_YEARLY=0"
sudo snapper -c home set-config "SPACE_LIMIT=0.2"
sudo snapper -c home set-config "QGROUP=1/0"
sudo snapper -c home get-config
sudo snapper -c home list
