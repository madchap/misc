#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4

from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import argparse


def gdrive_auth():
    gauth = GoogleAuth()

    # Try to load saved client credentials in current folder
    gauth.LoadCredentialsFile("pydrive_creds.txt")
    if gauth.credentials is None:
        gauth.LocalWebserverAuth()
        action = "Logged in"
    elif gauth.access_token_expired:
        gauth.Refresh()
        action = "Refreshed"
    else:
        gauth.Authorize()
        action = "Authorized"

    gauth.SaveCredentialsFile("pydrive_creds.txt")

    print("{} Google Drive.").format(action)

    return GoogleDrive(gauth)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--filename', help="Full path to the file to upload.")

    args = parser.parse_args()
