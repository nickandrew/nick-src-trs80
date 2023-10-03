# TRS-80 Utilities

This directory contains many miscellaneous utilities which I wrote,
or which I ported to the TRS-80.

<dl>
 <dt>amortz</dt>
 <dd>A loan amortization program written in C which outputs a table
 of months and payments.</dd>
 <dt>anagram</dt>
 <dd>C program to produce anagrams of a string argument.</dd>
 <dt>basic</dt>
 <dd>A utility to disable the "POKE" and "SYSTEM" keywords.</dd>
 <dt>bincheck</dt>
 <dd>A C program to output a checksum and XOR of each 256-byte
 block of a file.</dd>
 <dt>border</dt>
 <dd>A C program to draw an ASCII border around a lot of text.
 The border is of fixed size (right margin is column 79).</dd>
 <dt>cleanup</dt>
 <dd>A C program to process backspaces (character 0x08) in text
 files. The backspace character removes the character before it.</dd>
 <dt>cmd</dt>
 <dd>There is a utility in this directory called "REGIONS" which
 analyses a loadable file and determines the addresses of all
 contiguous memory regions used by the file. It also reports
 whether the file overlaps itself (which might be some kind of
 copy protection, or it might be a patch which can be merged by
 another of my utilities).</dd>
 <dt>copyit</dt>
 <dd>This program is the Swiss Army Knife of tape copy programs. It
 autodetects whether the file being read is a BASIC program, or
 EDTASM source code, or a loadable file, and alters its
 behaviour accordingly.</dd>
 <dt>day</dt>
 <dd>This simple program calculates and prints the day of the week.</dd>
 <dt>directory</dt>
 <dd>There's a utility in this directory called "VISIBLE" which
 "finds invisible user files on disks". I didn't know that there
 was a problem viewing them with "DIR".</dd>
 <dt>drop</dt>
 <dd>This utility converts a file to lower case.</dd>
 <dt>errors</dt>
 <dd>This utility patches a hook in the BASIC interpreter to print
 full text error messages. For example,
 "SYNTAX ERROR" instead of "?SN ERROR".</dd>
 <dt>fast-format</dt>
 <dd>This is a program to test whether it's possible to do a
 really fast format on a disk. I'm not sure how.</dd>
 <dt>fileupd</dt>
 <dd>This utility updates a file with lines from another
 file. The input files are assumed to be in sorted order, so this
 program is really a kind of merge. Only the first 13 characters
 of every line are compared.</dd>
 <dt>format</dt>
 <dd>This C program produces "wraparound output from a file". I think
 it is designed for email because there is a special case for the
 first character of a line being '&gt;'.</dd>
 <dt>gettok</dt>
 <dd>This program extracts the BASIC token strings from the ROM
 and writes an assembler source file with the definitions.</dd>
 <dt>granules</dt>
 <dd>This program calculates the number of free granules on a
 disk. A granule is the fundamental unit of disk allocation.
 There is also "map" which shows free granules in visual form.</dd>
 <dt>grep</dt>
 <dd>A simple grep utility. Only fixed strings are searched for,
 and comparisons are case-independent.</dd>
 <dt>ifupd</dt>
 <dd>Executes a command only if a file is updated (i.e. if the
 'U' flag is set in the file's directory entry).</dd>
 <dt>large-file-editor</dt>
 <dd>This is a line editor for large files (up to 128 Kbytes in
 size). It requires my 256 Kbytes RAM modification.</dd>
 <dt>memtest</dt>
 <dd>This is a background resident program to test memory. It
 displays a warning message if memory is found to be faulty.</dd>
 <dt>merge</dt>
 <dd>This C program merges "two files columnwise". I suppose that
 means it is like the Unix "paste" program. The comments note
 that I ported this program from "merge.b" which was written in
 the "B" language, the parent of "C", and which ran on NSWIT's
 Honeywell Level/66 mainframe.</dd>
 <dt>newc</dt>
 <dd>According to the comment, this program "gets rid of
 undesirable Shift/Down Arrow effects". Whatever <b>they</b>
 may be!</dd>
 <dt>newjkl</dt>
 <dd>This program looks like a patch to Newdos-80. It dumps the
 screen contents to the printer ... including graphics.</dd>
 <dt>newsfmt</dt>
 <dd>This C program "reformats news files to suit". I think that
 means stripping all unwanted headers and reformatting very
 long lines.</dd>
 <dt>pack</dt>
 <dd>This directory contains two implementation of the
 Unix "pack" program, one in C and the other in assembler.
 "pack" was the ancestor of "compress" which was the
 ancestor of "gzip" and "bzip2". Included is "pack",
 "pcat" and "unpack".</dd>
 <dt>pdir</dt>
 <dd>This program does a "printer-oriented DIR I P".</dd>
 <dt>peekhash</dt>
 <dd>This program takes a 16-bit TRS-80 type password hash
 and tries to find a corresponding password by brute force.
 It is not too hard, even for a TRS-80, to find synonyms.</dd>
 <dt>prime</dt>
 <dd>This program finds all prime numbers up to 65535.</dd>
 <dt>ptrdump</dt>
 <dd>There are two versions of a program in this directory
 which dump a file to the printer.</dd>
 <dt>repc</dt>
 <dd>This C program does repeat character encoding or decoding
 on a file. The output file starts with the magic sequence
 0x1b 0x1d and repeated characters represented by 0x10 followed
 by a repeat count followed by the repeated character. The
 0x10 character itself is repeat-encoded so this program is
 safe for binary files.</dd>
 <dt>report-writer</dt>
 <dd>The C program in this directory "ppk1" was written as
 an assignment solution for the University subject PPK
 (I've forgotten what the acronym stands for). Anyway it
 is a fairly flexible parser of line-oriented data files
 in a variety of formats. I'm sure my implementation
 provided far more than the specifications required, in
 only 600 lines of code. Other people were writing their
 solutions in COBOL, a spectacularly useless language
 for a program of this kind (or indeed any other kind).</dd>
 <dt>rot13</dt>
 <dd>This is rot13, actually 10 lines of C code.</dd>
 <dt>save</dt>
 <dd>This looks like a program to copy the TRS-80 "microchess"
 program from one tape to another.</dd>
 <dt>screen-dump</dt>
 <dd>This is some kind of screen dump program which writes
 the contents of the screen to disk sectors. Ugh!</dd>
 <dt>sort</dt>
 <dd>This C program sorts a text file. It looks like a
 bubble sort to me (again, ugh!). I wrote a much more
 lovely quicksort in PL/1 when I worked for IBM.</dd>
 <dt>split</dt>
 <dd>This directory contains a variety of programs to
 split large files into smaller files of various lengths.</dd>
 <dt>superc</dt>
 <dd>IBM had a great comparison utility called SUPERC
 which I wanted to emulate. This program doesn't come
 close, but it does detect inserted and deleted lines.
 </dd>
 <dt>tab4</dt>
 <dd>This program changes tabs in source files to spaces.
 The default tab width is 4. It understands that each tab
 character has varying width.</dd>
 <dt>tax</dt>
 <dd>I wrote this little C program to help with my
 parents' tax return.</dd>
 <dt>textdiff</dt>
 <dd>This program finds the "difference of two text files".
 </dd>
 <dt>tune</dt>
 <dd>This is a music playing program. I had calculated a
 frequency and duration table for each note. I don't remember
 how well it worked.</dd>
 <dt>unarc</dt>
 <dd>This is a TRS-80 port of a CP/M program written by
 Bob Freed. There are a few different versions in this
 directory because I couldn't figure out which, if any,
 was the latest.</dd>
 <dt>uncmprs</dt>
 <dd>This program "expands space compression codes in a file
 and deletes unusual characters". Gotta love how those pesky
 unusual characters get into files so they have to be
 automatically deleted. Space compression codes seem to
 be characters 0xc0 and up (where 0xc0 means 256 spaces
 and 0xc1 means 1 space). The unusual characters seem to
 be those in the range 0x80 - 0xbf, or chunky 2x3 TRS-80
 graphics characters.</dd>
 <dt>uncrc</dt>
 <dd>This program finds passwords which encode to any given
 TRS-80 password hash. Maybe that means I got the description
 for "peekhash" wrong.</dd>
 <dt>waveform</dt>
 <dd>I wrote this program under contract for Geoff Arthur
 when he wanted to produce a TRS-80 hardware/software package
 (there was an off-the-shelf ADC module available)
 to do waveform analysis for TV repair (Geoff was an old
 TV repairman if I recall). This program just displayed a
 demonstration waveform. Geoff didn't realise the TRS-80
 only had chunky graphics so he abandoned the idea of
 me writing this program for him and changed strategy to
 have somebody else write it under DOS. He told me that he
 had the program working once, but I don't know whether
 anything came of it.</dd>
 <dt>wc</dt>
 <dd>This C program counts (verbosely) the number of lines,
 words and characters in its input.</dd>

</dl>
