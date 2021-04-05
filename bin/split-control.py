#!/usr/bin/python3
"""Split a combined BUILD.yaml file into 1-file-per-directory.

Usage: split-control.py input.yaml

Output is in various */BUILD.yaml files throughout the repository.

If any targets are skipped, they are written to "skipped.yaml".

Pathnames in the files are not rewritten.
"""

import argparse
import os
import re
import sys
import yaml

class MissingSourceFilenameError(Exception):
    """A build target dict does not contain a unique source filename."""

class NoPrimaryDirectoryError(Exception):
    """A build target does not contain a dependency listing the file it is to compile/assemble."""

def write_targets(output):
    """Write */BUILD.yaml files in various directories.

    Args:
      output: Dict of pathname and content
    """

    print('Writing files:')
    for f in output:
        print(f'  {f}')

    for pathname in output:
        data = output[pathname]
        with open(pathname, 'w') as fp:
            yaml.dump(data, stream=fp)

def primary_directory(target_name, target):
    """Determine which is the "primary directory" of a target.

    Primary Directory is the directory in the "depends" section
    in which the filename exactly matches the source file name
    in an "assemble" or "compile" section.

    Args:
      target_name:  Name of build target (e.g. abcde.cmd)
      target:       Dict of build directives
    """

    if 'assemble' in target:
        source_filename = target['assemble']
    elif 'compile' in target:
        source_filename = target['compile']
    else:
        raise MissingSourceFilenameError(f'There is no assemble or compile directive in {target_name}')

    if 'depends' not in target:
        raise NoPrimaryDirectoryError(f'No dependencies in {target_name}')

    depends = target['depends']

    for pathname in depends:
        # This will be a greedy match, so m.group(2) will contain only the filename part
        m = re.match(r'(.+)\/(.+)$', pathname)
        if not m:
            print(f'Bad dependency list in {target_name} - unqualified {pathname}', file=sys.stderr)
            continue

        # Found it
        if m.group(2) == source_filename:
            return m.group(1)

    raise NoPrimaryDirectoryError(f'Cannot find {source_filename} as a dependency in {target_name}')

def split_file(control):
    """Split a YAML control file into 1-per-directory.

    Args:
      control: Filename of input YAML file
    """

    # The input data is a dict of target
    # target Key is the target name (e.g. abcde.cmd)
    # target Value is a dict of build instructions and dependencies

    with open(control, 'r') as f:
        input = yaml.safe_load(f)

    # output[dirname/BUILD.yaml] = dict of target
    output = {}

    # skipped targets
    skipped = {}

    for target_name in input:
        target = input[target_name]
        try:
            directory = primary_directory(target_name, target)
        except NoPrimaryDirectoryError as e:
            print(f'Skipping {target_name} due to NoPrimaryDirectoryError')
            skipped[target_name] = target
            continue
        except MissingSourceFilenameError as e:
            print(f'Skipping {target_name} due to MissingSourceFilenameError')
            skipped[target_name] = target
            continue

        output_file = f'{directory}/BUILD.yaml'

        # First time a given filename appears?
        if output_file not in output:
            output[output_file] = {}

        output[output_file][target_name] = target

    write_targets(output)

    if skipped:
      with open('skipped.yaml', 'w') as fp:
        yaml.dump(skipped, stream=fp)

def main():
    """main() function."""
    parser = argparse.ArgumentParser(description="Split a combined BUILD.yaml file by directory")
    parser.add_argument('control', type=str, help='Input BUILD.yaml file')
    args = parser.parse_args()

    split_file(args.control)

if __name__ == "__main__":
    main()
