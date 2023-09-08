#!/usr/bin/env python3
"""Automatic debugger. Wraps a harness around zbx to allow tracing at scale."""

import argparse
import importlib

from debugger import Zbx

def parse_args():
  parser = argparse.ArgumentParser(description='Automatically control a debugged process')
  parser.add_argument('--command', required=True, help='Command to execute')
  parser.add_argument('-m', required=True, help='Module name to load')
  args = parser.parse_args()
  return args

def main():
  args = parse_args()

  module = importlib.import_module('controllers.' + args.m)

  dbg = Zbx(['/bin/bash', '-c', args.command])
  ctl = module.Controller(dbg)
  ctl.run()


if __name__ == '__main__':
  main()
