;DUPLICAT/EDT COPIES ADVENTURE FROM ORIGINAL DISK.

*GET	DOSCALLS

	ORG	8000H
START	CALL	RESTOR
SAVER	CALL	INSSCE
	CALL	RESET
	CALL	LOAD50
	CALL	STOUT
	CALL	INSDES
	CALL	RESET
	CALL	SAVE50
	JP	SAVER
INSSCE	LD	HL,SMES
	JP	WTINP
SMES	DEFM	'INSERT <SOURCE> DISK AND HIT RETURN:'
	DEFB	0DH
DMES	DEFM	'INSERT <DESTINATION> DISK AND HIT RETURN:'
	DEFB	0DH
INSDES	LD	HL,DMES
WTINP	LD	A,(HL)
	CALL	ROM@PUT_VDU
	CP	0DH
	JR	Z,WTOUT
	INC	HL
	JR	WTINP
WTOUT	LD	A,(38FFH)
	OR	A
	JR	NZ,WTOUT
WTKBD	LD	A,(3840H)
	AND	1
	JR	Z,WTKBD
	LD	A,1
	LD	(37E1H),A
	LD	BC,4000H
	CALL	60H
	RET
RESTOR	LD	A,1
	LD	(37E1H),A
	LD	BC,4000H
	CALL	60H
	LD	A,0
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
LOP1	LD	A,(37ECH)
	BIT	0,A
	JR	NZ,LOP1
	RET
STOUT	LD	B,5
STEP	PUSH	BC
	CALL	STOUT2
	POP	BC
	DJNZ	STEP
	RET
STOUT2	LD	A,1
	LD	(37E1H),A
	LD	B,6
	DJNZ	$
	LD	A,60H
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
LOP2	LD	A,(37ECH)
	BIT	0,A
	JR	NZ,LOP2
	RET
LDFLAG	DEFB	0
SVFLAG	DEFB	0
SECT	DEFB	0
LDAREA	DEFW	8300H
LOAD50	LD	B,5
LOP3	PUSH	BC
	CALL	LOAD10
	POP	BC
	LD	A,255
	LD	(LDFLAG),A
	DJNZ	LOP3
	RET
LOAD10	CALL	LOAD
	LD	A,(SECT)
	INC	A
	LD	(SECT),A
	CP	0AH
	JR	C,LOAD10
	XOR	A
	LD	(SECT),A
	CALL	STEPIN
	RET
STEPIN	LD	A,1
	LD	(37E1H),A
	LD	B,6
	DJNZ	$
	LD	A,40H
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
LOP4	LD	A,(37ECH)
	BIT	0,A
	JR	NZ,LOP4
	RET
RESET	LD	BC,8300H
	LD	(LDAREA),BC
	RET
LOAD	LD	A,1
	LD	(37E1H),A
	LD	HL,37ECH
	LD	DE,37EFH
	LD	BC,(LDAREA)
	LD	A,(SECT)
	CP	0
	JR	NZ,ENC1
	LD	A,(LDFLAG)
	OR	A
	JR	Z,BYP1
ENC1	ADD	A,A
	CPL
	ADD	A,82H
BYP1	LD	(37EEH),A
	LD	(HL),88H
	PUSH	BC
	LD	B,6
	DJNZ	$
	POP	BC
LOP5	BIT	1,(HL)
	JR	Z,LOP5
	LD	A,(DE)
	LD	(BC),A
	INC	BC
	LD	A,C
	OR	A
	JR	NZ,LOP5
	LD	(LDAREA),BC
	RET
SAVE50	LD	B,5
LOP6	PUSH	BC
	CALL	SAVE10
	POP	BC
	LD	A,255
	LD	(SVFLAG),A
	DJNZ	LOP6
	RET
SAVE10	CALL	SAVE
	LD	A,(SECT)
	INC	A
	LD	(SECT),A
	CP	0AH
	JR	C,SAVE10
	XOR	A
	LD	(SECT),A
	CALL	STEPIN
	RET
SAVE	LD	A,1
	LD	(37E1H),A
	LD	HL,37ECH
	LD	DE,37EFH
	LD	BC,(LDAREA)
	LD	A,(SECT)
	CP	0
	JR	NZ,ENC2
	LD	A,(SVFLAG)
	OR	A
	JR	Z,BYP2
ENC2	ADD	A,A
	CPL
	ADD	A,82H
BYP2	LD	(37EEH),A
	LD	(HL),0AAH
	PUSH	BC
	LD	B,6
	DJNZ	$
	POP	BC
LOP7	BIT	1,(HL)
	JR	Z,LOP7
	LD	A,(BC)
	LD	(DE),A
	INC	BC
	LD	A,C
	OR	A
	JR	NZ,LOP7
	LD	(LDAREA),BC
	RET
	END	START
