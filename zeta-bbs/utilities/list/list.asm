;list: List the contents of a file.
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	TERMINATE
	DEFW	TERMINATE
;End of program load info.
;
	COM	'<List 1.2b 09-Oct-87>'
	ORG	BASE+100H
;
START	LD	SP,START
	CALL	GET_ARGS
	JR	Z,ARGS_OK
;
	LD	HL,M_USAGE
	LD	DE,$2
	CALL	MESS_0
	LD	A,0
	JP	TERMINATE
;
FILE_USAGE
	LD	HL,M_BAD_FILE
	LD	DE,$2
	CALL	MESS_0
	LD	HL,FILENAME
	CALL	MESS_0
	LD	A,CR
	CALL	$PUT
	XOR	A
	JP	TERMINATE
;
;
ARGS_OK
AOK_1
	LD	HL,0
	LD	(OUTBYTES),HL
;
	CALL	CHECK_FILENAME
	JR	NZ,FILE_USAGE
	LD	HL,FILENAME
	LD	DE,FCB_IN
	CALL	EXTRACT
	JP	NZ,FILE_ERROR
;
	LD	DE,FCB_IN
	LD	HL,BUFF_IN
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,FILE_ERROR
;
;if SYSOP, change prot=lock to prot=read in fcb.
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JR	Z,OPEN_1
	LD	A,(FCB_IN+1)
	LD	B,A
	AND	7
	CP	7
	JR	NZ,OPEN_1
	LD	A,B
	AND	0F8H
	OR	5
	LD	(FCB_IN+1),A	;unprotect a bit.
;
OPEN_1
	LD	HL,(START_LINE)
	LD	A,H
	OR	L
	JR	Z,START_LIST
	LD	HL,1
	LD	(THIS_LINE),HL
;
BYPASS_1
	LD	HL,(START_LINE)
	LD	DE,(THIS_LINE)
	OR	A
	SBC	HL,DE
	LD	A,H
	OR	L
	JR	Z,START_LIST
;
BYPASS_2
	LD	DE,FCB_IN
	CALL	$GET
	JR	NZ,POSS_EOF
	CP	CR
	JR	NZ,BYPASS_2
;
	LD	HL,(THIS_LINE)
	INC	HL
	LD	(THIS_LINE),HL
	JR	BYPASS_1
;
POSS_EOF
	CP	1CH
	JP	NZ,FILE_ERROR
EXIT
	LD	A,0
	JP	TERMINATE	;not that many lines.
;
START_LIST
	LD	HL,0
	LD	(LINES_PRINTED),HL
;
LIST_1
;
LIST_1A
	LD	A,(SAVED)
	OR	A
	JR	NZ,WAS_SAVED
	LD	DE,FCB_IN
	CALL	$GET
	JR	NZ,POSS_EOF
	CP	1AH
	JP	Z,EXIT
	LD	HL,(OUTBYTES)
	INC	HL
	LD	(OUTBYTES),HL
	LD	B,A
;
WAS_SAVED
	PUSH	AF
	XOR	A
	LD	(SAVED),A
	POP	AF
;
LIST_1B
	CP	80H		;graphics
	JR	NC,GRX
	CP	LF
	JR	Z,CTRL_J
	CP	CR
	JR	Z,CTRL_M
	CP	20H
	JR	C,CTRL
	CALL	STD_OUT
	JR	LIST_1
;
CTRL_J				;for unix type files.
	LD	A,CR
	CALL	STD_OUT
	JR	CTRL_2A
;
CTRL_M	LD	A,CR
	CALL	STD_OUT
	LD	DE,FCB_IN
	CALL	$GET
	JP	NZ,POSS_EOF
	CP	LF
	JR	Z,LIST_1A	;ignore next LF
	LD	(SAVED),A
	JR	CTRL_2A
;
GRX	JR	DOT
;
DOT	LD	A,'.'		;graphics
	CALL	STD_OUT
	JR	LIST_1
;
CTRL
	CP	TAB
	JR	NZ,DOT
	LD	A,TAB
	CALL	STD_OUT
	JP	LIST_1
;
CTRL_2A
	LD	HL,(LINE_COUNT)
	LD	A,H
	OR	L
	JP	Z,LIST_1
	LD	DE,(LINES_PRINTED)
	INC	DE
	LD	(LINES_PRINTED),DE
	OR	A
	SBC	HL,DE
	LD	A,H
	OR	L
	JP	NZ,LIST_1
;
	LD	A,(SYS_STAT)
	BIT	IS_SYSOP,A
	LD	A,0
	JP	Z,TERMINATE
;
;close file if sysop.
	LD	DE,FCB_IN
	CALL	DOS_CLOSE
	JP	NZ,FILE_ERROR
	LD	A,0
	JP	TERMINATE
;
FILE_ERROR
	PUSH	AF
	LD	HL,M_PROGRAM
	LD	DE,$2
	CALL	MESS_0
	LD	HL,FILENAME
	CALL	MESS_0
	LD	A,':'
	CALL	$PUT
	LD	A,' '
	CALL	$PUT
	POP	AF
	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	TERMINATE
;
RET_NZ	OR	A
	RET	NZ
	CP	1
	RET
;
GET_ARGS
	LD	A,(HL)
	CP	CR
	JR	Z,RET_NZ
	LD	DE,FILENAME
	LD	B,30
GA_1	LD	A,(HL)
	CP	CR
	JR	Z,GA_2
	CP	' '
	JR	Z,GA_2
	OR	A
	JR	Z,GA_2
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	GA_1
	JR	RET_NZ
;
GA_2	XOR	A
	LD	(DE),A
;
	DEC	HL
GA_3
	INC	HL
	LD	A,(HL)
	CP	CR
	RET	Z
	OR	A
	RET	Z
	CP	' '
	JR	Z,GA_3
;
	LD	A,(HL)
	CALL	IF_NUMBER
	RET	NZ
	CALL	GET_NUMBER
	LD	(START_LINE),DE
;
	DEC	HL
;
GA_4
	INC	HL
	LD	A,(HL)
	CP	CR
	RET	Z
	CP	' '
	JR	Z,GA_4
;
	LD	A,(HL)
	CALL	IF_NUMBER
	RET	NZ
;
	CALL	GET_NUMBER
	LD	(LINE_COUNT),DE
;
	DEC	HL
GA_5
	INC	HL
	LD	A,(HL)
	CP	CR
	RET	Z
	CP	' '
	JR	Z,GA_5
	RET	;NZ.
;
CHECK_FILENAME
	LD	HL,FILENAME
	LD	A,(HL)
	CALL	IF_LETTER
	RET	NZ
	LD	B,8
;
CF_1
	INC	HL
	LD	A,(HL)
	CALL	IF_ALPHA
	JR	NZ,CF_2
	DJNZ	CF_1
CF_2
	CP	'.'
	JR	NZ,CF_4
	INC	HL
	LD	A,(HL)
	CALL	IF_LETTER
	RET	NZ
	LD	B,3
CF_3
	INC	HL
	LD	A,(HL)
	CALL	IF_ALPHA
	JR	NZ,CF_4
	DJNZ	CF_1
CF_4
	CP	'/'
	JR	NZ,CF_6
	INC	HL
	LD	B,9
CF_5
	INC	HL
	LD	A,(HL)
	CALL	IF_ALPHA
	JR	NZ,CF_6
	DJNZ	CF_5
CF_6
	CP	':'
	JR	NZ,CF_7
	INC	HL
	LD	A,(HL)
	CALL	IF_NUMBER
	RET	NZ
	INC	HL
	LD	A,(HL)
CF_7
	CP	0	;;set Z flag
	RET
;
IF_ALPHA
	CALL	IF_LETTER
	RET	Z
	CALL	IF_NUMBER
	RET
;
IF_LETTER
	CP	'A'
	JR	C,NOT_LETTER
	CP	80H
	JR	NC,NOT_LETTER
	AND	5FH
	CP	'Z'+1
	JR	NC,NOT_LETTER
	CP	A
	RET
NOT_LETTER
	JP	RET_NZ
;
IF_NUMBER
	CP	'0'
	JR	C,NOT_NUMBER
	CP	'9'+1
	JR	NC,NOT_NUMBER
	CP	A
	RET
NOT_NUMBER
	JP	RET_NZ
;
;
GET_NUMBER
	LD	DE,0
	DEC	HL
GN_1
	INC	HL
	LD	A,(HL)
	CALL	IF_NUMBER
	RET	NZ
	PUSH	HL
	PUSH	DE
	POP	HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	ADD	HL,HL
	AND	0FH
	LD	E,A
	LD	D,0
	ADD	HL,DE
	PUSH	HL
	POP	DE
	POP	HL
	JR	GN_1
;
*GET	ROUTINES
;
M_PROGRAM
	DEFM	'List: ',0
M_USAGE	DEFM	CR
	DEFM	'LIST:  Display contents of a disk file.',CR
	DEFM	'Usage: LIST filename [start-line [line-count]]',CR
	DEFM	'Eg:    LIST filelist.zms',CR,0
;
M_BAD_FILE
	DEFM	'List: Invalid filename: ',0
;
OUTBYTES	DEFW	0
START_LINE	DEFW	0
LINE_COUNT	DEFW	0
THIS_LINE	DEFW	0
LINES_PRINTED	DEFW	0
SAVED	DEFB	0
;
FILENAME
	DC	32,0
;
FCB_IN	DEFS	32
BUFF_IN	DEFS	256
;
THIS_PROG_END	EQU	$
;
	END	START
