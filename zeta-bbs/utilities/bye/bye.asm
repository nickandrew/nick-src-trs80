;bye: logoff user.
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	BYE_ABORT
	DEFW	TERMINATE
;End of program load info.
;
	COM	'<BYE 1.4d 18-Apr-87>'
	ORG	BASE+100H
START
	LD	SP,START
;
;Check arguments...
	CALL	ARG_PROC
	JR	Z,ARG_OK
;Print usage.
	LD	HL,M_USAGE	;print usage
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	LD	A,0
	CALL	TERMINATE
;
ARG_OK
	LD	A,(FLAG_QUICK)
	OR	A
	JR	NZ,NO_MSG_1
;
	LD	HL,M_BYE
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
NO_MSG_1
	CALL	COMM
	CALL	Q_GARB
;
	LD	A,(FLAG_QUICK)
	OR	A
	CALL	NZ,QUICK
	JR	NZ,BYEBYE
;
	LD	HL,BYE_FILE
	CALL	LIST
;
BYEBYE
;
	LD	A,0
	JP	TERM_DISCON	;go exitsys then answer
;
BYE_ABORT
	LD	SP,START
	LD	HL,M_NOBYE
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	LD	A,0
	JP	TERMINATE
;
QUICK				;quick logoff.
	PUSH	AF
	LD	HL,M_BYEBYE
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	POP	AF
	RET
;
;Ask if a comment is to be left.
;If quick & no specific comment then dont ask.
COMM
;
	LD	A,(FLAG_COMMENT)
	OR	A		;if auto comment.
	JR	NZ,COMM_YES
;
	LD	A,(FLAG_QUICK)	;dont ask if quick.
	OR	A
	RET	NZ
;
;ask if comment?
	LD	A,(SYS_STAT)	;no comment if testing
	BIT	6,A
	RET	NZ
	LD	HL,M_COMM
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	LD	HL,IN_BUFF
	LD	B,3
	CALL	40H
	JR	C,COMM
	LD	A,(HL)
	AND	5FH
	CP	'N'
	JR	Z,COMM_NO
	CP	'Y'
	JR	Z,COMM_YES
	JR	COMM
;
COMM_YES
;
	LD	HL,COMMENT
	CALL	CALL_PROG
	RET
;
COMM_NO
	RET
;
;ask about garbage received.
Q_GARB
	LD	A,(GARBAGE_AMT)
	OR	A		;if garbage already said
	JR	NZ,RECORD_GARBAGE
	LD	A,(FLAG_QUICK)
	OR	A		;dont ask if quick.
	RET	NZ
;
	LD	A,(SYS_STAT)
	BIT	6,A		;dont ask if testing
	RET	NZ
GARBAGE
	LD	HL,M_GARBQ
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	LD	HL,IN_BUFF
	LD	B,3
	CALL	40H
	JR	C,GARBAGE
	LD	A,(HL)
	AND	5FH
	CP	'N'
	RET	Z
	CP	'Y'
	JR	Z,GARB_YES
	JR	GARBAGE
;
GARB_YES
	LD	HL,M_GEXT
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	LD	HL,IN_BUFF
	LD	B,1
	CALL	40H
	JR	C,GARB_YES
	LD	A,(HL)
	CP	'1'
	JR	C,GARB_YES
	CP	'6'
	JR	NC,GARB_YES
	LD	(GARBAGE_AMT),A
;
RECORD_GARBAGE
	LD	HL,M_GSTAT
	CALL	LOG_MSG
	RET
;
;
ARG_PROC	;process arguments.
	LD	A,(HL)
	CP	CR
	RET	Z
	CP	'Q'
	JR	Z,ARG_Q
	CP	'C'
	JR	Z,ARG_C
	CP	'1'
	RET	C	;also NZ.
	CP	'6'
	JR	C,ARG_NUM
	XOR	A
	CP	1
	RET		;also NZ.
;
ARG_Q	LD	A,(FLAG_QUICK)
	OR	A
	JR	NZ,RET_NZ
	LD	A,1
	LD	(FLAG_QUICK),A
ARG_NEXT
	INC	HL
	LD	A,(HL)
	CP	CR
	RET	Z
	CP	' '
	JR	Z,ARG_NEXT
	JR	ARG_PROC
;
ARG_C
	LD	A,1
	LD	(FLAG_COMMENT),A
	JR	ARG_NEXT
;
ARG_NUM
	LD	B,A
	LD	A,(GARBAGE_AMT)
	OR	A
	RET	NZ
	LD	A,B
	LD	(GARBAGE_AMT),A
	JR	ARG_NEXT
;
RET_NZ
	OR	A
	RET	NZ
	CP	1
	RET
;
*GET	ROUTINES
;
M_NOBYE
	DEFM	CR
	DEFM	'** Logoff Aborted **',CR
	DEFM	'** Back to Shell  **',CR,0
;
BYE_FILE DEFM	'bye.zms',CR
COMMENT	DEFM	'Comment',0
;
FLAG_QUICK	DEFB	0
FLAG_COMMENT	DEFB	0
;
M_BYE	DEFM	CR,'   Thanks for calling Zeta. Please call back soon.',CR
	DEFM	CR,0
;
M_COMM	DEFM	'Want to leave a comment? (Y/N): ',0
M_GARBQ	DEFM	CR,'Have you been receiving garbled characters? (Y/N): ',0
;
M_GEXT	DEFM	CR,'How much garbage?? :--',CR
	DEFM	' 1) Not much - every now and then',CR
	DEFM	' 2) Every few lines a character',CR
	DEFM	' 3) Characters garbled in most lines',CR
	DEFM	' 4) Hard to read words',CR
	DEFM	' 5) Very bad garbage - unreadable',CR,CR
	DEFM	CR,'Please type a number from 1 to 5: ',0
;
M_GSTAT	DEFM	'User garbage report: level '
GARBAGE_AMT	DEFB	0,' ***',CR,0
;
M_YN	DEFM	'Please answer either YES or NO',CR,0
;
M_BYEBYE
	DEFM	'Bye Bye..',CR,CR,CR,0
M_USAGE	DEFM	'bye:    logoff the system',CR
	DEFM	'usage:  bye [q] [1|2|3|4|5] [c]',CR
	DEFM	'Eg:     bye q',CR,0
;
IN_BUFF	DC	8,0
;
THIS_PROG_END	EQU	$
;
	END	START
