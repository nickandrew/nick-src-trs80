;logon1: Part 1 of 2 of logon.
;
START	LD	SP,START
;
	LD	A,(SYS_STAT)
	BIT	SYS_LOGDIN,A
	JR	Z,STAT_OK
	LD	HL,M_BADSTAT
	CALL	PUTS
	LD	A,130
	JP	TERMINATE
;
STAT_OK
;
	XOR	A
	LD	(WORD_WRAP),A
	LD	HL,HI_FILE
	CALL	LIST
	CALL	SETUP
;
	LD	HL,M_1
	CALL	PUTS
;
LP_1	CALL	GETNAME
	LD	HL,NAME_BUFF
	CALL	USER_SEARCH
	JP	Z,NAME_OK
	JP	C,ERROR
	CALL	NOTE_NAME
;
;Check if a prohibited word entered in a name
	CALL	BAD_NAMES
	JP	Z,NAUGHTY_MAN
	JR	LP_2		;Check if they like name
;
LP_1A
;
	LD	A,(COUNT)
	INC	A
	LD	(COUNT),A
	CP	6
	JR	C,LP_1
;
;Took too many tries ie. too many invalid names or
;guessed at names.
	LD	HL,M_NOLOG1
	CALL	PUTS
	LD	A,2
	CALL	SECOND
	LD	A,131
	JP	TERMINATE	;pass disconnect b/wards
;
LP_2	CALL	CHK_FORMAT
	JR	Z,LP_3		;jr if format OK
;
	LD	HL,M_THENAME
	CALL	PUTS
	LD	HL,NAME_BUFF
	CALL	PUTS
	LD	HL,M_BADFMT
	CALL	PUTS
	JR	LP_1A
;
LP_3	;the name "joe bloggs" is unknown.
	LD	HL,M_THENAME
	CALL	PUTS
	LD	HL,NAME_BUFF
	CALL	PUTS
	LD	HL,M_UNKN
	CALL	PUTS
;
LP_4	LD	HL,M_CORRECT
	CALL	PUTS
	LD	HL,IN_BUFF
	LD	B,30
	CALL	40H
	JR	C,LP_4
	LD	A,(HL)
	AND	5FH
	CP	'N'
	JR	Z,LP_1A
	CP	'Y'
	JR	NZ,LP_4
	CALL	REGISTER
	CALL	LOGIN_ACC
	JP	LOGIN_ALLWD
;
;Disconnect a naughty person....
NAUGHTY_MAN
	LD	HL,M_NAUGHTY
	CALL	LOG_MSG
	LD	A,2
	JP	TERMINATE	;Obviously naughty
;
;Bad_names: Check against a number of known,
;prohibited names....
BAD_NAMES
	LD	HL,NAME_BUFF
	LD	DE,BADN_1
	CALL	INSTR
	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_2
	CALL	INSTR
	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_3
	CALL	INSTR
	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_4
	CALL	INSTR
	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_5
	CALL	INSTR
	RET	Z
;;	LD	HL,NAME_BUFF
;;	LD	DE,BADN_6
;;	CALL	INSTR
;;	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_7
	CALL	INSTR
	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_8
	CALL	INSTR
	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_9
	CALL	INSTR
	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_10
	CALL	INSTR
	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_11
	CALL	INSTR
	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_12
	CALL	INSTR
	RET	Z
	LD	HL,NAME_BUFF
	LD	DE,BADN_13
	CALL	INSTR
	RET	Z
	RET
;
GETNAME
	CALL	GET_NAME
	LD	A,(NAME_BUFF)
	OR	A
	JR	Z,GETNAME
	RET
;
CHK_FORMAT
	LD	HL,NAME_BUFF
CF_1	LD	A,(HL)
	CALL	VALID
	RET	NZ
	OR	A
	JR	Z,CF_2
	CP	' '
	JR	Z,CF_3
	INC	HL
	JR	CF_1
CF_2	XOR	A
	CP	1
	RET
CF_3	INC	HL
	LD	A,(HL)
	CALL	VALID
	RET	NZ
	OR	A
	RET	Z
	JR	CF_3
;
VALID	CP	'-'
	RET	Z
	OR	A
	RET	Z
	CP	' '
	RET	Z
	CP	'A'
	RET	C	;=NZ.
	AND	5FH
	CP	'Z'
	RET	NC	;'Z'=Z, 5Bh-5Fh=NZ.
	CP	A
	RET
;
NAME_OK
;Firstly ensure this is a 'real' user...
	LD	A,(UF_STATUS)
	BIT	UF_ST_NOTUSER,A
	JR	Z,N_O_1
;Name entered is fake or locked out. Log name & disc.
	CALL	NOTE_NAME
	JP	NAUGHTY_MAN
;
N_O_1
	CALL	CHK_PASS
	JR	Z,LOGIN_ALLWD
;
	LD	HL,M_KICKOUT
	CALL	LOG_MSG
	LD	HL,NAME_BUFF
	CALL	LOG_MSG
	LD	HL,M_CR
	CALL	LOG_MSG
;
	LD	A,(UF_BADLOGIN)
	INC	A
	LD	(UF_BADLOGIN),A
	CALL	REWRITE
	LD	HL,M_DENIED
	CALL	PUTS
BUMP_OFF
	LD	A,2
	CALL	SECOND
	LD	A,2
	JP	TERMINATE	;not always naughty
;
LOGIN_ALLWD
	LD	HL,SYS_STAT
	SET	SYS_LOGDIN,(HL)
;
	LD	HL,(UF_UID)	;Set userid
	LD	(USR_NUMBER),HL
;
	CALL	SET_NAME
	CALL	LOG_NAME	;record the login
;
	LD	HL,SYS_STAT	;No caller inc if testing
	BIT	SYS_TEST,(HL)
	JR	NZ,NO_CLRINC
	LD	HL,(CALLER)	;inc # logged in callers
	INC	HL
	LD	(CALLER),HL
NO_CLRINC
;
;If network, bypass messages
	LD	HL,(USR_NUMBER)
	LD	DE,ACSNET_ID
	OR	A
	SBC	HL,DE
	JP	Z,EXIT_LOGIN
;
	LD	HL,M_LOG	;print msg
	CALL	PUTS
;
	LD	HL,M_YOURE	;You are zeta's
	CALL	PUTS
	LD	HL,(CALLER)	;N'th caller
	LD	DE,$2
	CALL	PRINT_NUMB
	CALL	PRINT_SUFF
	LD	HL,M_SCALL
	CALL	PUTS
	LD	HL,M_YOURNO	;This is your
	CALL	PUTS
	LD	HL,(UF_NCALLS)	;N'th call to Zeta
	LD	DE,$2
	CALL	PRINT_NUMB
	CALL	PRINT_SUFF
	LD	HL,M_YOURCL
	CALL	PUTS
;
	LD	A,(UF_PRIV2)
	BIT	IS_VISITOR,A
	CALL	Z,PCREDITS	;Print balance for member
;
;Print message if their last call was >2 months ago max.
	LD	A,(LAST_CALL+1)	;month number
	OR	A
	JR	Z,LAL_2		;No msg if first call.
	LD	B,A
	LD	A,(4046H)	;this current month
	CP	B
	JR	Z,LAL_2
	DEC	A
	JR	NZ,LAL_1
	LD	A,12
LAL_1	CP	B
	JR	Z,LAL_2
	LD	HL,M_OLDMATE
	CALL	PUTS
LAL_2
;
	IF	SYSOPONLY
	LD	A,(PRIV_1)	;Only let sysop login
	BIT	IS_SYSOP,A
	JR	NZ,LAL_2A
;
	LD	HL,M_SYSOPONLY
	LD	DE,$2
	CALL	MESS_0
	JP	BUMP_OFF
	ENDIF	;sysoponly
;
LAL_2A
	CALL	LOGIN_MSG	;List login.zms
;
	LD	A,(PRIV_2)	;check if member
	BIT	IS_VISITOR,A
	JR	Z,EXIT_LOGIN	;all OK if a member.
;
	LD	HL,(UF_NCALLS)
	LD	DE,4		;Give Visitor info for
	OR	A		;first 3 calls...
	SBC	HL,DE
	CALL	C,HI_VISITOR
;
EXIT_LOGIN
;
	LD	HL,(USR_NUMBER)
	LD	DE,ACSNET_ID
	OR	A
	SBC	HL,DE
	JR	Z,EXIT_ACSNET
;
	LD	HL,PRESHELL	;run .LOGIN command
	CALL	OVERLAY		;alias PRESHELL.
	LD	HL,M_SHELLERR
	CALL	PUTS
	JP	$		;loop ... no shell.
;
EXIT_ACSNET
	LD	HL,ACSNET
	CALL	OVERLAY
	LD	HL,M_ACSERR
	CALL	PUTS
	JP	$
;
SETUP	LD	HL,($2+1)	;Route devices
	LD	($KBD+1),HL
	LD	HL,($2+1)
	LD	($VDU+1),HL
;
	CALL	OPEN_UFILE
	RET
;
OPEN_UFILE
	LD	HL,US_BUFF
	LD	DE,US_FCB	;userfile
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(US_FCB+1)
	AND	0F8H
	LD	(US_FCB+1),A
	XOR	A
	LD	(COUNT),A
	RET
;
NOTE_NAME
	LD	HL,M_UNSUC
	CALL	LOG_MSG
	LD	HL,NAME_BUFF
	CALL	LOG_MSG
	LD	HL,M_CR
	CALL	LOG_MSG
	RET
;
SET_NAME
	LD	HL,(USR_NAME)
	LD	B,32
LN_01	LD	(HL),0
	INC	HL
	DJNZ	LN_01
;
	LD	HL,(USR_NAME)
	LD	DE,UF_NAME
LN_1	LD	A,(DE)
	LD	(HL),A
	OR	A
	JR	Z,LN_2
	INC	HL
	INC	DE
	JR	LN_1
LN_2
	LD	(HL),CR		;External CR on name end
	RET
;
LOG_NAME
	LD	HL,M_SUCCE
	CALL	LOG_MSG
	LD	HL,NAME_BUFF
	CALL	LOG_MSG
	LD	HL,M_CR
	CALL	LOG_MSG
	RET
;
LOGIN_MSG
	LD	HL,LOGIN_FILE
	CALL	LIST
	RET
;
GET_NAME
GS_1	LD	HL,M_FULLNAME
	CALL	PUTS
	XOR	A
;
	LD	HL,NAME_BUFF
	LD	B,24		;Names 24 now not 30
	CALL	40H
	JR	C,GS_1
	LD	HL,NAME_BUFF
	CALL	TERMINATE_S	;Put 00h on end
	LD	HL,NAME_BUFF
	CALL	STR_CLEAN	;Clean the string
	RET
;
STR_CLEAN
	PUSH	HL
	POP	DE
SCL_1	LD	A,(HL)
	OR	A
	JR	Z,SCL_5
	INC	HL
	CP	' '
	JR	Z,SCL_1
	LD	(DE),A
	INC	DE
SCL_2	LD	A,(HL)
	OR	A
	JR	Z,SCL_5
	LD	(DE),A
	INC	DE
	INC	HL
	CP	' '
	JR	NZ,SCL_2
SCL_3	LD	A,(HL)
	OR	A
	JR	Z,SCL_4
	INC	HL
	CP	' '
	JR	Z,SCL_3
	LD	(DE),A
	INC	DE
	JR	SCL_2
SCL_4	DEC	DE
SCL_5	XOR	A
	LD	(DE),A
	RET
;
ERROR	LD	HL,M_ERROR	;Dos error detected.
	CALL	LOG_MSG
	LD	HL,M_ERROR
	CALL	PUTS
	LD	HL,M_HNGUP
	CALL	PUTS
;
	LD	DE,US_FCB
	CALL	DOS_CLOSE
	LD	A,3
	CALL	SECOND
	LD	A,254
	JP	TERMINATE	;error. Not naughty,
				;just disconnect.
;
CHK_PASS
	LD	A,(UF_PASSWD)
	OR	A
	JP	Z,PASS_OK
	XOR	A
	LD	(PASS_TRY),A
CP_1	LD	HL,M_PASSWD
	CALL	PUTS
	LD	A,1
	LD	(_40H_INV),A	;Set no-echo
	LD	HL,IN_BUFF
	LD	B,12		;12 Chars in a passwd.
	CALL	FORTYHEX
	JR	C,CP_1
;if SYSOP typing password he can type anything
;so long as he hits SPACE while hitting CR.
	LD	A,(3840H)
	AND	81H
	CP	81H
	JP	Z,PASS_OK
;
	LD	A,(HL)
	CP	CR
	JR	Z,CP_1
	CALL	TO_UPPER
	LD	(HL),0		;(hl) was CR terminat.
	LD	HL,IN_BUFF
	LD	DE,UF_PASSWD
	LD	B,12		;password length.
CP_4	LD	A,(DE)
	CP	(HL)
	JR	NZ,CP_5
	OR	A
	JR	Z,PASS_OK
	INC	DE
	INC	HL
	DJNZ	CP_4
	LD	A,(HL)
	OR	A
	JR	Z,PASS_OK
CP_5				;Bad password entered.
				;Log to printer.
	LD	A,(F_THISUSR)
	OR	A
	JR	NZ,CP_5A
	LD	HL,M_THISUSR	;Log username attempted
	CALL	LOG_MSG
	LD	HL,NAME_BUFF
	CALL	LOG_MSG
	LD	HL,M_CR
	CALL	LOG_MSG
;
	LD	A,1
	LD	(F_THISUSR),A
;
CP_5A	LD	HL,M_THISPWD
	CALL	LOG_MSG
	LD	HL,IN_BUFF
	CALL	LOG_MSG
	LD	HL,M_CR
	CALL	LOG_MSG
;
	LD	HL,M_PWBAD
	CALL	PUTS
	LD	A,(PASS_TRY)
	INC	A
	LD	(PASS_TRY),A
	CP	4		;max no. of pwd tries
	JP	C,CP_1
;
;Setup user name "(failed) fred smith", print bad-passwd
;message then run "comment" to let them say their piece.
	LD	HL,M_FORGOT
	CALL	PUTS
;
	LD	HL,NAME_BUFF
	LD	DE,(USR_NAME)
	CALL	STRCPY
	LD	HL,NAME_FAIL
	CALL	STRCAT
;
	LD	HL,COMMENT
	CALL	CALL_PROG
;
	JP	LOGIN_REJ	;Bad password.
;
PASS_OK
	LD	HL,UF_PRIV2	;bit 5 was actually a bug
	BIT	6,(HL)		;Kbd approval required.
	JP	Z,LOGIN_ACC	;Accepted.
	LD	HL,M_YESNO
	LD	DE,$DO
	CALL	MESS_0
	LD	B,150		;15 sec.
CP_6	LD	DE,$KI
	CALL	$GET
	OR	A
	JR	NZ,CP_7
	LD	A,1
	CALL	SEC10
	DJNZ	CP_6
	JP	LOGIN_REJ
CP_7	AND	5FH
	CP	'N'
	JR	Z,LOGIN_REJ
	CP	'Y'
	JR	NZ,CP_6
	JR	LOGIN_ACC
LOGIN_REJ
	XOR	A
	CP	1
	RET
;
LOGIN_ACC
;Set privileges
	LD	A,(UF_PRIV1)
	LD	(PRIV_1),A
	LD	A,(UF_PRIV2)
	LD	(PRIV_2),A
;
	LD	HL,UF_LASTCALL	;Save last call date
	LD	DE,LAST_CALL
	LD	BC,3
	LDIR			;Set today's date in mem
	LD	A,(4045H)	;=DD
	LD	(UF_LASTCALL),A
	LD	A,(4046H)	;=MM
	LD	(UF_LASTCALL+1),A
	LD	A,(4044H)	;=YY
	LD	(UF_LASTCALL+2),A
;
	LD	HL,(UF_NCALLS)	;Inc number of calls
	INC	HL
	LD	(UF_NCALLS),HL
;
	LD	A,(UF_TFLAG2)	;load Stty
	OR	A
	JR	NZ,LA_0A
	LD	A,0BFH		;config for CPM if none
LA_0A
	LD	(TFLAG2),A
;
;
LA_1
	CALL	REWRITE
	XOR	A
	RET
;
WAIT_KEY
	LD	HL,M_HITKEY
	LD	DE,$2
	CALL	MESS_0
WK_1	CALL	$GET
	OR	A
	JR	Z,WK_1
	RET
;
REWRITE			;rewrite DATA file record.
	LD	DE,US_FCB	;Proper rewrite.
	LD	HL,(US_RBA+1)
	LD	A,(US_RBA)
	LD	C,A
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	LD	HL,US_UBUFF	;DATA buffer.
	LD	B,UF_LRL
RWL_1	LD	A,(HL)
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	DJNZ	RWL_1
;
	CALL	DOS_CLOSE
	JP	NZ,ERROR
	RET
;
SEC10	PUSH	BC		;wait A/10 seconds.
S1_1	PUSH	AF
	LD	B,4		;40/10
	LD	A,(TICKER)
	LD	D,A
S1_2	LD	A,(TICKER)
	CP	D
	LD	D,A
	JR	Z,S1_2
	DJNZ	S1_2
	POP	AF
	DEC	A
	JR	NZ,S1_1
	POP	BC
	RET
;
PCREDITS
	IF	CREDITS
	LD	A,(UF_NOTHING)
	OR	A
	JP	M,NEGBAL
;
	LD	HL,M_CRED1
	LD	DE,$2
	CALL	MESS_0
	LD	A,(UF_NOTHING)
	LD	L,A
	LD	H,0
	CALL	PRINT_NUMB
	LD	HL,M_CRED2
	LD	DE,$2
	CALL	MESS_0
	RET
NEGBAL
	LD	HL,M_CRED3
	LD	DE,$2
	CALL	MESS_0
	LD	A,(UF_NOTHING)
	NEG
	LD	L,A
	LD	H,0
	CALL	PRINT_NUMB
	LD	HL,M_CRED4
	LD	DE,$2
	CALL	MESS_0
;
	ENDIF	;credits
	RET
;
M_SYSOPONLY
	DEFM	CR,'**   For today only...',CR
	DEFM	'**  Zeta is not accepting user logins.',CR
	DEFM	'**  Please call back tomorrow.',CR,CR,0
