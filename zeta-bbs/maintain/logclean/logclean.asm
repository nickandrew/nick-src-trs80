;Logclean: Truncate from the front of the printed log.
;
MAX_SIZE	EQU	45
MIN_SIZE	EQU	35
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info.
;
	COM	'<Logclean 1.0b 14-Feb-88>'
	ORG	BASE+100H
START	LD	SP,START
;
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JR	NZ,LOGC_1
	LD	HL,M_SORRY
	LD	DE,($STDOUT)
	CALL	PUTS
	LD	A,128
	JP	TERMINATE
;
LOGC_1
;
;
	LD	HL,LOG_CLOSE
	CALL	LOG_MSG		;Close disk log.
;
	LD	HL,BUFF_IN
	LD	DE,FCB_IN
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
;
	LD	A,(FCB_IN+1)
	AND	0F8H
	LD	(FCB_IN+1),A
;
	LD	HL,(FCB_IN+12)	;middle, high EOF.
	LD	DE,MAX_SIZE
	OR	A
	SBC	HL,DE
	JR	C,NOSHORT
	LD	DE,MAX_SIZE-MIN_SIZE	;Amount to bypass
	ADD	HL,DE
	PUSH	HL
	POP	BC
LOGC_2
	PUSH	BC
	LD	DE,FCB_IN
	CALL	DOS_READ_SECT
	JP	NZ,ERROR
	POP	BC
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,LOGC_2
;
LOGC_3	CALL	ROM@GET
	JP	NZ,ERROR
	CP	CR
	JR	NZ,LOGC_3
;
	LD	HL,BUFF_OUT
	LD	DE,FCB_OUT
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
;
	LD	A,(FCB_OUT+1)
	AND	0F8H
	LD	(FCB_OUT+1),A
;
;Now copy...
LOGC_4	LD	DE,FCB_IN
	CALL	ROM@GET
	JR	NZ,LOGC_5
	LD	DE,FCB_OUT
	CALL	ROM@PUT
	JP	NZ,ERROR
	JR	LOGC_4
;
NOSHORT
;
;Reopen log file
	LD	HL,LOG_OPEN
	CALL	LOG_MSG
;
	LD	HL,M_SHORT
	LD	DE,($STDOUT)
	CALL	FPUTS
;
	LD	A,129
	JP	TERMINATE
;
LOGC_5	CP	1CH
	JR	Z,LOGC_6
	CP	1DH
	JP	NZ,ERROR
LOGC_6	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	JP	NZ,ERROR
;
;Reopen log file.
	LD	HL,LOG_OPEN
	CALL	LOG_MSG
;
;Send a 'Cleaned.' message to the file.
	LD	HL,M_CLEANED
	CALL	LOG_MSG
;
	XOR	A
	JP	TERMINATE
;
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
;
	LD	HL,LOG_OPEN	;should be before!
	CALL	LOG_MSG
;
	POP	AF
	JP	TERMINATE
;
*GET	FPUTS
*GET	PUTS
;
LOG_CLOSE	DEFB	3,0	;close the log file.
LOG_OPEN	DEFB	4,0	;open the log file.
;
FCB_IN	DEFM	'printer.log',ETX
	DC	32-12,0
FCB_OUT	DEFM	'printer.log',ETX
	DC	32-12,0
;
M_SORRY	DEFM	'Erasing all trace of your call now',CR,0
M_SHORT	DEFM	'Log file too short to truncate.',CR,0
M_CLEANED
	DEFM	CR,'*** Log cleaned ***',CR,0
;
STAT_SAVED
	DEFB	0
BUFF_IN	DEFS	256
BUFF_OUT
	DEFS	256
;
THIS_PROG_END	EQU	$
;
	END	START
