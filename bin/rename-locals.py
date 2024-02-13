#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Rename local symbols to a standard format in a single ASM file."""

import argparse
from   asm_helpers import RenameSymbol
import asm_parser
from   asm_xref import Symtab
import os
import re
import sys

from lark import Token,Tree
from lark.reconstruct import Reconstructor
from lark.visitors import Discard,Transformer,Visitor

# Xref of all source files
all_symtab = {}


class NameGenerator(object):
    def __init__(self, mod_name):
        self.mod_name = mod_name
        self.code_num = 0
        self.data_num = 0

    def gen_code_name(self, num):
        # Code names are A[0..Z] up to Z[0..Z].
        char_set = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        return f'${self.mod_name}_' + char_set[int(num/36)+10] + char_set[num % 36]

    def gen_data_name(self, num):
        # Data names are {00..99}
        return f'${self.mod_name}_{num:02d}'

    def new_code_name(self):
        n = self.gen_code_name(self.code_num)
        self.code_num = self.code_num + 1
        return n

    def new_data_name(self):
        n = self.gen_data_name(self.data_num)
        self.data_num = self.data_num + 1
        return n


def choose_new_label(label_name, symtab, gen):
    filenames = symtab.symbol_referred_in(label_name)
    if filenames:
        print(f'symbol {label_name} is a global - not renaming')
        return label_name

    # The same symbol defined in multiple files is a candidate
    # for combining the definitions into one source file. Do not rename.
    filenames = symtab.symbol_defined_in(label_name)
    if len(filenames) > 1:
        print(f'symbol {label_name} is a potential global - not renaming')
        return label_name

    return gen.new_code_name()


def is_tree(node, data):
    """Returns true if 'node' is a tree and its data is 'data'."""
    if not isinstance(node, Tree):
        return False
    if node.data == data:
        return True
    return False

def token_value(node, data):
    """Checks that node is a Tree with data data, and returns the value of the first child."""
    if not isinstance(node, Tree):
        return None
    if node.data != data:
        return None
    return node.children[0].value


def remap_local_symbols(tree, mod_name, all_symtab):
    """Iterate over the tree. Ignore global labels. Map local labels
    to a generated name of the form {mod}_{xx} where xx is 00-99 for
    data, and A0-ZZ for code.

    Return a symbol map for use editing the tree.
    """

    gen = NameGenerator(mod_name)

    cl = len(tree.children)
    print(f'cl is {cl}')
    for i in range(cl):
        # tree.children[i] is a line
        line_i = tree.children[i]

        if not is_tree(line_i, 'line'):
            print(f'Expected a line but got {repr(line_i)}')
            break

        child_0 = line_i.children[0]
        # print(f'child_0 is {repr(child_0)}')

        if isinstance(child_0, Tree):
            if child_0.data == 'comment':
                continue
            if child_0.data == 'get_line':
                continue
            if child_0.data == 'label':
                child_1 = line_i.children[2]
                if is_tree(child_1, 'equ'):
                    label_name = token_value(child_0, 'label')
                    print(f'label name is {label_name}')
                    new_label = choose_new_label(label_name, all_symtab, gen)
                    print(f'Rename {label_name} to {new_label}')
                    continue
                # TODO
                print(f'Unexpected type of line with a label: {repr(line_i)}')
            if child_0.data == 'std_line':
                child_1 = child_0.children[0]
                if isinstance(child_1, Token):
                    # No label on this line
                    continue

                if is_tree(child_1, 'label'):
                    label_name = child_1.children[0].value
                    print(f'label name is {label_name}')
                    new_label = choose_new_label(label_name, all_symtab, gen)
                    print(f'Rename {label_name} to {new_label}')
                    continue

        break


def process_file(filename, mod_name):
    """Edit the contents of filename and rename all local symbols."""
    parser = asm_parser.ASMParser()

    with open(filename, 'r') as in_f:
        try:
            tree = parser.parse(in_f.read())
        except Exception:
            print(f'Unable to parse {filename}, skipping')
            return

    # Iterate through the tree, figuring out new symbol names
    symbol_map = remap_local_symbols(tree, mod_name, all_symtab)
    raise ValueError('die here')

    t = RenameSymbol(symbol_map=symbol_map)
    new_tree = t.transform(tree)
    if t.modified:
        print(f'Modified {filename}')
        result = Reconstructor(parser.parser).reconstruct(new_tree)
        with open(filename, 'w') as out_f:
            print(result, end='', file=out_f)


def parse_args():
    p = argparse.ArgumentParser(description='Refactor ASM files to remove multiple definitions')
    p.add_argument('--mod', help='1-3 char unique module name [A-Z0-9]{1,3}')
    p.add_argument('--files', nargs='*', help='Filenames to process')
    p.add_argument('--xref', required=True, help='YAML xref filename')
    return p.parse_args()

def main():
    args = parse_args()

    global all_symtab
    all_symtab = Symtab(args.xref)

    if not re.match(r'[A-Z0-9]{1,3}$', args.mod):
        raise ValueError(f'Invalid mod {args.mod}')

    for filename in args.files:
        process_file(filename=filename, mod_name=args.mod)

if __name__ == '__main__':
    main()
