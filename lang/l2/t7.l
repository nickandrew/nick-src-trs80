(*  t7  - Interpreter test program 4 *)
(*  calculate integer approximation to sqrt(x)  *)

prog
   var x,s;

   funct abs(number);
   begin
      if number >=0 then return number
      else return -number endif
   endfn

   funct sqrt(number);
   var  guess,newguess,iter;
   var  diff;
   begin
      iter := 0;
      if number < 0 then return -1 endif;
      if number = 0 then return 0 endif;

      guess := number / 2;
      newguess := (guess + number/guess)/2;
      diff := abs(guess - number/guess);

      while diff > 1 do
         iter := iter + 1;
         guess := newguess;
         newguess := (guess + number/guess)/2;
         diff := abs(guess - number/guess)
      enddo;
      write "Required ",iter," iterations."
   endfn

begin
   write "Execution of square root program commenceth";
   write "Enter values or 0 to end";
   read x;

   while x > 0 do
      s := sqrt(x);
      write "X=",x," sqrt(x) approx =",s;
      read x
   enddo

endprg
