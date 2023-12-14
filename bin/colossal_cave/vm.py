"""Colossal Cave Abstract Virtual Machine.

The Colossal Cave game implements a 16-bit Abstract Virtual Machine
which is intermixed among the z80 code. VM instructions are a single
byte long (see the Opcode class). The VM is primarily stack-based:
each 4-byte stack item consists of a 16-bit value and a 16-bit pointer.

The use of pushing pointers onto the stack is believed to support
call-by-reference.

The VM fetch-execute cycle is initiated by loading z80 register BC
with the address of the opcode to fetch, and DE with the top of stack,
then calling 0x5a18.
"""

class OpcodeError(Exception):
  """An opcode-related error, e.g. Unknown opcode."""

class Instruction(object):
  """A single instruction in memory.

  An Instruction is formed from the 1-3 bytes of memory which start with
  the opcode, at some known memory address.

  The Instruction is the Opcode, plus:
    * address
    * memory (at that address)
    * operand
    * next_address
  """

  def __init__(self, address:int, memory:bytes):
    """Return a new Instruction.

    Arguments:
      * address: The memory address of the instruction
      * memory: 3 bytes of memory at 'address'
    """

    self.address = address
    self.memory = memory
    try:
      self.opcode = Opcode(memory[0])
    except OpcodeError as e:
      raise OpcodeError(f'Address {address:04x} {e}')

    self.operand = None  # The implicit or explicit operand

    length = self.opcode.length
    opcode = self.opcode

    if length == 2:
      self.operand = memory[1]
    elif length == 3:
      self.operand = memory[1] + 256 * memory[2]

    if opcode.byte_relative:
      # Sign-extend the operand then compute relative address
      if self.operand >= 0x80:
        self.operand = 256 - self.operand
      self.operand = (self.address + 1 + self.operand) & 0xffff
    elif opcode.word_relative:
      # The operand is a relative address; compute it here
      self.operand = (self.address + 1 + self.operand) & 0xffff

  @property
  def next_address(self):
    return self.address + self.opcode.length

  def FromMemory(address:int, memory:'Memory') -> 'Instruction':
    """Instantiate an instruction from a slice of memory.

    Args:
      memory   An instance of debugger.Memory or similar

    Returns:

      An Instruction.
    """

    instruction = Instruction(address=address, memory=memory.memory_bytes(address, 3))

    return instruction

  def disassemble(self):
    """Return a string representation of an Instruction."""

    op_str = self.opcode.string
    operand = self.operand
    if 'BYTE' in op_str:
      op_str = op_str.replace('BYTE', f'[{operand:02x}]')
    elif 'ADDR' in op_str:
      op_str = op_str.replace('ADDR', f'[{operand:04x}]')
    elif 'WORD' in op_str:
      op_str = op_str.replace('WORD', f'[{operand:04x}]')

    return op_str

  def str1(self) -> str:
    """A disassembly of just the opcode and its operand (if any).

    Returns a string.
    """

    op_str = self.opcode.string
    return op_str

  def str2(self) -> str:
    """Return a disassembly of the instruction in the form:

    address    disassembly
    """

    op_str = self.opcode.string
    return f'{self.address:04x}  {op_str}'

class Opcode(object):
  """This class represents a Virtual Machine opcode.

  An opcode is an 8-bit integer, each with a unique operation. What is
  known about each opcode is represented in opcode_table below.

  Known opcodes fall into these general categories:

  ## Push a global variable onto the stack

  There are push opcodes for the global variables in Word Table 3
  and Word Table 1. The meaning of almost all global variables
  is unknown.

  ## Push a literal onto the stack

  Either a byte or a word value.

  ## 16-bit unary and binary math and logical operators

  Unary operators: negate (2's complement), complement (1's complement)

  Binary operators: or, and, add, sub, mul, div, mod, abs, 1<<L (shift
  right), <=, <, >=, >, ==, !=

  ## Control flow

  Conditional jumps (Z or NZ) and unconditional jumps.

  There are also some complex and unknown control flows.

  ## Lookup a map of some sort

  Some of the maps are known:

  * d9: Maps the score to the diskette sector containing the message
  * e0: Maps long descriptions to the sector containing the message
  * e2: Ditto for object descriptions
  * e3: Ditto for special messages
  * e4: Ditto for brief descriptions

  """

  # At present I don't know what the memory addresses refer to, so
  # the disassembly shows their hex value. When I understand the
  # purpose of an address, I'll replace the hex value with a symbolic
  # name.
  opcode_table = {
    0x00: {'s': 'push2 wt3 43ba', 'w': 0x43ba},
    0x01: {'s': 'push2 wt3 43bc', 'w': 0x43bc},
    0x02: {'s': 'push2 wt3 43be', 'w': 0x43be},
    0x03: {'s': 'push2 wt3 43c0', 'w': 0x43c0},
    0x04: {'s': 'push2 wt3 43c2', 'w': 0x43c2},
    0x05: {'s': 'push2 wt3 43c4', 'w': 0x43c4},
    0x06: {'s': 'push2 wt3 43c6', 'w': 0x43c6},
    0x07: {'s': 'push2 wt3 43c8', 'w': 0x43c8},
    0x08: {'s': 'push2 wt3 43ca', 'w': 0x43ca},
    0x09: {'s': 'push2 wt3 43cc', 'w': 0x43cc},
    0x0a: {'s': 'push2 wt3 43ce', 'w': 0x43ce},
    0x0b: {'s': 'push2 wt3 43d0', 'w': 0x43d0},
    0x0c: {'s': 'push2 wt3 43d2', 'w': 0x43d2},
    0x0d: {'s': 'push2 wt3 43d4', 'w': 0x43d4},
    0x0e: {'s': 'push2 wt3 43d6', 'w': 0x43d6},
    0x0f: {'s': 'push2 wt3 43d8', 'w': 0x43d8},
    0x10: {'s': 'push2 wt3 43da', 'w': 0x43da},
    0x11: {'s': 'push2 wt3 43dc', 'w': 0x43dc},
    0x12: {'s': 'push2 wt3 43de', 'w': 0x43de},
    0x13: {'s': 'push2 wt3 43e0', 'w': 0x43e0},
    0x14: {'s': 'push2 wt3 43e2', 'w': 0x43e2},
    0x15: {'s': 'push2 wt3 43e4', 'w': 0x43e4},
    0x16: {'s': 'push2 wt3 43e6', 'w': 0x43e6},
    0x17: {'s': 'push2 wt3 43e8', 'w': 0x43e8},
    0x18: {'s': 'push2 wt3 43ea', 'w': 0x43ea},
    0x19: {'s': 'push2 wt3 43ec', 'w': 0x43ec},
    0x1a: {'s': 'push2 wt3 43ee', 'w': 0x43ee},
    0x1b: {'s': 'push2 wt3 43f0', 'w': 0x43f0},
    0x1c: {'s': 'push2 wt3 43f2', 'w': 0x43f2},
    0x1d: {'s': 'push2 wt3 43f4', 'w': 0x43f4},
    0x1e: {'s': 'push2 wt3 43f6', 'w': 0x43f6},
    0x1f: {'s': 'push2 wt3 43f8', 'w': 0x43f8},
    0x20: {'s': 'push2 wt3 43fa', 'w': 0x43fa},
    0x21: {'s': 'push2 wt3 43fc', 'w': 0x43fc},
    0x22: {'s': 'push2 wt3 43fe', 'w': 0x43fe},
    0x23: {'s': 'push2 wt3 4400', 'w': 0x4400},
    0x24: {'s': 'push2 wt3 4402', 'w': 0x4402},
    0x25: {'s': 'push2 wt3 4404', 'w': 0x4404},
    0x26: {'s': 'push2 wt3 4406', 'w': 0x4406},
    0x27: {'s': 'push2 wt3 4408', 'w': 0x4408},
    0x28: {'s': 'push2 wt3 440a', 'w': 0x440a},
    0x29: {'s': 'push2 wt3 440c', 'w': 0x440c},
    0x2a: {'s': 'push2 wt3 440e', 'w': 0x440e},
    0x2b: {'s': 'push2 wt3 4410', 'w': 0x4410},
    0x2c: {'s': 'push2 wt3 4412', 'w': 0x4412},
    0x2d: {'s': 'push2 wt3 4414', 'w': 0x4414},
    0x2e: {'s': 'push2 wt3 4416', 'w': 0x4416},
    0x2f: {'s': 'push2 wt3 4418', 'w': 0x4418},
    0x30: {'s': 'push2 wt3 441a', 'w': 0x441a},
    0x31: {'s': 'push2 wt3 441c', 'w': 0x441c},
    0x32: {'s': 'push2 wt3 441e', 'w': 0x441e},
    0x33: {'s': 'push2 wt3 4420', 'w': 0x4420},
    0x34: {'s': 'push2 wt3 4422', 'w': 0x4422},
    0x35: {'s': 'push2 wt3 4424', 'w': 0x4424},
    0x36: {'s': 'push2 wt3 4426', 'w': 0x4426},
    0x37: {'s': 'push2 wt3 4428', 'w': 0x4428},
    0x38: {'s': 'push2 wt3 442a', 'w': 0x442a},
    0x39: {'s': 'push2 wt3 442c', 'w': 0x442c},
    0x3a: {'s': 'push2 wt3 442e', 'w': 0x442e},
    0x3b: {'s': 'push2 wt3 4430', 'w': 0x4430},
    0x3c: {'s': 'push2 wt3 4432', 'w': 0x4432},
    0x3d: {'s': 'push2 wt3 4434', 'w': 0x4434},
    0x3e: {'s': 'push2 wt3 4436', 'w': 0x4436},
    0x3f: {'s': 'push2 wt3 4438', 'w': 0x4438},
    0x40: {'s': 'push2 wt3 443a', 'w': 0x443a},
    0x41: {'s': 'push2 wt3 443c', 'w': 0x443c},
    0x42: {'s': 'push2 wt3 443e', 'w': 0x443e},
    0x43: {'s': 'push2 wt3 4440', 'w': 0x4440},
    0x44: {'s': 'push2 wt3 4442', 'w': 0x4442},
    0x45: {'s': 'push2 wt3 4444', 'w': 0x4444},
    0x46: {'s': 'push2 wt3 4446', 'w': 0x4446},
    0x47: {'s': 'push wt1 4300', 'w': 0x4300},
    0x48: {'s': 'push wt1 4302', 'w': 0x4302},
    0x49: {'s': 'push wt1 4304', 'w': 0x4304},
    0x4a: {'s': 'push wt1 4306', 'w': 0x4306},
    0x4b: {'s': 'push wt1 4308', 'w': 0x4308},
    0x4c: {'s': 'push wt1 430a', 'w': 0x430a},
    0x4d: {'s': 'push wt1 430c', 'w': 0x430c},
    0x4e: {'s': 'push wt1 430e', 'w': 0x430e},
    0x4f: {'s': 'push wt1 4310', 'w': 0x4310},
    0x50: {'s': 'push wt1 4312', 'w': 0x4312},
    0x51: {'s': 'push wt1 4314', 'w': 0x4314},
    0x52: {'s': 'push wt1 4316', 'w': 0x4316},
    0x53: {'s': 'push wt1 4318', 'w': 0x4318},
    0x54: {'s': 'push wt1 431a', 'w': 0x431a},
    0x55: {'s': 'push wt1 431c', 'w': 0x431c},
    0x56: {'s': 'push wt1 431e', 'w': 0x431e},
    0x57: {'s': 'push wt1 4320', 'w': 0x4320},
    0x58: {'s': 'push wt1 4322', 'w': 0x4322},
    0x59: {'s': 'push v_items_in_inventory', 'w': 0x4344},
    0x5a: {'s': 'push wt1 4326', 'w': 0x4326},
    0x5b: {'s': 'push wt1 4328', 'w': 0x4328},
    0x5c: {'s': 'push wt1 432a', 'w': 0x432a},
    0x5d: {'s': 'push wt1 432c', 'w': 0x432c},
    0x5e: {'s': 'push wt1 432e', 'w': 0x432e},
    0x5f: {'s': 'push wt1 4330', 'w': 0x4330},
    0x60: {'s': 'push wt1 4332', 'w': 0x4332},
    0x61: {'s': 'push wt1 4334', 'w': 0x4334},
    0x62: {'s': 'push wt1 4336', 'w': 0x4336},
    0x63: {'s': 'push wt1 4338', 'w': 0x4338},
    0x64: {'s': 'push wt1 433a', 'w': 0x433a},
    0x65: {'s': 'push v_location', 'w': 0x433c},
    0x66: {'s': 'push wt1 433e', 'w': 0x433e},
    0x67: {'s': 'push wt1 4340', 'w': 0x4340},
    0x68: {'s': 'push wt1 4342', 'w': 0x4342},
    0x69: {'s': 'push wt1 4344', 'w': 0x4344},
    0x6a: {'s': 'push wt1 4346', 'w': 0x4346},
    0x6b: {'s': 'push wt1 4348', 'w': 0x4348},
    0x6c: {'s': 'push wt1 434a', 'w': 0x434a},
    0x6d: {'s': 'push wt1 434c', 'w': 0x434c},
    0x6e: {'s': 'push wt1 434e', 'w': 0x434e},
    0x6f: {'s': 'push wt1 4350', 'w': 0x4350},
    0x70: {'s': 'push wt1 4352', 'w': 0x4352},
    0x71: {'s': 'push wt1 4354', 'w': 0x4354},
    0x72: {'s': 'push wt1 4356', 'w': 0x4356},
    0x73: {'s': 'push wt1 4358', 'w': 0x4358},
    0x74: {'s': 'push wt1 435a', 'w': 0x435a},
    0x75: {'s': 'push wt1 435c', 'w': 0x435c},
    0x76: {'s': 'push wt1 435e', 'w': 0x435e},
    0x77: {'s': 'push wt1 4360', 'w': 0x4360},
    0x78: {'s': 'push wt1 4362', 'w': 0x4362},
    0x79: {'s': 'push wt1 4364', 'w': 0x4364},
    0x7a: {'s': 'push wt1 4366', 'w': 0x4366},
    0x7b: {'s': 'push v_turn_counter', 'w': 0x4368},
    0x7c: {'s': 'push wt1 436a', 'w': 0x436a},
    0x7d: {'s': 'push wt1 436c', 'w': 0x436c},
    0x7e: {'s': 'push wt1 436e', 'w': 0x436e},
    0x7f: {'s': 'push wt1 4370', 'w': 0x4370},
    0x80: {'s': 'push wt1 4372', 'w': 0x4372},
    0x81: {'s': 'push wt1 4374', 'w': 0x4374},
    0x82: {'s': 'push wt1 4376', 'w': 0x4376},
    0x83: {'s': 'push wt1 4378', 'w': 0x4378},
    0x84: {'s': 'push wt1 437a', 'w': 0x437a},
    0x85: {'s': 'cmp le', 'stack_count': 2},
    0x86: {'s': 'cmp lt', 'stack_count': 2},
    0x87: {'s': 'cmp ge', 'stack_count': 2},
    0x88: {'s': 'cmp gt', 'stack_count': 2},
    0x89: {'s': 'cmp eq', 'stack_count': 2},
    0x8a: {'s': 'cmp ne', 'stack_count': 2},
    0x8b: {'s': 'or', 'stack_count': 2},
    0x8c: {'s': 'and', 'stack_count': 2},
    0x8d: {'s': 'add', 'stack_count': 2},
    0x8e: {'s': 'sub', 'stack_count': 2},
    0x8f: {'s': 'mul', 'stack_count': 2},
    0x90: {'s': 'div', 'stack_count': 2},
    0x91: {'s': 'mod', 'stack_count': 2},
    0x92: {'s': 'abs', 'stack_count': 1},
    0x93: {'s': '1<<L', 'stack_count': 1},
    0x94: {'s': 'negate', 'stack_count': 1},
    0x95: {'s': 'complement', 'stack_count': 1},
    0x96: {'s': 'push byte BYTE', 'length': 2},
    0x97: {'s': 'push word WORD', 'length': 3},
    # Conditions:
    #   NZ: hl != 0
    #   Z:  hl == 0
    0x98: {'s': 'cond jump True far ADDR', 'length': 3, 'word_relative': True, 'is_cond_jump': True},
    0x99: {'s': 'cond jump False near ADDR', 'length': 2, 'byte_relative': True, 'is_cond_jump': True},
    0x9a: {'s': 'unknown opcode 0x9a'},
    # 0x9b:
    #   Pop 2 arguments off stack
    #   Store next literal byte in various places
    #   Save next PC in 0x5eb7
    #   Gosub 0x5c1f
    #   Continue
    0x9b: {'s': 'store BYTE setjmp 5eb7 gosub 5c1f', 'length': 2, 'stack_count': 2},
    # Gosub 5c26 then either continue or goto contents of address 5eb7
    # longjmp if byte at 0x5b5e != register c
    0x9c: {'s': 'gosub 5c26 then cond longjmp 5eb7'},
    # 0x9d:
    #   Pop 1 argument off stack
    #   Pop another argument off stack, into BC
    0x9d: {'s': 'unknown opcode 0x9d', 'stack_count': 2},
    0x9e: {'s': 'unknown opcode 0x9e', 'stack_count': 1},
    0x9f: {'s': 'unknown opcode 0x9f', 'stack_count': 1},
    # 0xa0:
    #   Pop 1 argument off stack
    #   Execute opcode 0x71 (push wt1 4354)
    #   Then (z80) jump to 0x5b63
    0xa0: {'s': 'unknown opcode 0xa0'},
    # Jump to relative address in next 2 bytes
    0xa1: {'s': 'jump ADDR', 'length': 3, 'word_relative': True, 'is_jump': True},
    # Jump table [n]: This is a variable-length opcode.
    # pc = 0xa2
    # pc + 1 = number of table entries
    # Following words are code entrypoints relative to the address of each word
    0xa2: {'s': 'jump table size=BYTE', 'length': 2, 'is_jump_table': True},
    0xa4: {'s': '!= 0', 'stack_count': 1},
    0xa5: {'s': '== 0', 'stack_count': 1},
    0xa6: {'s': 'Code follows', 'is_code_follows': True},
    0xa7: {'s': 'Return', 'is_return': True},

    # 0xa8 to 0xc7 are gosubs
    0xa8: {'s': 'gosub 7670', 'gosub_addr': 0x7670},
    0xa9: {'s': 'gosub 7673', 'gosub_addr': 0x7673},
    0xaa: {'s': 'gosub 7676', 'gosub_addr': 0x7676},
    0xab: {'s': 'gosub 5f1f', 'gosub_addr': 0x5f1f},
    0xac: {'s': 'gosub 5f5b', 'gosub_addr': 0x5f5b},
    0xad: {'s': 'gosub 7877', 'gosub_addr': 0x7877},
    0xae: {'s': 'gosub 77ec', 'gosub_addr': 0x77ec},
    0xaf: {'s': 'gosub 5f67', 'gosub_addr': 0x5f67},
    0xb0: {'s': 'gosub 782b', 'gosub_addr': 0x782b},
    0xb1: {'s': 'gosub 77a7', 'gosub_addr': 0x77a7},
    0xb2: {'s': 'gosub 5f63', 'gosub_addr': 0x5f63},
    0xb3: {'s': 'gosub wait_input_line', 'gosub_addr': 0x798a},
    0xb4: {'s': 'gosub 5f15', 'gosub_addr': 0x5f15},
    0xb5: {'s': 'gosub 77aa', 'gosub_addr': 0x77aa},
    0xb6: {'s': 'gosub 5f3b', 'gosub_addr': 0x5f3b},
    0xb7: {'s': 'gosub 5f2b', 'gosub_addr': 0x5f2b},
    0xb8: {'s': 'gosub 5f46', 'gosub_addr': 0x5f46},
    0xb9: {'s': 'gosub 7695', 'gosub_addr': 0x7695},
    0xba: {'s': 'gosub 76a3', 'gosub_addr': 0x76a3},
    0xbb: {'s': 'gosub 77bc', 'gosub_addr': 0x77bc},
    0xbc: {'s': 'gosub 5f77', 'gosub_addr': 0x5f77},
    0xbd: {'s': 'gosub 7953', 'gosub_addr': 0x7953},
    0xbe: {'s': 'gosub 77e5', 'gosub_addr': 0x77e5},
    0xbf: {'s': 'gosub random_n', 'gosub_addr': 0x785d},
    0xc0: {'s': 'gosub print_a_general_message', 'gosub_addr': 0x7980},
    0xc1: {'s': 'gosub print_a_message', 'gosub_addr': 0x7895},
    0xc2: {'s': 'gosub 5f11', 'gosub_addr': 0x5f11},
    0xc3: {'s': 'gosub 76b1', 'gosub_addr': 0x76b1},
    0xc4: {'s': 'gosub ask_a_yes_or_no_question', 'gosub_addr': 0x79fd},
    0xc5: {'s': 'gosub print_introduction_message', 'gosub_addr': 0x7a64},
    0xc6: {'s': 'gosub 7a68', 'gosub_addr': 0x7a68},
    0xc7: {'s': 'gosub 7a69', 'gosub_addr': 0x7a69},

    0xc8: {'s': 'lookup_opcode_c8_map'},
    0xc9: {'s': 'lookup_opcode_c9_map'},
    0xca: {'s': 'lookup_opcode_ca_map'},
    0xcb: {'s': 'lookup_opcode_cb_map'},
    0xcc: {'s': 'lookup_opcode_cc_map'},
    0xcd: {'s': 'lookup_opcode_cd_map'},
    0xce: {'s': 'lookup_opcode_ce_map'},
    0xcf: {'s': 'lookup_opcode_cf_map'},
    0xd0: {'s': 'lookup_opcode_d0_map'},
    0xd1: {'s': 'lookup_opcode_d1_map'},
    0xd2: {'s': 'lookup_opcode_d2_map'},
    0xd3: {'s': 'lookup_opcode_d3_map'},
    0xd4: {'s': 'lookup_opcode_d4_map'},
    0xd5: {'s': 'lookup_opcode_d5_map'},
    0xd6: {'s': 'lookup_opcode_d6_map'},
    0xd7: {'s': 'lookup_opcode_d7_map'},
    0xd8: {'s': 'lookup_opcode_d8_map'},
    0xd9: {'s': 'lookup_score_message_sector_map'},
    0xda: {'s': 'lookup_opcode_da_map'},
    0xdb: {'s': 'lookup_opcode_db_map'},
    0xdc: {'s': 'lookup_opcode_dc_map'},
    0xdd: {'s': 'lookup_opcode_dd_map'},
    0xde: {'s': 'lookup_opcode_de_map'},
    0xdf: {'s': 'lookup_opcode_df_map'},
    0xe0: {'s': 'lookup_long_desc_sector_map'},
    0xe1: {'s': 'lookup_opcode_e1_map'},
    0xe2: {'s': 'lookup_object_desc_sector_map'},
    0xe3: {'s': 'lookup_special_msg_sector_map'},
    0xe4: {'s': 'lookup_brief_desc_sector_map'},
    0xe5: {'s': 'lookup_opcode_e5_map'},
    0xe6: {'s': 'lookup_opcode_e6_map'},
    0xe7: {'s': 'lookup_opcode_e7_map'},
    0xe8: {'s': 'unknown opcode 0xe8'},
    0xe9: {'s': 'unknown opcode 0xe9'},
    0xea: {'s': 'unknown opcode 0xea'},
    0xeb: {'s': 'unknown opcode 0xeb'},
    0xec: {'s': 'unknown opcode 0xec'},
  }

  def __init__(self, opcode:int):
    """Return a new Opcode.

    Arguments:
      * opcode: The 8-bit value of the opcode.

    Raises:
      OpcodeError: If the opcode number is unknown.
    """

    if opcode not in Opcode.opcode_table:
      raise OpcodeError(f'Unknown opcode {opcode:02x}')

    desc = Opcode.opcode_table[opcode]
    self.opcode = opcode
    self.desc = desc

    if 'length' in desc:
      self._length = desc['length']
    else:
      self._length = 1

    # stack_count is the number of on-stack operands (if known)
    if 'stack_count' in desc:
      self.stack_count = desc['stack_count']
    else:
      self.stack_count = 0

    # 'w' is the address of a word (probably to be pushed)
    if 'w' in desc:
      self.word_address = desc['w']
    else:
      self.word_address = None

    # Set defaults for all these attributes
    self.gosub_addr = None
    self.is_cond_jump = False
    self.is_gosub = False
    self.is_jump = False
    self.byte_relative = False
    self.word_relative = False

    if 'gosub_addr' in desc:
      # Figure out implicit operand (gosubs)
      self.gosub_addr = desc['gosub_addr']
      self.is_gosub = True
    elif 'byte_relative' in desc:
      self.byte_relative = desc['byte_relative']
    elif 'word_relative' in desc:
      self.word_relative = desc['word_relative']

    if 'is_jump' in desc:
      self.is_jump = desc['is_jump']
    elif 'is_cond_jump' in desc:
      self.is_cond_jump = desc['is_cond_jump']

  def disassemble(address:int, memory:bytes):
    """Construct an Instruction, and disassemble it.

    Arguments:
      * address: The address of the memory area
      * memory: 3 bytes of memory starting at 'address'

    Returns:
      The disassembly of the instruction.
    """

    instruction = Instruction.FromMemory(address=address, memory=memory)
    return instruction.disassemble()

  def opcode_length(opcode:int):
    """Return the length of the opcode number."""
    return Opcode(opcode).length

  @property
  def is_code_follows(self) -> bool:
    """Returns True if this opcode is a code_follows instruction."""
    if 'is_code_follows' in self.desc:
      return self.desc['is_code_follows']

    return False

  @property
  def is_jump_table(self) -> bool:
    """Returns True if a jump table follows this opcode in memory.

    This is a terminating instruction (like a jump). A disassembler must
    parse the following bytes to find all possible jump addresses.
    """
    if 'is_jump_table' in self.desc:
      return self.desc['is_jump_table']

    return False

  @property
  def is_return(self) -> bool:
    """Returns True if this opcode is a return instruction."""
    if 'is_return' in self.desc:
      return self.desc['is_return']

    return False

  @property
  def length(self):
    """The length of this opcode, in bytes."""

    return self._length

  @property
  def string(self):
    """The string representation of this opcode.

    This does not include any substitutions for operands, e.g.

    >>> print(Opcode(0x96).string)
    'push byte BYTE'
    """

    return self.desc['s']

class Debug(object):
  """A Debugger controller for the bytecode virtual machine."""

  def __init__(self, dbg):
    """Return a new instance of Debug.

    Arguments:

      * dbg:   An instance of Debugger.
    """

    self._have_registers = False
    self.breakpoints = {}
    self.memory = dbg.all_memory()
    self.traces = {}
    self.dbg = dbg
    self._pc = None
    self._sp = None

    self.dbg.add_breakpoint('5a19', self._fetch_exec_loop)

  def _fetch_exec_loop(self):
    """This is called each time an opcode is fetched, before execution.

    It runs all configured breakpoint functions for that program counter,
    then it runs all configured trace functions. Any trace function which
    does not return True is removed from the list of trace functions.

    In future, breakpoint functions will have to return True.
    """
    self._have_registers = False
    self.dbg.get_registers()
    pc = self.dbg.get_reg_bc()
    self._pc = pc
    self._sp = self.dbg.get_reg_de()

    if pc in self.breakpoints:
      # Run one or more breakpoint functions
      for func in list(self.breakpoints[pc]):
        func()

    for func in list(self.traces):
      if not func():
        del self.traces[func]


  def add_breakpoint(self, addr:int, func):
    """Set a breakpoint at 'addr'.

    When fetching the bytecode at 'addr', call func().
    """
    if addr not in self.breakpoints:
      self.breakpoints[addr] = []
    self.breakpoints[addr].append(func)

  def add_trace(self, func):
    """Trace every instruction.

    Calls func() after all breakpoint functions have been called.

    The trace is deleted unless the function returns True.
    """
    self.traces[func] = func

  @property
  def pc(self) -> int:
    """The current VM program counter (integer)."""
    return self._pc

  @property
  def sp(self) -> int:
    """The current VM stack pointer (integer)."""
    return self._sp

  def instruction(self) -> 'Instruction':
    """Return the currently about to be executed instruction as an Instruction."""

    return Instruction(address=self.pc, memory=self.memory.memory_bytes(self.pc, 3))

  def stack(self, offset:int) -> (int,int):
    """Return the 2 16-bit values in the stack at relative 'offset'.

    Since each stack item occupies 4 bytes, offset is multiplied by 4
    to find the memory addresses to read:

    start_ptr = sp + 4 * offset

    e.g. (pointer, value) = x.stack(1)
    """
    start_addr = self.sp + 4 * offset
    value = self.memory.word(start_addr)
    pointer = self.memory.word(start_addr + 2)

    return (value, pointer)
