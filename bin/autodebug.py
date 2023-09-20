#!/usr/bin/env python3
"""Automatic debugger. Wraps a harness around zbx to allow tracing at scale."""

import argparse
import importlib

from debugger import Zbx

def parse_args():
  parser = argparse.ArgumentParser(description='Automatically control a debugged process')
  parser.add_argument('--command', required=True, help='Command to execute')
  parser.add_argument('-m', required=True, help='Module name(s) to load, separated by commas')
  args = parser.parse_args()
  return args

def main():
  args = parse_args()

  dbg = Zbx(['/bin/bash', '-c', args.command])

  for module_name in args.m.split(sep=','):
    module = importlib.import_module('controllers.' + module_name)
    dbg.add_module(module)

  dbg.run()


if __name__ == '__main__':
  main()
