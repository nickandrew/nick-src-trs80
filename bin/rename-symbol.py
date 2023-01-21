#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Rename symbol A to B in multiple ASM files."""

import argparse
from   asm_helpers import RenameSymbol
import asm_parser
import os
import sys

from lark import Token,Tree
from lark.reconstruct import Reconstructor
from lark.visitors import Discard,Transformer,Visitor


def process_file(filename, from_symbol, to_symbol):
    """Edit the contents of filename and change from_symbol to to_symbol."""
    parser = asm_parser.ASMParser()

    with open(filename, 'r') as in_f:
        try:
            tree = parser.parse(in_f.read())
        except Exception:
            # print(f'Unable to parse {filename}, skipping')
            return

    t = RenameSymbol(from_symbol=from_symbol, to_symbol=to_symbol)
    new_tree = t.transform(tree)
    if t.modified:
        print(f'Modified {filename}')
        result = Reconstructor(parser.parser).reconstruct(new_tree)
        with open(filename, 'w') as out_f:
            print(result, end='', file=out_f)


def parse_args():
    p = argparse.ArgumentParser(description='Refactor ASM files to remove multiple definitions')
    p.add_argument('from_symbol', help='Symbol to be renamed')
    p.add_argument('to_symbol', help='Symbol to rename to')
    p.add_argument('filenames', nargs='*', help='Filenames to process')
    return p.parse_args()


def main():
    args = parse_args()

    for filename in args.filenames:
        process_file(filename=filename, from_symbol=args.from_symbol, to_symbol=args.to_symbol)

if __name__ == '__main__':
    main()
