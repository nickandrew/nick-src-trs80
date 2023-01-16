;chat: Test for and chat to the sysop.
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
	COM	'<Chat 1.7a 06-Feb-88>'
	ORG	BASE+100H
START
	LD	SP,START
;Check parameters. Usage is 'chat'.
	LD	A,(HL)
	CP	CR
	JR	Z,ARGS_OK
	LD	HL,M_USAGE
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	XOR	A
	JP	TERMINATE
;
ARGS_OK
	LD	A,(38FFH)
	OR	A
	JR	NZ,SYSOP_CALL
	LD	HL,(USR_NAME)
	LD	DE,($STDOUT_DEF)
	CALL	MESS_NOCR
	LD	HL,M_CALLING
	CALL	MESS_0
	LD	HL,M_SYSOP
	CALL	MESS_0
	LD	HL,M_WAIT
	CALL	MESS_0
;
	LD	B,250		;25 sec
LOOP_1
	LD	A,(38FFH)	;any keyboard key
	OR	A
	JR	NZ,SYSOP_HERE
	LD	A,B
	AND	31
	JR	NZ,NO_BEEP
;beep at user.
	LD	A,'.'
	LD	DE,($STDOUT_DEF)
	CALL	$PUT
	LD	A,' '
	CALL	$PUT
	LD	A,7
	CALL	$PUT
;if time between 2300 & 0700 don't beep the printer.
	LD	A,(4043H)
	CP	7
	JR	C,NO_BEEP
	LD	A,(4043H)
	CP	23
	JR	NC,NO_BEEP
;beep printer.
A_BEEP	LD	A,7
	LD	(37E8H),A
;
NO_BEEP	LD	A,1
	CALL	SEC10
	DJNZ	LOOP_1
;
	LD	HL,M_AWAY
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	XOR	A
	JP	TERMINATE
;
SYSOP_CALL
	LD	HL,M_SYSOP
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	LD	HL,M_CALLING
	CALL	MESS_0
	LD	HL,(USR_NAME)
	CALL	MESS_NOCR
	LD	A,CR
	CALL	$PUT
;
SYSOP_HERE
	LD	HL,0
	LD	(ABORT),HL
	LD	HL,MESS1
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
;
;start word wraparound
;
LOOP_2	LD	HL,M_PROMPT
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	CALL	LINEIN
	JR	C,POSS_EXIT
	LD	A,(LI_BUF)
	CP	'!'
	JR	NZ,LOOP_2
	JR	ESCAPE
;
;
ESCAPE	LD	HL,LI_BUF+1
	CALL	CALL_PROG
;
	LD	A,CR
	LD	DE,($STDOUT_DEF)
	CALL	$PUT
;
	JP	LOOP_2
;
POSS_EXIT
	LD	A,(3840H)
	BIT	2,A
	JR	NZ,EXIT
;else print msg & wait 20 secs for Y or N.
	LD	HL,MESS2
	LD	DE,$DO
	CALL	MESS_0
;
	LD	A,CR
	LD	DE,($STDOUT_DEF)
	CALL	$PUT
;
	LD	B,200	;20 secs.
LP_YN	LD	DE,$KI
	CALL	$GET
	AND	5FH
	CP	'Y'
	JR	Z,EXIT
	CP	'N'
	JR	Z,LOOP_2
	LD	A,1
	CALL	SEC10
	DJNZ	LP_YN
	JR	EXIT
;
EXIT
;
	LD	HL,M_THANKS
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	XOR	A
	JP	TERMINATE
;
MESS_NOCR
	LD	A,(HL)
	OR	A
	RET	Z
	CP	CR
	RET	Z
	CALL	$PUT
	INC	HL
	JR	MESS_NOCR
;
SEC10	PUSH	BC
S1_0	PUSH	AF
	LD	B,4
	LD	A,(TICKER)
	LD	C,A
S1_1	LD	A,(TICKER)
	CP	C
	LD	C,A
	JR	Z,S1_1
	DJNZ	S1_1
	POP	AF
	DEC	A
	JR	NZ,S1_0
	POP	BC
	RET
;
*GET	LINEIN
*GET	ROUTINES
;
M_THANKS	DEFM	CR,'Thanks for the chat!',CR,0
;
MESS1
	DEFM	CR,CR,0
;
M_CALLING
	DEFM	' calling ',0
M_SYSOP	DEFM	'Sysop',0
M_WAIT	DEFM	'. Please wait: ',0
;
M_AWAY	DEFM	CR,'Sorry Nick isn''t around.',CR,0
;
MESS2	DEFB	CR
	DEFM	'SYSOP: Hit <Y> to exit chat mode,',CR
	DEFM	'       or  <N> to continue chat.',CR
	DEFM	'       20 second timeout.',CR,0
;
M_USAGE	DEFM	'usage:  chat',CR,0
M_PROMPT
	DEFM	': ',0
;
THIS_PROG_END	EQU	$
;
	END	START
