; @(#) dialout.asm - Poll one of our neighbours using Fidonet protocol
;
; 1.1f  11 Jun 90	Make it fidonet.hdr independant except for gate_num
; 1.1e  20 May 90	Change net number for ACSgate
; 1.1d  13 May 90	Change ACSgate to 2400 bps
;			Also shorten some stimulus strings & change passwd
;			Use fidonet.hdr for node numbers for ftalk.
; 1.1c  24 Mar 90	Add ability to call John Cepak and Ian Hunter
;			When finishing, do ATH1 not ATH0.
; 1.1b	16 Aug 89	Increase carrier detect interval when dialling
; 1.1a	31 May 89	Base version
;
*GET	DOSCALLS.HDR
*GET	EXTERNAL.HDR
*GET	ASCII.HDR
*GET	RS232.HDR
*GET	FIDONET.HDR
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	REEXIT
;End of program load info.
;
	COM	'<Dialout 1.1f 11 Jun 90>'
	ORG	BASE+100H
;
START	LD	SP,START
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JR	Z,EXIT
	LD	A,(HL)
	CALL	TO_UPPER_C
	CP	'A'
	JR	Z,DIAL_ACSGATE
	CP	'C'
	JR	Z,DIAL_CEPAK
	CP	'H'
	JR	Z,DIAL_HUNTER
	CP	'P'
	JR	Z,DIAL_PROPHET
	CP	'X'
	JP	Z,DIAL_RANDOM
	JR	EXIT
;
EXIT	XOR	A
	LD	HL,0
	JP	TERMINATE
;
DIAL_ACSGATE
	LD	HL,M_ACSGATE
	CALL	LOG_THIS
	LD	A,1
	LD	(F_ULOGIN),A	;Unix login
	LD	A,(REDL_ACSGATE)
	LD	(REDIALS),A
	LD	HL,POLL_ACSGATE
	LD	(POLL_STRING),HL
	LD	HL,PH_ACSGATE
	LD	(DIAL_CMD),HL
	CALL	SET_FIDO_NAME
	CALL	SET_2400
	JP	DIAL_OUT
;
DIAL_CEPAK
	LD	HL,M_CEPAK
	CALL	LOG_THIS
	XOR	A
	LD	(F_ULOGIN),A	;No unix login
	LD	A,(REDL_CEPAK)
	LD	(REDIALS),A
	LD	HL,POLL_CEPAK
	LD	(POLL_STRING),HL
	LD	HL,PH_CEPAK
	LD	(DIAL_CMD),HL
	CALL	SET_FIDO_NAME
	CALL	SET_2400
	JP	DIAL_OUT
;
DIAL_HUNTER
	LD	HL,M_HUNTER
	CALL	LOG_THIS
	XOR	A
	LD	(F_ULOGIN),A	;No unix login
	LD	A,(REDL_HUNTER)
	LD	(REDIALS),A
	LD	HL,POLL_HUNTER
	LD	(POLL_STRING),HL
	LD	HL,PH_HUNTER
	LD	(DIAL_CMD),HL
	CALL	SET_FIDO_NAME
	CALL	SET_2400
	JP	DIAL_OUT
;
DIAL_PROPHET
	LD	HL,M_PROPHET
	CALL	LOG_THIS
	XOR	A
	LD	(F_ULOGIN),A	;No unix login
	LD	A,(REDL_PROPHET)
	LD	(REDIALS),A
	LD	HL,POLL_PROPHET
	LD	(POLL_STRING),HL
	LD	HL,PH_PROPHET
	LD	(DIAL_CMD),HL
	CALL	SET_FIDO_NAME
	CALL	SET_2400
	JP	DIAL_OUT
;
DIAL_RANDOM
	LD	HL,M_RANDOM
	CALL	LOG_THIS
	XOR	A
	LD	(F_ULOGIN),A	;No unix login
	LD	A,(REDL_RANDOM)
	LD	(REDIALS),A
	LD	HL,POLL_RANDOM
	LD	(POLL_STRING),HL
	LD	HL,PH_RANDOM
	LD	(DIAL_CMD),HL
	CALL	SET_FIDO_NAME
	CALL	SET_2400
	JP	DIAL_OUT
;
DIAL_OUT
DIAL_0
	CALL	DTR_ON
	LD	A,1
	CALL	SEC10
	LD	HL,MODEM_ATH0
	CALL	MODEM_PUTS
	LD	HL,(DIAL_CMD)
	CALL	MODEM_PUTS
	CALL	MODEM_FLUSH
	LD	HL,120*40	;Delay up to 120 seconds
	LD	(TIMEOUT),HL	;Set timeout in ticks
;
DIAL_1	CALL	MODEM_GETC
	JR	NZ,DIAL_2
	LD	A,(TICKER)
	LD	HL,LAST_TICK
	CP	(HL)
	JR	Z,DIAL_1	;Not 1/40 second passed so loop
	LD	(HL),A		;Adjust last tick value
	LD	HL,(TIMEOUT)
	DEC	HL
	LD	(TIMEOUT),HL
	LD	A,H
	OR	L
	JR	NZ,DIAL_1	;Have not timed out yet
	JR	NO_GO		;Modem not responding - give up
;
DIAL_2
	CP	'0'		;Ok - loop
	JR	Z,DIAL_1
	CP	'3'		;No carrier
	JR	Z,NO_CARRIER
	CP	'1'		;v21/22bis (assume 22bis)
	JR	Z,CONN_24
	CP	'5'		;v22/v23 connect
	JR	Z,CONN_12
	JR	DIAL_1
;
NO_CARRIER
	LD	HL,M_NOCARR	;No carrier found
	CALL	LOG_THIS
;
	LD	A,(REDIALS)
	OR	A
	JR	Z,NO_GO
	DEC	A
	LD	(REDIALS),A
	LD	A,R		;Random number 0 - 127
	AND	127
	CALL	SEC10		;Delay 0.1 to 12.8 seconds
	LD	A,60		;Delay 6 seconds
	CALL	SEC10
	JR	DIAL_0
;
;Cannot get carrier or modem not responding
NO_GO
	CALL	DTR_OFF
	LD	HL,M_GIVEUP
	CALL	LOG_THIS
;
	CALL	SET_1200
	LD	HL,MODEM_ATH1
	CALL	MODEM_PUTS
	CALL	DTR_ON
	JP	EXIT
;
;Connected at 1200 bps ... v22 or v23
CONN_12
	LD	HL,M_FDCARR_V22
	CALL	LOG_THIS
	CALL	SET_1200
	JR	CONNECTED
;
CONN_24
	LD	HL,M_FDCARR_BIS
	CALL	LOG_THIS
	CALL	SET_2400
	JR	CONNECTED
;
CONNECTED
	LD	A,(F_ULOGIN)	;Is Unix login required
	OR	A
	CALL	NZ,UNIX_LOGIN
	LD	HL,(POLL_STRING)
	CALL	CALL_PROG
;
REEXIT
	CALL	DTR_OFF
	LD	A,5
	CALL	SEC10
	LD	HL,MODEM_ATH1
	CALL	MODEM_PUTS
	CALL	DTR_ON
	LD	A,1
	CALL	SEC10
	XOR	A
	JP	TERMINATE
;
LOG_THIS
	PUSH	HL
	CALL	T_STR
	LD	HL,TIMDAT
	CALL	LOG_MSG
	POP	HL
	PUSH	HL
	CALL	LOG_MSG
	POP	HL
	LD	DE,$DO
	CALL	MESS_0
	RET
;
MODEM_ACK
	LD	A,(TICKER)
	ADD	A,40
	LD	B,A
MA_01	LD	A,(TICKER)
	CP	B
	RET	Z
	CALL	MODEM_GETC_SHOW
	JR	MA_01
;
T_STR
	LD	HL,DATE
	CALL	X_TODAY
	LD	HL,TIME
	CALL	446DH
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
SET_FIDO_NAME
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
	RET
;
;Read a character from the modem and return NZ if one
MODEM_GETC
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
MODEM_PUTS
	CALL	MODEM_GETC_SHOW
	LD	A,(HL)
	OR	A
	JP	Z,MODEM_ACK
	CALL	MODEM_PUTC
	INC	HL
	JR	MODEM_PUTS
;
MODEM_GETC_SHOW
	CALL	MODEM_GETC
	RET	Z
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
TO_UPPER_C
	CP	'a'
	RET	C
	CP	'z'+1
	RET	NC
	AND	5FH
	RET
;
; Implement a state table with stimulus and response strings.
UNIX_LOGIN
	CALL	STATEINIT
UL_01
	LD	A,(STATE)
	CP	2		;Is this the exit state?
	JR	NC,UL_02	;Yes, we are done
	CALL	STATEMACH	;Issue response and read stimulus
	LD	HL,(STATEMAX)
	DEC	HL
	LD	(STATEMAX),HL
	LD	A,H
	OR	L
	JR	NZ,UL_01	;Looping limit not up
	LD	HL,M_LIMIT
	CALL	LOG_THIS
;
UL_02
	RET
;
; Initialise pointers and variables
STATEINIT
	XOR	A
	LD	(STATE),A
	LD	HL,STIMBUFF
	LD	(HL),0
	LD	(STIMPTR),HL
	LD	HL,50		;Max 50 loops through state machine
	LD	(STATEMAX),HL
	RET
;
; Do one loop through the state machine
;
STATEMACH
	CALL	DEFINE_STATE
	CALL	READMODEM
	CALL	RESPONSE
	RET
;
DEFINE_STATE
	LD	A,(STATE)
	ADD	A,A
	LD	HL,STATES
	LD	E,A
	LD	D,0
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(STATETABLE),DE
	RET
;
;Read chars from the modem until CR or 2-second timeout
READMODEM
	LD	A,120
	LD	(TIMEOUT1),A
	LD	A,(TICKER)
	LD	(LAST_TICK),A
RM_01
	CALL	MODEM_GETC
	JR	NZ,RM_02		;If a character received
	LD	HL,LAST_TICK
	LD	A,(TICKER)
	CP	(HL)
	JR	Z,RM_01			;If same tick
	LD	(HL),A
	LD	A,(TIMEOUT1)
	DEC	A
	LD	(TIMEOUT1),A
	JR	NZ,RM_01		;Not timed out yet
	LD	HL,(STIMPTR)
	LD	(HL),0			;End the stimulus string
	RET
;
RM_02
	AND	7FH
	JR	Z,RM_01			;Ignore nulls
	CP	LF
	JR	Z,RM_01			;Ignore LF
	PUSH	AF
	LD	DE,$DO
	CALL	$PUT
	POP	AF
	LD	HL,(STIMPTR)
	LD	(HL),A
	INC	HL
	LD	(STIMPTR),HL
	CP	CR
	JR	NZ,RM_01		;Loop for rest of string
	LD	(HL),0			;End the stimulus
	RET
;
;Output a character to the modem, but also read one if possible and place
;into STIMBUFF
MODEM_GPUTC
	LD	C,A
	LD	HL,(STIMPTR)
MG_01	IN	A,(RDSTAT)
	BIT	DAV_BIT,A
	JR	NZ,MG_02
	BIT	CTS_BIT,A
	JR	Z,MG_01
	LD	A,C
	OUT	(WRDATA),A
	LD	(STIMPTR),HL
	RET
;
MG_02	IN	A,(RDDATA)
	AND	7FH
	CP	LF
	JR	Z,MG_01
	LD	(HL),A
	INC	HL
	PUSH	BC
	PUSH	HL
	LD	DE,$DO
	CALL	$PUT
	POP	HL
	POP	BC
	JR	MG_01
;
;Test the stimulus string against the possibilities
RESPONSE
	LD	HL,STIMBUFF
	LD	A,(HL)
	OR	A
	JR	Z,RESP_02		;No data received -
	CALL	BYP_ENTRY		;Bypass one state entry
;
;Check second and subsequent state table entries
RESP_01
	CALL	CHK_ENTRY
	JR	Z,RESP_02
	CALL	BYP_ENTRY
	JR	RESP_01
;
;Send the response
RESP_02
	CALL	SEND_RESP
	RET
;
;Bypass one state table entry - update variable STATETABLE
BYP_ENTRY
	LD	HL,(STATETABLE)
	CALL	BE_S1			;Bypass stimulus string
	CALL	BE_S1			;Bypass response string
	INC	HL			;Bypass next state
	LD	(STATETABLE),HL
	RET
;
;Bypass a (possibly empty) null terminated string
BE_S1	LD	A,(HL)
	INC	HL
	OR	A
	JR	NZ,BE_S1
	RET
;
;Check whether the string in STIMBUFF - (STIMPTR) contains the
;string starting at (STATETABLE)
CHK_ENTRY
	LD	HL,(STATETABLE)
	LD	A,(HL)
	OR	A
	RET	Z			;end of table - "anything" entry
	LD	HL,STIMBUFF
	LD	(TEMP1),HL
CE_01
	LD	A,(HL)
	OR	A
	JR	Z,CE_02			;Failure
	LD	DE,(STATETABLE)
	CALL	STRCMP
	JR	Z,CE_03			;Success!
	LD	HL,(TEMP1)		;Skip one character & try again
	INC	HL
	LD	(TEMP1),HL
	JR	CE_01
;
;End of long string, so no match
CE_02
	XOR	A
	CP	1
	RET
;
;Matched a real string!
CE_03
	LD	A,'!'
	LD	DE,$DO
	CALL	$PUT
	CP	A
	RET
;
;Send a response to the modem. Also re-initialise STIMBUFF and set new state
SEND_RESP
	LD	HL,STIMBUFF
	LD	(HL),0
	LD	(STIMPTR),HL
;
	LD	HL,(STATETABLE)
	CALL	BE_S1			;Bypass first string
;
SR_01
	LD	A,(HL)
	OR	A
	JR	Z,SR_03
	PUSH	HL
	CALL	MODEM_GPUTC
	POP	HL
	INC	HL
	JR	SR_01
;
SR_03
	INC	HL			;Now points to new state
	LD	A,(HL)
	LD	(STATE),A
	RET
;
;Compare two null terminated strings for equality
STRCMP
STRCMP_01
	LD	A,(DE)
	CP	(HL)
	RET	NZ
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	STRCMP_01
;
;Include common routines.
*GET	ROUTINES.LIB
;
; -----------------------------------------------
;
MODEM_1A	DEFM	'AT&F v0 X1 H0',CR,0
MODEM_1B	DEFM	'AT v0 x1 s0=3 s2=255 s11=7',CR,0
MODEM_1E	DEFM	'AT m0 b2 &w',CR,0
MODEM_1F	DEFM	'AT B0 M1',CR,0	;1200 or 2400 bps
MODEM_AT	DEFM	'AT',CR,0
MODEM_ATO	DEFM	'ATO',CR,0
MODEM_ATH0	DEFM	'AT H0 B2 S7=50',CR,0
MODEM_ATH1	DEFM	'AT H1',CR,0
MODEM_ATZ	DEFM	'ATZ',CR,0
MODEM_2		DEFM	'ATH1',CR,0
MODEM_3		DEFM	'ATH0 ',CR,0
MODEM_4		DEFM	'ATA',CR,0
;
M_FIDO		DEFM	CR,CR,'** Fido session underway',CR,0
M_ACSGATE	DEFM	'Dialling ACSgate',CR,0
M_CEPAK		DEFM	'Dialling SUG Opus',CR,0
M_HUNTER	DEFM	'Dialling Cabal Connection',CR,0
M_PROPHET	DEFM	'Dialling Prophet',CR,0
M_RANDOM	DEFM	'Dialling random Fidonet',CR,0
M_LIMIT		DEFM	'State machine looping',CR,0
;
FIDO_NAME	DEFM	'Fido Network',CR,0
;
M_NOCARR	DEFM	'No carrier found',CR,0
M_GIVEUP	DEFM	'Cannot get carrier, giving up',CR,0
;
M_FDCARR_V21	DEFM	'Found V21 carrier',CR,0
M_FDCARR_V22	DEFM	'Found V22 carrier',CR,0
M_FDCARR_BIS	DEFM	'Found V22bis carrier',CR,0
M_FDCARR_V23	DEFM	'Found V23 carrier',CR,0
;
POLL_STRING	DEFW	0
DIAL_CMD	DEFW	0
USER_STRING	DEFW	0
PASS_STRING	DEFW	0
F_ULOGIN	DEFB	0	;1 if unix login required
LAST_TICK	DEFB	0
TIMEOUT		DEFW	0
TIMEOUT1	DEFB	0
TEMP1		DEFW	0
REDIALS		DEFB	0	;# of further redials to try if no carrier
STATE		DEFB	0
STATEMAX	DEFW	0
;
POLL_ACSGATE	DEFM	'Ftalk2 -c '
		GATE_NUM
		DEFM	0
;
POLL_CEPAK	DEFM	'Ftalk2 -c 713/607',0
POLL_HUNTER	DEFM	'Ftalk2 -c 713/606',0
;
POLL_PROPHET	DEFM	'Ftalk2 -c 713/600',0
POLL_RANDOM	DEFM	'Ftalk2 -c XXX/YYY  ',0
;
PH_ACSGATE	DEFM	'AT B0 M1 DT2111406',CR,0
PH_CEPAK	DEFM	'AT B0 M1 DT6268020',CR,0
PH_HUNTER	DEFM	'AT B0 M1 DT6256055',CR,0
PH_PROPHET	DEFM	'AT B0 M1 DT6287030',CR,0
PH_RANDOM	DEFM	'AT B0 M1 DTxxxxxxx       ',CR,0
;
REDL_ACSGATE	DEFB	3
REDL_CEPAK	DEFB	1
REDL_HUNTER	DEFB	1
REDL_PROPHET	DEFB	1
REDL_RANDOM	DEFB	0
;
TIMDAT
DATE		DEFM	'DD-MMM-YY  '
TIME		DEFM	'HH:MM:SS : ',0
;
STATETABLE	DEFW	0	;Address of current state entries
STIMBUFF	DEFS	256	;Storage of stimulus string
STIMPTR		DEFW	0	;Next free char in stimulus buffer
;
; -- State tables for Unix login --
STATES
	DEFW	STATE0
	DEFW	STATE1
	DEFW	0
;
STATE0
;Start of state table
	DEFB	0		;Matches "no data received"
	DEFB	CR,0		;Send CR
	DEFB	0		;Next state is 0
;
	DEFB	'ogin: ',0	;Stimulus string
	DEFB	'prophet',CR,0	;Response string
	DEFB	0		;State afterwards
;
	DEFB	'assword:',0
	DEFB	'pfgnaqzg',CR,0
	DEFB	1		;Go to state 1
;
	DEFB	'LOGIN: ',0
	DEFB	EOT,0
	DEFB	0
;
	DEFB	'PASSWORD:',0
	DEFB	EOT,0
	DEFB	0
;
	DEFB	'llo prophet',CR,0
	DEFB	0
	DEFB	2		;Go to state 2
;
	DEFB	'ogin incorrect',CR,0
	DEFB	0
	DEFB	0
;
	DEFB	'LOGIN INCORRECT',CR,0
	DEFB	0
	DEFB	0
;
	DEFB	'% ',0
	DEFB	'exit',CR,0
	DEFB	0
;
	DEFB	'$ ',0
	DEFB	EOT,0
	DEFB	0
;
	DEFB	'# ',0
	DEFB	'exit',CR,0
	DEFB	0
;
	DEFB	0		;End of table - all else
	DEFB	0		;Anything which does not match
	DEFB	0
;
STATE1
	DEFB	0		;Nothing received
	DEFB	CR,0		;Send CR
	DEFB	0		;Return to state 0
;
	DEFB	'llo prophet',CR,0
	DEFB	0
	DEFB	2		;State 2 - exit
;
	DEFB	'Login incorrect',CR,0
	DEFB	0
	DEFB	0		;Return to state 0
;
	DEFB	0		;Anything else received
	DEFB	0		;Send nothing
	DEFB	0		;Return to state 0
;
THIS_PROG_END	EQU	$
;
	END	START
