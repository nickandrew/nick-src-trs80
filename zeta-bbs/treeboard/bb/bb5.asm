;BB5.asm: BB subroutines, on 30 Jul 89
;
; ------------------------------
;
HDR_PRNT			;print a header.
	LD	HL,M_MSG2
	CALL	MESS
	LD	HL,(MSG_NUM)
	CALL	PRINT_NUMB
	LD	HL,M_SPACES
	CALL	MESS
	LD	A,(HDR_TOPIC)
	CALL	TOPIC_PRINT
;
	CALL	BGETC		;bypass dummy byte
	CALL	BGETC		;bypass # of lines
;
	CALL	PUTCR
;
	LD	HL,M_SNDR
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
;
	LD	HL,M_RCVR
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
;
	LD	A,(HDR_FLAG)
	BIT	FM_PRIVATE,A
	JR	Z,HPR_2
	LD	HL,M_P
	CALL	MESS
HPR_2
	LD	A,(HDR_FLAG)
	BIT	FM_NETSENT,A
	JR	Z,HPR_2A	;if not sent
	LD	HL,M_NETSENT
	CALL	MESS
HPR_2A
;
	LD	HL,M_DATE
	CALL	MESS
	CALL	TXT_GET_PUT_NCR		;now date & time.
;
	LD	HL,M_SUBJ
	CALL	MESS
	CALL	TXT_GET_PUT_NCR
;
	CALL	PUTCR
	CALL	PUTCR
	RET
;
; ------------------------------
;
;Store fields of a header in buffers
HDR_STORE
	CALL	BGETC		;bypass dummy byte
	CALL	BGETC		;bypass # of lines
;
	LD	HL,B_FROM
	CALL	HDR_GETNCR
;
	LD	HL,B_TO
	CALL	HDR_GETNCR
;
	LD	HL,B_DATE
	CALL	HDR_GETNCR
;
	LD	HL,B_SUBJ
	CALL	HDR_GETNCR
	RET
;
HDR_GETNCR
	LD	B,80
HGN_01
	PUSH	BC
	PUSH	HL
	CALL	BGETC
	POP	HL
	POP	BC
	JR	NZ,HGN_02
	CP	CR
	JR	Z,HGN_02
	OR	A
	JR	Z,HGN_02
	LD	(HL),A
	INC	HL
	DJNZ	HGN_01
HGN_02
	LD	(HL),0
	RET
;
; ------------------------------
;
RET_NZ
	OR	A
	RET	NZ
	CP	1
	RET
;
MESS	PUSH	DE
	LD	DE,DCB_2O
	CALL	MESS_0
	POP	DE
	RET
;
MESS_CR
	PUSH	DE
	LD	DE,DCB_2O
MCR_01
	LD	A,(HL)
	PUSH	AF
	CALL	ROM@PUT
	POP	AF
	CP	CR
	JR	Z,MCR_02
	OR	A
	JR	Z,MCR_02
	INC	HL
	JR	MCR_01
MCR_02
	POP	DE
	RET
;
; ------------------------------
;
MENU
	LD	(CONTROL),HL
;
	LD	HL,(CHAR_POSN)
	LD	A,(HL)
	OR	A
	RET	NZ
;
	LD	HL,(CONTROL)
	LD	A,(OPTIONS)
	BIT	FO_EXP,A
	JR	Z,MU_0
	INC	HL
	INC	HL
	INC	HL
	INC	HL
MU_0
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
MU_1	LD	A,(HL)
	OR	A
	JR	NZ,MU_2
	XOR	A
	CP	1
	RET
MU_2
	CALL	PUT
	LD	DE,DCB_2I
	CALL	ROM@GET
	INC	HL
	OR	A
	JR	Z,MU_1
	CP	CR
	JR	NZ,MU_3
;
	CALL	PUT
	LD	A,CR
	CALL	PUT
;
	LD	HL,IN_BUFF
	LD	(HL),0
	LD	(CHAR_POSN),HL
	XOR	A
	CP	1
	RET
;
MU_3
	PUSH	HL
	LD	HL,(CONTROL)
	INC	HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CP	'a'
	JR	C,MU_3A
	AND	5FH
MU_3A
	LD	B,A
	EX	DE,HL
MU_4	LD	A,(HL)
	OR	A
	JR	Z,MU_5
	CP	B
	INC	HL
	JR	NZ,MU_4
;
	POP	HL
	LD	A,B
	LD	(IN_BUFF),A
	LD	A,CR
	LD	(IN_BUFF+1),A
	CALL	PUT
	XOR	A
	LD	(IN_BUFF+2),A
	LD	HL,IN_BUFF
	LD	(CHAR_POSN),HL
	XOR	A
	RET
;
MU_5
	POP	HL
	JR	MU_1
;
; ------------------------------
;
GET_STRING
	PUSH	HL
	LD	HL,(CHAR_POSN)
	LD	A,(HL)
	OR	A
	JR	Z,GS_001
	POP	HL		;some chars already ahead
	RET
GS_001
	POP	HL
	PUSH	HL
	CALL	MESS
	LD	HL,IN_BUFF
	LD	B,48
	CALL	ROM@WAIT_LINE
	JR	C,GS_001
	POP	HL
	LD	HL,IN_BUFF
	LD	(CHAR_POSN),HL
GS_002	LD	A,(HL)
	INC	HL
	CP	CR
	JR	NZ,GS_002
	LD	(HL),0
	RET
;
; ------------------------------
;
GET_CHAR
	LD	HL,(CHAR_POSN)
	LD	A,(HL)
	OR	A
	RET	Z
	INC	HL
	LD	(CHAR_POSN),HL
	CP	';'
	JR	NZ,GC_1
	LD	A,CR
GC_1	CP	A
	RET
;
; ------------------------------
;
IF_CHAR	LD	HL,(CHAR_POSN)	;Set NZ if no more chars
	LD	A,(HL)
	OR	A
	JR	Z,IC_1
	CP	A
	RET
IC_1	CP	1
	RET
;
IF_NUM	CP	'0'
	RET	C	;&NZ
	CP	'9'+1
	JR	C,IN_1
	OR	A	;&NZ
	RET
IN_1	CP	A
	RET
;
; ------------------------------
;
GET_NUM
	LD	HL,0
	CALL	IF_NUM
	RET	NZ
GN_1	SUB	'0'
	ADD	A,L
	LD	L,A
	JR	NC,GN_2
	INC	H
	JR	Z,O_FLO
GN_2	PUSH	HL
	CALL	IF_CHAR
	POP	HL
	CALL	IF_NUM
	JR	NZ,GN_3
	PUSH	HL
	CALL	GET_CHAR
	POP	HL
	PUSH	HL
	POP	DE
	ADD	HL,HL	;*2
	ADD	HL,HL	;*4
	ADD	HL,DE	;*5
	ADD	HL,HL	;*10
;
	OR	A
	PUSH	HL
	SBC	HL,DE
	POP	HL
	JR	C,O_FLO
	JR	GN_1
GN_3	CP	A
	RET
O_FLO	LD	HL,0C000H	;sufficiently big
	XOR	A
	CP	1
	RET
;
;to stop all such 65536-65537 attempts.
;
; ------------------------------
;
;
FUNC	LD	HL,(FUNCTION)
	LD	A,H
	OR	L
	RET	Z
	JP	(HL)
;
; ------------------------------
;
PUT	PUSH	DE
	LD	DE,DCB_2O
	CALL	ROM@PUT
	POP	DE
	RET
;
TXT_GET_PUT_CR
	PUSH	DE
TGPC_01
	CALL	BGETC
	PUSH	AF
	LD	DE,DCB_2O
	CALL	ROM@PUT
	POP	AF
	CP	CR
	JR	NZ,TGPC_01
	POP	DE
	RET
;
CPHLDE	LD	A,H
	CP	D
	RET	NZ
	LD	A,L
	CP	E
	RET
;
TOP_ADDR
	CALL	MUL_20
	LD	DE,TOPIC_DAT
	ADD	HL,DE
	RET
;
MUL_20	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	PUSH	HL
	POP	DE
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	RET
;
TO_UPPER
	LD	A,(HL)
	CP	CR
	RET	Z
	OR	A
	RET	Z
	CP	ETX
	RET	Z
	INC	HL
	CP	'a'
	JR	C,TO_UPPER
	CP	'z'+1
	JR	NC,TO_UPPER
	DEC	HL
	AND	5FH
	LD	(HL),A
	INC	HL
	JR	TO_UPPER
;
YES_NO
	PUSH	HL
	LD	A,(HL)
	OR	A
	JR	Z,YN_5
	CALL	PUT
	LD	DE,DCB_2I		;was $ta
	CALL	ROM@GET
	OR	A
	JR	NZ,YN_2
YN_1	POP	HL
	INC	HL
	JR	YES_NO
;
YN_2	AND	5FH
	CP	'Y'
	JR	Z,YN_3
	CP	'Q'
	JR	Z,YN_3
	CP	'N'
	JR	Z,YN_3
	JR	YN_1
YN_3	POP	HL
	LD	HL,M_YES
	CP	'Y'
	JR	Z,YN_4
	LD	HL,M_NO
	CP	'N'
	JR	Z,YN_4
	LD	HL,M_QUIT
YN_4
	PUSH	AF
	CALL	MESS
	POP	AF
	CP	A
	RET
YN_5	LD	DE,DCB_2I
	CALL	ROM@GET
	AND	5FH
	CP	'Y'
	JR	Z,YN_2
	CP	'N'
	JR	Z,YN_2
	CP	'Q'
	JR	Z,YN_2
	JR	YN_5
;
TEXT_POSN
;
	LD	HL,(TXT_RBA+1)
	CALL	_SEEKTO
	CALL	_READBLK
	LD	HL,2
	LD	(_BLKPOS),HL
;
	CALL	BGETC
	CP	0FFH
	LD	A,1
	JP	NZ,ERROR
	RET
;
;
CHK_CHAR
	LD	C,(HL)
	INC	HL
	LD	B,0
	CP	'a'
	JR	C,CKCH_1
	AND	5FH
CKCH_1	CPIR
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
;find_top_num: Given a string topic name, find the number
;return NZ if not found
FIND_TOP_NUM
	LD	(FTN_STR),HL
	CALL	FTN_COPY
	RET	NZ		;if invalid name
;
;
	XOR	A
	LD	(FTN_TOP),A
;
FTN_1	LD	HL,(FTN_STR)
	LD	A,(HL)
	OR	A
	JR	Z,FTN_EXIT
	LD	A,(FTN_TOP)
	CP	200		;MAX_TOPICS
	JR	Z,FTN_BAD
;
	CALL	FTN_CMP
	JR	NZ,FTN_2
;
;Found!
	JR	FTN_EXIT
;
FTN_2
	LD	A,(FTN_TOP)
	INC	A
	LD	(FTN_TOP),A
	JR	FTN_1
;
FTN_BAD
	XOR	A
	CP	1
	RET
;
FTN_EXIT
	LD	A,(FTN_TOP)
	CP	A
	RET
;
FTN_CMP
	LD	A,(FTN_TOP)
	CALL	TOP_ADDR
	LD	A,(HL)
	OR	A
	JR	NZ,FTNC_1
	XOR	A
	CP	1
	RET
FTNC_1
	LD	DE,FTN_NAME
FTNC_2	LD	A,(HL)
	CP	CR
	JR	Z,FTNC_3
	OR	A
	JR	Z,FTNC_3
	CALL	CI_CMP
	JR	NZ,FTNC_4
	INC	HL
	INC	DE
	JR	FTNC_2
FTNC_3	LD	A,(DE)
	OR	A
	JR	Z,FTNC_5
FTNC_4
	XOR	A
	CP	1
	RET
FTNC_5	CP	A
	RET
;
FTN_COPY
	LD	HL,(FTN_STR)
	LD	DE,FTN_NAME
	LD	B,15
FTNC_6	LD	A,(HL)
	OR	A
	JR	Z,FTNC_8
	CP	CR
	JR	Z,FTNC_8
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	FTNC_6
	XOR	A
	CP	1
	RET
FTNC_8	LD	(FTN_STR),HL
	XOR	A
	LD	(DE),A
	RET
;
PUTCR
	LD	A,CR
	CALL	PUT
	RET
;
GET_2I
	LD	DE,DCB_2I
	CALL	ROM@GET
	RET
;
; ------------------------------
;
IF_VISITOR
	LD	A,(PRIV_2)
	BIT	IS_VISITOR,A
	RET
;
IF_SYSOP
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	RET
;
;End of bb5
