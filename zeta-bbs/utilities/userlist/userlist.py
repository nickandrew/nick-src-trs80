#!/usr/bin/env python3
"""Decode a userfile."""

import argparse
from dataclasses import dataclass
import datetime
import struct

@dataclass
class UserRecord:
    status: int
    name: str
    passwd: str
    uid: int
    ncalls: int
    lastcall: datetime.date
    priv1: int
    priv2: int
    priv3: int
    tdata: int
    regcount: int
    badlogin: int
    tflag1: int
    tflag2: int
    erase: int
    kill: int


def show_file(filename: str):
    with open(filename, 'rb') as ifp:
        data = ifp.read()
    rec_len = 56
    data_len = len(data)

    # Skip the first 256 bytes of the file, and 256 bytes after each 256 records
    index = 0
    count = 0

    while index < data_len:
        if count % 256 == 0:
            # Skip 256 bytes here
            index += 256
        buf = data[index:index+rec_len]
        index += rec_len
        count += 1

        uf_status, uf_name, uf_passwd, uf_uid, uf_ncalls, uf_lastcall, uf_priv1, uf_priv2, uf_priv3, uf_tdata, uf_regcount, uf_badlogin, uf_tflag1, uf_tflag2, uf_erase, uf_kill, uf_nothing = struct.unpack('<B24s13sHH3sBBBBBBBBBBB', buf)
        if uf_status & 0x40 == 0:
            # Record not in use
            continue
        if uf_status & 0x20 != 0:
            # Fake username or rude disconnection
            continue

        # Fix the data
        uf_name = uf_name.decode('ascii').strip('\x00')
        uf_passwd = uf_passwd.decode('ascii').strip('\x00')
        uf_lastcall = datetime.date(year=uf_lastcall[2] + 1900, month=uf_lastcall[1], day=uf_lastcall[0])
        # print(uf_status, uf_name, uf_passwd, uf_uid, uf_ncalls, uf_lastcall)
        ur = UserRecord(uf_status, uf_name, uf_passwd, uf_uid, uf_ncalls, uf_lastcall, uf_priv1, uf_priv2, uf_priv3, uf_tdata, uf_regcount, uf_badlogin, uf_tflag1, uf_tflag2, uf_erase, uf_kill)
        print('{:02x} {:24s} {:13s} {} {:5d} {:02x} {:02x}'.format(
            uf_status,
            uf_name,
            uf_passwd,
            uf_lastcall,
            uf_ncalls,
            uf_priv1,
            uf_priv2,
        ))

def main():
    parser = argparse.ArgumentParser(description='Decode a userfile')
    parser.add_argument('filename', help='Filename to decode')
    args = parser.parse_args()

    show_file(args.filename)

if __name__ == '__main__':
    main()

