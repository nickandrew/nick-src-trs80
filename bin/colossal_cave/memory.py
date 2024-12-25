"""A chunk of Memory or disk data as bytes."""

class MemoryError(Exception):
  """An address out of memory range was requested."""

class Memory(object):
  """A sequence of bytes starting at some address.

  Address arguments in lookup functions (memory_bytes, byte, word,
  slice) are absolute; the start address of the Memory object is
  subtracted to index into the stored bytes.
  """

  def __init__(self, *, address:int, memory:bytes):
    """Return a new instance of Memory.

    Arguments:
      address     Start address
      memory      Memory contents starting at that address
    """

    self.start_address = address
    self.size = len(memory)
    self.last_address = address + self.size
    self.memory = memory

  def memory_bytes(self, start_address, size):
    """Return a slice of memory."""
    s = start_address - self.start_address
    if s < 0:
      raise MemoryError(f'Memory start_address {start_address:04x} less than {self.start_address:04x}')
    last_address = start_address + size
    if last_address > self.last_address:
      raise MemoryError(f'Memory last address {last_address:04x} greater than {self.last_address:04x}')

    return self.memory[s:s + size]

  def byte(self, address):
    """Return the single byte at this address."""
    b = self.memory_bytes(address, 1)
    return b[0]

  def word(self, address):
    """Return the 16-bit word at this address."""
    b = self.memory_bytes(address, 2)
    return b[0] + b[1] * 0x100

  def slice(self, address, size):
    """Return a new instance of Memory containing a slice of this instance."""
    return Memory(address=address, memory=self.memory_bytes(address, size))
