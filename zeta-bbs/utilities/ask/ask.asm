;ask: Ask a yes/no question
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
	COM	'<Ask 1.0  27-May-86>'
	ORG	BASE+100H
START	LD	SP,START
	LD	A,(HL)
	CP	CR
	JR	Z,USAGE
	OR	A
	JR	NZ,NOUSAGE
USAGE
	LD	HL,M_USAGE
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	LD	A,2
	JP	TERMINATE
;
NOUSAGE
	LD	A,(HL)
	CP	CR
	JR	Z,EOM
	OR	A
	JR	Z,EOM
	LD	DE,($STDOUT_DEF)
	CALL	ROM@PUT
	INC	HL
	JR	NOUSAGE
;
EOM
	LD	A,' '
	CALL	ROM@PUT
	CALL	ROM@PUT
	LD	HL,YN_BUFF
	LD	B,3
	CALL	ROM@WAIT_LINE
	JP	C,EXIT
	LD	A,(HL)
	AND	5FH
	CP	'Y'
	JR	Z,YES
	CP	'N'
	JR	Z,NO
	LD	A,3
	JP	TERMINATE
YES
	XOR	A
	JP	TERMINATE
NO	LD	A,1
	JP	TERMINATE
;
EXIT	LD	A,3
	JP	TERMINATE
;
*GET	ROUTINES
;
M_USAGE	DEFM	'Ask:  Ask a yes/no question.',CR
	DEFM	'Usage: ASK text...',CR
	DEFM	'Eg:    ASK  Are you over 18? ',CR,0
;
YN_BUFF
	DEFS	3
;
THIS_PROG_END	EQU	$
;
	END	START
