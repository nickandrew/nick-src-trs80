;extern char *line;
	COM	'<small c compiler output>'
*MOD
;
;main(argc,argv)
;int  argc;
_MAIN:
	DEBUG	'main'
;char *argv[];
;{
;argc=2;
	LD	HL,4
	ADD	HL,SP
	PUSH	HL
	LD	HL,2
	POP	DE
	CALL	CCPINT
;}
	RET
	END
