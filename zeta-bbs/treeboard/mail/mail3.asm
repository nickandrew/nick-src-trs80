;@(#) mail3.asm - mail code file #3, 26 Jun 89
;
TOPIC_PRINT
	LD	(TEMP_TOPIC),A
	LD	A,0
	CALL	TOP_ADDR
	CALL	TOP_PRT_1
	LD	A,(TEMP_TOPIC)
	AND	0E0H
	OR	A
	RET	Z
;
	PUSH	AF
	LD	A,'>'
	CALL	PUT
	POP	AF
	CALL	TOP_INT
	CALL	TOP_ADDR
	CALL	TOP_PRT_1
;
	LD	A,(TEMP_TOPIC)
	AND	0FCH
	LD	B,A
	AND	1CH
	RET	Z
	LD	A,B
	PUSH	AF
	LD	A,'>'
	CALL	PUT
	POP	AF
	CALL	TOP_INT
	CALL	TOP_ADDR
	CALL	TOP_PRT_1
;
	LD	A,(TEMP_TOPIC)
	OR	A
	AND	3
	RET	Z
	LD	A,'>'
	CALL	PUT
	LD	A,(TEMP_TOPIC)
	CALL	TOP_INT
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
TOPIC_DOWN
	LD	B,A
	OR	A
	JR	NZ,TD_1
	LD	A,C		;level 0 to 1.
	AND	7
	RRCA
	RRCA
	RRCA
	CP	A
	RET
TD_1	LD	A,B
	AND	1CH
	JR	NZ,TD_2
	LD	A,C		;level 1 to 2.
	AND	7
	RLCA
	RLCA
	OR	B
	CP	A
	RET
TD_2	LD	A,B
	AND	3
	RET	NZ
	LD	A,C
	AND	3
	OR	B
	CP	A
	RET
;
TOPIC_UP
	LD	B,A
	AND	3
	JR	Z,TU_1
	LD	A,B
	AND	0FCH
	RET
TU_1	LD	A,B
	AND	1CH
	JR	Z,TU_2
	LD	A,B
	AND	0E0H
	RET
TU_2	XOR	A
	RET
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
;
	LD	HL,M_RCVR
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
;
HS_08
HS_09
	LD	HL,M_DATE
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
;
	LD	HL,M_SUBJ
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
	CALL	PUTCR
	RET
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
SET_MASK
	LD	A,0FFH		;all!
	LD	(TOPIC_MASK),A
	LD	A,(OPTIONS)
	BIT	FO_LOWR,A
	RET	Z		;if LOWER not selected.
	LD	A,(MY_LEVEL)
	LD	E,A
	LD	D,0
	LD	HL,MASK_DATA
	ADD	HL,DE
	LD	A,(HL)
	LD	(TOPIC_MASK),A
	RET
;
CLEAN_DISCON			;A clean disconnect.
	CALL	CLOSE_ALL
	LD	A,0
	JP	TERM_DISCON	;pass a disconnect.
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
;;	PUSH	AF
;;	CALL	GET_CHAR
;;	POP	AF
;
	CP	'#'
	JP	Z,MAIN
;;	CP	'C'		;Create subtopic
;;	JP	Z,CREATE_CMD
	CP	'D'		;Delete this topic
	JP	Z,DELTOP_CMD
	CP	'F'		;Forward msgs to user
	JP	Z,FORWARD_CMD
	CP	'M'
	JP	Z,MOVMSG_CMD
	CP	'R'
	JP	Z,RESEND_CMD	;In bb6
	JP	BADSYN
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
	CALL	GET_2I
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
	CALL	GET_2I
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
	CALL	ROM@PUT
	JP	NZ,ERROR
;
;rewrite header.
	CALL	WRITE_MSGHDR
;
;finished.
	LD	HL,M_MSGMVD
	CALL	MESS
	RET
;
MOVMSG_CMD
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
;End of mail3
