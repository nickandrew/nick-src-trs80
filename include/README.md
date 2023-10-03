# TRS-80 Include (ASM) files

This directory contains various ASM files which I used in many
source packages, to define common constants or provide useful
functions. In some cases I had
several different versions of each file, and I have tried to combine
them to produce a "latest and greatest" of each.

These files are listed as dependencies where needed in the
[Build System](../BUILD.yaml) and work is still in progress
to make consistent definitions and eliminate duplicate code.

The source files are:

<dl>
 <dt>ascii.asm</dt>
 <dd>ASCII character abbreviations (CR, LF, etc)</dd>
 <dt>asctime.asm</dt>
 <dd>A function usable by a C program to convert the current
 date/time into the format 'dd mmm yy hh:mm:ss'.</dd>
 <dt>call.asm</dt>
 <dd>This is the "Small C arithmetic and logical library". I didn't
 write it, but I probably made some changes to it. It seems essential
 to get some of my programs going, so it is included here.</dd>
 <dt>debug.asm</dt>
 <dd>A function and a macro to assist in debugging the Small C
 compiler output. Apart from porting the J.E. Hendrix Small C compiler
 to TRS-80, I modified it to improve its handling for some data types.
 Debug would print the function name to the screen and then delay a bit
 to give me time to read the name.
 </dd>
 <dt>debugf.asm</dt>
 <dd>Very similar to debug.asm, with a much smaller delay.</dd>
 <dt>doscalls.asm</dt>
 <dd>This file gave symbolic names to the constant addresses used
 by DOS to open and close files, etc. as well as commonly occurring
 error codes and some differences between Model 1 and Model 3.</dd>
 <dt>external.asm</dt>
 <dd>This was a definition of how my system used high memory locations
 in the region 0xFE00 through 0xFFFF. A lot of this is specific to the
 Zeta BBS (see trs80-zeta-bbs package) but it also might be used by
 the programs which manipulated my 256 Kbyte paged memory subsystem.
 </dd>
 <dt>filename.asm</dt>
 <dd>Some functions for manipulating filenames.</dd>
 <dt>fread.asm</dt>
 <dd>fread() function callable from C.</dd>
 <dt>ftell.asm</dt>
 <dd>ftell() function callable from C.</dd>
 <dt>gettime.asm</dt>
 <dd>Functions for getting the year/month/day/hour/minute/second
 callable from C.</dd>
 <dt>libc.asm</dt>
 <dd>Standard I-O library for Small C.
 In addition to defining some symbolic constants, the following
 C functions were implemented:
 fileno(), putchar(), fputc(), getc(), fgets(), fread(), fgetc(),
 fputs(), exit(), strcpy(), fclose(), fopen(), feof(), fflush(),
 fseek(), rewind(), brk() and FIX_PROG_END.
 The following were added as do-nothing functions:
 sprintf(), fprintf(), printf().
 I seem to recall that Small C used the "wrong" function calling
 conventions and so use of varying numbers of arguments in functions
 was impossible.</dd>
 <dt>listalc.asm</dt>
 <dd>Defines some list manipulation functions.</dd>
 <dt>malloc.asm</dt>
 <dd>Implements malloc(), callable from C.</dd>
 <dt>prognumb.asm</dt>
 <dd>Some constants to identify individual programs. I'm not
 sure why this was needed.</dd>
 <dt>raw.asm</dt>
 <dd>Implements raw() and cooked(), callable from C.</dd>
 <dt>reada.asm</dt>
 <dd>Reads a line of text from the keyboard, callable from C.</dd>
 <dt>savepos.asm</dt>
 <dd>Saves and restores current file position, callable from C.
 I don't know why I didn't implement fseek/ftell ... perhaps
 because the Small C compiler did not implement the "long"
 data type.</dd>
 <dt>setpos.asm</dt>
 <dd>Similar to savepos.asm, but enough differences that I thought
 it better to release both files.</dd>
 <dt>unlink.asm</dt>
 <dd>unlink(), callable from C.</dd>
</dl>
