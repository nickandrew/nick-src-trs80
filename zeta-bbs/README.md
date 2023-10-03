# TRS-80 - Zeta BBS

My Zeta BBS evolved through many iterations. I started writing code
(in BASIC!) in December 1984. After a while I rewrote everything in
Assembler (and even later, in C). The official birthdate of Zeta BBS
was 1st February, 1985.

Zeta started from the most humble beginnings. I had bought a 300 bps
modem around September 1984, so I could dial into BBSs and the
University modems just like my friend Mark McDougall, who was in
the same course and year as me. But the modem wasn't the beginning -
Zeta's germination started with something even smaller - a single
red LED.

The LED was attached to a circuit called "visual ring detect". The
circuit came from one of the hobbyist magazines. The idea was to
connect the circuit to a telephone line and the LED would flash
when the telephone rang. Of course this was illegal because the
device was not TELECOM-approved, so the magazine published the
circuit but labelled it for private telephone use only.

Anyway my reasoning was as follows: If a telephone ring signal
(a nasty jumble of 50 volt AC pulses) could be reduced to light
in a single LED, then the LED could be replaced by an opto-coupler
(which is basically a LED and a photo-detector inside a chip)
and the detector could be coupled to the computer, which would be
able to tell when the phone was ringing. Knowing when the phone
was ringing, the computer could then flip a relay which would
connect the (approved) modem to the telephone circuit. The modem
being in ANSWER mode would start to talk to the other party's
modem and there would be a connected data circuit!

This was in the days before auto-answer modems existed, before
Hayes brought out the famous AT command set (the source of so
much modem trouble over the years). At least _I_ did not
have access to any fancy gear, I only had a very crappy
<i>Dick Smith Dataphone</i> modem and a ring-detect circuit...

So I wired up the computer as described above. I managed to blow
up a few opto-couplers and also the computer's cassette relay
as I've always been hopeless at analogue electronics, but eventually
I got something which sorta worked.

I setup the gear on my parents' telephone, which was also a
business line, between the hours of 11pm and 7am daily. Many
people called outside those times and my mother got quite used
to hearing the persistent whine of a 300 baud modem at the other
end. Zeta BBS was born!

And to cut a long story short, Zeta was a free service for a
while as I experimented and wrote more software for it. I
hooked it up to Fidonet, joining the first group of Fidonet
users in Australia (net was run by a chap called Brian Gatenby)
and I wrote a gateway between Fidonet and ACSNet which ran
between my computer and a minicomputer at NSWIT and Larry Lewis'
Prophet BBS. It was called ACSGate.

Here are a bunch of directories which contain a fairly complete
picture of the source code for the Zeta BBS. Nothing has been
tested.

## Zeta BBS - Catalogs

This directory contains some programs to maintain the online files catalog.
The BBS was floppy based (3 x 80 track double sided, double density) and
so sometimes files were "available" but not "online".

<dl>
 <dt>fixwhere</dt>
 <dd>This program "builds and maintains file catalogues".</dd>

 <dt>fmerge</dt>
 <dd>This C program "merges CATALOG/NEW and FILELIST/ZMS
 into CATALOG/UPD with unknowns filed in CATALOG/UNK".</dd>

 <dt>rearr</dt>
 <dd>This C program rearranges the CATALOG/ZMS format to put
 the filenames at the start of each line.</dd>

 <dt>volume</dt>
 <dd>This program determines if a particular volume (diskette)
 is mounted.</dd>

</dl>

## Zeta BBS - Communications

I tried to gather low level communications routines and some
protocols into this package.

<dl>
 <dt>acsnet</dt>
 <dd>Protocol handler for ACSnet news and email. I don't know what
 protocol this program was implementing, but from the code it looks
 complete.</dd>
 <dt>answer</dt>
 <dd>This program took care of the initial modem handshake and
 invocation of Fidonet protocol call reception too. No
 messing with Ring Indicate here, this program was used when I
 got an auto-answer modem.</dd>
 <dt>carrier</dt>
 <dd>This resident program monitored the carrier signal at all
 times.</dd>
 <dt>devices</dt>
 <dd>This resident program sets up and implements all the special
 devices.</dd>
 <dt>dialout</dt>
 <dd>This program dials out and initiates Fidonet protocol transfers.</dd>
 <dt>fcp</dt>
 <dd>This program performs the Fidotalk connection protocol.</dd>
 <dt>ftalk</dt>
 <dd>This program sends a mail "packet" (and file attaches).
 There's also "ftalk2" which combines the functions of ftalk
 and getpkt.</dd>
 <dt>getpkt</dt>
 <dd>This program receives a Fidonet "packet".</dd>

</dl>

## Zeta BBS - File Transfer

This directory contains some file transfer programs which I used
within and maybe outside the Zeta BBS environment.

<dl>
 <dt>capture</dt>
 <dd>This is a non-protocol upload program (ASCII data capture).</dd>
 <dt>xfer</dt>
 <dd>This program provides a menu for file transfers.</dd>
 <dt>xmodem</dt>
 <dd>There are various incarnations of Xmodem transfer programs
 in this directory.</dd>

</dl>

## Zeta BBS - Games

At one time I had the original Adventure running on Zeta. I believe that
it required a reboot to get back to the BBS though. Later I got Zork
running ... by disassembling the infocom executor, massaging it into
a source code format, and then reassembling the source code to live
within the Zeta BBS environment.

This package contains my work on the Zork 1 executor. It's modified
Infocom code, but I don't think Infocom are around to care any more.
Anyway, there are free Infocom executors around, so it's not as if
you <b>need</b> this code. I'm just showing it here for research
purposes, as the work that I did on it. Please note that the Zork 1
datafile is <b>not</b> included in this package.

<dl>
 <dt>zork</dt>
 <dd>Massaged Z-machine executor including Zeta BBS patch to make the
 lamp flicker and go out after 30 moves (only cripples non-members).</dd>
</dl>

## Zeta BBS - High Memory

This directory contains some files which manipulate my 256 Kbyte RAM
modification and/or stay resident in high memory.

<dl>
 <dt>errlog</dt>
 <dd>This program hooks into DOS errors (how?) and logs certain errors
 (such as permission denied) to the LOG_MSG device.</dd>
 <dt>ptrlog</dt>
 <dd>This program logs all output from LOG_MSG to disk.</dd>
 <dt>real</dt>
 <dd>This program uses my Real Time Clock circuit.</dd>
 <dt>special</dt>
 <dd>This program sets up the Zeta BBS environment (event hooks
 and global variables in high memory area, for example).</dd>
</dl>

## Zeta BBS - Include

This directory contains the standard assembly include files which
were required to compile almost anything for the Zeta BBS
environment.

<dl>
 <dt>bb7func.asm</dt>
 <dd>Treeboard message-base file I/O functions.</dd>
 <dt>bbopen.asm</dt>
 <dd>A file open function which checks privileges first.</dd>
 <dt>chksysop.asm</dt>
 <dd>Check if we are running as the sysop.</dd>
 <dt>fidonet.asm</dt>
 <dd>Our identity within Fidonet (and peer identities).</dd>
 <dt>fortyhex.asm</dt>
 <dd>Message output function.</dd>
 <dt>getuname.asm</dt>
 <dd>Function to return the current user name.</dd>
 <dt>libcz.asm</dt>
 <dd>Variant of the Small C Standard I/O library for Zeta environment.</dd>
 <dt>linein.asm</dt>
 <dd>A sophisticated line input routine.</dd>
 <dt>morepipe.asm</dt>
 <dd>Pagination and word wrap routine.</dd>
 <dt>msghdr.asm</dt>
 <dd>Format of the MSGHDR.ZMS file.</dd>
 <dt>msgtop.asm</dt>
 <dd>Format of the MSGTOP.ZMS file.</dd>
 <dt>program-template.asm</dt>
 <dd>A template for assembling a C program for execution in the Zeta environment.</dd>
 <dt>routines.asm</dt>
 <dd>A bunch of common routines.</dd>
 <dt>rs232.asm</dt>
 <dd>Definitions for my RS-232 interface.</dd>
 <dt>stats.asm</dt>
 <dd>Format of the STATS.ZMS file (keeps caller counts, etc).</dd>
 <dt>stddev.asm</dt>
 <dd>Routines for standard device usage.</dd>
 <dt>system.asm</dt>
 <dd>Provides the system(cmd) call for Small C programs.</dd>
 <dt>times.asm</dt>
 <dd>Some routines for time handling.</dd>
 <dt>userfile.asm</dt>
 <dd>Format of one USERFILE entry.</dd>
 <dt>userfunc.asm</dt>
 <dd>uopen(), uclose() and others. Possibly was not used.</dd>
</dl>

## Zeta BBS - Internal

This directory contains some "internal" programs - things which the
system ran without the user's knowledge.

<dl>
 <dt>cron</dt>
 <dd>Like the Unix utility, "cron" executes commands at certain times
 and at certain intervals. Unlike Unix, it didn't run as a daemon and
 so it updated its control file with "next execute" datestamps.
 I have provided a sample crontab.</dd>
 <dt>exitsys</dt>
 <dd>This program runs each time a user logs out.</dd>
 <dt>logon</dt>
 <dd>This program accepts a user's name and password and starts
 their preshell.</dd>
 <dt>preshell</dt>
 <dd>This program executes some commands for the user who has
 just logged in.</dd>
 <dt>setup</dt>
 <dd>This program prepares the computer for use as a remote system.</dd>
 <dt>swapper</dt>
 <dd>This program uses my 256 Kbyte memory subsystem to allow multiple
 programs to be resident in memory concurrently (although not to
 execute concurrently). A program can call another program, and the
 older program will be transparently "swapped" into inaccessible
 physical memory, while fresh memory pages will become available
 for the newer program. When the newer program exited, its pages
 would be freed and the pages belonging to the older program would
 be replaced at their physical locations, and the older program
 would resume executing from where it left off. It was quite a
 lovely system.</dd>
</dl>

## Zeta BBS - Mail System

This directory contains everything related to the Zeta BBS
private message system (including email).

<dl>
 <dt>mail-command</dt>
 <dd>This directory contains the source to the end-user mail
 application</dd>
 <dt>mail-in-c</dt>
 <dd>This directory contains a C language reimplementation of
 the Zeta Mail system. I don't know if the program is complete.</dd>
 <dt>msgdel</dt>
 <dd>This program deletes mail messages older than a certain date.</dd>
</dl>

## Zeta BBS - Maintenance

<dl>
 <dt>adduser</dt>
 <dd>Add a new user to the user file or give a person member status.</dd>
 <dt>credit</dt>
 <dd>Alter a person's credit. In the latter years of the lifetime
 of the Zeta BBS I ran it as an optional-payment system. $1 per month.</dd>
 <dt>deluser</dt>
 <dd>Delete a user or lock out the user.</dd>
 <dt>junklog</dt>
 <dd>Delete unwanted lines from the system logfile.</dd>
 <dt>logclean</dt>
 <dd>Truncate from the front of the (to be?) printed log.</dd>
 <dt>printlog</dt>
 <dd>Print the log file, but only complete pages.</dd>
 <dt>ulist</dt>
 <dd>List the contents of the user file.</dd>
 <dt>usrclean</dt>
 <dd>Delete inactive non-members.</dd>
</dl>

## Zeta BBS - Networking

This directory contains a bunch of programs which contributed to
the Zeta BBS exchanging messages with the Fidonet and ACSNet
networks.

<dl>
 <dt>ankhmail</dt>
 <dd>Process all incoming files from other network nodes, including
 email, message bundles, Fidonews, USENET News files and Nodediffs.
 Name is a pun on "arcmail".</dd>
 <dt>cpnews</dt>
 <dd>"Copies an ACSnet file into NEWSTXT".</dd>
 <dt>fidonet</dt>
 <dd>This directory contains a compendium of programs which I have
 previously released as "fidonet-packet-handlers".
 There are programs here to scan the message bases for messages
 which need to be sent elsewhere, which reformat them into transport
 files of various formats, and do the reverse actions, unpacking
 files which we have received from other nodes and inserting
 the messages into the MAIL or BB message bases. And much more!</dd>
 <dt>pkthack</dt>
 <dd>Split a big packet into smaller packets.
 "packet" was the Fidonet terminology for a collection of messages
 wrapped up in a binary file of the appropriate format. Not an IP
 packet!</dd>
 <dt>pktlook</dt>
 <dd>Check out what's inside a packet.</dd>
 <dt>uechoarc</dt>
 <dd>"A filter for echoarc messages". I'm afraid I don't know
 what that means now.</dd>
</dl>

## Zeta BBS - Treeboard

The Treeboard was the jewel in the crown of Zeta BBS. It was a public
message board, as all BBSs needed, but with a difference. It used a
tree hierarchy of topics and users could create their own topics. Like
the "room" idea of the Citadel BBS, which came well before Zeta, but
a little more nerdy as a person who didn't like, say, sports, could
skip sports at the top level and that would avoid all sporting-type
discussions.

The topics were organised as a tree. In the first incarnation I
used a single 8-bit byte for each topic code, organised bitwise
as AAABBBCC, where AAA represents the major category of the
tree: 00100000 was a top-level category, 00100100 was a second-level
category under that, and 00100101 was a third-level category.
You can see that the system is limited to 7 top-level categories,
7 x 7 mid-level categories, and 7 x 7 x 3 third-level categories,
for a grand total of 203 if the tree was filled evenly.
In the second incarnation I realised that keeping the hierarchy
information in the topic code byte itself was inefficient and so
I made that a simple integer (extending the range of the system
to 255 total categories) and made some other arrangement to
store the category structure.

Treeboard, or BB as it was called on the system, also had quite an
advanced user input routine. One could use line commands (pressing
enter after each line) or one could press the key while the menu
was being output, and cancel the menu and jump straight to the
requested function. One could also string commands together
in line-input mode, by separating them with semicolons.

<dl>
 <dt>bb</dt>
 <dd>This directory contains the treeboard source code and HELP file.</dd>
 <dt>bb-a86</dt>
 <dd>This is an 8086 port of the treeboard which I wrote for the
 NSW Disadvantaged Schools Project BBS. It was a straight port,
 in other words I read the original code and rewrote that in 8086
 line by line, and I added some glue functions to tie it to
 the operating system (which was MP/M-86). The program worked
 fine.</dd>
 <dt>bbarch</dt>
 <dd>This program archives the oldest messages on the tree. Due to
 the Zeta BBS having only floppy disks the message base was limited
 to some maximum size. I think architecturally it was limited to
 512 Kbytes, and so it was necessary to regularly free up some
 space. I think maybe I implemented a circular buffer after a while
 so that new messages would simply wipe out the oldest ones.</dd>
 <dt>bbsquash</dt>
 <dd>This program "squashes" treeboard messages. Obviously this
 came before the circular buffer mentioned above.</dd>
 <dt>msgcomp</dt>
 <dd>This program "compresses message system in-place". Not sure
 if it relates to the mail or bb system or both.</dd>
 <dt>msgconv</dt>
 <dd>This program converts message files from the old to the
 new format. This might represent the transition point to the
 circular buffer.</dd>
</dl>

## Zeta BBS - Utilities

This directory contains commands which end-users were expected to use.
As a budding Unix-phile I was keen on seeing things happen through
the command line (or the shell I started to write) and so I resisted
providing a menu-driven system for a long, long time. Even when I
put my SunOS box online, users were mostly in the bash shell.

<dl>
 <dt>ask</dt>
 <dd>Ask a yes/no question.</dd>
 <dt>bye</dt>
 <dd>Request logout from the system.</dd>
 <dt>cat</dt>
 <dd>Concatenate files, like Unix.</dd>
 <dt>chat</dt>
 <dd>Every BBS needs one ... a little program to chat to the Sysop
 (who naturally spends much time hovering around his BBS to just
 make sure that it is still running and keep an eye on what's going
 on in case some Skr!pt |&lt;idd13 is trying to 0wn his box).</dd>
 <dt>cmds</dt>
 <dd>Lists all .CMD files on drive zero.</dd>
 <dt>comment</dt>
 <dd>Leave a user comment for the Sysop to read. Strangely enough
 most Sysops craved attention from their users and so there was
 the interactive chat, special "message to sysop" options and
 of course the obligatory "leave a comment" at the end of the
 call.</dd>
 <dt>cp</dt>
 <dd>Copy files (I think usage of this command was limited to
 the Sysop).</dd>
 <dt>cwiz</dt>
 <dd>It prints a random wise saying. This program was written
 by Ross McKay, and I don't think he will mind it appearing here.
 Ross is also
 the author of the "Portable GUI Development Kits FAQ" which is
 archived on www.faqs.org.</dd>
 <dt>date</dt>
 <dd>Print current date and time.</dd>
 <dt>dir</dt>
 <dd>Print a diskette directory.</dd>
 <dt>dirall</dt>
 <dd>Print directory of all disk drives.</dd>
 <dt>direct</dt>
 <dd>My "DIRECT" utility, which appears and is well documented
 in another of my TRS-80 packages (maybe trs80-file-utils).</dd>
 <dt>echo</dt>
 <dd>Echoes its command line input.</dd>
 <dt>edit</dt>
 <dd>A simple editor. I think even end-users were allowed to use
 this. This looks like it is adapted from the TRS-80 Lisp
 system.</dd>
 <dt>free</dt>
 <dd>Find out how much free disk space there is.</dd>
 <dt>grep</dt>
 <dd>Search for a string of characters in a text file.</dd>
 <dt>help</dt>
 <dd>Displays documentation for commands and other topics, and
 provides a simple pagination and manner of navigation.</dd>
 <dt>id</dt>
 <dd>Shows the current user number and user name.</dd>
 <dt>kill</dt>
 <dd>Deletes a file. End-users were only allowed to modify
 one file which was called TEMPFILE. So the kill command
 would permit end-users to delete TEMPFILE.</dd>
 <dt>list</dt>
 <dd>Output the contents of a text file.</dd>
 <dt>logout</dt>
 <dd>Logout from the system.</dd>
 <dt>lprint</dt>
 <dd>Print timestamp and a message on the printer. This program
 was used very early on - last modified 1986-07-06 - and was
 probably replaced by LOG/ZMS which accumulated all log output
 and sometime later a utility would print a page of that file
 at a time. I probably got sick of hearing my line printer
 chirp at random intervals during every night, so I arranged
 to save paper and get it all done quickly by buffering the
 log output and flushing the buffer when I felt like it.</dd>
 <dt>ls</dt>
 <dd>Output a directory listing.</dd>
 <dt>me</dt>
 <dd>Message entry for the Treeboard.</dd>
 <dt>menu</dt>
 <dd>Provide a menu for people who found all those commands were
 just intimidating.</dd>
 <dt>more</dt>
 <dd>Output the contents of a text file, with pagination.</dd>
 <dt>note</dt>
 <dd>Send and receive short notes.</dd>
 <dt>pack</dt>
 <dd>The Unix "pack" command, reimplemented in assembler.</dd>
 <dt>password</dt>
 <dd>Let a user change their password.</dd>
 <dt>readnews-in-c</dt>
 <dd>A Small C program to act as a newsreader. It is probably
 unfinished.</dd>
 <dt>rm</dt>
 <dd>Remove files, analogous to "kill".</dd>
 <dt>scrub</dt>
 <dd>Clear bit 7 from file contents and convert text files from
 CP/M (now DOS) to TRS-80 format.</dd>
 <dt>shell</dt>
 <dd>A user shell which is re-entrant and can execute simple
 batch files.</dd>
 <dt>sort</dt>
 <dd>A file sorter. This one looks like it uses the bubble
 sort algorithm too (sigh).</dd>
 <dt>stty</dt>
 <dd>A quite impressive version of stty. Many options, but
 some probably did nothing. The user can change their terminal
 width and length, at least!</dd>
 <dt>survey</dt>
 <dd>Ask some questions of the user (there's that Sysop craving
 interaction again).</dd>
 <dt>userlist</dt>
 <dd>List members and non-members.</dd>
 <dt>wisdom</dt>
 <dd>Analogous to "cwiz", again a program by Ross McKay.</dd>
</dl>
