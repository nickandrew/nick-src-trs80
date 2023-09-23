# Colossal Cave aka Microsoft Adventure

Microsoft Adventure was a reimplementation for the TRS-80 Model 1
of the original "Adventure" game for the DEC PDP-10 and similar
mainframe computers, written by Crowther and Woods.

I had played the game on the DECSystem 20 at Deakin University Geelong
before I had my own computer, and I was given the Microsoft Adventure
later as a present.

The TRS-80 game is notable for its reasonably complete implementation of
the original, and its copy protection system.

For an in-depth look at the code and data, see
[Colossal Cave Internals](INTERNALS.md)

## Subdirectories

### boot-sector

Disassembled boot sectors for all known versions of the game
(version 1.0 and 1.1).

Source code for a boot sector for a normally formatted diskette
(not copy-protected).

### copier

Source code to copy Colossal Cave from a copy-protected diskette
to a normally formatted diskette.

duplic21.asm is the latest version; it can copy to either a protected
diskette or a normally formatted diskette.

### formatter

Source code to format a copy-protected diskette.

I disassembled TRSDOS DISK FORMATTER version 2.3 and hacked
in the track/sector mapping required for original Colossal
Cave diskettes.

## The copy protection system

The Microsoft Adventure was distributed on a self-booting diskette
which did not use the DOS; it used its own disk I/O subroutines. It
was an early example of "copy protected" software: standard copying
tools could not read or write the specially-formatted diskettes. The
program did not have any function for making backups either. If your
game diskette developed uncorrectable read errors, you'd have to pay
Microsoft for a replacement.

Saved games are written to the game diskette - there are 2 save slots -
so you wouldn't even be able to write-protect your original diskette.

Consequently, making a backup of this important diskette was a high
priority for me.

Protected diskettes were specially formatted with translated
track and sector numbers. The translation is:

* 0 => 0, 1 => 127, 2 => 125, 3 => 123, 4 => 121, 5 => 119, 6 => 117, 7 => 115, 8 => 113, 9 => 111
* and so on, for track numbers 10 through 34.

So Track 0 Sector 0 was the only sector on the diskette with a
regular track and sector number; this is needed for the diskette to
be bootable.

This was a great deal of fun to figure out, and to write code to copy
the "uncopyable" diskette successfully.

## Diskette layout

sector range | purpose
000-000 | Boot sector
001-062 | Game Code (loads at 0x4300-0x80ff)
063-085 | Save Game 2 data (loads at 0x4300-0x59ff)
086-108 | Save Game 1 data (loads at 0x4300-0x59ff)
109-349 | Static game data until end of diskette

Games are saved by copying the 23 x 256-byte memory area starting at
0x4300 which obviously contains the current game state. This memory area
is also loaded in the first 23 sectors of game code. The diskette dumps
I have contain different data in these 3 areas because the 2 save slots
were written to by whoever dumped the diskettes to emulated files.

## Virtual machine

The game includes some kind of virtual machine executor, the data
for which is interspersed among the Z80 code.

For more information, see [Colossal Cave Virtual Machine](VM.md)
