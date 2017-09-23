#!/bin/bash

set -e

NUM_OF_KEYS=0
NUM_OF_KEYS=$(ssh-add -l |grep -v "has no identities" |wc -l)
echo "🔑$NUM_OF_KEYS"

