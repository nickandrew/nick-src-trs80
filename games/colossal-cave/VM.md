# Colossal Cave Abstract Virtual Machine

Colossal Cave implements a flexible bytecode interpreter, which controls
most of the game logic. Opcodes are mostly 1 byte long, and some have
additional operands. Little is known about the function of most of the
opcodes, but some are known to act as subroutines and there are
conditional and non-conditional relative jumps.

## Opcodes

### Push the contents of Word Table 3

| Opcode | Address | Label | Description |
| 00     |         |       | push wt3 43ba (contents of 43ba, then 43ba) |
| 01     |         |       | push wt3 43bc |
| [...]  | | | |

### Push the contents of Word Table 1

| Opcode | Address | Label | Description |
| 47 | | | push_wt1_4300 |
| 5a | | | push_wt1_4326 |
| 7e | | | push_wt1_436e (contents of 436e, then 436e) |
| 7f | | | push_wt1_4370 (contents of 4370, then 4370) |

# Opcode 85..91 : Logical and arithmetic operations

| Opcode | Address | Label | Description |
| 85     | 5c67    | skip_5c67 | if hl <= bc return 0000 else return ffff |
| 86     | 5c53    | skip_5c53 | if hl < bc return 0000 else return ffff |
| 87     | 5c63    | cmp_bc_hl_2 | swap bc,hl; if hl <= bc return 0000 else return ffff |
| 88     | 5c4f    | cmp_bc_hl_1 | swap bc,hl; if hl < bc return 0000 else return ffff |
| 89     | 5c7a    | cmp_hl_bc_1 | if hl != bc return 0000 else return ffff |
| 8a     | 5c87    | cmp_hl_bc_2 | if hl == bc return 0000 else return ffff |
| 8b     | 5c94    | or_hl_bc | hl = hl or bc |
| 8c     | 5c9b    | and_hl_bc | hl = hl and bc |
| 8d     | 5ca2    | add_hl_bc | hl = hl + bc |
| 8e     | 5ca4    | sub_hl_bc | hl = hl - bc |
| 8f     | 5cab    | skip_5cab | hl = hl * bc |
| 90     | 5cb2    | skip_5cb2 | hl = bc / hl |
| 91     | 5cbc    | skip_5cbc | hl = bc % hl |

| 97     |         |           | Push the next word (2 bytes) |
| 98     |         |           | conditional jump if hl != 0 to following 2 bytes |
| 99     |         |           | conditional relative jump if hl == 0 |
| 9b     |         |           | store next byte in various places then call an opcode subroutine at 5c1f |
| 9c     |         |           | call opsub 5c26 then either return or opgoto contents of 5eb7 |
| 9d     |         |           | |
| 9e     |         |           | |
| 9f     |         |           | Load HL with 0x0000 |
| a0     |         |           | Do something then exec opcode 0x71, jump to 5b63 |
| a1     |         |           | opgoto next 2 bytes |
| a2     |         |           | looks like following bytes are a jump table |
| a3     |         |           | opgoto 63bb |
| a6     |         |           | z80 code follows |
| a7     |         |           | Return |

## Opcodes a8..c7

These opcodes call one of 32 bytecode subroutines.

| a8     | 7670 | opcode_a8_sub | gosub 7670 |
| a9     | 7673 | opcode_a9_sub |            |
| aa     | 7676 | opcode_aa_sub |            |
| ab     | 5f1f |               |            |
| b9     | 7695 | opcode_b9_sub |            |
| ba     | 76a3 | opcode_ba_sub |            |
| bd     |      |               | Print an object description |
| be     |      |               |            |
| bf     | 785d | opcode_bf_sub | Return a random number (0..n-1) |
| c0     |      |               |            |
| c1     |      |               | Print a message |
| c4     |      |               | Ask a yes or no question |

## Opcodes c8..e7

| c8     |      |               |            |

| c8     |      |               |            |
| c9     |      |               |            |
| ca     |      |               |            |
| cb     |      |               |            |
| cc     |      |               |            |
| cd     |      |               |            |
| ce     |      |               |            |
| cf     |      |               |            |
| d0     |      |               |            |
| d1     |      |               |            |
| d2     |      |               |            |
| d3     |      |               | wt7+0      |
| d4     |      |               |            |
| d5     |      |               |            |
| d6     |      |               |            |
| d7     |      |               |            |
| d8     |      |               |            |
| d9     |      |               | Use score_message_sector_map |
| da     |      |               |            |
| db     |      |               |            |
| dc     |      |               |            |
| dd     |      |               |            |
| de     |      |               |            |
| df     |      |               |            |
| e0     |      |               | Use long_description_sector_map |
| e1     |      |               |            |
| e2     |      |               | Use object_description_sector_map |
| e3     |      |               | Use special_message_sector_map |
| e4     |      |               | Use brief_description_sector_map |
| e5     |      |               |            |
| e6     |      |               |            |
| e7     |      |               |            |


## Memory addresses

Memory addresses used for location tracking:

432a, 4354, 435c:
   23 = Grate locked
   24 = Grate unlocked

433c - Looks like the main one for location
4340 - secondary location?
4348
434a

4362 - Yes/No question Input chars 0-1
4364 - Yes/No question Input chars 2-3
4366 - Input chars 4-5, etc
436c - First word chars 0-1
436e - First word chars 2-3
