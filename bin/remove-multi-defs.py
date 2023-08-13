#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Where a symbol is defined in 2 or more files, remove the redundant definitions."""

import argparse
from   asm_helpers import GetIncludes,GetEquates,DeleteEquates,AddIncludeEarly
import asm_parser
import os
import sys

from lark import Token,Tree
from lark.reconstruct import Reconstructor
from lark.visitors import Discard,Transformer,Visitor


def process_file(filename, symtab, prefer_file):
    """Edit the contents of filename and remove any definitions of symbols in symtab."""
    parser = asm_parser.ASMParser()

    with open(filename, 'r') as in_f:
        try:
            tree = parser.parse(in_f.read())
        except Exception:
            print(f'Unable to parse {filename}, skipping')
            return

    includes = set()
    v = GetIncludes(includes=includes)
    v.visit(tree)

    t = DeleteEquates(symtab=symtab)
    new_tree = t.transform(tree)
    if t.modified:
        print(f'Modified {filename}')
        if prefer_file not in includes:
            t = AddIncludeEarly(filename=prefer_file, includes=includes)
            new_tree = t.transform(new_tree)
        result = Reconstructor(parser.parser).reconstruct(new_tree)
        with open(filename, 'w') as out_f:
            print(result, end='', file=out_f)



def get_labels(filename, check_values=False):
    """Parse filename and retrieve the names and values of labels.

    Ignore multiple definitions (due to conditional assembly).
    """
    parser = asm_parser.ASMParser()
    with open(filename, 'r') as in_f:
        tree = parser.parse(in_f.read())

    symtab = {}
    visitor = GetEquates(symtab=symtab, parser=parser)
    visitor.visit(tree)
    print(f'Final symtab to prune is {symtab}')

    if check_values:
        # Check for multiple labels sharing the same value. For memory addresses, it often
        # means one symbol should be renamed to another. But this doesn't apply to other
        # uses of EQU (e.g. small numbers).
        values = {}
        failed = False
        for k in symtab:
            v = symtab[k]
            if v in values:
                failed = True
                print(f'Value {v} is shared by keys {values[v]} and {k} in equates')
            values[v] = k

        if failed:
            raise ValueError('Duplicate symbols have the same value')

    return symtab

def parse_args():
    p = argparse.ArgumentParser(description='Refactor ASM files to remove multiple definitions')
    p.add_argument('--check_values', action='store_true', help='Check no duplicate values in the prefer file')
    p.add_argument('--prefer', required=True, help='The canonical definition filename')
    p.add_argument('filenames', nargs='*', help='Filenames to process')
    return p.parse_args()

def main():
    args = parse_args()
    symtab = get_labels(filename=args.prefer, check_values=args.check_values)
    base_filename = os.path.basename(args.prefer)
    (base_filename,_) = os.path.splitext(base_filename)

    for filename in args.filenames:
        if filename != args.prefer:
            process_file(filename=filename, symtab=symtab, prefer_file=base_filename)

if __name__ == '__main__':
    main()
