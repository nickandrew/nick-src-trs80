program transport(input,output,result);

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
                 state    : states;
                 remadd   : address;
                 remid    : connid;
                 timeouts : integer;
                 setup    : integer;    {time of creation}
                 owner    : owners;     {who made it}
                 intended : integer;    {intended duration}
                 duration : integer     {time remaining}
               end;

    connopen : array[address] of integer; {count of open conn}

    result   : text;
    time     : integer;
    me       : address;

    r, s     : message;

function xrand(top:integer) : integer;
begin
   xrand := trunc(rndr * top) + 1
end;

{ send a packet to a destination }
procedure sendpkt(a : mtype; b,c : address; d,e : connid);
begin
   s.mmtype := a;
   s.remote := b;
   s.local  := c;
   s.loccon := d;
   s.remcon := e;
   if (xrand(10) > errorprob) then begin
      queuepos[b] := queuepos[b] + 1;

      if (queuepos[b] <= 10) then
         queue[b,queuepos[b]] := s
      else writeln('Queue for host',b:3,' too long')
   end
end; { sendpkt }


{ process connect request }
procedure newconn;
var  i : integer;
     dupflag, okflag : boolean;
begin

   dupflag := false;
   okflag  := false;

   { determine if duplicate }
   i := 1;
   while (i<=sessions) and (not dupflag) do begin
      if (connarr[me,i].remadd = r.local) and
      (connarr[me,i].state = isopen) and
      (connarr[me,i].remcon = r.loccon) then begin
         { send connect confirm }
         dupflag := true
      end;
      i := i + 1
   end;

   if not dupflag then begin

      { find an idle connection if possible }
      i := 1;
      repeat
         i := i + 1;
         if (connarr[me,i].state = idle) then
            okflag := true
      until (i = sessions) or (okflag)
   end;

   if (okflag) then begin
      { setup the connection }
      connarr[me,i].state := isopen;
      connarr[me,i].remadd := r.local;
      connarr[me,i].remid := r.loccon;
      connarr[me,i].timeouts := 0;        {not needed}
      connarr[me,i].setup := time;
      connarr[me,i].owner := them;
      connarr[me,i].duration := 0         {not needed}
   end;

   if (dupflag or okflag) then begin
      { send a connect confirm }
      sendpkt(connconf,r.local,me,i,r.loccon)
      { args are: mmtype,remote,local,loccon,remcon }
   end

end; { newconn }

{ executed when a 'connect confirm' message arrives }

procedure verifyconn;
var  i : integer;
begin
   { set the referred-to connection 'open' }
   i := r.remcon;
   connarr[me,i].state := isopen;
   connarr[me,i].setup := time;
   connarr[me,i].intended := xrand(10);
   connarr[me,i].duration := connarr[me,i].intended
end; { verifyconn }

{ executed when a 'disconnect confirm' message arrives }

procedure verifydisc;
var  i : integer;
begin
   { set the referred-to connection 'idle' from 'closing' }
   i := r.remcon;
   connarr[me,i].state := idle;

   { output the connection record }
   write(result,'closed: local=',me:2,' remote=',r.local:2,
         ' local id=',i:2,' remote id=',r.loccon:2);
   writeln(result);
   write(result,'Intended duration=',connarr[me,i].intended:3,
         ' Actual duration=',(time-connarr[me,i].setup+1):3,
         ' Current time=',time:3);
   writeln(result);
   writeln(result)

end; { verifydisc }

{ executed when disconnect request is received }
procedure doconfirm;
var  i : integer;
begin

   i := r.remcon;

   { set idle only if the connection if correct }
   if (connarr[me,i].state  = isopen) and
      (connarr[me,i].remadd = r.local) and
      (connarr[me,i].remid  = r.loccon) then
         connarr[me,i].state := idle;

   { reply with disconnect confirm }
   sendpkt(discconf,r.local,me,i,r.loccon)
end; { doconfirm }

procedure newmessages;
var  i : integer;
begin
   {process arriving messages}

   for i:=1 to queuepos[me] do begin
      r := queue[me,i];
      case r.mmtype of
         connreq  : begin
                       newconn;
                    end;

         connconf : begin
                       verifyconn;
                    end;

         discreq  : begin
                       doconfirm;
                    end;

         discconf : begin
                       verifydisc;
                    end
      end;
   end;
end; {newmessages}

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
            if (connarr[me,i].state = opening)
               then m := connreq
               else m := discreq;

            sendpkt(m,connarr[me,i].remadd,
                    me,i,connarr[me,i].remid);
            connarr[me,i].timeouts := 0
         end
      end
   end
end;

{ sends disconnect request for finished connections }

procedure killconn;
begin
end;

{ sends a connect request if possible }

procedure newreq;
begin
end;


procedure transportlayer;
begin {transportlayer}

   {process any incoming messages}
   newmessages;

   {terminate any expired connections}
   killconn;

   {generate new connection requests}
   if (time <= stage1) then newreq;

end; {transportlayer}

procedure init;
var  i,j : integer;
   index : integer;
begin
   rewrite(result);
   for i:= 1 to machines do begin
      queuepos[i]      := 0;   {nothing in queue}
      connopen[i]      := 0;   {no connections open}
      for j:=1 to sessions do
         connarr[i,j].state := idle
   end
end;  {init}

begin    {program}
   init;
   for time:= 1 to stage2  do
      for me:=1 to machines do
         transportlayer
end.
