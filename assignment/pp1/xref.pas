{PP1 Assignment 1 part C: Pascal Cross Referencer (Concordance)
             Nick Andrew (S8425464)     (N.P.Andrew)
	     30/04/84 - Appropriate Comments added.              }


program xref(input,output,inputfile,xrefout,resvd1,resvd2);

{X-Reference program: Description.
   This program produces a cross-reference listing of all identifiers
used inside a program written in standard Pascal. It disregards reserved
words (begin,end,not etc...) in two stages: at the time of making the
identifier list, and after the list has been sorted. Deleting most
common reserved words in the first stage saves memory space needed for
identifiers and also saves time in the final stage.

Program Input: Input is in the form f a standard pascal source program
including comments and strings inside 's. The X-ref will not recognise
the use of alt. comment/index markers. Program input is free
format.

Program Output: This program outputs to two separate devices: firstly
the screen, for any error messages and other status information.
  Secondly the program writes to a file called 'xrefout' the cross
reference text.
  Cross Reference text comprises:
    1) A copy of the input file, with line numbers inserted at the start
of each line. Empty lines also receive a line number.
    2) A list of all variables used (with lengths of up to 23 chars) in
the leftmost position. To the right of this is a list of all lines in
which each identifier is utilised - in any way (ie. write,assign,declare,
test etc...).
       If there are more than 'numident' (see program decl.) identifiers,
then the program will list the first 'numident' of those, and discard
the rest. Similarly, if any identifier is referenced more than 'maxref'
times, then only the first 'maxref' times will be stored and subsequently
printed. Error messages are output to the vdu for both occurrences.
