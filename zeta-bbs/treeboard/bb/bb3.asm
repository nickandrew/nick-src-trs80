; @(#) bb3.asm - BB code file #3, 30 Jul 89
;
; ------------------------------
;
HDR_SCAN
	LD	HL,M_MSG2
	CALL	MESS
	LD	HL,(MSG_NUM)
	CALL	PRINT_NUMB
;
	CALL	BGETC		;The flags?
	CALL	BGETC		;Dummy byte?
;
	LD	HL,M_SNDR
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
	LD	HL,M_RCVR
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
HS_08	LD	A,(HDR_FLAG)	;And privacy stuff
	BIT	FM_PRIVATE,A
	JR	Z,HS_09
	LD	HL,M_P
	CALL	MESS
HS_09
	LD	HL,M_DATE
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
	LD	HL,M_MSGTOP
	CALL	MESS
	LD	A,(HDR_TOPIC)
	CALL	TOPIC_PRINT
	LD	HL,M_SUBJ
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
	CALL	PUTCR
	RET
;
; ------------------------------
;
CHK_USERS
;name is in NAME_BUFF terminated by CR.
;move to USN_BUFF.
	LD	HL,NAME_BUFF
	LD	DE,USN_BUFF
CU_1	LD	A,(HL)
	LD	(DE),A
	CP	CR
	JR	Z,CU_2
	INC	HL
	INC	DE
	JR	CU_1
CU_2	LD	HL,USN_BUFF
	CALL	USER_SEARCH
	LD	HL,(UF_UID)
	LD	(US_NUM),HL
	RET	;Z or NZ (even with errors!)
;
; ------------------------------
;
OPT_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
	CALL	IF_CHAR
	JR	Z,OC_X3
;print out current options.
OC_0A	LD	HL,M_OPTIONS
	CALL	MESS
	LD	HL,OPTIONS
	BIT	FO_NORM,(HL)
	JR	Z,OC_3
	LD	HL,M_NORM
	CALL	MESS
	LD	HL,OPTIONS
OC_3	BIT	FO_EXP,(HL)
	JR	Z,OC_4
	LD	HL,M_EXP
	CALL	MESS
	LD	HL,OPTIONS
OC_4
;print up menu.
OC_X2	LD	HL,MENU_OPT
	CALL	MENU
	LD	HL,PMPT_OPT
	CALL	GET_STRING
OC_X3	CALL	GET_CHAR
	CP	CR
	JP	Z,MAIN
	CP	'3'
	JR	Z,SET_NORM
	CP	'4'
	JR	Z,SET_EXP
	JP	MAIN
;
OC_X4
	JP	MAIN
;
SET_NORM
	CALL	GET_CHAR
	CP	CR
	JR	NZ,OC_X2
	LD	HL,OPTIONS
	RES	FO_EXP,(HL)
	SET	FO_NORM,(HL)
	JR	OC_X4
;
SET_EXP
	CALL	GET_CHAR
	CP	CR
	JR	NZ,OC_X2
	LD	HL,OPTIONS
	RES	FO_NORM,(HL)
	SET	FO_EXP,(HL)
	JR	OC_X4
;
; ------------------------------
;
CLEAN_DISCON			;A clean disconnect.
	CALL	CLOSE_ALL
	LD	A,0
	JP	TERM_DISCON	;pass a disconnect.
;
; ------------------------------
;
SPEC_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
	LD	HL,MENU_SPEC
	CALL	MENU
	LD	HL,PMPT_SPEC
	CALL	GET_STRING
SPEC_1	CALL	GET_CHAR
	CP	CR
	JP	Z,MAIN
	CP	' '
	JR	Z,SPEC_1
	CALL	TO_UPPER_C
;
	CP	'#'
	JP	Z,MAIN
	CP	'C'		;Create subtopic
	JP	Z,CREATE_CMD
	CP	'D'		;Delete this topic
	JP	Z,DELTOP_CMD
	CP	'F'		;Forward msgs to user
	JP	Z,FORWARD_CMD
	CP	'M'
	JP	Z,MOVMSG_CMD
	CP	'R'
	JP	Z,RESEND_CMD	;In bb6
	CP	'S'		;Change topic status flags
	JP	Z,STATUS_CMD
	JP	BADSYN
;
; ------------------------------
;
MOVMSG_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
;
;***
MMGX_0
	LD	HL,M_MOVWHR	;move to where?
	CALL	GET_STRING
	LD	IX,TOPNAM_BUFF
MMGX_1
	CALL	GET_CHAR
	LD	(IX),A
	INC	IX
	CP	CR
	JR	NZ,MMGX_1
;
	LD	(IX-1),0
	LD	HL,TOPNAM_BUFF
	LD	A,(HL)
	OR	A
	JP	Z,MAIN
	CALL	FIND_TOP_NUM
	JR	NZ,MMGX_0
MMGX_4
	LD	HL,MOVEMESSAGE
	LD	(FUNCTION),HL
	LD	HL,M_MOVEMSG
	LD	(FUNCNM),HL
	CALL	DO_SCAN_1
	CALL	INFO_SETUP
	JP	SPEC_CMD
;
; ------------------------------
;
MOVEMESSAGE
	LD	A,(MSG_FOUND)
	OR	A
	JR	NZ,MMSG_1
	XOR	A
	LD	(MOVE_QUERY),A
	LD	HL,M_MVQRY
	CALL	YES_NO
	CP	'N'
	JR	Z,MMSG_1
	CP	'Q'
	JR	Z,MMSG_Q
	LD	A,1
	LD	(MOVE_QUERY),A
MMSG_1
	CALL	GET_$2
	CP	1
	JR	Z,MMSG_Q
;make sure message is TO me or FROM me or SYSOP.
	CALL	IF_SYSOP
	JR	NZ,MMSG_2
	LD	DE,(USR_NUMBER)
	LD	HL,(HDR_SNDR)
	OR	A
	SBC	HL,DE
	JR	Z,MMSG_2
	LD	HL,(HDR_RCVR)
	OR	A
	SBC	HL,DE
	JR	Z,MMSG_2
	LD	HL,M_MSG2
	CALL	MESS
	LD	HL,(MSG_NUM)
	CALL	PRINT_NUMB
	LD	HL,M_NTFRYO
	CALL	MESS
	RET
;
MMSG_2
	CALL	TEXT_POSN
	CALL	HDR_PRNT
	LD	A,(MOVE_QUERY)
	OR	A
	JR	Z,MMSG_3
	LD	HL,M_MOVEIT
	CALL	YES_NO
	CP	'Y'
	JR	Z,MMSG_3
	CP	'N'
	RET	Z
MMSG_Q	LD	A,1
	LD	(SCAN_ABORT),A
	RET
MMSG_3
	LD	HL,M_MOVING
	CALL	MESS
	LD	HL,(MSG_NUM)
	CALL	PRINT_NUMB
	CALL	PUTCR
;allow chance to abort.
	CALL	GET_$2
	CP	1
	JR	Z,MMSG_Q
;move message.
	CALL	TEXT_POSN
;
;Change message topic to number found
	LD	A,(FTN_TOP)
	LD	(HDR_TOPIC),A
;
;At this point the topic number is changed
;Anywhere the number appears it should be changed
; 1) NOT Text file -
; 2) Header file       *DONE*
; 3) Topic file (and in memory).   *DONE*
;
	LD	DE,MSG_TOPIC	;change in memory
	LD	HL,(A_MSG_POSN)
	ADD	HL,DE
	LD	A,(FTN_TOP)
	LD	(HL),A
	LD	HL,(A_MSG_POSN)
	LD	C,L
	LD	L,H
	LD	H,0
	LD	DE,16		;Offset 16 sectors.
	ADD	HL,DE
	LD	DE,TOP_FCB
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	LD	A,(FTN_TOP)
	CALL	$PUT
	JP	NZ,ERROR
;
;rewrite header.
	CALL	WRITE_MSG_HDR
;
;finished.
	LD	HL,M_MSGMVD
	CALL	MESS
	RET
;
; ------------------------------
;
;Treewalk: Quasi-recursive tree scan to read Unread msgs
TREAD_CMD
	LD	HL,M_TREEWALK
	CALL	MESS
;
	LD	A,(OPTIONS)
	LD	(TR_OPTIONS),A
;
	LD	A,(MY_TOPIC)
	LD	(TR_TOPIC),A
;
	XOR	A		;Go to General
	LD	(MY_TOPIC),A
;
;
	CALL	INFO_SETUP	;Move yo' asses!
;
	LD	HL,TOP_RMESSAGE
	LD	(FUNCTION),HL	;Funky!
	LD	HL,1
	LD	(FIRST_MSG),HL	;From 1
	LD	HL,(N_MSG_TOP)
	LD	(LAST_MSG),HL	;To   $
;
	LD	A,4		;Unread messages (so they think)
	LD	(SCAN_MASK),A
;
TOP_LOOP:
	LD	A,1
	LD	(TR_NEWFLAG),A
	XOR	A
	LD	(TR_SKIP),A
	LD	(MSG_FOUND),A
	LD	(SCAN_ABORT),A
	CALL	DO_SCAN		;Scan all this topic
;
	LD	A,(TR_SKIP)	;Takes precedence over
	OR	A		;scan_abort for topic
	JR	NZ,TL_00	;skip.
	LD	A,(SCAN_ABORT)
	OR	A
	JR	NZ,TL_01
;
TL_00
	LD	A,(MY_TOPIC)
	CALL	TREE_WALK	;Find next place to be
	CP	0		;If wrap to general
	JR	Z,TL_01		;End the treewalk
	CP	200
	JR	Z,TL_01		;The real end of the loop
	LD	(MY_TOPIC),A
;Check if used
	CALL	TOP_ADDR
	LD	A,(HL)
	OR	A
	JR	Z,TL_00		;If unused
;
	LD	A,(MY_TOPIC)
	CALL	INFO_SETUP
;
	LD	HL,1
	LD	(FIRST_MSG),HL	;From 1
	LD	HL,(N_MSG_TOP)
	LD	(LAST_MSG),HL	;To   $
	JR	TOP_LOOP
;
TL_01
	LD	A,(TR_TOPIC)
	LD	(MY_TOPIC),A
	CALL	INFO_SETUP
	JP	MAIN		;Finished.
;
; ------------------------------
;
TOP_RMESSAGE
	XOR	A
	LD	(SCRDONE),A
;
	LD	A,(TR_NEWFLAG)
	OR	A
	JR	Z,TRM_01
;
;** print topic name
	CALL	PUTCR
	LD	A,(MY_TOPIC)
	CALL	TOPIC_PRINT
	LD	A,2
	LD	(SCRDONE),A
;
	XOR	A
	LD	(TR_NEWFLAG),A
;
TRM_01
;Print message header
	CALL	PUTCR
	CALL	TEXT_POSN
	CALL	HDR_PRNT
;
;Initialise more for treewalk
	LD	HL,TW_INFUNC	;Setup input function
	LD	(INFUNC),HL
	LD	HL,TW_KEYFUNC	;Setup key function
	LD	(KEYFUNC),HL
	LD	A,(SCRDONE)
	ADD	A,7
	LD	(SCRDONE),A
;
	CALL	MOREPIPE	;Display the message through more
	OR	A
	JR	NZ,TRM_10
	JR	TRM_08
;
TRM_08	LD	HL,M_TRMPAUSE
	CALL	MESS
TRM_09	CALL	GET_$2
	OR	A
	JR	Z,TRM_09
TRM_10
	CP	' '
	JR	Z,TRM_11	;Next message
	CP	'?'
	JR	Z,TRM_16	;Help
	AND	5FH
	CP	'A'
	JR	Z,TRM_14	;Read again
	CP	'N'
	JR	Z,TRM_11	;Next message
	CP	'R'
	JR	Z,TRM_15	;Reply
	CP	'T'
	JR	Z,TRM_12	;Skip rest of topic
	CP	'Q'
	JR	Z,TRM_13	;Quit the Treewalk
	JR	TRM_09		;Try again
;
TRM_11
	CALL	PUTCR
	RET
;
TRM_12
	LD	A,1
	LD	(SCAN_ABORT),A
	LD	(TR_SKIP),A
	CALL	PUTCR
	RET
;
TRM_13
	LD	A,1
	LD	(SCAN_ABORT),A
	RET
;
TRM_14
	XOR	A
	LD	(SCRDONE),A
	JP	TRM_01
;
TRM_15
	CALL	DO_REPLY
	RET
;
TRM_16
	LD	HL,M_TRMHELP
	CALL	MESS
	JR	TRM_08
;
; ------------------------------
;
TW_INFUNC
	CALL	BGETC
	RET	NZ
	CP	A
	RET
;
; ------------------------------
;
TW_KEYFUNC
	CP	'?'
	JR	Z,TWK_01	;Help
	AND	5FH
	CP	'A'
	JR	Z,TWK_02	;Read again
	CP	'N'
	JR	Z,TWK_02	;Next message
	CP	'R'
	JR	Z,TWK_02	;Reply
	CP	'T'
	JR	Z,TWK_02	;Next topic
	CP	'Q'
	JR	Z,TWK_02	;Quit
	XOR	A		;Redisplay more prompt
	RET
;
TWK_01
	LD	HL,M_TRMHELP
	CALL	MESS
	XOR	A
	RET
;
TWK_02
	JP	MORE_Q
;
; ------------------------------
; Find the next topic in the tree in a preorder scan
TREE_WALK
	INC	A
	RET
;
; ------------------------------
;
TOPIC_PRINT
	LD	(TEMP_TOPIC),A
	CALL	TOP_ADDR
	CALL	TOP_PRT_1
	RET
;
TOP_PRT_1
	LD	A,(HL)
	CP	CR
	RET	Z
	OR	A
	JR	NZ,TP1_1
	LD	A,'*'
	CALL	PUT
	RET
TP1_1
	CALL	PUT
	INC	HL
	JR	TOP_PRT_1
;
; ------------------------------
;
STATUS_CMD
	CALL	GET_CHAR
	CP	CR
	JP	NZ,BADSYN
;
	CALL	IF_SYSOP
	JP	Z,NO_PERMS
;
	LD	HL,PMPT_STATUS
	CALL	GET_STRING
	CALL	GET_CHAR
	CP	CR
	JP	Z,MAIN
	AND	5FH
	CP	'E'
	JR	Z,STAT_01
	CP	'L'
	JR	Z,STAT_02
	JP	BADSYN
;
STAT_01
	LD	B,1
	JR	STAT_03
STAT_02
	LD	B,0
	JR	STAT_03
;
STAT_03
	PUSH	BC
	LD	A,(MY_TOPIC)
	CALL	TOP_ADDR
	LD	DE,19
	ADD	HL,DE
	POP	BC
	LD	A,(HL)
	AND	0FEH
	OR	B
	LD	(HL),A
	PUSH	AF
;
;Find offset within topic file and overwrite 1 byte
	LD	A,(MY_TOPIC)
	CALL	MUL_20
	LD	DE,16		;Size of initial status information
	ADD	HL,DE
	LD	DE,19
	ADD	HL,DE		;Offset within data structure
	LD	C,L
	LD	L,H
	LD	H,0
	LD	DE,TOP_FCB
	CALL	DOS_POS_RBA
	POP	BC
	JP	NZ,ERROR
	LD	A,B
	CALL	$PUT
	JP	NZ,ERROR
;
	LD	HL,M_STATOK
	CALL	MESS
	JP	MAIN
;
;End of bb3
