/*
 * ULIST/C: List users of Zeta.
 * 30-Mar-86.
 */

#include <stdio.h>

FILE *fp_uf;
int uid;

struct {
       char   uf_status;
       char   uf_name[24];
       char   uf_passwd[13];
       int    uf_uid;
       int    uf_ncalls;
       char   uf_lc1,uf_lc2,uf_lc3;
       char   uf_priv1,uf_priv2,uf_priv3;
       char   uf_tdata;
       char   uf_regcount;
       char   uf_badlogin;
       char   uf_tflg1,uf_tflg2;
       char   uf_erase,uf_kill;
       char   uf_nothing;
       } ufb;

char hash[256];


main()
{
   int  i;
   fprintf(stderr,"ulist: opening files\n");
   if (sizeof (ufb) != 56)
      {
      fprintf(stderr,"ulist: buffer has wrong size\n");
      exit(1);
      }

   fp_uf=fopen("userfile/zms","r");
   if (!fp_uf )
      {
      fprintf(stderr,"ulist: difficulty opening file\n");
      exit(1);
      }
 
   uid= -1;

   printf("\017");
   printf("St Name.................... Password..... ");
   printf("Uid.. Calls DD/MM/YY p1 p2 p3 Td Rc Bd TT ");
   printf("T2 ^H ^X ??\n");
   while (listu());
   fclose(fp_uf);
   printf("\022");
   fprintf(stderr,"ulist: finished\n");
}

listu()
{
   int  c,i;
   char *ufp,*cp;

   ufp= &ufb;
   uid++;

   /* bypass hash sector info */
   if ((uid%256)==0) for (i=0;i<256;i++) getc(fp_uf);

   for (i=0;i<56;i++)
      {
      c=getc(fp_uf);
      if (c==EOF)
         if  (i==0) break;
         else       {
            fprintf(stderr,"Bad userfile EOF\n");
            exit(1);
         }
      *(ufp++) = c;
      }
   if (c==EOF) return(0);

   fprintf(stderr,"Listing record %d\n",uid);

   printf("%2x ",ufb.uf_status);
   for (i=0;i<24;i++) {
      if (ufb.uf_name[i]==0) putchar(' ');
      else putchar(ufb.uf_name[i]);
   }
   putchar(' ');
   for (i=0;i<13;i++) {
      if (ufb.uf_passwd[i]==0) putchar(' ');
      else putchar(ufb.uf_passwd[i]);
   }

   printf("%5d %5d %2d/%2d/%2d %2x %2x %2x %2x ",
          ufb.uf_uid, ufb.uf_ncalls,
          ufb.uf_lc1, ufb.uf_lc2, ufb.uf_lc3,
          ufb.uf_priv1, ufb.uf_priv2, ufb.uf_priv3,
          ufb.uf_tdata);
   printf("%2x %2x %2x %2x %2x %2x %2x\n",
          ufb.uf_regcount, ufb.uf_badlogin, ufb.uf_tflg1,
          ufb.uf_tflg2, ufb.uf_erase, ufb.uf_kill,
          ufb.uf_nothing);
}

