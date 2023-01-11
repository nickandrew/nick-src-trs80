;
;fgets(s,n,ioptr)
;char *s;
;int  n;
;FILE *ioptr;
_FGETS
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;DE = ioptr
	LD	(FG_IO),DE
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;BC = n
	LD	(FG_N),BC
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL		;HL = s
	LD	(FG_S),HL
	LD	A,B
	OR	C
	JP	Z,FG_8		;if count = 0
FG_1
	DEC	BC
	LD	A,B
	OR	C
	JP	Z,FG_8
	PUSH	HL
	PUSH	BC
	LD	DE,(FG_IO)
	PUSH	DE
	CALL	_FGETC
	POP	IY
	POP	BC
	EX	DE,HL		;de = char or EOF
	LD	HL,EOF
	OR	A
	SBC	HL,DE
	JR	NZ,FG_2
;Eof seen....
	POP	HL		;string *
FG_8	LD	(HL),0
	LD	DE,(FG_S)
	OR	A
	SBC	HL,DE		;if hl = 0 then return HL
	RET	Z
	EX	DE,HL		;else return S (de)
	RET
;
FG_2
	POP	HL		;hl = string *
	LD	(HL),E
	INC	HL
	LD	A,E
	CP	0DH		;NL,CR, whatever
	JR	NZ,FG_1
	JR	FG_8
;
FG_N	DEFW	0
FG_IO	DEFW	0
FG_S	DEFW	0
;
