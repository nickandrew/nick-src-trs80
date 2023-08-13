;
;fputs: Put a string to a device or file.
FPUTS
	LD	A,(HL)
	OR	A
	RET	Z
	CALL	ROM@PUT
	RET	NZ
	INC	HL
	JR	FPUTS
