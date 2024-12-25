#!/usr/bin/env python3
"""Automatic debugger. Wraps a harness around zbx to allow tracing at scale."""

import argparse
import importlib

from controllers import input
from debugger import Zbx

def parse_args():
  parser = argparse.ArgumentParser(description='Automatically control a debugged process')
  parser.add_argument('--command', required=True, help='Command to execute')
  parser.add_argument('-m', required=False, help='Module name(s) to load, separated by commas')
  args = parser.parse_args()
  return args

def main():
  args = parse_args()

  dbg = Zbx(['/bin/bash', '-c', args.command])

  dbg.add_module('input', input)

  if args.m:
    for module_name in args.m.split(sep=','):
      module = importlib.import_module('controllers.' + module_name)
      dbg.add_module(module_name, module)

  input_ctl = dbg.module('input')
  # Restore a saved game?
  input_ctl.add_input('')
  # Would you like instructions?
  input_ctl.add_input('NO')
  # Enter the building and get the basics
  input_ctl.add_inputs(['E', 'GET KEYS', 'GET LAMP', 'W', 'S', 'S', 'S', 'UNLOCK GRATE', 'D'])
  input_ctl.add_inputs(['W', 'GET CAGE', 'W', 'LIGHT LAMP', 'W', 'W', 'GET BIRD'])
  input_ctl.add_inputs(['W', 'D', 'D', 'DROP BIRD', 'GET BIRD'])
  input_ctl.add_inputs(['U', 'U', 'E', 'E', 'E', 'XYZZY', 'DROP CAGE', 'XYZZY'])

  dbg.run()


if __name__ == '__main__':
  main()
