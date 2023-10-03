# TRS-80 Languages

This directory contains a variety of programs related to
software development or computer languages.

<dl>
 <dt>alcor</dt>
 <dd>Stuff for the Alcor C Compiler. There's a patch here to make it
 work on the model 1, and a program to concatenate its object files
 together (presumably required to execute a separately-compiled
 program).
 </dd>
 <dt>asmclean</dt>
 <dd>A small C program which "cleans up" ASM source files by reformatting
 certain lines. It removes the colons from label definitions and adjusts
 all comments (which did not start at the start of the line) to start in
 a particular column so the comments all line up. Null lines are replaced
 by lines containing only a semicolon.</dd>
 <dt>asmup</dt>
 <dd>This small C program converts an assembler source file to all
 uppercase (excluding character or string literals and comments).
 </dd>
 <dt>ceval</dt>
 <dd>This is a program which evaluates a constant expression in the
 C language. It understands the four basic operations as well as
 right and left association and open and close parentheses. This
 program was obviously written for educational purposes, as it is
 full of debugging.</dd>
 <dt>cpack</dt>
 <dd>I wrote this cute little program in 1985 to compress a 'C' source
 file given knowledge of all the C reserved words. It also did
 Run-Length Encoding of spaces and tabs (only). I don't recall what
 typical compression ratios were achieved but somehow I doubt that
 it achieved the 50% of LZW.
 </dd>
 <dt>cpu-6502</dt>
 <dd>As a kid I once went for a job at a software house which wrote
 for the Apple II platform. Why? I was a TRS-80 guy. I dunno.
 Anyway to show that I could do 6502 assembly language I wrote a
 bunch of Z80 macros which emulated the 6502. I wrote an integer
 multiply function as a test and the macros worked. Of course it
 wasn't a proper 6502 emulator as there was no instruction decode,
 but it was a good way to learn the 6502 code. I didn't get the
 job but I'm not bitter about it.
 </dd>
 <dt>decode</dt>
 <dd>The comment on this program says "Decodes a /REL file". I
 think a /REL file is compiled FORTRAN and the strings in the
 source back me up on this. Consider this program like an
 <b>nm</b> for TRS-80 FORTRAN.</dd>
 <dt>delabel</dt>
 <dd>This program "removes extraneous labels from source code
 created using Newdos Disassem package". I guess that disassem
 wasn't all that smart, and assigned labels for things which
 did not need labels. I recall that sometime later I used a
 very cool program called DISNDATA which used flow-of-control
 analysis to identify which parts of a disassembled program
 were code and which were data, and represent the data parts
 as literals and the code parts as Z80 instructions. DISNDATA
 helped so much in the arduous task of opening up and studying
 and fixing all the TRS-80 software which I had.
 There's also a BASIC program of the same name which probably
 does the same thing.</dd>
 <dt>execute</dt>
 <dd>This is a small C interpreter for an invented structured
 language. The language cannot do much on its own but it was
 a cute idea to write little special-purpose languages. The
 interpreter is only 150 lines of code.</dd>
 <dt>flow</dt>
 <dd>Show how an assembler program flow by printing all labels,
 jumps and calls. It looks like almost a "grep" for control-flow
 altering statements in an assembler source file. I would have
 thought something which actually analysed the structure and
 reported in 2 dimensions or constructed a reference graph would
 have been more useful. I guess it solved some hard problem I
 faced at the time!
 </dd>
 <dt>fortran</dt>
 <dd>change.asm in this directory converts a /EDT type file created
 with probably the Radio Shack assembler, to the format required
 by the TRS-80 FORTRAN compiler. This is probably because the
 FORTRAN editor was a hunk of junk and so I would have started
 using the more convenient EDTASM as an editor.</dd>
 <dt>l2</dt>
 <dd>This was a University assignment for Languages and Processors
 (lecturer: John Colville). It is a compiler and/or interpreter
 for an invented
 language called L2. I'm sure it's written exactly the way the
 Dragon Book says a compiler should be written. It's actually
 quite a large program. Some L2 test programs are included; the
 language looks similar to Pascal (although obviously not repeating
 all of Pascal's design flaws).
 <p>
 I found my submitted assignment. It scored 18/20. Can you find
 any bugs?
 </p>
 </dd>
 <dt>lcopt</dt>
 <dd>This program implements a peephole optimiser for assembler
 source code created by the LC program (LDOS C Compiler). LC was
 like Small C, only worse - a lot worse. It was a memory hog and
 it ran very slowly and it had bugs. At least, I think it had
 bugs. I was much happier after porting Small C and improving
 the latter's type handling.
 <p>
 The optimiser looks for a certain common 3-line sequence:
 "PUSH HL; LD HL,n; POP DE" and replaces it with the more
 efficient "EX DE,HL; LD HL,n".
 </p>
 <p>
 A further optimisation look for a "LD HL,n; PUSH HL; LD HL,n"
 sequence (where the 'n' is the same) and eliminates the final
 line.
 </p>
 <p>
 The final optimisation looks for "EX DE,HL; LD HL,n; EX DE,HL"
 and replaces this with "LD DE,n".
 </p>
 </dd>
 <dt>listbas</dt>
 <dd>This program reads a disk file containing a tokenised BASIC
 program and expands the tokens into their original keywords.
 Interestingly enough, it contains token tables for both CP/M
 (which flavour?) and TRS-80, and the CP/M one is enabled.
 <p>
 Just as an aside, in the process of recovering all my TRS-80
 source code I wrote a BASIC untokenizer in perl. My perl script
 was undoubtedly easier and faster to write, and has the feature
 that it also selectively adds whitespace around the expanded
 tokens for the benefit of 21st century dudes like me who can
 barely understand BASIC programs now, and I wouldn't be at
 all happy if I had to strain to separate the language keywords
 from their operands. Almost nobody nowadays thinks that "PRINTX"
 is a good way to write "PRINT X" because it saves one space.
 </p>
 <p>
 One day I will add my perl untokenizer here, so you can see what
 a difference 15 years of computing technology makes. Not much
 difference to count of lines of code it seems, as both programs
 seem to be about 150 lines long (excluding the translation table).
 Of course the perl program spends a good half of its length at
 figuring out its selective addition of spaces around tokens.
 And the perl program has comments.
 </p>
 <p>
 This directory also contains an untokenizer in C, of similar
 length. This program is interesting because it actually
 manipulates the language a little, stripping any code after
 'CLEAR' for example.
 </p>
 </dd>
 <dt>nedas</dt>
 <dd>First there was EDAS, an Editor-Assembler for LDOS. I modified that to
 work under Newdos-80 and renamed it NEDAS.
 There's a NEDAS command reference in this directory.
 </dd>
 <dt>nedasref</dt>
 <dd>
 It's a cross-reference program written
 in C and attributed to Gustav Francois (a pseudonym I used sometimes
 in 1986) called nedasref.
 </dd>
 <dt>noffs</dt>
 <dd>This simple program looks for multiple instances of "RST 38H" in
 a disassembler output and changes it to "DC nnH,0FFH". "RST 38H" is
 opcode 0xFF.</dd>
 <dt>nonops</dt>
 <dd>This simple program does the same thing as <b>noffs</b> above,
 except for "NOP" instructions (which are opcode 0x00).</dd>
 <dt>notabs</dt>
 <dd>This program changes tabs in source files to runs of spaces.
 It knows that a tab represents a variable number of columns.
 </dd>
 <dt>pasconv</dt>
 <dd>This assembler program converts Pascal-80 source files to
 plain ASCII.
 <p>
 Like with the tokenized BASIC,
 I had to write a Pascal-80 converter in perl for extracting my
 code. The perl Pascal-80 converter is 49 lines of spaced and
 commented code compared to about 116 lines of mostly uncommented
 assembler. Perl rocks :-) although after finding the assembler
 version I noticed that it was more functional than the perl one
 (the assembler version stripped trailing spaces from the output).
 Of course it was a few moments work to change the perl one to do
 that also (that change is included in the 49 lines of code).
 </p>
 </dd>
 <dt>pp</dt>
 <dd>This is a simple C preprocessor which I wrote. I think it's
 all my code. I think I had a problem with the integrated
 preprocessor in the Small C compiler, namely that it was
 too big, so I cut out the preprocessor to save space and
 wrote my own for the exercise. Or maybe I did no such thing,
 it's so hard to tell 17 years later. Anyway I think now that
 keeping the preprocessor in the code was the right thing to
 do for a small machine, because multi-pass multi-program
 compiling would have made things too slow.
 </dd>
 <dt>ret86</dt>
 <dd>I wrote an 8086 implementation of my Zeta-BBS message
 system (Treeboard) for the NSW Disadvantaged Schools Program.
 The code was to run on an MP/M-86 microcomputer. As far as
 I know the program worked fine. I didn't really rewrite it
 from scratch, I simply hand-translated it from Z80 assembler
 to 8086 assembler and I wrote some interface functions to
 handle the specific differences between TRS-80 and MP/M-86
 systems (like file or keyboard I/O).
 <p>
 Anyway it looks like I made
 a colossal blunder when rewriting the code. I was using
 "ret nz" in places, which is perhaps not a valid instruction
 for an 8086. In 2002 I would not have thought offhand that
 the 8086 could be less powerful than the Z80 in this
 respect, and a quick web search leaves me none the wiser.
 Anyway this program takes an 8086 assembler source code
 file and changes all instances of "retnz" to a conditional
 jump around an unconditional return.
 </p>
 </dd>
 <dt>sptotab</dt>
 <dd>This program changes spaces to tabs in an assembler
 source file, and it doesn't appear to care about preserving
 the columns (in other words it will change any number of
 contiguous spaces to a single tab).</dd>
 <dt>strip</dt>
 <dd>This program removes the line numbers from source
 files. Obviously source files created with those cumbersome
 line editors which insisted on preserving the line numbers
 with the saved file.</dd>
 <dt>toupper</dt>
 <dd>This program looks like it changes a COBOL source file
 to all upper-case, excepting comments. I looked carefully for
 any COBOL programs I may have written to be preserved in my
 TRS-80 packages archive, but alas there were none, and I
 don't get to express in HTML my utter disgust for the COBOL
 language.
 <p>
 To be more precise, there was one, a calculator program,
 and I couldn't be certain that I wrote it, so I did not
 include it. The calculator program could perform the 4
 basic operations only, on only 2 operands, so it was not
 an "expression evaluator" unless the expression was no
 more complex than "2 + 3" or "4 * 5". I suspect this program
 was a sample program written by Ryan-McFarland Corporation
 who wrote RMCOBOL which was rebadged by Radio Shack as
 RSCOBOL. It strikes me as quite ironic that a calculator
 program should be used, as this is a task for which COBOL
 is quite unsuited.
 </p>
 </dd>
 <dt>trail</dt>
 <dd>This program removes a trailing TAB from source files
 created by disassem. It appears that all lines with
 opcodes but no operands have this trailing TAB.</dd>
 <dt>unline</dt>
 <dd>Unline "takes line numbers off long source files".
 I imagine it takes them off short source files too, but
 the line numbers only became a problem with long source
 files. How long? Maybe the system did not accept line
 numbers larger than 65535, and it would be necessary to
 strip them before loading them into an editor.</dd>
</dl>
