(*  t6  - Interpreter test program 3 *)
(*  calculate fibonacci sequence     *)

prog
   var fib1,fib2,fib3,counter;
   var i;

begin
   write "Execution of fibonacci program commenceth";
   write "Enter number of iterations";
   read counter;

   fib1 := 1;
   fib2 := 1;
   i := 3;

   write "Fib",1,"  =",fib1;
   write "Fib",2,"  =",fib2;

   while counter > 0 do
      fib3 := fib1 + fib2;
      write "Fib",i,"  =",fib3;
      i := i + 1;
      fib1 := fib2;
      fib2 := fib3;
      counter := counter - 1
   enddo

   write "End of fibonnaci"
endprg
