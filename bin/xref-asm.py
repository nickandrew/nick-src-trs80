#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Produce a cross-reference of multiple ASM files."""

import argparse
import asm_parser
import sys

from lark.visitors import Visitor

symtab = {}

def add_def(symtab, label, filename):
    if label not in symtab:
        symtab[label] = { 'def': {}, 'ref': {} }
    x = symtab[label]
    x['def'][filename] = 1

def add_ref(symtab, symbol, filename):
    if symbol not in symtab:
        symtab[symbol] = { 'def': {}, 'ref': {} }
    x = symtab[symbol]
    x['ref'][filename] = 1


class Labelizer(Visitor):
    def __init__(self, defines, refers):
        self.defines = defines
        self.refers = refers
    def label(self, tree):
        # tree.data == 'label'
        # Tree(Token('RULE', 'label'), [Token('__ANON_16', 'MESS$DI')])
        self.defines.add(tree.children[0])

    def symbol(self, tree):
        self.refers.add(tree.children[0])


def report_symtab():
    for label in sorted(symtab.keys()):
        x = symtab[label]
        defines = ' '.join(sorted(x['def'].keys()))
        print(f'{label} Defined: {defines}')
        references = ' '.join(sorted(x['ref'].keys()))
        print(f'{label} Referred: {references}')

def xref_add(filename, tree):
    """Add labels and symbol references from filename to our data."""
    defines = set()
    refers = set()
    Labelizer(defines=defines, refers=refers).visit(tree)

    # Merge the defines and refers into the global symbol table
    for symbol in defines:
        add_def(symtab, symbol, filename)

    for symbol in refers:
        # Only add a reference if not defined in this file
        if symbol not in defines:
            add_ref(symtab, symbol, filename)

def xref_files(filenames):
    parser = asm_parser.ASMParser()

    for filename in filenames:
        with open(filename, 'r') as in_f:
            try:
                tree = parser.parse(in_f.read())
            except Exception:
                print(f'Unable to parse {filename}, skipping', file=sys.stderr)
                continue
        xref_add(filename, tree)

    report_symtab()

def parse_args():
    p = argparse.ArgumentParser(description='Parse ASM source files')
    p.add_argument('filenames', nargs='*', help='Filename to parse')
    return p.parse_args()

def main():
    args = parse_args()
    if args.filenames:
        xref_files(args.filenames)

if __name__ == '__main__':
    main()
