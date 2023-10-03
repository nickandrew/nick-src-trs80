# TRS-80 File Utilities

This directory contains some mostly trivial programs for text files.


<dl>
 <dt>addlf</dt>
 <dd>This program converts TRS-80 text files (lines ending in CR)
 to CPM or MSDOS format. It adds a LF after every CR and adds 0x1A
 at eof. The output goes to STDOUT, and this program looks like it
 runs under the zeta-bbs environment. There's also a C language
 version.</dd>
 <dt>chardiff</dt>
 <dd>This program looks for single-character differences in two files
 and reports only the differences bracketed by { }.</dd>
 <dt>chopfile</dt>
 <dd>This program splits a file into 20-kbyte chunks, presumably to
 make restart easier if file transfer fails.</dd>
 <dt>direct</dt>
 <dd>This program is a file archiver. Text or binary files can be
 added to the archive or extracted, and the contents of the archive
 can be listed. The stored files are not limited to the 8.3 format.
 The archive uses two files, "archive/DAT" for data and "archive/DIR"
 for the directory. The archive format is not compressed.
 <p>
 I wrote this program because I had seen "ARC" for DOS and CP/M
 and I wanted to be able to group related files for archiving or
 bulk transfer. I did not include compression in the storage format
 because I believed that tools should be single-purpose: a compressor
 for compressing files and an archiver for storage and retrieval.
 </p>
 <p>
 This program is here in both assembler and C. I wrote the C program
 for Unix/Minix. Just as an aside, when I was recovering all my TRS-80
 code, I had to extract a lot of files from these archives, so I wrote
 a Perl extractor and a Perl lister. It was a lot quicker to write in
 Perl. Someday I will add the Perl code to this directory.
 </p>
 <p>
 This is one of very few programs which actually comes with documentation.
 I wanted everybody to use this program. Even if it did cost them $5.
 </p>
 </dd>
 <dt>fromcpm</dt>
 <dd>This program converts a text file from CP/M (or DOS) line
 ending conventions (CR LF) to TRS-80 format.</dd>
 <dt>fromunix</dt>
 <dd>This program changes the LF line ending convention in a Unix text
 file to CRs.</dd>
 <dt>hexdump</dt>
 <dd>This program produces a hex dump of a file direct to printer.</dd>
 <dt>tocpm</dt>
 <dd>This program converts a text file of any format (Unix or TRS-80
 or CP/M) to CR LF line terminators.</dd>
 <dt>totabs</dt>
 <dd>This C program converts multiple spaces in an input file to
 TABs. Unfortunately it doesn't understand the length of TABs in
 its input!
 </dd>
 <dt>tounix</dt>
 <dd>This program converts a text file to the Unix line ending
 convention.</dd>
</dl>
