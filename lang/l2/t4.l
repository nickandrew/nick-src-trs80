(*  t4  - Interpreter test program 1 *)
(*  Test general execution of statements & expressions *)

prog
   var  x, glob1, junk;

   funct fa (value);
   var temp;
   var tempunhidden;

      funct fa1 (value);
      begin
         write "FA1, value",value;
         write "tempunhidden is",tempunhidden;
         tempunhidden := tempunhidden + 1;
         return fa(value-1)
      endfn

   begin  (* fa *)
      write "FA, value",value;
      tempunhidden := 1;
      if value = 0 then return 6 endif;
      temp := fa1(value)+2;
      write "tempunhidden must equal 2 ...",tempunhidden;
      write " ";
      return temp
   endfn

   funct fb (value);
   var temp;
   begin  (* fb *)
      write "FB, value",value;
      temp := value/3;
      if temp*3 <> value then
         return fa(value)
      else
         return temp
      endif
   endfn

begin (* main program *)

   write "The L2 test program starteth";
   x := 3;
   write "x is",x,", now to test maths functions";

   x := (x-24)/3 + 8/(5-x)*(9-7) - 16;
   write "x should be -15, x actually is",x;

   write "subtraction (5) ", 8-3;
   write "addition (9) ", 4+5;
   write "more complex functions (22) ", 8-6/3+50 - 2*17;
   write "product (42) ", 6*7;
   write "division (18) ", 414 / 23;

   x := 0;

   while x < 20 do
      write "X=",x;

      (* the following statements will test IF-THEN-ELSE *)
      (* execution & logical statements including OR, AND *)

      if x < 10 then
         write "X is < 10"
      else
         write "X is >= 10"
      endif;

      if x=2 or x=3 or x=5 or x=7 then
         write "X is a prime < 10"
      endif;

      if x>5 and x<12 then
         write "5 < x < 12"
      endif;

      x := x + 1
   enddo;

   (* test WN opcode execution & unary operators *)

   write 25,576,2045,493,33,x-2,x-1,x,x+1;
   write -x, -(x+3), -x+3, +x-3, +(x-3), ++6;

   (* test global variable set/read *)
   glob1 := 555;
   write "Glob1 was",glob1;

   (* do some tests on recursive function calls *)
   (* and data hiding *)

   x := 0;
   while (x <> 10) do
      if x<>7 and x<>3 then junk := fa(x) endif;
      junk := fb(10-x);
      x := x + 1;
   enddo

endprg
