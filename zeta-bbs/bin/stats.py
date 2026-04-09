#!/usr/bin/env python3
"""Decode STATS.ZMS files. Output in JSON."""

import argparse
import json

def getstats(filename: str):
    with open(filename, 'rb') as ifp:
        buf = ifp.read()
    stats = {
        'total_calls': buf[0] + buf[1] * 0x100,
        'logged_in': buf[2] + buf[3] * 0x100,
        'no_login': buf[4] + buf[5] * 0x100,
        'no_carrier': buf[6] + buf[7] * 0x100,
        'non_member': buf[8] + buf[9] * 0x100,
        'disconnected': buf[10] + buf[11] * 0x100,
        'packets_rcvd': buf[12] + buf[13] * 0x100,
        'packets_sent': buf[14] + buf[15] * 0x100,
    }

    return stats


def main():
    parser = argparse.ArgumentParser(description='Decode STATS.ZMS files. Output in JSON.')
    parser.add_argument('files', nargs='+', help='STATS.ZMS filenames')
    args = parser.parse_args()

    print('{:50s} | {:11s} | {:9s} | {:8s} | {:10s} | {:10s} | {:12s} | {:12s} | {:12s}'.format(
        'filename',
        'total_calls',
        'logged_in',
        'no_login',
        'no_carrier',
        'non_member',
        'disconnected',
        'packets_rcvd',
        'packets_sent',
    ))

    for filename in args.files:
        r = getstats(filename)
        print('{:50s} | {:11d} | {:9d} | {:8d} | {:10d} | {:10d} | {:12d} | {:12d} | {:12d}'.format(
            filename,
            r['total_calls'],
            r['logged_in'],
            r['no_login'],
            r['no_carrier'],
            r['non_member'],
            r['disconnected'],
            r['packets_rcvd'],
            r['packets_sent'],
        ))


if __name__ == '__main__':
    main()
