;/* simple.c ... a simple c prog to test C80 / Sc.
; * Nick, '87
; */
	COM	'<small c compiler output>'
*MOD
;
;char **charptrptr;
_CHARPTRP:
	DC	2,0
;char  *charptr;
_CHARPTR:
	DC	2,0
;char   charv;
_CHARV:
	DC	1,0
;
;main(argc,argv)
;char *argv[];
_MAIN:
	DEBUG	'main'
;int argc;
;{
;   charptr=argv[-2];
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	LD	DE,-4
	ADD	HL,DE
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr=argv[-1];
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	DEC	HL
	DEC	HL
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr=argv[0];
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr=argv[1];
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	INC	HL
	INC	HL
	CALL	CCGINT
	LD	(_CHARPTR),HL
;   charptr=argv[2];
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	LD	DE,4
	ADD	HL,DE
	CALL	CCGINT
	LD	(_CHARPTR),HL
;}
	RET
;
	END
