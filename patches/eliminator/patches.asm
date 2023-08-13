;ELIMINATOR HOT-IT-UP PATCHES...

*GET	DOSCALLS

	ORG	8DA6H
	LD	A,(3820H)
	BIT	6,A
	JP	NZ,557DH
	BIT	4,A
	JP	NZ,5531H
	ORG	0AEFDH
	JP	LOADXI
	ORG	0C800H
LOADXI	LD	HL,MESS1
	CALL	ROM@CLS
LOOP1	LD	A,(HL)
	OR	A
	JR	Z,FINI
	CALL	ROM@PUT_VDU
	INC	HL
	JR	LOOP1
MESS1	DEFM	'INSERT HIGH-SCORES DISK AND HIT ENTER:'
	DEFB	0
FINI	LD	A,(3840H)
	OR	A
	JR	Z,FINI
	LD	A,1
	LD	(37E1H),A
	LD	A,3
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
LOOP2	LD	A,(37ECH)
	BIT	0,A
	JR	NZ,LOOP2
	LD	A,1
	LD	(37E1H),A
	LD	D,39
	LD	E,5
	LD	(37EEH),DE
	LD	A,1BH
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
LOOP3	LD	A,(37ECH)
	BIT	0,A
	JR	NZ,LOOP3
	LD	A,88H
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
	LD	B,230
	LD	HL,32264
LOOP4	LD	A,(37ECH)
	BIT	1,A
	JR	Z,LOOP4
	LD	A,(37EFH)
	LD	(HL),A
	INC	HL
	DJNZ	LOOP4
	RET
SAVEXI	LD	A,1
	LD	(37E1H),A
	LD	A,3
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
LOOPA1	LD	A,(37ECH)
	BIT	0,A
	JR	NZ,LOOPA1
	LD	A,1
	LD	(37E1H),A
	LD	D,39
	LD	E,5
	LD	(37EEH),DE
	LD	A,1BH
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
LOOPA2	LD	A,(37ECH)
	BIT	0,A
	JR	NZ,LOOPA2
	LD	A,0ACH
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
	LD	HL,32264
	LD	B,230
LOOPA3	LD	A,(37ECH)
	BIT	1,A
	JR	Z,LOOPA3
	LD	A,(HL)
	LD	(37EFH),A
	INC	HL
	DJNZ	LOOPA3
	LD	B,26
LOOPA4	LD	A,(37ECH)
	BIT	1,A
	JR	Z,LOOPA4
	LD	A,0
	LD	(37EFH),A
	DJNZ	LOOPA4
	JP	535BH
	ORG	8C19H
	JP	Z,SAVEXI
	END	816EH
