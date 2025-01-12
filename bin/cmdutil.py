#!/usr/bin/env python3
"""CMD file utility"""

from dataclasses import dataclass

import argparse
import re
import sys

import cmdfile

def parse_cmdfile(filename: str):
    for record in cmdfile.records(filename):
        if record.address is not None:
            address = f'{record.address:04x}'
        else:
            address = 'None'

        data = ''
        if record.data:
            sl = record.data[0:20]
            data = ' [' + ','.join(f'{a:02x}' for a in sl)
            if len(record.data) > 20:
                data += ', ...]'
            else:
                data += ']'

        print(f'Type: {record.record_type:02x} size {record.size:02x} address {address}{data}')

def main():
    parser = argparse.ArgumentParser(description='CMD file utility')
    parser.add_argument('function', help='Function (parse)')
    parser.add_argument('filename', help='Filename to be read')
    args = parser.parse_args()

    if args.function == 'parse':
        parse_cmdfile(args.filename)

if __name__ == '__main__':
    main()
