#  vim:expandtab:sw=4:ts=8:sts=4:ai:
"""Class and methods representing BUILD rules in a YAML file."""

import yaml

class BuildFile(object):
    def __init__(self, filename=None):
        self.targets = {}
        self.filename = filename
        if filename:
            with open(filename, 'r') as in_f:
                self.targets = yaml.safe_load(in_f)

    def add_depends(self, target, filename):
        if target in self.targets:
            d = self.targets[target]['depends']
            d.append(filename)
            self.targets[target]['depends'] = sorted(d)

    def get_depends(self, target):
        if target in self.targets:
            d = self.targets[target]['depends']
            return d
        return None

    def write(self, filename=None):
        if not filename:
            filename = self.filename

        if filename:
            with open(filename, 'w') as out_f:
                yaml.safe_dump(self.targets, stream=out_f)
