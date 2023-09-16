#!/usr/bin/env python3
"""Check whether a dz80 .ctl file is sorted by address, and report problems.

My .ctl files are in two parts: first part defines labels, comments and
similar. Second part defines the type of each byte of memory space. Each
part needs to be sorted by increasing address, but there are some issues
which make automatic sorting difficult or impossible:

* The file format includes comments and there can be blank lines
* There can be multiple directive lines for the same address, and
  these need to be preserved in order.

At this point, just do a simple one pass through the file, looking for
reductions in the address, and tracking the last address seen. There
will always be one reduction reported, at the point where the 2nd part
of the file starts.
"""

import argparse
import re

def check_file(filename):
  """Read a single text file. Report any address reductions."""

  max_address = -1
  with open(filename, 'r') as infile:
    line_number = 0
    for line in infile:
      line_number = line_number + 1
      m = re.match(r'(.) ([0-9a-fA-F]{4})(-([0-9a-fA-F]{4}))?', line)

      if m:
        start_address = int(m.group(2), 16)
        if start_address <= max_address:
          print(f'{filename} line {line_number} start address {start_address:04x} overlaps max_address {max_address:04x}')
        max_address = start_address

        if m.group(4):
          last_address = int(m.group(4), 16)
          if last_address < start_address:
            print(f'{filename} line {line_number} {start_address:04x}-{last_address:04x} is illegal')
          max_address = last_address

def emit_line(directive, start_address, last_address, comment):
  """Return a string ending in \n which defines the contents of the range of addresses.
  """

  if last_address == start_address:
    s = f'{directive} {start_address:04x}'
    if comment:
      s = s + '\t\t; ' + comment
  else:
    s = f'{directive} {start_address:04x}-{last_address:04x}'
    if comment:
      s = s + '\t; ' + comment

  return s + '\n'


def check_memory(memory_map, directive, start_address, last_address):
  """Check whether the given directive corresponds with the known memory map.

  Return None if there is no change to be made (this ensures any comments
  are preserved), otherwise one or more replacement lines.

  memory_map values:
    0  unknown
    1  code ('c' directive)
    2  opcode ('b')

  Returns '', or one or more strings ending in \n.
  """

  s = ''

  # Convert from hex
  start_address = int(start_address, 16)
  if last_address:
    last_address = int(last_address, 16)
  else:
    last_address = start_address

  want_memory = 1  # Code
  want_directive = 'c'

  if directive != 'c':
    want_memory = 2  # Bytes

  type_map = {
    0: 'n',
    1: 'c',
    2: 'b',
  }

  comment_map = {
    1: 'Code',
    2: 'Opcodes',
  }

  mismatch = False
  i = start_address

  while i <= last_address:
    m = memory_map[i]
    if m != 0 and m != want_memory:
      mismatch = True
      break
    i = i + 1

  if not mismatch:
    return ''

  i = start_address
  start_repl = None

  # Find all runs of code or opcodes, and emit a single line per run
  while i <= last_address:
    m = memory_map[i]
    if m != 0 and m != want_memory:
      # Replace from start_address to i-1
      if i > start_address:
        s = s + emit_line(directive=type_map[want_memory], start_address=start_address, last_address=i-1, comment=comment_map[want_memory])

      # If memory_map switches from e.g. code to binary
      want_memory = m
      start_address = i

    i = i + 1

  # Emit a final line
  if i > start_address:
    s = s + emit_line(directive=type_map[want_memory], start_address=start_address, last_address=i-1, comment=comment_map[want_memory])

  return s


def verify_rewrite(filename, verify_file):
  """Read verify_file, which is a memory map.

  For every address in the .ctl file, check if the specified type agrees with
  the memory map.

  Rewrite a new .ctl file (filename.new) with any changes needed due to discrepancies.
  """

  with open(verify_file, 'rb') as ifp:
    mmap = ifp.read()
    memory_map = bytearray(mmap)

  output = ''
  changed = False

  with open(filename, 'r') as infile:
    line_number = 0
    for line in infile:
      m = re.match(r'(.) ([0-9a-fA-F]{4})(-([0-9a-fA-F]{4}))?', line)

      if m and m.group(1) in 'bawct':
        s = check_memory(memory_map=memory_map, directive=m.group(1), start_address=m.group(2), last_address=m.group(4))
        if s != '':
          changed = True
        else:
          s = line
      else:
        s = line

      # Append to output
      if s:
        output = output + s


  # Rewrite
  if changed:
    with open(filename + '.new', 'w') as outfile:
      outfile.write(output)
      print(f'Rewrite {filename} with changes.')

def consolidate(filename):
  """Consolidate adjacent byte/word/code areas in a .ctl file.

  Only non-commented lines are consolidated.
  """

  output = ''
  saved_directive = None
  saved_first = None
  saved_last = None

  def emit():
    """Write consolidated line to output buffer."""
    nonlocal output
    nonlocal saved_directive
    nonlocal saved_first
    nonlocal saved_last

    if saved_directive is not None:
      s = f'{saved_directive} {saved_first:04x}'

      if saved_last != saved_first:
        s = s + f'-{saved_last:04x}'

      output = output + s + '\n'

      saved_directive = None

  def save(directive, first_address, last_address):
    nonlocal saved_directive
    nonlocal saved_first
    nonlocal saved_last

    """Consolidate directive with saved directive, or save anew."""
    if directive == saved_directive and first_address == saved_last + 1:
      saved_last = last_address
    else:
      emit()
      saved_directive = directive
      saved_first = first_address
      saved_last = last_address


  with open(filename, 'r') as infile:
    line_number = 0

    for line in infile:
      m = re.match(r'(.) ([0-9a-fA-F]{4})(-([0-9a-fA-F]{4}))?$', line)
      if m:
        first_address = int(m.group(2), 16)
        last_address = first_address
        if m.group(4):
          last_address = int(m.group(4), 16)
        save(directive=m.group(1), first_address=first_address, last_address=last_address)
      else:
        emit()
        output = output + line

      line_number = line_number + 1

    emit()

  with open(filename + '.new', 'w') as outfile:
    outfile.write(output)
    print(f'Rewrite {filename} with changes.')

def parse_args():
  parser = argparse.ArgumentParser(description='Check a .ctl file for sortedness')
  parser.add_argument('--consolidate', action='store_true', help='Consolidate adjacent byte/word/code areas')
  parser.add_argument('--verify', help='Memory dump filename to verify and rewrite the .ctl file')
  parser.add_argument('file', help='Filename to analyse')
  return parser.parse_args()

def main():
  args = parse_args()
  if args.consolidate:
    consolidate(filename=args.file)
  elif args.verify:
    verify_rewrite(filename=args.file, verify_file=args.verify)
  else:
    check_file(filename=args.file)

if __name__ == '__main__':
  main()
