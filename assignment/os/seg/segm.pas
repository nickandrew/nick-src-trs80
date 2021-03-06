program segmentation(input,output);
const
   memorysize = 1000;
   numevents = 100;
   maxholes = 50;
type
   memory = 0 .. memorysize;
   holetype = record
                 size : memory;
                 where : memory
              end;
   holetime = record
                 hole : holetype;
                 time : real
              end;

var
   queue : array [1..maxholes] of holetime;
   qptr : integer;
   free : array [1..maxholes] of holetype;
   fno,cptr : integer;

   ghole,rhole,ihole : holetime;
   i : integer;
   htime, endtime : real;
   room : boolean;
   beenfilled : boolean;

procedure pause;
var c:char;
begin read(c) end;


procedure insevent(ihole:holetime);
var
   qold,slot,qmove:memory;
begin
   qold :=qptr;
   qptr :=qptr+1;
   slot:=1;
   if qold > 0
   then begin
        while (slot<=qold) and (ihole.time<queue[slot].time)
           do slot:=slot+1;
        if slot <= qold then
           for qmove:= qold downto slot do
              queue[qmove+1] := queue[qmove]
        end;
   queue[slot]:=ihole
end;

procedure remevent(var rhole  : holetime);
begin
   if qptr > 0 then
      begin
      rhole:=queue[qptr];
      qptr:=qptr-1
      end
   else begin
        writeln('Error. Event Queue overemptied');
        rhole.time:=0.0
        end
end;

procedure genrat(var size:memory;var htime:real);
const low=4.5399E-5;
     ln10=2.3026E0;
var y:real;
begin
   y:=rnd(maxint)/maxint;
   if y<=low then y:=low;
   size:=trunc(-100.0 * ln(y)/ln10);
   size:=size+1;
   y:=rnd(maxint)/maxint;
   if y<=low then y:=low;
   htime:= -0.5*ln(y)/ln10;
   writeln('Size ',size,' Time ',htime:8:4);
end;

procedure getspace(var ghole:holetime;var room:boolean;
                   beenfilled:boolean);
var i,holeno:integer;
begin
   room:=false;
   if fno<>0 then
      begin
      i:=1;
      while (i<=fno) and not room do
         begin
         if (free[i].size >=ghole.hole.size) then
            begin
            room:=true;
            holeno:=i
            end;
         i:=i+1
         end;
      if room then
         begin
         free[holeno].size:=free[holeno].size-ghole.hole.size;
         ghole.hole.where :=free[holeno].where;
         free[holeno].where:=free[holeno].where
                             + ghole.hole.size;
         if free[holeno].size = 0 then
            begin
            for i:=holeno to fno do
               free[i]:=free[i+1];
            fno:=fno-1
            end
         end
      end;
if room then
   begin
   write('Got:  Time: ',ghole.time:8:4);
   write(' Locn ',ghole.hole.where:3);
   write(' Size ',ghole.hole.size:3);
   writeln(' No. free blocks',fno);
   for i:=1 to fno do
      write('[',free[i].where,',',free[i].size,'] ');
   writeln;
   end;
pause;
end;

procedure releasespace(rhole:holetime);
var i,j,movedown:integer;
begin
writeln('Releasing ',rhole.hole.where,',',rhole.hole.size);
   if fno=0 then
      begin
      fno:=1;
      free[1].size:=rhole.hole.size;
      free[1].where:=rhole.hole.where
      end
   else
      begin
      i:=1;
      while (i<=fno) and (free[i].where<rhole.hole.where) do
         i:=i+1;
      for j:=fno downto i do
         free[j+1]:=free[j];
      fno:=fno+1;
      if (i>1) then
         if free[i-1].where+free[i-1].size
                = rhole.hole.where then
            begin
            rhole.hole.where:=free[i-1].where;
            rhole.hole.size:=rhole.hole.size+free[i-1].size;
            for j:=i to fno-1 do
               free[j]:=free[j+1];
            i:=i-1;
            fno:=fno-1
            end;
      if (i<fno) then
         if rhole.hole.where+rhole.hole.size
                = free[i+1].where then
            begin
            rhole.hole.size:=rhole.hole.size+free[i+1].size;
            for j:=i+1 to fno-1 do
               free[j]:=free[j+1];
            fno:=fno-1
            end;
      free[i]:=rhole.hole
      end;
write('Rels: Time: ',rhole.time:8:4);
write(' Locn ',rhole.hole.where:3);
writeln(' Size ',rhole.hole.size:3,' No. Free blocks ',fno);
for i:=1 to fno do
   write('[',free[i].where,',',free[i].size,'] ');
writeln;
pause;
end;

procedure acstat;
begin end;

procedure summary;
begin end;



begin (* main prog *)
   cptr:=1;
   fno:=1;
   free[1].where:=0;
   free[1].size := memorysize;
   qptr:=0;

   room:=true;
   beenfilled:=false;
   ghole.time:=0.0;
   while room do
      begin
      genrat(ghole.hole.size,htime);
      getspace(ghole,room,beenfilled);
      ihole.hole:=ghole.hole;
      ihole.time:=htime;
      if room then insevent(ihole)
      end;
   ghole.time:=0.0;
   endtime:=0.0;
   beenfilled:=true;
   acstat;
   for i:=1 to numevents do
      begin
      genrat(ghole.hole.size,htime);
      getspace(ghole,room,beenfilled);
      while not room do
         begin
         remevent(rhole);
         ghole.time := rhole.time;
         endtime := ghole.time;
         acstat;
         releasespace(rhole);
         getspace(ghole,room,beenfilled)
         end;
      ihole.hole :=ghole.hole;
      ihole.time :=ghole.time + htime;
      insevent(ihole)
      end;
   writeln('Stats gathering ends at ',endtime:8:4,' secs.');
   summary
end.
