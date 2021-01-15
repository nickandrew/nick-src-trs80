;char  *charptr;
	COM	'<small c compiler output>'
*MOD
_CHARPTR:
	DC	2,0
;
;main(argc,argv)
;char *argv[];
_MAIN:
	DEBUG	'main'
;int argc;
;{
;   char *fred[7];
;   int  var1,var2;
;   charptr=argv[-2];
	LD	HL,-18
	ADD	HL,SP
	LD	SP,HL
	LD	HL,20
	ADD	HL,SP
	CALL	CCGINT
	LD	DE,-4
	ADD	HL,DE
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr=fred[-2];
	LD	HL,4
	ADD	HL,SP
	LD	DE,-4
	ADD	HL,DE
	CALL	CCGINT
	LD	(_CHARPTR),HL
;
;   charptr=argv[-1];
	LD	HL,20
	ADD	HL,SP
	CALL	CCGINT
	DEC	HL
	DEC	HL
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr=fred[-2];
	LD	HL,4
	ADD	HL,SP
	LD	DE,-4
	ADD	HL,DE
	CALL	CCGINT
	LD	(_CHARPTR),HL
;
;   charptr=argv[0];
	LD	HL,20
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr=fred[0];
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	LD	(_CHARPTR),HL
;
;   charptr=argv[1];
	LD	HL,20
	ADD	HL,SP
	CALL	CCGINT
	INC	HL
	INC	HL
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr=fred[1];
	LD	HL,4
	ADD	HL,SP
	INC	HL
	INC	HL
	CALL	CCGINT
	LD	(_CHARPTR),HL
;
;   charptr=argv[2];
	LD	HL,20
	ADD	HL,SP
	CALL	CCGINT
	LD	DE,4
	ADD	HL,DE
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr=fred[2];
	LD	HL,4
	ADD	HL,SP
	LD	DE,4
	ADD	HL,DE
	CALL	CCGINT
	LD	(_CHARPTR),HL
;}
	LD	HL,18
	ADD	HL,SP
	LD	SP,HL
	RET
;
	END
