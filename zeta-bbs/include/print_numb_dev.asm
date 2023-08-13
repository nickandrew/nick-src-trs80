;
PRINT_NUMB_DEV
	LD	(_PRNU_DEV),DE
	XOR	A
	LD	(BLANK),A
	LD	DE,10000
	CALL	PRT_DIGIT
	LD	DE,1000
	CALL	PRT_DIGIT
	LD	DE,100
	CALL	PRT_DIGIT
	LD	DE,10
	CALL	PRT_DIGIT
	LD	A,(DIGIT)
	LD	(TENS),A
	LD	DE,1
	LD	A,E
	LD	(BLANK),A
	CALL	PRT_DIGIT
	LD	A,(DIGIT)
	LD	(ONES),A
	RET
;
PRT_DIGIT
	LD	B,'0'-1
PD_1	INC	B
	OR	A
	SBC	HL,DE
	JR	NC,PD_1
	ADD	HL,DE
	LD	A,(BLANK)
	OR	A
	JR	NZ,PD_2
	LD	A,B
	LD	(DIGIT),A
	CP	'0'
	RET	Z
PD_2	LD	(BLANK),A
	LD	A,B
	LD	(DIGIT),A
	LD	DE,(_PRNU_DEV)
	CALL	ROM@PUT
	RET
;
BLANK	DEFB	0
DIGIT	DEFB	0
TENS	DEFB	0
ONES	DEFB	0
_PRNU_DEV	DEFW	0
;