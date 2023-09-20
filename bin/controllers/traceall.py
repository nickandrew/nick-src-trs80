"""Traces virtual machine opcode fetch and execute loop."""

import os.path
import re
import time

two_byte_opcodes = [0x96, 0x99, 0x9b];
three_byte_opcodes = [0x97, 0x98, 0xa1];

class Controller(object):
  """A Controller executes a debugging scenario - setting breakpoints, running code etc."""

  def __init__(self, dbg):
    self.dbg = dbg
    self.trace_count = 0
    self.slots_used = 0
    self.last_report = None
    if os.path.exists('memory-map'):
      with open('memory-map', 'rb') as ifp:
        mmap = ifp.read()
        self.memory_map = bytearray(mmap)
        self.slots_used = self.count_slots()
        print(f'Loaded {self.slots_used} slots')
    else:
      self.memory_map = bytearray(0x10000)

  def init(self):
    """Set up debugging."""
    self.dbg.add_breakpoint('5a00', self.entrypoint)
    self.dbg.add_breakpoint('5a19', self.fetch_opcode)

  def entrypoint(self):
    self.dbg.traceon(self.trace)

  def count_slots(self):
    count = 0
    for address in range(0x5a00, 0x8100):
      if self.memory_map[address] != 0:
        count = count + 1

    return count

  def always_report(self, stream):
    r_start = None
    r_end = None
    r_state = 'closed'
    for address in range(0x5a00, 0x8100):
      m = self.memory_map[address]
      if r_state == 'closed':
        if m == 1:
          r_state = 'code'
          r_start = address
        elif m == 2:
          r_state = 'opcode'
          r_start = address
        else:
          pass
      elif r_state == 'code':
        if m == 1:
          pass
        elif m == 2:
          r_end = address - 1
          print(f'Code from {r_start:04x} to {r_end:04x}', file=stream)
          r_state = 'opcode'
          r_start = address
        else:
          r_end = address - 1
          print(f'Code from {r_start:04x} to {r_end:04x}', file=stream)
          r_state = 'closed'
      else: # r_state == 'opcode'
        if m == 1:
          r_end = address - 1
          print(f'Opcodes from {r_start:04x} to {r_end:04x}', file=stream)
          r_state = 'code'
          r_start = address
        elif m == 2:
          pass
        else:
          r_end = address - 1
          print(f'Opcodes from {r_start:04x} to {r_end:04x}', file=stream)
          r_state = 'closed'

  def report(self):
    current_count = self.count_slots()

    if current_count <= self.slots_used:
      return

    now = time.time()
    if not self.last_report or self.last_report < now - 60:
      print(f'Using {current_count} slots')
      self.slots_used = current_count
      with open('memory-map', 'wb') as ofp:
        ofp.write(self.memory_map)
      with open('report.txt', 'w') as report_file:
        self.always_report(report_file)
      print('Reported')
      self.last_report = now


  def trace(self, line):
    self.trace_count = self.trace_count + 1
    if self.trace_count % 100000 == 0:
      self.report()

    m = re.match(r'([0-9a-fA-F]{4})  (..) (..) (..) (..)', line)
    if m:
      addr = int(m.group(1), 16)
      for i in range(2,6):
        s = m.group(i)
        if s == '  ':
          break

        self.memory_map[addr] = 1
        addr = addr + 1

  def fetch_opcode(self):
    self.dbg.get_registers()
    bc = self.dbg.get_reg_bc()
    opcode = self.dbg.get_reg_a()

    self.memory_map[bc] = 2

    if opcode in two_byte_opcodes:
      self.memory_map[bc + 1] = 2

    if opcode in three_byte_opcodes:
      self.memory_map[bc + 1] = 2
      self.memory_map[bc + 2] = 2
