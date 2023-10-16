"""Colossal Cave Abstract Virtual Machine."""

class Instruction(object):
  """A single instruction in memory."""

  def __init__(self, opcode:int, address:int, operand:int = None):
    self.opcode = opcode
    self.address = address
    self.operand = operand

    # Default attributes
    self.length = 1
    self.is_gosub = False
    self.is_jump = False
    self.is_cond_jump = False
    self.next_address = None

  def FromMemory(address:int, memory:list[bytes]) -> 'Instruction':
    """Instantiate an instruction from a slice of memory.

    Args:
      memory   3-byte slice of memory contents

    3 bytes is enough for an opcode and an 8 or 16 bit
    operand.

    Returns:

      An Instruction.
    """

    opcode = memory[0]

    operand = None
    is_gosub = False
    is_cond_jump = False
    is_jump = False

    length = 1
    if opcode in Opcodes.two_byte_opcodes:
      operand = memory[1]
      length = 2
    elif opcode in Opcodes.three_byte_opcodes:
      operand = memory[1] + 256 * memory[2]
      length = 3

    # Figure out implicit operand (gosubs)
    if opcode in Opcodes.gosub_opcodes:
      (dest, s) = Opcodes.gosub_opcodes[opcode]
      operand = dest
      is_gosub = True

    elif opcode in Opcodes.byte_relative_opcodes:
      # Sign-extend the operand then compute relative address
      if operand >= 0x80:
        operand = 256 - operand
      operand = (address + 1 + operand) & 0xffff

    elif opcode in Opcodes.word_relative_opcodes:
      # The operand is a relative address; compute it here
      operand = (address + 1 + operand) & 0xffff

    if opcode in Opcodes.jump_opcodes:
      is_jump = True
    elif opcode in Opcodes.cond_jump_opcodes:
      is_cond_jump = True

    instruction = Instruction(opcode=opcode, address=address, operand=operand)
    instruction.length = length
    instruction.is_gosub = is_gosub
    instruction.is_cond_jump = is_cond_jump
    instruction.is_jump = is_jump
    instruction.next_address = address + length

    return instruction

  def disassemble(self):
    """Return a string representation of an Instruction."""

    # 0xa8 to 0xc7 are gosubs
    if self.opcode in Opcodes.gosub_opcodes:
      (dest, s) = Opcodes.gosub_opcodes[self.opcode]
      # Substitute symbolic reference (rather than hex address) if known
      if s:
        return f'gosub {s}'
      return f'gosub {dest:04x}'

    if self.opcode in Opcodes.opcode_table:
      op_str = Opcodes.opcode_table[self.opcode]
      operand = self.operand
      if 'RELBYTE' in op_str:
        op_str = op_str.replace('RELBYTE', '') + f'[{operand:04x}]'
      elif 'RELWORD' in op_str:
        op_str = op_str.replace('RELWORD', '') + f'[{operand:04x}]'
      elif 'BYTE' in op_str:
        op_str = op_str.replace('BYTE', '') + f'[{operand:02x}]'
      elif 'WORD' in op_str:
        op_str = op_str.replace('WORD', '') + f'[{operand:04x}]'

      return op_str

    return f'unknown opcode 0x{self.opcode:02x}'

  def str1(self):
    return self.op_str

  def str2(self):
    """A more verbose disassembly."""
    return f'{self.address:04x}  {self.op_str}'

class Opcodes(object):
  """This class deals with the VM Opcodes.

  Things I know about some opcodes ...

  0x98 ... conditional jump if hl != 0 to following 2 bytes
  0x99 ... conditional relative jump if hl == 0
  0x9b ... store next byte in various places then call an opcode subroutine at 51cf
  0x9c ... call opsub 5c26 then either return or opgoto contents of 5eb7
  0xa1 ... opgoto next 2 bytes
  0xa2 ... looks like following bytes are a jump table
  """

  two_byte_opcodes = [0x96, 0x99, 0x9b]
  three_byte_opcodes = [0x97, 0x98, 0xa1]
  byte_relative_opcodes = [0x99]
  word_relative_opcodes = [0x98, 0xa1]
  jump_opcodes = [0xa1]
  cond_jump_opcodes = [0x98, 0x99]

  gosub_opcodes = {
    0xa8: (0x7670, None),
    0xa9: (0x7673, None),
    0xaa: (0x7676, None),
    0xab: (0x5f1f, None),
    0xac: (0x5f5b, None),
    0xad: (0x7877, None),
    0xae: (0x77ec, None),
    0xaf: (0x5f67, None),
    0xb0: (0x782b, None),
    0xb1: (0x77a7, None),
    0xb2: (0x5f63, None),
    0xb3: (0x798a, None),
    0xb4: (0x5f15, None),
    0xb5: (0x77aa, None),
    0xb6: (0x5f3b, None),
    0xb7: (0x5f2b, None),
    0xb8: (0x5f46, None),
    0xb9: (0x7695, None),
    0xba: (0x76a3, None),
    0xbb: (0x77bc, None),
    0xbc: (0x5f77, None),
    0xbd: (0x7953, None),
    0xbe: (0x77e5, None),
    0xbf: (0x785d, None),
    0xc0: (0x7980, None),
    0xc1: (0x7895, 'print a message'),
    0xc2: (0x5f11, None),
    0xc3: (0x76b1, None),
    0xc4: (0x79fd, None),
    0xc5: (0x7a64, None),
    0xc6: (0x7a68, None),
    0xc7: (0x7a69, None),
  }

  # At present I don't know what the memory addresses refer to, so
  # the disassembly shows their hex value. When I understand the
  # purpose of an address, I'll replace the hex value with a symbolic
  # name.
  opcode_table = {
    0x00: 'push2 wt3 43ba',
    0x01: 'push2 wt3 43bc',
    0x02: 'push2 wt3 43be',
    0x03: 'push2 wt3 43c0',
    0x04: 'push2 wt3 43c2',
    0x05: 'push2 wt3 43c4',
    0x06: 'push2 wt3 43c6',
    0x07: 'push2 wt3 43c8',
    0x08: 'push2 wt3 43ca',
    0x09: 'push2 wt3 43cc',
    0x0a: 'push2 wt3 43ce',
    0x0b: 'push2 wt3 43d0',
    0x0c: 'push2 wt3 43d2',
    0x0d: 'push2 wt3 43d4',
    0x0e: 'push2 wt3 43d6',
    0x0f: 'push2 wt3 43d8',
    0x10: 'push2 wt3 43da',
    0x11: 'push2 wt3 43dc',
    0x12: 'push2 wt3 43de',
    0x13: 'push2 wt3 43e0',
    0x14: 'push2 wt3 43e2',
    0x15: 'push2 wt3 43e4',
    0x16: 'push2 wt3 43e6',
    0x17: 'push2 wt3 43e8',
    0x18: 'push2 wt3 43ea',
    0x19: 'push2 wt3 43ec',
    0x1a: 'push2 wt3 43ee',
    0x1b: 'push2 wt3 43f0',
    0x1c: 'push2 wt3 43f2',
    0x1d: 'push2 wt3 43f4',
    0x1e: 'push2 wt3 43f6',
    0x1f: 'push2 wt3 43f8',
    0x20: 'push2 wt3 43fa',
    0x21: 'push2 wt3 43fc',
    0x22: 'push2 wt3 43fe',
    0x23: 'push2 wt3 4400',
    0x24: 'push2 wt3 4402',
    0x25: 'push2 wt3 4404',
    0x26: 'push2 wt3 4406',
    0x27: 'push2 wt3 4408',
    0x28: 'push2 wt3 440a',
    0x29: 'push2 wt3 440c',
    0x2a: 'push2 wt3 440e',
    0x2b: 'push2 wt3 4410',
    0x2c: 'push2 wt3 4412',
    0x2d: 'push2 wt3 4414',
    0x2e: 'push2 wt3 4416',
    0x2f: 'push2 wt3 4418',
    0x30: 'push2 wt3 441a',
    0x31: 'push2 wt3 441c',
    0x32: 'push2 wt3 441e',
    0x33: 'push2 wt3 4420',
    0x34: 'push2 wt3 4422',
    0x35: 'push2 wt3 4424',
    0x36: 'push2 wt3 4426',
    0x37: 'push2 wt3 4428',
    0x38: 'push2 wt3 442a',
    0x39: 'push2 wt3 442c',
    0x3a: 'push2 wt3 442e',
    0x3b: 'push2 wt3 4430',
    0x3c: 'push2 wt3 4432',
    0x3d: 'push2 wt3 4434',
    0x3e: 'push2 wt3 4436',
    0x3f: 'push2 wt3 4438',
    0x40: 'push2 wt3 443a',
    0x41: 'push2 wt3 443c',
    0x42: 'push2 wt3 443e',
    0x43: 'push2 wt3 4440',
    0x44: 'push2 wt3 4442',
    0x45: 'push2 wt3 4444',
    0x46: 'push2 wt3 4446',
    0x47: 'push wt1 4300',
    0x48: 'push wt1 4302',
    0x49: 'push wt1 4304',
    0x4a: 'push wt1 4306',
    0x4b: 'push wt1 4308',
    0x4c: 'push wt1 430a',
    0x4d: 'push wt1 430c',
    0x4e: 'push wt1 430e',
    0x4f: 'push wt1 4310',
    0x50: 'push wt1 4312',
    0x51: 'push wt1 4314',
    0x52: 'push wt1 4316',
    0x53: 'push wt1 4318',
    0x54: 'push wt1 431a',
    0x55: 'push wt1 431c',
    0x56: 'push wt1 431e',
    0x57: 'push wt1 4320',
    0x58: 'push wt1 4322',
    0x59: 'push v_items_in_inventory',
    0x5a: 'push wt1 4326',
    0x5b: 'push wt1 4328',
    0x5c: 'push wt1 432a',
    0x5d: 'push wt1 432c',
    0x5e: 'push wt1 432e',
    0x5f: 'push wt1 4330',
    0x60: 'push wt1 4332',
    0x61: 'push wt1 4334',
    0x62: 'push wt1 4336',
    0x63: 'push wt1 4338',
    0x64: 'push wt1 433a',
    0x65: 'push v_location',
    0x66: 'push wt1 433e',
    0x67: 'push wt1 4340',
    0x68: 'push wt1 4342',
    0x69: 'push wt1 4344',
    0x6a: 'push wt1 4346',
    0x6b: 'push wt1 4348',
    0x6c: 'push wt1 434a',
    0x6d: 'push wt1 434c',
    0x6e: 'push wt1 434e',
    0x6f: 'push wt1 4350',
    0x70: 'push wt1 4352',
    0x71: 'push wt1 4354',
    0x72: 'push wt1 4356',
    0x73: 'push wt1 4358',
    0x74: 'push wt1 435a',
    0x75: 'push wt1 435c',
    0x76: 'push wt1 435e',
    0x77: 'push wt1 4360',
    0x78: 'push wt1 4362',
    0x79: 'push wt1 4364',
    0x7a: 'push wt1 4366',
    0x7b: 'push v_turn_counter',
    0x7c: 'push wt1 436a',
    0x7d: 'push wt1 436c',
    0x7e: 'push wt1 436e',
    0x7f: 'push wt1 4370',
    0x80: 'push wt1 4372',
    0x81: 'push wt1 4374',
    0x82: 'push wt1 4376',
    0x83: 'push wt1 4378',
    0x84: 'push wt1 437a',
    0x85: 'cmp le',
    0x86: 'cmp lt',
    0x87: 'cmp ge',
    0x88: 'cmp gt',
    0x89: 'cmp eq',
    0x8a: 'cmp ne',
    0x8b: 'or',
    0x8c: 'and',
    0x8d: 'add',
    0x8e: 'sub',
    0x8f: 'mul',
    0x90: 'div',
    0x91: 'mod',
    0x92: 'abs',
    0x93: '1<<L',
    0x94: 'negate',
    0x95: 'complement',
    0x96: 'push byte BYTE',
    0x97: 'push word WORD',
    0x98: 'cond jump NZ far RELWORD',
    0x99: 'cond jump Z near RELBYTE',
    0x9b: 'store BYTE setjmp 5eb7 gosub 5c1f',
    0x9c: 'gosub 5c26 cond return or longjmp 5eb7',
    0xa1: 'jump RELWORD',
    0xa2: 'jump table',
    0xa4: '!= 0',
    0xa5: '== 0',
    0xa6: 'Code follows',
    0xa7: 'Return',
    # 0xa8 to 0xc7 are gosubs, listed above
    0xc8: 'lookup_opcode_c8_map',
    0xc9: 'lookup_opcode_c9_map',
    0xca: 'lookup_opcode_ca_map',
    0xcb: 'lookup_opcode_cb_map',
    0xcc: 'lookup_opcode_cc_map',
    0xcd: 'lookup_opcode_cd_map',
    0xce: 'lookup_opcode_ce_map',
    0xcf: 'lookup_opcode_cf_map',
    0xd0: 'lookup_opcode_d0_map',
    0xd1: 'lookup_opcode_d1_map',
    0xd2: 'lookup_opcode_d2_map',
    0xd3: 'lookup_opcode_d3_map',
    0xd4: 'lookup_opcode_d4_map',
    0xd5: 'lookup_opcode_d5_map',
    0xd6: 'lookup_opcode_d6_map',
    0xd7: 'lookup_opcode_d7_map',
    0xd8: 'lookup_opcode_d8_map',
    0xd9: 'lookup_score_message_sector_map',
    0xda: 'lookup_opcode_da_map',
    0xdb: 'lookup_opcode_db_map',
    0xdc: 'lookup_opcode_dc_map',
    0xdd: 'lookup_opcode_dd_map',
    0xde: 'lookup_opcode_de_map',
    0xdf: 'lookup_opcode_df_map',
    0xe0: 'lookup_long_desc_sector_map',
    0xe1: 'lookup_opcode_e1_map',
    0xe2: 'lookup_object_desc_sector_map',
    0xe3: 'lookup_special_msg_sector_map',
    0xe4: 'lookup_brief_desc_sector_map',
    0xe5: 'lookup_opcode_e5_map',
    0xe6: 'lookup_opcode_e6_map',
    0xe7: 'lookup_opcode_e7_map',
  }

  def disassemble(address, memory):
    instruction = Instruction.FromMemory(address=address, memory=memory)
    return instruction.disassemble()

  def opcode_length(opcode):
    if opcode in Opcodes.two_byte_opcodes:
      return 2
    elif opcode in Opcodes.three_byte_opcodes:
      return 3
    return 1
