/*     Languages & Processors
**
**     lls.h  - Low level scan header
**
**     Nick Andrew, 8425464   (zeta@amdahl)
**
*/

#define INVALID	0
#define BLANK		0
#define PLUS		1
#define MINUS		2
#define STAR		3
#define SLASH		4
#define EQUAL		5
#define NOTEQUAL	6
#define LESS		7
#define LESSEQUAL	8
#define GREATER		9
#define GREATEREQUAL	10
#define GETS		11
#define SEMICOLON	12
#define LEFT		13
#define RIGHT		14
#define COMMA		15
#define NAME		16
#define CHARSTR		17
#define NUMBER		18
#define ENDFILE		19

#define MAXDIGITS       9
#define STRLENGTH       80
#define LINESIZE        81

extern error();
