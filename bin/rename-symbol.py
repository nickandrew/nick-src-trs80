#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Rename symbol A to B in multiple ASM files."""

import argparse
from   asm_helpers import RenameSymbol
import asm_parser
import os
import re
import sys

from lark import Token,Tree
from lark.reconstruct import Reconstructor
from lark.visitors import Discard,Transformer,Visitor



def process_file(filename, symbol_map):
    """Edit the contents of filename and change symbols in symbol_map."""
    parser = asm_parser.ASMParser()

    with open(filename, 'r') as in_f:
        try:
            tree = parser.parse(in_f.read())
        except Exception:
            # print(f'Unable to parse {filename}, skipping')
            return

    t = RenameSymbol(symbol_map=symbol_map)
    new_tree = t.transform(tree)
    if t.modified:
        print(f'Modified {filename}')
        result = Reconstructor(parser.parser).reconstruct(new_tree)
        with open(filename, 'w') as out_f:
            print(result, end='', file=out_f)


def parse_args():
    p = argparse.ArgumentParser(description='Refactor ASM files to remove multiple definitions')
    p.add_argument('--map', nargs='*', help='One or more old_symbol=new_symbol')
    p.add_argument('--files', nargs='*', help='Filenames to process')
    return p.parse_args()

def main():
    args = parse_args()

    symbol_map = {}
    for s in args.map:
        m = re.match(r'(.+)=(.+)', s)
        if m:
            symbol_map[m.group(1)] = m.group(2)

    if not symbol_map:
        raise ValueError('No symbol mappings were requested on command line')

    for filename in args.files:
        process_file(filename=filename, symbol_map=symbol_map)

if __name__ == '__main__':
    main()
