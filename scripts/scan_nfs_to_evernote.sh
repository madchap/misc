#!/bin/bash

geeknote=/usr/bin/geeknote
tag_triage="triage"
notebook="Main"
logfile=/home/fblaise/evernote_upload.log
# crontab and value here must correlate with the scan_max_value
# example: cron every 5mn, diff between scan_max_value and scan_min_value should be 300 secs.
# the delta is here to avoid picking up on not fully written files yet, as scanning a remote nfs folder (i.e. lsof -N) is not working in my case.
# in seconds
scan_max_value=315
scan_min_value=15
scan_point="/home/fblaise/nfs/scans"
email_to="fred.blaise@gmail.com"


log_it() {
	msg=$1
	echo "`date`: $msg" | tee -a $logfile
}

check_nfs_mount() {
	log_it "Checking NFS mount."
	count=1
	nfs_ok=1

	while [[ $count -le 3 ]] && [[ $nfs_ok -eq 1 ]] ; do
		local fs=$(stat -f -L -c %T ${scan_point})
		if [ "$fs" != "nfs" ]; then
			log_it "NFS not mounted. Attempting now (Attempt $count)."
			sudo mount -t nfs 192.168.10.25:/Scans /home/fblaise/nfs/scans
		else
			log_it "NFS mount OK."
			nfs_ok=0
		fi
		((count++))
	done
}

send_email() {
	subject=$1
	body=$2

	echo "$body" | mail -s "$subject" "$email_to"
}

log_it "Starting." 
log_it "Upper and lower time limits on file to search: $scan_max_value $scan_min_value"
log_it "Scan point: $scan_point"

check_nfs_mount

# Look for file
files=$(find ${scan_point} -type f -newermt "-${scan_max_value} seconds" -not -newermt "-${scan_min_value} seconds")

[[ ${#files[@]} -eq 1 ]] && log_it "No new file found."

for file in ${files}; do
	log_it "Found file $file. Uploading..."
	# upload via geeknote
	$geeknote create --title "${file##*/}" --resource "$file" --content "" --tag "${tag_triage}" --notebook ${notebook} >> $logfile
	if [ $? -ne 0 ]; then
		log_it "Error $? when trying to upload file."
		send_email "Geeknote scan error" "$(tail -n100 $logfile)"
	else
		log_it "Ok, file uploaded."
		send_email "Evernote: New files to be triaged" "You've got new files that need to be triaged."
	fi
done
