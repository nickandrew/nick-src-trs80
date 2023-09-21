# Colossal Cave Internals

## Virtual machine

The game includes some kind of virtual machine executor, the data
for which is interspersed among the Z80 code.

For more information, see [Colossal Cave Virtual Machine](VM.md)

## Locations and Rooms

There are 141 unique locations, numbered from 0x01 to 0x8d. Each location
has 2 textual descriptions - a full one, and a brief one. The game will
print the full description the first time a location is visited, and
the brief one the next few times a room description is required.

The player starts at location 0x01, "END OF ROAD". The full description is:

```
YOU ARE STANDING AT THE END OF A ROAD BEFORE A SMALL BRICK
BUILDING.  AROUND YOU IS A FOREST.  A SMALL STREAM FLOWS OUT
OF THE BUILDING AND DOWN A GULLY.
```

The brief description is:

```
YOU'RE AT END OF ROAD AGAIN.
```

Full descriptions are stored on diskette in the Static game data area starting at
offset 2f00 of `data10.bin` and brief descriptions at offset 7601.

Descriptions are *encrypted* on diskette using a stream cipher. The
core of the cipher is a permutation function I call `permute_random1`
in the disassembly, and `permute()` in Python. This permutation function
takes a 16-bit input, loops through various bitwise operations 15 times,
and makes a 16-bit output.

The assembly code for `permute_random1` is:

```
permute_random1:
        ld      hl,(random1)    ; 7ba9  2a b9 5e
        push    de              ; 7bac  d5
        ld      d,0fh           ; 7bad  16 0f      ; 15 loops through the permutation
X7baf:  ld      a,h             ; 7baf  7c
        and     a               ; 7bb0  a7         ; Reset the C flag
        rra                     ; 7bb1  1f         ; HL = HL / 2
        ld      h,a             ; 7bb2  67
        ld      a,l             ; 7bb3  7d
        rra                     ; 7bb4  1f
        ld      l,a             ; 7bb5  6f
        rla                     ; 7bb6  17
        rla                     ; 7bb7  17
        rla                     ; 7bb8  17
        rla                     ; 7bb9  17
        xor     l               ; 7bba  ad
        rla                     ; 7bbb  17
        rla                     ; 7bbc  17
        rla                     ; 7bbd  17
        and     40h             ; 7bbe  e6 40
        or      h               ; 7bc0  b4
        ld      h,a             ; 7bc1  67
        dec     d               ; 7bc2  15
        jp      nz,X7baf        ; 7bc3  c2 af 7b
        ld      (random1),hl    ; 7bc6  22 b9 5e
        pop     de              ; 7bc9  d1
        ret                     ; 7bca  c9
```

Or in python:

```
def permute1(hl):
  """Execute the permutation inner loop."""
  bit_0 = hl & 1
  bit_4 = hl & 0x10
  hl = int(hl / 2)
  xor = (bit_0 == 0) != (bit_4 == 0)

  if xor:
    hl = hl | (1 << 14)

  return hl

def permute(hl):
  """Permute value in HL; return new value."""
  for _ in range(15):
    hl = permute1(hl)
  return hl
```

Here's how the stream cipher works: For each message (text line) to
be printed, a 16-bit Initialization Vector (IV) is chosen. The IV
seeds the permutation function, which is run once before each
character to be printed. The low-order 8 bits of the output is
XORed against the character on diskette to compute the character
to be printed (clear bit 7 before printing, for reasons). Each 16-bit
output from the permutation function is the input for the next
run of the function.

How is the IV chosen? Let's look at the format on disk:

```
002f00 00 01 cb cc d6 ab d2 90 83 a2 e1 b5 86 d5 c6 cb  >................<
002f10 c4 dd e3 c6 93 9b 94 ac df bb f7 a7 93 e2 89 84  >................<
002f20 d6 a0 c7 ab 89 d3 df fa cd da f0 92 92 81 f8 bc  >................<
002f30 82 bb eb ed 9a f7 d0 85 d9 ca d0 c9 00 01 d0 d6  >................<
002f40 ca c7 d7 8b 88 c5 9c c1 e7 da d0 cd df d4 87 a7  >................<
002f50 9e f4 95 c4 d3 c8 92 a8 f7 84 89 90 b3 b2 b3 d7  >................<
002f60 e6 b2 da fa dc d2 f7 91 8c e4 8b a9 f0 ad e7 e1  >................<
002f70 f6 fd bc 88 dc d0 b3 cd df de 00 01 dd c5 a3 df  >................<
002f80 db 87 e6 c0 e7 a8 8b df cb cc cd ba 82 c9 83 9b  >................<
002f90 84 ab cd d5 92 a8 f7 85 93 8e ba b8 c9 00 02 fb  >................<
002fa0 cf e5 b3 ea d9 ef 87 8e 93 99 d9 87 ed d6 93 cd  >................<
```

The first byte is 00. Zero signifies the end of a message or the start of
the next message. The next byte is an index: 01. This is the index of the
location (END OF ROAD). Following bytes, all with bit 7 set, constitute
one line of description ("cb cc d6 ab d2 90 83 a2 e1 b5 86" decrypts to
"YOU ARE STA"). The message ends at offset 0x2f3c with a zero byte, and
is immediately followed by another index 01. The same index value means a
2nd or subsequent text line for the same location.

There are 3 messages associated with location 01, and the IV for each message
is 0x0102. The high order bits of the IV are the location, and the low order
bits are the offset sector number (offset 0x2f00 is sector 02).

All the messages are stored in sequence, and a message can overflow to
the next sector, or the messages for a location can overflow to the
next sector. The encoding on disk (where 00 represents the end of a
message) ensures that the first message for a location can be found
efficiently without decrypting any previous messages. All that's needed
is a map from the location number to the first sector: that's one byte
per location, 144 bytes all up (for reasons), which is quite efficient.

The map for full descriptions starts at disassembled address 0x4cb5.

The logic therefore, to display a full description for location N, is:
get the byte B at address 0x4cb5 + N, add a constant to B to find
the first sector to read. Read the sector, and scan looking for the
first message with index N. Construct an IV from (N,B). Decrypt the
message, reading the next sector (increment B) whenever the message
overflows. Loop to continue for subsequent messages for index N,
and stop looping when some other index is seen.

Brief descriptions start at offset sector number 0x49, and their
corresponding map starts at disassembled address 0x4eab.
