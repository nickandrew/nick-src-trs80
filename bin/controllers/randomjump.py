"""Warps to random locations every 3rd command."""

import random

class Controller(object):
  """A Controller executes a debugging scenario - setting breakpoints, running code etc."""

  def __init__(self, dbg):
    self.dbg = dbg
    self.counter = 0

  def run(self):
    """Run the debugging until the end."""
    self.dbg.add_breakpoint('7ebc', self.input_line)
    self.dbg.run()

  def input_line(self):
    """Dump memory between each command."""

    self.counter = self.counter + 1

    if (self.counter > 5):
      # Valid locations are 0x00 through 0x8d
      # self.new_location = random.randint(0x00, 0x8d)
      self.new_location = 0x92 - self.counter
      # self.new_location = self.counter
      self.dbg.cmd(f'assign 433c = {self.new_location:02x}')
      print(f'Now at {self.new_location:02x}')
