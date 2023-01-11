;
;str_cmp: compare two strings for equality.
STR_CMP
	LD	A,(DE)
	CP	(HL)
	RET	NZ
	OR	A
	RET	Z
	CP	ETX
	RET	Z
	CP	CR
	RET	Z
	INC	HL
	INC	DE
	JR	STR_CMP
;
