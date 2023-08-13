;
;Strcpy: Copy string at HL to DE up to null.
STRCPY:
	LD	A,(HL)
	LD	(DE),A
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	STRCPY
