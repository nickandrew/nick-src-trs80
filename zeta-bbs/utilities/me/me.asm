;me: Message entry for BB primarily, but other things too
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
MAX_LINES	EQU	250
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	CLEAN_DISCON
;End of program load info.
;
	COM	'<me 1.0  28 May 88>'
;
	ORG	BASE+100H
;
START	LD	SP,START
	;-;	Process arguments, initialise etc
	JP	ENTER_CMD
;
EXIT	;-;	Close output file etc
	XOR	A
	JP	TERMINATE
;
CANCEL	;-;	Close output file etc
	LD	A,1
;
	JP	TERMINATE
;
ENTER_CMD
;
;Set highest allowable address.
	LD	HL,(HIMEM)
	LD	DE,-256		;Give it some clearance!
	ADD	HL,DE
	LD	(TEXT_HIMEM),HL
	LD	HL,F_WARN
	RES	1,(HL)		;Message length warning
;
	LD	HL,M_ENTER
	CALL	MESS
;
	CALL	SETUP_MEM	;Date & sender name
	CALL	GET_NAME	;local & networking.
	JP	NZ,CANCEL
;
	CALL	ADD_DATE	;Add date to text_buff
	CALL	GET_SUBJ	;Add a subject
	JP	NZ,CANCEL
;
	CALL	ENTER_MSG	;enter message manually
	JP	NZ,CANCEL	;if aborted
	CALL	SAVE_MSG	;save it to txt
	JP	EXIT
;
SETUP_MEM
	XOR	A
	LD	(NETMSG),A	;Not a net message yet.
	LD	(LINES),A	;No lines in it.
	CALL	INIT_HDR	;zero all bytes of it.
	XOR	A
	LD	(HDR_FLAG),A
;
	LD	A,(4041H)	;Date/time stamp
	LD	(HDR_TIME),A	;Sec
	LD	A,(4042H)
	LD	(HDR_TIME+1),A	;Min
	LD	A,(4043H)
	LD	(HDR_TIME+2),A	;Hours
	LD	A,(4045H)
	LD	(HDR_DATE),A	;Day
	LD	A,(4046H)
	LD	(HDR_DATE+1),A	;Mon
	LD	A,(4044H)
	LD	(HDR_DATE+2),A	;Year
;
	LD	DE,TEXT_BUF
	LD	(MEM_PTR),DE
	LD	HL,(USR_NAME)
SM_01	LD	A,(HL)		;Copy senders name
	CP	CR
	JR	Z,SM_02
	OR	A
	JR	Z,SM_02
	LD	(DE),A
	INC	HL
	INC	DE
	JR	SM_01
;
SM_02	LD	A,CR
	LD	(DE),A
	INC	DE
	EX	DE,HL
	LD	(MEM_PTR),HL
	LD	(MEMT_PTR),HL
	RET
;
;
;Allow typing in of the message only....
ENTER_MSG
	XOR	A
	LD	(NULL_LINE),A
	LD	(WORD_WRAP),A
	LD	(LI_PRE),A	;no preinput.
;
	LD	HL,M_TYPEIN
	CALL	MESS
EM_1	CALL	ENTER_PMPT
;
EM_2
	CALL	LINEIN		;Wraparound input routine
	JR	C,EM_6		;no CR, null terminated
;
;Give warning if buffer nearly full.
	LD	DE,(MEM_PTR)	;current high address
	LD	HL,(TEXT_HIMEM)
	OR	A
	SBC	HL,DE		;hl = whats left unused
	LD	DE,256
	OR	A
	SBC	HL,DE
	CALL	C,WARN_1
;
	CALL	INTO_BUFF
	JP	NZ,EM_7		;If buffer full.
;
;
	LD	A,(LI_BUF)	;first char
	OR	A
	JR	Z,EM_4
	CP	'.'		;Dot commands.
	JR	NZ,EM_2Z
;
EM_2Z
	XOR	A
	LD	(NULL_LINE),A
;
EM_3
	LD	A,(LINES)
	INC	A
	LD	(LINES),A
	CP	MAX_LINES
	JR	Z,EM_7
	CP	MAX_LINES-3
	JR	NZ,EM_1
	LD	HL,M_ENDWRN
	CALL	MESS
	JR	EM_1
;
EM_4	LD	A,(NULL_LINE)
	INC	A
	LD	(NULL_LINE),A
	CP	2
	JR	NZ,EM_3
	LD	HL,(MEM_PTR)
	DEC	HL	;take off last CR
	DEC	HL	;take off second last CR
	LD	(MEM_PTR),HL
	LD	(HL),0
	LD	HL,LINES
	DEC	(HL)
	LD	A,(HL)
	OR	A
	JR	Z,NO_LINES
EM_5	JP	MESG_QUEST
;
NO_LINES			;abort exit.
	XOR	A
	CP	1
	RET
;
EM_6
;ask if abort desired.
	LD	HL,M_IFABRT
	CALL	YES_NO
	CP	'Y'
	JR	Z,NO_LINES
	CP	'Q'
	JR	Z,NO_LINES
	LD	HL,M_DISREG
	CALL	MESS
	JP	EM_1
;
EM_7
	LD	HL,M_FRCEND
	CALL	MESS
	JP	MESG_QUEST
;
WARN_1
	LD	A,(F_WARN)
	BIT	1,A
	RET	NZ
	SET	1,A
	LD	(F_WARN),A
	LD	HL,M_ENDWRN
	CALL	MESS
	RET
;
ENTER_PMPT
;Good place to put "Line 8", "Line 16" messages....
	LD	A,':'
	CALL	PUT
	LD	A,' '
	CALL	PUT
	LD	A,0EH		;Cursor on
	LD	DE,$DO
	CALL	$PUT
	RET
;
MESG_QUEST
	XOR	A
	LD	(NULL_LINE),A
;
	LD	HL,MENU_QUEST
	CALL	MENU
MQ_1	LD	HL,PMPT_QUEST
	CALL	GET_STRING
MQ_2	CALL	GET_CHAR
	CP	CR
	JR	Z,MQ_1
	PUSH	AF
	CALL	GET_CHAR	;get CR
	POP	AF
	AND	5FH
	CP	'A'		;Abort
	JP	Z,NO_LINES
	CP	'S'		;Save
	RET	Z
	CP	'C'		;Continue
	JR	Z,CONTIN
	CP	'L'		;List
	JR	Z,M_LIST
	CP	'E'		;Edit line
	JR	Z,MESG_EDIT
	JR	MESG_QUEST
;
CONTIN
	LD	A,(LINES)
	CP	MAX_LINES
	JP	C,EM_1
	LD	HL,M_MAXLIN
	CALL	MESS
	JR	MESG_QUEST
;
M_LIST
	LD	HL,(MEMT_PTR)
	LD	A,1
	LD	(M_LINE),A
MLS_1	LD	A,(HL)
	CP	0
	JR	Z,MESG_QUEST
	PUSH	HL
	LD	A,(M_LINE)
	LD	L,A
	LD	H,0
	CALL	PRINT_NUMB
	LD	A,':'
	CALL	PUT
	LD	A,' '
	CALL	PUT
	POP	HL
MLS_2	PUSH	HL
	LD	A,(HL)
	CP	CR
	JR	Z,MLS_3
	CALL	PUT
	CALL	GET_$2
	CP	1
	JR	Z,MLS_3
	POP	HL
	INC	HL
	JR	MLS_2
MLS_3	PUSH	AF
	LD	A,(M_LINE)
	INC	A
	LD	(M_LINE),A
	CALL	PUTCR
	POP	AF
	POP	HL
	INC	HL
	CP	1
	JR	NZ,MLS_1
;list finished.
	JP	MESG_QUEST
;
MESG_EDIT
;ask which line to edit.
	CALL	IF_CHAR
	JR	Z,MED_2
MED_1	LD	HL,M_EDWHLI
	CALL	GET_STRING
MED_2	CALL	GET_CHAR
	CP	CR
	JP	Z,MESG_QUEST
	CALL	IF_NUM
	JR	NZ,MED_1
	CALL	GET_NUM
	EX	DE,HL
	LD	A,D
	OR	A
	JR	NZ,MED_1
	LD	A,(LINES)
	CP	E
	JR	C,MED_1
	LD	HL,(MEMT_PTR)
	LD	B,1
MED_3	LD	A,(HL)
	OR	A
	JP	Z,MESG_QUEST
	LD	A,B
	CP	E
	JR	Z,DO_EDIT
;
MED_4	LD	A,(HL)		;bypass line
	CP	CR
	INC	HL
	JR	NZ,MED_4
	INC	B
	JR	MED_3
;
DO_EDIT
	LD	(EDIT_PTR),HL
	LD	DE,OUTBUF
MED_5	LD	A,(HL)
	LD	(DE),A
	CP	CR
	JR	Z,DO_EDIT_2
	INC	HL
	INC	DE
	JR	MED_5
;
DO_EDIT_2
	LD	HL,M_TRSEDIT
	CALL	MESS
;
	LD	HL,TRUE_ESC	;setup ESC key for abort
	LD	(ABORT),HL
;
	CALL	X_START		;NZ on ret if quit.
;
	LD	HL,0		;mask out escape
	LD	(ABORT),HL
;
	JP	NZ,MESG_QUEST
;
	LD	HL,OUTBUF	;save message
	LD	C,0		;count chars incl 0.
MED_6	LD	A,(HL)
	INC	C
	INC	HL
	OR	A
	JR	NZ,MED_6
;set last char as 0dh
	DEC	HL
	LD	(HL),CR
;
;c=number of chars including 00h.
	LD	HL,(EDIT_PTR)
MED_7	LD	A,(HL)
	CP	CR
	INC	HL
	JR	NZ,MED_7
	LD	DE,(EDIT_PTR)	;move msg down
MED_8	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	NZ,MED_8
	DEC	DE		;de=0h byte at end of msg
	PUSH	DE
	EX	DE,HL		;hl=last byte end of msg.
	LD	DE,(EDIT_PTR)
	OR	A
	SBC	HL,DE
	INC	HL		;hl=length of msg.
	POP	DE		;de=addr end of msg
	PUSH	HL
	EX	DE,HL		;hl=addr end, de=length
	PUSH	HL		;push addr end
	LD	B,0
	ADD	HL,BC		;hl=end of msg after move up
	LD	(MEM_PTR),HL	;new EOM.
	POP	DE		;de=src (addr end)
	POP	BC		;bc=len (num bytes to move)
	EX	DE,HL
	LDDR			;open space.
;
	LD	HL,OUTBUF	;move out OUTBUF line
	LD	DE,(EDIT_PTR)
MED_9	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	CP	CR
	JR	NZ,MED_9
	JP	MESG_QUEST
;
X_START
	LD	HL,OUTBUF
	LD	C,255
EDIT_01	INC	C
	LD	A,(HL)
	CP	CR
	INC	HL
	JR	NZ,EDIT_01
	DEC	HL
	LD	(HL),0		;null terminate
EDIT_02	LD	B,0
	LD	HL,OUTBUF
	LD	A,'>'
	CALL	EDIT_PUT
	LD	A,0EH
	CALL	EDIT_PUT
EDIT_03	LD	D,0
EDIT_04
	CALL	KEY_GET
	CP	'0'
	JR	C,EDIT_05
	CP	'9'+1
	JR	NC,EDIT_05
	SUB	'0'
	LD	E,A		;to numb.
	LD	A,D
	RLCA
	RLCA
	ADD	A,D
	RLCA
	ADD	A,E
	LD	D,A
	JR	EDIT_04
EDIT_05	PUSH	AF
	LD	A,D
	OR	A
	JR	NZ,EDIT_06
	INC	D		;d=1 if 0.
EDIT_06	POP	AF
	CP	1		;break
	JR	Z,EDIT_08
	CP	8		;bsp
	JR	Z,EDIT_09
	CP	CR		;cr. finished.
	JP	Z,EDIT_18
	CP	' '		;space
	JR	Z,EDIT_10
	CP	9		;tab like space.
	JR	Z,EDIT_10
	CP	'a'		;l/c.
	JR	C,EDIT_07
	AND	5FH		;to U/C.
EDIT_07	CP	'A'
	JR	Z,EDIT_11
	CP	'C'
	JR	Z,EDIT_12
	CP	'D'
	JP	Z,EDIT_14
	CP	'E'
	JP	Z,EDIT_19
	CP	'H'
	JP	Z,EDIT_20
	CP	'I'
	JP	Z,EDIT_23
	CP	'K'
	JP	Z,EDIT_33
	CP	'L'
	JP	Z,EDIT_30
	CP	'Q'
	JP	Z,EDIT_29
	CP	'S'
	JP	Z,EDIT_31
	CP	'X'
	JP	Z,EDIT_21
	JR	EDIT_04
EDIT_08	CALL	EDIT_MESS
	LD	A,CR
	CALL	EDIT_PUT
	LD	HL,M_EQUIT
	CALL	EDIT_MESS
	JP	E_ABORT
M_EQUIT	DEFM	'Quit.',CR
EDIT_09	LD	A,B
	OR	A
	JP	Z,EDIT_03
	DEC	B
	DEC	HL
	LD	A,8
	CALL	EDIT_PUT
	DEC	D
	JR	NZ,EDIT_09
	JP	EDIT_03
;
EDIT_10	LD	A,(HL)
	OR	A
	JP	Z,EDIT_03
	INC	B
	CALL	EDIT_PUT
	INC	HL
	DEC	D
	JR	NZ,EDIT_10
	JP	EDIT_03
EDIT_11	CALL	RELOAD
	LD	A,CR
	CALL	EDIT_PUT
	JP	EDIT_02
;**** Can't do. Need original line.
EDIT_12	LD	A,(HL)
	OR	A
	JP	Z,EDIT_03
EDIT_13	CALL	KEY_GET
	CP	' '
	JR	C,EDIT_13
	CP	7FH
	JR	NC,EDIT_13
	LD	(HL),A
	CALL	EDIT_PUT
	INC	HL
	INC	B
	DEC	D
	JR	NZ,EDIT_12
	JP	EDIT_03
EDIT_14	LD	A,(HL)
	OR	A
	JP	Z,EDIT_03
	LD	A,5BH	;open bracket.
	CALL	EDIT_PUT
EDIT_15	LD	A,(HL)
	OR	A
	JR	Z,EDIT_17
	CALL	EDIT_PUT
	PUSH	HL
	POP	IX
EDIT_16	LD	A,(IX+1)
	LD	(IX+0),A
	INC	IX
	OR	A
	JR	NZ,EDIT_16
	DEC	C
	DEC	D
	JR	NZ,EDIT_15
EDIT_17	LD	A,']'
	CALL	EDIT_PUT
	JP	EDIT_03
EDIT_18	CALL	EDIT_MESS
EDIT_19	LD	A,CR
	CALL	EDIT_PUT
;real exit point.
;**
E_EXIT
	CP	A
	RET
E_ABORT
	XOR	A
	CP	1
	RET
;**
EDIT_20	LD	(HL),0
	LD	C,B
EDIT_21	CALL	EDIT_MESS
	LD	HL,OUTBUF
EDIT_22	LD	A,(HL)
	INC	HL
	OR	A
	JR	NZ,EDIT_22
	DEC	HL
	LD	B,C
EDIT_23	CALL	KEY_GET
	CP	8
	JR	Z,EDIT_27
	CP	CR
	JR	Z,EDIT_18
	CP	1BH
	JP	Z,EDIT_03
	CP	' '
	JR	C,EDIT_23
	CP	7FH
	JR	NC,EDIT_23
	PUSH	AF
	LD	A,C
	CP	78		;was 62
	JR	C,EDIT_24
	POP	AF
	JR	EDIT_23
EDIT_24	PUSH	HL
	INC	C
	INC	B
	LD	D,0
EDIT_25	LD	A,(HL)
	INC	HL
	INC	D
	OR	A
	JR	NZ,EDIT_25
	DEC	HL
	PUSH	HL
	POP	IX
EDIT_26	LD	A,(IX)
	LD	(IX+1),A
	DEC	IX
	DEC	D
	JR	NZ,EDIT_26
	POP	HL
	POP	AF
	LD	(HL),A
	INC	HL
	CALL	EDIT_PUT
	JR	EDIT_23
EDIT_27	LD	A,B
	OR	A
	JR	Z,EDIT_23
	LD	A,8
	CALL	EDIT_PUT
	DEC	C
	DEC	B
	DEC	HL
	PUSH	HL
	POP	IX
EDIT_28	LD	A,(IX+1)
	LD	(IX+0),A
	OR	A
	INC	IX
	JR	NZ,EDIT_28
	JR	EDIT_23
EDIT_29	CALL	EDIT_MESS
	LD	A,CR
	CALL	EDIT_PUT
	JP	E_ABORT
EDIT_30
	CALL	EDIT_MESS
	LD	A,CR
	CALL	EDIT_PUT
	JP	EDIT_02
EDIT_31	CALL	KEY_GET
	CP	' '
	JR	C,EDIT_31
	CP	7FH
	JR	NC,EDIT_31
	LD	E,A
	LD	A,(HL)
	OR	A
	JP	Z,EDIT_03
	CP	E
	JR	NZ,EDIT_32
	CALL	EDIT_PUT
	INC	HL
	INC	B
EDIT_32	LD	A,(HL)
	OR	A
	JP	Z,EDIT_03
	CALL	EDIT_PUT
	INC	HL
	INC	B
	CP	E
	JR	NZ,EDIT_32
	DEC	D
	JR	NZ,EDIT_32
	LD	A,8
	CALL	EDIT_PUT
	DEC	HL
	DEC	B
	JP	EDIT_03
EDIT_33	CALL	KEY_GET
	CP	' '
	JR	C,EDIT_33
	CP	7FH
	JR	NC,EDIT_33
	LD	E,A
	LD	A,5BH
	CALL	EDIT_PUT
EDIT_34	LD	A,(HL)
	OR	A
	JR	Z,EDIT_36
	CALL	EDIT_PUT
	PUSH	HL
	POP	IX
EDIT_35	LD	A,(IX+1)
	LD	(IX+0),A
	INC	IX
	OR	A
	JR	NZ,EDIT_35
	DEC	C
	LD	A,(HL)
	CP	E
	JR	NZ,EDIT_34
	DEC	D
	JR	NZ,EDIT_34
EDIT_36	LD	A,']'
	CALL	EDIT_PUT
	JP	EDIT_03
KEY_GET
	PUSH	BC
	PUSH	DE
	LD	DE,$2
KEYGET_1
	CALL	$GET
	OR	A
	JR	Z,KEYGET_1
	POP	DE
	POP	BC
	RET
;
EDIT_PUT
	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	DE,$2
	CALL	$PUT
	POP	DE
	POP	BC
	POP	AF
	RET
;
EDIT_MESS
	LD	A,(HL)
	OR	A
	RET	Z
	CP	ETX
	RET	Z
	CALL	EDIT_PUT
	LD	A,(HL)
	CP	CR
	RET	Z
	INC	HL
	JR	EDIT_MESS
;
RELOAD
	LD	HL,(EDIT_PTR)
	LD	DE,OUTBUF
MED_A	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	CP	CR
	JR	NZ,MED_A
	DEC	DE
	LD	A,0
	LD	(DE),A
	RET
;
TRUE_ESC	;allow the ESC key to give an ESC char
	LD	A,1BH
	RET
;
;Save a message to the tree.
SAVE_MSG
	;-;	Save file header ...
	CALL	SAVE_TEXT_1	;save header & text
	RET
;
;save message text.
SAVE_TEXT_1
	LD	A,0FFH
	CALL	BPUTC
	JP	NZ,SAVE_ERROR
	XOR	A
	CALL	BPUTC
	JP	NZ,SAVE_ERROR
	XOR	A		;Unused
	CALL	BPUTC
	JP	NZ,SAVE_ERROR
	LD	HL,TEXT_BUF
	CALL	_BPUTS
	JP	NZ,SAVE_ERROR
	RET
;
GET_NAME
GEN_01
	LD	HL,M_WHOTO
	CALL	GET_STRING
	CALL	COPY_NAME	;into name_buff
;
	LD	HL,NAME_BUFF
	LD	A,(HL)
	CP	CR
	JP	Z,GEN_07	;Quitting
GEN_04
;
;Check for network address.
GEN_05	LD	A,(HL)
	CP	CR
	JR	Z,GEN_06
	OR	A
	JR	Z,GEN_06
	INC	HL
	CP	'@'
	JR	NZ,GEN_05
;has a network address appended. This is (NET_BIT).
	LD	A,(PRIV_1)
	BIT	GRA_ENET,A	;Network message entry
	JP	Z,NO_PERMS
;
	LD	A,1
	LD	(NETMSG),A
	LD	HL,HDR_FLAG
	SET	FM_NETMSG,(HL)
	LD	HL,0FFFEH
	LD	(HDR_RCVR),HL	;to network id.
;
	LD	DE,NAME_BUFF
	CALL	SET_DEST_NAME
	CALL	ASK_PRIV	;-; Should remove!
	RET
;
GEN_06
	LD	A,(PRIV_1)
	BIT	GRA_ELOC,A
	JP	Z,NO_PERMS
;
;check if name is registered.
	LD	HL,NAME_BUFF
	CALL	CHK_USERS
	LD	HL,(US_NUM)
	JP	Z,TO_KNOWN	;Name is in userfile
;
	LD	HL,M_DESTSTR
	CALL	MESS
	LD	HL,NAME_BUFF
	LD	DE,$2
	CALL	MESS_CR
	LD	HL,M_DESTSTR2
	CALL	MESS
	JP	GEN_01		;Name not in userfile
GEN_07	XOR	A
	CP	1
	RET
;
TO_KNOWN
	LD	(HDR_RCVR),HL
;
;Don't ask for private if message is to All (uid=ffff)
	LD	A,H
	AND	L
	CP	0FFH
	CALL	NZ,ASK_PRIV
	RET	NZ		;if quit.
;
;To a known user so use name stored in userfile.
	LD	DE,UF_NAME
	CALL	SET_DEST_NAME
	RET
;
SET_DEST_NAME
	LD	HL,(MEM_PTR)
SDN_01	LD	A,(DE)
	CP	CR
	JR	Z,SDN_02
	OR	A		;if from UF_NAME
	JR	Z,SDN_02
	LD	(HL),A
	INC	HL
	INC	DE
	JR	SDN_01
;
SDN_02	LD	(HL),CR
	INC	HL
	LD	(MEM_PTR),HL
	LD	(HL),0
	CP	A
	RET
;
ASK_PRIV
	LD	HL,HDR_FLAG
	RES	FM_PRIVATE,(HL)
	LD	HL,M_PRIVATE	;Ask if private
	CALL	YES_NO
	CP	'N'
	RET	Z
	CP	'Q'
	JP	Z,GEN_07
	LD	HL,HDR_FLAG
	SET	FM_PRIVATE,(HL)
	CP	A
	RET
;
ADD_DATE
	LD	HL,HDR_TIME
	LD	A,(HL)
	LD	(HMS_S),A
	INC	HL
	LD	A,(HL)
	LD	(HMS_M),A
	INC	HL
	LD	A,(HL)
	LD	(HMS_H),A
;
	LD	HL,HDR_DATE
	LD	A,(HL)
	LD	(DMY_D),A
	INC	HL
	LD	A,(HL)
	LD	(DMY_M),A
	INC	HL
	LD	A,(HL)
	LD	(DMY_Y),A
	CALL	DMY_ASC		;use stored date.
	LD	DE,(MEM_PTR)
	CALL	STRCPY
	EX	DE,HL
	LD	(HL),' '
	INC	HL
	LD	(HL),' '
	INC	HL
	LD	(MEM_PTR),HL
;
	CALL	HMS_ASC
	LD	DE,(MEM_PTR)
	CALL	STRCPY
	LD	A,CR
	LD	(DE),A
	INC	DE
	LD	(MEM_PTR),DE
	LD	(MEMT_PTR),DE
;
	XOR	A
	LD	(DE),A		;zero it.
	RET
;
GET_SUBJ
GS_1	LD	HL,M_WHTSUBJ
	CALL	GET_STRING
GS_2	CALL	IF_CHAR
	CP	CR
	JR	NZ,GS_3
	XOR	A
	CP	1
	RET
;
GS_3	LD	HL,(MEM_PTR)
GS_4	PUSH	HL
	CALL	GET_CHAR
	POP	HL
	LD	(HL),A
	INC	HL
	CP	CR
	JR	NZ,GS_4
	LD	(MEM_PTR),HL
	LD	(MEMT_PTR),HL
	LD	(HL),0
	CP	A
	RET
;
INTO_BUFF
;HL=LI_BUF
;DE=(mem_ptr) *de = 0;
;maximum address = (text_himem)
	LD	DE,(MEM_PTR)
	LD	HL,LI_BUF
IB_01	PUSH	HL
	LD	HL,(TEXT_HIMEM)
	DEC	HL
	OR	A
	SBC	HL,DE
	POP	HL
	JR	Z,IB_03
	LD	A,(HL)
	LD	(DE),A
	OR	A
	JR	Z,IB_02
	INC	HL
	INC	DE
	JR	IB_01
;
IB_02
	EX	DE,HL
	LD	(HL),CR
	INC	HL
	LD	(HL),0
	LD	(MEM_PTR),HL
	CP	A
	RET
IB_03
	LD	HL,(MEM_PTR)
	LD	(HL),0
	XOR	A
	CP	1
	RET
;
COPY_NAME
	LD	IX,NAME_BUFF
CN_01	CALL	GET_CHAR	;Get name until CR
	LD	(IX),A
	INC	IX
	CP	CR
	JR	NZ,CN_01
	RET
;
SAVE_ERROR
	LD	HL,M_SAVEERR
	CALL	MESS
	JP	MAIN
;
*GET	LINEIN
*GET	TIMES
*GET	ROUTINES
;
ZZZZZZZY EQU $		;End of required data (?)
	DEFS	4096	;Text buffer.
ZZZZZZZZ EQU $		;End of 4k buffer.
;
THIS_PROG_END	EQU	$
;
	END	START
