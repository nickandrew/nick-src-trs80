#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Find missing dependencies of an ASM file; edit to add includes."""

import argparse
import asm_parser
from   asm_xref import Symtab
import yaml

from lark import Token,Tree
from lark.reconstruct import Reconstructor
from lark.visitors import Discard,Transformer,Visitor

def line_get_line(filename: str, comment: str = None) -> Tree:
    new_line = Tree('line', [
        Tree('get_line', [
            Tree('star_get', []),
            Token('TABS', '\t'),
            Token('FILENAME', filename),
        ]),
        Token('LF', '\n')
    ])

    return new_line

def get_all_includes(tree: Tree):
    """Find the set of included files in a source tree.
    """

    includes = []

    for line in tree.children:
        # print(f'Checking: {line}')
        contents = line.children[0]

        if isinstance(contents, Tree):
            if contents.data == 'get_line':
                print(f'get_line {line}')
                includes.append(contents.children[2].value)

    return includes


def get_lower_includes(tree: Tree):
    """Find the set of included files in a source tree.

    Normally this would be any "*GET filename" line,
    but we're looking only in a portion of the ASM source code
    marked by "<includes>" in a comment.
    """
    # Look for a:
    #  line
    #    comment    ; <includes>
    # Then look for a sequence of:
    #  line > get_line > filename FILENAME
    # To add a new one, add:
    #  line > get_line > (star_get, filename FILENAME, comment ;COMMENT)

    includes = []
    found_includes = False

    for line in tree.children:
        # print(f'Checking: {line}')
        contents = line.children[0]

        if found_includes:
            if isinstance(contents, Tree):
                if contents.data == 'get_line':
                    print(f'get_line {line}')
                    includes.append(contents.children[2].value)
                elif contents.data == 'comment':
                    # print(f'End of includes')
                    break
            else:
                # print('Not Tree')
                pass
            continue

        if isinstance(contents, Token):
            # print(yaml.dump(Token))
            # print(f'A token: {line}')
            continue

        if contents.data == 'comment':
            # print(f'Found comment: {contents}')
            if '<includes>' in contents.children[0]:
                # print('Found it')
                found_includes = True

    return includes


def replace_lower_includes(tree: Tree, new_includes: list[str]):
    """Replace the set of included files in a source tree.

    Normally this would be any "*GET filename" line,
    but we're looking only in a portion of the ASM source code
    marked by "<includes>" in a comment.
    """
    # Look for a:
    #  line
    #    comment    ; <includes>
    # Then look for a sequence of:
    #  line > get_line > filename FILENAME
    # To add a new one, add:
    #  line > get_line > (star_get, filename FILENAME, comment ;COMMENT)

    found_includes = False
    new_children = []

    for line in tree.children:
        # print(f'Checking: {line}')
        contents = line.children[0]

        if found_includes:
            if isinstance(contents, Tree):
                if contents.data == 'get_line':
                    print(f'skip get_line {line}')
                    continue

            found_includes = False
            new_children.append(line)
            continue

        new_children.append(line)
        if isinstance(contents, Token):
            # print(yaml.dump(Token))
            # print(f'A token: {line}')
            continue

        if contents.data == 'comment':
            # print(f'Found comment: {contents}')
            if '<includes>' in contents.children[0]:
                # print('Found it')
                found_includes = True
                for filename in new_includes:
                    t = line_get_line(filename)
                    new_children.append(t)

    # Replace children with new set
    tree.children = new_children


def process_file(filename: str, symtab: Symtab):
    """Modify an ASM file in-place to add any missing "*GET" lines.

    This is done by looking for symbols used in the file, but not
    defined in it, and adding a "*GET" for the file which defines
    that symbol.
    """

    parser = asm_parser.ASMParser()
    with open(filename, 'r') as in_f:
        tree = parser.parse(in_f.read())

    includes = get_all_includes(tree)
    print(f'Includes: {includes}')

    need_files = set()

    # Get all the symbols referred to in this file
    symbols = symtab.filename_referred(filename)
    print(f'symbols referred to in this file: {symbols}')

    for symbol in symbols:
        # Is it defined in this file? Who cares, just include all the filenames that define this symbol
        pathnames = symtab.symbol_defined_in(symbol)
        # Filter out files which are not specific includes
        pathnames = [x for x in pathnames if 'include' in x]
        # print(f'{symbol} is defined in {pathnames}')
        filenames = [x.removesuffix('.asm').split(sep='/')[-1].upper() for x in pathnames]
        # Filter out libc.asm
        filenames = [x for x in filenames if x != 'LIBC']
        print(f'{symbol} is defined in {filenames}')
        for f in filenames:
            if f not in includes:
                need_files.add(f)

    print(f'Need these files: {sorted(need_files)}')

    # Find all "*GET" already existing under the "<includes>" comment
    lower_includes = get_lower_includes(tree)
    print(f'Lower includes: {lower_includes}')
    final_set = set(lower_includes) | set(need_files)

    depends = sorted(final_set)
    print(f'Depends: {depends}')

    replace_lower_includes(tree, depends)

    # Print the new file
    result = Reconstructor(parser.parser).reconstruct(tree)
    with open(filename, 'w') as out_f:
        print(result, end='', file=out_f)


def main():
    p = argparse.ArgumentParser(description='Add missing dependencies to an ASM file')
    p.add_argument('--xref', required=True, help='YAML xref filename')
    p.add_argument('filename', help='Filename to edit')
    args = p.parse_args()

    symtab = Symtab(args.xref)

    process_file(args.filename, symtab=symtab)

if __name__ == '__main__':
    main()
