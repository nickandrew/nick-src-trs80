; @(#) malloc.asm 17 Jun 90 - Allocate memory.
;
;char   *malloc(num);
_MALLOC
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = amount to allocate
	LD	HL,(_BRKSIZE)
	PUSH	HL		;old brksize
	ADD	HL,DE
	PUSH	HL		;HL = proposed new brksize
	POP	BC		;BC = proposed new brksize
	EX	DE,HL
	LD	HL,(HIMEM)
	OR	A
	SBC	HL,DE		;Is it >HIMEM
	POP	DE		;DE = old brksize
	LD	HL,0
	RET	C		;Not enough memory
	EX	DE,HL		;HL = old brksize
	PUSH	HL
	LD	(_BRKSIZE),BC
	CALL	FIX_PROG_END
	POP	HL		;HL = old brksize
	RET
;
;end of malloc.asm
