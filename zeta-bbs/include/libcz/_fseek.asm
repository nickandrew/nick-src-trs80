;
;fseek(fp,offset,n)
;FILE *fp;
;int offset;   /* should be long */
;int n;
_FSEEK
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = N
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc = offset
	INC	HL
	PUSH	BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc = ioptr
	LD	HL,FD_FCBPTR
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc = fcb
	PUSH	BC
	POP	IX
	LD	A,E
	OR	A
	JR	Z,FSE_0
	DEC	A
	JR	Z,FSE_1
	LD	C,(IX+13)	;eof high
	LD	H,(IX+12)	;eof mid
	LD	L,(IX+8)	;eof low
	JR	FSE_N
FSE_1
	LD	C,(IX+11)
	LD	H,(IX+10)
	LD	L,(IX+5)
	JR	FSE_N
FSE_0
	LD	C,0
	LD	H,C
	LD	L,C
FSE_N
	POP	DE
	LD	B,0
	BIT	7,D	;check if signed
	JR	Z,FSE_N1
	LD	B,0FFH
FSE_N1
	ADD	HL,DE
	LD	A,B
	ADC	A,C
	LD	C,L
	LD	L,H
	LD	H,A
	PUSH	IX
	POP	DE
	CALL	DOS_POS_RBA
;Return eof value
	PUSH	DE
	POP	IX
	LD	L,(IX+5)
	LD	H,(IX+10)
	RET
