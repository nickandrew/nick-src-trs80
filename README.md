# Nick Andrew's TRS-80 source code

I've written a lot of code since 1980, in a lot of different
languages. Much of it was written very specifically to solve some
problem I was facing at the time. Since the year 2000 I've been
deliberately releasing some code I write into the Public Domain or
open-sourcing it under the GNU Public License (GPL). I hope that this
will help some people and maybe somebody will improve it and release
their improvements as I have released the original work.

This is my collection of my recovered TRS-80 programs from around 1981
to 1990. In late 2000 I spent a lot of time extracting the contents
of all my TRS-80 diskettes (approx. 200 of them) and I wrote several
programs to convert, extract and compare these files. In mid-2002
I started going through the results disk by disk in order to piece
together different versions of my source code and arrange them in
directories. Now all this code is online for your enjoyment.

## Directories

* [Uni Assignments](assignment/) Programs I wrote for Uni
* [Modern bin directory](bin/) The Build system and other tools, mostly in python
* [CMD file utilities](cmd-utils/)
* [Communications](comm/)

## How to use this code

Compile/assemble the source code using the Build System
(documented below) and run the programs on a TRS-80 emulator. I use
[xtrs](https://www.tim-mann.org/xtrs) which is packaged for Ubuntu
and other Linux distros.

You'll need [zmac](http://48k.ca/zmac.html) to cross-assemble and
[sdcc](https://sdcc.sourceforge.net/) to cross-compile.

## Highlights

### The Build System

I want to make sure all the code works - which means, as it's largely
assembler, that at least it compiles/assembles without errors. Testing
the resulting binaries is still on the TODO list; so far I've only tested
programs which I'm actively working on.

In the spirit of CI/CD, and inspired by
[Bazel](https://en.wikipedia.org/wiki/Bazel_(software)), all the TRS-80
code is in a single repository and a single command will recursively
build all artefacts, controlled by a BUILD.yaml file in each directory.

Back in the 1980s my code was a mess. I only had floppy disks, so the
source code for different programs was on different diskettes, and any
common files (INCLUDE files or .h files etc) were on multiple diskettes,
often with minor changes. There was no Source Code Control System at
the time.

I'm applying modern software engineering principles now by de-duplicating
common code, using the same name for the same function across different
programs, and building libraries for reuse.

On my development VM the entire codebase is rebuit every hour and failures
are counted and instrumented. This allowed me to fix the many errors
from the original 1980s code over time, and ensure that any introduced
errors are noticed and fixed.

For more details, see [The Build System](BUILD.md)

### Assembler grammar and parser

Back in the 1980s I assembled ASM code initially with `EDTASM` and upgraded
after some time to `EDAS` (which I modified for Newdos/80 and renamed
to `NEDAS`). I also tried some Misosys program.

When I first worked on automatic assembling the entire codebase I tried to
do it by importing each assembler file to the emulator and assembling it
on the emulator, and copying the /CMD file back to Linux. This approach
ultimately failed due to bugs and memory limitations in the assembler.

So I moved to cross-assembling and settled on `zmac` as its assembler
language was close enough to `EDAS` to make only minimal changes.

But the total amount of assembly code is quite large and I needed some
way to do cross referencing and automated code changes. So I built a
language parser using the Lark system in python, and implemented:

* basic parser (bin/parse-asm.py)
* cross references (bin/xref-asm.py)
* symbol renamer (bin/rename-symbol.py)
* Remove multiple symbol definitions (bin/remove-multi-defs.py)

### Modern libraries

#### basicio

Implementation of argument parsing from the DOS command line into
the (argc, argv) format needed by a C program.

getchar() and putchar() which C programs will need.

Model 1/3 compatible time functions.

A function to help identify the (emulated) hardware. It's intended
to allow cross-model compiled and assembled code, but there are so
many differences between the models that further work is required.

#### fd1771

Functions to control the fd1771/fd1791 (emulated) disk interface
from C programs

#### newdos80

Most of the Newdos/80 documented functions can be called from C
programs for efficient use.

#### stdio

A decent subset of STDIO is implemented for C program use (includes
fopen, STDOUT/STDERR/STDIN, printf etc).
