;
$MONTH_NAME
	LD	A,(DE)
	INC	DE
	DEC	A
	CP	12
	JR	C,$MN_01
	LD	A,12
$MN_01
	LD	C,A
	ADD	A,A
	ADD	A,C
	LD	C,A
	LD	B,0
	PUSH	DE
	EX	DE,HL
	LD	HL,$MN_DATA
	ADD	HL,BC
	LD	C,3
	LDIR
	EX	DE,HL
	POP	DE
	RET
;
$MN_DATA
	DEFM	'JanFebMarAprMayJunJulAugSepOctNovDec***'
;