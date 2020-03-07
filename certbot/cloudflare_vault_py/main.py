#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
import CloudFlare
import hvac
import json
import sys


def get_cf_token_from_vault():
    vc = hvac.Client(
        url='https://vault.darthgibus.net'
    )

    try:
        with open('token', 'r') as token:
            return token.readline().strip()
    except:
        print("No token file found.")

"""
    try:
        r = vc.secrets.kv.read_secret_version(path='cloudflare')
        cftoken = r['data']['data']['tower-dev']
        print(f'Value read: {cftoken}')
        return cftoken
    except Exception as e:
        print("Something is wrong: {}".format(e))
"""

def flip_dns_proxy(switch=True):
    zone_name = "darthgibus.net"
    zones = cf.zones.get(params={'name': zone_name})
    if len(zones) == 0:
        print("no zone found")
        sys.exit()
    # else:
    #    print(json.dumps(zones, indent=4, sort_keys=True))
    
    zone_id = zones[0]['id']
    print("Dealing with zone id {}".format(zone_id))

    try:
        dns_records = cf.zones.dns_records.get(zone_id)
        for dns in dns_records:
            records_to_process = ["pw", "q", "vault"]
            if dns['name'].split('.')[0] in records_to_process:
                print(json.dumps(dns, indent=4, sort_keys=True))
                print("Switching proxy state to {}".format(switch))
                dns['proxied'] = switch
                dns_record_id = dns['id']
                print(json.dumps(dns, indent=4, sort_keys=True))
                cf.zones.dns_records.patch(zone_id, dns_record_id, data=dns)

    except CloudFlare.exceptions.CloudFlareAPIError as e:
        exit("DNS records call failed {}".format(e))


if __name__ == "__main__":
    cftoken = get_cf_token_from_vault()
    cf = CloudFlare.CloudFlare(debug=False, token=cftoken)
    flip_dns_proxy(True)