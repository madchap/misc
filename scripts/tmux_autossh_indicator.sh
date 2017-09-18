#!/bin/bash

set -e

NUM_OF_AUTOSSH=0
NUM_OF_AUTOSSH=$(ps -ef |grep "autossh -" |grep -v grep |wc -l)
echo "🚞$NUM_OF_AUTOSSH"

