;Objcat: Concatenate Object files for Alcor C.
;Written By Nick Andrew.
;
*GET	DOSCALLS
;
CR	EQU	0DH
;
	COM	'<Objcat 1.0  16-Jun-86>'
	ORG	5300H
START	LD	SP,START
	LD	A,(HL)
	CP	CR
	JR	NZ,PROCESS
;
USAGE
	LD	HL,M_USAGE
	CALL	MESS
	JP	EXIT
;
PROCESS	LD	(ARGS),HL
OC_1	PUSH	HL
	CALL	BYP_WORD
	LD	A,(HL)
	CP	CR
	JR	Z,OC_2
	POP	DE
	JR	OC_1
OC_2	POP	HL
	LD	DE,FCB_OUT
	PUSH	HL
	CALL	DOS_EXTRACT
	JP	NZ,ERROR
	POP	HL
	LD	(HL),CR
;
	LD	HL,(ARGS)
	LD	A,(HL)
	CP	CR
	JR	Z,USAGE
;
	LD	HL,BUFF_OUT
	LD	DE,FCB_OUT
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,ERROR
;
OC_3	LD	HL,(ARGS)
	LD	A,(HL)
	CP	CR
	JR	Z,OC_4
	CALL	DOFILE
	LD	HL,(ARGS)
	CALL	BYP_WORD
	LD	(ARGS),HL
	JR	OC_3
;
OC_4	LD	DE,FCB_OUT
	LD	A,':'		;Eof byte 1
	CALL	ROM@PUT
	LD	A,CR
	CALL	ROM@PUT
	JP	NZ,ERROR
	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	JP	NZ,ERROR
	JP	EXIT
;
DOFILE
	LD	DE,FCB_IN
	CALL	DOS_EXTRACT
	JP	NZ,ERROR
	LD	HL,BUFF_IN
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	Z,OC_5
	OR	80H
	CALL	DOS_ERROR
	RET
OC_5
BEGIN	LD	DE,FCB_IN
	CALL	ROM@GET
	JP	NZ,ERROR
	CP	':'
	JR	Z,OC_6
	LD	DE,FCB_OUT
	CALL	ROM@PUT
	JP	NZ,ERROR
	JR	BEGIN
OC_6
	RET
;
MESS	LD	A,(HL)
	OR	A
	RET	Z
	CALL	33H
	INC	HL
	JR	MESS
;
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	DOS_NOERROR
;
BYP_WORD
	LD	A,(HL)
	CP	' '
	JR	Z,BW_1
	CP	CR
	RET	Z
	INC	HL
	JR	BYP_WORD
BW_1	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,BW_1
	RET
;
EXIT	JP	DOS_NOERROR
;
M_USAGE	DEFM	'Objcat:  Concatenate Alcor C object files',CR
	DEFM	'Usage:   OBJCAT infile1 [infile2] [infile3] ... outfile',CR
	DEFM	'Eg:      OBJCAT pack/o fileno/o pack/obj',CR,0
FCB_IN	DEFS	32
FCB_OUT	DEFS	32
BUFF_IN	DEFS	256
BUFF_OUT	DEFS	256
;
ARGS	DEFW	0
;
	END	START
