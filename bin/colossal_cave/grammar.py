"""Encode and decode the Colossal Cave grammar.

The game has hardcoded tables of nouns and verbs. Each 3-4 character
word is encoded into 3 bytes:

* The character set is ' ', '@', A-Z, '['
* Space is an alias for '@'
* '2' is an alias for '[' (I don't know why)
* The game deals only in uppercase

In that scheme, there are 5 data bits per unique character. 5 x 4 = 20,
so that will fit into 3 bytes with 4 bits to spare.

There are 4 lookup tables. Each entry is 3 bytes long. The lookup function
takes 4 input characters and returns a 16-bit index into the table. The
table includes aliases, so several different strings may return the
same index.

The end of the table is identified by an entry starting with 0x00. Bit 7 of
the first byte means "increment index" and is set on the first entry of
a set of aliases.

Input:

   010ABCDE
   010FGHIJ
   010KLMNO
   010PQRST

Output:

b: 0001ABCD
c: FGHIJEON
d: KLMPQRST
"""

def _transform(c:int):
  if c == 0x20:
    return 0x00
  if c == 0x32:
    return 0x1b
  if c < 0x40 or c > 0x5b:
    raise ValueError(f'invalid char {c}')
  return c - 0x40

def encode(verb:str):
  """Encode a 4-character uppercase string into 3 bytes."""

  char_0 = _transform(ord(verb[0]))
  char_1 = _transform(ord(verb[1]))
  char_2 = _transform(ord(verb[2]))
  char_3 = _transform(ord(verb[3]))

  bin_0 = f'{char_0:08b}'
  bin_1 = f'{char_1:08b}'
  bin_2 = f'{char_2:08b}'
  bin_3 = f'{char_3:08b}'

  munge_b = '0001' + bin_0[3] + bin_0[4] + bin_0[5] + bin_0[6]
  munge_c = bin_1[3] + bin_1[4] + bin_1[5] + bin_1[6] + bin_1[7] + bin_0[7] + bin_2[7] + bin_2[6]
  munge_d = bin_2[3] + bin_1[4] + bin_1[5] + bin_3[3] + bin_3[4] + bin_3[5] + bin_3[6] + bin_3[7]

  final_b = int(munge_b, 2)
  final_c = int(munge_c, 2)
  final_d = int(munge_d, 2)

  return bytes([final_b, final_c, final_d])

def decode(word:bytes):
  """Apply the opposite bit transformation to encode()."""

  final_b = word[0]
  final_c = word[1]
  final_d = word[2]

  bin_b = f'{final_b:08b}'
  bin_c = f'{final_c:08b}'
  bin_d = f'{final_d:08b}'

  munge_0 = '010' + bin_b[4] + bin_b[5] + bin_b[6] + bin_b[7] + bin_c[5]
  munge_1 = '010' + bin_c[0] + bin_c[1] + bin_c[2] + bin_c[3] + bin_c[4]
  munge_2 = '010' + bin_d[0] + bin_d[1] + bin_d[2] + bin_c[7] + bin_c[6]
  munge_3 = '010' + bin_d[3] + bin_d[4] + bin_d[5] + bin_d[6] + bin_d[7]

  final = chr(int(munge_0, 2)) + chr(int(munge_1, 2)) + chr(int(munge_2, 2)) + chr(int(munge_3, 2))

  final = final.replace('@', ' ')
  final = final.replace('[', '2')

  return final
