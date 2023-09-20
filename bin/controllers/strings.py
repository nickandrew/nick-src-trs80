"""Traces string printing and disk I/O."""

def hex2int(s):
  """Convert a 2-digit or 4-digit hex string to an integer."""
  return int(s, 16)


class Controller(object):
  """A Controller executes a debugging scenario - setting breakpoints, running code etc."""

  def __init__(self, dbg):
    self.dbg = dbg
    self.string = []
    self.last_read_sector_id = 0

  def init(self):
    """Set up debugging."""
    self.dbg.add_breakpoint('78e7', self.set_random1)
    self.dbg.add_breakpoint('78ea', self.start_of_string)
    self.dbg.add_breakpoint('7909', self.set_random1)
    self.dbg.add_breakpoint('792c', self.get_one_enc_char)
    self.dbg.add_breakpoint('7947', self.decode_char_end)
    self.dbg.add_breakpoint('7951', self.decode_char)
    self.dbg.add_breakpoint('7ce3', self.set_next_sector)
    self.dbg.add_breakpoint('7d4b', self.read_sector)

  def read_sector(self):
    self.dbg.get_registers()
    bc = self.dbg.get_reg_bc()
    hl = self.dbg.get_reg_hl()
    self.last_read_sector_id = bc
    print(f'  Read sector:  BC = {bc:04x}, HL = {hl:04x}')

  def get_one_enc_char(self):
    self.dbg.get_registers()
    self.enc_char = self.dbg.get_reg_a()

  def decode_char(self):
    self.dbg.get_registers()
    self.string.append((self.enc_char, self.dbg.get_reg_a()))

  def decode_char_end(self):
    s = b''
    raw_data = []
    for (raw,final) in self.string:
      s = s + final.to_bytes(1,'big')
      raw_data.append(f'{raw:02x}')
    print(f'Decode string: {s}')
    s2 = '[' + ' '.join(raw_data) + ']'
    print(f'Raw data: {s2}')
    self.string = []


  def set_next_sector(self):
    self.dbg.get_registers()
    bc = self.dbg.get_reg_bc()
    print(f'  Set next sector:  BC = {bc:04x} (within disk: {(bc+0x6d):04x})')

  def set_random1(self):
    self.dbg.get_registers()
    hl = self.dbg.get_reg_hl()
    pc = self.dbg.get_reg_pc()
    self.random1 = hl
    print(f'  Set random1:  HL = {hl:04x} at PC {pc:04x}')

  def start_of_string(self):
    # The next instruction is 'pop hl' which should be the start of the memory
    # location of the string to be printed. As we stopped just before the pop,
    # we have to get the value off the stack
    self.dbg.get_registers()
    sp = self.dbg.get_reg_sp()
    mem = self.dbg.memory(sp, 2)
    self.start_of_string = hex2int(mem[1] + mem[0])
    print(f'Memory at {sp:04x}: {mem} -- start of string {self.start_of_string:04x}')
    # Figure out the location within the data dump - starts 63 sectors after start of disk
    # Boot sector: size 1
    # Code: size 62
    # Save game 2: size 23 (data dump starts here)
    # Save game 1: size 23

    string_offset = (self.last_read_sector_id - 0x3f) * 256 + (self.start_of_string - 0x4724)
    print(f'Try looking for this string at {string_offset:04x} in the dump')
