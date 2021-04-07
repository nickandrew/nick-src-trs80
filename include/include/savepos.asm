;savepos.asm: Savepos & setpos routines - file pointer first arg
;Last updated: 22-May-89
;
;  void savepos(FILE *fp, char buf[3]);
;  int setpos(FILE *fp, char buf[3]);
;
_SAVEPOS
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc = buffer
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = fp
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = fcb
	PUSH	DE
	POP	IX
	LD	A,(IX+5)	;Low
	LD	(BC),A
	INC	BC
	LD	A,(IX+10)	;Middle
	LD	(BC),A
	INC	BC
	LD	A,(IX+11)	;High
	LD	(BC),A
	LD	HL,0
	RET
;
_SETPOS
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc = buffer
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = fp
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = fcb
	PUSH	BC
	POP	IX
	LD	A,(IX+0)	;Low
	LD	C,A
	LD	A,(IX+1)	;Medium
	LD	L,A
	LD	A,(IX+2)	;High
	LD	H,A
	CALL	DOS_POS_RBA
	LD	HL,-1
	RET	NZ
	LD	HL,0
	RET
;
;End of savepos.asm
