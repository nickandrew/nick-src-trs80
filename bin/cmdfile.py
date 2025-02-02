"""
# CMD file format:

CMD files are a sequence of records. Each record starts with a record_type
byte, and it is followed by a size byte.

## Load Block record: 01 ss ll hh <data>

Load the following <data> bytes into memory starting at address 0xhhll.
ss is the size of the data plus 2, mod 256 (therefore a size of 8 means
2 address bytes and 6 data bytes; a size of 0 means 2 address bytes and
254 data bytes; a size of 2 means 2 address bytes and 256 data bytes).

Newdos/80 SYS0/SYS returns an error 0x24 (Tried to load read-only memory)
if the record tries to write into non-existent memory.

## Execution Address record: 02 xx ll hh

Start executing this file at address 0xhhll. The size byte xx is ignored
and its value is typically 00 or 02. This must be the last record of the
file.

## Ignored records: xx ss <data>

Record types from 03 to 1f inclusive are ignored when loading a CMD file.
The size byte ss is the length of the following data to be skipped.

Newdos/80 SYS0/SYS actually implements this by trying to load the data
into memory between 0x0300 and 0x1fff, where the high order byte of the
load address comes from the record type. These addresses are assumed to
be ROM, and the error 0x24 is suppressed.

Conventionally, record type 0x05 is considered to be a "filename" record.

Likewise, record type 0x1f is considered to be a comment.

## Any other record type

Other record types cause DOSERR_LOAD_FILE_FORMAT_ERROR on load.
"""

from dataclasses import dataclass

@dataclass
class Record:
    record_type: int
    size: int
    address: int
    data: bytes

class CMDFileFormatError(Exception):
    """An error was encountered parsing a CMD file."""

def _read_record(ifp):
    buf = ifp.read(2)
    if len(buf) != 2:
        return None

    record_type = buf[0]
    size = buf[1]
    address = 0
    data = None

    if record_type == 0x01:
        # Load record
        buf = ifp.read(2)
        if len(buf) != 2:
            raise CMDFileFormatError(f'EOF within load record')
        address = buf[0] | (buf[1] << 8)
        n_size = size - 2
        if n_size <= 0:
            n_size += 256
        data = ifp.read(n_size)
        if len(data) != n_size:
            raise CMDFileFormatError(f'EOF within load record data')
        return Record(record_type=record_type, size=size, address=address, data=data)
    elif record_type == 0x02:
        buf = ifp.read(2)
        if len(buf) != 2:
            raise CMDFileFormatError(f'EOF within start address record')
        address = buf[0] | (buf[1] << 8)
        return Record(record_type=record_type, size=size, address=address, data=data)
    else:
        data = ifp.read(size)
        if len(data) != size:
            raise CMDFileFormatError(f'EOF within other data')
        return Record(record_type=record_type, size=size, address=address, data=data)


def records(filename: str):
    """An iterator over a CMD file records."""
    with open(filename, 'rb') as ifp:

        record = _read_record(ifp)
        while record is not None:
            yield record
            if record.record_type == 0x02:
                return
            record = _read_record(ifp)


class CMDFile(object):
    """A .cmd file."""

    def __init__(self):
        self.records = []
        self._start_address = 0x0000

    def add_filename(self, s: str):
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


    def start_address(self, address: int=None):
        if address is not None:
            self._start_address = address
        return self._start_address

    def to_bytes(self):
        buf = bytearray()
        for r in self.records:
            buf.extend(r)
        start_low = self._start_address % 0x100
        start_high = (self._start_address >> 8)
        start_record = bytes([0x02, 0x02, start_low, start_high])
        buf.extend(start_record)

        return buf

    def data_from(self, address: int) -> bytes:
        """Return an array of 1 or more bytes starting at 'address' from the CMD file.

        Data is returned only from the first matching record.

        The array contains only data until the end of the record.
        """

        for r in self.records:
            # Calculate the data size (2 is 256, 1 is 255, 0 is 254, 255 is 253, ...)
            size = r.size - 2
            if size < 0:
                size = size + 256

            if r.address <= address and (r.address + size > address):
                offset = address - r.address
                return r.data[offset:]

        return None

def read_file(filename: str):
    """Read a file, and return a CMDFile."""
    c = CMDFile()
    for r in records(filename):
        if r.record_type == 0x02:
            c.start_address(r.address)
        else:
            c.records.append(r)

    return c
