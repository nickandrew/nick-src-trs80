;
$TWO_DIGIT
	LD	(HL),'0'-1
	LD	A,(DE)
$TD_01
	INC	(HL)
	SUB	10
	JR	NC,$TD_01
	INC	HL
	ADD	A,'0'+10
	LD	(HL),A
	INC	HL
	INC	DE
	RET