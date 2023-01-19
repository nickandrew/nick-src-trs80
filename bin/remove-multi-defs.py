#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Where a symbol is defined in 2 or more files, remove the redundant definitions."""

import argparse
import asm_parser
import sys

from lark import Token,Tree
from lark.reconstruct import Reconstructor
from lark.visitors import Discard,Transformer,Visitor

class GetEquates(Visitor):
    def __init__(self, symtab):
        self.symtab = symtab

    def line(self, tree):
        nchildren = len(tree.children)
        if nchildren < 5:
            return
        if isinstance(tree.children[2], Tree) and tree.children[2].data == 'equ':
            self.symtab.add(tree.children[0].children[0].value)

class DeleteEquates(Transformer):
    def __init__(self, symtab):
        self.symtab = symtab
        self.modified = False

    def line(self, children):
        # print(f'DeleteEquates line called with {repr(children)}')

        nchildren = len(children)
        if nchildren < 5:
            return Tree('line', children)
        if isinstance(children[2], Tree) and children[2].data == 'equ':
            symbol = children[0].children[0].value
            if symbol in self.symtab:
                self.modified = True
                # print(f'Discarding line called with {repr(children)}')
                return Discard
        return Tree('line', children)

def process_file(filename, symtab):
    """Edit the contents of filename and remove any definitions of symbols in symtab."""
    parser = asm_parser.ASMParser()

    with open(filename, 'r') as in_f:
        try:
            tree = parser.parse(in_f.read())
        except Exception:
            print(f'Unable to parse {filename}, skipping')
            return

    t = DeleteEquates(symtab=symtab)
    new_tree = t.transform(tree)
    if t.modified:
        print(f'Modified {filename}')
        result = Reconstructor(parser.parser).reconstruct(new_tree)
        with open(filename, 'w') as out_f:
            print(result, end='', file=out_f)



def get_labels(filename):
    """Parse filename and retrieve the names and values of labels.

    Ignore multiple definitions (due to conditional assembly).
    """
    parser = asm_parser.ASMParser()
    with open(filename, 'r') as in_f:
        tree = parser.parse(in_f.read())

    symtab = set()
    visitor = GetEquates(symtab=symtab)
    visitor.visit(tree)
    print(f'Final symtab to prune is {symtab}')
    return symtab

def parse_args():
    p = argparse.ArgumentParser(description='Refactor ASM files to remove multiple definitions')
    p.add_argument('--prefer', required=True, help='The canonical definition filename')
    p.add_argument('filenames', nargs='*', help='Filenames to process')
    return p.parse_args()

def main():
    args = parse_args()
    symtab = get_labels(filename=args.prefer)
    for filename in args.filenames:
        if filename != args.prefer:
            process_file(filename=filename, symtab=symtab)

if __name__ == '__main__':
    main()
