;
;int feof(fp)
;FILE *fp;
_FEOF
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)	;DE = fp (pointer to fdarray)
	EX	DE,HL
	BIT	IS_TERM,(HL)
	JR	NZ,$C_17
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	POP	IX
	LD	A,(IX+11)	;Next high
	CP	(IX+13)		;EOF  high
	JR	NZ,$C_15
	LD	A,(IX+10)	;Next mid
	CP	(IX+12)		;EOF  mid
	JR	NZ,$C_15
	LD	A,(IX+5)	;Next low
	CP	(IX+8)		;EOF  low
	JR	NZ,$C_15
	LD	HL,1
	RET
$C_15	LD	HL,1
	RET	NC
$C_17	LD	HL,0
	RET
