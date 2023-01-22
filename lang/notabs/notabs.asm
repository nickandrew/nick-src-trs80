;Notabs:   Change tabs in source file to spaces.
;          Default tab width is 8.
;
*GET	DOSCALLS
	ORG	5300H
START	LD	SP,START
	LD	DE,FCB_I
	CALL	DOS_EXTRACT
	LD	DE,FCB_O
	CALL	DOS_EXTRACT
	LD	HL,BUF_I
	LD	DE,FCB_I
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,DOS_ERROR
;
	LD	HL,BUF_O
	LD	DE,FCB_O
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,DOS_ERROR
;
	LD	A,1
	LD	(POS),A
;
LOOP	LD	DE,FCB_I
	CALL	ROM@GET
	JR	NZ,END_OF_FILE
	CP	09H
	JR	NZ,CHK_CR
;
	LD	A,(POS)
	DEC	A
	AND	7
	LD	B,A
	LD	A,8
	SUB	B
	LD	B,A
	LD	DE,FCB_O
TAB_LP	PUSH	BC
	LD	A,' '
	CALL	ROM@PUT
	JP	NZ,DOS_ERROR
	POP	BC
	DJNZ	TAB_LP
;
	LD	A,(POS)
	ADD	A,8
	AND	0F8H
	ADD	A,1
	LD	(POS),A
	JR	LOOP
;
CHK_CR	CP	0DH
	JR	NZ,PUTCHAR
	XOR	A
	LD	(POS),A
	LD	A,0DH
PUTCHAR
	LD	DE,FCB_O
	CALL	ROM@PUT
	JP	NZ,DOS_ERROR
	LD	A,(POS)
	INC	A
	LD	(POS),A
	JR	LOOP
;
END_OF_FILE
	LD	DE,FCB_I
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	LD	DE,FCB_O
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	JP	DOS_NOERROR
;
FCB_I	DEFS	32
FCB_O	DEFS	32
BUF_I	DEFS	256
BUF_O	DEFS	256
POS	DEFB	0
;
	END	START
