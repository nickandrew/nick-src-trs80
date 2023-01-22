;reada: Read a line of text from the keyboard.
;Last updated: 23-Jan-88
;
;reada(line)
;char *line;
_READA
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	B,78
	CALL	ROM@WAIT_LINE
	JP	C,_READA
READA1	LD	A,(HL)
	INC	HL
	CP	0DH
	JR	NZ,READA1
	DEC	HL
	LD	(HL),0
	RET
;
