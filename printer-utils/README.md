# TRS-80 Printer Utilities

This directory contains mostly spoolers and filters. I don't
recall why a print spooler was required.

<dl>
 <dt>driver</dt>
 <dd>This is billed as a "new printer driver". That's quite a feat
 for 9 lines of code. It appears that this code was intended to allow
 me to pause printout by pressing one of the keyboard keys.</dd>

 <dt>pcopy</dt>
 <dd>This program copies a file to the printer.</dd>

 <dt>pfilt</dt>
 <dd>This program filters out "rubbish" from the printer - only
 allowing 0x08, 0x0d from among the ASCII control characters. It
 won't help much against attempting to print an executable, but
 maybe it lets a CP/M text file be printed without the LFs.</dd>

 <dt>ptrfilt</dt>
 <dd>This one filters out Ctrl-N and Ctrl-O characters. I think
 those characters were for boldface, or maybe double-width.</dd>

 <dt>spool</dt>
 <dd>There's a program here to spool from printer to disk file.
 It used the *NAME mechanism (useful to send a command to a
 resident program). There's another pair of programs which
 look like they communicate, one being an end-user application
 and the other being a driver.</dd>

</dl>
