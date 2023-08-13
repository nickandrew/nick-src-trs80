;
;strlen: Find (in HL) the length of the string in DE
STRLEN
	LD	HL,0
_STRLEN_1	LD	A,(DE)
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	_STRLEN_1
