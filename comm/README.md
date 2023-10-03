# Communications

This package contains programs which do some sort of RS-232 communications.

My System-80 used a custom-built RS-232 adapter which was not compatible
with the standard TRS-80 one. The RS-232 adapter came from Deakin
University and was specific to the System-80 (i.e. it plugged into the
System-80's unique 50-pin expansion bus using a standard 25x2 way plug).

The RS-232 adapter had only the one 50-pin connector, which meant that
it could not be used with a disk system (neither expansion box provided
a connector to daisy-chain other equipment). The RS-232 adapter was
designed for cassette users. When I got my disk system, I modified
the RS-232 adapter and soldered it inside the System-80 Expansion
Unit. I don't recall how many iterations the adapter went through,
but at the end I think I had it mostly plugging in via the 20-way
connector which the Expansion Unit provided for that purpose.

The RS-232 adapter was incompatible in another way too. It used a
different UART chip than the standard TRS-80 one, which needed to
be driven quite differently. My one was more powerful ... but this
is of little consequence when every comms-using piece of software
needed to be modified to work with my gear. Anyway, I didn't use
other peoples' comms software mostly.

<dl>
 <dt>dumprom</dt>
 <dd>There was an Australian-designed modem called the <b>NICE Modem</b>
 which was being sold by an acquaintance of mine, Geoff Arthur. The
 NICE Modem had a command to dump its ROM contents. This program
 obtains that data from the ROM and writes it to disk.</dd>
 <dt>exmodem</dt>
 <dd>This was an XMODEM type file transfer program. XMODEM was all the
 rage before ZMODEM came about. I really don't recall if I wrote this
 program from scratch or modified somebody else's. In any case, it
 was hacked many times over the years to add various extensions to
 the basic XMODEM protocol, such as 16-bit CRC checking, non-integral
 final block size, and various methods to transfer multiple files in
 a single session.</dd>
 <dt>getfiles</dt>
 <dd>Getfiles is another "single-use" program.
 Its job is to get a list of files from an OMEN type system
 (Ted Romer ran OMEN BBS in Sydney, he is still around but does
 not run BBSs anymore, he owns a company called Watermaid which
 manufactures electric pool chlorinators). I couldn't figure
 out from looking at the source code how it gets the file list,
 but it then downloads each file.</dd>
 <dt>remote</dt>
 <dd>This little program links the standard TRS-80 display and keyboard
 devices with the RS-232 adapter. So basically output from programs would
 go to both the screen and the modem, and keyboard input could also come
 from the modem.
 <p>
 I used this program to play "security games" with Mark McDougall.
 I would lock my system down in various ways, and he would dial
 up via modem and attempt to defeat my security measures. I don't
 recall just how the system was secured or what tools were made
 available to assist in the removal of those measures. Perhaps I
 gave him a debugger or the editor-assembler. I expect Mark did
 the same with his machine and I dialled into him to try to break
 through his security.
 </p>
 
 <p>
 This program was probably the very first piece of software which
 became Zeta Internet.
 </p>
 </dd>
 <dt>term</dt>
 <dd>Term was a pretty standard terminal program. It was able to use a
 variety of baud rates, bit sizes and stop bits (as my non-standard
 UART permitted), and had various compatibility modes and a
 character translation table. I used it to dial up BBSs but more
 importantly, to access NSWIT's Honeywell Level 66 computer via
 modem.
 <p>
 The Honeywell was a dreadful computer and its modem
 interface was no better than the rest of the system. It was 7 bits
 even parity if I recall, and half duplex, with no flow control,
 and it was necessary to wait a little after sending each carriage
 return, because the system had no input buffering, sending too
 quickly would cause data to be lost. If you think file transfer
 would be hard under those conditions, I seem to recall that it had
 automatic pagination which could not be turned off, and that just
 added to the difficulty. NSWIT's Honeywell had 5 modems, and some
 of them would not be working at various times. I remember there was
 one modem (or one terminal input) which would not accept the uppercase
 letters T through Z on an input line. If you were to type one of these
 letters the entire input line would be rejected. I reported this problem
 to the Computer Centre and they dismissed my report as out-of-hand as if
 I had been taking drugs.
 </p>

 <p>I remember one more amusing story about the NSWIT computing
 infrastructure which is worth telling here, even if this isn't
 quite the right place for it. Around 1985, NSWIT used X.25
 multiplexers to link its central Computer Centre (with its Honeywell)
 to terminal rooms around the campus. These X.25 multiplexers
 had a certain bug, which was if they saw a packet containing 4
 contiguous lowercase "n" characters, i.e. "nnnn" on either input
 OR output, the multiplexer would crash and all users of that
 multiplexer (up to 16 people) would lose their sessions. I
 discovered this problem while trying to read a manpage (or the
 Honeywell equivalent). I every time I would try to read the
 manpage the system would crash. After a while I realised the
 connection. I was able to write the manpage to a file then I
 went through it line by line with the editor, so I knew the
 line _before_ the crash line. Somehow I split up the dangerous
 line character by character to see the 4 "n"s which were the
 source of all the trouble. I reported that problem also, but
 I don't recall the problem being fixed before the equipment
 was replaced with something better.
 I actually related this story in brief in Risks Digest 14.46,
 online at
 <a href="http://catless.ncl.ac.uk/Risks/14.46.html">http://catless.ncl.ac.uk/Risks/14.46.html</a>
 on 3rd April 1993.
 </p>
 </dd>
</dl>
