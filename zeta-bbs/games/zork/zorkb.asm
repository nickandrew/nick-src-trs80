;ZorkB/src
;Zork 1 for TRS-80 I, File 2.
	INC	HL
	DEC	A
	JP	M,H4A14
	CALL	NZ,CRASH
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	EX	DE,HL
	JP	H45D7
H4A14	LD	L,(HL)
	LD	H,0
	JP	H45D7
H4A1A	CALL	H4EED
H4A1D	CALL	H4F04
	LD	B,A
	LD	A,(H588B)
	CP	B
	JP	Z,H4A31
	JP	NC,H45D3
	CALL	H4F0F
	JP	H4A1D
H4A31	INC	HL
	EX	DE,HL
	LD	HL,(H58A4)
	LD	A,E
	SUB	L
	LD	L,A
	LD	A,D
	SBC	A,H
	LD	H,A
	JP	H45D7
H4A3F	CALL	H4EED
	LD	A,(H588B)
	OR	A
	JP	Z,H4A5D
H4A49	CALL	H4F04
	LD	B,A
	LD	A,(H588B)
	CP	B
	JP	Z,H4A63
	JP	NC,H45D3
	CALL	H4F0F
	JP	H4A49
H4A5D	CALL	H4F04
	JP	H45D4
H4A63	CALL	H4F0F
	JP	H4A5D
H4A69	CALL	H4F38
	ADD	HL,DE
	JP	H45D7
H4A70	CALL	H4F38
	LD	A,E
	SUB	L
	LD	L,A
	LD	A,D
	SBC	A,H
	LD	H,A
	JP	H45D7
H4A7C	CALL	H4F38
	EX	DE,HL
	CALL	H4E9B
	PUSH	HL
	LD	HL,0002H
	CALL	H4F48
	JP	Z,H4AA3
	LD	HL,0004H
	CALL	H4F48
	JP	Z,H4AA0
	POP	HL
	CALL	H4E3F
H4A9A	CALL	H4EA8
	JP	H45D7
H4AA0	POP	HL
	ADD	HL,HL
	PUSH	HL
H4AA3	POP	HL
	ADD	HL,HL
	JP	H4A9A
H4AA8	CALL	H4F38
	EX	DE,HL
	CALL	H4E9B
	PUSH	HL
	LD	HL,0002H
	CALL	H4F48
	JP	Z,H4AC9
	LD	HL,0004H
	CALL	H4F48
	JP	Z,H4AD0
	POP	HL
	CALL	H4E68
	JP	H4A9A
H4AC9	POP	HL
H4ACA	CALL	H4AD7
	JP	H4A9A
H4AD0	POP	HL
	CALL	H4AD7
	JP	H4ACA
H4AD7	OR	A
	LD	A,H
	RRA
	LD	H,A
	LD	A,L
	RRA
	LD	L,A
	RET
H4ADF	CALL	H4F38
	EX	DE,HL
	CALL	H4E9B
	CALL	H4E68
	EX	DE,HL
	JP	H45D7
H4AED	LD	HL,(H5889)
	EX	DE,HL
	LD	A,(H5891)
	LD	B,A
	DEC	B
	CALL	Z,CRASH
	LD	HL,(H588B)
	CALL	H4B0E
	LD	HL,(H588D)
	CALL	H4B0E
	LD	HL,(H588F)
	CALL	H4B0E
	CALL	CRASH
H4B0E	CALL	H4F48
	POP	HL
	JP	Z,ENTRY
	DEC	B
	JP	Z,H460F
	JP	(HL)
H4B1A	LD	HL,(H5889)
	LD	A,H
	OR	L
	JP	Z,H45D7
	LD	HL,(H587E)
	CALL	APUSH
	LD	HL,(H587C)
	CALL	APUSH
	LD	HL,(H5873)
	CALL	APUSH
	LD	HL,(H5872)
	PUSH	HL
	XOR	A
	LD	(H5899),A
	LD	H,A
	LD	A,(H5889)
	LD	L,A
	ADD	HL,HL
	LD	(H5873),HL
	LD	A,(H588A)
	LD	(H5872),A
	CALL	H4F7D
	POP	HL
	LD	B,A
	LD	H,A
	PUSH	HL
	LD	HL,H5854
	OR	A
	JP	Z,H4B77
H4B59	PUSH	BC
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	EX	DE,HL
	CALL	APUSH
	DEC	DE
	PUSH	DE
	CALL	H4F7D
	LD	D,A
	PUSH	DE
	CALL	H4F7D
	POP	DE
	LD	E,A
	POP	HL
	LD	(HL),D
	INC	HL
	LD	(HL),E
	INC	HL
	POP	BC
	DEC	B
	JP	NZ,H4B59
H4B77	LD	A,(H5891)
	LD	B,A
	DEC	B
	JP	Z,H4B93
	LD	HL,H588B
	LD	DE,H5854
H4B85	LD	A,(HL)
	INC	HL
	INC	DE
	LD	(DE),A
	DEC	DE
	LD	A,(HL)
	INC	HL
	LD	(DE),A
	INC	DE
	INC	DE
	DEC	B
	JP	NZ,H4B85
H4B93	POP	HL
	CALL	APUSH
	LD	A,(H5879)
	LD	(H587E),A
	LD	HL,(H587A)
	LD	(H587C),HL
	JP	H449E
H4BA6	LD	HL,(H588B)
	ADD	HL,HL
	EX	DE,HL
	LD	HL,(H5889)
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(H58A4)
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(H588D)
	EX	DE,HL
	LD	(HL),D
	INC	HL
	LD	(HL),E
	JP	H449E
H4BBF	LD	HL,(H588B)
	EX	DE,HL
	LD	HL,(H5889)
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(H58A4)
	ADD	HL,DE
	LD	A,(H588D)
	LD	(HL),A
	JP	H449E
H4BD3	CALL	H4EED
H4BD6	CALL	H4F04
	LD	B,A
	LD	A,(H588B)
	CP	B
	JP	Z,H4BEA
	CALL	NC,CRASH
	CALL	H4F0F
	JP	H4BD6
H4BEA	CALL	H4F08
	INC	HL
	EX	DE,HL
	LD	HL,(H588D)
	DEC	A
	JP	M,H4C00
	CALL	NZ,CRASH
	EX	DE,HL
	LD	(HL),D
	INC	HL
	LD	(HL),E
	JP	H449E
H4C00	EX	DE,HL
	LD	(HL),E
	JP	H449E
H4C05	CALL	H54D8
	CALL	H4E11
	LD	HL,(H58A4)
	EX	DE,HL
	LD	HL,(H5889)
	ADD	HL,DE
	LD	(H5889),HL
	LD	HL,(H588B)
	ADD	HL,DE
	LD	(H588B),HL
	CALL	H574D
	LD	B,A
	LD	C,0
	LD	HL,(H588B)
	INC	HL
	LD	(HL),0
	INC	HL
	LD	(H5975),HL
	LD	HL,(H5889)
	INC	HL
H4C31	PUSH	HL
	LD	HL,(H588B)
	LD	A,'x'
	INC	HL
	CP	(HL)
	POP	HL
	JP	Z,H449E
	LD	A,B
	OR	C
	JP	Z,H449E
	LD	A,C
	CP	6
	CALL	Z,H4CCB
	LD	A,C
	OR	A
	JP	NZ,H4C7D
	PUSH	HL
	LD	D,6
	LD	HL,H587F
H4C53	LD	(HL),0
	INC	HL
	DEC	D
	JP	NZ,H4C53
	POP	HL
	LD	A,(H5889)
	LD	D,A
	LD	A,L
	SUB	D
	PUSH	HL
	LD	HL,(H5975)
	INC	HL
	INC	HL
	INC	HL
	LD	(HL),A
	POP	HL
	LD	A,(HL)
	CALL	H4CF2
	JP	C,H4C9A
	LD	A,(HL)
	CALL	H4CD9
	JP	NC,H4C7D
	INC	HL
	DEC	B
	JP	H4C31
H4C7D	LD	A,B
	OR	A
	JP	Z,H4CA0
	LD	A,(HL)
	CALL	H4CD9
	JP	C,H4CA0
	LD	D,(HL)
	PUSH	HL
	LD	HL,H587F
	LD	A,C
	CALL	ADDHLA
	LD	(HL),D
	POP	HL
	DEC	B
	INC	C
	INC	HL
	JP	H4C31
H4C9A	LD	(H587F),A
	INC	C
	DEC	B
	INC	HL
H4CA0	LD	A,C
	OR	A
	JP	Z,H4C31
	PUSH	HL
	PUSH	BC
	LD	HL,(H5975)
	INC	HL
	INC	HL
	LD	(HL),C
	CALL	H5242
	CALL	H4D17
	LD	HL,(H5975)
	LD	(HL),D
	INC	HL
	LD	(HL),E
	INC	HL
	INC	HL
	INC	HL
	LD	(H5975),HL
	LD	HL,(H588B)
	INC	HL
	INC	(HL)
	POP	BC
	POP	HL
	LD	C,0
	JP	H4C31
H4CCB	LD	A,B
	OR	A
	RET	Z
	LD	A,(HL)
	CALL	H4CD9
	RET	C
	INC	HL
	DEC	B
	INC	C
	JP	H4CCB
H4CD9	CALL	H4CF2
	RET	C
	PUSH	HL
	LD	HL,H4D0F
	LD	D,8
H4CE3	CP	(HL)
	JP	Z,H4CEF
	INC	HL
	DEC	D
	JP	NZ,H4CE3
H4CEC	POP	HL
	OR	A
	RET
H4CEF	POP	HL
	SCF
	RET
H4CF2	PUSH	HL
	CALL	H4D00
	LD	D,(HL)
	DEC	D
	INC	D
	JP	Z,H4CEC
	INC	HL
	JP	H4CE3
H4D00	LD	HL,(H58A4)
	LD	DE,0008H
	ADD	HL,DE
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	LD	HL,(H58A4)
	ADD	HL,DE
	RET
H4D0F	DEFM	' .,?'
	DEFW	0A0DH
	DEFW	0C09H
H4D17	CALL	H4D00
	LD	A,(HL)
	INC	HL
	CALL	ADDHLA
	LD	A,(HL)
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	C,A
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	A,(H5970)
	LD	B,A
	JP	H4D36
H4D31	LD	A,(HL)
	CP	B
	JP	NC,H4D48
H4D36	LD	A,L
	ADD	A,C
	LD	L,A
	LD	A,H
	ADC	A,0
	LD	H,A
	LD	A,E
	SUB	10H
	LD	E,A
	JP	NC,H4D31
	DEC	D
	JP	P,H4D31
H4D48	LD	A,L
	SUB	C
	LD	L,A
	LD	A,H
	SBC	A,0
	LD	H,A
	LD	A,E
	ADD	A,10H
	LD	E,A
	LD	A,D
	ADC	A,0
	LD	D,A
	LD	A,C
	RRCA
	RRCA
	RRCA
	RRCA
	LD	C,A
H4D5D	LD	A,(H5970)
	CP	(HL)
	JP	C,H4D95
	JP	NZ,H4D8B
	INC	HL
	LD	A,(H596F)
	CP	(HL)
	JP	C,H4D95
	JP	NZ,H4D8A
	INC	HL
	LD	A,(H5972)
	CP	(HL)
	JP	C,H4D95
	JP	NZ,H4D89
	INC	HL
	LD	A,(H5971)
	CP	(HL)
	JP	C,H4D95
	JP	Z,H4D99
	DEC	HL
H4D89	DEC	HL
H4D8A	DEC	HL
H4D8B	LD	A,C
	CALL	ADDHLA
	DEC	DE
	LD	A,D
	OR	E
	JP	NZ,H4D5D
H4D95	LD	DE,0000H
	RET
H4D99	DEC	HL
	DEC	HL
	DEC	HL
	EX	DE,HL
	LD	HL,(H58A4)
	LD	A,E
	SUB	L
	LD	E,A
	LD	A,D
	SBC	A,H
	LD	D,A
	RET
H4DA7	LD	A,(H5889)
	LD	C,A
	CALL	VDUOUT_1
	JP	H449E
H4DB1	LD	HL,(H5889)
	CALL	H4DBA
	JP	H449E
H4DBA	LD	A,H
	OR	A
	CALL	M,H4DE8
	LD	B,0
H4DC1	LD	A,H
	OR	L
	JP	Z,H4DD1
	LD	DE,000AH
	CALL	H4E68
	PUSH	DE
	INC	B
	JP	H4DC1
H4DD1	XOR	A
	ADD	A,B
	JP	Z,H4DE3
H4DD6	POP	DE
	LD	A,'0'
	ADD	A,E
	LD	C,A
	CALL	VDUOUT_1
	DEC	B
	JP	NZ,H4DD6
	RET
H4DE3	LD	C,'0'
	JP	VDUOUT_1
H4DE8	LD	C,'-'
	CALL	VDUOUT_1
	JP	H4EAE
H4DF0	LD	HL,(H5889)
	EX	DE,HL
	CALL	H4E11
	CALL	H4E68
	EX	DE,HL
	INC	HL
	JP	H45D7
H4DFF	LD	HL,(H5889)
	CALL	APUSH
	JP	H449E
H4E08	CALL	APOP
	LD	A,(H5889)
	JP	H4974
H4E11	PUSH	BC
	LD	C,2
H4E14	LD	B,8
	LD	HL,H5875
	LD	A,(HL)
H4E1A	RLCA
	RLCA
	RLCA
	XOR	(HL)
	RLA
	RLA
	LD	HL,H5875
	LD	A,(HL)
	RLA
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	RLA
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	RLA
	LD	(HL),A
	INC	HL
	LD	A,(HL)
	RLA
	LD	(HL),A
	DEC	B
	JP	NZ,H4E1A
	DEC	C
	JP	NZ,H4E14
	POP	BC
	LD	HL,(H5877)
	RET
H4E3F	PUSH	BC
	LD	BC,0000H
	LD	A,10H
H4E45	PUSH	AF
	LD	A,E
	AND	1
	JP	Z,H4E51
	PUSH	HL
	ADD	HL,BC
	LD	B,H
	LD	C,L
	POP	HL
H4E51	LD	A,B
	RRA
	LD	B,A
	LD	A,C
	RRA
	LD	C,A
	LD	A,D
	RRA
	LD	D,A
	LD	A,E
	RRA
	LD	E,A
	POP	AF
	DEC	A
	JP	NZ,H4E45
	LD	H,D
	LD	L,E
	LD	D,B
	LD	E,C
	POP	BC
	RET
H4E68	PUSH	BC
	LD	B,H
	LD	C,L
	LD	A,D
	CPL
	LD	D,A
	LD	A,E
	CPL
	LD	E,A
	INC	DE
	LD	HL,0000H
	LD	A,11H
H4E77	PUSH	HL
	ADD	HL,DE
	JP	NC,H4E7D
	EX	(SP),HL
H4E7D	POP	HL
	PUSH	AF
	LD	A,C
	RLA
	LD	C,A
	LD	A,B
	RLA
	LD	B,A
	LD	A,L
	RLA
	LD	L,A
	LD	A,H
	RLA
	LD	H,A
	POP	AF
	DEC	A
	JP	NZ,H4E77
	OR	A
	LD	A,H
	RRA
	LD	D,A
	LD	A,L
	RRA
	LD	E,A
	LD	H,B
	LD	L,C
	POP	BC
	RET
H4E9B	XOR	A
	LD	(H5888),A
	CALL	H4EB6
	EX	DE,HL
	CALL	H4EB6
	EX	DE,HL
	RET
H4EA8	LD	A,(H5888)
	AND	1
	RET	Z
H4EAE	XOR	A
	SUB	L
	LD	L,A
	LD	A,0
	SBC	A,H
	LD	H,A
	RET
H4EB6	LD	A,H
	OR	A
	RET	P
	LD	A,(H5888)
	INC	A
	LD	(H5888),A
	JP	H4EAE
H4EC3	LD	A,(H5889)
	CALL	H4F17
	LD	A,(H588B)
	CP	10H
	JP	C,H4ED5
	SUB	10H
	INC	HL
	INC	HL
H4ED5	PUSH	HL
	LD	B,A
	LD	A,0FH
	SUB	B
	LD	HL,0001H
H4EDD	JP	Z,H4EE5
	ADD	HL,HL
	DEC	A
	JP	H4EDD
H4EE5	LD	B,H
	LD	C,L
	POP	HL
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	DEC	HL
	RET
H4EED	LD	A,(H5889)
	CALL	H4F17
	LD	DE,0007H
	ADD	HL,DE
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	LD	HL,(H58A4)
	ADD	HL,DE
	LD	A,(HL)
	ADD	A,A
	INC	A
	JP	ADDHLA
H4F04	LD	A,(HL)
	AND	1FH
	RET
H4F08	LD	A,(HL)
	RLCA
	RLCA
	RLCA
	AND	7
	RET
H4F0F	CALL	H4F08
	ADD	A,2
	JP	ADDHLA
H4F17	PUSH	DE
	LD	L,A
	LD	H,0
	LD	D,H
	LD	E,L
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	LD	DE,0035H
	ADD	HL,DE
	PUSH	HL
	LD	HL,(H58A4)
	LD	DE,000AH
	ADD	HL,DE
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	LD	HL,(H58A4)
	ADD	HL,DE
	POP	DE
	ADD	HL,DE
	POP	DE
	RET
H4F38	LD	HL,(H5889)
	EX	DE,HL
	LD	HL,(H588B)
	RET
H4F40	LD	A,D
	XOR	H
	JP	P,H4F48
	LD	A,H
	CP	D
	RET
H4F48	LD	A,D
	CP	H
	RET	NZ
	LD	A,L
	CP	E
	CCF
	RET
APUSH	PUSH	DE
	EX	DE,HL
	LD	HL,(H587A)
	DEC	HL
	LD	(HL),E
	DEC	HL
	LD	(HL),D
	LD	(H587A),HL
	LD	HL,H5879
	INC	(HL)
	LD	A,(HL)
	CP	0C0H
	CALL	Z,CRASH
	EX	DE,HL
	POP	DE
	RET
APOP	PUSH	DE
	LD	HL,(H587A)
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	(H587A),HL
	LD	HL,H5879
	DEC	(HL)
	CALL	Z,CRASH
	EX	DE,HL
	POP	DE
	RET
H4F7D	LD	A,(H5899)
	OR	A
	JP	Z,H4FAA
	LD	HL,(H5897)
	LD	B,(HL)
	INC	HL
	LD	(H5897),HL
	LD	HL,(H5873)
	INC	L
	LD	(H5873),HL
	LD	A,B
	RET	NZ
	LD	A,H
	INC	H
	LD	(H5873),HL
	OR	A
	LD	A,B
	RET	Z
	XOR	A
	LD	(H5874),A
	LD	(H5899),A
	LD	HL,H5872
	INC	(HL)
	LD	A,B
	RET
H4FAA	LD	A,(H5872)
	LD	HL,H58A6
	CP	(HL)
	LD	HL,(H58A4)
	JP	C,H4FC9
	CALL	LOOKUP1
	LD	(H589A),A
	JP	C,H4FDC
H4FC0	CALL	H50DF
	LD	A,(H589A)
	LD	HL,(H58A2)
H4FC9	ADD	A,A
	ADD	A,H
	LD	H,A
	EX	DE,HL
	LD	HL,(H5873)
	ADD	HL,DE
	LD	(H5897),HL
	LD	A,0FFH
	LD	(H5899),A
	JP	H4F7D
H4FDC	LD	HL,H58A1
	CP	(HL)
	JP	NZ,H4FE9
	LD	B,A
	XOR	A
	LD	(H58A0),A
	LD	A,B
H4FE9	LD	HL,(H58A2)
	ADD	A,A
	ADD	A,H
	LD	H,A
	LD	A,(H5872)
	CALL	GETBLOCK
	LD	A,(H589A)
	LD	B,A
	LD	HL,H58A7
	CALL	ADDHLA
	LD	A,(H5872)
	LD	(HL),A
	LD	A,B
	JP	H4FC0
H5007	LD	A,H
	OR	A
	RRA
	LD	(H589B),A
H500D	LD	A,H
	AND	1
	LD	H,A
	LD	(H589C),HL
	XOR	A
	LD	(H58A0),A
	RET
H5019	LD	A,H
	LD	(H589B),A
	ADD	HL,HL
	JP	H500D
H5021	XOR	A
	LD	(H58A0),A
	LD	A,(H5969)
	LD	(H58A1),A
	CALL	H50B2
	CALL	H50DF
	LD	A,(H58A1)
	LD	B,A
	LD	HL,(H58A2)
	ADD	A,A
	ADD	A,H
	LD	H,A
	LD	(H589E),HL
	LD	A,B
	LD	HL,H58A7
	CALL	ADDHLA
	LD	(HL),0
	RET
H5048	CALL	H5053
	PUSH	AF
	CALL	H5053
	LD	L,A
	POP	AF
	LD	H,A
	RET
H5053	LD	A,(H58A0)
	OR	A
	JP	Z,H5080
	LD	HL,(H589E)
	LD	B,(HL)
	INC	HL
	LD	(H589E),HL
	LD	HL,(H589C)
	INC	L
	LD	(H589C),HL
	LD	A,B
	RET	NZ
	LD	A,H
	INC	H
	LD	(H589C),HL
	OR	A
	LD	A,B
	RET	Z
	XOR	A
	LD	(H589D),A
	LD	(H58A0),A
	LD	HL,H589B
	INC	(HL)
	LD	A,B
	RET
H5080	LD	A,(H589B)
	LD	HL,H58A6
	CP	(HL)
	LD	HL,(H58A4)
	JP	C,H509F
	CALL	LOOKUP1
	LD	(H58A1),A
	JP	C,H50BE
H5096	CALL	H50DF
	LD	A,(H58A1)
	LD	HL,(H58A2)
H509F	ADD	A,A
	ADD	A,H
	LD	H,A
	EX	DE,HL
	LD	HL,(H589C)
	ADD	HL,DE
	LD	(H589E),HL
	LD	A,0FFH
	LD	(H58A0),A
	JP	H5053
H50B2	LD	HL,H589A
	CP	(HL)
	RET	NZ
	LD	B,A
	XOR	A
	LD	(H5899),A
	LD	A,B
	RET
H50BE	CALL	H50B2
	LD	HL,(H58A2)
	ADD	A,A
	ADD	A,H
	LD	H,A
	LD	A,(H589B)
	CALL	GETBLOCK
	LD	A,(H58A1)
	LD	B,A
	LD	HL,H58A7
	CALL	ADDHLA
	LD	A,(H589B)
	LD	(HL),A
	LD	A,B
	JP	H5096
H50DF	LD	C,A
	LD	A,(H5968)
	CP	C
	RET	Z
	LD	B,A
	LD	A,C
	LD	(H5968),A
	LD	HL,H58E7
	CALL	ADDHLA
	LD	E,(HL)
	LD	(HL),B
	LD	HL,H5927
	LD	A,C
	CALL	ADDHLA
	LD	D,(HL)
	LD	(HL),0FFH
