program ptass3(input,output);
type stringptr = @stringtype;
     stringtype = record
                     ch : char;
                   next : stringptr
                  end;
     treeptr  = @treetype;
     treetype = record
                   parent : treeptr;
                   lchild : treeptr;
                   rchild : treeptr;
                   name   : stringptr
                end;
     equality = (less,equal,greater);

var
       root : treeptr;
   tree     : treeptr;
     string : stringptr;
     switch : boolean;
      count : integer;

procedure nodeinit(var node:treeptr; parentnode:treeptr );
begin
   new(node);
   node@.parent:=parentnode;
   node@.lchild:=nil;
   node@.rchild:=nil;
   node@.name:=nil
end;

procedure crleft(root:treeptr);
var newleft:treeptr;
begin
   nodeinit(newleft,root);
   root@.lchild:=newleft
end;

procedure crright(root:treeptr);
var newright:treeptr;
begin
   nodeinit(newright,root);
   root@.rchild:=newright
end;

procedure downleft(var root:treeptr);
begin
   if (root@.lchild <> nil)
      then root:=root@.lchild
end;

procedure downright(var root:treeptr);
begin
   if (root@.rchild <> nil)
      then root:=root@.rchild
end;

function ifleft(root:treeptr):boolean;
begin
   ifleft:= root@.lchild <> nil
end;

function ifright(root:treeptr):boolean;
begin
   ifright:= root@.rchild <> nil
end;

function compare(stringa,stringb:stringptr):equality;
var spa,spb:stringptr;
    temp   : equality;
begin
spa:=stringa;
spb:=stringb;
temp:=equal;
while (spa@.next <> nil) and (spb@.next <> nil)
       and (temp = equal) do
   begin
      if ord(spa@.ch)<ord(spb@.ch) then temp:=less;
      if ord(spa@.ch)>ord(spb@.ch) then temp:=greater;
      spa:=spa@.next;
      spb:=spb@.next;
   end;
if temp=equal then
   begin
   if (spa@.next <> nil) then temp:=greater;
   if (spb@.next <> nil) then temp:=less
   end;
compare:=temp
end;

procedure up(var root:treeptr);
begin
   if (root@.parent <> nil) then root:=root@.parent
end;

procedure searchtree(root:treeptr;var count:integer;
                     cmpstring:stringptr);
var node:treeptr;
  branch:equality;
  bottom:boolean;
begin
   node:=root;
   count:=count+1;
   branch:=compare(cmpstring,node@.name);
   if (branch <> equal) then
       begin
       bottom:=true;
       if branch = less then
          begin
             bottom:=not ifleft(node);
             if not bottom then downleft(node)
          end
       else
          begin
             bottom:=not ifright(node);
             if not bottom then downright(node)
          end;
       if not bottom then searchtree(node,count,cmpstring)
       end
end;

procedure addtree(root:treeptr;string:stringptr);
var node:treeptr;
  branch:equality;
begin
   node:=root;
   branch:=compare(string,root@.name);
   if (branch <> equal)
      then begin
           if (branch = less) then
              if ifleft(root)
                 then addtree(root@.lchild,string)
                 else begin
                      crleft(node);
                      downleft(node);
                      node@.name:=string
                      end;
           if (branch = greater) then
              if ifright(root)
                 then addtree(root@.rchild,string)
                 else begin
                      crright(node);
                      downright(node);
                      node@.name:=string
                      end
           end
end;

function readstring(var string:stringptr):boolean;
var letter:char;
    endstring:stringptr;
    nextchar:stringptr;
    currstr:stringptr;
begin
new(string);
currstr:=string;
string@.next:=nil;
repeat
   read(letter)
until (letter <> ' ');
readstring:=false;
if (letter = '*') then
   readstring:=true
   else
      while (letter <> ' ') do
         begin
         currstr@.ch:=letter;
         new(endstring);
         endstring@.next:=nil;
         currstr@.next:=endstring;
         currstr:=endstring;
         read(letter)
         end;
end;

procedure writestring(string:stringptr);
var currstr:stringptr;
begin
   currstr:=string;
   while (currstr@.next <> nil) do
      begin
      write(currstr@.ch);
      currstr:=currstr@.next
      end;
   writeln
end;

procedure printree(root:treeptr);
begin
   if (root = nil) then writeln('Empty.')
   else begin
        write('Node: ');
        writestring(root@.name);
        write('Left: ');
        printree(root@.lchild);
        write('Right: ');
        printree(root@.rchild);
        end
end;

begin (* main program *)
nodeinit(root,nil);
switch:=readstring(string);
root@.name:=string;
printree(root);
switch:=readstring(string);
while not switch do
   begin
   addtree(root,string);
   printree(root);
   writeln;
   switch:=readstring(string);
   end;
switch:=readstring(string);
while not switch do
   begin
   count:=0;
   searchtree(root,count,string);
   switch:=readstring(string);
   writeln('Required ',count,'comparisons.')
   end;
switch:=readstring(string);
while not switch do
   begin
   addtree(root,string);
   printree(root);
   writeln;
   switch:=readstring(string);
   end;
switch:=readstring(string);
while not switch do
   begin
   count:=0;
   searchtree(root,count,string);
   switch:=readstring(string);
   writeln('Required ',count,'comparisons.')
   end;
end.
