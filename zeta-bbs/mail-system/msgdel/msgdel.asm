;msgdel: Delete messages older than a certain age
;usage:  msgdel
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
*GET	FIDONET
;
	COM	'<Msgdel 1.0  29-Dec-88>'
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info.
;
	ORG	BASE+100H
;
START	LD	SP,START
	CALL	INIT
	CALL	OPEN_FILES
	CALL	READ_INFO
	CALL	EXPIRE
	CALL	WRITE_INFO
	CALL	REPORT
	CALL	CLOSE_FILES
	XOR	A
	JP	TERMINATE
;
INIT
	LD	A,(4045H)
	LD	(DD),A
	LD	A,(4046H)
	LD	(MM),A
	LD	A,(4044H)
	LD	(YY),A
	LD	A,87		;Some old year...
	LD	(YEAR_OFF),A
	CALL	GET_DATE_INT
	LD	(TODAY),HL
	RET
;
OPEN_FILES
	LD	HL,_BLOCK
	LD	DE,TXT_FCB
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	NZ,OPEN_ERROR
;
	LD	HL,HDR_BUF
	LD	DE,HDR_FCB
	LD	B,16
	CALL	DOS_OPEN_EX
	JR	NZ,OPEN_ERROR
;
	LD	HL,TOP_BUF
	LD	DE,TOP_FCB
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	NZ,OPEN_ERROR
;
	LD	A,(TXT_FCB+1)
	AND	0F8H
	OR	40H
	LD	(TXT_FCB+1),A
;
	LD	A,(HDR_FCB+1)
	AND	0F8H
	OR	40H
	LD	(HDR_FCB+1),A
;
	LD	A,(TOP_FCB+1)
	AND	0F8H
	OR	40H
	LD	(TOP_FCB+1),A
	RET
;
OPEN_ERROR
	LD	HL,M_OPERR
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,1
	JP	TERMINATE
;
READ_INFO
	CALL	_READFREE
	CALL	READ_TOPIC
	RET
;
WRITE_INFO
	CALL	_WRITEFRE
	CALL	WRITE_TOPIC
	RET
;
READ_TOPIC
	LD	DE,TOP_FCB
	CALL	DOS_REWIND
;
	LD	HL,TOPIC
	LD	B,16
RDF_1	PUSH	BC
	LD	DE,TOP_FCB
	CALL	DOS_READ_SECT
	JP	NZ,RD1A_ERROR
	EX	DE,HL
	LD	HL,TOP_BUF
	LD	BC,256
	LDIR
	EX	DE,HL
	POP	BC
	DJNZ	RDF_1
;
;Force the topic file into byte (or LRL) I/O mode, so
;write_topic will not trash the first sector.
	LD	DE,TOP_FCB
	CALL	$GET
;
	RET
;
RD1A_ERROR
	POP	BC
RD1_ERROR
	LD	HL,M_R1ERR
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,1
	JP	TERMINATE
;
WRITE_TOPIC
	LD	DE,TOP_FCB
	CALL	DOS_REWIND
;
;;	LD	HL,TOPIC
;;	LD	DE,TOP_BUF
;;	LD	BC,256
;;	LDIR
;
	LD	HL,TOPIC
	LD	DE,TOP_FCB
	CALL	DOS_WRIT_SECT
	JP	NZ,WRT_ERROR
	RET
;
EXPIRE
	LD	HL,0
	LD	(THIS_MSG),HL
;
	LD	DE,HDR_FCB
	CALL	DOS_REWIND
;
EXP_01
	LD	HL,(THIS_MSG)
	LD	DE,(N_MSG)
	OR	A
	SBC	HL,DE
	JR	Z,EXP_02
;
	CALL	READ_MSG_HDR
	CALL	TEST_EXPIRE
	CALL	Z,KILL_IT
;
	LD	HL,(THIS_MSG)
	INC	HL
	LD	(THIS_MSG),HL
	JR	EXP_01
;
EXP_02
	RET
;
READ_MSG_HDR
	LD	HL,THIS_MSG_HDR
	LD	DE,HDR_FCB
	CALL	DOS_READ_SECT
	JR	NZ,RD2_ERROR
	RET
;
RD2_ERROR
	LD	HL,M_R2ERR
	LD	DE,DCB_2O
	CALL	MESS_0
	CALL	CLOSE_FILES
	LD	A,3
	JP	TERMINATE
;
TEST_EXPIRE
	LD	A,(HDR_FLAG)
	BIT	FM_KILLED,A
	RET	NZ
;
	BIT	FM_NETMSG,A
	JR	Z,TEX_01
	BIT	FM_NETSENT,A
	JP	Z,RET_NZ
TEX_01
	LD	A,(HDR_DATE)
	LD	(DD),A
	LD	A,(HDR_DATE+1)
	LD	(MM),A
	LD	A,(HDR_DATE+2)
	LD	(YY),A
	CALL	GET_DATE_INT
	LD	(MESSAGE_DATE),HL
;
	LD	A,(HDR_TOPIC)
	CALL	TOP_INT
	CALL	MUL_20
	LD	DE,TOPIC_DAT
	ADD	HL,DE
	LD	DE,18
	ADD	HL,DE
;
	LD	A,(HL)		;Expiry interval in days
	OR	A
	JP	Z,RET_NZ	;Never expire
;
	LD	E,A
	LD	D,0
	LD	HL,(TODAY)
	OR	A
	SBC	HL,DE
	LD	(EXPIRE_DATE),HL
;
	LD	DE,(MESSAGE_DATE)
	EX	DE,HL
	OR	A
	SBC	HL,DE
	JP	NC,RET_NZ
	CP	A
	RET
;
REPORT
	RET
;
KILL_IT
	LD	HL,M_KILLING
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	HL,(THIS_MSG)
	INC	HL
	CALL	PRINT_NUMB
	LD	HL,M_CR
	LD	DE,DCB_2O
	CALL	MESS_0
;
	LD	HL,HDR_FLAG
	SET	FM_KILLED,(HL)
;
	CALL	FREE_BLOCKS
;
	LD	A,1
	LD	(HDR_TOPIC),A
;
	CALL	WRITE_TOPIC_NO
	CALL	WRITE_HDR_REC
;
	LD	HL,(N_KLD_MSG)
	INC	HL
	LD	(N_KLD_MSG),HL
	RET
;
FREE_BLOCKS			;Free all blocks used by the current message
	LD	HL,0
	LD	(FREED),HL
;
	LD	HL,(HDR_RBA+1)	;First block
	LD	(_THISBLK),HL
KF_01
	CALL	_PUTFREE
;
	LD	HL,(FREED)
	INC	HL
	LD	(FREED),HL
;
	LD	HL,(_THISBLK)
	CALL	_SEEKTO
	CALL	_READBLK
	JR	NZ,KF_02	;Error
	LD	HL,0
	CALL	_GETINT
	LD	(_THISBLK),HL
	LD	A,H
	OR	L
	JR	NZ,KF_01
;
	LD	HL,M_FREED1
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	HL,(FREED)
	CALL	PRINT_NUMB
	LD	HL,M_FREED2
	LD	DE,DCB_2O
	CALL	MESS_0
;
	RET
;
KF_02	LD	HL,M_KILLERR
	LD	DE,DCB_2O
	CALL	MESS_0
	RET
;
WRITE_TOPIC_NO
	LD	HL,(THIS_MSG)
	LD	DE,16*256	;16 sectors...
	ADD	HL,DE
	LD	C,L
	LD	L,H
	LD	H,0
	LD	DE,TOP_FCB
	CALL	DOS_POS_RBA
	JP	NZ,WRT_ERROR
;
	LD	A,1
	CALL	$PUT
	JP	NZ,WRT_ERROR
	RET
;
WRITE_HDR_REC
	LD	DE,HDR_FCB
	CALL	DOS_BACK_RECD
	JP	NZ,WRT_ERROR
;
	LD	HL,THIS_MSG_HDR
	LD	DE,HDR_FCB
	CALL	DOS_WRIT_SECT
	JP	NZ,WRT_ERROR
	RET
;
GET_DATE_INT
	LD	HL,0
	LD	DE,365
	LD	A,(YEAR_OFF)
	LD	B,A
	LD	A,(YY)
	LD	C,A
GDI_01
	LD	A,B
	CP	C
	JR	Z,GDI_03
	ADD	HL,DE
	AND	3		;Is it a leap year?
	JR	NZ,GDI_02
	INC	HL
GDI_02
	INC	B
	JR	GDI_01
;
GDI_03
	LD	A,(DD)
	DEC	A		;Zero offset
	LD	E,A
	LD	D,0
	ADD	HL,DE
;
	LD	A,(MM)
	DEC	A
	ADD	A,A
	LD	E,A
	LD	D,0
	PUSH	HL
	LD	HL,MONTH_COUNT
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	POP	HL
	ADD	HL,DE
;
	LD	A,(YY)
	AND	3
	JR	NZ,GDI_04
	LD	A,(MM)
	CP	3
	JR	C,GDI_04
	INC	HL		;Leap day if march or later
GDI_04
	RET
;
TOP_INT
	LD	E,A
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
MUL_20
	LD	L,A
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
CLOSE_FILES
	LD	DE,TXT_FCB
	CALL	DOS_CLOSE
	JR	NZ,CLOSE_ERR
	LD	DE,TOP_FCB
	CALL	DOS_CLOSE
	JR	NZ,CLOSE_ERR
	LD	DE,HDR_FCB
	CALL	DOS_CLOSE
	JR	NZ,CLOSE_ERR
	RET
;
CLOSE_ERR
	LD	HL,M_CLERR
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,1
	JP	TERMINATE
;
WRT_ERROR
	LD	HL,M_W1ERR
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,3
	JP	TERMINATE
;
RET_NZ
	XOR	A
	CP	1
	RET
;
*GET	BB7
*GET	ROUTINES
;
;-------------------------------
M_OPERR		DEFM	'Error opening message files',CR,0
M_R1ERR		DEFM	'Error reading initial information',CR,0
M_KILLING	DEFM	'Killing message ',0
M_KILLERR	DEFM	'Error while killing a message',CR,0
M_CLERR		DEFM	'Error closing message files',CR,0
M_R2ERR		DEFM	'Error reading message files - now corrupt',CR,0
M_W1ERR		DEFM	'Error writing message files - now corrupt',CR,0
M_CR		DEFM	CR,0
M_FREED1	DEFM	'Freed ',0
M_FREED2	DEFM	' blocks.',CR,0
;
TOP_BUF		DEFS	256
HDR_BUF		DEFS	256
;
TXT_FCB		DEFM	'msgtxt.zms',CR
		DC	32-11,0
TOP_FCB		DEFM	'msgtop.zms',CR
		DC	32-11,0
HDR_FCB		DEFM	'msghdr.zms',CR
		DC	32-11,0
;
MONTH_COUNT
		DEFW	0,31,59,90,120,151,181,212,243,273,304,334
;
TODAY		DEFW	0
MESSAGE_DATE	DEFW	0
EXPIRE_DATE	DEFW	0
THIS_MSG	DEFW	0
DD		DEFB	0
MM		DEFB	0
YY		DEFB	0
YEAR_OFF	DEFB	0
FREED		DEFW	0
;-------------------------------
TOPIC
N_MSG		DEFW	0
N_KLD_MSG	DEFW	0
EOF_RBA		DEFB	0,0,0
		DC	9,0
TOPIC_DAT
		DEFS	4080
;-------------------------------
;
HDR_LEN	EQU	16
THIS_MSG_HDR
HDR_FLAG	DEFB	0
HDR_LINES	DEFB	0
HDR_RBA		DEFB	0,0,0
HDR_DATE	DEFB	0,0,0
HDR_SNDR	DEFW	0
HDR_RCVR	DEFW	0
HDR_TOPIC	DEFB	0
HDR_TIME	DEFB	0,0,0
;
FM_KILLED	EQU	0
FM_PRIVATE	EQU	1
FM_IMPORT	EQU	2
FM_RUDE		EQU	3
FM_NETMSG	EQU	4
FM_NETSENT	EQU	5
;-------------------------------
;
THIS_PROG_END	EQU	$
;
	END	START
