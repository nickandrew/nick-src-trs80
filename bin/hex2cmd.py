#!/usr/bin/env python3
"""Convert Intel Hex format on stdin to a .cmd file.

The .cmd file is written in ascending address order, filled 256-byte blocks
whenever possible, with the exception of any overlapping areas. Overlapping
areas are written first to the output file.
"""

from dataclasses import dataclass

import argparse
import re
import sys

class HexError(Exception):
    """An Intel Hex line failed validation."""

@dataclass
class HexLine:
    length: int
    addr: int
    record_type: int
    data: bytes
    checksum: int

def parse_hex_line(line: str):
    """Parse a single line of Intel Hex format.

    The trailing \n has already been stripped.

    Return a HexLine.
    """

    if not re.match(r':[A-F0-9]+$', line):
        raise HexError(f'This is not an Intel hex line: {line}')

    # line length: 1 + 2 x (length + addr + addr + record_type) + 2 * length + 2
    l = len(line)
    if l < 11:
        raise HexError(f'Line too short: {line}')

    # Parse the data in the line
    line_bytes = [int(line[(2 * i + 1):(2 * i + 3)], 16) for i in range((l - 1) // 2)]

    length = int(line[1:3], 16)
    addr = int(line[3:7], 16)
    record_type = int(line[7:9], 16)

    test_checksum = sum(b for b in line_bytes)

    if test_checksum % 256 != 0:
        raise HexError(f'Checksum error: {line} got {test_checksum:x} expected 00')

    return HexLine(
        length=length,
        addr=addr,
        record_type=record_type,
        data=line_bytes[4:4+length],
        checksum=line_bytes[-1],
    )

class Buffer(object):
    """A Buffer represents a contiguous set of data to be loaded into memory."""
    def __init__(self, start_address:int):
        self.start_address = start_address
        self.end_address = start_address
        self.data = bytearray()

    def __str__(self):
        return f'Buffer {{start_address:{self.start_address:04x} end_address:{self.end_address:04x} data:...}}'

    def append_data(self, b:bytes):
        self.data.extend(b)
        self.end_address = self.end_address + len(b)

    def emit(self, cmd=None):
        print(f'Emit Buffer from {self.start_address:04x} to {self.end_address:04x}')
        if cmd:
            cmd.add_data(self.start_address, self.data)

    def overlaps(self, start_address:int, end_address:int) -> bool:
        """Return True if this buffer overlaps any of the memory range specified.

        Arguments:
          start_address: Start of the memory range
          end_address: End of the memory range plus 1
        """

        if start_address >= self.end_address or end_address <= self.start_address:
            return False

        return True

class Buffers(object):
    """A group of Buffer."""

    def __init__(self):
        self.buffers = {}

    def add_data(self, start_address:int, b:bytes, cmd):
        end_address = start_address + len(b)

        # Emit any existing, overlapping buffers
        delete_set = set()
        for k, v in self.buffers.items():
            if v.overlaps(start_address, end_address):
                print(f'Add data [{start_address:04x}:{end_address:04x}] {v} overlaps [{start_address:04x}:{end_address:04x}], emitting')
                v.emit(cmd)
                delete_set.add(k)

        # Delete any overlapping buffers
        for k in delete_set:
            del self.buffers[k]

        # See if there's a buffer to append to
        chosen_buffer = None
        for v in self.buffers.values():
            if start_address == v.end_address:
                print(f'Add data [{start_address:04x}:{end_address:04x}] append to buffer at {v.start_address:04x}')
                v.append_data(b)
                chosen_buffer = v
                break

        if chosen_buffer is None:
            print(f'Add data [{start_address:04x}:{end_address:04x}] make new buffer')
            chosen_buffer = Buffer(start_address)
            chosen_buffer.append_data(b)
            self.buffers[start_address] = chosen_buffer

        # See if there's a buffer adjoining the chosen buffer, to adjoin
        if end_address in self.buffers:
            print(f'Add data [{start_address:04x}:{end_address:04x}] adjoining buffer found at {end_address:04x}, appending and deleting')
            chosen_buffer.append_data(self.buffers[end_address].data)
            del self.buffers[end_address]

    def emit(self, cmd):
        """Emit all buffers sorted by increasing start address."""
        for k in sorted(self.buffers.keys()):
            self.buffers[k].emit(cmd)
        self.buffers = {}

class CMDFile(object):
    """A .cmd file."""

    def __init__(self):
        self.records = []
        self._start_address = 0x0000

    def add_filename(self, s:str):
        l = len(s)
        if l > 255:
            raise ValueError(f'Filename in .cmd file cannot be length {l}')

        record = bytes([0x05, len(s)]) + bytes(s, 'utf8')
        self.records.append(record)

    def add_data(self, address:int, data:bytes):
        """Add one or more load blocks to the .cmd file.

        All load blocks until the last will be 256 bytes; the last may be
        256 bytes depending on the size of the data.
        """
        l = len(data)
        if l == 0:
            raise ValueError(f'Cannot add empty data block to CMDFile')
        offset = 0

        while l > 0:
            sz = min(l, 0x100)
            address_low = address % 0x100
            address_high = (address >> 8)
            record = bytes([0x01, (sz + 2) % 0x100, address_low, address_high]) + data[offset:offset+sz]
            self.records.append(record)
            offset += sz
            address += sz
            l -= sz


    def start_address(self, address:int):
        self._start_address = address

    def to_bytes(self):
        buf = bytearray()
        for r in self.records:
            buf.extend(r)
        start_low = self._start_address % 0x100
        start_high = (self._start_address >> 8)
        start_record = bytes([0x02, 0x02, start_low, start_high])
        buf.extend(start_record)

        return buf

def read_file(source, filename=None, start_address=None):
    """Reads an Intel Hex file and constructs a corresponding .cmd file.

    Arguments:
      source:   An iterator
    """

    bufs = Buffers()
    cmd = CMDFile()

    if filename is not None:
        cmd.add_filename(filename)

    if start_address is not None:
        cmd.start_address(start_address)

    for line in source:
        line = line.rstrip()
        hl = parse_hex_line(line)

        if hl.record_type == 0x00:
            if hl.length > 0:
                bufs.add_data(hl.addr, hl.data, cmd)
            else:
                # A zero-length record signifies start address
                cmd.start_address(hl.addr)
        elif hl.record_type == 0x01 and hl.addr > 0:
            cmd.start_address(hl.addr)

    # Clear the buffers, finally
    bufs.emit(cmd)

    return cmd

def main():
    parser = argparse.ArgumentParser(description='Convert a .hex file on stdin to .cmd')
    parser.add_argument('--output', required=True, help='Output filename (ending in .cmd')
    parser.add_argument('--filename', help='Filename to be encoded in the output file')
    parser.add_argument('--entry', help='Execution start address')
    args = parser.parse_args()

    start_address = None
    if args.entry:
        start_address = int(args.entry, 16)

    cmdfile = read_file(sys.stdin, filename=args.filename, start_address=start_address)

    with open(args.output, 'wb') as ofp:
        ofp.write(cmdfile.to_bytes())

if __name__ == '__main__':
    main()
