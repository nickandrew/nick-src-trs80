;Visible/asm: finds invisible user files on disks.

*GET	DOSCALLS

	ORG	5200H
VISIBLE	LD	HL,MESS
	CALL	MESS_DO
	CALL	ROM@WAIT_KEY
	CP	1
	JP	Z,402DH
	XOR	A
	CALL	490AH
	LD	HL,42D0H
	LD	DE,DISKNAME
	LD	BC,8
	LDIR
	LD	HL,42D8H
	LD	DE,DATE
	LD	BC,8
	LDIR
	LD	HL,DISK
	CALL	MESS_DO
	LD	B,8
LOOP	LD	A,B
	INC	A
	CALL	490AH
	LD	C,0
LOOP2	LD	L,C
	LD	H,42H
	LD	A,(HL)
	AND	0D8H
	CP	18H
	CALL	Z,INVIS
	LD	A,C
	ADD	A,20H
	LD	C,A
	OR	A
	JR	NZ,LOOP2
	DJNZ	LOOP
	JR	VISIBLE
INVIS	PUSH	BC
	LD	H,42H
	LD	A,C
	ADD	A,5
	LD	L,A
	LD	B,8
LOOP3	LD	A,(HL)
	CP	20H
	JR	Z,LOUT
	PUSH	BC
	CALL	ROM@PUT_VDU
	POP	BC
	INC	HL
	DJNZ	LOOP3
LOUT	LD	H,42H
	LD	A,C
	ADD	A,13
	LD	L,A
	LD	B,3
	LD	A,(HL)
	CP	20H
	JR	Z,NOEXT
	LD	A,'/'
	CALL	ROM@PUT_VDU
LOOP4	LD	A,(HL)
	INC	HL
	PUSH	BC
	CALL	ROM@PUT_VDU
	POP	BC
	DJNZ	LOOP4
NOEXT	LD	A,0DH
	CALL	ROM@PUT_VDU
	POP	BC
	RET
MESS	DEFM	'Hit <ENTER> to read or <BREAK> to exit.'
	DEFB	0DH
DISK	DEFM	'DISK: '
DISKNAME	DEFM	'XXXXXXXX'
	DEFM	'    '
DATE	DEFM	'DD/MM/YY.',0DH
	END	VISIBLE
