"""Debugger harness module."""

import re
import subprocess

class DebuggerError(Exception):
  """A Debugger specific exception."""

class NoSuchModule(DebuggerError):
  """A registered module was requested which is unknown."""

class Zbx(object):
  """An instance of the zbx debugger, running in a subprocess."""

  def __init__(self, command):
    self.command = command
    print(f'Command is {command}')
    self.sp = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=False, bufsize=0, close_fds=True)
    self.breakpoints = {}
    self.modules = {}
    self.trace_func = None

  def cmd(self, cmd):
    self.sp.stdin.write(bytes(cmd + '\n', 'utf-8'))

  def output(self):
    """Generator function returning the subprocess's STDOUT, one line at a time."""
    buf = ''
    while not buf.startswith('(zbx) '):
      b = self.sp.stdout.read(100)
      if b == b'':
        # EOF, return
        return
      s = str(b, 'utf-8')
      buf = buf + s
      while '\n' in buf:
        l = buf.index('\n')
        yield buf[0:l]
        buf = buf[l+1:]

  def read_prompt(self):
    buf = ''
    for line in self.output():
      buf = buf + line

  def run_until_prompt(self):
    break_location = None
    for line in self.output():

      # Implement tracing
      if self.trace_func:
        self.trace_func(line)

      m = re.match('Stopped at ([0-9a-fA-F]+)', line)
      if m:
        break_location = m.group(1)

    if break_location:
      # print(f'Breakpoint hit at {break_location}')
      if break_location in self.breakpoints:
        # Run one or more breakpoint functions
        for func in self.breakpoints[break_location]:
          func()
      else:
        print(f'Breakpoint hit at unknown location {break_location}')

  def get_registers(self):
    """Retrieve all register values.

    dump output looks like:

           S Z - H - PV N C   IFF1 IFF2 IM
    Flags: 0 0 0 0 0  0 0 0     0    0   0

    A F: 00 00    IX: 0000    AF': 0000
    B C: 00 00    IY: 0000    BC': 0000
    D E: 00 00    PC: 0000    DE': 0000
    H L: 00 00    SP: 0000    HL': 0000

    T-state counter: 0    Delay setting: 0 (fixed)
    """


    self.cmd('dump')
    self.reg_b = None
    self.reg_c = None
    self.reg_h = None
    self.reg_l = None
    for line in self.output():
      m = re.match(r"A F: (..) (..) * IX: (....) * AF': (....)", line)
      if m:
        self.reg_a = int(m.group(1), 16)
        self.reg_f = int(m.group(2), 16)
        self.reg_ix = int(m.group(3), 16)
        self.reg_afprime = int(m.group(4), 16)
        continue
      m = re.match(r"B C: (..) (..) * IY: (....) * BC': (....)", line)
      if m:
        self.reg_b = int(m.group(1), 16)
        self.reg_c = int(m.group(2), 16)
        self.reg_iy = int(m.group(3), 16)
        self.reg_bcprime = int(m.group(4), 16)
        continue
      m = re.match(r"D E: (..) (..) * PC: (....) * DE': (....)", line)
      if m:
        self.reg_d = int(m.group(1), 16)
        self.reg_e = int(m.group(2), 16)
        self.reg_pc = int(m.group(3), 16)
        self.reg_deprime = int(m.group(4), 16)
        continue
      m = re.match(r"H L: (..) (..) * SP: (....) * HL': (....)", line)
      if m:
        self.reg_h = int(m.group(1), 16)
        self.reg_l = int(m.group(2), 16)
        self.reg_sp = int(m.group(3), 16)
        self.reg_hlprime = int(m.group(4), 16)
        continue

  def memory(self, start_address, size):
    """Retrieve memory contents.

    Memory dumps look like this:
    (zbx) 0/25
    0000:   f3 af c3 74 06 c3 00 40 c3 00 40 e1 e9 c3 9f 06     ...t...@..@.....
    0010:   c3 03 40 c5 06 01 18 2e c3 06 40 c5 06 02 18 26     ..@.......@....&
    0020:   c3 09 40 c5 06                                      ..@..

    (zbx) 42e0/2
    42e0:   9a 47                                               .G


    Return an array of 2-character hex strings (for convenience printing).
    """

    if size <= 0:
      return []

    self.cmd(f'{start_address:04x}/{size:x}')
    text = ''
    r = []
    for line in self.output():
      text = text + line + '\n'
      m = re.match(r'([0-9a-fA-F]{4}):\t(.{48})', line)
      if m:
        m2 = re.match(r'(..) (..) (..) (..) (..) (..) (..) (..) (..) (..) (..) (..) (..) (..) (..) (..) ', m.group(2))
        for i in range(16):
          ch = m2.group(i + 1)
          if ch != '  ':
            r.append(ch)

    return r

  def get_reg_a(self):
    return self.reg_a

  def get_reg_b(self):
    return self.reg_b

  def get_reg_c(self):
    return self.reg_c

  def get_reg_bc(self):
    return self.reg_b * 256 + self.reg_c

  def get_reg_de(self):
    return self.reg_d * 256 + self.reg_e

  def get_reg_hl(self):
    return self.reg_h * 256 + self.reg_l

  def get_reg_h(self):
    return self.reg_h

  def get_reg_l(self):
    return self.reg_l

  def get_reg_pc(self):
    return self.reg_pc

  def get_reg_sp(self):
    return self.reg_sp

  def set_register(self, register: str, value: int):
    """Set a register or register pair to an integer value.

    Register can be one of:
      a, af, b, bc, d, de, h, hl, sp, pc etc...
    """

    self.cmd(f'set ${register} = {value:04x}')
    self.read_prompt()

  def set_memory(self, address: int, values: list[int]):
    """Set memory contents starting at 'address'."""

    for b in values:
      self.cmd(f'set {address:04x} = {b:02x}')
      self.read_prompt()
      address = address + 1

  def traceoff(self):
    self.trace_func = None
    self.cmd('traceoff')

  def traceon(self, func):
    self.trace_func = func
    self.cmd('traceon')
    print('Turned tracing on')

  def add_breakpoint(self, location, func):
    if location not in self.breakpoints:
      self.breakpoints[location] = []
    self.breakpoints[location].append(func)
    self.read_prompt()
    self.cmd(f'break {location}')
    print(f'Added breakpoint at {location}')

  def add_module(self, name, module):
    """Add a new module. Let the module initialise breakpoints, etc."""
    ctl = module.Controller(self)
    self.modules[name] = ctl
    ctl.init()


  def module(self, name):
    """Return the instantiated Controller object for this registered module."""
    if name in self.modules:
      return self.modules[name]
    raise NoSuchModule(f'No such registered module: {name}')


  def run(self):
    while True:
      self.run_until_prompt()
      self.cmd('cont')
