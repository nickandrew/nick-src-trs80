#!/usr/bin/python3
"""Build all files in the supplied BUILD yaml file"""

from __future__ import print_function

import argparse
import os
import re
import shutil
import sys
import time
import yaml

def basename(pathname):
  """Return a pathname stripped of all its directory prefixes."""
  if '/' in pathname:
    i = pathname.rindex('/')
    return pathname[i+1:]
  return pathname

class LocalBuilder(object):
  """Builds a file on Unix."""
  def __init__(self, args):
    self.args = args
    self.output_dir = 'zout'
    self.input_dir = 'zin'

  def assemble(self, filename):
    """Assemble the primary .ASM file.

    Dependencies are expected to be already resolved, and available
    in self.input_dir.
    """

    cmd = f'zmac -I {self.input_dir} -DMODEL1 -L --mras --oo cmd,lst {self.input_dir}/{filename}'
    rc = os.system(cmd)
    if rc != 0:
      print(f'system({cmd}) failed, code {rc}')
      return False
    else:
      print(f'system({cmd}) succeeded')
      return True

  def compile_cc80(self, filename, dest_filename):
    """Compile a .c file with Small-C.

    cc80 only reads include files from the current directory, so the
    command needs to 'cd' into that directory first.
    """

    asm_file = re.sub(r'\.c', r'.asm', filename)
    cmd = f'cd {self.input_dir} && cc80 -l {filename} > {asm_file}'
    rc = os.system(cmd)
    if rc != 0:
      print(f'system({cmd}) failed, code {rc}')
      return False
    else:
      print(f'system({cmd}) succeeded')
      return True

  def build(self, filename, d, control):
    """Build a .cmd file according to the instructions in 'd'."""
    built_filename = f'{self.output_dir}/{filename}'
    if os.path.exists(built_filename):
      print(f'Built file {built_filename} exists, skipping the build.')
      return True

    if 'skip' in d:
      print(f'{filename} skipped due to {d["skip"]}')
      return False

    if 'depends' not in d:
      print(f'{filename} has no dependencies; nothing to build')
      return True

    depends = d['depends']
    is_ok = 1
    # Scan depends list to make sure all files exist
    for p in depends:
      if (p not in control) and not os.path.exists(p):
        print("No pathname {}, not building {}".format(p, filename))
        is_ok = 0
    if not is_ok:
      print(f'Dependency check failed')
      return False

    # Copy all the dependencies in
    for p in depends:
      if p in control:
        # Recurse to build a dependency
        built_ok = self.build(p, control[p], control)
        if not built_ok:
          print(f'Building dependency {p} failed')
          return False
      else:
        dest_file = self.input_dir + '/' + basename(p)
        print("Import {} as {}".format(p, dest_file))
        shutil.copyfile(p, dest_file)

    # Compile or assemble
    if 'assemble' in d:
      success = self.assemble(d['assemble'])
    elif 'compile' in d:
      success = self.compile_cc80(d['compile'], filename)

    # Do not delete dependencies if there was a failure, so this
    # can be debugged later
    if not success:
      return success

    # Delete all the source files
    for p in depends:
      dest_file = self.input_dir + '/' + basename(p)
      if os.path.exists(dest_file):
        os.unlink(dest_file)

    return success

def build_control(builder, data):
  """Build all directives in given dict."""

  for filename in data:
    d = data[filename]
    if 'skip' in d:
      print(f'Skipping {filename} due to {d["skip"]}')
    elif 'depends' not in d:
      print(f'Skipping {filename} due to no dependencies; nothing to build')
    else:
      print("Building {}".format(filename))
      success = builder.build(filename, data[filename], data)
      if success:
        print(f'SUCCESS building {filename}')
      else:
        print(f'FAILURE building {filename}')

def build_path(builder, control):
  """Build from one YAML control file."""
  with open(control, "r") as f:
    data = yaml.safe_load(f)

  build_control(builder, data)

def build_root(builder, d):
  """Build all BUILD.yaml files in d and its subdirectories."""

  if not os.path.isdir(d):
    raise NotADirectoryError(f'{d} is not a directory')

  # Build subdirectories first
  for root, dirs, files in os.walk(d, topdown=False):
    if 'BUILD.yaml' in files:
      print(f'Building {root}/BUILD.yaml')
      build_path(builder, f'{root}/BUILD.yaml')


def main():
  parser = argparse.ArgumentParser(description="Build all source files in a YAML set.")
  parser.add_argument('--control', required=False, help='YAML filename containing build instructions')
  parser.add_argument('directories', nargs='*', type=str, help='Directories to build')
  args = parser.parse_args()

  builder = LocalBuilder(args)

  if args.control:
    build_path(builder, args.control)
    return

  if args.directories:
    for d in args.directories:
      build_root(builder, d)

if __name__ == '__main__':
  main()
