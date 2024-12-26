"""A colossal cave diskette.

The diskette is 350 x 256-byte sectors long, or 89600 bytes.

The image format is:

  * Boot sector: 1 sector
  * Game code: 62 sectors
  * Data area: 287 sectors
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

    self._boot_sector = None
    self._code = None
    self._data = None

    if buf is not None:
      self._boot_sector = buf[0x0000:0x0100]
      self._code = buf[0x0100:0x3f00]
      self._data = buf[0x3f00:]

  def boot_sector(self, buf:bytes=None) -> bytes:
    """Set/Get the boot sector code."""

    if buf is not None:
      if len(buf) != 256:
        raise BufferError('Boot sector must be 256 bytes long')
      self._boot_sector = buf

    return self._boot_sector

  def code(self, buf:bytes=None) -> bytes:
    """Set/Get the game code."""

    if buf is not None:
      if len(buf) != 62 * 256:
        raise BufferError('Code must be 62 * 256 bytes long')
      self._code = buf

    return self._code

  def data(self, buf:bytes=None) -> bytes:
    """Set/Get the data area."""

    if buf is not None:
      if len(buf) != 287 * 256:
        raise BufferError('Data must be 287 * 256 bytes long')
      self._data = buf

    return self._data

  def image(self) -> bytes:
    """Return the 89600 byte long game image."""
    return self._boot_sector + self._code + self._data
