# The Build System

The Build System recursively compiles/assembles the entire repository,
or individual directories, as required.

## Running the builder

`bin/build2.py --build_dir $TEMPDIR $DIRECTORY`

For example:

```
rm -rf tmp/output
mkdir -p tmp/output
bin/build2.py --build_dir tmp/output library
```

## BUILD.yaml files

A BUILD.yaml file lists which artefacts will be built from the sources
in that directory, and for each artefact, what are all the dependencies
such as include files or libraries. Take an example from
[disk-utils/diskette-inspector](disk-utils/diskette-inspector/BUILD.yaml):

```
inspector.cmd:
  link: inspector
  depends:
  - inspector.rel
  - library/basicio/basicio.lib
  - library/fd1771/fd1771.lib
  - library/newdos80/newdos80.lib
inspector.rel:
  sdcc: inspector.c
  depends:
  - inspector.c
```

There are 2 artefacts: `inspector.cmd` and `inspector.rel`. This is actually
a modern C program which compiles to a working TRS-80 /CMD file!

The builder (bin/build2.py) resolves dependencies recursively. So it will
build `inspector.rel` first, by compiling `inspector.c` with sdcc. It will
build all 3 libraries (unless they were already built in that run). When
all 4 dependencies have been satisfied, it will link them together to
create `inspector.cmd`.

To use `inspector.cmd` on xtrs, issue the command in the emulator:

```
import -l inspector.cmd inspect/cmd:0
```

Let's look at 2 more examples. The first is assembling some code
from [utilities/cmd/regions](utilities/cmd/regions/BUILD.yaml):

```
regions.cmd:
  assemble: regions.asm
  depends:
  - regions.asm
  - include/include/doscalls.asm
```

This is very straightforward. `regions.asm` is cross-assembled using zmac
and has `include/include/doscalls.asm` as a dependency. The source code
has:

```
*GET    DOSCALLS
```

and the builder copies `regions.asm` and `doscalls.asm` into a temporary
directory before invoking the assembler. This guarantees that only listed
dependencies can go into a build, and therefore, that there aren't any
unlisted dependencies.

The second example is building a library, from
[library/basicio](library/basicio/BUILD.yaml)

```
basicio.lib:
  library: basicio.lib
  depends:
  - argparse.rel
  - hardware_id.rel
  - putchar.rel
  - getchar.rel
  - soft_time.rel
argparse.rel:
  sdcc: argparse.c
  depends:
  - argparse.c
hardware_id.rel:
  sdcc: hardware_id.c
  depends:
  - hardware_id.c
  - hardware_id.h
putchar.rel:
  sdcc: putchar.c
  depends:
  - putchar.c
getchar.rel:
  sdcc: getchar.c
  depends:
  - getchar.c
soft_time.rel:
  sdcc: soft_time.c
  depends:
  - soft_time.c
```

The primary artefact `basicio.lib` is created by archiving (`sdar`)
several `.rel` files which are each created by compiling the relevant
C source code.
