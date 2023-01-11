;
;mess_0: Print a message until NULL terminator.
MESS_0
	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$PUT
	INC	HL
	JR	MESS_0
;
