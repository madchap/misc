#!/bin/bash

gpg-connect-agent "DELETE_KEY 7E3A8A6A6F9653FA61DCDB72270BAF4949F001BB" /bye
gpg-connect-agent "DELETE_KEY 4A5B1994358AD9359D73C6C62CDD8B5D81B7E3AC" /bye
gpg --card-status >/dev/null
