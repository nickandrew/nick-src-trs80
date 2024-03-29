;rm: remove files off disk.
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	TERM_ABORT
	DEFW	0
;End of program load info.
;
	COM	'<rm 1.1b 02-Apr-88>'
	ORG	BASE+100H
START	LD	SP,START
;
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JR	NZ,KILL_ANY
;
;Kill tempfile only.
	LD	HL,M_TEMPFILE
	LD	DE,DCB_2O
	CALL	FPUTS
;
	LD	HL,TEMPFILE
	CALL	REMOVE
	JP	TERMINATE
;
KILL_ANY
	XOR	A
	LD	(I_FLAG),A	;default off now.
;
	LD	A,(HL)
	CP	CR
	JR	Z,USAGE
	OR	A
	JR	Z,USAGE
;
KA_01	CP	'-'
	JR	NZ,KA_01A
	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,KA_01A
	CP	CR
	JR	Z,USAGE
	OR	A
	JR	Z,USAGE
	CP	'I'
	JR	NZ,USAGE
	LD	A,1
	LD	(I_FLAG),A
	INC	HL
	JR	KA_01
;
KA_01A	CALL	BYP_SP
;
KA_02	LD	A,(HL)
	CP	CR
	JR	Z,KA_03
	OR	A
	JR	Z,KA_03
	CALL	REMOVE
	LD	HL,(ARG)
	CALL	BYP_WORD
	JR	KA_02
KA_03	XOR	A
	JP	TERMINATE
;
USAGE	LD	HL,M_USAGE
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,1
	JP	TERMINATE
;
BYP_SP	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	BYP_SP
;
BYP_WORD
	LD	A,(HL)
	CP	CR
	RET	Z
	OR	A
	RET	Z
	CP	' '
	JR	Z,BYP_SP
	INC	HL
	JR	BYP_WORD
;
REMOVE
	LD	(ARG),HL
	LD	DE,FCB_KILL
	CALL	EXTRACT
	JP	NZ,NONEX
	LD	HL,0
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,NONEX
	CALL	ASK
	RET	NZ		;don't remove.
	LD	DE,FCB_KILL
	CALL	DOS_KILL
	RET	Z
	JP	NOKILL
;
ASK	LD	A,(I_FLAG)
	OR	A
	RET	Z
	LD	HL,(ARG)
	LD	DE,DCB_2O
	CALL	MESS_WORD
	LD	A,' '
	CALL	ROM@PUT
	LD	A,'?'
	CALL	ROM@PUT
	LD	A,' '
	CALL	ROM@PUT
	LD	HL,YN_BUFF
	LD	B,1
	CALL	ROM@WAIT_LINE
	JR	C,DONT_KILL
	LD	A,(HL)
	AND	5FH
	CP	'Y'
	RET	Z
DONT_KILL
	XOR	A
	CP	1
	RET
;
NONEX
	LD	HL,M_KILL
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	HL,M_NONEX
	CALL	MESS_0
	LD	HL,(ARG)
	CALL	MESS_WORD
	LD	A,CR
	CALL	ROM@PUT
	RET
;
NOKILL
	LD	HL,M_KILL
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	HL,M_NOKILL
	CALL	MESS_0
	LD	HL,(ARG)
	CALL	MESS_WORD
	LD	A,CR
	CALL	ROM@PUT
	RET
;
MESS_WORD
	LD	A,(HL)
	CP	CR
	RET	Z
	CP	' '
	RET	Z
	OR	A
	RET	Z
	CALL	ROM@PUT
	INC	HL
	JR	MESS_WORD
;
*GET	ROUTINES
;
M_KILL	DEFM	'rm: ',0
M_NONEX	DEFM	'Cannot find ',0
M_NOKILL
	DEFM	'Cannot kill ',0
M_USAGE	DEFM	'rm: remove files from disk',CR
	DEFM	'usage: rm [-i] file ...',CR
	DEFM	'eg:    rm -i tempfile',CR,0
;
M_TEMPFILE
	DEFM	'Not Sysop. Assuming "rm -i tempfile"',CR,0
TEMPFILE
	DEFM	'TEMPFILE',CR,0
I_FLAG	DEFB	1	;default ON.
ARG	DEFW	0	;arg pointer
;
YN_BUFF	DC	3,0
;
FCB_KILL	DEFS	32
;
THIS_PROG_END	EQU	$
;
	END	START
