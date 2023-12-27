"""Decrypt messages.

Almost all text printed by the game is stored encrypted on diskette;
this includes room descriptions, introductory text, object names,
events which occur in the game and so on.
"""

def _permute1(hl):
  """Execute the permutation inner loop."""
  bit_0 = hl & 1
  bit_4 = hl & 0x10
  hl = int(hl / 2)
  xor = (bit_0 == 0) != (bit_4 == 0)

  if xor:
    hl = hl | (1 << 14)

  return hl

def permute(hl:int) -> int:
  """Permute value in HL; return new value."""
  for _ in range(15):
    hl = _permute1(hl)
  return hl

class Message(object):
  """A multi-line text string that the game is able to display.

  Each Message has an associated message_id.
  """

  def __init__(self, message_id:int, text:list[str], lookup_id:int=None):
    """Return a new instance of Message.

    Arguments:
      message_id    8-bit message ID
      text          List of decoded text strings
    """

    self._lookup_id = lookup_id
    self._message_id = message_id
    self._text = text

  @property
  def lookup_id(self):
    """Return the message_id."""
    return self._lookup_id

  @property
  def message_id(self):
    """Return the message_id."""
    return self._message_id

  @property
  def text(self):
    """Return the list of text strings."""
    return self._text

  def append(self, line):
    """Append one line to the message's text."""
    self._text.append(line)

  def to_dict(self):
    """Return this object as an untyped dict."""
    d = {
      'message_id': self._message_id,
      'text': self._text,
    }

    if self._lookup_id is not None:
      d['lookup_id'] = self._lookup_id

    return d

  def set_lookup_id(self, lookup_id):
    self._lookup_id = lookup_id
