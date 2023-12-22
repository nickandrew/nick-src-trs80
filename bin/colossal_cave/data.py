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

class Data(object):
  """Game data."""

  def __init__(self, buf:bytes=None):
    """Return a new instance of Data.

    Arguments:
      buf     [Optional] bytes read from a data file.

    If buf is not supplied, an empty object is returned.

    If buf is supplied, it is split into its logical components.

      Starting points are at 2f00, 7600, 8000 and e500.
      2f00: messages 01..8d (long location descriptions)
      7600: messages 01..8d (short location descriptions, with gaps)
      8000: messages 01..1f (and variants (21, 41, 61 etc)), messages 00, 20 etc at end
      9500: messages 01..db (rtext)
      e500: messages 01..09 (score summaries)
    """

    self._save_game_data_2 = None
    self._save_game_data_1 = None
    self._gap_1 = None
    self._long_descriptions = None
    self._short_descriptions = None
    self._object_descriptions = None
    self._rtext = None
    self._score_summaries = None
    self._gap_2 = None
    self._backup_code = None

    if buf is not None:
      self._save_game_data_2 = buf[0x0000:0x1700]
      self._save_game_data_1 = buf[0x1700:0x2e00]
      # There's a data gap of zeroes between 0x2e00 and 0x2f00
      self._gap_1 = buf[0x2e00:0x2f00]
      self._long_descriptions = buf[0x2f00:0x7600]
      self._short_descriptions = buf[0x7600:0x8000]
      self._object_descriptions = buf[0x8000:0x9500]
      self._rtext = buf[0x9500:0xe500]
      self._score_summaries = buf[0xe500:0xe900]
      self._gap_2 = buf[0xe900:0x11500]
      self._backup_code = buf[0x11500:0x11e00]

  def long_descriptions(self):
    """Return a list of the decoded long descriptions.

    See help(decode_buf) for the list format.
    """
    return decode_buf(0x02, self._long_descriptions)

  def short_descriptions(self):
    """Return a list of the decoded short descriptions.

    See help(decode_buf) for the list format.
    """
    return decode_buf(0x49, self._short_descriptions)

  def object_descriptions(self):
    """Return a list of the decoded object descriptions.

    See help(decode_buf) for the list format.
    """
    return decode_buf(0x53, self._object_descriptions)

  def rtext(self):
    """Return a list of the decoded random text.

    See help(decode_buf) for the list format.
    """
    return decode_buf(0x68, self._rtext)

  def score_summaries(self):
    """Return a list of the decoded score_summaries.

    See help(decode_buf) for the list format.
    """
    return decode_buf(0xb8, self._score_summaries)
