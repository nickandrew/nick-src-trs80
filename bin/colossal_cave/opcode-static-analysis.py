#!/usr/bin/env python3

"""Perform static analysis of Colossal Cave bytecode.

Addresses hardcoded in here are for code10.bin.

Output a graphviz digraph.
"""

import argparse

import vm

class MemoryError(Exception):
  """An address out of memory range was requested."""

class Memory(object):
  """A sequence of bytes starting at some address."""

  def __init__(self, *, address, memory):
    self.start_address = address
    self.size = len(memory)
    self.last_address = address + self.size
    self.memory = memory

  def memory_bytes(self, start_address, size):
    s = start_address - self.start_address
    if s < 0:
      raise MemoryError(f'Memory start_address {start_address:04x} less than {self.start_address:04x}')
    last_address = start_address + size
    if last_address > self.last_address:
      raise MemoryError(f'Memory last address {last_address:04x} greater than {self.last_address:04x}')

    return self.memory[s:s + size]

  def byte(self, address):
    b = self.memory_bytes(address, 1)
    return b[0]

  def word(self, address):
    b = self.memory_bytes(address, 2)
    return b[0] + b[1] * 0x100


class CodeSpec(object):
  # The bin file loads starting at this address
  load_offset = 0x4300

  # All known entrypoints to bytecode
  entrypoints = {
    0x5f9b: 'program_start_1',
    0x5fba: 'Common 5fba',
    0x62e3: 'Common 62e3',
    0x63bb: 'Common 63bb',
    0x63bd: 'Common 63bd',
    0x6990: 'Common 6990',
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
        print(f'  "{left}" -> "{right}";', file=stream)

    print('}', file=stream)

  def save(self, output_file):
    with open(output_file, 'w') as ofp:
      self.generate_graph(stream=ofp)



class Analysis(object):
  def __init__(self, memory: bytes):
    self.memory = Memory(address=CodeSpec.load_offset, memory=memory)

    self.digraph1 = Digraph()    # Mainline code
    self.digraph2 = Digraph()    # All subroutines

    # Keeps track of addresses already investigated
    self.seen = {}

    # Keeps track of starting points to analyse
    # Tuple of (address, digraph)
    self.todo = []

  def get_memory(self, addr):
    """Returns one byte of code memory at 'addr'."""
    return self.memory.byte(addr)

  def get_memory_slice(self, addr, length):
    """Returns a slice of code memory at 'addr'."""
    return self.memory.memory_bytes(addr, length)


  def start_analysis(self, addr: int, digraph) -> None:
    """Start analysis at a specified entrypoint.

    Keep going until a return or code_follows is seen.
    """

    while addr not in self.seen:
      instruction = vm.Instruction(address=addr, memory=self.memory.memory_bytes(addr, 3))
      opcode = instruction.opcode
      length = instruction.opcode.length
      self.seen[addr] = True
      s = instruction.disassemble()
      # Add it to whichever digraph this function is working in
      node_name = f'x{addr:04x}'
      digraph.add_node(node_name, s)

      if opcode.is_code_follows:
        # Code follows, that's where we stop
        return

      if opcode.is_return:
        # This is a return, we stop here
        return

      if opcode.is_jump_table:
        # A jump table follows. We stop here, but add the calculated table
        # addresses to our TODO list.
        size = instruction.operand
        print(f'Jump table at {addr:04x} ... ', end='')
        for index in range(size):
          jump_addr = (addr + 2 + index * 2 + self.memory.word(addr + 2 + index * 2)) & 0xffff
          print(f'{jump_addr:04x} ', end='')

          # Add this to list of entrypoints
          if jump_addr not in CodeSpec.entrypoints:
            start_node_id = f'x{jump_addr:04x} start'
            CodeSpec.entrypoints[jump_addr] = start_node_id
            digraph.add_node(start_node_id, start_node_id)
            digraph.add_edge(start_node_id, f'x{jump_addr:04x}')

          # Add a node for the destination
          unique_node_id = f'jump_table_x{addr:04x}_to_x{jump_addr:04x}'
          digraph.add_node(unique_node_id, f'to x{jump_addr:04x}')
          digraph.add_edge(node_name, unique_node_id)

          # Add a node from the table index to the implementation
          unique_node_id_2 = f'x{addr:04x} jump table index {index}'
          digraph.add_node(unique_node_id_2, unique_node_id_2)
          digraph.add_edge(unique_node_id_2, f'x{jump_addr:04x} start')

          self.todo.append((jump_addr, digraph))

        print('')
        return

      if opcode.gosub_addr:
        # Analyse the subroutine
        gosub_addr = opcode.gosub_addr
        # Optimise to only add it to the todo list once
        if gosub_addr not in self.seen:
          if gosub_addr not in CodeSpec.entrypoints:
            description = instruction.disassemble() + ' start'
            CodeSpec.entrypoints[gosub_addr] = description
            # Subroutines always go to digraph2
            self.digraph2.add_edge(description, f'x{gosub_addr:04x}')
          self.todo.append((gosub_addr, self.digraph2))

      if opcode.is_jump:
        jump_addr = instruction.operand
        if jump_addr in CodeSpec.entrypoints:
          # Make a leaf node "to {jump_addr}", so the entrypoint will be separate
          unique_node_id = f'x{addr:04x}_to_x{jump_addr:04x}'
          digraph.add_node(unique_node_id, f'to x{jump_addr:04x}')
          digraph.add_edge(node_name, unique_node_id)
        else:
          digraph.add_edge(node_name, f'x{jump_addr:04x}')
        # jumps stay within the current digraph
        self.todo.append((jump_addr, digraph))
        # And are terminal
        return

      if opcode.is_cond_jump:
        # Add a 2nd edge for the conditional jump
        jump_addr = instruction.operand
        if jump_addr in CodeSpec.entrypoints:
          # Make a leaf node "to {jump_addr}", so the entrypoint will be separate
          unique_node_id = f'x{addr:04x}_to_x{jump_addr:04x}'
          digraph.add_node(unique_node_id, f'to x{jump_addr:04x}')
          digraph.add_edge(node_name, unique_node_id)
        else:
          digraph.add_edge(node_name, f'x{jump_addr:04x}')
        self.todo.append((jump_addr, digraph))
        # Conditional jumps fall through to the next address

      # Step to the next instruction in the sequence
      next_addr = instruction.next_address
      digraph.add_edge(node_name, f'x{next_addr:04x}')
      addr = next_addr


  def analyse_all(self):
    """Analyse all entrypoints in 'self.todo'.

    Return when todo is empty.
    """

    while self.todo:
      (entrypoint, digraph) = self.todo.pop(0)
      self.start_analysis(entrypoint, digraph)

  def analyse(self):
    # Set up all the known entrypoints
    for addr in CodeSpec.entrypoints.keys():
      description = CodeSpec.entrypoints[addr]
      self.digraph1.add_node(description, description)
      self.digraph1.add_edge(description, f'x{addr:04x}')
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
