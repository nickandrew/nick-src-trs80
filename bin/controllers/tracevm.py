"""Traces virtual machine opcode fetch and execute loop."""

from colossal_cave import vm

class Controller(object):
  """A Controller executes a debugging scenario - setting breakpoints, running code etc."""

  def __init__(self, dbg):
    self.vmdbg = vm.Debug(dbg)

  def init(self):
    """Set up debugging."""
    self.vmdbg.add_trace(self.trace_1)

  def trace_1(self):
    instruction = self.vmdbg.instruction()
    o1 = ' '.join([f'{x:02x}' for x in instruction.memory])
    print(f'{self.vmdbg.pc:04x}    {o1:8s} {instruction.disassemble()}')

    # Additional operands
    operand_list = []
    if instruction.opcode.stack_count > 0:
      for i in range(instruction.opcode.stack_count):
        (value, pointer) = self.vmdbg.stack(i)
        s = f'({value:04x},{pointer:04x})'
        operand_list.append(s)

    if instruction.opcode.word_address:
      value = self.vmdbg.memory.word(instruction.opcode.word_address)
      operand_list.append(f'mem:{value:04x}')

    if operand_list:
      operands = '          Operands: ' + ' '.join(operand_list)
      print(operands)

    return True
