"""The various tables used in Colossal Cave."""

import sys

import message

def _hex(value:int) -> str:
  """Return a valid hex literal.

  Values from a0 to ff return "0xxh"; lesser values return "xxh".
  """
  if value < 0xa0:
    return f'{value:02x}h'
  else:
    return f'0{value:02x}h'


class Table(object):
  """A generic message table."""

  def __init__(self, messages:list[message.Message]=None, lookup_size=0, size=0):
    self._data = None
    self._messages = messages
    self._lookup = None
    self._lookup_size = lookup_size
    self._size = size

  def generate_data(self, start_address:int) -> bytes:
    b = bytearray()
    address = start_address
    self._lookup = bytearray(self._lookup_size)

    # Every binary block of messages starts with a zero byte
    b.append(0)

    for msg in self._messages:
      _id = msg.message_id

      for text_line in msg.text:
        address = start_address + len(b)
        b.append(_id)
        seed = (_id * 256) + ((address >> 8) & 0xff)

        # Add an entry to the lookup table for the first message in a set
        # FIXME this won't work for object descriptions, which aren't
        # monotonic increasing.
        if _id < self._lookup_size and self._lookup[_id] == 0:
          self._lookup[_id] = (address >> 8) & 0xff

        text_bytes = bytearray()
        for plaintext in text_line:
          seed = message.permute(seed)
          enc = ord(plaintext) ^ (seed & 0xff)
          text_bytes.append(enc | 0x80)
        # A zero byte at the end of each text line

        text_bytes.append(0)
        b.extend(text_bytes)

    # Add 3 zeroes to represent end of table
    b.extend([0, 0, 0])

    # Then pad to desired size or multiple of 256 bytes
    if self._size == 0:
      r = len(b) % 256
      if r > 0:
        remainder = 256 - r
      else:
        remainder = 0
    else:
      remainder = self._size - len(b)
    if remainder > 0:
      b.extend(bytes(remainder))

    self._data = b
    return b

  def lookup_asm(self) -> str:
    """Return the lookup data for this table in ASM format."""
    lookup = self._lookup
    if lookup is None:
      raise ValueError('generate_data() must be called before lookup_asm()')

    l = len(lookup)
    i = 0
    s = ''

    while i < l:
      s = s + f'\tdb\t' + _hex(lookup[i])
      i = i + 1
      j = i
      while j < i + 7 and j < l:
        s = s + ',' + _hex(lookup[j])
        j = j + 1
      i = j
      s = s + '\n'

    return s

def LongDescription(messages:list[message.Message]=None):
  return Table(messages, lookup_size=144, size=71 * 256)

def ShortDescription(messages:list[message.Message]=None):
  return Table(messages, lookup_size=144, size=10 * 256)

def ObjectDescription(messages:list[message.Message]=None):
  return Table(messages, lookup_size=68, size=21 * 256)

def RText(messages:list[message.Message]=None):
  return Table(messages, lookup_size=222, size=80 * 256)

def ScoreSummaries(messages:list[message.Message]=None):
  return Table(messages, lookup_size=14, size=4 * 256)
