program transport(input,output,result,z);

const
       machines = 5;               {number of machines}
       sessions = 5;               {sessions per machine}
       toint = 2;                  {timeout interval}
       errorprob = 0;              {packet hit probability %}
       stage1  = 100;              {new connections interval}
       stage2  = 120;              {end of run}

type
       address = 1..machines;      {a transport station}
       connid  = 1..sessions;      {a connection identifier}
       mtype = (connreq,connconf,discreq,discconf);
       states = (idle, opening, isopen, closing);
       owners = (us, them);

       message = record             {a single message}
                 mmtype: mtype;
                 remote: address;
                 local : address;
                 loccon: connid;    {local connection id}
                 remcon: connid;
                 end;

var
    {An input queue for each transport station, length 10}

    queue    : array[address,1..10] of message;
    queuepos : array[address] of 0..10;

    {A connection array for each station}

    connarr  : array[address,connid] of
               record
                 state    : states;     {idle,open etc..}
                 remadd   : address;    {remote station id}
                 remid    : connid;     {remote connection id}
                 timeouts : integer;    {# of setup timeouts}
                 setup    : integer;    {time of creation}
                 owner    : owners;     {who made it}
                 intended : integer;    {intended duration}
                 duration : integer     {time remaining}
               end;

    result,z : text;
    time     : integer;
    me       : address;
    r, s     : message;

{------------------------------------------------------------}
{ generate a random number in the range 1..top }

function xrand(top:integer) : integer;
begin
   xrand := trunc(rndr * top) + 1
end;

{------------------------------------------------------------}
{ send a packet to a destination }

procedure sendpkt(a : mtype; b,c : address; d,e : connid);
begin
   s.mmtype := a;
   s.remote := b;
   s.local  := c;
   s.loccon := d;
   s.remcon := e;

   if (xrand(10) > errorprob) then begin

      if (queuepos[b] < 10) then begin
         queuepos[b] := queuepos[b] + 1;
         queue[b,queuepos[b]] := s
      end else begin
         writeln('Queue for host',b:2,' too long')
      end

   end else begin
      writeln(z,' Packet from',c:2,' to',b:2,' ** ZAPPED **')
   end
end; { sendpkt }

{------------------------------------------------------------}
{ process connect request message }

procedure newconn;
var  i : integer;
     dupflag, okflag : boolean;
begin

   dupflag := false;
   okflag  := false;

   { determine if duplicate received }
   i := 0;
   repeat
      i := i + 1;
      if (connarr[me,i].remadd = r.local) and
      (connarr[me,i].state = isopen)      and
      (connarr[me,i].remcon = r.loccon)   then begin
         dupflag := true
      end
   until (i = sessions) or (dupflag);

   if not dupflag then begin

      { find an idle connection if possible }
      i := 0;
      repeat
         i := i + 1;
         if (connarr[me,i].state = idle) then
            okflag := true
      until (i = sessions) or (okflag)
   end;

   if (okflag) then begin
      { setup the connection }
      connarr[me,i].state    := isopen;
      connarr[me,i].remadd   := r.local;
      connarr[me,i].remid    := r.loccon;
      connarr[me,i].timeouts := 0;        {not needed}
      connarr[me,i].setup    := time;
      connarr[me,i].owner    := them;
      connarr[me,i].duration := 0         {not needed}
   end;

   if (dupflag or okflag) then begin

      { send a connect confirm }
      writeln(z,'Connconf (',i:1,') to',r.local:2,'/',
              r.loccon:1);
      sendpkt(connconf,r.local,me,i,r.loccon)
      { args are: mmtype,remote,local,loccon,remcon }

   end else begin
      { connection attempt failed, we don't have any free }
      writeln(z,'Discreq to',r.local:2,'/',r.loccon:1);
      sendpkt(discreq,r.local,me,1,r.loccon)
   end
end; { newconn }

{------------------------------------------------------------}
{ executed when a 'connect confirm' message arrives }

procedure verifyconn;
var  i : integer;
begin
   { set the referred-to connection 'open' }
   i := r.remcon;
   connarr[me,i].state := isopen;
   connarr[me,i].remid := r.loccon;    { we know this now }
   connarr[me,i].setup := time;
   connarr[me,i].intended := xrand(10);
   connarr[me,i].duration := connarr[me,i].intended
end; { verifyconn }

{------------------------------------------------------------}
{ executed when a 'disconnect confirm' message arrives }

procedure verifydisc;
var  i : integer;
begin
   { set the referred-to connection 'idle' from 'closing' }
   i := r.remcon;
   connarr[me,i].state := idle;

   { output the connection record }
   writeln(result,'closed',me:4,'/',i:1,
           r.local:6,'/',r.loccon:1,
           connarr[me,i].intended:8,
           (time-connarr[me,i].setup+1):9,
           time:8);

end; { verifydisc }

{------------------------------------------------------------}
{ executed when disconnect request is received }

procedure doconfirm;
var  i : integer;
begin

   i := r.remcon;

   { if connect request failed on a connection }
   if (connarr[me,i].state  = opening) and
      (connarr[me,i].remadd = r.local) then begin
         connarr[me,i].state := idle;
         { output failed connection record }
         writeln(result,'FAILED',me:4,'/',i:1,
                 r.local:6,'/ ',
                 '        ',0:9,
                 time:8);

   end else begin

      { set idle only if the connection is correct and open }
      if (connarr[me,i].state  = isopen) and
         (connarr[me,i].remadd = r.local) and
         (connarr[me,i].remid  = r.loccon) then
            connarr[me,i].state := idle;

      { reply with disconnect confirm }
      writeln(z,'Discconf (',i:1,') to',
              r.local:3,'/',r.loccon:1);
      sendpkt(discconf,r.local,me,i,r.loccon)
   end
end; { doconfirm }

{------------------------------------------------------------}
{ process arriving messages }

procedure newmessages;
var  i : integer;
begin

   for i:=1 to queuepos[me] do begin
      r := queue[me,i];

      case r.mmtype of
         connreq  : begin
                       writeln(z,'connreq from',
                               r.local:3,'/',r.loccon:1);
                       newconn;
                    end;

         connconf : begin
                       writeln(z,'connconf to ',me:3,'/',
                               r.remcon:1);
                       verifyconn;
                    end;

         discreq  : begin
                       writeln(z,'discreq for ',
                               me:3,'/',r.remcon:1);
                       doconfirm;
                    end;

         discconf : begin
                       writeln(z,'discconf for',
                               me:3,'/',r.remcon:1);
                       verifydisc;
                    end
      end;

   end;
   queuepos[me] := 0

end; {newmessages}

{------------------------------------------------------------}
{ retransmits timed-out connect request, disconnect request }

procedure dotimeouts;
var  i : integer;
     m : mtype;   { message type }
begin
   for i:=1 to sessions do begin

      if (connarr[me,i].state = opening) or
         (connarr[me,i].state = closing) then begin

         { increase timeout count }
         connarr[me,i].timeouts := connarr[me,i].timeouts+1;
         if (connarr[me,i].timeouts > 2) then begin

            { resend packet }
            write(z,'Resend ');
            if (connarr[me,i].state = opening) then begin
               m := connreq;
               write(z,'connreq')
            end else begin
               m := discreq;
               write(z,'discreq')
            end;
            writeln(z,' (',i:1,') to',connarr[me,i].remadd:3,
                    '/',connarr[me,i].remid:1);

            sendpkt(m,connarr[me,i].remadd,
                    me,i,connarr[me,i].remid);
            connarr[me,i].timeouts := 0
         end
      end
   end
end;

{------------------------------------------------------------}
{ sends disconnect request for finished connections }

procedure killconn;
var  i : integer;
begin
   for i:=1 to sessions do begin
      if (connarr[me,i].state = isopen) and
         (connarr[me,i].owner = us)     then begin
         if (connarr[me,i].duration = 0) then begin

            { send disconnect request }
            writeln(z,'Discreq (',i:1,') to',connarr[me,i]
              .remadd:3,'/',connarr[me,i].remid:1);
            sendpkt(discreq,connarr[me,i].remadd,me,
                    i,connarr[me,i].remid);
            connarr[me,i].state := closing

         end
            else connarr[me,i].duration :=
                 connarr[me,i].duration - 1
      end
   end
end;

{------------------------------------------------------------}
{ sends a connect request if possible }

procedure newreq;
var  i : integer;
     idleconn : boolean;
     dest     : address;
begin

   idleconn := false;
   i := 1;
   while (i <= sessions) and not idleconn do begin
      if connarr[me,i].state = idle then begin
         idleconn := true;
         repeat
            dest := xrand(5);
         until (dest <> me);
         connarr[me,i].state    := opening;
         connarr[me,i].remadd   := dest;
         connarr[me,i].remid    := 1;       { not known }
         connarr[me,i].timeouts := 0;
         connarr[me,i].owner    := us;

         writeln(z,'Connreq (',i:1,') to',dest:3);
         sendpkt(connreq,dest,me,i,1)
      end;
      i := i + 1
   end
end;

{------------------------------------------------------------}

procedure transportlayer;
begin {transportlayer}

   { process any incoming messages }

   newmessages;

   { resend any messages which were timed out }

   dotimeouts;

   { terminate any expired connections }

   killconn;

   { generate new connection requests if time<=100 }

   if (time <= stage1) then newreq;

end; {transportlayer}

{------------------------------------------------------------}

procedure init;
var  i,j : integer;
   index : integer;
begin
   rewrite(result);
   rewrite(z);
   for i:= 1 to machines do begin
      queuepos[i] := 0;               {nothing in queue}
      for j:=1 to sessions do
         connarr[i,j].state := idle   {everything idle}
   end
end;  {init}

{------------------------------------------------------------}

begin    {program}
   init;
   for time:= 1 to stage2 do begin

      if (time mod 5)=1 then begin
         writeln(result);
         writeln(result,'Status  Local  Remote  ',
                        'Intended  Actual  Time');
      end;

      for me:=1 to machines do begin
         writeln(z);
         writeln(z,'---  Host',me:3,'  Time',time:5);
         transportlayer
      end
   end
end.
