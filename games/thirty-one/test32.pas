program thirtyone(input,output);
type card    = 0..6;
     plyr    = (player1,player2);
     cardset = array(.1..15.) of card;

var  chosen  : cardset;
     player  : plyr;
     i,loops : integer;
     table   : array(.1..6.) of integer;
     nloops  : integer;


function play(chosen:cardset):plyr;
var  copy             : cardset;
     playresult       : plyr;
     sum,sum2,pos,i,j : integer;
     currentplayer    : plyr;
     oppositeplayer   : plyr;
     currentwin       : boolean;
     allowed          : boolean;
     total            : array(.0..6.) of integer;

begin (* function play *)
   loops:=(loops+1) mod 200;
   if loops=0
      then begin
              nloops:=nloops+1;
              writeln('Loop number ',nloops);
              for i:=1 to 15 do write(chosen(.i.));
              writeln
           end;
   sum:=0;
   for i:=1 to 15 do sum:=sum + chosen(.i.);
   i:=1;
   while (chosen(.i.)<>0) and (i<16) do i:=i+1;
   if odd(i)
      then currentplayer:=player1
      else currentplayer:=player2;
   oppositeplayer:=player1;
   if currentplayer=player1 then oppositeplayer:=player2;
   if sum=31 then play:=oppositeplayer;
   if sum>31 then play:=currentplayer;
   if sum<31 then
      begin
         pos:=i;
         for i:=1 to 15 do copy(.i.):=chosen(.i.);
         currentwin:=false;
         for i:=0 to 6 do total(.i.):=0;
         for i:=1 to 15 do
            begin
               j:=chosen(.i.);
               total(.j.):=total(.j.)+1
            end;
         i:=1;
         while (i<7) and (not currentwin) do
            begin
               j:=table(.i.);
               copy(.pos.):=j;
               if total(.j.) < 4 then currentwin:=
                  currentwin or (currentplayer=play(copy));
               i:=i+1
            end;
         if currentwin
            then play:=currentplayer
            else play:=oppositeplayer
      end
end;


begin (* main program thirtyone *)
   loops:=0;
   nloops:=0;
   table(.1.):=1;
   table(.2.):=6;
   table(.3.):=3;
   table(.4.):=4;
   table(.5.):=2;
   table(.6.):=5;
   for i:=1 to 15 do chosen(.i.):=0;  (*no cards*)
   player:=play(chosen);
   if player=player1
      then writeln('Overall, player 1 wins.')
      else writeln('Overall, player 2 wins.')
end.
