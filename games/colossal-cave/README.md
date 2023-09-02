# Colossal Cave aka Microsoft Adventure

The Microsoft Adventure was distributed on a self-booting diskette
which did not use the DOS; it used its own disk I/O subroutines. It
was an early example of "copy protected" software: standard copying
tools could not read or write the specially-formatted diskettes. The
program could make a limited number of copies of the diskette for
backup purposes (2?) and once you had made that number of copies,
no more would be permitted.

This scheme allows some protection against loss, but it is not
perfect: diskettes can develop read errors over time, and playing
the game requires reading the diskette multiple times. Saved games
are written to the same diskette, so you wouldn't even be able to
write-protect your original or copies.

## The copy protection system

Protected diskettes were specially formatted with translated
track and sector numbers. The translation is:

* 0 => 0, 1 => 127, 2 => 125, 3 => 123, 4 => 121, 5 => 119, 6 => 117, 7 => 115, 8 => 113, 9 => 111
* and so on, for track numbers 10 through 34.

So Track 0 Sector 0 was the only sector on the diskette with a
regular track and sector number; this is needed for the diskette to
be bootable.

This was a great deal of fun to figure out, and write code to copy
the "uncopyable" diskette successfully.

# boot-sector

Disassembled boot sectors for all known versions of the game
(version 1.0 and 1.1).

Source code for a boot sector for a normally formatted diskette
(not copy-protected).

# copier

Source code to copy Colossal Cave from a copy-protected diskette
to a normally formatted diskette.

duplic21.asm is the latest version; it can copy to either a protected
diskette or a normally formatted diskette.

# formatter

Source code to format a copy-protected diskette.

I disassembled TRSDOS DISK FORMATTER version 2.3 and hacked
in the track/sector mapping required for original Colossal
Cave diskettes.
