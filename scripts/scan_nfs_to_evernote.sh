#!/bin/bash
set -eo pipefail

# geeknote used is https://github.com/jeffkowalski/geeknote

geeknote=/usr/bin/geeknote
tesseract=$(which tesseract)
upload_to_gdrive="docker run --rm --name=scanner-uploader -v $(dirname $0)/gdrive/secrets:/secrets -v /exports/scans:/docs:ro madchap/gdrive-scanner-upload:0.1"
tag_triage="triage"
notebook="Main"
logfile=/home/fblaise/evernote_upload.log
# scan_max_value=315
scan_min_value=15
# nfs_server="192.168.10.25"
# nfs_export_point="/Scans"
scan_point="/exports/scans"
email_to=""
evernote_email=""

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

[[ -z "$1" ]] && echo "Need a target platform: evernote or gdrive, or both." && exit -1
target_platform=$1

# check_nfs_mount

# Look for file, pdf
# files=$(find ${scan_point} -maxdepth 1 -type f -newermt "-${scan_max_value} seconds" -not -newermt "-${scan_min_value} seconds" \( -name '*.tif' -o -name '*.jpg' -o -name '*.pdf' \))
files=$(find ${scan_point} -maxdepth 1 -type f -not -newermt "-${scan_min_value} seconds" \( -name '*.tif' -o -name '*.jpg' -o -name '*.pdf' \))
#[[ ${#files[@]} -eq 1 ]] && log_it "No new file found."
processed_directory=${scan_point}/processed
[[ ! -d $processed_directory ]] && mkdir $processed_directory

something_is_processed=0
for file in ${files}; do
	log_it "Found file $file."
    something_is_processed=1

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

	if [[ "$target_platform" == "evernote" ]] || [[ "$target_platform" == "both" ]]; then
	    log_it "Sending to evernote via email..."
	    echo "Sent via $0" | mail -s "${filename_noext} #${tag_triage} @${notebook}" -a "${file_pathonly}/${filename_noext}.${filename_ext}" "$evernote_email"
	    # send_email "Geeknote scan: New file(s) to be triaged" "You've got new file(s) that need to be triaged at https://www.evernote.com/Home.action"
	fi

	if [[ "$target_platform" == "gdrive" ]] || [[ "$target_platform" == "both" ]]; then
	    log_it "Sending to google drive..."
	    $upload_to_gdrive --filename /docs/${filename_noext}.${filename_ext}
	fi
	
	something_is_processed=1
	mv "${file_pathonly}/${filename_noext}.${filename_ext}" $processed_directory

done

[[ $something_is_processed -eq 1 ]] && clean_tesseract_temp_files && echo "Done."
