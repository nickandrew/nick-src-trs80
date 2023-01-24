;DISKEDT: DISK SAVING & LOADING FOR EDTASM PLUS.
;Assembled OK 30-Mar-85.

*GET	DOSCALLS

EDITOR	EQU	44CCH
	ORG	7169H
	CALL	OPCMEX
RCMV01	CALL	READ
	CP	2
	JR	Z,RCMV07
	CP	5
	JR	NZ,RCMV03
	CALL	READ
	LD	B,A
RCMV02	CALL	READ
	DJNZ	RCMV02
	JR	RCMV01
RCMV03	CALL	READ
	LD	B,A
	DEC	B
	DEC	B
	CALL	READ
	LD	L,A
	CALL	READ
	LD	H,A
RCMV04	CALL	READ
	LD	(HL),A
	CP	(HL)
	INC	HL
	JR	NZ,RCMV06
RCMV05	DJNZ	RCMV04
	CALL	022CH
	JR	RCMV01
RCMV06	LD	A,'M'
	LD	(3C3DH),A
	JR	RCMV05
RCMV07	CALL	READ
	CALL	READ
	LD	L,A
	CALL	READ
	LD	H,A
	LD	(41F7H),HL
	LD	(42E9H),HL
	CALL	$CLOSE
	RET
	ORG	628AH
	PUSH	HL
	PUSH	BC
	LD	HL,4101H
	LD	A,1
	CALL	WRITE
	LD	A,(HL)
	ADD	A,2
	LD	B,A
	CALL	WRITE
WCMV01	INC	HL
	LD	A,(HL)
	CALL	WRITE
	DJNZ	WCMV01
	XOR	A
	LD	(42DDH),A
	POP	BC
	POP	HL
	RET
	ORG	4D11H
	CALL	OPEDEX
	LD	B,7
REDV01	CALL	READ
	DJNZ	REDV01
REDV02	CALL	READ
	CP	1AH
	JR	NZ,REDV03
	CALL	$CLOSE
	RET
REDV03	LD	B,A
	CALL	49C0H
	LD	HL,(4230H)
	LD	(4226H),HL
	LD	A,B
	LD	HL,0
	LD	B,5
REDV04	AND	7FH
	CALL	48B3H
	CALL	READ
	DJNZ	REDV04
	EX	DE,HL
	LD	HL,(4232H)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),0
	LD	D,H
	LD	E,L
	CALL	022CH
REDV05	INC	HL
	LD	(4232H),HL
	LD	(HL),255
	INC	HL
	LD	(HL),255
	DEC	HL
	CALL	READ
	CP	0DH
	JR	Z,REDV02
	EX	DE,HL
	INC	(HL)
	EX	DE,HL
	LD	(HL),A
	JR	REDV05
	ORG	0E800H
PATCH_01	CALL	SWAP
	JP	DOS_NOERROR
ERROR	OR	80H
	LD	HL,(0EE20H)
	LD	DE,(4020H)
	LD	(4020H),HL
	LD	(0EE20H),DE
	LD	HL,FCB
	LD	(HL),0
	INC	HL
	LD	(HL),0
	CALL	DOS_ERROR
	CALL	SWAP
	LD	HL,(0EE20H)
	LD	DE,(4020H)
	LD	(4020H),HL
	LD	(0EE20H),DE
	JP	EDITOR
OPCMEX	CALL	PUSHALL
	CALL	FILNAME
	CALL	SWAP
	LD	HL,EXCMD
	LD	DE,FCB
	CALL	DOS_EXTEND
	LD	HL,BUFFER
	LD	DE,FCB
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	CALL	SWAP
	JP	POPALL
OPCMNW	CALL	PUSHALL
	CALL	FILNAME
	CALL	SWAP
	LD	HL,EXCMD
	LD	DE,FCB
	CALL	DOS_EXTEND
	LD	HL,BUFFER
	LD	DE,FCB
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,ERROR
	CALL	SWAP
	JR	POPALL
OPEDEX	CALL	PUSHALL
	CALL	FILNAME
	CALL	SWAP
	LD	HL,EXEDT
	LD	DE,FCB
	CALL	DOS_EXTEND
	LD	HL,BUFFER
	LD	DE,FCB
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	CALL	SWAP
	JR	POPALL
OPEDNW	CALL	PUSHALL
	CALL	FILNAME
	CALL	SWAP
	LD	HL,EXEDT
	LD	DE,FCB
	CALL	DOS_EXTEND
	LD	HL,BUFFER
	LD	DE,FCB
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,ERROR
	CALL	SWAP
	JR	POPALL
FILNAME	LD	HL,M$FIL
	CALL	MESSAGE
	LD	A,(400CH)
	LD	(INSTR),A
	LD	A,0C9H
	LD	(400CH),A
	XOR	A
	LD	(COUNT),A
	LD	HL,FCB
	LD	B,31
	CALL	ROM@WAIT_LINE
	LD	A,(INSTR)
	LD	(400CH),A
	JP	C,4383H
	LD	A,0EH
	CALL	ROM@PUT_VDU
	RET
INSTR	DEFB	0
POPALL	POP	HL
	POP	IX
	POP	IY
	POP	DE
	POP	BC
	POP	AF
	RET
PUSHALL	LD	(STORHL),HL
	POP	HL
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	IY
	PUSH	IX
	PUSH	HL
	POP	IY
	LD	HL,(STORHL)
	PUSH	HL
	PUSH	IY
	RET
$CLOSE	CALL	PUSHALL
	LD	A,(FCB)
	BIT	7,A
	JR	Z,POPALL
	CALL	SWAP
	LD	DE,FCB
	LD	A,(FCB+1)
	BIT	4,A
	CALL	NZ,DOS_WRIT_SECT
	JP	NZ,ERROR
	LD	DE,FCB
	CALL	DOS_CLOSE
	JP	NZ,ERROR
	CALL	SWAP
	JR	POPALL
READ	CALL	PUSHALL
	LD	A,(COUNT)
	OR	A
	CALL	Z,RDREC
	LD	A,(COUNT)
	LD	E,A
	INC	A
	LD	(COUNT),A
	LD	D,0
	LD	HL,BUFFER
	ADD	HL,DE
	LD	A,(HL)
	LD	(STORA+1),A
	POP	HL
	POP	IY
	POP	IX
	POP	DE
	POP	BC
	POP	AF
	LD	A,(STORA+1)
	RET
RDREC	CALL	SWAP
	LD	DE,FCB
	CALL	DOS_READ_SECT
	JR	Z,RDRV01
	CP	1CH
	JR	Z,RDRV01
	CP	1DH
	JP	NZ,ERROR
RDRV01	CALL	SWAP
	RET
WRITE	CALL	PUSHALL
	LD	(STORA+1),A
	LD	A,(COUNT)
	LD	E,A
	INC	A
	LD	(COUNT),A
	LD	A,(FCB+1)
	SET	4,A
	LD	(FCB+1),A
	LD	D,0
	LD	HL,BUFFER
	ADD	HL,DE
	LD	A,(STORA+1)
	LD	(HL),A
	LD	A,255
	CP	E
	CALL	Z,WRREC
	JP	POPALL
WRREC	CALL	SWAP
	LD	DE,FCB
	CALL	DOS_WRIT_SECT
	JP	NZ,ERROR
	CALL	SWAP
	RET
MESSAGE	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
MESSAG2	LD	A,(HL)
	OR	A
	JR	Z,MESOUT
	CALL	ROM@PUT_VDU
	CP	0DH
	JR	Z,MESOUT
	INC	HL
	JR	MESSAG2
MESOUT	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
M$FIL	DEFM	'DISK FILESPEC: '
	DEFB	0
EXCMD	DEFM	'CMD'
EXEDT	DEFM	'EDT'
STORHL	DEFW	0
STORA	DEFW	0
COUNT	DEFB	0
SWAP	POP	IX
	LD	(SP1),SP
	LD	SP,(SP2)
	LD	A,(SP1)
	LD	(SP2),A
	LD	A,(SP1+1)
	LD	(SP2+1),A
	DI
	LD	HL,4000H
	LD	DE,0EE00H
	LD	BC,1200H
LOOP	LD	A,(HL)
	LD	(STORA),A
	LD	A,(DE)
	LD	(HL),A
	LD	A,(STORA)
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,LOOP
	PUSH	IX
	RET
SP1	DEFW	0
SP2	DEFW	STACK
FCB	DEFW	0
	DEFS	30
	DEFS	128
STACK	DEFW	0
BUFFER	DEFS	256
;
	ORG	44D0H
	DEFW	$CLOSE
	ORG	6503H
	DEFW	$CLOSE
	ORG	454DH
	DEFW	WRITE
	ORG	4FE9H
	DEFW	WRITE
	ORG	4FEFH
	DEFW	WRITE
	ORG	4FF8H
	DEFW	WRITE
	ORG	55CAH
	CALL	OPCMNW
	ORG	7136H
	CALL	OPCMNW
	ORG	4FFEH
	LD	A,2
	CALL	WRITE
	LD	A,2
	CALL	WRITE
	LD	A,L
	CALL	WRITE
	LD	A,H
	CALL	WRITE
	CALL	$CLOSE
	RET
	ORG	5F38H
	JP	4FFEH
	ORG	4FD4H
	CALL	OPEDNW
	ORG	4FE3H
	DEFW	0
	DEFB	0
	ORG	4696H
	DEFW	PATCH_01
	END	8500H
