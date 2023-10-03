# TRS-80 Hardware modifications

I owned my System-80 since about 1981 and used it actively until
around 1992. During that time I modified it extensively because
the design was simple enough for a child to understand, and
I wanted the computer to be more powerful.

The modifications I made included the following. This is not
in chronological order:

* Add lower-case using an EPROM as a character generator.
 I got the character set out of one of the chip databooks and
 programmed the EPROM using a programmer owned by my friend
 Mark Simon.
* Upgrade memory from 16 Kbytes to 32K, then 48K.
 This was done by soldering ram chips on top of the existing
 socketed chips. Only pins 15 and 14 (I think) were not connected
 in parallel; they were used to arbitrate between the banks of RAM.
* Speed up the CPU from 1.77 MHz to 2 MHz and then 3.54 MHz.
 I never achieved 4 MHz, probably because my ROM chip was too slow.
* Replace ROM chip with an EPROM and made minor changes to the
 BASIC interpreter inside. I don't recall ever trying for 4 MHz
 after doing this, nor do I recall exactly what changes I made to
 the 12 Kbyte ROM. I remember putting my own name into the EPROM.
 I might have changed the BASIC error messages to mixed case too.
* Upgrade memory to 80 Kbytes. I did this by bank-switching
 two 32K chunks (so 32 + 32 + 16 = 80). That was useful for
 storing the DOS system files in the other bank.
* Add a simple interrupt counter. This was my first attempt at
 a real-time clock. When DOS did disk I/O it would disable interrupts
 for a long time and the CPU would lose clock interrupt ticks. So the CPU
 would read this counter every time it processed a clock interrupt
 and would count how many missed interrupts there were, and adjust
 the clock accordingly. In practice it worked pretty well, but of
 course the time was not kept across reboots.
* Add inverse video controlled by switch or I/O port. This would
 invert the whole screen contents. I thought it was cool for a while.
* Install the Deakin University RS-232 controller board in my
 Dick Smith System-80 Expansion Unit. This was wired up to the bus
 somehow, but by the end I had completely redesigned the circuit
 and I was plugging it into the 20-pin expansion connector inside
 the Expansion Unit.
* Replaced the keyboard connector with a DB25 plug/socket pair
 and made a 25-pin expansion cable so I could lie on my bed and
 type. This was a poor attempt at portability ... I was also far
 away from the screen so I couldn't see what I was typing, and
 the excessive cable length caused the keyboard signals to become
 corrupted. I abandoned the extension cable and kept the DB25.
 The System-80 used a semi-rigid wire-frame connector for the
 keyboard and to join the two main boards inside the computer.
 These connectors were notoriously unreliable and any change
 could only have been an improvement.
* I added a "hard reset" pushbutton. The standard reset button
 causes an interrupt which the ROM passes to RAM (and can thus
 be caught/ignored). My reset button forces the CPU to start
 executing again at location zero.
* I added an audio output jack at the back so the internal
 speaker could be plugged into a cassette recorder. I might
 also have added a switch to force use of the external cassette
 interface (all these details are getting murky ... I seem to
 recall that it was a problem sometimes that the user wanted to
 use the external cassette and the system chose the internal
 one).
* I added various keys to the keyboard ... CLEAR and TAB? I
 remember by striking I, O and SPACE simultaneously that completed
 the matrix so the system believed that CLEAR had been pressed.
 I also added hard brackets, curly braces and the backslash key.
 Or was it underline?
* I "improved" the System-80 power supply by changing the main
 transformer to a bigger one which produced a higher intermediate
 (AC) voltage. This was before the days of switchmode power supplies.
 The computer would crash sometimes on minor power disturbances in
 the house (heater use, fridge turning on, and the like) and the
 bigger transformer reduced that problem. Later I put in a much
 bigger Ferguson transformer which "solved" the power problems
 better ... at the cost of huge heat output, which melted the
 case under the transformer. I had to put the computer on a block
 of wood to stop the transformer melting its way right through
 the case.
* I added a simple 4-bit resistor network to output 16 different
 voltage levels and thus make a better sound than the 3-level square
 wave which the ordinary audio output could do.
* I added a joystick (ATARI switch type one) connected to the
 keyboard arrows and SPACE. This joystick was attached via a
 round pinned connector.
* The CPU memory interface used maybe 3 D-type flip-flops to
 accomplish a 3 clock-cycle delay when reading or writing memory.
 I had already started using faster RAM chips (250 nS then 150 nS)
 and so these long delays were no longer required and I removed
 one wait state from the memory timing.
* I changed my 80 Kbytes RAM to 256 Kbytes RAM using a very
 fast (13 ns?) cache ram chip on every memory lookup. It worked
 like this:
  * The chip was used to translate all memory accesses within the
  48 Kbyte RAM address space. It didn't touch ROM or video memory
  or memory-mapped peripheral areas (such as the disk controller).
  * The chip mapped pages in 1 Kbyte chunks, so the 6 address
  inputs on the chip were connected to address lines A10 through A16.
  The 8 data outputs from the chip were connected to 8 x 256 Kbit
  RAM chips, becoming A10 through A18.
  * The chip was port-addressable so I could program it by
  writing bytes to I/O port 0x10. To do this I actually used an
  "undocumented" feature of the Z80, where an "OUT (C), A"
  instruction would actually place the contents of the register
  B on the top 8 bits of the address bus (allowing in effect,
  a 16-bit port address space). My chip programming involved
  mapping from a logical address (on the address lines) to a
  physical RAM address (on the data lines).
  * On power-up the system was able to load the first sector from
  the disk without using more than 1 Kbyte of memory, so that part
  worked even when the address translation chip was unprogrammed.
  I wrote a new boot sector which did an initial mapping of the
  address space and then loaded a new boot sector from sector one
  of the disk (which was, by default, a copy of sector zero anyway).
  Thus I achieved compatibility with the original system.
  * The boot sector mapping was tricky. It would map a known
  physical page into a known virtual page, then copy all the code
  to that known page. If the unknown physical page which was used
  to load the boot sector was the same as the known physical page,
  the code would be unaffected because it would be moved to the
  same memory area. After the move, the new code segment was
  executed, which would map all the rest of the pages.

* I added a true real-time clock circuit using the MSM-5832RS
 clock chip and 2 AA NiCad batteries for power-off retention. This
 clock worked well, once the programming foibles of the chip were
 understood.

* I added circuitry to the video memory to add wait states to
 video reads and writes until a horizontal or vertical retrace
 period occurred. This had the effect of virtually eliminating
 noise on the screen during video I/O. The original circuitry
 would just write at any time, and so the more I/O was done,
 the more white or black streaks would run through the display.
 It's possible I also added code to allow the CPU to detect when
 the retrace was in effect and optionally delay its writes (as
 opposed to hard-wiring the delays). I don't have the hardware
 anymore to go check the circuit, so just guessing here.

* I replaced one or more 5 Volt regulators inside the CPU unit
 with more powerful versions (or maybe added heatsinks).

* I unsoldered quite a few chips from the main board and soldered
 sockets in their place. This was good for when I killed a chip
 (which happened occasionally) but the danger was in destroying the
 delicate pads on the PCB. I ended up with a few short wire jumpers
 to replace broken pads.

* I have pictures of most of these works, taken on 2001-04-13.
 I just have to find the time to retrieve the pics and make thumbnails
 and commentary.

This directory contains some code I wrote which was specific to my
modified hardware.


<dl>
 <dt>fast</dt>
 <dd>This would set the CPU to high speed or normal speed.</dd>
 <dt>memory</dt>
 <dd>This program would set one of the two 32K memory chunks, when
 my computer had 80 Kbytes RAM. The chunks were useful primarily for
 storing the DOS files in memory, so that DOS would not need to reload
 parts of itself from disk for such simple operations as opening a file.
 </dd>
 <dt>ram256k</dt>
 <dd>The two programs in this directory manipulate the paged memory
 system.</dd>
 <dt>realtime-clock</dt>
 <dd>These programs set and query the hardware realtime clock.</dd>
 <dt>restore</dt>
 <dd>This program caches DOS system files in memory (as many as
 needed) and hooks into DOS so that requests are filled by copying
 memory rather than reading the modules from disk. I seem to recall
 that the original idea was somebody else's program and my program
 developed on that, to load more modules, and of course to use my
 unique paged memory subsystem to enable all the modules to be
 cached at once.</dd>
</dl>
