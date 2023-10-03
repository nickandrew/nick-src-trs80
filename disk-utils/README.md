# Disk Utilities

This package contains programs which work directly with diskettes.

My disk subsystem was initially a standard single-density System-80 one.
I guess this meant it was memory-mapped just like the TRS-80 one. For
once Dick Smith decided against a trivial hardware change which ruined
compatibility with the TRS-80 Model 1 ... so thankfully all OSs and
disk-using programs written for the Model 1 worked fine on the System-80.

I tried to get Double Density by adding a suitable controller. The
original controller was the Western Digital WD-1771. I tried adding
the WD-1790 (I think that was its designation) which is supposed to
be able to do Double Density, at the expense of not being able to
handle 2 of the 4 Data Address Marks which the 1771 could make.

After some trouble getting my hardware and software working I had
single density working with the WD-1790, but double density just
didn't work somehow. So I bit the bullet and bought a "commercial"
Double Density adapter board made by Errol Rosser
(see [SYDTRUG home page](http://www.sydtrug.org/)).
Errol's board required the original Single Density controller to
plug into a socket on the board. It then switched between controllers,
using the Double Density controller only for Double Density work.
This preserved compatibility with the 4 Data Address Marks.

Oh yes, the programs ... I have no idea what most of them do. The code
looks like a lot of them were written around the same time.


<dl>
 <dt>duplicat</dt>
 <dd>The purpose of this program is clear, at least. It's a special purpose
 program to copy the Micro$oft Adventure from its original (supposedly
 "copy-protected") disk. The Original Adventure was written to a
 specially formatted disk where the sectors were numbered 127, 125, 123,
 etc... and so were the tracks. Or something like that. All this was
 a great deal of fun to figure out, and even more fun to figure out how
 to copy it successfully. I had to write a special FORMAT program, which
 is in this directory also.
 <p>
 I also wrote a copier which writes to a standard format diskette. It
 just made a lot of sense to cut out the stupid copy protection. I
 have the required patch to the program itself, somewhere.
 </p>
 </dd>
 <dt>trk</dt>
 <dd>I guess it's a track-by-track copy program ?</dd>
 <dt>write</dt>
 <dd>The comment on this one says it duplicates whole diskette
 contents, and the code is very similar to <b>trk</b>.</dd>
</dl>
