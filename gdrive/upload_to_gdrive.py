#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4

import argparse
import os
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import random
import time
import smtplib

# Import the email modules we'll need
from email.mime.text import MIMEText


def gdrive_auth():
    gauth = GoogleAuth()
    pydrive_creds = "/secrets/pydrive_creds.txt"

    gauth.LoadCredentialsFile(pydrive_creds)
    if gauth.credentials is None:
        gauth.LocalWebserverAuth()
        action = "Logged in"
    elif gauth.access_token_expired:
        gauth.Refresh()
        action = "Refreshed"
    else:
        gauth.Authorize()
        action = "Authorized"

    gauth.SaveCredentialsFile(pydrive_creds)

    print("{} Google Drive.".format(action))

    return GoogleDrive(gauth)


def send_email(filename):
    msg = MIMEText("Please seek the #triage tag")
    msg['Subject'] = "File {} was uploaded".format(filename)
    msg['From'] = "binarydude1010@gmail.com"
    msg['To'] = "fred.blaise@gmail.com"

    s = smtplib.SMTP('192.168.10.206')
    s.send_message(msg)
    s.quit()


def get_top_parent_folder_id(parentfolder):
    global drive

    file_list = drive.ListFile({'q': "'root' in parents and trashed=false"}).GetList()
    for file_folder in file_list:
        if file_folder['title'] == parentfolder:
            return file_folder['id']


def log_message(**kwargs):
    to_print = "[{}] {}".format(time.ctime(), kwargs['message'])
    print(to_print)


def upload(filename, parentfolder):
    global drive

    parentfolder_id = get_top_parent_folder_id(parentfolder)
    if parentfolder_id is None:
        print("Houston, we have a problem. The top folder parent does not exist. Aborting mission.")
        raise SystemExit

    short_filename = os.path.basename(os.path.normpath(filename))
    short_title = short_filename

    log_message(message="Top parent ID is {}".format(parentfolder_id))
    f = drive.CreateFile({"parents": [{"kind": "drive#fileLink", "id": parentfolder_id}]})
    f.SetContentFile(filename)

    f['title'] = short_title
    f['description'] = "tags: {}".format('#triage')

    max_retries = 10
    retries = 0
    is_success = False
    while max_retries > retries and not is_success:
        try:
            log_message(message="Uploading {}".format(f['title']))
            f.Upload()
            is_success = True
            send_email(short_filename)
        except Exception as upload_e:
            retries += 1
            log_message(message="Exception trying to upload to Gdrive. Error {}".format(upload_e.message))
            log_message(message="Sleeping a bit and retrying..")
            time.sleep(random.uniform(5, 10))  # backoff a bit to avoid being cut off
            drive = gdrive_auth()
            log_message(message="Retrying upload of {}".format(f['title']))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--filename', help="Full path (or docker related path) to the file to upload.")
    parser.add_argument('--parentfolder', default='docs_archives', help='Default to docs_archives at google drive\'s root')
    args = parser.parse_args()

    drive = gdrive_auth()
    upload(args.filename, args.parentfolder)
