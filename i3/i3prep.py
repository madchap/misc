#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# This script is a simple wrapper which prefixes each i3status line with custom
# information. It is a python reimplementation of:
# http://code.stapelberg.de/git/i3status/tree/contrib/wrapper.pl
#
# To use it, ensure your ~/.i3status.conf contains this line:
#     output_format = "i3bar"
# in the 'general' section.
# Then, in your ~/.i3/config, use:
#     status_command i3status | ~/i3status/contrib/wrapper.py
# In the 'bar' section.
#
# In its current version it will display the cpu frequency governor, but you
# are free to change it to display whatever you like, see the comment in the
# source code below.
#
# © 2012 Valentin Haenel <valentin.haenel@gmx.de>
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License (WTFPL), Version
# 2, as published by Sam Hocevar. See http://sam.zoy.org/wtfpl/COPYING for more
# details.

import re
import sys
import json
import netifaces
import subprocess
import pulsectl

def get_governor():
    """ Get the current governor for cpu0, assuming all CPUs use the same. """
    with open('/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor') as fp:
        return fp.readlines()[0].strip()

def get_vpnssl_status(iface):
    """ Get my vpnssl status """
    if iface in netifaces.interfaces():
        addr = netifaces.ifaddresses(iface)
        if len(addr) > 0:   # vpn0 remains in the array even when gone, for whatever reason. So check if there is anything in there.
            return True

    return False


def get_procs_count(proc_name):
    """ Returns number of procs """
    procs = subprocess.check_output(['ps','-ef']).splitlines()
    name_procs = [proc for proc in procs if proc_name.encode() in proc]
    return len(name_procs)


def get_sshuttle_args_count(proc_name):
    """ Returns number of subnets handled by sshuttle """
    procs = subprocess.check_output(['ps', '-eo', 'comm,args']).splitlines()
    name_procs = [proc for proc in procs if proc_name.encode() in proc]

    if len(name_procs) > 1:
        return -1
    elif len(name_procs) == 0:
        return 0
    else:
        nets = re.split('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,3}', name_procs[0])
        return len(nets)-1


def get_brightness():
    """ Returns brightness from file, as writter per xrandr.sh custom script """
    file = open ("/home/fblaise/.i3/scripts/backlight_p.out",'r')
    return "{}%".format(file.readline().strip())


def print_line(message):
    """ Non-buffered printing to stdout. """
    sys.stdout.write(message + '\n')
    sys.stdout.flush()


def read_line():
    """ Interrupted respecting reader for stdin. """
    # try reading a line, removing any extra whitespace
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    # exit on ctrl-c
    except KeyboardInterrupt:
        sys.exit()


def get_pulseaudio_source_status():
    # relies on the fact that all are toggled muted or not per key binding
    pulse = pulsectl.Pulse('i3bar')
    # 1 when muted, 0 when not muted
    is_muted = pulse.source_list()[0].mute
    pulse.close()
    if is_muted:
        return "Muted"
    else:
        return "On Air"


if __name__ == '__main__':
    # Skip the first line which contains the version header.
    print_line(read_line())

    # The second line contains the start of the infinite array.
    print_line(read_line())

    while True:
        line, prefix = read_line(), ''
        # ignore comma at start of lines
        if line.startswith(','):
            line, prefix = line[1:], ','

        j = json.loads(line)
        # insert information into the start of the json, but could be anywhere
        # CHANGE THIS LINE TO INSERT SOMETHING ELSE
        #j.insert(0, {'full_text' : '%s' % get_governor(), 'name' : 'gov'})
        if get_vpnssl_status("ppp0") or get_vpnssl_status("vpn0") or get_vpnssl_status("tun0") or get_vpnssl_status("wg0"):
            vpn_color = '#00ff00'
            vpn_icon = ""
        else:
            vpn_color = '#ffff00'
            vpn_icon = ''
        
        j.insert(0, {'full_text': ' %s' % get_procs_count('pinentry'), 'name': 'pinentry'})
        j.insert(1, {'full_text': '%s' % vpn_icon, 'name': 'vpnssl', 'color': vpn_color})
        j.insert(2, {'full_text': ' %s' % get_sshuttle_args_count('sshuttle --pidfile=/tmp/sshuttle.pid -D -r'), 'name': 'sshuttle'})
        j.insert(3, {'full_text': ' %s' % get_procs_count('autossh -'), 'name': 'autossh'})
        j.insert(4, {'full_text': '🎙%s' % get_pulseaudio_source_status(), 'name': 'pa_source'})
        # j.insert(4, {'full_text': ' %s' % get_brightness(), 'name': 'brightness'})
        # and echo back new encoded json
        print_line(prefix+json.dumps(j))
