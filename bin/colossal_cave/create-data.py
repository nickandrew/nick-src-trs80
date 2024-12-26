#!/usr/bin/env python3
"""Create a Colossal Cave data file.

The data file is created from several input files:

  * 2 Save Game slots
  * A YAML file containing the text of the 5 sets of messages
  * Backup code

The YAML messages file is required. Save Game slots and backup code
default to zeroes if no file is supplied.
"""

import argparse
import yaml

import data
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
  parser = argparse.ArgumentParser(description="Encode Colossal Cave data file messages")
  parser.add_argument('--backup', help="Backup code .bin")
  parser.add_argument('--outdata', help="Output data .bin")
  parser.add_argument('--savegame1', help="Save Game 1 data .bin")
  parser.add_argument('--savegame2', help="Save Game 2 data .bin")
  parser.add_argument('--messages', required=True, help="Source messages .yaml")
  args = parser.parse_args()

  with open(args.messages, "r") as infile:
    msgs = yaml.safe_load(infile)

  long_description = table.LongDescription(messages=convert_to_message_array(msgs['long_descriptions']))
  short_description = table.ShortDescription(messages=convert_to_message_array(msgs['short_descriptions']))
  object_description = table.ObjectDescription(messages=convert_to_message_array(msgs['object_descriptions']))
  rtext = table.RText(messages=convert_to_message_array(msgs['rtext']))
  score_summaries = table.ScoreSummaries(messages=convert_to_message_array(msgs['score_summaries']))

  d = data.Data()

  b = long_description.generate_data(start_address=0x0200)
  d.set_chunk('long_descriptions', b)

  b = short_description.generate_data(start_address=0x4900)
  d.set_chunk('short_descriptions', b)

  b = object_description.generate_data(start_address=0x5300)
  d.set_chunk('object_descriptions', b)

  b = rtext.generate_data(start_address=0x6800)
  d.set_chunk('rtext', b)

  b = score_summaries.generate_data(start_address=0xb800)
  d.set_chunk('score_summaries', b)

  if args.savegame1:
    with open(args.savegame1, "rb") as ifp:
      b = ifp.read()
    d.set_chunk('save_game_1', b)

  if args.savegame2:
    with open(args.savegame2, "rb") as ifp:
      b = ifp.read()
    d.set_chunk('save_game_2', b)

  if args.backup:
    with open(args.backup, "rb") as ifp:
      b = ifp.read()
    d.set_chunk('backup_code', b)

  # Write the data file
  with open(args.outdata, "wb") as outfile:
    outfile.write(d.image())

if __name__ == '__main__':
  main()
