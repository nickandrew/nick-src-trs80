# CMD file utilities

This directory contains programs which work with TRS-80 executable
files (i.e. `/CMD`).

<dl>
 <dt>compact</dt>
 <dd>Compact reads a CMD file and analyses the memory areas used
 by the file. TRS-80 CMD files contain chunks which specify a starting
 location and up to 256 data bytes to be loaded at that location.
 Programs were often patched by appending chunks which overlapped
 previously loaded addresses. The Compact program merges those
 patches and rewrites the CMD file in address order with the
 largest possible chunks for contiguous memory addresses.
 </dd>
 <dt>mdtocim</dt>
 <dd>Mdtocim reads a file containing a raw memory dump (i.e. with no
 structure) and writes a CMD format file. I used it to turn the
 Dick Smith Disk/Memory diagnostic program into a /CMD file.</dd>
 <dt>offset</dt>
 <dd>Offset is one of my best TRS-80 programs. To understand its
 function, first read the description of unoffset below and then
 return here.
 <p>
 Offset reads an executable file from cassette or disk and modifies
 the file so that it can be loaded without conflicting with DOS memory
 areas, and then execute automatically. Offset did this by analysing
 the memory areas used by the file, and only relocating those areas
 which were needed by DOS. Then offset would add a small chunk of
 code which would disable DOS and copy the relocated data to its
 correct load area, and then execute the program directly.
 </p>
 <p>
 The advantage of offset over LMOFFSET and other attempts to make
 cassette-based programs run from disk, is that offset calculated
 the highest memory address used by the program and moved only the
 necessary load data into a buffer above that address. So offset
 worked where other programs did not. Of course it was much more
 convenient to not have to reboot and issue commands before running
 the program, too.
 </p>
 </dd>
 <dt>unoffset</dt>
 <dd>Newdos/80 included a program called LMOFFSET. The function of
 LMOFFSET was to enable a cassette-based program to be run from a
 disk-based system. Cassette-based programs usually loaded at a
 low memory address (e.g. 0x4200) which was incompatible with DOS,
 because DOS used up to 0x5200. So LMOFFSET would read a cassette
 program, change its load addresses to load above the DOS memory
 area, then append a small chunk of code to be executed. This
 chunk of code would display a message then require the user to
 press reset (reboot without DOS) and then type a BASIC command
 to start execution of the program (which remained in memory).
 <p>
 Needless to say this was pretty yukky. It also didn't work on
 some programs, depending on what load addresses were used.
 </p>
 <p>
 Unoffset takes an LMOFFSET-modified CMD file as its input and
 reorganises the file into its original contents, removing the
 LMOFFSET module. The output file from unoffset should then
 be processed by offset.
 </p>
 </dd>
</dl>
