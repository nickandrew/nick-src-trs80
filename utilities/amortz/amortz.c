/* Loan amortization - uses double precision floating point
 * program is based upon a loan amortization program
 * in the LEVEL I BASIC manual for the TRS80 Model I
 */

#include <stdio.h>


main()
{
        float   a, b, princ, rate, interest;
        double  monthpay, t;
        double  work1,work2,work3;
        float   atof(), ftoa();
        int     c,c2,cz,periods,year;
        char inline[80];


        /* principal */
        puts("Principal ==> ");
        gets(inline);
        princ = atof(inline);
        printf("Princ is %5g\n",princ);

        /* number of periods (periods) */
        puts("\n# of Periods ==> ");
        gets(inline);
        periods = atoi(inline);
        printf("Periods is %3d\n",periods);

        /* interest rate */
        puts("\nInterest Rate (%) ==> ");
        gets(inline);
        interest = atof(inline);
        printf("Interest = %5f\n",interest);

        /* x% monthly interest is (x/12) * .01 */
        year = 0;
        puts("\n\n\n\tWorking....");
        interest = interest/1200.0;

        t = 1.0;
        work1 = 1.0 + interest;
        for (cz = periods; cz != 0 ; --cz)
                t = t * work1;
        t = 1.0 / t;
        t = 1.0 - t;

        monthpay = princ * interest + t;
        monthpay = dround(monthpay);
        header(++year);
        for (cz = 1; cz <= periods; ++cz) {
                a = dround(princ*interest);
                b = monthpay - a;
                princ = princ - b;
                printf("%7d %9f %8f %9f %8f\n",
                       cz, princ, monthpay, b, a);
                c = cz;
                if ((c %= 12 ) == 0) {
                        if (cz != periods) header(++year);
                }
        }
        exit(0);
}
header(year)
int     year;
{
printf("Payment Remaining  Monthly  Principal Interest  Year:%d\n",year);
puts  ("Number  Principal  Payment   Payment  Payment\n");
}

double dround(d1)
double  d1;
/* converts a double precision number to round to hundreths */
{
        double  work1;
        long    work2;
        work1 = d1 * 100.0 + 0.05;
        work2 = (long) work1;
        work1 = work2 / 100.0;
        return work1;
}


printd(d1,w)
/* print double precision d1 in field of width w */
double d1;
int    w;
{
   char cd1[20];
   int i;
   char c,control[5],width[3];

        if (w > 64) abort("printd: width too great");
        i = ftoa((float) d1,cd1);
        for (i=0; (c = cd1[i++]) != '.' && c != '\0';) ;

        if (c == '.') {
                if (c = cd1[i++]) {
                        if (c = cd1[i]) ;
                        else cd1[i] = '0';
                        cd1[++i] = '\0';
                } else
                        strcat(cd1,"00");
        } else
                strcat(cd1,".00");

        itoa(w,width);
        i =     strlen(width);
        if (i == 1) {
           control[0] = '%';
           control[1] = width[0];
           control[2] = 's';
           control[3] = ' ';
           control[4] = '\0';
        } else {
           control[0] = '%';
           control[1] = width[0];
           control[2] = width[1];
           control[3] = 's';
           control[4] = ' ';
           control[5] = '\0';
        }
        printf(control,cd1);

}


abort(msg)
char *msg;
{
        fputs(msg,stderr);
        putc('\n',stderr);
        exit(1);
}
