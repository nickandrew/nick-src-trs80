;Exitsys - record fact of users logout.
;
*GET	DOSCALLS.HDR
*GET	EXTERNAL.HDR
*GET	ASCII.HDR
*GET	RS232.HDR
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info.
;
	COM	'<Exitsys 2.2  06-Jan-88>'
	ORG	BASE+100H
START	LD	SP,START
;
	CALL	DTR_OFF
;
	LD	A,(SYS_STAT)
	BIT	SYS_TEST,A
	JR	Z,NO_TEST	;Jump if not test
;
	RES	SYS_LOGDIN,A
	LD	(SYS_STAT),A
	CALL	UNROUTE
;
	XOR	A
	LD	(PRIV_1),A
	LD	(PRIV_2),A
	LD	(RUDE_DISC),A
;
	LD	A,(SYS_STAT)
	BIT	4,A		;=1 if booted in TEST.
	JP	Z,RUN_ANSWER
	JP	DOS		;back to Newdos.
;
NO_TEST	LD	A,(SYS_STAT)
	LD	(STAT_COPY),A
	RES	SYS_LOGDIN,A		;logout.
	LD	(SYS_STAT),A
	CALL	UNROUTE
;record hangup time for inclusion in file.
	LD	HL,HUP_TIME
	CALL	446DH
	LD	HL,PUP_TIME
	LD	DE,PUP_TIME_1
	LD	BC,8
	LDIR
	LD	HL,PUP_DATE
	LD	DE,PUP_DATE_1
	LD	BC,8
	LDIR
	LD	HL,PUP_DATE_1
	CALL	X_DATE
;
	LD	HL,BUFF
	LD	DE,S_FCB
	LD	B,16
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	CALL	UNPROT
	LD	HL,S_BUFF
	CALL	DOS_READ_SECT
	JP	NZ,ERROR
;increment total # of calls.
	LD	HL,(S_TOTAL)
	INC	HL
	LD	(S_TOTAL),HL
;
;record other info.
	LD	A,(STAT_COPY)
	BIT	SYS_LOGDIN,A
	JR	Z,NOLOGON
;increment logged-in-callers count.
	LD	HL,(S_LOGDIN)
	INC	HL
	LD	(S_LOGDIN),HL
	JR	DATA_2
NOLOGON
;;	BIT	1,A
;;Carrier seen this call
;;	JR	NZ,CARR_ONLY
;;	LD	HL,(S_BUFF+6)	;no carrier calls
;;	INC	HL
;;	LD	(S_BUFF+6),HL
;;	JR	DATA_2
;;CARR_ONLY
;;	LD	HL,(S_BUFF+4)	;didnt get logged in
;;	INC	HL
;;	LD	(S_BUFF+4),HL
;
DATA_2	LD	A,(PRIV_2)
	BIT	IS_VISITOR,A
	JR	Z,NOT_VIS
;increment count of non-member callers
	LD	HL,(S_BUFF+8)
	INC	HL
	LD	(S_BUFF+8),HL
NOT_VIS	LD	A,(STAT_COPY)
	BIT	SYS_LOGDIN,A
	JR	Z,NOT_PREM
;;	LD	A,(CD_STAT)
;;	BIT	1,A
;;	JR	Z,NOT_PREM
;increment count of hangups without logout.
;;	LD	HL,(S_BUFF+10)	;Hangup no logout
;;	INC	HL
;;	LD	(S_BUFF+10),HL
;
;write new record back.
NOT_PREM
	LD	BC,0
	CALL	DOS_POSIT
	LD	HL,S_BUFF
	CALL	DOS_WRIT_SECT
	JP	NZ,ERROR
	CALL	DOS_CLOSE
	JP	NZ,ERROR
;
;now record data in ascii file.
	LD	HL,BUFF
	LD	DE,L_FCB
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	CALL	UNPROT
	CALL	DOS_POS_EOF
	JP	NZ,ERROR
;
;if logged in write logged-in number else write
;total call number.
	LD	HL,(S_BUFF)	;total calls
	LD	A,(STAT_COPY)
	BIT	SYS_LOGDIN,A
	JR	Z,NUMB_1
;check for discrepancy between CALLER and S_BUFF+2.
	LD	HL,(CALLER)
	LD	BC,(S_BUFF+2)
	OR	A
	SBC	HL,BC
	LD	A,H
	OR	L
	LD	HL,(S_BUFF+2)
	JR	Z,NUMB_1
	LD	HL,(CALLER)
	CALL	WR_NUMB
	LD	HL,(S_BUFF+2)
;if there is a discrepancy, write both.
;first CALLER then S_BUFF+2 else write only S_BUFF+2.
NUMB_1	CALL	WR_NUMB
	LD	HL,PUP_DATE_1
	CALL	WR_STRING
	LD	HL,PUP_TIME_1
	CALL	WR_STRING
	LD	HL,HUP_TIME
	CALL	WR_STRING
; now for tests..
;;	LD	A,(STAT_COPY)
;;	BIT	1,A
;;	JR	NZ,FD_CARR
;;	LD	HL,L_NOCARR
;;	CALL	WR_STRING
;;	JP	EXIT
FD_CARR
;;	LD	A,(CD_LOSS)
;;	LD	L,A
;;	LD	H,0
;;	CALL	WR_NUMB
;
	LD	A,(STAT_COPY)
	BIT	SYS_LOGDIN,A
	JR	NZ,LOGD_ON
	LD	HL,L_NOLOGON
	CALL	WR_STRING
	JP	EXIT
;
LOGD_ON	LD	HL,(USR_NAME)
	LD	DE,L_FCB
LO_LOOP	LD	A,(HL)
	CP	CR
	JR	Z,LO_END
	OR	A
	JR	Z,LO_END
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	JR	LO_LOOP
LO_END
;check if logged out formally.
;;	LD	A,(CD_STAT)
;;	BIT	1,A
;;	JR	Z,FORMAL
;;	LD	HL,L_DISCON
;;	CALL	WR_STRING
;;	JR	EXIT
FORMAL	LD	HL,L_LOGOFF
	LD	A,(RUDE_DISC)
	OR	A
	JR	Z,LO_END1
	LD	HL,L_RUDE
LO_END1
	CALL	WR_STRING
EXIT	LD	DE,L_FCB
	CALL	DOS_CLOSE
	JP	NZ,ERROR
;zero privileges (again!)
	XOR	A
	LD	(PRIV_1),A
	LD	(PRIV_2),A
;
;If RUDE_DISC is set then stop them calling again
	LD	HL,RUDE_DISC
	LD	A,(HL)
	LD	(HL),0		;reset
	OR	A
	JR	Z,RUN_ANSWER	;if not rude
	LD	A,(STAT_COPY)
	BIT	SYS_LOGDIN,A
	JR	Z,RUN_ANSWER	;can do nothing if they
				;didn't even log in.
	CALL	MASK_OUT
;
RUN_ANSWER
	LD	HL,ANSWER
	CALL	OVERLAY
	JR	$		;forever (it failed).
;
UNROUTE				;the devices.
	LD	HL,4516H
	LD	($KBD+1),HL
	LD	HL,4505H
	LD	($VDU+1),HL
;;	LD	HL,SYS_STAT
;;	RES	3,(HL)
	LD	HL,$DO
	LD	($STDOUT),HL
	LD	($STDOUT_DEF),HL
	LD	HL,$KI
	LD	($STDIN),HL
	LD	($STDIN_DEF),HL
	RET
;
DTR_OFF
	LD	A,82H
	OUT	(WRSTAT),A
	LD	A,40H
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT1)
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT2)
	RES	DTR_BIT,A
	LD	(MODEM_STAT2),A
	OUT	(WRSTAT),A
	RET
;
UNPROT		;let a protected file be accessed.
	PUSH	DE
	INC	DE
	LD	A,(DE)
	AND	0F8H
	LD	(DE),A
	POP	DE
	RET
;
ERROR		;take the easy way out.
		;Note: The 'easy way' out was found to
		;be insufficient after 1 exitsys error
		;exit. The appropriate error code is
		;now displayed.
	PUSH	AF
	LD	HL,M_EXITERR
	CALL	LOG_MSG
;
	POP	AF
	PUSH	AF
	OR	80H
	CALL	DOS_ERROR	;Display error on screen
				;Log to printer if ERRLOG
;
	XOR	A
	LD	(SYS_STAT),A
	LD	(PRIV_1),A
	LD	(PRIV_2),A
	LD	(RUDE_DISC),A
;
	LD	HL,ANSWER
	CALL	OVERLAY
;Darn. Failed.
	JR	$		;Forever
;
WR_NUMB	XOR	A
	LD	(FLAG),A
	LD	DE,10000
	CALL	PRINT_CHAR
	LD	DE,1000
	CALL	PRINT_CHAR
	LD	DE,100
	CALL	PRINT_CHAR
	LD	DE,10
	CALL	PRINT_CHAR
	LD	DE,1
	LD	A,E
	LD	(FLAG),A
	CALL	PRINT_CHAR
	LD	A,' '
	LD	DE,L_FCB
	CALL	$PUT
	JP	NZ,ERROR
	RET
;
PRINT_CHAR
	LD	B,2FH
PC_1	INC	B
	OR	A
	SBC	HL,DE
	JR	NC,PC_1
	ADD	HL,DE
	LD	A,(FLAG)
	OR	A
	JR	NZ,PC_2
	LD	A,B
	CP	'0'
	LD	A,' '
	JR	Z,PC_3
PC_2	LD	A,1
	LD	(FLAG),A
PC_3	LD	A,B
	LD	DE,L_FCB
	CALL	$PUT
	JP	NZ,ERROR
	RET
;
WR_STRING
	LD	DE,L_FCB
WS_1
	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	JR	WS_1
;
;mask_out: Set UF_ST_NOTUSER,(UF_STATUS) in userfile.
MASK_OUT
	LD	HL,(USR_NAME)
	CALL	USER_SEARCH
	JP	NZ,ERROR
;name found & data in buffer.
	LD	HL,UF_STATUS
	SET	UF_ST_NOTUSER,(HL)
;Now rewrite record to disk....
	LD	DE,US_FCB
	LD	HL,(US_RBA+1)
	LD	A,(US_RBA)
	LD	C,A
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	LD	HL,US_UBUFF
	LD	B,UF_LRL
REWR_1	LD	A,(HL)
	CALL	$PUT
	INC	HL
	DJNZ	REWR_1
	CALL	DOS_CLOSE
	JP	NZ,ERROR
	RET			;Done!
;
*GET	ROUTINES
;
STAT_COPY DEFB	0
FLAG	DEFB	0
;
S_FCB	DEFM	'stats.zms',CR
	DC	32-10,0
;
S_BUFF
S_TOTAL		DEFW	0
S_LOGDIN	DEFW	0
S_CARRIER	DEFW	0	;?
S_NOCARR	DEFW	0
S_VISITORS	DEFW	0	;?
S_DISCON	DEFW	0
		DEFW	0
		DEFW	0
;
L_FCB	DEFM	'log.zms',CR
	DC	32-8,0
;
PUP_TIME_1
	DEFM	'HH:MM:SS to ',0
PUP_DATE_1
	DEFM	'DD-MMM-YY ',0
HUP_TIME
	DEFM	'HH:MM:SS ',0
;
L_NOCARR
	DC	6,' '
	DEFM	'No carrier found',CR,0
L_NOLOGON
	DEFM	'Didn''t log on',CR,0
;
L_DISCON DEFM	' (Discon)',CR,0
L_LOGOFF DEFM	CR,0
L_RUDE	 DEFM	' (Rude)',CR,0
;
M_EXITERR
	DEFM	'** EXITSYS ** Error encountered.',CR,0
;
ANSWER	DEFM	'Answer',0
;
BUFF	DEFS	256
;
THIS_PROG_END	NOP
;
	END	START
