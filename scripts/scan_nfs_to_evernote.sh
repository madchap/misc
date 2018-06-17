#!/bin/bash
set -euo pipefail

# geeknote used is https://github.com/jeffkowalski/geeknote

geeknote=/usr/bin/geeknote
tesseract=$(which tesseract)
tag_triage="triage"
notebook="Main"
logfile=/home/fblaise/evernote_upload.log
# crontab and value here must correlate with the scan_max_value
# example: cron every 5mn, diff between scan_max_value and scan_min_value should be 300 secs.
# the delta is here to avoid picking up on not fully written files yet, as scanning a remote nfs folder (i.e. lsof -N) is not working in my case.
# in seconds
scan_max_value=315
scan_min_value=15
# nfs_server="192.168.10.25"
# nfs_export_point="/Scans"
scan_point="/exports/scans"
email_to="xxxxxxxxxx"
evernote_email="xxxxxxxxxx"

log_it() {
	msg=$1
	echo "`date`: $msg" | tee -a $logfile
}

check_nfs_mount() {
	count=1
	nfs_ok=1

	while [[ $count -le 2 ]] && [[ $nfs_ok -eq 1 ]] ; do
		local fs=$(stat -f -L -c %T ${scan_point})
		if [ "$fs" != "nfs" ]; then
			log_it "NFS not mounted (fs indicated $fs). Attempting now (Attempt $count)."
			nfsoutput=$(sudo mount -t nfs ${nfs_server}:${nfs_export_point} ${scan_point})
			if [ $? -ne 0 ]; then
				send_email "Geeknote scan: NFS refused to mount" "$nfsoutput"
			fi
		else
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

tesseract_file() {
	log_it "Tesseract'ing file."
	filename_fullpath=$1
	filename_noext=$2
	$tesseract "$filename_fullpath" -l fra+eng -psm 3 ${scan_point}/${filename_noext} pdf |tee -a $logfile

	log_it "Tesseract return code is $?"
}

clean_tesseract_temp_files() {
	log_it "Cleaning up temp files."
	rm -f $scan_point/*.txt $scan_point/*.tif
}

# check_nfs_mount

# Look for file, pdf 
files=$(find ${scan_point} -type f -newermt "-${scan_max_value} seconds" -not -newermt "-${scan_min_value} seconds" \( -name '*.tif' -o -name '*.jpg' -o -name '*.pdf' \))
#[[ ${#files[@]} -eq 1 ]] && log_it "No new file found."

for file in ${files}; do
	log_it "Found file $file."

	file_fullpath=$file
	file_pathonly=${file%/*}
	file_nopath=${file##*/}
	filename_noext=${file_nopath%.*}
	filename_ext=${file##*.}
	
	if [ ${filename_ext} == "tif" ]; then
		# make it a searchable pdf
		tesseract_file $file_fullpath $filename_noext
		filename_ext="pdf"
	fi

	log_it "Sending to evernote via email..."
	echo "Sent via $0" | mail -s "${filename_noext} #${tag_triage} @${notebook}" -a "${file_pathonly}/${filename_noext}.${filename_ext}" "$evernote_email"
	send_email "Geeknote scan: New file(s) to be triaged" "You've got new file(s) that need to be triaged at https://www.evernote.com/Home.action"

done

clean_tesseract_temp_files

log_it "Done."
