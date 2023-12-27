#!/usr/bin/env python3
"""Generate Assembler lookup tables for a messages file."""

import argparse
import yaml

import message
import table

def convert_to_message_array(array:list) -> list:
  """Convert an array of message dicts into message.Message.

  Args:
    array    [ { message_id: 1, text: ['line', 'line', ... ] }, ... ]

  Returns:
    [ message.Message(), ... ]
  """

  message_array = []
  for d2 in array:
    m = message.Message(message_id=d2['message_id'], text=d2['text'])
    message_array.append(m)

  return message_array

def main():
  parser = argparse.ArgumentParser(description="Generate Assembler lookup tables for a messages file")
  parser.add_argument('--messages', required=True, help="Input messages .yaml")
  parser.add_argument('--outasm', required=True, help="Output lookup table .asm")
  args = parser.parse_args()

  with open(args.messages, "r") as infile:
    msgs = yaml.safe_load(infile)

  long_description = table.LongDescription(messages=convert_to_message_array(msgs['long_descriptions']))
  short_description = table.ShortDescription(messages=convert_to_message_array(msgs['short_descriptions']))
  object_description = table.ObjectDescription(messages=convert_to_message_array(msgs['object_descriptions']))
  rtext = table.RText(messages=convert_to_message_array(msgs['rtext']))
  score_summaries = table.ScoreSummaries(messages=convert_to_message_array(msgs['score_summaries']))

  # The lookup table is generated at the same time as the encrypted data,
  # which is thrown away.
  long_description.generate_data(start_address=0x0200)
  short_description.generate_data(start_address=0x4900)
  object_description.generate_data(start_address=0x5300)
  rtext.generate_data(start_address=0x6800)
  score_summaries.generate_data(start_address=0xb800)

  with open(args.outasm, "w") as outasm:
    outasm.write('long_description_sector_map:\n')
    outasm.write(long_description.lookup_asm())
    outasm.write('\n')
    outasm.write('brief_description_sector_map:\n')
    outasm.write(short_description.lookup_asm())
    outasm.write('\n')
    outasm.write('object_description_sector_map:\n')
    outasm.write(object_description.lookup_asm())
    outasm.write('\n')
    outasm.write('rtext_sector_map:\n')
    outasm.write(rtext.lookup_asm())
    outasm.write('\n')
    outasm.write('score_message_sector_map:\n')
    outasm.write(score_summaries.lookup_asm())

if __name__ == '__main__':
  main()
