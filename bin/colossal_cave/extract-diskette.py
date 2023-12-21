#!/usr/bin/env python3
"""Extract the boot sector, code and data from a diskette image.

Usage:
  extract-diskette.py --infile game.bin --suffix v10

Reads:
  game.bin

Writes:
  bootv10.bin
  codev10.bin
  datav10.bin
"""

import argparse

import diskette

def main():
  parser = argparse.ArgumentParser(description="Decode Colossal Cave data file")
  parser.add_argument('--infile', required=True, help="Input diskette.bin")
  parser.add_argument('--suffix', required=True, help="Output filename suffix")
  args = parser.parse_args()

  with open(args.infile, "rb") as infile:
    buf = infile.read()

  disk = diskette.Diskette(buf)
  suffix = args.suffix

  with open(f'boot{suffix}.bin', "wb") as ofp:
    ofp.write(disk.boot_sector())

  with open(f'code{suffix}.bin', "wb") as ofp:
    ofp.write(disk.code())

  with open(f'data{suffix}.bin', "wb") as ofp:
    ofp.write(disk.data())

  print(f'Wrote boot{suffix}.bin code{suffix}.bin data{suffix}.bin')

if __name__ == '__main__':
  main()
