#!/usr/bin/env python3
"""Decode all the encrypted strings in a Colossal Cave data file."""

import argparse

def permute1(hl):
  """Execute the permutation inner loop."""
  bit_0 = hl & 1
  bit_4 = hl & 0x10
  hl = int(hl / 2)
  xor = (bit_0 == 0) != (bit_4 == 0)

  if xor:
    hl = hl | (1 << 14)

  return hl

def permute(hl):
  """Permute value in HL; return new value."""
  for _ in range(15):
    hl = permute1(hl)
  return hl

def decode_buf(buf):
  """Decode all strings in the buffer.

  We assume some things about the size and start location of strings.
  """

  i = 0x2f00

  while i < 0xe900:
    n = buf[i]

    # Runs of zeroes are ignored
    if n == 0:
      i = i + 1
      continue

    # Must be start of a string
    # Figure out the seed
    sector_number = int(i / 256) - 45
    seed = (n * 256) + (sector_number & 255)
    print(f'String start at {i:04x}, IV {seed:04x}')
    s = ''

    i = i + 1
    n = buf[i]
    while n != 0:
      seed = permute(seed)
      ch = 0x7f & (n ^ (seed & 0xff))
      # print(f'  i {i:04x} n {n:02x} seed {seed:04x} result {ch:02x}')
      s = s + chr(ch)
      i = i + 1
      n = buf[i]

    print(f'Result: {s}')

def main():
  parser = argparse.ArgumentParser(description="Decode Colossal Cave data file")
  parser.add_argument('--infile', required=True, help="Source data.bin")
  args = parser.parse_args()

  with open(args.infile, "rb") as infile:
    buf = infile.read()
    decode_buf(buf)


if __name__ == '__main__':
  main()
