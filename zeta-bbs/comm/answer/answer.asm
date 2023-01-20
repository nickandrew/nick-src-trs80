;answer: telephone answer & initial connection program
;
; 4.0d 20 May 90 Remove reference to ACSnet and Fidonet addresses
; 4.0c 24 Mar 90 Use ftalk2 instead of ftalk when answering Fidonet
; 4.0b 12 Aug 89 Re-enable V21 carrier, and give a short message when
;	somebody attempts to logon.
; 4.0a 24 Jul 89 Stop answering phone during incoming call
;	(When modem says "RING", it is eventually followed by either a
;	"CONNECT" or "NO CARRIER" ... so go into another checking loop)
; 4.0  02 Jul 89 Restructured somewhat...
; 3.3p  	Lock out V21 callers
;		Ensure modem always talks to us at v22
;		Change "modem online, start" to start at current rate
; 3.3o:		Add "waiting for carrier" message
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
*GET	RS232
;
$TA	EQU	0FF38H		;Type ahead.
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	TERMINATE
;End of program load info.
;
	COM	'<Answer 4.0d 20 May 90>'
	ORG	BASE+100H
START
	LD	SP,START
	LD	A,(SYS_STAT)	;check status
	BIT	SYS_LOGDIN,A
	JR	Z,ANS_01
;
	LD	HL,M_42
	LD	DE,DCB_2O
	CALL	MESS_0		;Print a cute message
	LD	A,2
	JP	TERMINATE	;if already logged on
;
ANS_01
	LD	A,1		;Set CPU fast.
	OUT	(0FEH),A
;
	LD	A,OM_COOKED
	LD	(OUTPUT_MODE),A
;
	LD	HL,CD_STAT
	RES	CDS_DISCON,(HL)
;
	CALL	DTR_OFF
	CALL	SET_1200	;For netcomm
;
	LD	HL,MODEM_1A	;reset the lot
	CALL	MODEM_PUTS
	LD	HL,MODEM_1B
	CALL	MODEM_PUTS
	LD	HL,MODEM_1E
	CALL	MODEM_PUTS
;
	CALL	DTR_ON
;
	CALL	RESET_DCB
;
	CALL	SET_SCREEN	;Std dev point to screen
;
	LD	A,0A2H		;Trs-80 for sysop
	LD	(TFLAG2),A
	XOR	A
	LD	(RUDE_DISC),A
	CALL	ZERO_TA		;squash type-ahead.
;
;Set VISITOR permissions to prevent rude words.
	LD	A,1BH
	LD	(PRIV_1),A
	LD	A,0BH
	LD	(PRIV_2),A
;
	LD	HL,M_RUNNING	;running answer
	LD	DE,$DO
	CALL	MESS_0
;
;if TEST mode don't signal HANGUP. Just reset mode
	LD	HL,SYS_STAT
	BIT	6,(HL)
	JR	Z,ANS_02
	RES	6,(HL)		;Reset TEST mode.
	JR	ANS_03
;
ANS_02
;signal termination of previous call.
	CALL	T_STR		;time in string
	LD	HL,TIMDAT
	CALL	LOG_MSG
	LD	HL,M_HUP
	CALL	LOG_MSG
;
ANS_03
;Wait for call to come in
CDLOOP
	LD	HL,M_WAITING
	LD	DE,$DO
	CALL	MESS_0
CDL_00
	CALL	MODEM_CHAR
	OR	A
	CP	'2'		;ring signal
	JR	Z,CDL_02	;Ringing
	CP	'3'		;no carrier
	JP	Z,CD_NOCARR
	CP	'1'		;1=Conn 300. 10=Conn 2400
	JP	Z,CD_VAR
	CP	'5'		;connect 1200 (/75?)
	JP	Z,CD_1200
	CP	'0'
	JR	Z,CDL_00	;ok
;
	LD	A,(CD_MODE)
	AND	0FH
	CP	4
	JR	NZ,CDL_01
	LD	HL,M_BADMODE
	CALL	LOG_MSG
	XOR	A
	LD	(CD_MODE),A
CDL_01
;
	CALL	CHECK_CRON
	CALL	CHECK_KEYB
;
	CALL	TIME_RING
	JR	CDL_00
;
; Telephone rang, so wait for a connect or a no carrier
CDL_02
	CALL	CD_RING		;Print ring message, set ring time to 0
CDL_03
	CALL	MODEM_CHAR
	CP	'2'		;ring signal
	JR	Z,CDL_02
	CP	'3'		;no carrier
	JP	Z,CD_NOCARR
	CP	'1'		;1=Conn 300. 10=Conn 2400
	JP	Z,CD_VAR
	CP	'5'		;connect 1200 (/75?)
	JP	Z,CD_1200
	CP	'0'
	JR	Z,CDL_00	;ok
;Do not check cron here, as somebody is calling us!
	CALL	CHECK_KEYB
;
	CALL	TIME_RING
	JR	CDL_03
;
; - record actions then rerun answer.
CD_NOCARR
	LD	HL,PUP_TIME	;Record pickup time/date
	CALL	446DH
	LD	HL,PUP_DATE
	CALL	4470H
;
	CALL	T_STR		;time in string
	LD	HL,TIMDAT	;{dd-mmm-yy ....
	CALL	LOG_MSG
	LD	HL,M_NOCARR
	CALL	LOG_MSG
	LD	HL,M_NOCARR	;Display no carrier
	LD	DE,$DO
	CALL	MESS_0
;
	JP	CDL_00
;
CD_1200
	CALL	SET_1200
	CALL	LOG_PICKUP
	LD	A,(RING_TIME)
	CP	60		;if >12 seconds.
	JR	NC,CD_1200_75
	LD	HL,M_FDCARR_V22
	LD	DE,$DO
	CALL	MESS_0
	LD	HL,M_FDCARR_V22
	CALL	LOG_MSG
	JR	CDFOUND
;
CD_1200_75
	LD	HL,M_FDCARR_V23
	LD	DE,$DO
	CALL	MESS_0
	LD	HL,M_FDCARR_V23
	CALL	LOG_MSG
	JR	CDFOUND
;
;Modem detected carrier at either 300 BPS or 2400 BPS.
CD_VAR
	CALL	MODEM_CHAR
	OR	A
	JR	Z,CD_VAR
	CP	CR
	JR	Z,CD_300_2
	CP	'0'		;'10'=connect 2400
	JP	Z,CD_2400
;
CD_300_2
	CALL	SET_300
;
	CALL	LOG_PICKUP
	LD	HL,M_FDCARR_V21
	LD	DE,$DO
	CALL	MESS_0
	LD	HL,M_FDCARR_V21
	CALL	LOG_MSG
;
	LD	HL,M_TOOSLOW
	LD	DE,DCB_2O
	CALL	MESS_0
;
	LD	A,100		;Delay 10 full seconds
	CALL	SEC10
;
	CALL	DTR_OFF		;Boot them off, quick
;
	LD	A,10		;Wait 1 second with DTR off.
	CALL	SEC10
	JP	ANS_01		;Not structured, but re-init.
;
CD_2400
	CALL	SET_2400
	CALL	LOG_PICKUP
	LD	HL,M_FDCARR_BIS
	LD	DE,$DO
	CALL	MESS_0
	LD	HL,M_FDCARR_BIS
	CALL	LOG_MSG
	JR	CDFOUND
;
;A carrier was found at a valid speed. We have set our comms speed.
CDFOUND
	LD	A,1
	CALL	SEC10
	CALL	CARR_DETECT
;
	LD	A,20		;Wait 2 seconds
	CALL	SEC10
	CALL	MODEM_FLUSH
;
	CALL	T_STR
	LD	HL,TIMDAT	;Output time/date
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	HL,M_ZETA	;Output Zeta message
	CALL	MESS_0
;
;This 5 second long loop waits for TSYNC char from Fido.
	LD	DE,0200		;5 sec delay
	LD	A,(TICKER)
	LD	C,A
SWAIT_1	PUSH	DE
	CALL	MODEM_CHAR
SWAIT_1Z
	CP	TSYNC
	JP	Z,FIDO_CALL
	CP	ESC
	JR	Z,NOT_FIDO
	CP	'!'
	JR	Z,NOT_FIDO
	CP	CR
	JR	Z,SWAIT_1B
	CP	' '
	JR	Z,SWAIT_1B
	JR	SWAIT_2
;
SWAIT_1B
	LD	HL,M_DUMMY
SWAIT_1A
	LD	A,(HL)
	OR	A
	JR	Z,SWAIT_2
	CALL	MODEM_PUTC
	CALL	MODEM_CHAR	;Get character if any
	CP	TSYNC		;Only check for TSYNC
	JP	Z,FIDO_CALL	;Go if found one!
	INC	HL
	JR	SWAIT_1A
;
SWAIT_2
	POP	DE
	LD	A,(TICKER)
	CP	C
	LD	C,A
	JR	Z,SWAIT_1
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,SWAIT_1
	JR	NOT_FIDO
;
;End of fido checking loop.
NOT_FIDO
	CALL	ROUTE_DEV	;after not fido
;
	LD	A,0BFH		;LF required terminal
	LD	(TFLAG2),A
	LD	HL,APB		;list the intro
	CALL	LISTFILE
;
	JR	RUN_LOGON
;
;Run the user logon program.
RUN_LOGON
	LD	HL,CMD_LOGON
	CALL	OVERLAY		;execute LOGON prog
	JP	$		;Failed. Darn.
;
T_STR
	LD	HL,DATE
	CALL	X_TODAY
	LD	HL,TIME
	CALL	446DH
	RET
;
;Do ring timing. Count 1/5 second intervals.
TIME_RING
	LD	A,(RING_TICK)
	LD	B,A
	LD	A,(TICKER)
	AND	0F8H		;ignore low 3 bits
	CP	B
	RET	Z
	LD	(RING_TICK),A
	LD	HL,RING_TIME
	INC	(HL)
	LD	HL,3C3FH
	INC	(HL)
	RET
;
CD_RING
	LD	HL,M_RING
	LD	DE,$DO
	CALL	MESS_0
;
	XOR	A
	LD	(RING_TIME),A
	RET
;
LOG_PICKUP
	LD	HL,PUP_TIME	;Record pickup time/date
	CALL	446DH
	LD	HL,PUP_DATE
	CALL	4470H
;
	CALL	T_STR		;time in string
	LD	HL,TIMDAT	;{dd-mmm-yy ....
	CALL	LOG_MSG
	RET
;
CHECK_CRON
	LD	A,(4041H)	;sec
	OR	A
	RET	NZ
	LD	A,(4042H)	;min
	OR	A
	RET	NZ
;
	LD	HL,0
	LD	(DISCON),HL
;
	CALL	CRON
;
	CALL	SET_1200
	LD	HL,0
	LD	(CD_MODE),HL
;
	LD	A,1
	CALL	SEC10
;
	LD	HL,CD_STAT
	RES	CDS_DISCON,(HL)
;
	LD	HL,TERMINATE
	LD	(DISCON),HL
;
	LD	DE,0		;reset counters
	RET
;
HAYES
	LD	HL,M_HAYES
	LD	DE,$DO
	CALL	MESS_0
	LD	HL,STRING
	LD	B,30
	CALL	40H
	JP	C,SP_FUNC
	LD	HL,STRING
HAYES1	LD	A,(HL)
	INC	HL
	CP	CR
	JR	NZ,HAYES1
	LD	(HL),0
	LD	HL,STRING
	CALL	MODEM_PUTS
	JR	HAYES
;
ONLINE
	LD	HL,MODEM_ATO
	CALL	MODEM_PUTS
	JP	CDFOUND
;
CALL_FND
	CALL	SET_1200
	LD	HL,MODEM_4	;order it to answer
	CALL	MODEM_PUTS	;answer phone
	JP	CDLOOP		;wait for results
;
CHECK_KEYB
	LD	DE,$KI
	CALL	$GET
	CP	1FH		;CLEAR key
	JP	Z,SP_FUNC_JP
	RET
;
;Special function
SP_FUNC_JP
	POP	AF		;return address
SP_FUNC
	LD	HL,M_SPFUNC
	LD	DE,$DO
	CALL	MESS_0
GET_FN	LD	HL,M_SPPMT
	CALL	MESS_0
	LD	HL,STRING
	LD	B,2
	CALL	40H
	JP	C,CDLOOP	;break = do nothing
	LD	A,(HL)
	CP	'!'		;=shell esc
	JP	Z,SHELL_ESC
	CP	'$'
	JP	Z,SYSTEM_ESC
	CP	CR
	JP	Z,CDLOOP	;do nothing
	CP	'a'
	JR	C,GF_0
	AND	5FH
GF_0
	LD	(HL),A
	CP	'A'
	JR	Z,CALL_FND	;Answer via ATA
	CP	'H'
	JP	Z,HAYES		;Hayes command.
	CP	'O'
	JP	Z,ONLINE	;Modem is online!
	CP	'S'
	JR	Z,SHUTDOWN	;Shut down the system
	CP	'T'
	JR	Z,SET_TEST	;Test system
	CP	'1'
	JR	NZ,GF_1
	CALL	SET_1200	;Set speed to 1200
	JR	ATTN
GF_1	CP	'2'
	JR	NZ,GF_2
	CALL	SET_2400
	JR	ATTN
GF_2	CP	'3'
	JR	NZ,GF_3
	CALL	SET_300
ATTN	LD	HL,MODEM_AT
	CALL	MODEM_PUTS
	JR	SP_FUNC
GF_3
	JR	SP_FUNC
;
;set TEST mode. run LOGON for sysop.
SET_TEST
	LD	HL,SYS_STAT
	SET	6,(HL)
;
	CALL	SET_1200
	CALL	SET_STDDEV
;
	LD	HL,MODEM_ATH1	;stop it answering
	CALL	MODEM_PUTS
	JP	RUN_LOGON
;
SHUTDOWN
	LD	HL,MODEM_ATH1	;Stop it answering
	CALL	MODEM_PUTS
	CALL	T_STR
	LD	HL,TIMDAT
	CALL	LOG_MSG
	LD	HL,M_SHUTDN
	CALL	LOG_MSG
;
	LD	HL,SYS_STAT	;Set test mode
	SET	6,(HL)
	JP	DOS_NOERROR		;Valid jump to dos.
;
SHELL_ESC			;A shell escape.
	LD	HL,NICK		;as nick
	CALL	SYSTEM_LOGON
	LD	HL,M_ESC
	CALL	PUTS
	LD	HL,STRING
	LD	B,60
	CALL	40H
	CALL	NC,CALL_PROG
	CALL	SYSTEM_LOGOUT	;shell escape
	JP	CDLOOP		;Wait for carrier again
;
SYSTEM_ESC
	LD	HL,SYSTEM
	CALL	SYSTEM_LOGON
	LD	HL,M_ESC
	CALL	PUTS
	LD	HL,STRING
	LD	B,60
	CALL	40H
	CALL	NC,CALL_PROG
	CALL	SYSTEM_LOGOUT	;shell escape
	JP	CDLOOP		;Wait for carrier again
;
CRON
	LD	HL,SYSTEM
	CALL	SYSTEM_LOGON
;
	LD	HL,CMD_CRON	;Run cron now!
	CALL	CALL_PROG
;
	CALL	SYSTEM_LOGOUT
	RET
;
SYSTEM_LOGON
	PUSH	HL
	CALL	DTR_OFF
	LD	A,1
	CALL	SEC10
	LD	HL,MODEM_ATH1	;Stop it answering
	CALL	MODEM_PUTS
;
	POP	HL		;login name
	LD	DE,(USR_NAME)	;Set the name
SL_01	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	NZ,SL_01
	EX	DE,HL
	LD	(HL),0		;Set name terminator
	DEC	HL
	LD	(HL),CR
;
	LD	A,0FFH		;System privileges!
	LD	(PRIV_1),A
	LD	A,09H		;Log commands.
	LD	(PRIV_2),A
	LD	A,(SYS_STAT)
	OR	60H		;set TEST & LOGDIN
	LD	(SYS_STAT),A
;
	CALL	ROUTE_DEV	;system logon
;
	LD	HL,2		;=Sysops number
	LD	(USR_NUMBER),HL
	RET
;
SYSTEM_LOGOUT
	LD	A,1BH		;Back to visitor privs
	LD	(PRIV_1),A
	LD	A,0BH
	LD	(PRIV_2),A
	LD	A,(SYS_STAT)
	AND	09FH		;reset TEST & LOGDIN
	LD	(SYS_STAT),A
	LD	HL,0FFFFH	;Null userid
	LD	(USR_NUMBER),HL
;
	CALL	RESET_DCB
;
	CALL	DTR_OFF
	LD	A,1
	CALL	SEC10
;
	LD	HL,CD_STAT
	RES	CDS_DISCON,(HL)
;
	CALL	SET_1200
	LD	HL,MODEM_ATZ
	CALL	MODEM_PUTS
;
	CALL	DTR_ON
	LD	A,1
	CALL	SEC10
	RET
;
RESET_DCB
	LD	HL,4516H
	LD	($KBD+1),HL
	LD	HL,4505H
	LD	($VDU+1),HL
	RET
;
SET_SCREEN
;Set all new devices to point to vdu
	LD	HL,$DO
	LD	($STDOUT),HL
	LD	($STDOUT_DEF),HL
	LD	HL,$KI
	LD	($STDIN),HL
	LD	($STDIN_DEF),HL
	RET
;
ZERO_TA
	XOR	A
	LD	($TA+3),A
	LD	($TA+4),A
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
DTR_ON
	LD	A,82H		;Re-init USART
	OUT	(WRSTAT),A
	LD	A,40H
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT1)
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT2)
	SET	DTR_BIT,A
	LD	(MODEM_STAT2),A
	OUT	(WRSTAT),A
	RET
;
ROUTE_DEV
	LD	HL,(DCB_2I+1)	;Route devices
	LD	($KBD+1),HL
	LD	HL,(DCB_2O+1)
	LD	($VDU+1),HL
;
	CALL	SET_STDDEV
;
	CALL	ZERO_TA
	RET
;
SET_STDDEV
;Set standard devices.
	LD	HL,DCB_2O
	LD	($STDOUT),HL
	LD	($STDIN),HL
	LD	($STDOUT_DEF),HL
	LD	($STDIN_DEF),HL
	RET
;
FIDO_CALL			;handle a call from Fido
	CALL	FIDO_LOGIN
;
	LD	HL,M_FIDO
	LD	DE,$DO
	CALL	MESS_0
;
	LD	HL,CMD_GETPKT
	CALL	CALL_PROG
	CALL	SYSTEM_LOGOUT
	JP	CDLOOP
;
;;	LD	HL,CMD_GETPKT
;;	CALL	OVERLAY
;;	JP	$		;Overlay failed. darn.
;
FIDO_LOGIN
	LD	HL,FIDO_NAME
	LD	DE,(USR_NAME)
	LD	BC,14
	LDIR
;
	LD	A,0FFH
	LD	(PRIV_1),A
	LD	A,09H
	LD	(PRIV_2),A
	LD	HL,2
	LD	(USR_NUMBER),HL
;
	CALL	LOG_PICKUP
;"Fido Network" is now logged in.
	RET
;
MODEM_CHAR
	IN	A,(RDSTAT)	;check status
	BIT	DAV_BIT,A
	LD	A,0
	RET	Z
	IN	A,(RDDATA)	;read char
	RET
;
MODEM_FLUSH
	IN	A,(RDDATA)
	NOP
	IN	A,(RDDATA)
	NOP
	IN	A,(RDDATA)
	RET
;
MODEM_PUTC
	LD	C,A
MP_1	IN	A,(RDSTAT)
	BIT	CTS_BIT,A
	JR	Z,MP_1
	LD	A,C
	OUT	(WRDATA),A
	RET
;
MODEM_GPUTS
;Output a string. Ignore its echo. Read a reply from the modem in HL.
MG_01
	LD	A,(HL)
	OR	A
	JR	Z,MG_02
	CALL	MODEM_PUTC
	CALL	MODEM_GCHAR_1		;0.1 second maximum wait
	INC	HL
	JR	MG_01
MG_02
	LD	B,64			;A maximum length
MG_03
	CALL	MODEM_GCHAR_10		;1 second maximum wait
	JR	C,MG_04			;No response
	LD	(DE),A
	INC	DE
	DJNZ	MG_03
MG_04	XOR	A
	LD	(DE),A
	RET
;
MODEM_GCHAR_1
	LD	A,(TICKER)
	ADD	A,4
	LD	C,A
MG1_01	LD	A,(TICKER)
	CP	C
	SCF
	RET	Z
	CALL	MODEM_CHAR
	JR	Z,MG1_01
	OR	A
	RET
;
MODEM_GCHAR_10
	LD	A,(TICKER)
	ADD	A,40
	LD	C,A
MG10_01	LD	A,(TICKER)
	CP	C
	SCF
	RET	Z
	CALL	MODEM_CHAR
	JR	Z,MG10_01
	OR	A
	RET
;
MODEM_PUTS
	CALL	MODEM_CHAR_SHOW
	LD	A,(HL)
	OR	A
	JR	Z,MODEM_ACK
	CALL	MODEM_PUTC
	INC	HL
	JR	MODEM_PUTS
;
MODEM_ACK
	LD	A,(TICKER)
	ADD	A,40
	LD	B,A
MA_01	LD	A,(TICKER)
	CP	B
	RET	Z
	CALL	MODEM_CHAR_SHOW
	JR	MA_01
;
MODEM_CHAR_SHOW
	CALL	MODEM_CHAR
	OR	A
	RET	Z
	CP	LF
	RET	Z
	LD	DE,$DO
	CALL	$PUT
	RET
;
SET_300
	LD	A,82H		;Re-init USART
	OUT	(WRSTAT),A
	LD	A,40H
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT1)	;??,8,n,1
	AND	0FCH
	OR	3		;set to 300 baud
	LD	(MODEM_STAT1),A
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT2)
	RES	RTS_BIT,A	;reset "double speed"
	LD	(MODEM_STAT2),A
	OUT	(WRSTAT),A
	RET
;
SET_1200
	LD	A,82H
	OUT	(WRSTAT),A
	LD	A,40H
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT1)
	AND	0FCH
	OR	02H		;set to 1200 baud
	LD	(MODEM_STAT1),A
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT2)
	RES	RTS_BIT,A	;reset "double speed"
	LD	(MODEM_STAT2),A
	OUT	(WRSTAT),A
	RET
;
SET_2400
	LD	A,82H
	OUT	(WRSTAT),A
	LD	A,40H
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT1)
	AND	0FCH
	OR	02H		;set to 1200 baud
	LD	(MODEM_STAT1),A
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT2)
	SET	RTS_BIT,A	;set "double speed".
	LD	(MODEM_STAT2),A
	OUT	(WRSTAT),A
	RET
;
;List a file to the dual output
LISTFILE
	LD	DE,FCB_LIST
	CALL	EXTRACT
	LD	HL,BUF_LIST
	LD	B,0
	CALL	DOS_OPEN_EX
	RET	NZ
LF_01
	LD	DE,FCB_LIST
	CALL	$GET
	JR	NZ,LF_02
	LD	DE,DCB_2O
	CALL	$PUT
	JR	LF_01
;
LF_02
	LD	DE,FCB_LIST
	CALL	DOS_CLOSE
	RET
;
;Include common routines.
*GET	ROUTINES
;
MODEM_1A	DEFM	'AT&FB2&T5',CR,0
MODEM_1B	DEFM	'AT v0 x1 h0 s0=3 s2=255 s11=8',CR,0
MODEM_1E	DEFM	'AT m1 b2 &w',CR,0
MODEM_1F	DEFM	'ATB0M1',CR,0	;1200 or 2400 bps
MODEM_AT	DEFM	'AT',CR,0
MODEM_ATO	DEFM	'ATO',CR,0
MODEM_ATH1	DEFM	'ATH1',CR,0
MODEM_ATH0	DEFM	'ATH0',CR,0
MODEM_ATZ	DEFM	'ATZ',CR,0
MODEM_4		DEFM	'ATA',CR,0
;
M_FIDO		DEFM	CR,CR,'** Fidonet transfer underway **',CR,0
M_RING		DEFM	' Ring ... ',0
M_HAYES		DEFM	'Hayes command: ',0
FIDO_NAME	DEFM	'Fido Network',CR,0
LAST_TICK	DEFB	0
RING_TIME	DEFB	0
RING_TICK	DEFB	0
;
M_SPFUNC
	DEFM	CR,'Zeta special functions...',CR,CR
	DEFM	'"S": Shut the system down          "T": Enter Test mode',CR
	DEFM	'"A": Perform answer sequence       ',CR
	DEFM	'"O": Modem online, start session   "H": Issue Hayes commands',CR
	DEFM	'"!": Command Escape ... as Nick    "$": Commands ... as System',CR
	DEFM	'"1": Set 1200 bps     "2" Set 2400 bps    "3" Set 300 bps',CR
	DEFM	CR,0
;
M_TOOSLOW
	DEFM	CR,CR
	DEFM	'Thank you for calling Zeta.  This system no longer supports',CR
	DEFM	'V21 (300 bps) callers.  Modem speeds supported are:',CR
	DEFM	'    V22bis  (2400 bps)',CR
	DEFM	'    V22     (1200 bps)',CR
	DEFM	'and V23     (1200/75 bps Ascii)',CR
	DEFM	CR
	DEFM	'For more information about Zeta, please send a SASE to:',CR
	DEFM	'        Zeta Microcomputer Software',CR
	DEFM	'        P.O Box 177,',CR
	DEFM	'        Riverstone NSW 2765',CR
	DEFM	'and mention that you attempted to call at 300 bps.',CR
	DEFM	CR
	DEFM	CR,0
;
M_SPPMT		DEFM	'Function > ',0
;
M_SHUTDN	DEFM	'Shutdown.',CR,3,0	;close log
;
M_42		DEFM	CR,'      42',CR,CR,0
;
M_NOCARR	DEFM	'No carrier found',CR,0
M_FDCARR_V21	DEFM	'Found V21 carrier!',CR,0
M_FDCARR_V22	DEFM	'Found V22 carrier',CR,0
M_FDCARR_BIS	DEFM	'Found V22bis carrier',CR,0
M_FDCARR_V23	DEFM	'Found V23 carrier',CR,0
;
CMD_LOGON	DEFM	'Logon',0
CMD_EXITSYS	DEFM	'Exitsys',0
CMD_CRON	DEFM	'Cron',0
CMD_GETPKT	DEFM	'Ftalk2 -l',0
;
M_RUNNING	DEFM	CR,'Running Answer',CR,0
;
;M_hup contains 01H byte which closes & re-opens
;system log file.
M_HUP		DEFM	'Hangup',CR,CR,1,0
;
TIMDAT
DATE		DEFM	'DD-MMM-YY  '
TIME		DEFM	'HH:MM:SS : ',0
;
APB		DEFM	'APB.ZMS',CR
;
M_ZETA		DEFM	CR,LF,CR,LF
		DEFM	'Welcome to Zeta, O modem user!'
		DEFM	CR,LF,CR,LF,0
M_DUMMY		DEFM	'Please be patient!',CR,LF,0
SYSTEM		DEFM	'System',0
NICK		DEFM	'Nick Andrew',0
M_ESC		DEFM	CR,'System escape >',0
M_BADMODE	DEFM	'Mode number 4 detected!',CR,0
M_WAITING	DEFM	CR,'Waiting for call',CR,0
;
STRING		DC	64,0
FCB_LIST	DEFS	32
BUF_LIST	DEFS	256
;
THIS_PROG_END	EQU	$
;
	END	START
