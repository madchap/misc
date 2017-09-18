#!/bin/bash

set -e

$(ip addr |grep -q ppp0)
[[ "$?" == 0 ]] && echo "🛡️ "
