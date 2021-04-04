;pktass1: Code for Pktass
;
	CALL	OPEN_FILES
;
	CALL	READ_CONFIG	;Read netnodes
;
LOOP	CALL	GET_MSG
	JP	C,EOF
	CALL	Z,OUTPUT_MSG
	JR	LOOP
;
EOF	CALL	CLOSE_FILES
	XOR	A
	JP	TERMINATE
;
OPEN_FILES
	LD	DE,NETN_FCB	;Open the NETN.ZMS file
	LD	HL,NETN_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(NETN_FCB+1)
	AND	0F8H
	OR	5
	LD	(NETN_FCB+1),A
;
	LD	DE,NETL_FCB	;Open the NETL.ZMS file
	LD	HL,NETL_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(NETL_FCB+1)
	AND	0F8H
	OR	5
	LD	(NETL_FCB+1),A
;
	LD	DE,TOP_FCB	;Open msgtop.zms
	LD	HL,MSGTOP_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(TOP_FCB+1)
	AND	0F8H
	LD	(TOP_FCB+1),A
;
	LD	DE,HDR_FCB	;Open msghdr.zms
	LD	HL,MSGHDR_BUF
	LD	B,HDR_LEN
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(HDR_FCB+1)
	AND	0F8H
	OR	40H		;prevent write shrink
	LD	(HDR_FCB+1),A
;
	LD	DE,TXT_FCB	;Open msgtxt.zms
	LD	HL,MSGTXT_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(TXT_FCB+1)
	AND	0F8H
	LD	(TXT_FCB+1),A
;
	CALL	READ_STATS
	CALL	_READFREE	;Read free block bitmap
	RET
;
;Read first 16 bytes from topic file for statistics
;
READ_STATS
	LD	HL,STATS_REC
	LD	B,16
	LD	DE,TOP_FCB
RS_01	CALL	$GET
	JP	NZ,ERROR
	LD	(HL),A
	INC	HL
	DJNZ	RS_01
	RET
;
;Read from files NETN.ZMS:
;    shortname   fidonode     linkname    longname
;    sw_tools    [711/403]    naba        Software_tools
;Read from file  NETL.ZMS:
;    primary_link
;    naba
;    linkname    fidonode     packetfile
;    realtors    [712/301]    REALTORS.NET:2
;
READ_CONFIG
	CALL	READ_NODES
	CALL	READ_LINKS
;
	LD	HL,(EM)
	LD	(MSGBUF),HL
	RET
;
;Read in the vital statistics of a message....
GET_MSG
;
	XOR	A
	LD	(F_ECHO),A
;
	LD	HL,(MSGNO)
	INC	HL
	LD	(MSGNO),HL
;
	LD	DE,(NUM_MSG)
	OR	A
	SBC	HL,DE
	JR	NZ,GM_00A
	SCF
	RET			;with C set = eof.
;
GM_00A
	LD	HL,HDR_REC
	LD	DE,HDR_FCB
	CALL	DOS_READ_SECT
	JR	Z,GM_02
	JP	NZ,ERROR
;
;Test if the message is a candidate to send out
GM_02	LD	A,(HDR_FLAG)
	BIT	FM_KILLED,A
	RET	NZ
;
	IF	ALLNET
	BIT	FM_NETMSG,A
	RET			;Copy non-net messages!
	ELSE
	BIT	FM_NETMSG,A	;1=A network message
	JP	Z,RET_NZ	;Not a net message
	BIT	FM_NETSENT,A	;1=Already sent on net.
	RET	NZ		;Already sent
	CP	A
	RET
	ENDIF
;
;Read a message from the tree, copy to the appropriate
;packet file, then kill the message.
OUTPUT_MSG:
	CALL	FIND_CONF
	LD	A,(F_ECHO)
	OR	A
	RET	Z		;Not echomail. Do not send.
	CALL	READ_HEAD	;Read message header
	CALL	OPEN_PACKET	;Open output packet
	CALL	COPY_MSG	;Copy the entire message
	CALL	KILL_THIS	;Set status to "sent"
	RET
;
;Read orig name, dest name & node & subject from MSGTXT.
READ_HEAD:
	LD	HL,(HDR_RBA+1)
	CALL	_SEEKTO
	CALL	_READBLK
	JP	NZ,ERROR
	LD	HL,2
	LD	(_BLKPOS),HL
;
	CALL	BGETC		;Read first byte
	CP	0FFH
	LD	HL,M_NOFF
	JP	NZ,CORRUPT	;no FF at start.
;
	CALL	BGETC		;bypass flags
	CALL	BGETC		;bypass unused byte
;
	LD	HL,ORIG_NAME
	CALL	READ_CR
	LD	HL,DEST_NAME
	CALL	READ_CR
	LD	HL,DATE_LEFT
	CALL	READ_CR
;
;Fix the dashes "-" at offsets +2 and +6 to spaces.
	LD	A,' '
	LD	(DATE_LEFT+2),A
	LD	(DATE_LEFT+6),A
;
	LD	HL,SUBJECT
	CALL	READ_CR
;
	CALL	PRINT_INFO	;Print from & to
;
	RET
;
;------------------------------------------------------
;
;Figure out if this message is in an echomail/news conference
;If so, which is it?
FIND_CONF
;
	XOR	A
	LD	(F_ECHO),A
;
	LD	HL,ECHOMAIL	;Check areas table.
	LD	(EMPTR),HL
	LD	A,(HDR_TOPIC)
	LD	C,A
;
FC_01
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,D
	OR	E
	RET	Z		;End of table. Not found.
	LD	A,B
	CP	C
	JR	Z,FC_02		;Topic number is known
	LD	DE,5
	ADD	HL,DE
	JR	FC_01
;
FC_02
;Substitute in co-ordinators node and set F_ECHO flag.
	INC	HL
	LD	(ECHO_AREA),DE
;
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(ECHO_COORD),DE		;Pointer to net, node ints
;
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(ECHO_ORIGIN),DE
;
	LD	HL,(ECHO_COORD)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(TO_NET_NUM),DE
;
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(TO_NODE_NUM),DE
;
	CALL	MAKE_FILENAME
;
	LD	A,1
	LD	(F_ECHO),A
	RET
;
;Make a filename in ROUTE_FILENAME to the node to which
;this echomail message must be sent.
MAKE_FILENAME
	LD	HL,ROUTE_FILENAME
	LD	DE,(TO_NET_NUM)
	CALL	FOUR_HEX_FIX
	LD	HL,ROUTE_FILENAME+4
	LD	DE,(TO_NODE_NUM)
	CALL	FOUR_HEX_FIX
	RET
;
;Open the filename as determined by ROUTE_FILENAME
;if already open, leave open & return.
;if a new file, write out the header first.
; otherwise, position to EOF.
OPEN_PACKET
	LD	HL,ROUTE_FILENAME
	LD	DE,CURRENT_FILE
	CALL	STRCMP_CI
	JR	Z,OP_01		;already open.
;
	LD	HL,ROUTE_FILENAME
	LD	DE,CURRENT_FILE
	CALL	STRCPY		;set the name.
;
	LD	DE,PKT_FCB
	LD	A,(DE)
	AND	80H
	CALL	NZ,DOS_CLOSE	;close if open.
	JP	NZ,ERROR
;
	LD	HL,M_OPENING
	CALL	MESS
	LD	HL,CURRENT_FILE
	CALL	MESS
	LD	HL,M_CR
	CALL	MESS
;
	LD	HL,CURRENT_FILE
	LD	DE,PKT_FCB
	CALL	EXTRACT		;extract.
	JP	NZ,ERROR
;
	LD	DE,PKT_FCB
	LD	HL,PKT_BUF
	LD	B,0
	CALL	DOS_OPEN_NEW	;open new or existing
	JP	NZ,ERROR
	CALL	C,MAKE_HEADER	;If new, make header
;
OP_01
	LD	DE,PKT_FCB
	CALL	DOS_POS_EOF
	JP	NZ,ERROR
;
;Backspace two characters so next write to file will
;overwrite "packet eof" bytes.
	LD	A,(PKT_FCB+5)
	LD	C,A
	LD	HL,(PKT_FCB+10)
	CP	2
	JR	NC,PO_02
	DEC	HL
PO_02	DEC	C
	DEC	C
	LD	DE,PKT_FCB
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	RET
;
;Make a 58 byte header for the packet file, since its
;just been created. Include such goodies as the current
;date and time, my ID, your ID, etc...
;Also add two zero bytes for end-of-packet.
;
MAKE_HEADER:
	LD	HL,ZETA_NODE		;our node
	LD	DE,PKT_FCB
	CALL	PUTW
;
	LD	HL,(TO_NODE_NUM)	;Echomail (no routing)
	CALL	PUTW
;
	LD	A,(4044H)	;write year
	LD	C,A
	LD	B,0
	LD	HL,1900
	ADD	HL,BC
	CALL	PUTW
;
	LD	A,(4046H)	;then month
	DEC	A		;zero offset!
	LD	L,A
	LD	H,0
	CALL	PUTW
;
	LD	A,(4045H)	;then day
	LD	L,A
	CALL	PUTW
;
	LD	A,(4043H)	;then hour
	LD	L,A
	CALL	PUTW
;
	LD	A,(4042H)	;then minute
	LD	L,A
	CALL	PUTW
;
	LD	A,(4041H)	;then second
	LD	L,A
	CALL	PUTW
;
	LD	HL,0		;rate = 0
	CALL	PUTW
;
	LD	HL,2		;ver = 2
	CALL	PUTW
;
	LD	HL,ZETA_NET	;originating net
	CALL	PUTW
;
	LD	HL,(TO_NET_NUM)
	CALL	PUTW		;destination net
;
;Followed by 34 zeroes.
	LD	B,17
	LD	HL,0
MH_01	CALL	PUTW
	JP	NZ,ERROR
	DJNZ	MH_01
;
	LD	HL,0		;Final word (backspaced soon)
	CALL	PUTW
	JP	NZ,ERROR
	RET
;
;Copy a message header first and then the actual text
;from MSGTXT into the packet file.
;
COPY_MSG:
;
;First make the message's header.
	LD	DE,PKT_FCB
	LD	HL,2		;type = 2
	CALL	PUTW
;
	LD	HL,ZETA_NODE	;orig_node
	CALL	PUTW
;
	LD	HL,(TO_NODE_NUM)
	CALL	PUTW
;
	LD	HL,ZETA_NET	;orig_net
	CALL	PUTW
;
	LD	HL,(TO_NET_NUM)
	CALL	PUTW
;
;Now for the flags
	LD	HL,0
	CALL	PUTW		;Zeroed flags
;
;And set the cost to something...
	LD	HL,10		;10 cents
	CALL	PUTW
	JP	NZ,ERROR
;
;Its now time to copy the strings read into memory a
;long LONG time ago (maybe 2 sec?) into the packet file.
;
	LD	HL,ORIG_NAME
	CALL	FIX_NAME_CASE
	LD	HL,DEST_NAME
	CALL	FIX_NAME_CASE
;
;Remove any trailing (nnn/nnn) which may be on the ORIG_NAME
	LD	HL,ORIG_NAME
	CALL	REMOVE_NODENR
;
;Remove any trailing (nnn/nnn) which may be on the DEST_NAME
	LD	HL,DEST_NAME
	CALL	REMOVE_NODENR
;
CM_01A
	LD	DE,PKT_FCB
	LD	HL,DATE_LEFT	;19 chars long
	CALL	FPUTS		;dd mmm yy  hh:mm:ss
	JP	NZ,ERROR
	CALL	PUTNULL		;MANDATORY !!!
;
	LD	HL,DEST_NAME
	CALL	FPUTS		;Output entire string
	JP	NZ,ERROR
	CALL	PUTNULL
;
	LD	HL,ORIG_NAME
	CALL	FPUTS
	JP	NZ,ERROR
	CALL	PUTNULL
;
	LD	HL,SUBJECT
	CALL	FPUTS
	JP	NZ,ERROR
	CALL	PUTNULL
;
CM_01B
	LD	HL,S_AREA
	CALL	MESS
	LD	HL,(ECHO_AREA)
	CALL	MESS
;
	LD	DE,PKT_FCB
	LD	HL,S_AREA
	CALL	FPUTS
	JP	NZ,ERROR
	LD	HL,(ECHO_AREA)
	CALL	FPUTS
	JP	NZ,ERROR
;
;Now the message can be copied a character at a time.
;Translate all CR to CRLF
;
CM_02
	CALL	BGETC
	JP	NZ,ERROR
;
	CP	CR
	JR	NZ,CM_03
;
	LD	DE,PKT_FCB
	LD	A,CR
	CALL	$PUT
	JP	NZ,ERROR
	LD	A,LF
	CALL	$PUT
	JP	NZ,ERROR
	JR	CM_02
;
CM_03	OR	A
	JR	Z,CM_04
	LD	DE,PKT_FCB
	CALL	$PUT
	JR	CM_02
;
CM_04
	LD	DE,PKT_FCB
	LD	HL,(ECHO_ORIGIN)
	CALL	FPUTS
	JP	NZ,ERROR
;
CM_05	LD	DE,PKT_FCB
	XOR	A
	CALL	$PUT
;Write the two zero bytes signifying end of packet
; into the packet file.
	XOR	A
	CALL	$PUT
	JP	NZ,ERROR
	XOR	A
	CALL	$PUT
	JP	NZ,ERROR
	RET			;finished copy.
;
;  Don't actually kill the message from the system but
; set the FM_NETSENT bit instead so the message will not
; get sent again.
KILL_THIS
;
	LD	HL,HDR_FLAG
	SET	FM_NETSENT,(HL)
	SET	FM_NETMSG,(HL)
;
	LD	DE,HDR_FCB	;  Rewrite the header file.
	CALL	DOS_BACK_RECD
	JP	NZ,ERROR
	LD	HL,HDR_REC
	CALL	DOS_WRIT_SECT
	JP	NZ,ERROR
	RET
;
READ_NODES:
	LD	HL,NODE
	LD	(NLPTR),HL
;
	LD	HL,BIG_BUFF	;set addr to load names.
	LD	(EM),HL
;
RN_01	LD	HL,(EM)		;store addr of start
	LD	(NODE_SHORT),HL
RN_02				;read in shortname
	LD	DE,NETN_FCB
	CALL	$GET
	JR	Z,RN_04
	CP	1CH
	JR	Z,RN_03
	CP	1DH
	JP	NZ,ERROR
RN_03	LD	HL,0
	LD	(NODE_SHORT),HL
	CALL	MOVE_NODE_ARRAY
	RET
RN_04	CP	' '
	JR	Z,RN_05
	LD	(HL),A
	INC	HL
	JR	RN_02
;
RN_05	LD	(HL),0
	INC	HL
	LD	(EM),HL
	LD	(NODE_FIDONODE),HL
;
	LD	HL,(EM)
RN_06	CALL	GETZ
	CP	' '
	JR	Z,RN_07
	LD	(HL),A
	INC	HL
	JR	RN_06
RN_07	LD	(HL),0
	INC	HL
	LD	(EM),HL
	LD	(NODE_LINK),HL
RN_08	CALL	GETZ
	CP	' '
	JR	Z,RN_09
	LD	(HL),A
	INC	HL
	JR	RN_08
RN_09	LD	(HL),0
	INC	HL
	LD	(EM),HL
RN_10	CALL	GETZ
	CP	CR
	JR	NZ,RN_10
	CALL	MOVE_NODE_ARRAY
	JR	RN_01
;
MOVE_NODE_ARRAY
	LD	HL,(NLPTR)
	LD	DE,(NODE_SHORT)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	DE,(NODE_FIDONODE)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	DE,(NODE_LINK)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(NLPTR),HL
	LD	(HL),0
	INC	HL
	LD	(HL),0
	RET
;
READ_LINKS:
;First read primary link.
	LD	HL,PRIM_LINK
	LD	DE,NETL_FCB
RL_01	CALL	GETZ
	CP	CR
	JR	Z,RL_02
	LD	(HL),A
	INC	HL
	JR	RL_01
RL_02	LD	(HL),0
;
	LD	HL,LINK		;Then read all the other links...
	LD	(LTPTR),HL
;
;
RL_03	LD	HL,(EM)		;store addr of start
	LD	(LINK_NAME),HL
RL_04				;read in shortname
	LD	DE,NETL_FCB
	CALL	$GET
	JR	Z,RL_06
	CP	1CH
	JR	Z,RL_05
	CP	1DH
	JP	NZ,ERROR
RL_05	LD	HL,0
	LD	(LINK_NAME),HL
	CALL	MOVE_LINK_ARRAY
	RET
RL_06	CP	' '
	JR	Z,RL_07
	LD	(HL),A
	INC	HL
	JR	RL_04
;
RL_07	LD	(HL),0
	INC	HL
	LD	(EM),HL
	LD	(LINK_FIDONODE),HL
;
	LD	HL,(EM)
RL_08	CALL	GETZ
	CP	' '
	JR	Z,RL_09
	LD	(HL),A
	INC	HL
	JR	RL_08
RL_09	LD	(HL),0
	INC	HL
	LD	(EM),HL
	LD	(LINK_FILENAME),HL
RL_10	CALL	GETZ
	CP	CR
	JR	Z,RL_11
	LD	(HL),A
	INC	HL
	JR	RL_10
RL_11	LD	(HL),0
	INC	HL
	LD	(EM),HL
RL_12
	CALL	MOVE_LINK_ARRAY
	JR	RL_03
;
MOVE_LINK_ARRAY
	LD	HL,(LTPTR)
	LD	DE,(LINK_NAME)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	DE,(LINK_FIDONODE)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	DE,(LINK_FILENAME)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(LTPTR),HL
	LD	(HL),0
	INC	HL
	LD	(HL),0
	RET
;
;Read the message into a buffer until CR.
READ_CR
RC_01	CALL	BGETC
	CP	CR
	JR	Z,RC_02
	LD	(HL),A
	INC	HL
	JR	RC_01
RC_02	LD	(HL),0
	RET
;
;Print the contents of this message on the screen.
PRINT_INFO
	LD	HL,M_FROM
	CALL	MESS
	LD	HL,ORIG_NAME
	CALL	MESS
	LD	HL,M_TO
	CALL	MESS
	LD	HL,DEST_NAME
	CALL	MESS
	LD	HL,M_CR
	CALL	MESS
	RET
;
FOUR_HEX_FIX
	PUSH	HL
	CALL	FOUR_HEX
	POP	HL
	LD	A,(HL)
	CP	'9'+1
	RET	NC
	ADD	A,'A'-'0'
	LD	(HL),A
	RET
;
FOUR_HEX
	CALL	TWO_HEX
	LD	D,E
	CALL	TWO_HEX
	RET
;
TWO_HEX
	LD	A,D
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	CALL	ONE_HEX
	LD	A,D
	CALL	ONE_HEX
	RET
;
ONE_HEX
	AND	0FH
	CP	10
	JR	C,ONE_HEX_1
	ADD	A,7
ONE_HEX_1
	ADD	A,'0'
	LD	(HL),A
	INC	HL
	RET
;
CLOSE_FILES
	LD	DE,TXT_FCB
	CALL	DOS_CLOSE
;
	LD	DE,HDR_FCB
	CALL	DOS_CLOSE
;
	LD	DE,TOP_FCB
	CALL	DOS_CLOSE
;
	LD	DE,NETN_FCB
	CALL	DOS_CLOSE
;
	LD	DE,NETL_FCB
	CALL	DOS_CLOSE
;
	LD	DE,PKT_FCB
	CALL	DOS_CLOSE
	RET
;
;Set first char of each word to upper case.
FIX_NAME_CASE
	LD	A,(HL)
	OR	A
	RET	Z
	CP	'a'		;First char of word
	JR	C,FNC_1		;to upper case
	CP	'z'+1
	JR	NC,FNC_1
	AND	5FH
	LD	(HL),A
FNC_1	INC	HL
	LD	A,(HL)
	OR	A
	RET	Z
	CP	'A'
	JR	C,FNC_2
	CP	'Z'+1
	JR	NC,FNC_2
	OR	20H
	LD	(HL),A
FNC_2
	CP	' '
	JR	NZ,FNC_1
FNC_3
	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,FNC_3
	JR	FIX_NAME_CASE
;
;Remove any trailing (nnn/nnn) which may be on an address
REMOVE_NODENR
RMN_01
	LD	A,(HL)
	OR	A
	RET	Z		;End of name
	CP	'('		;(nnn/nnn)
	JR	Z,RMN_02
	INC	HL
	JR	RMN_01
;
RMN_02
	DEC	HL
	LD	(HL),0		;Wipe out the rest of it
	RET
;
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	OR	20H
	JP	TERMINATE
;
GETZ	CALL	$GET
	RET	Z
	JP	ERROR
;
PUTW	LD	A,L
	CALL	$PUT
	RET	NZ
	LD	A,H
	CALL	$PUT
	RET
;
PUTNULL	XOR	A
	CALL	$PUT
	RET
;
CORRUPT:
	PUSH	HL
	LD	HL,M_CORRUPT
	CALL	MESS
	POP	HL
	CALL	MESS
	LD	A,64
	JP	TERMINATE
;
MESS	LD	DE,DCB_2O
	CALL	MESS_0
	RET
;
PUTCR	LD	A,CR
	LD	DE,DCB_2O
	CALL	$PUT
	RET
;
ADD_SUM	PUSH	HL
	PUSH	DE
	POP	HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	ADD	HL,HL
	SUB	'0'
	LD	E,A
	LD	D,0
	ADD	HL,DE
	PUSH	HL
	POP	DE
	POP	HL
	RET
;
FPUTS_ID
	LD	A,(HL)
	OR	A
	RET	Z
	CP	'@'
	RET	Z
	CALL	$PUT
	RET	NZ
	INC	HL
	JR	FPUTS_ID
;
RET_NZ	LD	A,1
	OR	A		;and reset carry
	RET
;
;End of pktass1
