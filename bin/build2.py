#!/usr/bin/env python3
"""Build a directory or the entire system.

Starts as a stub to test WIP; ends as a full builder.
"""

import argparse
import os

from buildsys.control import BuildSystem, DirectoryBuilder

class NotADirectoryError(Exception):
  """A thing is not a directory."""
  pass

def build_root(builder, d):
  """Build all directories in d and its subdirectories which contain a BUILD.yaml file."""

  if not os.path.isdir(d):
    raise NotADirectoryError(f'{d} is not a directory')

  # Build subdirectories first
  for root, dirs, files in os.walk(d, topdown=False):
    if 'BUILD.yaml' in files:
      source_dir = os.path.normpath(root)
      print(f'Building {source_dir}/BUILD.yaml')
      builder.build_sequence(source_dir)

def main():
  parser = argparse.ArgumentParser(description="Recursively build binaries in specified directories.")
  parser.add_argument('--build_dir', default='tmp/build_dir', help='Build all files under this directory')
  parser.add_argument('directories', nargs='*', type=str, help='Directories to build')
  args = parser.parse_args()

  bs = BuildSystem(build_dir=args.build_dir)

  for directory in args.directories:
    build_root(bs, directory)

if __name__ == '__main__':
  main()
