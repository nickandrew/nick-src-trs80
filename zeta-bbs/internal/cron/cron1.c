/* Zetasource
** cron
** execute commands at predefined intervals
*/

char version[20]="cron 1.0a 10-Jul-87";

#include <stdio.h>

FILE *crontab;
char line[256],freq,*cp,*datep;
int  inc,doit;
int  s_y,s_m,s_d,s_h,s_min;    /* scheduled date */
int  n_y,n_m,n_d,n_h,n_min;    /* current date */
int  montab[12] = {31,31,28,31,30,31,30,31,31,30,31,30  };
/* order is:       decjanfebmaraprmayjunjulaugsepoctnov */


main() {

    char *fgets();

    n_y = getyear();
    n_m = getmonth();
    n_d = getday();
    n_h = gethour();
    n_min = getminute();

    if ((crontab=fopen("crontab","r"))==NULL) {
        fputs("Can't open crontab\n",stderr);
        exit(1);
    }

    while (1) {
        savepos(crontab);
        if (fgets(line,256,crontab)==NULL) break;
        cp = line;
        if (*cp == '#') continue;
        blanks();
        freq = toupper(*cp++);

        if (freq!='D' && freq!='M' && freq!='Y') {
            fputs("Invalid D, M or Y in column 0\n",stderr);
            exit(1);
        }

        blanks();
        inc = 0;
        while (*cp>='0' && *cp <= '9')
            inc = 10*inc + (*cp++) - '0';
        blanks();

        if (inc <= 0) {
            fputs("Invalid line increment\n",stderr);
            exit(1);
        }

        datep = cp;
        s_y = getsched();
        s_m = getsched();
        s_d = getsched();
        s_h = getsched();
        s_min = getsched();

        blanks();

        if (chkdate()==1) {
            system(cp);
            setpos(crontab);
            fixdate();
            putsched(s_y);
            putsched(s_m);
            putsched(s_d);
            putsched(s_h);
            putsched(s_min);
            fputs(line,crontab);
        }
    }

    fclose(crontab);
}


chkdate() {
    if (s_y < n_y) return 1;
    if (s_y > n_y) return 0;
    if (s_m < n_m) return 1;
    if (s_m > n_m) return 0;
    if (s_d < n_d) return 1;
    if (s_d > n_d) return 0;
    if (s_h < n_h) return 1;
    if (s_h > n_h) return 0;
    if (s_min < n_min) return 1;
    if (s_min > n_min) return 0;
    return 1;
}

blanks() {
    while (*cp==' ') ++cp;
}

getsched() {
    int e;
    if (*cp<'0' || *cp>'9' || *(cp+1)<'0' || *(cp+1)>'9') {
        fputs("Error in YYMMDDHHMM specification\n",stderr);
        exit(1);
    }

    e = 10 * (*cp++ - '0');
    e += *cp++ - '0';
    return e;
}

fixdate() {
    if (freq=='D') s_d += inc;
    else if (freq=='M') s_m += inc;
    else if (freq=='Y') s_y += inc;

    while (s_d > montab[s_m % 12]) {
        s_d -= montab[s_m % 12];
        ++s_m;
    }

    while (s_m > 12) {
        s_m -= 12;
        ++s_y;
    }

    while (s_y > 99) s_y -= 100;
}

putsched(v)
int  v;
{
    *datep++ = v / 10 + '0';
    *datep++ = v % 10 + '0';
}

