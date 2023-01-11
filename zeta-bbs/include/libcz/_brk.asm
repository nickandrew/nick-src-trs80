;
;_brk: Set the end of the data space allocated to this program
_BRK
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;DE = endds
	LD	HL,(HIMEM)
	OR	A
	SBC	HL,DE
	JR	C,$C_20		;HIMEM - endds < 0
;
	LD	HL,(_BRKSIZE)
	OR	A
	SBC	HL,DE
	JR	NC,$C_19	;_BRKSIZE - endds >= 0

;Must zero the intermediate storage. HL = number of bytes to zero
	PUSH	HL
	POP	BC
	LD	HL,(_BRKSIZE)
$C_18
	LD	(HL),0
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,$C_18
$C_19
	EX	DE,HL		;HL = endds
	LD	(_BRKSIZE),HL
	LD	HL,0
	RET
;
$C_20
	LD	HL,-1		;Tried to allocate above HIMEM
	RET
;
