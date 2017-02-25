sudo snapper -c home create-config /home
sudo snapper -c home set-config "NUMBER_CLEANUP=no"
sudo snapper -c home set-config "NUMBER_LIMIT=0"
sudo snapper -c home set-config "NUMBER_LIMIT_IMPORTANT=0"
sudo snapper -c home set-config "TIMELINE_LIMIT_DAILY=7"
sudo snapper -c home set-config "TIMELINE_LIMIT_HOURLY=24"
sudo snapper -c home set-config "TIMELINE_LIMIT_WEEKLY=2"
sudo snapper -c home set-config "TIMELINE_LIMIT_MONTHLY=0"
sudo snapper -c home set-config "TIMELINE_LIMIT_YEARLY=0"
sudo snapper -c home set-config "SPACE_LIMIT=0.2"
sudo snapper -c home get-config
sudo snapper -c home list
