;cat: Concatenate files.
;
*GET	DOSCALLS.HDR
*GET	EXTERNAL.HDR
*GET	ASCII.HDR
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	TERMINATE
	DEFW	TERMINATE
;End of program load info.
;
	COM	'<Cat 1.0  05-Jul-86>'
	ORG	BASE+100H
START	LD	SP,START
;
LOOP
	LD	A,(HL)
	CP	CR
	JR	Z,CAT_END
	OR	A
	JR	Z,CAT_END
	LD	(ARGP),HL
	CALL	CAT
	LD	HL,(ARGP)
	CALL	NEXT_WORD
	JR	LOOP
;
CAT_END	XOR	A
	JP	TERMINATE
;
CAT	LD	DE,FCB_IN
	CALL	EXTRACT
	LD	HL,BUFF_IN
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,CAT_NOOPEN
CAT_01	LD	DE,FCB_IN
	CALL	$GET
	RET	NZ
	CALL	STD_OUT
	JR	CAT_01
;
CAT_NOOPEN
	LD	HL,M_NOOPEN
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	LD	HL,(ARGP)
	CALL	MESS_SPACE
	LD	A,CR
	CALL	$PUT
	RET
;
NEXT_WORD	LD	A,(HL)
	OR	A
	RET	Z
	CP	CR
	RET	Z
	INC	HL
	CP	' '
	JR	NZ,NEXT_WORD
NW_1	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	NW_1
;
MESS_SPACE	LD	A,(HL)
	CP	' '
	RET	Z
	CP	CR
	RET	Z
	OR	A
	RET	Z
	CALL	$PUT
	INC	HL
	JR	MESS_SPACE
;
*GET	ROUTINES
;
ARGP	DEFW	0
FCB_IN	DEFS	32
BUFF_IN	DEFS	256
;
M_NOOPEN
	DEFM	'cat: Cannot open ',0
;
THIS_PROG_END	EQU	$
;
	END	START
