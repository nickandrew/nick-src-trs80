#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Construct a parse tree of an ASM file."""

import argparse
import asm_parser


def lex_file(filename):
    """Just run the lexical analyser on the file. No grammar."""
    parser = asm_parser.ASMParser()
    with open(filename, 'r') as in_f:
        print('Lexing only')
        tokens = parser.lex(in_f.read())

    for token in tokens:
        print(f'{repr(token)}')

def parse_file(filename):
    parser = asm_parser.ASMParser()
    with open(filename, 'r') as in_f:
        tree = parser.parse(in_f.read())
    print(tree.pretty())

def parse_args():
    p = argparse.ArgumentParser(description='Parse ASM source files')
    p.add_argument('--lex', action='store_true', help='Do lexical analysis only')
    p.add_argument('filename', help='Filename to parse')
    return p.parse_args()

def main():
    args = parse_args()
    if args.filename:
        if args.lex:
            lex_file(args.filename)
        else:
            parse_file(args.filename)

if __name__ == '__main__':
    main()
