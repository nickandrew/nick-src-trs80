;
;int fgetc(fp)
;FILE *fp;
;
_FGETC
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	BIT	IS_TERM,(HL)
	JR	NZ,FG_01		;If terminal
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	ROM@GET
	LD	L,A
	LD	H,0
	RET	Z
	LD	HL,EOF
	RET
FG_01				;fgetc from terminal
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
FG_02	CALL	ROM@GET
	OR	A
	JR	Z,FG_02
	LD	L,A
	LD	H,0
	CP	04H		;eof char
	RET	NZ
	LD	HL,EOF
	RET
