;scripatc: patch for @ key in scripsit.
; Assembled OK 30-Mar-85.
	ORG	7A9EH
	BIT	0,(IY+0EH)
	JR	NZ,AT0
	CP	'@'
	JR	Z,AT1
AT0	LD	(37E8H),A
	JP	5F74H
AT1	EX	DE,HL
	LD	A,(DE)
	CP	'@'
	PUSH	AF
	JR	NZ,AT2
	INC	DE
AT2	XOR	A
	LD	(BYTE),A
	CALL	BIT4
	RLCA
	RLCA
	RLCA
	RLCA
	LD	(BYTE),A
	CALL	BIT4
	LD	(37E8H),A
	POP	AF
	JR	NZ,AT3
	DEC	DE
AT3	XOR	A
	EX	DE,HL
	RET
BIT4	LD	A,(DE)
	INC	DE
	EXX
	SUB	30H
	CP	0AH
	JR	C,AT4
	SUB	7
AT4	LD	B,A
	LD	A,(BYTE)
	ADD	A,B
	EXX
	RET
AT10	CALL	6026H
	LD	B,(IY+35H)
	LD	C,0
AT11	LD	A,(DE)
	OR	A
	RET	Z
	CP	'@'
	JR	Z,AT21
	INC	C
	INC	DE
	JP	Z,535FH
	BIT	7,A
	JR	Z,AT12
	CALL	53FFH
	RET	Z
	CP	0ADH
	JR	NZ,AT11
AT12	DJNZ	AT11
AT13	LD	A,(DE)
	OR	A
	RET	Z
AT14	DEC	DE
	LD	A,(DE)
	CP	'@'
	JR	NZ,AT15
	INC	C
	INC	C
	JR	AT14
AT15	CP	20H
	JR	NZ,AT16
	INC	DE
	RET
AT16	DEC	C
	JR	NZ,AT13
	JP	5356H
AT21	INC	DE
	INC	DE
	INC	DE
	JP	AT11
AT20	LD	A,(DE)
	INC	DE
	DEC	C
	CP	'@'
	JP	NZ,722AH
	LD	A,(STOR)
	INC	A
	LD	(STOR),A
	INC	C
	INC	HL
	LD	(HL),40H
	LD	A,(DE)
	INC	DE
	INC	HL
	LD	(HL),A
	LD	A,(DE)
	INC	DE
	INC	HL
	LD	(HL),A
	JP	7227H
AT30	LD	HL,7ED9H
	XOR	A
	LD	(STOR),A
	JP	721FH
AT35	LD	D,A
	LD	A,(STOR)
	LD	E,A
	LD	A,D
	ADD	A,E
	ADD	A,E
	ADD	A,E
	SUB	L
	POP	DE
	JP	C,724EH
	RET
BYTE	DEFB	0
STOR	DEFB	0
	ORG	752FH
	CALL	AT10
	ORG	7227H
	JP	AT20
	ORG	721CH
	JP	AT30
	ORG	72A4H
	JP	AT35
NEWTXT	EQU	7F62H+100H
	ORG	529BH
	DEFW	NEWTXT-1
	ORG	5BD4H
	DEFW	NEWTXT-1
	ORG	5277H
	DEFW	NEWTXT
	ORG	5416H
	DEFW	NEWTXT
	ORG	5532H
	DEFW	NEWTXT
	ORG	5993H
	DEFW	NEWTXT
	ORG	59CBH
	DEFW	NEWTXT
	ORG	5DB6H
	DEFW	NEWTXT
	ORG	6316H
	DEFW	NEWTXT
	ORG	6352H
	DEFW	NEWTXT
	ORG	66DFH
	DEFW	NEWTXT
	ORG	69B4H
	DEFW	NEWTXT
	ORG	6E25H
	DEFW	NEWTXT
	ORG	741AH
	DEFW	NEWTXT
	ORG	7428H
	DEFW	NEWTXT
	END	5200H
