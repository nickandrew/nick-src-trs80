/*  Zetasource
**  credit.c : Set account balance for people
**  Version 1.0  14-Aug-87
**
**  Usage: credit [r][+=-]amount [username]
**  'r' flag:    Update recent callers only
**  +/-/=amount: Add, subtract or set balance
**  [username]:  Update individual account
**/

#include <stdio.h>
#include <stdlib.h>

// I don't know where these are defined
extern int  chksysop(void);
extern int  getmonth(void);
extern int  getyear(void);
extern int  readrec(void);
extern int  search(void);
extern void skip(void);
extern void uopen(void);
extern void uclose(void);
extern void writrec(void);

void totals(void);
void repstr(char *string);
void reptot(char *string, int value);
int fixbal(void);

FILE *report;
int adjust, rec, recent = 0;
char namestr[25], *cp, *ncp;
char func;                      /* +, -, or = */
int *balptr;
char *lastcall;
char *uname;

char *priv2, *status;
#define IS_VISITOR      2
#define IS_USED        64

int plus = 0, minus = 0, zero = 0;
int nouse = 0;

int main(int argc, char *argv[])
{
    fputs("Chksysop", stdout);
    if (chksysop() == 0)
        exit(1);

    if (argc == 1) {
        fputs("usage: credit [r][+=-]amt [username]\n", stderr);
        exit(1);
    }

    if (**++argv == 'R') {
        recent = 1;
        ++*argv;
    }

    switch (**argv) {
    case '+':
    case '-':
    case '=':
        func = **argv;
        break;
    default:
        fputs("credit: use +, -, or = n\n", stderr);
        exit(1);
    }

    adjust = atoi(*argv + 1);
    if ((report = fopen("credrep", "a")) == NULL)
        fputs("credit: can't open credrep\n", stderr);

    uopen();

    if (argc > 2) {
        cp = namestr;
        --argc;
        while (--argc) {
            ncp = *++argv;
            while (*ncp) {
                *(cp++) = *(ncp++);
            }
            *(cp++) = ' ';
        }
        *(--cp) = 0;

        fputs("Searching...", stdout);
        if (search() != 1) {
            fputs("No account by that name\n", stderr);
            exit(1);
        }

        fputs("Fixing balance...", stdout);
        fixbal();
        fputs("Rewriting...\n", stdout);
        writrec();
    } else {
        rec = 0;
        for (;;) {
            if ((rec & 0xff) == 0)
                skip();
            if (readrec() != 0)
                break;
            if (fixbal()) {
                writrec();
            }
            ++rec;
        }
        totals();
    }
    if (report != NULL)
        fclose(report);
    uclose();
    return 0;
}

void totals(void)
{
    fputs("Printing totals...\n", stdout);
    repstr("Credit adjustment report -- totals\n\n");
    reptot("Users with positive credit: ", plus);
    reptot("Users in hock to Zeta:      ", minus);
    reptot("Bankrupt users:             ", zero);
}

void repstr(char *string)
{
    if (report != NULL)
        fputs(string, report);
}

void reptot(char *string, int value)
{
    char str[7];
    if (report != NULL) {
        fputs(string, report);
        itoa(value, str);
        fputs(str, report);
        fputs("\n", report);
    }
}

int fixbal(void)
{
    int month, year;

    month = getmonth();
    year = getyear();

    if ((*status & IS_USED) == 0)
        return 0;
    if (*priv2 & IS_VISITOR)
        return 0;

    if (--month == 0) {
        month = 12;
        --year;
    }

    if (recent) {
        if (lastcall[2] < year) {
            ++nouse;
            return 0;
        }

        if (lastcall[1] < month) {
            ++nouse;
            return 0;
        }
    }

    switch (func) {
    case '+':
        *balptr += adjust;
        break;
    case '-':
        *balptr -= adjust;
        break;
    case '=':
        *balptr = adjust;
    }

    if (*balptr < 0) {
        repstr(uname);
        reptot(" owes us $", -*balptr);
        ++minus;
    } else if (*balptr == 0) {
        repstr(uname);
        repstr(" is on the brink of ruin\n");
        ++zero;
    } else {
        ++plus;
    }
    return 1;
}
