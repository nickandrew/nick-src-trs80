#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Parse an ASM file then generate equal (?) text from the parse tree."""

import argparse
import asm_parser

from lark.reconstruct import Reconstructor

def parse_file(filename):
    parser = asm_parser.ASMParser()
    with open(filename, 'r') as in_f:
        tree = parser.parse(in_f.read())
    result = Reconstructor(parser.parser).reconstruct(tree)
    print(result, end='')

def parse_args():
    p = argparse.ArgumentParser(description='Parse ASM source files and regenerate')
    p.add_argument('filename', help='Filename to parse')
    return p.parse_args()

def main():
    args = parse_args()
    if args.filename:
        parse_file(args.filename)

if __name__ == '__main__':
    main()
