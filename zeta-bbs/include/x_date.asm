;
;X_date: convert mm/dd/yy to dd-mmm-yy.
X_DATE
	PUSH	HL
	LD	DE,7
	ADD	HL,DE
	PUSH	HL
	POP	DE
	INC	DE
	LD	BC,2
	LDDR
	EX	DE,HL
	LD	(HL),'-'
	POP	HL
	PUSH	HL
	LD	A,(HL)
	CP	'1'
	LD	A,0
	JR	NZ,XTOD_1
	LD	A,10
XTOD_1	PUSH	HL
	INC	HL
	LD	B,(HL)
	ADD	A,B
	SUB	'0'
	LD	C,A
	ADD	A,A
	ADD	A,C
	LD	C,A
	INC	HL
	INC	HL
	LD	A,(HL)
	POP	DE
	LD	(DE),A
	INC	HL
	INC	DE
	LD	A,(HL)
	LD	(DE),A
	INC	DE
	LD	A,'-'
	LD	(DE),A
	INC	DE
	LD	HL,X_DATA
	LD	B,0
	ADD	HL,BC
	LD	C,3
	LDIR
	POP	HL
	RET
;
X_DATA	DEFM	'***JanFebMarAprMay'
	DEFM	'JunJulAugSepOctNov'
	DEFM	'Dec***************'
	DEFM	'******************'
;
