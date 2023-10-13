"""Traces virtual machine opcode fetch and execute loop."""

import colossal_cave.vm

class Controller(object):
  """A Controller executes a debugging scenario - setting breakpoints, running code etc."""

  def __init__(self, dbg):
    self.dbg = dbg

  def init(self):
    """Set up debugging."""
    self.dbg.add_breakpoint('5a19', self.fetch_opcode)

  def fetch_opcode(self):
    self.dbg.get_registers()
    a = self.dbg.get_reg_a()
    bc = self.dbg.get_reg_bc()
    # Grab the next 2 bytes of memory in case it's a 2 or 3 byte opcode
    m_str = self.dbg.memory(bc + 1, 2)
    memory = [a, int(m_str[0], 16), int(m_str[1], 16)]

    disassembly = colossal_cave.vm.Opcodes.disassemble(bc, memory)
    length = colossal_cave.vm.Opcodes.opcode_length(a)

    rest = ''
    if length == 2:
      rest = f'{m_str[0]}   '
    elif length == 3:
      rest = f'{m_str[0]} {m_str[1]}'
    else:
      rest = '     '

    print(f'{bc:04x}    {a:02x} {rest} {disassembly}')
