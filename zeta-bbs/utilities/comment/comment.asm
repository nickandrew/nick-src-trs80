;comment: Save user comments onto disk.
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	TERMINATE
;End of program load info.
;
	COM	'<Comment 4.0a 04-Jan-88>'
	ORG	BASE+100H
START
	LD	SP,START
	PUSH	HL	;save cmd line.
;
;
;open file
	LD	DE,C_FCB
	LD	HL,C_BUFF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,COMM_ERR
	LD	A,(C_FCB+1)
	AND	0F8H
	LD	(C_FCB+1),A
;check if sysop wants to manipulate the file.
	POP	HL
	LD	A,(HL)
	CP	CR
	JR	Z,ADD_COMM
	OR	A
	JR	Z,ADD_COMM
;parameters entered. Check if sysop is doing this.
;if not, disregard params.
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JP	NZ,SYSOP_CTRL	;sysop control.
;
ADD_COMM
	CALL	DOS_POS_EOF
	LD	HL,M_FROM	;Record who runs
	CALL	FILE_MSG
	JP	NZ,COMM_ERR
	LD	HL,(USR_NAME)
	LD	DE,C_FCB
;
W_USER	LD	A,(HL)		;Copy user name,
	CP	CR
	JR	Z,COPY_DATE
	OR	A
	JR	Z,COPY_DATE
	CALL	$PUT
	JP	NZ,COMM_ERR
	INC	HL
	JR	W_USER
;
COPY_DATE LD	HL,DATE		;Copy date & time
	CALL	X_TODAY
	LD	HL,TIME
	CALL	446DH
	LD	HL,M_TIMDAT
	LD	DE,C_FCB
	CALL	FILE_MSG
	JP	NZ,COMM_ERR
;
	LD	HL,M_TYPE
	LD	DE,$2
	CALL	MESS_0
	XOR	A
	LD	(LINES),A
LOOP	LD	HL,M_PROMPT
	LD	DE,$2
	CALL	MESS_0
	CALL	LINEIN		;with wraparound
	JR	C,DISREG
	LD	HL,LI_BUF	;entered line.
	LD	A,(HL)
	OR	A
	JR	Z,EXIT
	LD	DE,C_FCB
	CALL	FILE_MSG
	LD	A,CR
	CALL	$PUT
	JP	NZ,COMM_ERR
;increment lines.
	LD	A,(LINES)
	INC	A
	LD	(LINES),A
	CP	64
	JR	NC,EXIT
;
	JR	LOOP
DISREG	LD	HL,M_DISREG
	LD	DE,$2
	CALL	MESS_0
	JR	LOOP
;
COMM_ERR	;for file access errors.
	PUSH	AF
	LD	DE,C_FCB
	CALL	DOS_CLOSE
	LD	HL,M_ERROR
	CALL	LOG_MSG
	POP	AF
	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	LD	HL,M_SORRY
	LD	DE,$2
	CALL	MESS_0
	POP	AF
	JP	TERMINATE
;
EXIT
	LD	A,0CH		;A formfeed!
	LD	DE,C_FCB
	CALL	$PUT
	CALL	DOS_CLOSE
	JP	NZ,COMM_ERR
;
	LD	A,(LINES)
	OR	A
	JR	Z,NO_THANKS	;No lines typed
	LD	HL,M_THANKS	;Thank them
	LD	DE,$2
	CALL	MESS_0
	LD	A,0
	JP	TERMINATE
;
NO_THANKS
	LD	HL,M_NOTHANKS
	LD	DE,$2
	CALL	MESS_0
	LD	A,0
	JP	TERMINATE
;
FILE_MSG	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$PUT
	INC	HL
	JR	FILE_MSG
;
SYSOP_CTRL	;let the SYSOP manipulate the file.
	LD	A,(HL)
	AND	5FH
	CP	'L'
	JR	Z,L_COMM	;list comments
	CP	'K'
	JP	Z,KILL		;kill existing comments
	LD	HL,M_CMDERR
	LD	DE,$2
	CALL	MESS_0
	LD	A,128
	JP	TERMINATE
;
;List comments.
L_COMM
;
;print comment on screen.
PC_LP	LD	DE,C_FCB
	CALL	$GET
	JR	Z,PC_LP_2
	LD	A,0
	JP	TERMINATE
PC_LP_2
	OR	A		;If 0 = End of comment.
	JR	Z,PC_END
	CALL	STD_OUT
	JR	PC_LP
PC_END	LD	A,CR
	CALL	STD_OUT
	JR	PC_LP
;
;Kill all comments.
KILL	LD	DE,C_FCB
	CALL	DOS_REWIND
	LD	HL,NC_DATE
	CALL	X_TODAY
	LD	HL,NC_MSG
	LD	DE,C_FCB
	CALL	FILE_MSG
	JP	NZ,COMM_ERR
	CALL	DOS_CLOSE
	JP	NZ,COMM_ERR
	LD	A,0
	JP	TERMINATE
;
;Get required routines.
*GET	LINEIN		;Wraparound input routine.
*GET	ROUTINES
;
M_TYPE	DEFM	CR,CR
	DEFM	'Type out your comments now,',CR
	DEFM	'Hit <CR> on an empty line when finished',CR,CR,0
M_DISREG DEFM	'** Previous line disregarded **',CR,0
M_PROMPT DEFM	': ',0
M_THANKS DEFM	'Thanks for your comments',CR,0
M_NOTHANKS
	DEFM	CR,CR
	DEFM	'You certainly don''t waste your words!'
	DEFM	CR,CR,0
M_ERROR	DEFM	'COMMENT: Disk error',CR,0
M_SORRY	DEFM	'Sorry about that!',CR,0
M_CMDERR
	DEFM	'Comment: Leave or read sysop comments',CR
	DEFM	'Usage:   Comment [kl]',CR,0
M_FROM	DEFM	'From: ',0
;
M_TIMDAT DEFM	' {'
DATE	DEFM	'DD-MMM-YY '
TIME	DEFM	'HH:MM:SS}',CR,0
;
NC_MSG	DEFM	'Comment log commencing on '
NC_DATE	DEFM	'dd-mmm-yy.',CR,0
;
LINES	DEFB	0
;
C_FCB	DEFB	'comments.zms',CR
	DC	32-13,0
;
C_BUFF	DEFS	256
;
THIS_PROG_END	EQU	$
;
	END	START
