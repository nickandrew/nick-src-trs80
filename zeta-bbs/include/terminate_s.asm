;
;terminate_s: Put 00H byte on the end of a string.
TERMINATE_S
	LD	A,(HL)
	OR	A
	RET	Z
	CP	ETX
	JR	Z,_TERM_01
	CP	CR
	JR	Z,_TERM_01
	INC	HL
	JR	TERMINATE_S
_TERM_01	LD	(HL),0
	RET
;
