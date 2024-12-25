#!/usr/bin/env python3
"""Simple converter from Intel Hex format to a .bin file."""

import argparse
import sys

def main():
  p = argparse.ArgumentParser(description='Convert a .hex file on stdin to .bin')
  p.add_argument('--output', required=True, help='Output filename (ending in .bin)')
  p.add_argument('--pad', type=int, default=0, help='Pad output to this many bytes')
  args = p.parse_args()

  output = []

  for line in sys.stdin:
    if line[0] != ':':
      raise ValueError('This is not an Intel hex file')
    length = int(line[1:3], 16)
    addr = int(line[3:7], 16)
    code = int(line[7:9], 16)

    # Non-data lines are ignored
    # Checksum bytes are ignored
    if code != 0x00:
      continue

    line_bytes = []

    # FIXME: Address is ignored
    if length > 0:
      rest = line[9:-3]
      line_bytes = [int(rest[(2 * i):(2 * i + 2)], 16) for i in range(length)]
      output.append(line_bytes)

  length = 0

  with open(args.output, 'wb') as of:
    for line_bytes in output:
      of.write(bytes(line_bytes))
      length += len(line_bytes)
    if args.pad > 0:
      remainder = length % args.pad
      if remainder > 0:
        of.write(bytes(args.pad - remainder))


if __name__ == '__main__':
  main()
