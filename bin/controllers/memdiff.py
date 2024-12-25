"""Traces changes to the game state between each input command."""

class MemoryRegion(object):
  """A MemoryRegion will track changes within a continuous area of memory."""
  def __init__(self, dbg, first_address, last_address):
    self.dbg = dbg
    self.saved_memory = None
    self.first_address = first_address
    self.last_address = last_address

  def update(self):
    print(f'---------------- region from {self.first_address:04x} to {self.last_address:04x}')
    new_memory = self.dbg.memory(self.first_address, self.last_address - self.first_address + 1)

    if self.saved_memory is not None:
      for addr in range(0, self.last_address - self.first_address + 1):
        om = self.saved_memory[addr]
        nm = new_memory[addr]
        if om != nm:
          print(f'memory {addr + self.first_address:04x} changed from {om} to {nm}')

    self.saved_memory = new_memory


class Controller(object):
  """A Controller executes a debugging scenario - setting breakpoints, running code etc."""

  def __init__(self, dbg):
    self.dbg = dbg
    self.first_address = 0x4300
    self.last_address = 0x4723
    self.region_1 = MemoryRegion(dbg, first_address=0x4300, last_address=0x4723)
    self.region_2 = MemoryRegion(dbg, first_address=0x4824, last_address=0x59ff)

  def init(self):
    """Set up debugging."""
    self.dbg.add_breakpoint('7ebc', self.input_line)

  def input_line(self):
    """Dump memory between each command."""

    print('----------------')
    self.region_1.update()
    self.region_2.update()
