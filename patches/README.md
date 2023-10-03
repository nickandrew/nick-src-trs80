# TRS-80 Patches to other peoples' code

I patched quite a lot of programs for the TRS-80. Some of it was
for fun, like when I patched CMDFILE to have a graphic startup
message, some of it was more practical (e.g. to make EDAS work under
Newdos-80).

Here are all the patches which have survived as source code.
I haven't bothered to go through binaries looking for differences.

<dl>
 <dt>asylum</dt>
 <dd>Asylum was an infuriating semi-graphical adventure game.
 I patched it to save and load games from disk (apparently using
 direct disk I/O because the game could not co-reside with DOS).</dd>

 <dt>edtasm</dt>
 <dd>This is for a graphical startup banner.</dd>

 <dt>edtasm-plus</dt>
 <dd>I had the cassette version of this program I think, and so I
 patched it to load and save to disk. At least this patch used DOS,
 I remember a time when I had EDTASM but no DOS at all, and I was
 patching it to write its files direct to disk sectors. Ugh!!!</dd>

 <dt>eliminator</dt>
 <dd>This was a great arcade-style game with one fault - it
 required the CLEAR key, which I didn't have at that time.
 So this patch allows 'X' to substitute for CLEAR.</dd>

 <p>
 There's also a patch to load/save high scores from disk.
 </p>

 <dt>fortran-80</dt>
 <dd>It seems that FORTRAN-80 required source files to end with
 the character 0x1C and ordinary text files did not. So here's
 a patch to fool the program into thinking that character is
 there when EOF is reached.</dd>

 <dt>fs1</dt>
 <dd>Flight Simulator 1 was probably the most infuriating program
 I encountered on the TRS-80, except perhaps for Interlude :-).
 <p>
 Apart from being dreadfully slow, it was written for cassette loading
 and used its own mini-loader and its own cassette input code (at 500
 bits per second?). I suppose this was so that the program could even
 be used on the Level 1 computer, which supported cassette I/O at 250
 bits per second only (for no apparently good reason I think!).
 </p>
 
 <p>
 The mini loader was the first level of copy protection - most people made
 analogue audio copies of this program. The second level was that the code
 went through some kind of translation during or after loading. I don't
 recall whether I was able to work through that translation properly.
 </p>

 <p>
 Anyway the patch given here has nothing to do with copy
 protection; it allows my joystick to control the ailerons
 and rudder.
 </p>

 </dd>

 <dt>microsoft-adventure</dt>
 <dd>The Microsoft Adventure was fun, lots of fun. I had previously
 played "adventure" on a DEC System-20 at Deakin University where
 my uncle Peter Caldwell was a lecturer. I also played it extensively
 at a symposium called Computing-80 which was run by NSWIT in
 1980. Each school was invited to send one or two computing-aware
 students from years 10 through 12 to the symposium, and I was the
 "delegate" from my high school. I had to pretend that I was in
 Year 10, because I was actually in Year 9, and so strictly speaking
 I didn't qualify for the event ... but then again, I was more than
 qualified for the material covered.
 <p>
 We sat in University-like classes for a week where we were taught
 such staples of computing science as Structured Programming and
 Recursion. That was okay, but in our off-hours we got to play on
 NSWIT's mainframes, and boy did we ever play. I seem to recall we
 had an account on their Pr1me system, which had Adventure, and I
 spent many hours drawing a map of Colossal Cave, and got about
 two thirds of the way through the puzzles by the end of the week.
 I spent most of my time hanging around with a boy I met there
 who was very intelligent. His name was Ian Gronowski (sp?).
 Like me he was also a Year 9 student. He
 introduced me to the Hitch Hikers' Guide to the Galaxy (this is
 in the days when it was a radio play _only_, no fancy books nor
 games, and it wasn't known to every geek on the planet then)
 and the works of Harlan Ellison, particularly Deathbird Stories
 which he was reading at the time, and which I didn't get my
 own copy of until I visited a large bookstore in the USA.
 </p>

 <p>I wanted to get Ian's contact details but unfortunately he didn't
 attend on the last day of the event and so I lost contact with him,
 except that I saw his name and photo in the newspaper one day. He
 was the top HSC student of my year, earning 499 marks out of 500.
 <p>

 <p>
 Oh yes, back to Microsoft Adventure. I got that on diskette for
 christmas. It permitted perhaps 3 copies only to be made. I didn't
 want to ever lose this program (I still have the original diskette
 and its packaging). So I spent around 4 days straight playing the
 game until I had solved it, then another 2-3 days straight working
 out its copy protection mechanism so that I could copy it.
 </p>

 <p>
 The copy protection mechanism is quite straightforward and also
 quite effective. All the tracks and sectors on the disk are
 numbered differently to the norm. The norm is tracks 0 through 39
 (or 79 for those of us with 80-track disk drives) and sectors
 0 through 9 (or 18 or 35 when double-density is added to the picture).
 Anyway the Microsoft Adventure was shipped on a single-sided
 single-density 40 track diskette so we're only talking 0-39 and 0-9
 here. Well the track and sector numbers were mapped so they went
 127, 125, 123, etc. instead. This was excluding the boot sector
 which was necessarily written with the standard numbering, and
 possibly all of track zero.
 </p>

 <p>
 So the copy task simply became a matter of writing a disk formatter
 which would use the mapped numbers, and a full-disk copy tool which
 would use the mapped numbers too. I wrote both of those in about
 2 days and that was great.
 </p>

 <p>
 Later I was told that SUPERUTE (an amazing mega-utility written by
 Kim Watt) could copy that program by using its "special copy"
 function (or something like that). SUPERUTE would read each track
 and analyse its contents (sector lengths etc) and then build a
 special format on the fly for the copy. It was truly a spectacle
 of overkill. I bet my custom format/copy was a lot faster.
 </p>

 <p>
 Anyway this directory contains a disassembled source for the original
 boot sector, with the mapped track and sector numbers, and a modified
 one which does not map the numbers. Yep, I figured out after a while
 that there was no point preserving the copy protection, so I wrote
 it to a standard diskette and I patched out the mapping code in both
 the boot loader and the game itself.
 </p>

 <p>
 My "trs80-disk-utils" package contains a collection of the format
 and full-disk-copy programs which I used to accomplish this feat.
 </p>

 </dd>

 <dt>nedas</dt>
 <dd>This directory contains a patch to allow NEDAS to read EDTASM
 type files properly. Apparently there was some difference between
 Newdos-80 and LDOS in file I/O which meant programs had to be
 patched to convert from LDOS to Newdos-80.</dd>

 <dt>scripsit</dt>
 <dd>This is a patch for the "@" key in scripsit. I have no idea
 what the "@" key is supposed to have done! Perhaps it was
 something like a command mode and thus couldn't be used in
 documents? Revisiting the TRS-80 after 15+ years, nothing
 surprises me any more...
 <p>
 There's also a patch to print on the System-80, which had a
 port-mapped printer rather than the Model 1's memory mapped
 one.
 </p>

 </dd>

</dl>
