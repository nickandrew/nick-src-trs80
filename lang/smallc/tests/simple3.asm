;char  *charptr;
	COM	'<small c compiler output>'
*MOD
_CHARPTR:
	DC	2,0
;
;main()
;{
_MAIN:
	DEBUG	'main'
;   char *var1[7];
;   int  var2,var3;
;   charptr=var1[-2];
	LD	HL,-18
	ADD	HL,SP
	LD	SP,HL
	LD	HL,4
	ADD	HL,SP
	LD	DE,-4
	ADD	HL,DE
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr = var2;
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr = var3;
	LD	HL,0
	ADD	HL,SP
	CALL	CCGINT
	LD	(_CHARPTR),HL
;
;   charptr=var1[-1];
	LD	HL,4
	ADD	HL,SP
	DEC	HL
	DEC	HL
	CALL	CCGINT
	LD	(_CHARPTR),HL
;
;   charptr=var1[0];
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	LD	(_CHARPTR),HL
;
;   charptr=var1[1];
	LD	HL,4
	ADD	HL,SP
	INC	HL
	INC	HL
	CALL	CCGINT
	LD	(_CHARPTR),HL
;
;   charptr=var1[2];
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
