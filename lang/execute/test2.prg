set A
print print hello 3 times
while A
   print hello
   if C
      unset A
   end

   if B
      set C
   else
      set B
   end
end

unset A
unset B
unset C
set A

while A
   print -- A is set
   if B
      set C
      unset B
      print -- C is set and B is unset
   else
      print setting b
      set B
      if C
         if D
            unset A
         end
         print B is unset and C is set
         set D
      else
         print B is unset and C is unset
      end
   end
end

print program end
