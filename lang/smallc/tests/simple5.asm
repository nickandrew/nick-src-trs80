;/* simple5 .... another simple program */
	COM	'<small c compiler output>'
*MOD
;#define EOF -1
;extern int f();
;char a[5];
_A:
	DC	5,0
;char *b[3];
_B:
	DC	3,0
;char *(c[5]);
_C:
	DC	5,0
;int  **d;
_D:
	DC	2,0
	END
