;DAY/asm: PRINTS DAY OF WEEK

*GET	DOSCALLS

	ORG	5200H
DAY	LD	A,(4046H)
	CP	3
	LD	A,(4044H)
	JR	NC,DAYV01
	DEC	A
DAYV01	SRL	A
	SRL	A
	LD	(L1),A
	LD	A,(4046H)
	LD	HL,TABLE
	ADD	A,L
	LD	L,A
	LD	A,(HL)
	LD	(MO),A
	LD	A,(L1)
	LD	B,A
	LD	A,(MO)
	ADD	A,B
	LD	B,A
	LD	A,(4045H)
	ADD	A,B
	LD	B,A
	LD	A,(4044H)
	ADD	A,B
LOOP	SUB	7
	JR	NC,LOOP
	ADD	A,7
	ADD	A,A
	LD	HL,TABLE2
	ADD	A,L
	LD	L,A
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	CALL	MESS_DO
	JP	402DH
TABLE	DEFB	0
	DEFB	0
	DEFB	3
	DEFB	3
	DEFB	6
	DEFB	1
	DEFB	4
	DEFB	6
	DEFB	2
	DEFB	5
	DEFB	0
	DEFB	3
	DEFB	5
TABLE2	DEFW	D1
	DEFW	D2
	DEFW	D3
	DEFW	D4
	DEFW	D5
	DEFW	D6
	DEFW	D7
	DEFW	0
D1	DEFM	'Sunday'
	DEFB	13
D2	DEFM	'Monday'
	DEFB	13
D3	DEFM	'Tuesday'
	DEFB	0DH
D4	DEFM	'Wednesday'
	DEFB	0DH
D5	DEFM	'Thursday'
	DEFB	0DH
D6	DEFM	'Friday'
	DEFB	0DH
D7	DEFM	'Saturday'
	DEFB	0DH
L1	DEFB	0
MO	DEFB	0
	END	DAY
