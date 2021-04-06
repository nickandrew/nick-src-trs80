#include stdio/csh
#option redirect OFF

FILE *fp1, *fp2;
char *keyword[128];
int remflag, strflag;
main(argc, argv)
int argc, *argv;
{
    char c;
    if (argc != 3)
        abort("\n** Parameter error **\n");
    puts("\x1c\x1f");
    fp1 = getfile(*++argv, 'r');
    fp2 = getfile(*++argv, 'w');
    if ((c = getc(fp1)) != '\xff')
        abort("Not a compressed BASIC file!");
    setup();
    while (!end()) {
        linenumber();
        remflag = strflag = FALSE;
        while ((c = getc(fp1)) != '\0')
            if (remflag || strflag || c != ' ') {
                if (c > 127 && !strflag) {
                    if (token(c))
                        goto lineend;
                } else
                    out(c);
                if (c == '"')
                    strflag = strflag ? FALSE : TRUE;
            }
      lineend:if (strflag)
            out('"');
        out('\n');
    }
    fclose(fp1);
    fclose(fp2);
    exit(0);
}

linenumber()
{
    int num;
    num = getc(fp1);
    num += getc(fp1) * 256;
    fprintf(fp2, "%d ", num);
    printf("%d ", num);
    return (0);
}

end()
{
    int flag;
    char c;
    if ((c = getc(fp1)) == EOF)
        return TRUE;
    flag = c;
    if ((c = getc(fp1)) == EOF)
        return TRUE;
    flag += c * 256;
    if (flag == 0)
        return TRUE;
    else
        return FALSE;
}

token(val)
char val;
{
    char c;
    int pos, flag;
    fputs(keyword[val - 128], fp2);
    puts(keyword[val - 128]);
    if (val == 184) {           /* Strip value after CLEAR */
        while ((c = getc(fp1)) != ':' && c != '\0') {
        }
        if (c == '\0')
            return (TRUE);
        else {
            out(c);
            return (FALSE);
        }
    }
    if (val == 178) {           /* PRINT change PRINT@ values */
        while ((c = getc(fp1)) == ' ') {
        }
        if (c == '@') {
            out(c);
            pos = 0;
            flag = FALSE;
            while (isdigit(c = getc(fp1))) {
                flag = TRUE;
                pos *= 10;
                pos += c - '0';
            }
            if (flag) {
                fprintf(fp2, "(%d,%d)", pos / 64, pos % 64);
                printf("%d,%d)", pos / 64, pos % 64);
            }
        }
        if (c == '\0')
            return (TRUE);
        if (c > 127)
            return (token(c));
        else {
            if (c == '"')
                strflag = strflag ? FALSE : TRUE;
            out(c);
        }
    }
    if (val == 147 || val == 251)
        remflag = TRUE;
    return (FALSE);
}

getfile(fname, mode)
char *fname, mode;
{
    char *fp;
    if (mode == 'r') {
        if ((fp = fopen(fname, "r")) == NULL) {
            printf("Open error - %-20s\n", fname);
            exit(1);
        } else
            return fp;
    } else if (mode == 'w') {
        if ((fp = fopen(fname, "w")) == NULL) {
            printf("Open error - %-20s\n", fname);
            exit(1);
        } else
            return fp;
    }
}

out(c)
char c;
{
    putchar(c);
    if (c != putc(c, fp2)) {
        puts("File I/O error!\n");
        fclose(fp1);
        fclose(fp2);
        exit(1);
    }
    return (0);
}

setup()
{
    keyword[0] = "END ";
    keyword[1] = "FOR ";
    keyword[2] = "RESET";
    keyword[3] = "SET";
    keyword[4] = "CLS ";
    keyword[5] = "CMD ";
    keyword[6] = "RANDOM ";
    keyword[7] = "NEXT ";
    keyword[8] = "DATA ";
    keyword[9] = "INPUT ";
    keyword[10] = "DIM ";
    keyword[11] = "READ ";
    keyword[12] = "LET ";
    keyword[13] = " GOTO ";
    keyword[14] = "RUN ";
    keyword[15] = "IF ";
    keyword[16] = "RESTORE ";
    keyword[17] = " GOSUB ";
    keyword[18] = "RETURN ";
    keyword[19] = "REM ";
    keyword[20] = "STOP ";
    keyword[21] = " ELSE ";
    keyword[22] = "TRON ";
    keyword[23] = "TROFF ";
    keyword[24] = "DEFSTR ";
    keyword[25] = "DEFINT ";
    keyword[26] = "DEFSNG ";
    keyword[27] = "DEFDBL ";
    keyword[28] = "LINE ";
    keyword[29] = "EDIT ";
    keyword[30] = "ERROR ";
    keyword[31] = "RESUME ";
    keyword[32] = "OUT ";
    keyword[33] = "ON ";
    keyword[34] = "OPEN ";
    keyword[35] = "FIELD ";
    keyword[36] = "GET ";
    keyword[37] = "PUT ";
    keyword[38] = "CLOSE ";
    keyword[39] = "LOAD ";
    keyword[40] = "MERGE ";
    keyword[41] = "NAME ";
    keyword[42] = "KILL ";
    keyword[43] = "LSET ";
    keyword[44] = "RSET ";
    keyword[45] = "SAVE ";
    keyword[46] = "SYSTEM ";
    keyword[47] = "LPRINT ";
    keyword[48] = "DEF ";
    keyword[49] = "POKE ";
    keyword[50] = "PRINT ";
    keyword[51] = "CONT ";
    keyword[52] = "LIST ";
    keyword[53] = "LLIST ";
    keyword[54] = "DELETE ";
    keyword[55] = "AUTO ";
    keyword[56] = "CLEAR ";
    keyword[57] = "CLOAD ";
    keyword[58] = "CSAVE ";
    keyword[59] = "NEW ";
    keyword[60] = "TAB(";
    keyword[61] = " TO ";
    keyword[62] = "FN ";
    keyword[63] = "USING ";
    keyword[64] = "VARPTR ";
    keyword[65] = "USR ";
    keyword[66] = "ERL ";
    keyword[67] = "ERR ";
    keyword[68] = " STRING$";
    keyword[69] = " INSTR";
    keyword[70] = " POINT";
    keyword[71] = " TIME$ ";
    keyword[72] = " MEM ";
    keyword[73] = " INKEY$ ";
    keyword[74] = " THEN ";
    keyword[75] = " NOT ";
    keyword[76] = " STEP ";
    keyword[77] = "+";
    keyword[78] = "-";
    keyword[79] = "*";
    keyword[80] = "/";
    keyword[81] = "~";
    keyword[82] = " AND ";
    keyword[83] = " OR ";
    keyword[84] = ">";
    keyword[85] = "=";
    keyword[86] = "<";
    keyword[87] = " SGN";
    keyword[88] = " INT";
    keyword[89] = " ABS";
    keyword[90] = " FRE";
    keyword[91] = " INP";
    keyword[92] = " POS";
    keyword[93] = " SQR";
    keyword[94] = " RND";
    keyword[95] = " LOG";
    keyword[96] = " EXP";
    keyword[97] = " COS";
    keyword[98] = " SIN";
    keyword[99] = " TAN";
    keyword[100] = " ATN";
    keyword[101] = " PEEK";
    keyword[102] = " CVI";
    keyword[103] = " CVS";
    keyword[104] = " CVD";
    keyword[105] = " EOF";
    keyword[106] = " LOC";
    keyword[107] = " LOF";
    keyword[108] = " MKI$";
    keyword[109] = " MKS$";
    keyword[110] = " MKD$";
    keyword[111] = " CINT";
    keyword[112] = " CSNG";
    keyword[113] = " CDBL";
    keyword[114] = " FIX";
    keyword[115] = " LEN";
    keyword[116] = " STR$";
    keyword[117] = " VAL";
    keyword[118] = " ASC";
    keyword[119] = " CHR$";
    keyword[120] = " LEFT$";
    keyword[121] = " RIGHT$";
    keyword[122] = " MID$";
    keyword[123] = " ' ";
    return;
}

abort(msg)
char *msg;
{
    fputs(msg, stderr);
    putc(eol, stderr);
    exit(1);
}
