#!/usr/bin/env python3
#  vim:expandtab:sw=4:ts=8:sts=4:ai:

import yaml

class Symtab(object):
    def __init__(self, filename):
        self.symtab = {}
        self.filetab = {}

        with open(filename, 'r') as in_f:
            self.symtab = yaml.safe_load(in_f)

        # Invert symtab to make filetab.
        # self.filetab{filename} = {'def': [symbol ...], 'ref': [symbol ...]}
        for symbol in self.symtab:

            for filename in self.symtab[symbol]['def']:
                if filename not in self.filetab:
                    self.filetab[filename] = {'def': [], 'ref': []}
                self.filetab[filename]['def'].append(symbol)

            for filename in self.symtab[symbol]['ref']:
                if filename not in self.filetab:
                    self.filetab[filename] = {'def': [], 'ref': []}
                self.filetab[filename]['ref'].append(symbol)

    def is_defined_in(self, symbol, filename):
        if symbol not in self.symtab:
            return False
        if filename in self.symtab[symbol]['def']:
            return True
        return False

    def is_referred_in(self, symbol, filename):
        if symbol not in self.symtab:
            return False
        if filename in self.symtab[symbol]['ref']:
            return True
        return False

    def symbol_defined_in(self, symbol):
        """Return iterable of filenames this symbol is defined in."""
        if symbol not in self.symtab:
            return []
        return self.symtab[symbol]['def']

    def symbol_referred_in(self, symbol):
        """Return iterable of filenames this symbol is referred in."""
        if symbol not in self.symtab:
            return []
        return self.symtab[symbol]['ref']

    def filename_referred(self, filename):
        """Return iterable of symbols referred to in this filename."""
        if filename not in self.filetab:
            return []
        return self.filetab[filename]['ref']

