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

Files used (Reserved word files).
  This program utilises two reserved word files, namely
             resvd1            and            resvd2.
  Resvd1 contains a short list of the most common reserved words used
in pascal (begin,end,var,integer etc...) and is searched each time
a new identifier needs to be added to the identifier array.
  Resvd2 contains a list of all the remaining reserved words and is used
to delete the more obscure reserved words after the list has been sorted.
 This program requires a sorted resvd2 file to speed up processing.
                                                                            }



{program xref2.p
Variables Used:
	   Maxident      : constant (maximum # of identifiers allowed)
	   Idmaxlngth    : constant (maximum length of an identifier )
	   Maxref        : constant (maximum reference per identifier)
	   Null          : 0        (to indicate no data)
	   Inputfile     : textfile (file of pascal program input)
	   Xrefout       : textfile (xref output file)
	   Numident      : positive integer (number of identifiers)
	   Ident         : array of identifiers & references
	   Idindex       : array for sorted ident. numbers
	   Resvd1        : short reserved word file
	   Resvd2        : long  reserved word file
                                                                           }


const     maxident = 100;      {Maximum # of identifiers}
          idmaxlngth = 12;     {Maximum length of each identifier}
          maxref = 40;         {Maximum references for each}
          null = 0;
type      string = array[1..idmaxlngth] of char;
          pointer = array[1..maxident] of 0..maxident;
          idtype = record
                     name : string;
                    lines : array[1..maxref] of 0..maxint;
                   numref : 0..maxref
                   end;
          idarray = array[1..maxident] of idtype;
          strfile = text;
	  cmptype = (smaller,equal,larger);
	  posint = 0..maxint;
var       inputfile,xrefout : text;
          numident          : posint;
	  ident             : idarray;
	  idindex           : pointer;
	resvd1,resvd2 : strfile;
#include "xref_proc1.p"
#include "xref_proc2.p"
begin {xref}
writeln('Now initialising...');
InitialiseData;
writeln('Now adding lines to text...');
{Copy text to output file with line numbers added}
Addlines(inputfile,xrefout);
writeln('Now making list of identifiers...');
{Make a list of all identifiers excluding words in resvd1}
Makelist(inputfile,ident,numident,idindex,resvd1);
writeln('Now sorting list...');
{Sort list by index - method used: springsort}
Sort(ident,numident,idindex);
writeln('Now deleting bad identifiers...');
{delete any identifiers found in resvd2}
Delete(resvd2,ident,numident,idindex);
writeln('Now listing identifiers to output file...');
{List identifiers and references to output file}
List(ident,numident,idindex,xrefout);
writeln('Now finalising operation...');
{Finish up}
Finalise;
writeln('Finished...');
end. {xref}
