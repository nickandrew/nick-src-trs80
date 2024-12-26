"""A Colossal Cave data file.

The game data file consists of:

  * Save Game 2 data: 23 sectors
  * Save Game 1 data: 23 sectors
  * Gap: 1 sector
  * Long Descriptions: 71 sectors
  * Short Descriptions: 10 sectors
  * Object Descriptions: 21 sectors
  * Rtext: 80 sectors
  * Score summaries: 4 sectors
  * Gap: 44 sectors
  * Backup code: 9 sectors
  * Gap: 1 sector
"""

import message
import table

def decode_buf(offset:int, buf:bytes):
  """Decode all strings in the buffer.

  Returns:
    A list of message.Message instances

  The list is ordered the same as the messages appear in the buffer.
  """

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

  return ret

class SectorData(object):
  """The definition of a consecutive set of data sectors."""
  def __init__(self, start:int, size:int, cls:str=None, offset:int=None):
    self._start = start
    self._size = size
    self._cls = cls
    self._offset = offset

  @property
  def offset(self):
    return self._offset

  @property
  def start(self):
    return self._start

  @property
  def size(self):
    return self._size

class Data(object):
  """Game data."""

  default_layout = {
    'save_game_2':         SectorData(start=0x0000, size=23 * 256),
    'save_game_1':         SectorData(start=0x1700, size=23 * 256),
    'gap_1':               SectorData(start=0x2300, size=256),
    'long_descriptions':   SectorData(start=0x2f00, size=71 * 256, cls='encoded', offset=0x02),
    'short_descriptions':  SectorData(start=0x7600, size=10 * 256, cls='encoded', offset=0x49),
    'object_descriptions': SectorData(start=0x8000, size=21 * 256, cls='encoded', offset=0x53),
    'rtext':               SectorData(start=0x9500, size=80 * 256, cls='encoded', offset=0x68),
    'score_summaries':     SectorData(start=0xe500, size=4 * 256, cls='encoded', offset=0xb8),
    'gap_2':               SectorData(start=0xe900, size=44 * 256),
    'backup_code':         SectorData(start=0x11500, size=9 * 256),
    'gap_3':               SectorData(start=0x11e00, size=256),
  }

  def __init__(self, buf:bytes=None, layout:dict=default_layout):
    """Return a new instance of Data.

    Arguments:
      buf     [Optional] bytes read from a data file.
      layout  [Optional] dict specifying data area layout.

    If buf is not supplied, an empty object is returned.

    If buf is supplied, it is split into its logical components
    according to the specified layout.
    """

    self._layout = layout
    self.chunks = {}

    if buf is not None:
      for chunk_name in layout:
        start = layout[chunk_name].start
        end = layout[chunk_name].start + layout[chunk_name].size
        self.chunks[chunk_name] = buf[start:end]

  def chunk(self, chunk_name):
    """Return the raw contents of the named data chunk."""
    return self.chunks[chunk_name]

  def set_chunk(self, chunk_name, buf) -> None:
    """Set the raw contents of the named data chunk."""
    if chunk_name not in self._layout:
      raise ValueError(f'Chunk name {chunk_name} is not in data layout')
    self.chunks[chunk_name] = buf

  def image(self):
    """Return the concatenated image of all chunks."""
    buf = bytes()
    for chunk_name in sorted(self._layout.keys(), key=lambda x: self._layout[x].start):
      if chunk_name in self.chunks:
        buf = buf + self.chunks[chunk_name]
      else:
        size = self._layout[chunk_name].size
        buf = buf + bytes(size)

    return buf

  def long_descriptions(self):
    """Return a list of the decoded long descriptions.
    """
    offset = self._layout['long_descriptions'].offset
    t = table.LongDescription()
    t.decrypt(self.chunks['long_descriptions'], offset)
    return t.messages

  def short_descriptions(self):
    """Return a list of the decoded short descriptions.

    See help(decode_buf) for the list format.
    """
    offset = self._layout['short_descriptions'].offset
    t = table.ShortDescription()
    t.decrypt(self.chunks['short_descriptions'], offset)
    return t.messages

  def object_descriptions(self):
    """Return a list of the decoded object descriptions.

    See help(decode_buf) for the list format.
    """
    offset = self._layout['object_descriptions'].offset
    t = table.ObjectDescription()
    t.decrypt(self.chunks['object_descriptions'], offset)
    return t.messages

  def rtext(self):
    """Return a list of the decoded random text.

    See help(decode_buf) for the list format.
    """
    offset = self._layout['rtext'].offset
    t = table.RText()
    t.decrypt(self.chunks['rtext'], offset)
    return t.messages

  def score_summaries(self):
    """Return a list of the decoded score_summaries.

    See help(decode_buf) for the list format.
    """
    offset = self._layout['score_summaries'].offset
    t = table.ScoreSummaries()
    t.decrypt(self.chunks['score_summaries'], offset)
    return t.messages
