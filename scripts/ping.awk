#!/usr/bin/awk -f
#
# Taken from https://gist.github.com/somic/712175

# analyzes ping output on Linux and looks for missed returns
# based on icmp_seq
#
# ping output is expected on stdin
#

BEGIN { num = 0 }
$5 ~ /icmp_seq=/ {
    split($5, res, /=/);
    if (res[2] != num + 1) {
        print "missed between", num, "and", res[2] }
    num = res[2];
}

