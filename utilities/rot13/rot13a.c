/**************************************************************/
/* rot13 - decode or encode a file using the rot13 algorithm  */
/* usage:   rot13   <infile   >outfile                        */
/* Nick Andrew, 11-Nov-86. Anybody caught compiling, reading, */
/*    changing, using, or selling this program will be badly  */
/*    beaten about the ears. This is a severe copyright sign  */
/*    and THIS MEANS YOU!                                     */
/**************************************************************/

#include <stdio.h>

main() {
   int  c;
   while ((c=getchar())!=EOF) {
      if ((c>='a' & c<='z') | (c>='A' & c<='Z')) {
         putchar( (c&0x5f-0x40)>13  ? c-13 : c+13);
      }
      else putchar(c);
   }
}

