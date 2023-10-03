# Export Utilities

This directory contains some Perl scripts.

`export-jcl.pl` creates export commands for the emulator to copy all
the files off a diskette to Linux.

`find-diffs.pl` looks through directories to find files with the
same name but different contents, to deduplicate the multiple
copies of things I had.

`getdirs.pl` creates directory listings, to be parsed by `export-jcl.pl`

`untoken.pl` converts a tokenised BASIC file (using the TRS-80 token
map) to plain text.
