(*  t5  - Interpreter test program 2 *)
(*  calculate x!                     *)

prog
   var x,result;

   funct fact(n);
   begin
      if n < 0 then return -1 endif;
      if n = 0 then return  1 endif;
      return n * fact(n-1)
   endfn

begin
   write "Execution of factorial program commenceth";
   write "Enter value of X, -1 to end";
   read x;

   while x >= 0 do
      result := fact(x);
      write "X=",x,"  Fact(X)=",result;
      write "Enter value of X, -1 to end";
      read x 
   enddo;

   write "Program terminating";
   write "Last value of X entered was",x
endprg
