;Splitup/asm: Divide a long edtasm source file into
; a number of smaller files.
; Usage:   SPLITUP sourcefile
; output is in files from FILEA/EDT:1 to FILEx/EDT:1
; change data in locn 'file' for drive # or other names.
; Files are each 1000 lines long, except for the last.
;
; V1.0 21-Dec-84. Written by Nick Andrew.
;
*GET	DOSCALLS
	ORG	5200H
START	LD	DE,FCB_INP
	CALL	DOS_EXTRACT
	LD	A,'A'
	LD	(LETTER),A
	LD	HL,BUF_INP
	LD	DE,FCB_INP
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,DOS_ERROR
LOOP	CALL	GET
	CP	1AH
	JR	Z,EXIT
	PUSH	AF
	CALL	OPEN_2
	POP	AF
	CALL	COPY_1000
	JR	Z,EXIT
	LD	A,(LETTER)
	INC	A
	LD	(LETTER),A
	JR	LOOP
;
EXIT	LD	DE,FCB_INP
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	JP	DOS
;
OPEN_2	LD	HL,FILENAME
	LD	DE,FCB_OUT
	CALL	DOS_EXTRACT
	LD	HL,BUF_OUT
	LD	DE,FCB_OUT
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,DOS_ERROR
	RET
;
COPY_1000
	PUSH	AF
	LD	HL,0
	LD	(LINES),HL
	LD	HL,FILENAME
	CALL	4467H
	LD	A,' '
	CALL	0033H
	POP	AF
C_LOOP	CALL	PUT
	CALL	GET
	CP	0DH
	JR	NZ,C_LOOP
	CALL	PUT
	LD	HL,(LINES)
	INC	HL
	LD	(LINES),HL
	LD	A,L
	AND	31
	JR	NZ,C_BYP
	LD	A,'.'
	CALL	0033H
C_BYP	LD	DE,1000
	OR	A
	SBC	HL,DE
	LD	A,H
	OR	L
	JR	Z,C_EXIT
	CALL	GET
	CP	1AH
	JR	NZ,C_LOOP
	LD	A,1AH
	CALL	PUT
	LD	HL,EARLY
	CALL	4467H
	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	CP	A
	RET
;
C_EXIT
	LD	A,1AH
	CALL	PUT
	LD	HL,NORMAL
	CALL	4467H
	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	XOR	A
	CP	1
	RET
;
GET	LD	DE,FCB_INP
	CALL	0013H
	JP	NZ,DOS_ERROR
	RET
;
PUT	LD	DE,FCB_OUT
	CALL	001BH
	JP	NZ,DOS_ERROR
	RET
;
FILENAME
	DEFM	'FILE'
LETTER	DEFB	'A'
	DEFM	'/EDT:1',03H
;
LINES	DEFW	0
;
FCB_INP	DEFS	32
FCB_OUT	DEFS	32
BUF_INP	DEFS	256
BUF_OUT	DEFS	256
;
EARLY	DEFM	' Partially Full.',0DH
NORMAL	DEFM	' 1000 lines.',0DH
;
	END	START