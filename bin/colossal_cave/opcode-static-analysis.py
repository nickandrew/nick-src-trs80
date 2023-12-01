#!/usr/bin/env python3

"""Perform static analysis of Colossal Cave bytecode.

Addresses hardcoded in here are for code10.bin.

Output a graphviz digraph.
"""

import argparse

import vm


class CodeSpec(object):
  # The bin file loads starting at this address
  load_offset = 0x4300

  # All known entrypoints to bytecode
  entrypoints = {
    0x5f9b: 'program_start_1',
    0x730a: 'program_start_2',
  }


class Digraph(object):
  def __init__(self):
    # All nodes
    self.nodes = {}

    # A list of edges
    self.edges = []

  def add_node(self, name, label):
    self.nodes[name] = label

  def add_edge(self, from_node, to_node):
    self.edges.append((from_node, to_node))

  def generate_graph(self, /, stream):
    print('digraph {', file=stream)
    for name in self.nodes:
      s = self.nodes[name]
      print(f'  "{name}" [label="{s}"];', file=stream)

    for left, right in self.edges:
      if right:
        print(f'  "{left}" -> x{right:04x};', file=stream)

    print('}', file=stream)

  def save(self, output_file):
    with open(output_file, 'w') as ofp:
      self.generate_graph(stream=ofp)


class MemoryError(Exception):
  """An address out of memory range was requested."""


class Analysis(object):
  def __init__(self, memory: list[bytes]):
    self.memory = memory
    self.memory_offset = CodeSpec.load_offset

    self.digraph1 = Digraph()    # Mainline code
    self.digraph2 = Digraph()    # All subroutines

    # Keeps track of addresses already investigated
    self.seen = {}

    # Keeps track of starting points to analyse
    # Tuple of (address, digraph)
    self.todo = []

  def get_memory(self, addr):
    """Returns one byte of code memory at 'addr'."""
    if addr < self.memory_offset:
      raise MemoryError(f'Address {addr:04x} is less than start {self.memory_offset:04x}')
    return self.memory[addr - self.memory_offset]

  def get_memory_slice(self, addr, length):
    """Returns a slice of code memory at 'addr'."""
    if addr < self.memory_offset:
      raise MemoryError(f'Address {addr:04x} is less than start {self.memory_offset:04x}')
    start = addr - self.memory_offset
    return self.memory[start:start + length]


  def start_analysis(self, addr: int, digraph) -> None:
    """Start analysis at a specified entrypoint.

    Keep going until a return or code_follows is seen.
    """

    while addr not in self.seen:
      mem = self.get_memory_slice(addr, 3)
      instruction = vm.Instruction.FromMemory(addr, mem)
      opcode = instruction.opcode
      length = instruction.length
      self.seen[addr] = True
      s = instruction.disassemble()
      # Add it to whichever digraph this function is working in
      digraph.add_node(f'x{addr:04x}', s)

      if opcode == 0xa6:
        # Code follows, that's where we stop
        return

      if opcode == 0xa7:
        # This is a return, we stop here
        return

      if instruction.is_gosub:
        # Analyse the subroutine
        gosub_addr = instruction.operand
        # Optimise to only add it to the todo list once
        if gosub_addr not in self.seen:
          if gosub_addr not in CodeSpec.entrypoints:
            description = instruction.disassemble() + ' start'
            CodeSpec.entrypoints[gosub_addr] = description
            # Subroutines always go to digraph2
            self.digraph2.add_edge(description, gosub_addr)
          self.todo.append((gosub_addr, self.digraph2))

      if instruction.is_jump:
        jump_addr = instruction.operand
        # jumps stay within the current digraph
        digraph.add_edge(f'x{addr:04x}', jump_addr)
        self.todo.append((jump_addr, digraph))
        return

      if instruction.is_cond_jump:
        # Add a 2nd edge for the conditional jump
        jump_addr = instruction.operand
        digraph.add_edge(f'x{addr:04x}', jump_addr)
        self.todo.append((jump_addr, digraph))
        # Conditional jumps fall through to the next address

      # Step to the next instruction in the sequence
      next_addr = addr + length
      digraph.add_edge(f'x{addr:04x}', next_addr)
      addr = next_addr


  def analyse_all(self):
    """Analyse all entrypoints in 'self.todo'.

    Return when todo is empty.
    """

    while self.todo:
      (entrypoint, digraph) = self.todo.pop(0)
      self.start_analysis(entrypoint, digraph)


  def generate_graph(self):
    print('digraph {')
    for name in self.nodes:
      s = self.nodes[name]
      print(f'  "{name}" [label="{s}"];')

    for left, right in self.edges:
      if right:
        print(f'  "{left}" -> x{right:04x};')

    print('}')

  def analyse(self):

    # Set up all the known entrypoints
    for addr in CodeSpec.entrypoints.keys():
      description = CodeSpec.entrypoints[addr]
      self.digraph1.add_node(description, description)
      self.digraph1.add_edge(description, addr)
      self.todo.append((addr, self.digraph1))

    self.analyse_all()

  def report(self, /, digraph1, digraph2):
    self.digraph1.save(digraph1)
    self.digraph2.save(digraph2)

def parse_arguments() -> argparse.ArgumentParser:
  parser = argparse.ArgumentParser(description='Perform static analysis of Colossal Cave bytecode')
  parser.add_argument('--code', required=True, help='Binary code filename')
  parser.add_argument('--digraph1', required=True, help='Mainline code .dot file')
  parser.add_argument('--digraph2', required=True, help='Subroutines .dot file')
  return parser.parse_args()


def main() -> None:
  args = parse_arguments()
  with open(args.code, 'rb') as code_file:
    memory = code_file.read()
  analysis = Analysis(memory)
  analysis.analyse()
  analysis.report(digraph1=args.digraph1, digraph2=args.digraph2)

if __name__ == '__main__':
  main()
