;
;strcpy(out,in)
;char *out,*in;
;
_STRCPY
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
$C_05	LD	A,(BC)
	LD	(DE),A
	INC	BC
	INC	DE
	OR	A
	JR	NZ,$C_05
	RET
