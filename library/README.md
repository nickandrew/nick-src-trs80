# TRS-80 C Library

This directory contains several C source files and their assembler
counterparts which are useful as library functions. The assembler
sources will be required to assemble many of my programs.

Note: the [Build System](../BUILD.md) supersedes the above
comment; any directory containing a `BUILD.yaml` file can build
the programs in that directory, and if there's no `BUILD.yaml` file
then it's Work In Progress.

Some of the sources in here were not written by me, but are required
to run a lot of my software.

<dl>
 <dt>atoi.c</dt>
 <dd>Implements atoi() and itoa()</dd>
 <dt>cinit.c</dt>
 <dd>This is the C code which runs at the start of every Small C
 compiled program.</dd>
 <dt>ctype.c and ctype.h</dt>
 <dd>Implements isalpha(), isupper(), islower(), isdigit(), isspace(),
 toupper(), tolower().</dd>
 <dt>doserr.c</dt>
 <dd>Provides doserr() which translates from a Newdos-80 error number
 to an error string.</dd>
 <dt>fputc.c</dt>
 <dd>Implements fputc() and feof() (the latter is a dummy function).</dd>
 <dt>fwrite.c</dt>
 <dd>Implements fwrite().</dd>
 <dt>getopt.c</dt>
 <dd>This is Henry Spencer's implementation of getopt().</dd>
 <dt>getuid.c</dt>
 <dd>Implements getuid() as a dummy function.</dd>
 <dt>getw.c</dt>
 <dd>Implements getw() and putw().</dd>
 <dt>index.c</dt>
 <dd>Implements index().</dd>
 <dt>malloct.c</dt>
 <dd>Implements malloc(), realloc(), calloc() and free().</dd>
 <dt>msgfunc.c</dt>
 <dd>Functions for dealing with the Zeta-BBS message base files.</dd>
 <dt>openf2.c</dt>
 <dd>Opens a filename and if error prints an error message and exits.</dd>
 <dt>pnumb.c</dt>
 <dd>Prints a string and a number and a string.</dd>
 <dt>rand.c</dt>
 <dd>Implements a simple random number generator.</dd>
 <dt>sbrk.c</dt>
 <dd>Implements sbrk() using brk().</dd>
 <dt>seekto.c</dt>
 <dd>Seeks to a given sector offset (sector size = 256).</dd>
 <dt>strchr.c</dt>
 <dd>Implements strchr().</dd>
 <dt>strcmp.c</dt>
 <dd>Implements strcpy(), strcmp() and strcat().</dd>
 <dt>strlen.c</dt>
 <dd>Implements strlen().</dd>
 <dt>wild.c</dt>
 <dd>These are some wildcard checking routines I wrote. It looks
 like it only recognises '*' as a metacharacter, so no it isn't
 a general regex library.</dd>
