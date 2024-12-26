#!/usr/bin/env python3
"""Combine the Colossal Cave game components to create a binary image.

The output image is 350 x 256-byte sectors long, or 89600 bytes.

Usage:
  create-image.py --outfile gameVER.bin --boot bootVER.bin --code codeVER.bin --data dataVER.bin
"""

import argparse

import diskette

def main():
  parser = argparse.ArgumentParser(description="Create Colossal Cave diskette image")
  parser.add_argument('--outfile', required=True, help="Output image file .bin")
  parser.add_argument('--boot', required=True, help="Boot sector .bin")
  parser.add_argument('--code', required=True, help="Code .bin")
  parser.add_argument('--data', required=True, help="Data .bin")
  args = parser.parse_args()

  d = diskette.Diskette()

  with open(args.boot, "rb") as ifp:
    buf = ifp.read()
    d.boot_sector(buf)

  with open(args.code, "rb") as ifp:
    buf = ifp.read()
    d.code(buf)

  with open(args.data, "rb") as ifp:
    buf = ifp.read()
    d.data(buf)

  with open(args.outfile, "wb") as ofp:
    ofp.write(d.image())

  print(f'Wrote game image to {args.outfile}')

if __name__ == '__main__':
  main()
