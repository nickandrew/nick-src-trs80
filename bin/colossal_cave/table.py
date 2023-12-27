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

  def __init__(self, messages:list[message.Message]=None, lookup_size=0, size=0, object_index=False):
    self._data = None
    self._messages = messages
    self._lookup = None
    self._lookup_size = lookup_size
    self._object_index = object_index
    self._size = size

  @property
  def messages(self):
    return self._messages

  def _update_lookup(self, message_id:int, sector_number:int) -> int:
    """Try to update the lookup table for this given message.

    Returns:
      The index into the lookup table, if one was set, else None.
    """

    lookup_id = None

    if self._object_index:
      # True id is 1..64, but the first message in the set is (id % 0x20)
      # so skip anything >= 0x20
      if message_id < 0x20:
        # Find the first unused slot to find True ID.
        # This assumes there is only 1 line in the first message in the set.
        lookup_id = message_id

        # No ID zero exists, so start looking at 32.
        if lookup_id == 0:
          lookup_id = lookup_id + 0x20

        while self._lookup[lookup_id] != 0:
          lookup_id = lookup_id + 0x20

        self._lookup[lookup_id] = sector_number
    else:
      # Normal kind of lookup table where each message ID has a slot
      # in the lookup table.
      lookup_id = message_id

      # Only the first line in a message sets the lookup table address
      if self._lookup[lookup_id] == 0:
        self._lookup[lookup_id] = sector_number

    return lookup_id

  def decrypt(self, buf:bytes, offset:int) -> None:
    """Decrypt a buffer into this Table.

    Store the decrypted messages in self.messages. Calculate a nearly-correct
    lookup table from the message IDs.
    """

    self._messages = []
    self._lookup = bytearray(self._lookup_size)

    ret = []
    last_message = None
    last_message_id = None

    i = 0x1
    max_i = len(buf)

    if buf[0] != 0x00:
      raise ValueError('Supplied message buffer must start with 0x00')

    while i < max_i:

      # Runs of 3 or more zeroes signify the end of the set
      if buf[i - 1] == 0 and buf[i] == 0 and buf[i + 1] == 0:
        break

      # Figure out the seed
      message_id = buf[i]
      sector_number = int(i / 256) + offset
      seed = (message_id * 256) + (sector_number & 255)
      s = ''

      i = i + 1
      n = buf[i]

      while n != 0:
        seed = message.permute(seed)
        ch = 0x7f & (n ^ (seed & 0xff))
        s = s + chr(ch)
        i = i + 1
        n = buf[i]

      i = i + 1

      if last_message_id is None or message_id != last_message_id:
        # Append message to return list
        last_message = message.Message(message_id, [s])
        last_message_id = message_id
        ret.append(last_message)
      else:
        last_message.append(s)

      # Try to figure out an appropriate lookup table address
      lookup_id = self._update_lookup(message_id, sector_number)
      if lookup_id is not None:
        # Set it in the Message too
        last_message.set_lookup_id(lookup_id)

    self._messages = ret

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

        self._update_lookup(_id, (address >> 8) & 0xff)

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
  """Long Descriptions. 71 sectors of messages.

  IDs 1-141.
  """
  return Table(messages, lookup_size=144, size=71 * 256)

def ShortDescription(messages:list[message.Message]=None):
  """Short Descriptions. 10 sectors of messages.

  IDs 1-141.
  """
  return Table(messages, lookup_size=144, size=10 * 256)

def ObjectDescription(messages:list[message.Message]=None):
  """Object Descriptions. 21 sectors of messages.

  IDs 1-64, interleaved with variants (1, 33, 2, 34, 66, 0, etc).
  """
  return Table(messages, lookup_size=68, size=21 * 256, object_index=True)

def RText(messages:list[message.Message]=None):
  """Random Text. 80 sectors of messages.

  IDs 1-219.
  """
  return Table(messages, lookup_size=222, size=80 * 256)

def ScoreSummaries(messages:list[message.Message]=None):
  """Score Summaries. 4 sectors of messages.

  IDs 1-9.
  """
  return Table(messages, lookup_size=14, size=4 * 256)
