#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Parse one or more ASM sources and write corresponding BUILD rules."""

import argparse
import asm_parser
from   asm_xref import Symtab
import os
import re
import sys
import yaml

from lark.visitors import Visitor

symtab = {}
seen_end = False
includes = set()

class GrabIncludes(Visitor):
    def __init__(self, includes):
        self.includes = includes
        self.seen_end = False

    def pseudo_op_end(self, tree):
        # tree.data == 'pseudo_op_end'
        self.seen_end = True

    def filename(self, tree):
        self.includes.add(tree.children[0].lower())


def write_build_rule(filename, tree):
    """Figure out the dependencies for this filename."""
    includes = set()

    base_filename = os.path.basename(filename)
    base_dirname = os.path.dirname(filename)

    m = re.match(r'(.+)\.asm', base_filename)
    if not m:
        print(f'Ignoring {filename} as not a .asm file')
        return

    cmd_filename = m.group(1) + '.cmd'

    visitor = GrabIncludes(includes=includes)
    visitor.visit(tree)

    if not visitor.seen_end:
        print(f'Ignoring {filename} as no END pseudo-op')
        return

    rule = {
        'assemble': base_filename,
        'depends': []
    }

    depends = rule['depends']
    need_files = set()
    need_files.add(base_filename)

    # Get all the symbols referred to in this file
    symbols = symtab.filename_referred(filename)
    print(f'symbols referred to in this file: {symbols}')

    for symbol in symbols:
        # Is it defined in this file? Who cares, just include all the filenames that define this symbol
        filenames = symtab.symbol_defined_in(symbol)
        print(f'{symbol} is defined in {filenames}')
        for f in filenames:
            need_files.add(f)

    for f in sorted(need_files):
        depends.append(f)

    # Write the rule

    build_path = base_dirname + '/BUILD.yaml'
    build_rules = {}
    if os.path.exists(build_path):
        with open(build_path, 'r') as ifp:
            build_rules = yaml.safe_load(ifp)
    build_rules[cmd_filename] = rule

    with open(build_path, 'w') as ofp:
        yaml.safe_dump(build_rules, stream=ofp)

    print(f'--- BUILD.yaml for {filename}')
    yaml.safe_dump(build_rules, stream=sys.stdout)


def process_files(filenames):
    parser = asm_parser.ASMParser()

    for filename in filenames:
        with open(filename, 'r') as in_f:
            try:
                tree = parser.parse(in_f.read())
            except Exception:
                print(f'Unable to parse {filename}, skipping', file=sys.stderr)
                continue
        write_build_rule(filename, tree)

def parse_args():
    p = argparse.ArgumentParser(description='Parse ASM source files')
    p.add_argument('--xref', required=True, help='YAML xref filename')
    p.add_argument('filenames', nargs='*', help='Filenames to process')
    return p.parse_args()

def main():
    args = parse_args()

    global symtab
    symtab = Symtab(args.xref)

    if args.filenames:
        process_files(args.filenames)

if __name__ == '__main__':
    main()
