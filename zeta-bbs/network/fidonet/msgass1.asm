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
	LD	DE,NETN_FCB
	LD	HL,NETN_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(NETN_FCB+1)
	AND	0F8H
	OR	5
	LD	(NETN_FCB+1),A
;
	LD	DE,NETL_FCB
	LD	HL,NETL_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(NETL_FCB+1)
	AND	0F8H
	OR	5
	LD	(NETL_FCB+1),A
;
	LD	DE,TOP_FCB
	LD	HL,MSGTOP_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(TOP_FCB+1)
	AND	0F8H
	LD	(TOP_FCB+1),A
;
	LD	DE,HDR_FCB
	LD	HL,MSGHDR_BUF
	LD	B,HDR_LEN
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(HDR_FCB+1)
	AND	0F8H
	OR	40H		;prevent write shrink
	LD	(HDR_FCB+1),A
;
	LD	DE,TXT_FCB
	LD	HL,MSGTXT_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(TXT_FCB+1)
	AND	0F8H
	LD	(TXT_FCB+1),A
;
	LD	HL,STATS_REC
	LD	B,16
	LD	DE,TOP_FCB
OF_01	CALL	ROM@GET
	JP	NZ,ERROR
	LD	(HL),A
	INC	HL
	DJNZ	OF_01
;
	CALL	_READFREE
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
	CALL	ROM@GET
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
;Then read all the other links...
	LD	HL,LINK
	LD	(LTPTR),HL
;
;
RL_03	LD	HL,(EM)		;store addr of start
	LD	(LINK_NAME),HL
RL_04				;read in shortname
	LD	DE,NETL_FCB
	CALL	ROM@GET
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
;Read in the vital statistics of a message....
GET_MSG
;
	XOR	A
	LD	(F_ECHO),A
;
	LD	HL,(MSGNO)
	INC	HL
	LD	(MSGNO),HL
	LD	DE,(NUM_MSG)
	OR	A
	SBC	HL,DE
	JR	NZ,GM_00A
	SCF
	RET			;with C set = eof.
GM_00A
;
	LD	HL,HDR_REC
	LD	DE,HDR_FCB
	CALL	DOS_READ_SECT
	JR	Z,GM_02
	CP	1CH
	JR	Z,GM_01
	CP	1DH
	JP	NZ,ERROR
GM_01	SCF
	RET			;signal eof.
GM_02	LD	A,(HDR_FLAG)
	BIT	FM_KILLED,A
	RET	NZ		;don't bother...
	BIT	FM_NETMSG,A
	JP	Z,RET_NZ
	BIT	FM_NETSENT,A	;1=sent on net.
	JP	NZ,RET_NZ	;don't bother resend.
	CP	A
	RET
;
RET_NZ	LD	A,1
	OR	A		;and reset carry
	RET
;
;Read a message from the tree, copy to the appropriate
;packet file, then kill the message.
OUTPUT_MSG:
	CALL	READ_HEAD
	CALL	FIGURE_IT_OUT
	RET	NZ
	CALL	OPEN_PACKET
	CALL	COPY_MSG
	CALL	KILL_THIS
	RET
;
;Read orig name, dest name & node & subject from MSGTXT.
READ_HEAD:
;;	LD	A,(HDR_RBA)
;;	LD	C,A
	LD	HL,(HDR_RBA+1)
	CALL	_SEEKTO
	CALL	_READBLK
	JP	NZ,ERROR
	LD	HL,2
	LD	(_BLKPOS),HL
;
;;	LD	DE,TXT_FCB
;;	CALL	DOS_POS_RBA
;;	JP	NZ,ERROR
;
	CALL	BGETC
	CP	0FFH
	LD	HL,M_NOFF
	JP	NZ,CORRUPT	;no FF at start.
;
	CALL	BGETC		;bypass flags
	CALL	BGETC		;bypass unused byte
;
	LD	HL,ORIG_NAME
RH_01	CALL	BGETC
	CP	CR
	JR	Z,RH_02
	LD	(HL),A
	INC	HL
	JR	RH_01
RH_02	LD	(HL),0
	LD	HL,DEST_NAME
RH_03	CALL	BGETC
	CP	CR
	JR	Z,RH_04
	LD	(HL),A
	INC	HL
	JR	RH_03
RH_04	LD	(HL),0
	LD	HL,DATE_LEFT
RH_05	CALL	BGETC
	CP	CR
	JR	Z,RH_06
	LD	(HL),A
	INC	HL
	JR	RH_05
RH_06	LD	(HL),0
;
;Fix the dashes "-" at offsets +2 and +6 to spaces.
	LD	A,' '
	LD	(DATE_LEFT+2),A
	LD	(DATE_LEFT+6),A
;
	LD	HL,SUBJECT
RH_07	CALL	BGETC
	CP	CR
	JR	Z,RH_08
	LD	(HL),A
	INC	HL
	JR	RH_07
RH_08	LD	(HL),0
;
;Fixup the case of the From and To names
;;	LD	HL,ORIG_NAME
;;	CALL	FIX_NAME_CASE
;;	LD	HL,DEST_NAME
;;	CALL	FIX_NAME_CASE
;
;Print the contents of this message on the screen.
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
;We're positioned to read in the message text now,
;but first must find out where the message is aimed at.
;
;Figure out (a) the destination network number,
;	    (b) the destination link name.
FIGURE_IT_OUT
; Find the start of the network address
	LD	HL,DEST_NAME
FIO_01	LD	A,(HL)
	OR	A		;was CP CR
	LD	A,2
	JR	NZ,FIO_01A
	LD	HL,M_NOTNET
	JP	CORRUPT
FIO_01A	LD	A,(HL)
	INC	HL
	CP	'@'
	JR	NZ,FIO_01
	LD	(NET_ADDRESS),HL
;
;This might be echomail. Do a check if it is...
	CALL	HANDLE_ECHO
;
;Try to string-substitute it...
	LD	HL,NODE
	LD	(NLPTR),HL
FIO_02
	LD	E,(HL)		;Pointer to name string
	INC	HL
	LD	D,(HL)
	LD	A,D
	OR	E
	JR	Z,FIO_04	;not in nodelist
	PUSH	DE
	LD	HL,(NET_ADDRESS)
	CALL	STRCMP_CI
	POP	DE
	JR	Z,FIO_03
	LD	HL,(NLPTR)
	LD	BC,6
	ADD	HL,BC
	LD	(NLPTR),HL
	JR	FIO_02
;Are equal therefore substitute fidonode number & link
; & then jump to number interpreting.
FIO_03	LD	HL,(NLPTR)
	INC	HL
	INC	HL
	LD	E,(HL)		;Pointer to number string
	INC	HL
	LD	D,(HL)
	LD	(NET_ADDRESS),DE
	INC	HL
	LD	E,(HL)		;Pointer to link name
	INC	HL
	LD	D,(HL)
	LD	(LINK_TOUSE),DE
	JP	FIO_08
;
FIO_04		;Search on number now. A silly person
	LD	HL,NODE		;would use the node
	LD	(NLPTR),HL	;number even though a
FIO_05				;generic name was
	LD	E,(HL)		;available.
	INC	HL
	LD	D,(HL)
	LD	A,D
	OR	E
	JR	Z,FIO_07	;unkn NUMBER too.
	INC	HL
	LD	E,(HL)		;pointer to number string
	INC	HL
	LD	D,(HL)
	PUSH	DE
	LD	HL,(NET_ADDRESS)
	CALL	STRCMP_CI
	POP	DE
	JR	Z,FIO_06
	LD	HL,(NLPTR)
	LD	BC,6
	ADD	HL,BC
	LD	(NLPTR),HL
	JR	FIO_05
;
FIO_06
	LD	HL,(NLPTR)
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(LINK_TOUSE),DE
	JR	FIO_08
;
;Name and/or number is unknown. Set the linkname to
;the default (prim_link) then convert what must be
;a number into two integers.
FIO_07
	LD	DE,PRIM_LINK
	LD	(LINK_TOUSE),DE
;
;Convert whats now gotta be a number into the two
;integers for net/node.
FIO_08
	LD	HL,M_ONLINK
	CALL	MESS
	LD	HL,(LINK_TOUSE)
	CALL	MESS
	CALL	PUTCR
;
;Check format of (NET_ADDRESS) to be something like:
;     [nnnnn/nnnnn]<00>
	LD	HL,(NET_ADDRESS)
	LD	A,(HL)
	CP	'['
	JP	NZ,ACS_ADDRESS
	INC	HL
	LD	DE,0
	LD	A,(HL)
	CALL	IF_NUM
	JP	NZ,BAD_ADDRESS
FIO_09	CALL	ADD_SUM
	INC	HL
	LD	A,(HL)
	CALL	IF_NUM
	JR	Z,FIO_09
	CP	'/'
	JP	NZ,BAD_ADDRESS
	LD	(TO_NET_NUM),DE
	INC	HL
	LD	A,(HL)
	CALL	IF_NUM
	JP	NZ,BAD_ADDRESS
	LD	DE,0
FIO_10	CALL	ADD_SUM
	INC	HL
	LD	A,(HL)
	CALL	IF_NUM
	JR	Z,FIO_10
	CP	']'
	JP	NZ,BAD_ADDRESS
	INC	HL
	LD	A,(HL)
	OR	A
;;;	jp	nz,bad_address	;actually, ignore it.
	LD	(TO_NODE_NUM),DE
;
;Now ... use the linkname to find the fidonode number and
;packet file to use for this message.
FIO_11		;Search linknames for this one.
	LD	HL,LINK
	LD	(LTPTR),HL
FIO_12
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	DEC	HL
	LD	A,D
	OR	E
	JR	Z,FIO_13	;unkn linkname
	LD	E,(HL)		;get addr(link_name)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	LD	HL,(LINK_TOUSE)
	CALL	STRCMP_CI
	POP	DE
	JR	Z,FIO_14
	LD	HL,(LTPTR)
	LD	BC,6
	ADD	HL,BC
	LD	(LTPTR),HL
	JR	FIO_12
;
FIO_13				;linkname unknown.
	LD	HL,M_UNKNLINK
	JP	CORRUPT
;
FIO_14
	LD	HL,(LTPTR)
	INC	HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(ROUTE_ADDRESS),DE
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(ROUTE_FILENAME),DE
;
;Now the ascii address of the node to which the message
;must be sent is known, as is the filename which is to
;be used. Firstly convert the routing address into two
;integers.
;
;Check format of (ROUTE_ADDRESS) to be something like:
;     [nnn/nnn]<00>
	LD	HL,(ROUTE_ADDRESS)
	LD	A,(HL)
	CP	5BH
	JP	NZ,BAD_ADDRESS
	INC	HL
	LD	DE,0
	LD	A,(HL)
	CALL	IF_NUM
	JP	NZ,BAD_ADDRESS
FIO_15	CALL	ADD_SUM
	INC	HL
	LD	A,(HL)
	CALL	IF_NUM
	JR	Z,FIO_15
	CP	'/'
	JP	NZ,BAD_ADDRESS
	LD	(ROUTE_NET_NUM),DE
	INC	HL
	LD	A,(HL)
	CALL	IF_NUM
	JP	NZ,BAD_ADDRESS
	LD	DE,0
FIO_16	CALL	ADD_SUM
	INC	HL
	LD	A,(HL)
	CALL	IF_NUM
	JR	Z,FIO_16
	CP	']'
	JP	NZ,BAD_ADDRESS
	INC	HL
	LD	A,(HL)
	OR	A
;;;	jp	nz,bad_address	;actually, ignore it.
	LD	(ROUTE_NODE_NUM),DE
;
;I think perhaps everything is figured out now.
	XOR	A
	RET
;
;acs_address: Set things up so the msg is converted and
;goes to our acsnet feed (nswitgould).
ACS_ADDRESS
	LD	HL,DEST_NAME
	LD	DE,ADDRESSL
	CALL	STRCPY
	LD	HL,GATEWAY
	LD	DE,DEST_NAME
	CALL	STRCPY
	LD	HL,ACSLINK
	LD	(LINK_TOUSE),HL
	LD	A,1
	LD	(ON_ACS),A
	LD	HL,713		;acs link net number
	LD	(TO_NET_NUM),HL
	LD	HL,603		;acs link node number
	LD	(TO_NODE_NUM),HL
	JP	FIO_11		;Continue!
;
;
;open the filename as determined by ROUTE_FILENAME
;if already open, leave open & return.
;if a new file, write out the header first.
; otherwise, position to EOF.
OPEN_PACKET
	LD	HL,(ROUTE_FILENAME)
	LD	DE,CURRENT_FILE
	CALL	STRCMP_CI
	JR	Z,OP_01		;already open.
;
	LD	HL,(ROUTE_FILENAME)
	LD	DE,CURRENT_FILE
	CALL	STRCPY		;set the name.
;
	LD	DE,PKT_FCB
	LD	A,(DE)
	AND	80H
	CALL	NZ,DOS_CLOSE	;close if open.
	JP	NZ,ERROR
;
	LD	HL,CURRENT_FILE
	LD	DE,CURRENT_FILEA
	CALL	STRCPY
	LD	HL,FILE_APPEND
	LD	DE,CURRENT_FILEA
	CALL	STRCAT
;
	LD	HL,CURRENT_FILEA
	LD	DE,PKT_FCB
	CALL	EXTRACT		;extract.
	JP	NZ,ERROR
;
	LD	DE,PKT_FCB
	LD	HL,PKT_BUF
	LD	B,0
	CALL	DOS_OPEN_NEW	;open new or existing
	JP	NZ,ERROR
	CALL	C,MAKE_HEADER	;put hdr info in the pkt
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
	LD	HL,ZETA_NODE	;send originating node
	LD	DE,PKT_FCB
	CALL	PUTW
;
	LD	HL,(ROUTE_NODE_NUM)	;routing node
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
	LD	HL,(ROUTE_NET_NUM)
	CALL	PUTW		;destination net
;
;Followed by 34 zeroes.
	LD	B,17
	LD	HL,0
MH_01	CALL	PUTW
	JP	NZ,ERROR
	DJNZ	MH_01
;
	LD	HL,0
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
	LD	A,(HDR_FLAG)
	AND	2		;keep FM_PRIVATE
	SRL	A		;shift to bit zero
	LD	B,A
	LD	A,(F_ECHO)
	OR	A
	LD	A,0
	JR	NZ,CM_01	;Must be public if echomail
	LD	A,B
CM_01
	CALL	ROM@PUT
;
	XOR	A		;2nd flags byte
	CALL	ROM@PUT
;
;And set the cost to something...
	LD	HL,10		;10 cents
	CALL	PUTW
	JP	NZ,ERROR
;
;Its now time to copy the strings read into memory a
;long LONG time ago (maybe 2 sec?) into the packet file.
;
	LD	A,(ON_ACS)
	OR	A
	JR	NZ,CM_01A	;acsnet => case sensitive
	LD	HL,ORIG_NAME
	CALL	FIX_NAME_CASE
	LD	HL,DEST_NAME
	CALL	FIX_NAME_CASE
CM_01A
	LD	DE,PKT_FCB
	LD	HL,DATE_LEFT	;19 chars long
	CALL	FPUTS		;dd mmm yy  hh:mm:ss
	JP	NZ,ERROR
	CALL	PUTNULL		;MANDATORY !!!
;
	LD	HL,DEST_NAME
	CALL	FPUTS_ID	;Output until @ reached
	JP	NZ,ERROR
	CALL	PUTNULL
;
	LD	HL,ORIG_NAME
	CALL	FPUTS_ID
	JP	NZ,ERROR
	CALL	PUTNULL
;
	LD	HL,SUBJECT
	CALL	FPUTS
	JP	NZ,ERROR
	CALL	PUTNULL
;
;If an acsnet message, prefix it with "To:" line
	LD	A,(ON_ACS)
	OR	A
	JR	Z,CM_01B
	LD	HL,ADDRESS
	CALL	FPUTS
	LD	A,CR
	CALL	ROM@PUT
	LD	A,LF
	CALL	ROM@PUT
CM_01B
;If not echomail bypass area line append.
	LD	A,(F_ECHO)
	OR	A
	JR	Z,CM_02		;If not echomail
;
	LD	HL,S_AREA
	CALL	FPUTS
	JP	NZ,ERROR
	LD	HL,(ECHO_AREA)
	CALL	FPUTS
	JP	NZ,ERROR
;
;Now the message can be copied a character at a time.
;Translate all CR to CRLF, and when a null is read also
;write that to the packet.
;
CM_02
	CALL	BGETC
	JP	NZ,ERROR
	CP	CR
	JR	NZ,CM_03
;
	LD	DE,PKT_FCB
	CALL	ROM@PUT
	JP	NZ,ERROR
	LD	A,LF
	CALL	ROM@PUT
	JP	NZ,ERROR
	JR	CM_02
;
CM_03	OR	A
	JR	Z,CM_04
	LD	DE,PKT_FCB
	CALL	ROM@PUT
	JR	CM_02
;
CM_04
	LD	A,(F_ECHO)
	OR	A
	JR	Z,CM_05		;If not echomail
;
	LD	DE,PKT_FCB
	LD	HL,(ECHO_ORIGIN)
	CALL	FPUTS
	JP	NZ,ERROR
;
CM_05	LD	DE,PKT_FCB
	XOR	A
	CALL	ROM@PUT
;Write the two zero bytes signifying end of packet
; into the packet file.
	XOR	A
	CALL	ROM@PUT
	JP	NZ,ERROR
	XOR	A
	CALL	ROM@PUT
	JP	NZ,ERROR
	RET			;finished copy.
;
CLOSE_FILES
	LD	DE,TXT_FCB
	CALL	DOS_CLOSE
	LD	DE,HDR_FCB
	CALL	DOS_CLOSE
	LD	DE,TOP_FCB
	CALL	DOS_CLOSE
	LD	DE,NETN_FCB
	CALL	DOS_CLOSE
	LD	DE,NETL_FCB
	CALL	DOS_CLOSE
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
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	OR	20H
	JP	TERMINATE
;
GETZ	CALL	ROM@GET
	RET	Z
	JP	ERROR
;
PUTW	LD	A,L
	CALL	ROM@PUT
	RET	NZ
	LD	A,H
	CALL	ROM@PUT
	RET
;
PUTNULL	XOR	A
	CALL	ROM@PUT
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
BAD_ADDRESS
	PUSH	HL
	LD	HL,M_BADADD
	CALL	MESS
	LD	HL,M_BADADD
	CALL	LOG_MSG
	POP	HL
	PUSH	HL
	CALL	MESS
	POP	HL
	CALL	LOG_MSG
	LD	A,CR
	LD	DE,DCB_2O
	CALL	ROM@PUT
	XOR	A
	CP	1
	RET		;from FIO, bypass this msg.
;;	JP	ERROR
;
MESS	LD	DE,DCB_2O
	CALL	MESS_0
	RET
;
PUTCR	LD	A,CR
	LD	DE,DCB_2O
	CALL	ROM@PUT
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
KILL_THIS
;
;  Don't actually kill the message from the system but
; set the FM_NETSENT bit instead so the message will not
; get sent again.
	LD	HL,HDR_FLAG
	SET	FM_NETSENT,(HL)
;  Rewrite the header file.
	LD	DE,HDR_FCB
	CALL	DOS_BACK_RECD
	JP	NZ,ERROR
	LD	HL,HDR_REC
	CALL	DOS_WRIT_SECT
	JP	NZ,ERROR
	RET
;
FPUTS_ID
	LD	A,(HL)
	OR	A
	RET	Z
	CP	'@'
	RET	Z
	CALL	ROM@PUT
	RET	NZ
	INC	HL
	JR	FPUTS_ID
;
HANDLE_ECHO
;
	LD	HL,ECHOMAIL	;Check areas table.
	LD	(EMPTR),HL
HE_01
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,D
	OR	E
	RET	Z		;not echomail.
	PUSH	DE
	LD	HL,(NET_ADDRESS)
	CALL	STRCMP_CI
	POP	DE
	JR	Z,HE_02		;IS echomail!
	LD	HL,(EMPTR)
	LD	BC,8
	ADD	HL,BC
	LD	(EMPTR),HL
	JR	HE_01
;Substitute in co-ordinators node and set F_ECHO flag.
HE_02	LD	HL,(EMPTR)
;
	INC	HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(NET_ADDRESS),DE
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(ECHO_AREA),DE
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(ECHO_ORIGIN),DE
;
	LD	A,1
	LD	(F_ECHO),A
;
	RET
;
;End of pktass1
