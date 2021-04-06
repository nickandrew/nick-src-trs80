#include <stdio.h>

char *(sys_errlist[63]);
int firstcall = 1;

err_init()
{
    int i;
    char **s;

    s = sys_errlist;
    firstcall = 0;

    for (i = 0; i < 63; ++i)
        sys_errlist[i] = NULL;

    s[0] = "No error";
    s[1] = "Bad file data";
    s[2] = "Seek error during read";
    s[3] = "Lost data during read";
    s[4] = "Parity error during read";
    s[5] = "Data record not found during read";
    s[8] = "Device not available";
    s[15] = "Write protected diskette";
    s[17] = "Directory read error";
    s[18] = "Directory write error";
    s[19] = "Illegal file name";
    s[24] = "File not in directory";
    s[25] = "File access denied";
    s[26] = "Directory space full";
    s[27] = "Diskette space full";
    s[28] = "End of file encountered";
    s[29] = "Past end of file";
    s[31] = "Program not found";
    s[32] = "Illegal or missing drive #";
    s[34] = "Load file format error";
    s[37] = "Illegal access tried to protected file";
    s[39] = "File not open";
    s[44] = "Bad directory data";
    s[45] = "Bad FCB data";
    s[46] = "System program not found";
    s[47] = "Bad parameter(s)";
    s[48] = "Bad filespec";
    s[52] = "Illegal keyword or separator or terminator";
    s[53] = "File already exists";
    s[54] = "Command too long";
    s[62] = "Can't extend file via read";
}

doserr(err, str1, str2, rc)
int err;                        /* error code */
char *str1, *str2;              /* strings to print */
int rc;                         /* exit() code */
{
    if (firstcall)
        err_init();
    if (str1)
        fputs(str1, stderr);
    if (sys_errlist[err])
        fputs(sys_errlist[err], stderr);
    else
        fputs("Unexpected error code!", stderr);
    if (str2)
        fputs(str2, stderr);
    if (rc)
        exit(rc);
}
