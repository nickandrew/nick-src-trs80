Documentation for OBJCAT    V1.0 02-Aug-86
-------OBJCAT/ASM-------    Nick Andrew

    OBJCAT is a utility for Alcor C, model I or III version.
It concatenates 2 or more object files, producing one output
object file. This is useful when your program calls routines
which you compiled previously, and which are in a different
object file.

    I suffix all "first stage" object files with "/O", and
all "final" object files with "/obj". Thus, the usage of
OBJCAT is:

     OBJCAT file1/o file2/o file3/o .... filen/o fileout/obj

   And the file "fileout/obj" can be run with "runc" because
it is comprised of the contents of file1, file2, file3, etc...

   I think the file containing "main()" must be first in the
command line for OBJCAT.

   OBJCAT is distributed in source form only, and may be
assembled by Nedas or a similar assembler. The program will
work on either model I or III Trs-80.

