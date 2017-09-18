#!/bin/bash

set -e

NUM_OF_KEYS=0
NUM_OF_KEYS=$(ssh-add -l |wc -l)
echo "🔑$NUM_OF_KEYS"

