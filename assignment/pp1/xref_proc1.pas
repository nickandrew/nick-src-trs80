{xref_proc1.p - the saga continues}

function lowercase(ch:char):char;
{function to convert a single character input to lower case
variables used:
    ch        : char (character input)                                  }
begin {function lowercase}
if ch in ['A'..'Z']
   then lowercase:=chr(ord(ch)-ord('A')+ord('a'))
   else lowercase:=ch
end; {function lowercase}

procedure clrstr(var name:string);
{set a string type variable to all spaces
variables used:
name          : variable string (name to clear)
i             : local    integer (index)               }
var i:integer;
begin {clrstr}
for i:=1 to idmaxlngth do
   name[i]:=' '
end; {clrstr}

function cmpstr(string1,string2:string):cmptype;
{compare two strings for equality or size
variables used:
string1,string2   : value strings (two strings to compare)
same              : local boolean (flag for equal strings)
j                 : local integer (index)
(function output is one of (smaller,equal,larger))              }
var same:boolean;
       j:integer;
begin {function cmpstr}
j:=0;
same:=true;
{while equal so far}
while (j<idmaxlngth) and same do
   begin
      j:=j+1;
      same:=string1[j]=string2[j]
      {if .ne. then same=false}
   end;
case same of
   true: cmpstr:=equal;
  false: begin
            {retest the last character tested to find out which is bigger}
	    if ord(string1[j])>ord(string2[j])
	       then cmpstr:=larger
	       else cmpstr:=smaller
         end
end {case same}
end; {function cmpstr}


procedure clear(var ident:idtype);
{clear the entry for a particular identifier
variables used:
ident         : variable (single identifier record)
i             : local integer (index)                  }
var i:integer;
begin {clear}
{set name portion to all spaces}
clrstr(ident.name);          {clear name string}
ident.numref:=null;          {set no references}
for i:=1 to maxref do
   ident.lines[i]:=null      {set each line #=0}
end; {clear}
