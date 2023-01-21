#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Helper classes for parsing ASM files. Includes Visitors and Transformers."""

from lark import Token,Tree
from lark.reconstruct import Reconstructor
from lark.visitors import Discard,Transformer,Visitor


class GetIncludes(Visitor):
    def __init__(self, includes):
        self.includes = includes

    def get_line(self, tree):
        filename = tree.children[2].children[0].value.lower()
        self.includes.add(filename)


class GetEquates(Visitor):
    def __init__(self, symtab, parser):
        self.symtab = symtab
        self.parser = parser

    def line(self, tree):
        nchildren = len(tree.children)
        if nchildren < 5:
            return
        if isinstance(tree.children[2], Tree) and tree.children[2].data == 'equ':
            name = tree.children[0].children[0].value
            value = self.expression_to_string(tree.children[4])
            self.symtab[name] = value

    def expression_to_string(self, tree):
        """Turn an expression into the corresponding assembler string."""
        if tree.data != 'expression':
            raise ValueError(f'Called expression_to_string() on a non-expression')

        result = Reconstructor(self.parser.parser).reconstruct(tree)
        return result


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


class AddIncludeEarly(Transformer):
    def __init__(self, filename, includes=None):
        self.filename = filename.upper()
        self.includes = includes

    def start(self, children):
        # children are a sequence of lines
        cl = len(children)
        for i in range(cl):
            # Add *GET before the first non-comment line
            child = children[i].children[0]  # Actually grandchild
            # Break at first empty line or non-comment
            if isinstance(child, Token):
                break

            if child.data != 'comment':
                break

        # Now, i is the index of the first non-comment line, from 0 to cl-1 inclusive
        new_line = Tree('line', [
            Tree('get_line', [
                Tree('star_get', []),
                Token('TABS', '\t'),
                Tree('filename', [Token('__ANON_18', self.filename)]),  # Apparently the anon name matters
            ]),
            Token('LF', '\n')
        ])

        children = children[0:i] + [new_line] + children[i:]
        return Tree('start', children)


class RenameSymbol(Transformer):
    def __init__(self, from_symbol, to_symbol):
        self.from_symbol = from_symbol
        self.to_symbol = to_symbol
        self.modified = False

    def label(self, children):
        # print(f'label() called with {repr(children)}')

        if children[0] == self.from_symbol:
            key = children[0].type
            self.modified = True
            return Tree('label', [Token(key, self.to_symbol)])
        return Tree('label', children)

    def symbol(self, children):
        # print(f'symbol() called with {repr(children)}')

        if children[0] == self.from_symbol:
            self.modified = True
            key = children[0].type
            return Tree('symbol', [Token(key, self.to_symbol)])
        return Tree('symbol', children)
