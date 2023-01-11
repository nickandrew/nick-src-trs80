;
;MESS_CR: Print a CR terminated msg on device.
MESS_CR
	LD	A,(HL)
	CP	ETX
	RET	Z
	OR	A
	RET	Z
	CALL	$PUT
	LD	A,(HL)
	INC	HL
	CP	CR
	JR	NZ,MESS_CR
	RET
;
