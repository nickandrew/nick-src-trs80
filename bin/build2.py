#!/usr/bin/env python3
"""Build a directory or the entire system.

Starts as a stub to test WIP; ends as a full builder.
"""

import os
import sys

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
      print(f'Building {root}/BUILD.yaml')
      builder.build_sequence(root)

def main():
  bs = BuildSystem(build_dir='tmp/build_dir')

  for directory in sys.argv[1:]:
    build_root(bs, directory)

if __name__ == '__main__':
  main()
