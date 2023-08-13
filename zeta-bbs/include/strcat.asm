;
;strcat: Concatenate HL string on end of DE string.
STRCAT
	LD	A,(DE)
	OR	A
	JR	Z,_STRCAT_1
	INC	DE
	JR	STRCAT
_STRCAT_1	LD	A,(HL)
	LD	(DE),A
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	_STRCAT_1
