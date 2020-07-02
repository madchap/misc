#!/bin/bash

gpg-connect-agent "DELETE_KEY 5B58D60387951865B80EC12DD6ECA3C9A2598F62" /bye
gpg-connect-agent "DELETE_KEY E5B7CD9417ED2732C3D64AE2E3AE90B4CA49C666" /bye
gpg --card-status >/dev/null
