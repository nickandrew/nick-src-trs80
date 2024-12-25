"""Trace z80 PC and bytecode flow of control.

I'll use it to figure out why the game is failing when I insert 1
byte into the code area.

Only trace jumps. Periodically write a text report which lists all
the from-to jump pairs.

{address:04x} pc|op
"""

import os.path
import re
import time

import colossal_cave.vm
from helpers import control_flow


class Controller(object):
  """A Controller executes a debugging scenario - setting breakpoints, running code etc."""

  def __init__(self, dbg):
    self.dbg = dbg
    self.trace_count = 0

    # Set up ranges of addresses which won't be traced
    self.exclude_list = control_flow.ExcludeList([
      [0x0038, 0x0038],
      [0x0060, 0x0066],  # Input handler
      [0x0000, 0x3fff],  # The whole ROM
      [0x4012, 0x4012],  # Interrupt vector
      [0x7e2a, 0x7e4d],  # Input handler
      [0x7e84, 0x7e89],  # Watches the A' value from the interrupt handler
      [0x7f60, 0x7f7b],  # Interrupt handler
    ])

    self.control_flow_pc = control_flow.FlowOfControl(
      exclude_list = self.exclude_list,
      report_file = 'flow-pc-1.txt',
      start_address = 0x5a00,
      offset = 0,
    )

    self.control_flow_op = control_flow.FlowOfControl(
      exclude_list = self.exclude_list,
      report_file = 'flow-op-1.txt',
      start_address = 0x5a00,
      offset = 0,
    )


  def init(self):
    """Set up debugging."""
    self.dbg.add_breakpoint('5a00', self.entrypoint)
    self.dbg.add_breakpoint('5a19', self.fetch_opcode)


  def entrypoint(self):
    self.dbg.traceon(self.trace)


  def trace(self, line):
    """trace is called once for every z80 instruction executed."""

    self.trace_count = self.trace_count + 1
    if self.trace_count % 50000 == 0:
      self.control_flow_pc.report()
      self.control_flow_op.report()

    m = re.match(r'([0-9a-fA-F]{4})  (..) (..) (..) (..)', line)
    if m:
      addr = int(m.group(1), 16)
      self.control_flow_pc.update(addr)


  def fetch_opcode(self):
    """fetch_opcode is called at the entry of the fetch/execute loop."""
    self.dbg.get_registers()
    bc = self.dbg.get_reg_bc()

    self.control_flow_op.update(bc)
