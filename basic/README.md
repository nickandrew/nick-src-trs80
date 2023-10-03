# BASIC Programs

I started writing in Z80 assembler only one month after receiving
my Dick Smith System-80 computer. However, I still recall writing
quite a lot of BASIC programs. Some of them are here (others I think
are still on cassette tape and it will take another project to
digitise the tapes into WAV files and feed them into an emulator
to recover their contents).

BASIC is a ghastly language with no consistency of syntax and
a variety of ad-hoc extensions (Disk BASIC for example). In most
cases I can only guess at what these programs were written to do.

Also due to the lack of documentation (and also comments) on these
programs it's possible that I have included code which I didn't
actually write. If that is the case then I apologise and hope
nobody will mind, after all these years.

<dl>
 <dt>appoint</dt>
 <dd>Manage a calendar with appointments and reminders.
 Turn the computer into an alarm clock and bulletin board.</dd>
 <dt>convert</dt>
 <dd>Change spaces in EDTASM source files to tabs. That was
 important because some programs didn't understand about whitespace.</dd>
 <dt>dialer</dt>
 <dd>In 1981-1982 I discovered the joys of telephone decadic dialling.
 I found that dialling was basically a matter of breaking and making
 the telephone circuit sufficiently quickly for the dial counters in
 the exchange to count digits correctly. With a bit of practice I
 was able to dial using my fingers on the "on hook" plate. Sometime
 later I wired up a relay to my computer (or used the internal cassette
 relay) and wrote this little program to click the relay and dial.
 The program even had a timer to stop the user from spending too long
 on the telephone!</dd>
 <dt>keyword</dt>
 <dd>This program appears to alter the system to add an extra function
 to BASIC. Maybe somebody will decode the instructions one day.</dd>
 <dt>life</dt>
 <dd>This one plays Conway's Game Of Life.</dd>
 <dt>lookit</dt>
 <dd>A tiny program to allow me to view a part of a binary file on
 disk. The file is opened as a Random access file. I don't know if
 it shows more than one byte at a time. It certainly isn't a hex
 dumper!</dd>
 <dt>morserec</dt>
 <dd>Some programs to generate morse code (sounds) and parse received
 morse code. I remember earning some money by transcribing part of
 <i>pilgrim's progress</i> into Morse code. I also remember recording
 morse receiptions from my shortwave radio and the computer was able
 to decode some of it (that was way cool, particularly as I have never
 been able to understand morse code myself).</dd>
 <dt>renumber</dt>
 <dd>BASIC had a terrible problem: numbered lines (no labels!). The
 problem with these lines was often that there weren't enough gaps
 to add changes to the program. So the holy grail for basic programmers
 was the renumber utility, which was often itself written in BASIC.
 I have no idea how the renumber utility coexisted with the program
 which it was supposed to renumber, but it happened somehow. I remember
 using a version which renumbered the lines, but not the GOTO statements.
 How useless was that?! From what I recall, my version was much more
 functional but sometimes there just wasn't room for the new
 number (like "goto10" ... spaces were optional in some BASIC
 implementations). This program is probably a pretty good in-memory
 renumber utility.</dd>
 <dt>roulette</dt>
 <dd>It looks like this program simulates a roulette player following
 a betting algorithm.</dd>
 <dt>wordproc</dt>
 <dd>This is a Word Processor, 1981 style. It's notable because it
 says <i>TRILOBYTE SOFTWARE</i> which is what I called my business
 in High School, and because the file contains linefeeds and other
 unexpected characters. It looks like this one will need some cleaning
 up. Don't give up your Micro$oft Word installations just yet.</dd>
</dl>
