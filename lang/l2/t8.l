(*  t8  - Interpreter test program 5 *)
(*  test numbers from 2 upwards for primality  *)

prog
var top,i,j,maxp;

funct sqrt(number);
   var  guess,newguess,iter;
   var  diff;

   funct abs(number);
      begin
         if number >=0 then return number
         else return -number endif
      endfn
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
      enddo
   endfn

begin
   write "Execution of prime numbers program commenceth";
   write "Enter topmost integer to test";
   read top;

   i := 2;    (* start list of primes from 2 *)

   while i <= top do

      j := 2;
      while j <= sqrt(i) do
         if i/j*j = i then
            maxp := i;
            write i," is prime"
         endif;
         j := j + 1
      enddo;
      i := i + 1;
   enddo;

   write "The highest prime <=",top", is",maxp
endprg

