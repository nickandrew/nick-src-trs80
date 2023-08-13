;
;Fgets: get a string of length in 'B' (max 256)
FGETS
_FG1	CALL	ROM@GET
	RET	NZ
	LD	(HL),A
	OR	A
	JR	Z,_FG2
	CP	CR
	JR	Z,_FG2
	INC	HL
	DJNZ	_FG1
	LD	(HL),0
	RET
_FG2	LD	(HL),0
	RET
