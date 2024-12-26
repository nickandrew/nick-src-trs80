#!/usr/bin/env python3
"""Read a binary file and output a list of hex bytes, one per line.

Allows binary files to be diff'ed allowing for insertions and removals."""

import argparse

def main():
  parser = argparse.ArgumentParser(description="Dump a binary file as hex")
  parser.add_argument('filename', help='Binary filename to read')
  args = parser.parse_args()

  with open(args.filename, 'rb') as ifp:
    contents = ifp.read()
  for b in contents:
    print(f'{b:02x}')

if __name__ == '__main__':
  main()
