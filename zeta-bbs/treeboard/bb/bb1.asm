; @(#) bb1.asm - BB code file #1, on 16 May 89
;
START	LD	SP,START
	CALL	INIT		;Initialise the input buffer
;
	LD	HL,M_INTRO
	CALL	MESS
;
;;	CALL	IF_VISITOR
;;	JR	Z,NOT_VIS
;;	LD	HL,M_VISBAD	;Tell non members
;;	CALL	MESS		;to piss off
;
;;NOT_VIS
;
	CALL	SETUP		;Setup everything
;
	CALL	FIX_MFD		;Tree initialisation
;
MAIN				;Main section
	LD	SP,START
	CALL	IF_CHAR
	JR	Z,MAIN_1	;if input already here
;
	CALL	PRTMODE		;print mode/where.
	LD	HL,MENU_MAIN
	CALL	MENU
;
MAIN_1	LD	HL,PMPT_MAIN
	CALL	GET_STRING
;
MAIN_2				;parse first word
	CALL	GET_CHAR
	CP	CR
	JR	Z,MAIN_1	;was b_c_x
	CALL	TO_UPPER_C
	CP	' '
	JR	Z,MAIN_2
	CP	'R'		;<R>ead
	JP	Z,READ_CALL
	CP	'X'		;<X> Exit
	JP	Z,EXIT_CMD
	CP	'M'		;<M>ove
	JP	Z,MOVE2_CMD
	CP	'L'		;<L>ist
	JP	Z,LIST_CMD
	CP	'E'		;<E>nter
	JP	Z,ENTER_CMD
	CP	'S'		;<S>can
	JP	Z,SCAN_CMD
	CP	'O'		;<O>ptions
	JP	Z,OPT_CMD
	CP	'K'		;<K>ill msg
	JP	Z,KILL_CALL
	CP	'#'		;Special commands
	JP	Z,SPEC_CMD
	CP	'T'		;Treewalk
	JP	Z,TREAD_CMD
;
BAD_CMD	LD	HL,M_BADCMD
B_C_1	CALL	MESS
	LD	HL,IN_BUFF
	LD	(CHAR_POSN),HL
	LD	(HL),0
	JP	MAIN
;
BADSYN	LD	HL,M_BADSYN
	JR	B_C_1
;
NO_PERMS
	LD	HL,M_NOPERMS
	CALL	MESS
	JP	MAIN
;
; ------------------------------
;
KILL_CALL
	CALL	KILL_CMD
	JP	MAIN
;
; ------------------------------
;
READ_CALL
	CALL	READ_CMD
	JP	MAIN
;
READ_CMD			;Read Messages
	CALL	GET_CHAR
	CP	CR
	JR	NZ,READ_CMD
;
READ_MAIN
	LD	HL,READMESSAGE
	LD	(FUNCTION),HL
	LD	HL,M_READ
	LD	(FUNCNM),HL
	CALL	DO_SCAN_1
	RET
;
; ------------------------------
;
SCAN_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
SCAN_MAIN
	LD	HL,SCANMESSAGE
	LD	(FUNCTION),HL
	LD	HL,M_SCAN
	LD	(FUNCNM),HL
	CALL	DO_SCAN_1
	CP	CR
	JP	MAIN		;always
;
; ------------------------------
;
FORWARD_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
;
	LD	HL,M_RCVR	;to:
	CALL	GET_STRING
	LD	IX,NAME_BUFF
FWDX_1
	CALL	GET_CHAR
	LD	(IX),A
	INC	IX
	CP	CR
	JR	NZ,FWDX_1
;
	LD	HL,NAME_BUFF
	CALL	CHK_USERS
	JR	Z,FWDX_4
	LD	HL,M_FWD_NOONE
	CALL	MESS
	JP	MAIN
FWDX_4
	LD	HL,(US_NUM)
	LD	(FORWARD_ID),HL
	LD	HL,FORWARDMESSAGE
	LD	(FUNCTION),HL
	LD	HL,M_FORWARD
	LD	(FUNCNM),HL
	CALL	DO_SCAN_1
	JP	MAIN
;
; ------------------------------
;
WRITE_MSG_HDR
	LD	HL,(A_MSG_POSN)
	PUSH	HL
	POP	BC
	LD	DE,HDR_FCB
	CALL	DOS_POSIT
	JP	NZ,ERROR
	LD	HL,THIS_MSG_HDR
	CALL	DOS_WRIT_SECT
	JP	NZ,ERROR
	RET
;
; ------------------------------
;
EXIT_CMD
	CALL	CLOSE_ALL
	LD	A,0
	JP	TERMINATE
;
; ------------------------------
;
DO_SCAN_1
	LD	HL,(FUNCNM)
	CALL	MESS
;
	XOR	A
	LD	(MSG_FOUND),A
	LD	(SCAN_ABORT),A
;
	LD	HL,1
	LD	(FIRST_MSG),HL
	LD	HL,(N_MSG_TOP)
	LD	(LAST_MSG),HL
;
DS_1	LD	HL,MENU_DS1
	CALL	MENU
	LD	HL,PMPT_DS1
	CALL	GET_STRING
DS_2
	CALL	GET_CHAR
;
	CP	CR		;check char
	RET	Z
	CP	' '
	JR	Z,DS_2
	CP	'$'
	JR	Z,RANGE
	CALL	IF_NUM
	JR	Z,RANGE
	AND	5FH
;
	CP	'M'
	JR	Z,IS_TOME
	CP	'A'
	JR	Z,IS_ALL
	CP	'U'
	JR	Z,IS_UNRD
	CP	'F'	;from me.
	JR	Z,IS_FROM
	LD	HL,M_UNK	;Unknown criterion
	CALL	MESS
	JR	DS_1
;
IS_TOME	LD	A,2
	JR	DS_3
IS_ALL	LD	A,3
	JR	DS_3
IS_UNRD	LD	A,4
	JR	DS_3
IS_FROM	LD	A,6
	JR	DS_3
;
DS_3
	LD	(SCAN_MASK),A
	CALL	DO_SCAN
	JP	DS_2		;An experiment!
;
RANGE				;do for a range.
	CP	'$'
	JR	NZ,NOT_LAST
	LD	HL,(N_MSG_TOP)
	LD	(FIRST_MSG),HL
	JR	RANGE_MID
NOT_LAST			;must be number.
	CALL	GET_NUM		;into HL.
	LD	(FIRST_MSG),HL
RANGE_MID
	CALL	IF_CHAR
	CP	CR
	JR	NZ,NOT_SNGL
;1 number entered so last=first.
IS_SNGL
	LD	HL,(FIRST_MSG)
	LD	(LAST_MSG),HL
	JR	SCAN_RANGE
NOT_SNGL
	CP	'-'
	JR	Z,DASH	;to message or bkwards.
	CP	'+'
	JR	Z,PLUS
;
;Space after number means single & more coming.
	CP	' '
	JR	Z,IS_SNGL
;
	JP	DS_1		;unknown
;
PLUS	CALL	GET_CHAR	;Get the +
	LD	HL,(N_MSG_TOP)
	LD	(LAST_MSG),HL
	JR	SCAN_RANGE
;
DASH	CALL	GET_CHAR	;Get the -
	CALL	IF_CHAR
	CP	CR
	JR	NZ,TO_NUM
	LD	HL,1	;to start.
	LD	(LAST_MSG),HL
	JR	SCAN_RANGE
TO_NUM	CP	'$'
	JR	NZ,DA_NUM
	CALL	GET_CHAR	;Get the $
	LD	HL,(N_MSG_TOP)
	LD	(LAST_MSG),HL
	JR	SCAN_RANGE
DA_NUM	CALL	IF_NUM
	JP	NZ,DS_1		;Not a number
	CALL	GET_CHAR	;Get the first digit
	CALL	GET_NUM
	LD	(LAST_MSG),HL
SCAN_RANGE
	LD	A,5
	LD	(SCAN_MASK),A
	CALL	DO_SCAN		;do the scan.
	JP	DS_2		;Another experiment!
;
; ------------------------------
;
SETUP
	CALL	FILE_SETUP		;Open all files
	XOR	A
	LD	(MY_TOPIC),A
	LD	(MY_LEVEL),A
	LD	HL,OPTIONS
	LD	(HL),0
	SET	FO_CURR,(HL)		;current only.
	SET	FO_NORM,(HL)		;not expert.
	CALL	INFO_SETUP
	RET
;
; ------------------------------
;
FILE_SETUP
	LD	HL,_BLOCK
	LD	DE,TXT_FCB
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,NO_OPEN
	LD	HL,HDR_B
	LD	DE,HDR_FCB
	LD	B,HDR_LEN
	CALL	DOS_OPEN_EX
	JP	NZ,NO_OPEN
	LD	HL,TOP_B
	LD	DE,TOP_FCB
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,NO_OPEN
;
	LD	C,0F8H
	LD	B,40H
	LD	HL,TXT_FCB+1
	LD	A,(HL)
	AND	C
	OR	B
	LD	(HL),A
	LD	HL,HDR_FCB+1
	LD	A,(HL)
	AND	C
	OR	B
	LD	(HL),A
	LD	HL,TOP_FCB+1
	LD	A,(HL)
	AND	C
	OR	B
	LD	(HL),A
;
	LD	HL,TOPIC	;Read topic file
	LD	DE,TOP_FCB
;read in 16 sectors then byte by byte for topics.
	LD	B,16
RDT_1	PUSH	BC
	LD	DE,TOP_FCB
	CALL	DOS_READ_SECT
	JP	NZ,ERROR
	EX	DE,HL
	LD	HL,TOP_B
	LD	BC,256
	LDIR
	EX	DE,HL
	POP	BC
	DJNZ	RDT_1
;
	CALL	_READFREE	;Get free space map
	CALL	STATS_MSG	;print msg stats.
;
	LD	HL,MSG_TOPIC
	LD	DE,TOP_FCB
RDTOP	CALL	$GET		;read in topic each msg.
	JR	NZ,RDT_2
	LD	(HL),A
	INC	HL
	JR	RDTOP
RDT_2	CP	1CH
	RET	Z
	CP	1DH
	RET	Z
	JP	ERROR
;
CLOSE_ALL
	CALL	_WRITEFRE	;Write freemap
	LD	DE,TXT_FCB
	CALL	DOS_CLOSE
	CALL	NZ,NO_CLOSE
	LD	DE,HDR_FCB
	CALL	DOS_CLOSE
	CALL	NZ,NO_CLOSE
	LD	DE,TOP_FCB
	CALL	DOS_CLOSE
	CALL	NZ,NO_CLOSE
	RET
;
NO_CLOSE
	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	RET
;
NO_OPEN
	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	TERMINATE
;
ERROR
	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	CALL	CLOSE_ALL
	POP	AF
	JP	TERMINATE
;
PRTMODE
	LD	HL,M_WHERE
	CALL	MESS
	LD	A,(MY_TOPIC)
	CALL	TOPIC_PRINT
	LD	HL,M_WITHMSG
	CALL	MESS
	LD	HL,(N_MSG_TOP)
	CALL	PRINT_NUMB
	LD	HL,M_MSGS
	CALL	MESS
	RET
;
; ------------------------------
;
; Forward a message to another Zeta user
;
FORWARDMESSAGE
;ensure msg TO me or FROM me or I'M SYSOP.
	CALL	IF_SYSOP
	JR	NZ,FWMSG_1
	LD	DE,(USR_NUMBER)
	LD	HL,(HDR_SNDR)
	CALL	CPHLDE
	JR	Z,FWMSG_1
	LD	HL,(HDR_RCVR)
	CALL	CPHLDE
	JR	NZ,FWMSG_NO
	LD	A,(HDR_FLAG)
	BIT	FM_PRIVATE,A
	JR	Z,FWMSG_1
FWMSG_NO
	RET			;wont forward.
;
FWMSG_1
	CALL	TEXT_POSN
	CALL	HDR_PRNT
;
	LD	HL,M_FORWARDING
	CALL	MESS
	LD	HL,(MSG_NUM)
	CALL	PRINT_NUMB
	CALL	PUTCR
;
	CALL	GET_$2
	CP	1
	JR	NZ,FWMSG_NOQ
	LD	A,1
	LD	(SCAN_ABORT),A
	RET
FWMSG_NOQ				;no quit!
	LD	HL,(FORWARD_ID)
	LD	(HDR_RCVR),HL
	LD	A,H
	AND	L
	CP	0FFH
	JR	NZ,FWMSG_NALL
	LD	A,(HDR_FLAG)
	RES	FM_PRIVATE,A
	LD	(HDR_FLAG),A
FWMSG_NALL
	CALL	WRITE_MSG_HDR		;write header out
	RET
;
; ------------------------------
;
READMESSAGE
	LD	A,(MSG_FOUND)
	OR	A
	JR	NZ,RM_01
;
;Ask if pausing to be done. If pause, then more it.
	XOR	A
	LD	(PAUSE),A
	LD	HL,M_APAUSE
	CALL	YES_NO
	CP	'N'
	JR	Z,RM_01
	CP	'Q'
	JR	Z,RM_06
	LD	HL,M_TOPT
	CALL	MESS
	LD	A,1
	LD	(PAUSE),A
;Start to print the message
RM_01
	CALL	PUTCR
	CALL	PUTCR
	CALL	TEXT_POSN
	CALL	HDR_PRNT
;
;Decide whether to pipe through more or not
	LD	A,(PAUSE)
	OR	A
	JR	Z,RM_02		;No pause so direct output
;
;Initialise more
	LD	HL,RM_INFUNC
	LD	(INFUNC),HL	;Setup input function
	LD	HL,RM_KEYFUNC
	LD	(KEYFUNC),HL	;Setup key function
	LD	A,7		;Lines already printed
	LD	(SCRDONE),A
;
	CALL	MOREPIPE	;Pipe it through more
	OR	A
	JR	NZ,RM_05	;Interpret a key pressed while in more
	JR	RM_03		;Wait for a keystroke
;
RM_02	CALL	BGETC
	JR	NZ,RM_03	;Read error
	OR	A
	JR	Z,RM_03		;End of message
	CALL	PUT
	CALL	GET_$2
	AND	5FH
	CP	'N'
	JR	Z,RM_07
	CP	'Q'
	JR	Z,RM_06
	JR	RM_02
;
RM_03
	LD	A,(PAUSE)
	OR	A
	RET	Z
	LD	HL,M_PAUSE
	CALL	MESS
RM_04
	CALL	GET_$2
	OR	A
	JR	Z,RM_04
RM_05
	CP	'?'
	JR	Z,RM_10
	CP	' '
	RET	Z		;Next message
	AND	5FH
	CP	'A'
	JR	Z,RM_09		;Read again
	CP	'N'
	RET	Z		;Next message
	CP	'Q'
	JR	Z,RM_06		;Quit
	CP	'R'
	JR	Z,RM_08		;Reply option
	JR	RM_04
	RET
;
RM_06	LD	A,1
	LD	(SCAN_ABORT),A
	RET
;
RM_07	CALL	PUTCR
	RET
;
RM_08	CALL	DO_REPLY
	RET			;Next message
;
;Read again - reposition & back to the top
RM_09	JP	RM_01
;
;Display help message
RM_10	CALL	RMK_01
	JP	RM_03
;
; ------------------------------
;
RM_INFUNC
	CALL	BGETC
	RET	NZ		;If read error, ret nz
	CP	A
	RET
;
RM_KEYFUNC
	CP	'?'
	JR	Z,RMK_01	;Help
	AND	5FH
	CP	'A'
	JR	Z,RMK_02	;Read again
	CP	'H'
	JR	Z,RMK_01	;Help
	CP	'N'
	JR	Z,RMK_02	;Next message
	CP	'Q'
	JR	Z,RMK_02	;Quit
	CP	'R'
	JR	Z,RMK_02	;Reply
	LD	A,0		;Redisplay more prompt
	RET
;
RMK_01
	LD	HL,M_READHELP
	CALL	MESS
	LD	A,0		;Redisplay more prompt
	RET
;
RMK_02
	JP	MORE_Q
;
; ------------------------------
;
SCANMESSAGE
	CALL	TEXT_POSN
	CALL	HDR_SCAN
;
	CALL	GET_$2
	CP	1
	JR	Z,SCNM_Q
	AND	5FH
	CP	'Q'
	JR	Z,SCNM_Q
	RET
SCNM_Q	LD	A,1
	LD	(SCAN_ABORT),A
	CALL	PUTCR
	RET
;
; ------------------------------
;
DO_SCAN
	;scan through the file for messages
	;matching criteria fwd/bkwd etc..
	XOR	A
	LD	(BACKWARD),A
;
	LD	HL,(N_MSG)
	LD	A,H
	OR	L
	JP	Z,FIN_SCAN
	LD	HL,(N_MSG_TOP)
	LD	A,H
	OR	L
	JP	Z,FIN_SCAN
	LD	DE,(FIRST_MSG)
	LD	A,D
	OR	E
	JP	Z,BAD_RANGE
	LD	HL,(N_MSG_TOP)
	CALL	CPHLDE
	JP	C,BAD_RANGE
	LD	DE,(LAST_MSG)
	LD	A,D
	OR	E
	JP	Z,BAD_RANGE
	CALL	CPHLDE
	JP	C,BAD_RANGE
	LD	HL,(LAST_MSG)
	EX	DE,HL
	LD	HL,(FIRST_MSG)
	LD	A,D
	CP	H
	JR	NZ,DS_01
	LD	A,E
	CP	L
DS_01	JR	NC,DS_02
	LD	A,1
	LD	(BACKWARD),A
DS_02	LD	HL,(A_TOP_1ST)
	LD	A,(BACKWARD)
	OR	A
	JR	Z,DS_03
	LD	HL,(A_TOP_LAST)
DS_03	LD	(A_MSG_POSN),HL
	LD	HL,(N_MSG_TOP)
	LD	(MSG_NUM),HL
	LD	A,(BACKWARD)
	OR	A
	JR	NZ,DS_04
	LD	HL,1
	LD	(MSG_NUM),HL
DS_04	LD	HL,(A_MSG_POSN)
	LD	DE,MSG_TOPIC
	ADD	HL,DE
;******************************************************
;This code checks whether a message is in a 'SEEN'
;topic or not
;******************************************************
	LD	A,(HL)		;is message's topic.
	PUSH	HL
	LD	HL,TOPIC_MASK
	AND	(HL)
	POP	HL
	LD	B,A
	LD	A,(MY_TOPIC)	;my topic
	CP	B
	JP	NZ,DS_07	;msg not in seeable topic
;If topic is restricted, check userids against topic No.
;Message is given the same status as "private"...
	CALL	IF_SYSOP
	JR	NZ,DS_04Z	;allow it if sysop
	LD	A,(HL)		;get topic its in.
	AND	0FCH		;Mask out lower topics
	CP	068H		;general>fidonet>admin
	JP	Z,DS_05		;do not allow anybody
	JR	NZ,DS_04C
DS_04C				;more tests
DS_04Z
				;allow it.
;******************************************************
	CALL	IF_VISIBLE
	JR	NZ,DS_05	;chgd.
	CALL	CRITERIA
	JR	NZ,DS_05
;
	CALL	FUNC		;do function
	LD	A,1
	LD	(MSG_FOUND),A
	LD	A,(SCAN_ABORT)
	OR	A
	JR	Z,DS_05
	CALL	PUTCR
	JR	FIN_SCAN
DS_05	LD	HL,(MSG_NUM)
	EX	DE,HL
	LD	HL,(LAST_MSG)
	OR	A
	SBC	HL,DE
	LD	A,H
	OR	L
	JR	Z,FIN_SCAN
	LD	A,(BACKWARD)
	LD	HL,(MSG_NUM)
	INC	HL
	OR	A
	JR	Z,DS_06
	DEC	HL
	DEC	HL
DS_06	LD	(MSG_NUM),HL
DS_07	LD	A,(BACKWARD)	;Loop for next message.
	OR	A
	LD	HL,(A_MSG_POSN)
	INC	HL
	JR	Z,DS_08
	DEC	HL
	DEC	HL
DS_08	LD	(A_MSG_POSN),HL
	JP	DS_04
;
FIN_SCAN
	LD	A,(MSG_FOUND)
	OR	A
	RET	NZ
;Stop output so <T> scan won't look silly.
;;	LD	HL,M_NTFND
;;	CALL	MESS
	RET
;
BAD_RANGE
	LD	HL,M_BDRNG
	CALL	MESS
	RET
;
; ------------------------------
;
READ_MSGHDR
	LD	BC,(A_MSG_POSN)
	LD	DE,HDR_FCB
	CALL	DOS_POSIT
	JP	NZ,ERROR
	LD	HL,THIS_MSG_HDR
	CALL	DOS_READ_SECT
	JP	NZ,ERROR
	LD	HL,HDR_RBA	;Copy start of msg rba
	LD	DE,TXT_RBA
	LD	BC,3
	LDIR
	RET
;
; ------------------------------
;
IF_VISIBLE
	CALL	READ_MSGHDR
	LD	HL,HDR_FLAG
	BIT	FM_KILLED,(HL)
	RET	NZ		;not visible if killed.
	BIT	FM_PRIVATE,(HL)
	JR	Z,VISIBLE
	LD	DE,(USR_NUMBER)	;check uid if private
	LD	HL,(HDR_SNDR)
	OR	A
	SBC	HL,DE
	JR	Z,VISIBLE
	LD	HL,(HDR_RCVR)
	OR	A
	SBC	HL,DE
	JR	Z,VISIBLE
;else must be SYSOP.
	CALL	IF_SYSOP
	JR	NZ,VISIBLE
	XOR	A		;msg is unreadable.
	CP	1
	RET
VISIBLE
	CP	A		;msg is readable.
	RET
;
; ------------------------------
;
CRITERIA
	LD	A,(SCAN_MASK)
	CP	5		;range. all within.
	JR	Z,CRI_RNGE
	CP	3		;all.
	RET	Z
	CP	4		;unread
	JP	Z,CRI_UNRD
	CP	2		;TO me
	JR	Z,CRI_DEST
	CP	6		;FROM me
	RET	NZ
	LD	DE,(USR_NUMBER)
	LD	HL,(HDR_SNDR)
	OR	A
	SBC	HL,DE
	RET	;Z or NZ
;
CRI_DEST
	LD	DE,(USR_NUMBER)
	LD	HL,(HDR_RCVR)
	OR	A
	SBC	HL,DE
	RET	;z=they match.
;
CRI_RNGE
	LD	DE,(LAST_MSG)
	LD	HL,(FIRST_MSG)
	LD	A,D
	CP	H
	JR	NZ,CR_1
	LD	A,E
	CP	L
CR_1	JR	NC,CR_2
	EX	DE,HL
CR_2	PUSH	HL		;the smaller.
	LD	HL,(MSG_NUM)
	LD	A,D
	CP	H
	JR	NZ,CR_3
	LD	A,E
	CP	L
CR_3	POP	DE
	RET	C
	LD	A,D
	CP	H
	JR	NZ,CR_4
	LD	A,E
	CP	L
CR_4	RET	NC
	CP	A
	RET
;
CRI_UNRD
	CALL	CHK_DATE
	RET	C
	XOR	A
	RET
;
; ------------------------------
;
CHK_DATE
	LD	HL,(HDR_DATE+1)
	LD	DE,(LAST_CALL+1)
	CALL	CPHLDE
	RET	NZ
	LD	A,(LAST_CALL)
	LD	B,A
	LD	A,(HDR_DATE)
	CP	B
	RET
;
; ------------------------------
;
INFO_SETUP
	CALL	SET_MASK
;
	LD	HL,0
	LD	(N_MSG_TOP),HL
	LD	(A_TOP_1ST),HL
	LD	(A_TOP_LAST),HL
	LD	HL,(N_MSG)
	LD	A,H
	OR	L
	RET	Z
;
;Count how many messages can be seen by topic number
	LD	BC,(N_MSG)
	LD	HL,MSG_TOPIC
	LD	DE,0
	LD	IX,MY_TOPIC
	LD	IY,TOPIC_MASK
CNT_1	LD	A,(HL)
	AND	(IY)
	CP	(IX)
	JR	NZ,CNT_1A
	INC	DE
CNT_1A	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,CNT_1
;
	EX	DE,HL
	LD	(N_MSG_TOP),HL
	LD	A,H
	OR	L
	RET	Z
	EX	DE,HL
CNT_2	DEC	HL
	LD	A,(HL)
	AND	(IY)
	CP	(IX)
	JR	NZ,CNT_2
CNT_2A	LD	DE,MSG_TOPIC
	OR	A
	SBC	HL,DE
	LD	(A_TOP_LAST),HL
	LD	HL,MSG_TOPIC
CNT_3	LD	A,(HL)
	AND	(IY)
	CP	(IX)
	JR	Z,CNT_3A
	INC	HL
	JR	CNT_3
CNT_3A	LD	DE,MSG_TOPIC
	OR	A
	SBC	HL,DE
	LD	(A_TOP_1ST),HL
	RET			;finished.
;
; ------------------------------
;
;convert topic number to integer.
TOP_INT
;
	LD	E,A		;a=topic
	AND	3
	LD	B,A
	LD	C,49
	INC	B
	LD	A,-49
TI_1	ADD	A,C
	DJNZ	TI_1
	LD	D,A
	LD	A,E
	AND	1CH
	SRL	A
	SRL	A
	LD	B,A
	INC	B
	LD	C,7
	LD	A,-7
TI_2	ADD	A,C
	DJNZ	TI_2
	ADD	A,D
	LD	D,A
	LD	A,E
	AND	0E0H
	RLCA
	RLCA
	RLCA
	ADD	A,D
	LD	D,A
	RET
;
; ------------------------------
;
INIT	XOR	A
	LD	HL,IN_BUFF
	LD	(HL),A
	LD	(CHAR_POSN),HL
	RET
;
;End of BB1
