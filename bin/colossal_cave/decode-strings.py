#!/usr/bin/env python3
"""Decode all the encrypted strings in a Colossal Cave data file."""

import argparse
import yaml

import data

def main():
  parser = argparse.ArgumentParser(description="Decode Colossal Cave data file")
  parser.add_argument('--yaml', action='store_true', help="Output in YAML format")
  parser.add_argument('--infile', required=True, help="Source data.bin")
  args = parser.parse_args()

  with open(args.infile, "rb") as infile:
    buf = infile.read()

  all_data = data.Data(buf)

  if args.yaml:

    long_descriptions = all_data.long_descriptions()
    short_descriptions = all_data.short_descriptions()
    object_descriptions = all_data.object_descriptions()
    rtext = all_data.rtext()
    score_summaries = all_data.score_summaries()

    d = {}
    defs = {
      'long_descriptions': long_descriptions,
      'short_descriptions': short_descriptions,
      'object_descriptions': object_descriptions,
      'rtext': rtext,
      'score_summaries': score_summaries,
    }

    for k, v in defs.items():
      d[k] = [x.to_dict() for x in v]

    print(yaml.dump(d), end='')
    return

  else:
    print(f'Need arg --yaml')


if __name__ == '__main__':
  main()
