;main()
	COM	'<small c compiler output>'
*MOD
;{
_MAIN:
	DEBUG	'main'
;    int    e,f;
;    char   ( *(func()) ) [6];
;    char   (*x)[4];
;
;    x = func(1,3);
	PUSH	BC
	PUSH	BC
	PUSH	BC
	LD	HL,0
	ADD	HL,SP
	PUSH	HL
	LD	HL,1
	PUSH	HL
	LD	HL,3
	PUSH	HL
	CALL	_FUNC
	POP	BC
	POP	BC
	POP	DE
	CALL	CCPINT
;    (*x)[2] = 't';
	LD	HL,0
	ADD	HL,SP
	CALL	CCGINT
	INC	HL
	INC	HL
	PUSH	HL
	LD	HL,116
	POP	DE
	LD	A,L
	LD	(DE),A
;}
	POP	BC
	POP	BC
	POP	BC
	RET
;
;char (*(func(e,f)))[6]
;int  e,f;
_FUNC:
	DEBUG	'func'
;{
;   puts("This is func\n");
	LD	HL,$?2+0
	PUSH	HL
	CALL	_PUTS
	POP	BC
;   return e;
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	RET
;}
$?2:	DEFB	84,104,105,115,32,105,115,32,102,117
	DEFB	110,99,13,0
;
	END
