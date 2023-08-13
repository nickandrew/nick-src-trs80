;
;strcmp_ci - Case Independant STRCMP
STRCMP_CI:
	CALL	CI_CMP
	RET	NZ
	LD	A,(HL)
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	STRCMP_CI
