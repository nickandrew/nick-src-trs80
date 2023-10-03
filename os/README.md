# TRS-80 Operating Systems

This directory contains all my attempts at writing a better
operating system for the TRS-80, as well as some programs
which have a distinctive OS flavour.

<dl>
 <dt>filsys</dt>
 <dd>
 This directory contains my attempt to make a tree-structured filesystem
 on top of the Newdos-80 filesystem. I quite possibly succeeded in
 this effort. The utilities included are "cat", "cp", "filemake",
 "ls" and "mkdir". The filesystem metadata was stored in a file called
 "FILESYS/TEM" and the files themselves were named "fil00000/fil" through
 "fil99999/fil".
 <p>
 I think one area in which this filesystem fell short of
 the ideal was that the filesystem code was assembled with each utility
 rather than staying resident in high memory.
 </p>

 </dd>

 <dt>fs</dt>
 <dd>
 This code looks like it was intended to be a real unixlike filesystem
 but there isn't enough code to actually do anything (it's mostly
 declarations). Only the cache part has been written.
 </dd>

 <dt>newdos-80</dt>
 <dd>
 There's a patch in this directory which apparently "extends the range
 of DOS commands" and it assumes sysload to be in memory and running.
 There's another program which creates a command "*ERASE" to clear all
 memory to HIMEM. There's also "res", which is like sysload, and there's
 also "sys80" which is like sysload but it uses my 80 Kbyte hardware
 modification. There's "sysres", which is another variation on the same
 theme. And finally "trace", a background display of the Program Counter
 run from the clock interrupt timer.
 </dd>

 <dt>nix</dt>
 <dd>
 This is "nix", or "Nick's Operating System". Pity there isn't enough
 code for it to actually do anything.
 </dd>

 <dt>romplus</dt>
 <dd>
 "romplus" looks like the start of a replacement ROM for the System-80.
 I never used it. It doesn't appear to be my patched Micro$oft ROM
 either.
 </dd>

 <dt>unix-80</dt>
 <dd>
 In July 1984 I was so enamoured of Unix that I thought I should write
 a Unix-like OS for the TRS-80. It was beyond my capabilities, but I
 didn't find that out until I had written a few hundred lines of
 assembler code.
 <p>
 This code doesn't do anything - or maybe it shows a couple of processes
 competing for resources. There's actually quite a substantial amount
 of code there.
 </p>

 </dd>
 <dt>znix</dt>
 <dd>
 This looks like another attempt at a Unix-like filesystem for Newdos-80.
 Except in this case, the container is called 'ZNIX/SYS'.
 </dd>

</dl>
