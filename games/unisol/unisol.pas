program unisol(input,output,puzzles);
var
   l     : array[1..9] of record        { letter A-J }
            val       : 0..9;           { value 1-9  }
            touse     : 1..2;
           end;

 puzzles : text;
   val   : array[1..9] of 0..9;
   chars : array[1..10] of char;
   puz   : integer;
   i     : integer;
   square: array[1..4,1..4] of 0..10;
   sumh  : array[1..4] of integer;
   sumv  : array[1..4] of integer;
   sum   : integer;
   clue1 : 1..9;
   clue2 : 1..9;

procedure genval;
var i : integer;
placed: integer;
begin

   for i:=1 to 9 do l[i].val := 0;

   { assign values of 1..9 }
   placed := 0;
   while placed < 9 do begin
      repeat
         i := rnd(9);
      until l[i].val = 0;
      placed     := placed + 1;
      l[i].touse := 2;
      l[i].val   := placed
   end;

   { set which are used once & which are clue letters }
   i := rnd(9);
   l[i].touse := 1;
   clue1 := i;
   repeat i:= rnd(9) until l[i].touse = 2;
   l[i].touse := 1;
   repeat i:= rnd(9) until l[i].touse = 2;
   clue2 := i;
end;

function genpos : boolean;
var i , j : integer;
    xp,yp : integer;
    xo,yo : integer;
    tries : integer;
   failed : boolean;
begin

   { init }
   failed := false;
   tries := 0;
   for i:=1 to 4 do begin
      sumh[i] := 0;
      sumv[i] := 0;
      for j:=1 to 4 do
         square[i,j] := 0
   end;
   sum := 0;

   { assign first place }
   for i:=1 to 9 do begin
      repeat
         xp := rnd(4);
         yp := rnd(4)
      until square[xp,yp] = 0;

      xo := xp;
      yo := yp;

      square[xp,yp] := i;
      sumh[yp] := sumh[yp] + l[i].val;
      sumv[xp] := sumv[xp] + l[i].val;
      sum := sum + l[i].val;

      { assign second place }
      if l[i].touse = 2 then begin
         repeat
            xp := rnd(4);
            yp := rnd(4);
            tries := tries + 1
         until ((square[xp,yp]=0) and (xp<>xo) and (yp<>yo))
               or (tries > 100);
         if tries > 100 then failed := true;

         square[xp,yp] := i;
         sumh[yp] := sumh[yp] + l[i].val;
         sumv[xp] := sumv[xp] + l[i].val;
         sum := sum + l[i].val;
      end;
   end;

   if not failed then begin
      { pick a square for the X }
      repeat
         xp := rnd(4);
         yp := rnd(4)
      until l[square[xp,yp]].touse = 2;
      square[xp,yp] := 10
   end;

   genpos := not failed

end;



procedure print;
var i,j : integer;
begin
   writeln(puzzles);
   writeln(puzzles);
   writeln(puzzles,'+---+---+---+---+');
   for i:=1 to 4 do begin
      write(puzzles,'| ');
      for j:=1 to 4 do
         write(puzzles,chars[square[j,i]],' | ');
      writeln(puzzles,sumh[i]:3);
      writeln(puzzles,'+---+---+---+---+');
   end;

   for i:=1 to 4 do
      write(puzzles,sumv[i]:4);
   writeln(puzzles,sum:5);
end;


procedure init;
var i : integer;
begin
   for i:=1 to 8 do chars[i] := chr(i-1+ord('A'));
   chars[9] := 'J';
   chars[10] := 'X';
   rewrite(puzzles);
end;

begin {main}
   init;
   write('How many puzzles? ');
   read(puz);
   for i:=1 to puz do begin
      repeat
         writeln('Generating values');
         genval;
         writeln('Generating square');
      until genpos;
      print
   end;
end.
