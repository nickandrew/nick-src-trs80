#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Find dependencies of ASM files."""

import argparse
import asm_parser
import asm_xref
from   asm_xref import Symtab
import yaml


def show_deps(symtab: Symtab, filename: str):
    """Show dependencies of the given ASM filename."""

    print(f'----==== {filename} ====----')
    try:
        deps = symtab.find_depends(filename, set())
    except asm_xref.MultipleDefinitionError:
        print(f'Unable to resolve dependencies for {filename}')
        return

    filenames = [x.removesuffix('.asm').split(sep='/')[-1].upper() for x in deps]
    for f in sorted(filenames):
        print(f'*GET\t{f}')
    print('')


def main():
    p = argparse.ArgumentParser(description='Add missing dependencies to an ASM file')
    p.add_argument('--xref', required=True, help='YAML xref filename')
    p.add_argument('filename', nargs='*', help='Filenames to analyse')
    args = p.parse_args()

    symtab = Symtab(args.xref)

    for filename in args.filename:
        show_deps(symtab, filename)

if __name__ == '__main__':
    main()

