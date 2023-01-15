;setpos.asm: Setpos & Savepos routines - with file pointer last
;Last updated: 20-Jul-87
;
;
;  void savepos(char buf[3], FILE *fp)
;  intsetpos(char buf[3], FILE *fp)
;
_SAVEPOS
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = fp
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc = buffer
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	POP	IX
	LD	A,(IX+5)
	LD	(BC),A
	INC	BC
	LD	A,(IX+10)
	LD	(BC),A
	INC	BC
	LD	A,(IX+11)
	LD	(BC),A
	INC	BC		;redundant
	LD	HL,0
	RET
;
_SETPOS
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,(BC)
	INC	BC
	PUSH	AF
	LD	A,(BC)
	LD	L,A
	INC	BC
	LD	A,(BC)
	LD	H,A
	POP	AF
	LD	C,A
	CALL	DOS_POS_RBA
	LD	HL,EOF
	RET	NZ
	LD	HL,0
	RET
;
