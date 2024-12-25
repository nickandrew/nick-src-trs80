"""Traces read_forwd_4_bytes and read_forwd_4_bytes."""

class Controller(object):
  """A Controller executes a debugging scenario - setting breakpoints, running code etc."""

  def __init__(self, dbg):
    self.dbg = dbg

  def init(self):
    self.dbg.add_breakpoint('5e23', self.read_forwd)
    self.dbg.add_breakpoint('5e2c', self.write_back)

  def read_forwd(self):
    self.dbg.get_registers()
    de = self.dbg.get_reg_de()
    mem = self.dbg.memory(de, 4)
    print(f'POP {de:04x} {mem}')

  def write_back(self):
    self.dbg.get_registers()
    de = self.dbg.get_reg_de()
    hl = self.dbg.get_reg_hl()
    print(f'PUSH {de-4:04x} HL {hl:04x}')
