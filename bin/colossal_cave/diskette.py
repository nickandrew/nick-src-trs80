"""A colossal cave diskette.

The main contents of the diskette are, in order:

  Boot sector (1 sector)
  Game code (62 sectors)
  Data (287 sectors)
"""

class Diskette(object):
  """Diskette image."""

  def __init__(self, buf:bytes=None):
    """Return a new instance of Diskette.

    Arguments:
      buf     bytes read from a data file.

    If buf is not supplied, a zero-bytes buffer of length 59904 is
    used, making an empty object.

    The supplied bytes buffer is split into its logical components.
    """

    if buf is None:
      buf = bytes(0x15e00)

    self._boot_sector = buf[0x0000:0x0100]
    self._code = buf[0x0100:0x3f00]
    self._data = buf[0x3f00:]

  def boot_sector(self) -> bytes:
    """Return the boot sector code."""
    return self._boot_sector

  def code(self) -> bytes:
    """Return the game code."""
    return self._code

  def data(self) -> bytes:
    """Return the data area."""
    return self._data
