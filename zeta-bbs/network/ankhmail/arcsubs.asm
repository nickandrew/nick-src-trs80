;arcsubs : Some subroutines to deal with Arc files.
;
;arcnext(fp,filename) : Reads filename from open arc fp.
;
_ARCNEXT:
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;BC = filename output
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;DE = fp input
;
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	(AN_FCB),HL	;HL = fcb
	LD	(AN_FBUF),BC
;
	EX	DE,HL
	CALL	$GET		;Get 1st character 1A
	JP	NZ,AN_EOF
	CP	1AH
	JP	NZ,AN_ERR
;
	LD	DE,(AN_FCB)
	CALL	$GET		;Get compression type
	JP	NZ,AN_EOF
	OR	A
	JP	Z,AN_EOF
;
AN_FILE
	CALL	$GET
	JP	NZ,AN_EOF
	LD	HL,(AN_FBUF)
	LD	(HL),A
	INC	HL
	LD	(AN_FBUF),HL
	OR	A
	JR	NZ,AN_FILE
;
	LD	DE,(AN_FCB)
	CALL	$GET		;Read stored length lsb
	LD	(AN_LEN+0),A
;
	CALL	$GET
	LD	(AN_LEN+1),A
;
	CALL	$GET
	LD	(AN_LEN+2),A
;
	CALL	$GET
	LD	(AN_LEN+3),A
;
	LD	IX,(AN_FCB)
;
	LD	A,(IX+5)
	LD	(AN_POS),A
;
	LD	A,(IX+10)
	LD	(AN_POS+1),A
;
	LD	A,(IX+11)
	LD	(AN_POS+2),A
;
	CALL	POS_ADD
;
	LD	A,10
	LD	(AN_LEN),A
	XOR	A
	LD	(AN_LEN+1),A
	LD	(AN_LEN+2),A
;
	CALL	POS_ADD
;
	LD	A,(AN_POS)
	LD	C,A
	LD	HL,(AN_POS+1)
	LD	DE,(AN_FCB)
	CALL	DOS_POS_RBA
	JP	NZ,AN_ERR
;
	LD	HL,1
	RET
;
AN_ERR
	LD	HL,-1
	RET
AN_EOF
	LD	HL,0
	RET
;
POS_ADD
	LD	HL,AN_POS
	LD	A,(AN_LEN)
	ADD	A,(HL)
	LD	(HL),A
	INC	HL
;
	LD	A,(AN_LEN+1)
	ADC	A,(HL)
	LD	(HL),A
	INC	HL
;
	LD	A,(AN_LEN+2)
	ADC	A,(HL)
	LD	(HL),A
	INC	HL
	RET
;
AN_LEN	DC	4,0
AN_POS	DC	4,0
AN_FBUF	DEFW	0
AN_FCB	DEFW	0
