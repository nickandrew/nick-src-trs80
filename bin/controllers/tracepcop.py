"""Trace z80 PC and bytecode sequence.

I'll use it to figure out why the game is failing when I insert 1
byte into the code area.

Output one line for each instruction fetch (and each opcode fetch),
with a normalised address. Skip certain address ranges including
ROM, DOS, and interrupt handlers.

{address:04x} pc|op
"""

import os.path
import re
import time

import colossal_cave.vm
import controllers.input
from helpers import control_flow


class Controller(object):
  """A Controller executes a debugging scenario - setting breakpoints, running code etc."""

  def __init__(self, dbg):
    self.dbg = dbg

    # Set up ranges of addresses which won't be traced
    self.exclude_list = control_flow.ExcludeList([
      [0x0038, 0x0038],
      [0x0060, 0x0066],  # Input handler
      [0x0000, 0x3fff],  # The whole ROM
      [0x4012, 0x4012],  # Interrupt vector
      # [0x4200, 0x51ff],  # DOS area
      [0x7b07, 0x7b47],  # Division routine with interior jumps
      [0x7d9e, 0x7ea2],  # Disk I/O inner loop
      [0x7e2a, 0x7e4d],  # Input handler
      [0x7e84, 0x7e89],  # Watches the A' value from the interrupt handler
      [0x7f60, 0x7f7b],  # Interrupt handler
    ])

    self.control_flow_pc = control_flow.FlowOfControl(
      exclude_list = self.exclude_list,
      report_file = 'junk-output-1',
      start_address = 0x5300,
      offset = 0,
    )

    self.dbg.add_module('input', controllers.input)

  def init(self):
    """Set up debugging."""
    self.dbg.add_breakpoint('5a00', self.entrypoint)
    self.dbg.add_breakpoint('5a19', self.fetch_opcode)
    input_mod = self.dbg.modules['input']

    for line in ["", "YES", "", "E", "GET LAMP", "__EOF__"]:
      input_mod.add_input(text=line)


  def entrypoint(self):
    self.dbg.traceon(self.trace)


  def trace(self, line):
    """trace is called once for every z80 instruction executed."""

    m = re.match(r'([0-9a-fA-F]{4})  (..) (..) (..) (..)', line)
    if m:
      addr = int(m.group(1), 16)
      reported = self.control_flow_pc.translate(addr)
      if not self.exclude_list.isset(reported):
        print(f'{reported:04x}  pc', flush=True)


  def fetch_opcode(self):
    """fetch_opcode is called at the entry of the fetch/execute loop."""
    self.dbg.get_registers()
    bc = self.dbg.get_reg_bc()
    a = self.dbg.get_reg_a()

    reported = self.control_flow_pc.translate(bc)
    if not self.exclude_list.isset(reported):
      print(f'{reported:04x}  op {a:02x}', flush=True)
