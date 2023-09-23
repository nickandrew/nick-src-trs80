# Colossal Cave Virtual Machine

Colossal Cave implements a flexible bytecode interpreter, which controls
most of the game logic. Opcodes are mostly 1 byte long, and some have
additional operands. Little is known about the function of most of the
opcodes, but some are known to act as subroutines and there are
conditional and non-conditional relative jumps.
