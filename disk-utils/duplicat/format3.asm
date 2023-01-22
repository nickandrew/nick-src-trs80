;FORM3/EDT: SPECIAL FORMAT.

*GET	DOSCALLS

	ORG	5200H
FORM3	DI
	CALL	INSERT
	CALL	RESTORE
	XOR	A
	LD	(TRACK),A
FORV01	CALL	BUILD
	CALL	FORMAT
	CALL	STEPIN
	LD	A,(TRACK)
	INC	A
	LD	(TRACK),A
	CP	40
	JR	NZ,FORV01
	CALL	SYSDISK
	JP	402DH
BUILD	LD	DE,BUFFER
	LD	B,11
	CALL	POKFF
	XOR	A
	LD	(SECTR),A
SECTOR	LD	B,6
	CALL	POK00
	LD	A,0FEH
	LD	(DE),A
	INC	DE
	LD	A,(TRACK)
	LD	(DE),A
	INC	DE
	XOR	A
	LD	(DE),A
	INC	DE
	LD	A,(SECTR)
	LD	C,A
	LD	B,0
	LD	HL,STABLE
	ADD	HL,BC
	LD	A,(HL)
	LD	(DE),A
	INC	DE
	LD	A,1
	LD	(DE),A
	INC	DE
	LD	A,0F7H
	LD	(DE),A
	INC	DE
	LD	B,11
	CALL	POKFF
	LD	B,6
	CALL	POK00
	LD	A,0FBH
	LD	(DE),A
	INC	DE
	LD	A,0E5H
	LD	B,0
	CALL	POKDE
	LD	A,0F7H
	LD	(DE),A
	INC	DE
	LD	B,11
	CALL	POKFF
	LD	A,(SECTR)
	INC	A
	LD	(SECTR),A
	CP	10
	JR	NZ,SECTOR
	LD	B,6
	CALL	POK00
	LD	A,0FEH
	LD	(DE),A
	INC	DE
	LD	A,(TRACK)
	LD	(DE),A
	INC	DE
	XOR	A
	LD	(DE),A
	INC	DE
	LD	A,128
	LD	(DE),A
	INC	DE
	LD	A,1
	LD	(DE),A
	INC	DE
	LD	A,0F7H
	LD	(DE),A
	INC	DE
	LD	B,11
	CALL	POKFF
	LD	B,6
	CALL	POK00
	LD	A,0FBH
	LD	(DE),A
	INC	DE
	LD	B,16
	CALL	POK00
	LD	A,0F7H
	LD	(DE),A
	INC	DE
	LD	B,11
	CALL	POKFF
	LD	B,0
	CALL	POKFF
	RET
POKDE	LD	(DE),A
	INC	DE
	DJNZ	POKDE
	RET
POK00	XOR	A
	JR	POKDE
POKFF	LD	A,0FFH
	JR	POKDE
TRACK	DEFB	0
SECTR	DEFB	0
STABLE	DEFB	4
	DEFB	9
	DEFB	0
	DEFB	5
	DEFB	1
	DEFB	6
	DEFB	2
	DEFB	7
	DEFB	3
	DEFB	8
INSERT	LD	HL,M_INS
INSV01	CALL	MESSAGE
	LD	BC,4000H
	CALL	ROM@PAUSE
INSV02	LD	A,(38FFH)
	OR	A
	JR	Z,INSV02
	RET
MESSAGE	LD	A,(HL)
	OR	A
	RET	Z
	CALL	ROM@PUT_VDU
	INC	HL
	CP	0DH
	RET	Z
	JR	MESSAGE
SYSDISK	LD	HL,M_SYS
	JR	INSV01
M_INS	DEFM	'INSERT DESTINATION DISK'
	DEFB	0DH
M_SYS	DEFM	'INSERT SYSTEM DISK'
	DEFB	0DH
RESTORE	LD	HL,37ECH
	LD	(HL),0D0H
	CALL	DELAY0
	CALL	SPIN
	LD	BC,2000H
	CALL	ROM@PAUSE
	LD	(HL),3
	CALL	DELAY0
RESV01	LD	A,(HL)
	AND	1
	JR	NZ,RESV01
	RET
DELAY0	PUSH	BC
	LD	B,10
	DJNZ	$
	POP	BC
	RET
SPIN	LD	A,1
	LD	(37E0H),A
	RET
STEPIN	LD	HL,37ECH
	LD	(HL),0D0H
	CALL	DELAY0
	CALL	SPIN
	LD	(HL),58H
	CALL	DELAY0
STEV01	LD	A,(HL)
	AND	1
	JR	NZ,STEV01
	RET
FORMAT	LD	HL,37ECH
	LD	(HL),0D0H
	CALL	DELAY0
	LD	DE,BUFFER
	LD	(HL),0F4H
	CALL	DELAY0
FORMV01	LD	A,(HL)
	AND	1
	RET	Z
	BIT	1,(HL)
	JR	Z,FORMV01
	LD	A,(DE)
	LD	(37EFH),A
	INC	DE
	JR	FORMV01
BUFFER	DEFB	0
	END	FORM3
