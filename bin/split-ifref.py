#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Split a module file containing IFREF into individual asm files."""

import argparse
import re

def convert_file(filename):
    output_file = None
    buffer = ''
    line_number = 0

    with open(filename, 'r') as in_f:
        for line in in_f:
            line_number = line_number + 1
            m = re.match(r'\tIFREF\t([A-Z0-9_$]+)', line)
            if m:
                # Grab the label name to form the output_file name
                output_file = m.group(1).lower() + '.asm'
                continue

            m = re.match(r'\tENDIF', line)
            if m:
                if output_file:
                    with open(output_file, 'w') as out_f:
                        print(f'Writing {output_file}')
                        print(buffer, file=out_f, end='')
                        buffer = ''
                        output_file = None
                    continue
                else:
                    raise ValueError(f'ENDIF without IFREF at input line {line_number}')

            buffer = buffer + line
        if buffer:
            print('Trailing data:')
            print(buffer, end='')

def parse_args():
    p = argparse.ArgumentParser(description='Split ASM source files by IFREF')
    p.add_argument('filename', help='Filename to convert')
    return p.parse_args()

def main():
    args = parse_args()
    if args.filename:
        convert_file(args.filename)

if __name__ == '__main__':
    main()
