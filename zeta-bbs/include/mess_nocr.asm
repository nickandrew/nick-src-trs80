;
;mess_nocr: print a message UNTIL a CR is seen.
MESS_NOCR:
	LD	A,(HL)
	OR	A
	RET	Z
	CP	ETX
	RET	Z
	CP	CR
	RET	Z
	CALL	ROM@PUT
	INC	HL
	JR	MESS_NOCR
