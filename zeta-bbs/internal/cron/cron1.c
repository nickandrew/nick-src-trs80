/* @(#) cron: Execute commands at predefined intervals
*/

#include <stdio.h>
#include <stdlib.h>

char version[20] = "cron 1.1  12 May 90";

#define CRONTAB "crontab"

int chkdate(void);
void blanks(void);
int getsched(void);
void fixdate(void);
void putsched(int v);

FILE *crontab;

char line[256], posbuf[3],      /* saved position buffer */
 freq, *cp, *datep;

int inc, doit;

int s_y, s_m, s_d, s_h, s_min;  /* scheduled date */

int n_y, n_m, n_d, n_h, n_min;  /* current date */

int montab[12] = { 31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30 };

/* order is:          dec jan feb mar apr may jun jul aug sep oct nov */


int main()
{

    n_y = getyear();
    n_m = getmonth();
    n_d = getday();
    n_h = gethour();
    n_min = getminute();

    /* fopen mode should really be "r+" */
    if ((crontab = fopen(CRONTAB, "r")) == NULL) {
        fputs("Cannot open crontab\n", stderr);
        exit(1);
    }

    while (1) {
        savepos(crontab, posbuf);
        if (fgets(line, 256, crontab) == NULL)
            break;
        cp = line;
        if (*cp == '#')
            continue;           /* ignore comments */
        if (*cp == '\n')
            continue;           /* ignore blank lines */
        blanks();
        freq = toupper(*cp++);

        if (freq != 'D' && freq != 'M' && freq != 'Y' && freq != 'H') {
            fputs("Invalid D, M, Y or H in column 0\n", stderr);
            fputs(line, stderr);
            exit(1);
        }

        blanks();

        /* should use one of the standard routines for this */
        inc = 0;
        while (*cp >= '0' && *cp <= '9')
            inc = 10 * inc + (*cp++) - '0';
        blanks();

        if (inc <= 0) {
            fputs("Invalid line increment\n", stderr);
            exit(1);
        }

        datep = cp;
        s_y = getsched();
        s_m = getsched();
        s_d = getsched();
        s_h = getsched();
        s_min = getsched();

        blanks();

        if (chkdate() == 1) {
            /* current date is after scheduled date, do it */
            system(cp);
            setpos(crontab, posbuf);
            fixdate();
            putsched(s_y);
            putsched(s_m);
            putsched(s_d);
            putsched(s_h);
            putsched(s_min);
            fputs(line, crontab);
        }
    }

    fclose(crontab);
    return 0;
}

/* chkdate ... compare current date to scheduled date.
**	If we should run the command, return a 1
*/

int chkdate(void)
{
    if (s_y < n_y)
        return 1;
    if (s_y > n_y)
        return 0;
    if (s_m < n_m)
        return 1;
    if (s_m > n_m)
        return 0;
    if (s_d < n_d)
        return 1;
    if (s_d > n_d)
        return 0;
    if (s_h < n_h)
        return 1;
    if (s_h > n_h)
        return 0;
    if (s_min < n_min)
        return 1;
    if (s_min > n_min)
        return 0;
    return 1;
}

/*  blanks ... bypass spaces and tabs in the line */

void blanks(void)
{
    while (*cp == ' ' || *cp == '\t')
        ++cp;
}

/* getsched ... read a 2 digit number into an integer */

int getsched(void)
{
    int e;

    if (*cp < '0' || *cp > '9' || *(cp + 1) < '0' || *(cp + 1) > '9') {
        fputs("Error in YYMMDDHHMM specification\n", stderr);
        exit(1);
    }

    e = 10 * (*cp++ - '0');
    e += *cp++ - '0';
    return e;
}

/* fixdate ... increment the scheduled date by whatever necessary */

void fixdate(void)
{
    if (freq == 'H')
        s_h += inc;
    else if (freq == 'D')
        s_d += inc;
    else if (freq == 'M')
        s_m += inc;
    else if (freq == 'Y')
        s_y += inc;

    /* roll the days over with hourly increments */
    while (s_h > 23) {
        s_h -= 24;
        ++s_d;
    }

    /* roll the month over */
    while (s_d > montab[s_m % 12]) {
        s_d -= montab[s_m % 12];
        ++s_m;
    }

    /* roll the year over */
    while (s_m > 12) {
        s_m -= 12;
        ++s_y;
    }

    /* Christ, Zeta's old if this gets done! */
    while (s_y > 99) {
        fputs("You ancient old bastard, Zeta!\n", stderr);
        s_y -= 100;
    }
}

/* write a 2 digit field into the output line */

void putsched(int v)
{
    *datep++ = v / 10 + '0';
    *datep++ = v % 10 + '0';
}

/* end of program */
