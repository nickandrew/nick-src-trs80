"""Controller helper class(es)."""

import time

class ExcludeList(object):
  """Mark ranges of memory for some purpose."""

  def __init__(self, ranges: list[int]):
    self.memory_map = bytearray(0x10000)

    for exclude_range in ranges:
      addr = exclude_range[0]
      while addr <= exclude_range[1]:
        self.memory_map[addr] = 1
        addr = addr + 1

  def isset(self, address):
    return self.memory_map[address] == 1


class FlowOfControl(object):
  """Keeps track of last PC / opcode fetch address."""
  def __init__(self, exclude_list: ExcludeList, report_file: str, start_address: int, offset: int,
    start_address2: int = 0, offset2: int = 0):
    self.exclude_list = exclude_list
    self.report_file = report_file
    self.start_address = start_address
    self.offset = offset
    self.start_address2 = start_address2
    self.offset2 = offset2

    self.address = None
    self.counter = 0
    self.jump_map = {}
    self.report_time = None
    self.slots_used = 0


  def count_jumps(self):
    return len(self.jump_map)


  def always_report(self):
    with open(self.report_file, 'w') as report_file:
      for k in sorted(self.jump_map):
        print(k, file=report_file)


  def report(self):
    slots_used = self.count_jumps()

    if slots_used <= self.slots_used:
      return

    now = time.time()

    if not self.report_time or self.report_time < now - 10:
      print(f'Reporting to {self.report_file} at {now}')
      self.slots_used = slots_used
      self.always_report()
      self.report_time = now

  def translate(self, address: int) -> int:
    reported = address
    orig_reported = address
    if self.start_address2 > 0 and reported >= self.start_address2:
      reported = reported + self.offset2

    if reported >= self.start_address:
      reported = reported + self.offset

    return reported

  def update(self, address: int) -> None:
    reported = self.translate(address)

    if not self.address:
      self.address = reported
      return

    if self.exclude_list.isset(reported):
      # Ignore this new address until it goes outside the exclude_map range
      return

    if reported > self.address and reported < self.address + 4:
      # This is ordinary succession, not a jump, so update address and ignore
      self.address = reported
      return

    # Update address
    # key = f'{self.address:04x}-{reported:04x} {orig_reported:04x}'
    key = f'{self.address:04x}-{reported:04x}'
    self.jump_map[key] = 1
    self.address = reported
