program segmentation(input,output,lp);
(* LP=line printer *)


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
   fno : integer;

   ghole,rhole,ihole : holetime;
   i : integer;
   htime, endtime : real;
   room : boolean;
   beenfilled : boolean;
   meannum,meansiz,oldtime : real;



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
        writeln(lp,'Error. Event Queue overemptied');
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
   writeln(lp,'Size ',size,' Time ',htime:8:4);
end;

(* First Fit algorithm *)
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
   write(lp,'Got:  Time: ',ghole.time:8:4);
   write(lp,' Locn ',ghole.hole.where:3);
   write(lp,' Size ',ghole.hole.size:3);
   writeln(lp,' No. free blocks',fno);
   for i:=1 to fno do
      write(lp,'[',free[i].where,',',free[i].size,'] ');
   writeln(lp);
   end;
end;

procedure releasespace(rhole:holetime);
var i,j,movedown:integer;
begin
write(lp,'Rels: Time: ',rhole.time:8:4);
write(lp,' Size:',rhole.hole.size);

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
writeln(lp,' No. Free blocks',fno);
for i:=1 to fno do
   write(lp,'[',free[i].where,',',free[i].size,'] ');
writeln(lp);
end;

procedure acstat;
var elapsed:real;
    avsize :real;
    i : integer;
begin
   elapsed:=ghole.time-oldtime;
   meannum:=
      meannum + (fno - meannum)*elapsed/ghole.time;
   avsize:=0.0;
   for i:=1 to fno do
      avsize:=avsize+free[i].size;
   avsize:=avsize/fno;
   meansiz:=
      meansiz + (avsize - meansiz)*elapsed/ghole.time;
   oldtime:=ghole.time
end;


procedure summary;
begin
   writeln('Mean number of free blocks =',meannum);
   writeln('Mean size of blocks        =',meansiz)
end;

begin (* main prog *)
(* initialise means, SDs etc... *)
   meannum:=0.0;
   meansiz:=0.0;
   oldtime:=0.0;

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
