program cpx1(input,output,result);

const  maxseq = 7;
       maximp = 1;                 {only imps 0 and 1}
       propagation = 1;            {propagation delay}
       toint = 5;                  {timeout interval}
       errorprob = 0;              {line error probability %}
       hostrdyprob = 40;           {host ready prob %}
       maxtick = 100;              {length of run}
       maxmessage = 101;           {maximum messages}

type   sequencenr = 0..maxseq;     {frame numbering}
       message = 0..maxmessage;    {allowable data part}
       framekind = (data,ack);     {frame type}

       impnr = 0..maximp;
       frame = record
                  kind: framekind;
                  seq : sequencenr;
                  ack : sequencenr;
                  info: message;
               end;
       window = record
                   winfo: message;
                   timer: integer;
                end;
       outbuf  = array[sequencenr] of window;
       inbuf   = array[sequencenr] of record
                                      xinfo : message;
                                      used  : boolean;
                                      end;
       transbuf = record
                     f : frame;
                     arrivaltime: integer;
                  end;

       transit = array[0..propagation] of transbuf;
{length of channel array = 0..propagation because number of }
{ packets max travelling = propagation/packet send time (1) }
{ the receiver takes 1 packet off the channel each time unit}
{ this is especially noticeable with timeouts.              }

var
    result : text;
    nexttosend : array[impnr] of sequencenr;
    ackexpected : array[impnr] of sequencenr;
    frameexpected : array[impnr] of sequencenr;
    nbuffered : array[impnr] of sequencenr;
    buffer : array[impnr] of outbuf;
    recbuff : array[impnr] of inbuf; {receiver window}
    channel : array[impnr] of transit;
    nextsend : array[impnr] of 0..propagation;
    nextrec : array[impnr] of sequencenr;
    errorcount : array[impnr] of integer;
    tocount : array[impnr] of integer;
    nextmessageno : array[impnr] of message;
    pipedelay : array[impnr] of integer;
    r, s : frame;
    tick : integer;
    j    : impnr;

procedure wait;
var x: char;
begin
{  repeat x:= inkey
      until (ord(x) = 13);  }
end;

procedure inc(var k : sequencenr);
begin
   k := (k + 1) mod (maxseq + 1);
end; {inc}

function between(a,b,c : sequencenr) : boolean;
begin
   if ((a <= b) and (b < c))
   or ((c < a) and (a <= b))
   or ((b < c) and (c < a))
      then between := true
      else between := false;
end; {between}

procedure tohost(me:impnr; fr : frame);
begin
   writeln('Imp',me:3,' RCVD frame',fr.seq:4,
           ' message:',fr.info:4,' time:',tick:4,
           ' Ack:',fr.ack:2);
   writeln(result,'Imp',me:3,' Received message:',fr.info:4,
           ' at time:',tick:4)
end;

function fromhost(me:impnr) : message;
begin
   fromhost := nextmessageno[me];
   nextmessageno[me] := nextmessageno[me] + 1;
end;

procedure senddata(framenr : sequencenr; me:impnr);
var  temp : 0..propagation;
     err  : integer;
begin
   s.kind := data;
   s.seq  := framenr;
   s.ack  := (frameexpected[me] + maxseq) mod (maxseq + 1);
   buffer[me][framenr].winfo := s.info;
   buffer[me][framenr].timer := 0;

   {if no error, then send frame}
   err := trunc(rndr*100.0) + 1;    {1..100}
   if (err <= 100-errorprob) then begin
      {place frame on next available channel slot}
      temp := nextsend[me];
      channel[me][temp].f    := s;
      channel[me][temp].arrivaltime := tick + propagation;
      nextsend[me] := (temp + 1) mod (propagation + 1);
   end else errorcount[me] := errorcount[me] + 1;

   write('Imp',me:3);
   if (err <= 100-errorprob)
      then write(' sent frame',framenr:4)
      else write('  TRASHED  ',framenr:4);
   writeln(' message:',s.info:4,
           ' time:',tick:4,' Ack:',s.ack:2);
end;

procedure sendack(me : impnr);
var  temp : 0..propagation;
     err  : integer;
begin
   s.kind := ack;
   s.ack  := (frameexpected[me] + maxseq) mod (maxseq + 1);

   {if no error, then send ack frame}
   err := trunc(rndr*100.0) + 1;   {1..100}
   if (err <= 100-errorprob) then begin

      {place frame on next available channel slot}
      temp := nextsend[me];
      channel[me][temp].f := s;
      channel[me][temp].arrivaltime := tick + propagation;
   end
      else errorcount[me] := errorcount[me] + 1;
end;



function hostready : boolean;
var temp : integer;
begin
   temp := trunc(rndr*100.0)+1;     { 1..100 }
   if (temp <= hostrdyprob)
      then hostready := true
      else hostready := false;
end;

procedure protocol6(me,you : impnr);
var i,k,l,m,n   : integer;
    seq1,temp   : sequencenr;
    framerecvd  : boolean;
    framenr     : sequencenr;

begin {protocol6}

   {channel[me] is sending channel}
   {channel[you] is receiving channel}

   {look for arriving packets}
   framerecvd := false;
   for i:=0 to propagation do begin

      {this detects multiple frames with same arrivaltime}
      if (channel[you][i].arrivaltime = tick) then begin

         if (framerecvd) then begin
            writeln('Error: Multiple frames received');
         end;
         framerecvd := true;
         r := channel[you][i].f;

         {frame does not need to be 'removed' from channel}

         {temp is the first frame outside the window}
         temp:=(frameexpected[me]+(maxseq+1) div 2)
               mod (maxseq + 1);

         {if frame is within receivers window}
         if between(frameexpected[me],r.seq,temp) then begin
            recbuff[me][r.seq].xinfo := r.info;
            recbuff[me][r.seq].used  := true;

            {send message or group of messages if possible}
            framenr := frameexpected[me];
            while (recbuff[me][framenr]) do begin
               r.info := recbuff[me][framenr].xinfo;
               recbuff[me][framenr].used := false;
               tohost(me,r);
               {ack gets sent in next outgoing frame}
               inc(frameexpected[me]);
               inc(framenr);
            end;
         end else begin
            writeln('Imp',me:3,' Out-of-order frame',
             channel[you][i].f.seq:4,' Arrived at',tick:4);
         end;

         {process ack field within frame just received}
         while between(ackexpected[me],r.ack,
          nexttosend[me]) do begin
            nbuffered[me] := nbuffered[me] - 1;
            inc(ackexpected[me]);
         end;
      end;
   end;

   seq1 := ackexpected[me];
   while between(ackexpected[me],seq1,nexttosend[me]) do begin

      {update the timer. Only 1 frame can timeout per tick}
      buffer[me][seq1].timer := buffer[me][seq1].timer + 1;

      if (buffer[me][seq1].timer = toint) then begin
         {there has been a timeout}
         tocount[me] := tocount[me] + 1;
         writeln('Imp',me:3,' Timeout on frame',seq1:2,
                 ' at time:',tick:4);
         writeln(result,'Imp',me:3,' Timeout on frame',seq1:2,
                 ' at time:',tick:4);

         {setup for retransmission of timed out frame}
         pipedelay[me]:=1;

         {go back 1 ... retransmit frame "ackexpected" only}
      end;
      inc(seq1);
   end;

   if (pipedelay[me] = 0) then begin

      {use a smaller sender window ...(maxseq + 1)/2 }

      if (nbuffered[me] < (maxseq + 1)/2) then begin
         if (hostready) then begin
            {send new frame with ack for last frame received}
            nbuffered[me] := nbuffered[me] + 1;
            s.info := fromhost(me);
            senddata(nexttosend[me],me);
            inc(nexttosend[me]);
         end;
      end else begin
         {send an ack frame ... it can be garbled too}
         sendack(me);
      end;

   end else begin

      {retransmit a timed out frame}
      s.info := buffer[me][ackexpected[me]].winfo;
      senddata(ackexpected[me],me);
      pipedelay[me] := pipedelay[me] - 1;
   end;


end; {protocol6}

procedure initialise;
var  i,j : integer;
   index : integer;
begin
   rewrite(result);
   for j:= 0 to maximp do begin
      nexttosend[j]    := 0;
      ackexpected[j]   := 0;
      frameexpected[j] := 0;
      nbuffered[j]     := 0;
      errorcount[j]    := 0;
      tocount[j]       := 0;
      nextmessageno[j] := 1;
      nextsend[j]      := 0;
      nextrec[j]       := 0;
      pipedelay[j]     := 0;
      for i:= 0 to maxseq do begin
         buffer[j][i].timer := 0;
         recbuff[j][i].used := false;
      end;
      for i:=0 to propagation do begin
         channel[j][i].arrivaltime := 0;
      end;
   end;
end;  {initialise}

procedure printresults;
var i : integer;
begin {printresults}
   writeln(result);
   writeln(result,'Parameters - Protocol 6');
   writeln(result,'-----------------------');
   writeln(result,'Propagation delay : ',propagation:4);
   writeln(result,'Timeout interval  : ',toint:4);
   writeln(result,'Error Probability : ',errorprob:4);
   writeln(result,'Host Ready Prob   : ',hostrdyprob:4);
   writeln(result);
   writeln(result,'Imp  Msgs Xmtd    Errors    Timeouts');
   writeln(result,'---  ---------    ------    --------');

   for i:=0 to maximp do begin
      writeln(result,i:3,
              (nextmessageno[i]-1):11,
              errorcount[i]:10,
              tocount[i]:12);
   end;
end;  {printresults}

begin    {program}
   initialise;
   for tick:= 1 to maxtick do begin
      for j:=0 to maximp do begin
         wait;
         writeln;
         {imp J talks to imp 1-J when maximp=1}
         protocol6(j,1-j);
      end;
   end;
   printresults;
end.


