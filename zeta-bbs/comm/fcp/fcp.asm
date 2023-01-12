;Fcp: Fidotalk connection protocol
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
*GET	RS232
*GET	FIDONET
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	FIDO_LOST
;End of program load info.
;
	COM	'<Fcp 1.0  02-Jan-88>'
	ORG	BASE+100H
START	LD	SP,START
;
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JP	Z,TERMINATE
;
;Usage: Fcp  [{-d] net/node]
	LD	A,(HL)
	CP	'-'
	JR	NZ,ST_00A
	INC	HL
	LD	A,(HL)
	INC	HL
	INC	HL
	AND	5FH
	CP	'D'
	JR	NZ,ST_00A
	LD	A,1
	LD	(D_FLAG),A
ST_00A
	LD	A,(HL)
	CP	CR
	JR	Z,ST_00B
;
	LD	A,1
	LD	(SPHASE),A	;Send first
	CALL	CONVFILE	;Change n/n to filename
	CALL	IS_MAIL		;make mail packet if necc
;
ST_00B
	XOR	A
	LD	(FAILED),A
;
	CALL	MAKE_NAME	;Make pktNNN.pkt name
	CALL	DIAL_FIDO	;Dial 'im up
	CALL	CONN_FIDO	;Connection stuff
;
	LD	A,(SPHASE)
	OR	A
	JR	Z,ST_00C	;Recv phase first
;
	CALL	SEND_PHASE
	LD	A,(FAILED)
	OR	A
	CALL	Z,RECV_PHASE
	JR	ST_00D
;
ST_00C
	CALL	RECV_PHASE
	LD	A,(FAILED)
	OR	A
	CALL	Z,SEND_PHASE
ST_00D
	CALL	SAVE_PACKET	;Save old outgoing mail
	CALL	DISC_FIDO	;Disconnect
	XOR	A
;Modify & close STATS file
	CALL	CLOSE_STATS	;Alter & close stats.
	LD	HL,CMD_PKTDIS	;disassemble the packet.
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,FILENAME
	CALL	STRCAT
	LD	HL,STRING
	CALL	CALL_PROG
	JR	Z,GP_04
;
	LD	HL,M_NODIS
	CALL	LOG_MSG_2
	LD	A,2
	JP	TERMINATE
;
GP_04
	LD	HL,M_DISOK
	CALL	LOG_MSG_2
	LD	HL,M_OK
	CALL	LOG_MSG_2
	XOR	A
	JP	TERMINATE
;
EXIT_FTALK
	JP	TERMINATE
;
SEND_PHASE
	CALL	MAIL_SEND	;Send mail packet
	CALL	FILE_SEND	;Send file attaches
	RET
;
RECV_PHASE
;
GP_02
	CALL	MAIL_RECV
GP_03
	LD	HL,M_XMFOK
	CALL	LOG_MSG_2
;
;Now receive any attached files ...
	CALL	FILE_RECV
;
;
;
CONVFILE
	EX	DE,HL
	LD	HL,0
	CALL	GETINT
	LD	(TO_NET),HL
	LD	A,(DE)
	CP	'/'
	RET	NZ
	INC	DE
	LD	HL,0
	CALL	GETINT
	LD	(TO_NODE),HL
;
	LD	HL,(TO_NET)
	LD	DE,PKTNAME
	CALL	TO_HEX
	LD	A,(PKTNAME)
	ADD	A,11H
	LD	(PKTNAME),A
;
	LD	HL,(TO_NODE)
	LD	DE,PKTNAME+4
	CALL	TO_HEX
	LD	A,(PKTNAME+4)
	ADD	A,11H
	LD	(PKTNAME+4),A
;
	XOR	A
	LD	(PKTNAME+8),A
	RET
;
GETINT	LD	A,(DE)
	CP	'9'+1
	RET	NC
	CP	'0'
	RET	C
	SUB	'0'
	PUSH	HL
	POP	BC
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,BC
	ADD	HL,HL
	LD	C,A
	LD	B,0
	ADD	HL,BC
	INC	DE
	JR	GETINT
;
TO_HEX	LD	A,H
	CALL	TO_HEX_1
	LD	A,L
	CALL	TO_HEX_1
	RET
;
TO_HEX_1
	LD	C,A
	AND	0F0H
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	CALL	TO_HEX_2
	LD	A,C
	AND	0FH
	CALL	TO_HEX_2
	RET
;
TO_HEX_2
	CP	10
	JR	C,TO_HEX_3
	ADD	A,7
TO_HEX_3
	ADD	A,'0'
	LD	(DE),A
	INC	DE
	RET
;
IS_MAIL
	LD	HL,PKTNAME
	LD	DE,PKT_FCB
	CALL	STRCPY
	LD	HL,FILE_TRAIL1
	CALL	STRCAT
	LD	A,CR
	LD	(DE),A
;
	LD	HL,PKTNAME
	LD	DE,FA_FCB
	CALL	STRCPY
	LD	HL,FILE_TRAIL2
	CALL	STRCAT
	LD	A,CR
	LD	(DE),A
;
	LD	DE,PKT_FCB
	LD	HL,PKT_BUF
	LD	B,60
	CALL	DOS_OPEN_NEW
	RET	NC		;Existing
	LD	HL,(TO_NET)
	LD	(DUMMY_NET),HL
	LD	HL,(TO_NODE)
	LD	(DUMMY_NODE),HL
;
	LD	HL,DUMMY_PKT
	LD	DE,PKT_FCB
	CALL	DOS_WRIT_SECT
	JP	NZ,ERROR
	CALL	DOS_WRITE_EOF
	JP	NZ,ERROR
	RET
;
ERROR
	LD	A,2
	JP	TERMINATE
;
DIAL_FIDO
	LD	A,(D_FLAG)
	OR	A
	RET	Z		;Not dialling out
	LD	A,(SPHASE)
	OR	A
	RET	Z		;Cant dial if recv first
	LD	HL,M_DIAL1
	CALL	LOG_MSG_2
	LD	B,40		;40 sec delay for carrier
DIAL_01
	LD	A,10
	CALL	SEC10
	CALL	CARR_DETECT
	JR	Z,DIAL_02	;found
	DJNZ	DIAL_01		;try again
;
;We didn't get a carrier from the other side.
	LD	HL,M_DIAL3
	CALL	LOG_MSG_2
	LD	A,10
	JP	EXIT_FTALK
;
DIAL_02
	LD	HL,M_DIAL2
	CALL	LOG_MSG_2
	RET
;
CONN_FIDO
	LD	A,(D_FLAG)
	OR	A
	JP	Z,CONN_04	;Bypass if not dialling
;
	LD	HL,M_WHACK
	CALL	LOG_MSG_1
;
	LD	B,5		;Whack CR 5 times
;
CONN_01
	PUSH	BC
	LD	A,' '
	CALL	PUT_BYTE
	LD	A,CR
	CALL	PUT_BYTE
	LD	A,2
	CALL	SEC10
	LD	A,CR
	CALL	PUT_BYTE
;
	LD	B,80		;2 secs
	LD	A,(TICKER)
	LD	C,A
CONN_02A
	PUSH	BC
	CALL	SER_INP
	POP	BC
	CP	CR
	JR	Z,CONN_03A
	LD	A,(TICKER)
	CP	C
	LD	C,A
	JR	Z,CONN_02A
	DJNZ	CONN_02A
	POP	BC
	DJNZ	CONN_01		;2 sec over
				;try again...
	LD	HL,M_NOCRS
	CALL	LOG_MSG_2
;
;just assume it was accepted anyway!
	JR	CONN_04
;
	LD	A,11
	JP	EXIT_FTALK
;
CONN_03A
	POP	BC
;
CONN_04
	LD	B,1
	CALL	GET_BYTE
	JR	NC,CONN_04	;Wait till no input
;
	LD	A,TSYNC
	CALL	PUT_BYTE
;
	LD	HL,M_SAWTS
	CALL	LOG_MSG_1
	LD	A,TSYNC
	CALL	PUT_BYTE
	RET			;finished connecting.
;
MAIL_SEND
	LD	HL,CMD_XMF
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,PKTNAME
	CALL	STRCAT
	LD	HL,FILE_TRAIL1
	CALL	STRCAT
	CALL	XMF_S
	JR	NZ,MAIL_01
	LD	HL,M_MAILOK
	CALL	LOG_MSG_1
	LD	A,1
	LD	(SENTPKT),A
	RET
MAIL_01
	LD	HL,M_MAILBAD
	CALL	LOG_MSG_2
	LD	A,1
	LD	(FAILED),A
	RET
;
XMF_S
	LD	HL,STRING
	CALL	CALL_PROG
	LD	A,(LASTCC)
	OR	A
	RET
;
; Send any attached files (or queued files here)
FILE_SEND
	LD	A,(FAILED)
	OR	A
	RET	NZ		;If failed.
;
	XOR	A
	LD	(FILES),A
;
	LD	DE,FA_FCB
	LD	HL,PKT_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	NZ,FS_01
	LD	A,1
	LD	(FILES),A
	LD	HL,M_ISFILES
	CALL	LOG_MSG_1
FS_01	XOR	A
	LD	(TRIES),A
FS_02
	LD	HL,FS_MT_1
	CALL	LOG_MSG_1
	LD	A,(TRIES)
	INC	A
	LD	(TRIES),A
	CP	20
	JR	Z,FF_03		;Gave up
	LD	B,2
	CALL	GET_BYTE
	JR	C,FS_02		;Timed out
	CP	ASC_NAK
	JR	Z,FS_03		;Got Nak
	CP	ASC_ACK
	JR	Z,FF_05
	CP	TSYNC
	JR	Z,FF_02		;Tsync
	CP	'C'
	JR	Z,FF_04		;CRCnak
	LD	L,A
	LD	H,0
	PUSH	HL
	LD	HL,FS_MT_3
	CALL	LOG_MSG_1
	POP	HL
	LD	DE,$DO
	CALL	PRINT_NUMB
	JR	FS_02
;
FS_03	LD	HL,FS_MT_2		;Rcvd nak
	CALL	LOG_MSG_1
	JR	FF_06
;
FF_02	LD	HL,FS_MT_4		;Rcvd Tsync
	CALL	LOG_MSG_1
	RET
;
FF_03	LD	HL,FS_MT_5		;Gave up
	CALL	LOG_MSG_1
	LD	A,1
	LD	(FAILED),A
	RET
;
FF_04	LD	HL,FS_MT_6		;Rcvd C
	CALL	LOG_MSG_1
	JR	FF_06
FF_05
	LD	HL,FS_MT_7		;Rcvd ACK
	CALL	LOG_MSG_1
	JR	FS_02
;
FF_06
	LD	A,(FILES)
	OR	A
	JR	NZ,FF_07
;
FF_08
	LD	A,ASC_EOT
	CALL	PUT_BYTE
	LD	HL,FS_MT_8
	CALL	LOG_MSG_1
	JR	FS_02
;
FF_07
	CALL	READFN
	JR	NZ,FF_08	;No more files / error
	LD	HL,FA_FILE
	LD	A,(HL)
	CP	'*'
	JR	Z,FF_07		;Try again
	CALL	CONVFN
	CALL	MODEM7_FNAME
	JR	NZ,FF_07A	;Fn send failed
	LD	HL,CMD_XMF
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,FA_FILE
	CALL	STRCAT
	CALL	XMF_S
	JP	Z,FS_01
	LD	HL,M_FTFAIL
	CALL	LOG_MSG_1
	LD	A,1
	LD	(FAILED),A
	RET
;
FF_07A
	LD	HL,M_FNFAIL
	CALL	LOG_MSG_1
	LD	A,1
	LD	(FAILED),A
	RET
;
MODEM7_FNAME
	XOR	A
	LD	(TRIES),A
FS_MS0
	LD	A,(TRIES)
	INC	A
	LD	(TRIES),A
	CP	20
	JR	NZ,MF_01

	LD	HL,M7_TRY_MSG	; Too many tries
	CALL	LOG_MSG_1
	LD	A,3
	CP	0
	RET	;nz
MF_01	LD	A,ASC_ACK
	CALL	PUT_BYTE
	LD	HL,TEMPFN
	PUSH	HL
	LD	A,(HL)
	LD	C,A
	INC	HL
	CALL	PUT_BYTE
FS_MS1
	LD	B,2
	CALL	GET_BYTE
	JR	NC,MF_03
MF_02	LD	A,'u'
	CALL	PUT_BYTE
	POP	HL		;Discard
	LD	HL,M7_U		;Sending 'u'
	CALL	LOG_MSG_1
	JR	FS_MS0
MF_03
	CP	ASC_ACK
	JR	NZ,MF_02
	POP	HL
	LD	A,(HL)
	OR	A
	JR	Z,MF_04
	PUSH	HL
	CALL	PUT_BYTE
	POP	HL
	LD	A,(HL)
	ADD	A,C
	LD	C,A
	INC	HL
	PUSH	HL
	JR	FS_MS1
MF_04	LD	A,ASC_SUB
	CALL	PUT_BYTE
	LD	A,ASC_SUB
	ADD	A,C
	LD	C,A
FS_MS2
	LD	B,2
	CALL	GET_BYTE
	JR	C,FS_MS0
	CP	C
	JR	NZ,FS_MS0
	LD	A,ASC_ACK
	CALL	PUT_BYTE
	CP	A		; Set Z flag
	RET			; Success!
;
CONVFN
	LD	DE,TEMPFN
	PUSH	DE
	LD	A,' '
	LD	B,11
CV_00	LD	(DE),A
	INC	DE
	DJNZ	CV_00
	XOR	A
	LD	(DE),A
	POP	DE
	LD	B,8
CV_01	LD	A,(HL)
	OR	A
	JR	Z,CV_06
	CP	'.'
	JR	Z,CV_02
	CP	':'
	JR	Z,CV_06
	CP	'/'
	JR	Z,CV_06
	CALL	TO_UPPER_C
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	CV_01
CV_02
	LD	DE,TEMPFN+8
	LD	A,(HL)
	CP	'.'
	JR	NZ,CV_06
	LD	B,3
	INC	HL
CV_03	LD	A,(HL)
	OR	A
	JR	Z,CV_06
	CP	':'
	JR	Z,CV_06
	CP	'/'
	JR	Z,CV_06
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	CV_03
;
CV_06
	RET
;
READFN
	LD	HL,FA_FILE
	LD	DE,FA_FCB
	LD	B,31
RF_01	CALL	$GET
	RET	NZ
	CP	CR
	JR	Z,RF_02
	LD	(HL),A
	INC	HL
	DJNZ	RF_01
RF_02	LD	(HL),0
	CP	A
	RET
;
;
;
;
DISC_FIDO
	LD	A,20
	CALL	SEC10
	LD	HL,M_HANG1
	CALL	LOG_MSG_2
	XOR	A
	RET
;
PICK_FIDO
	LD	HL,GETPKT_CMD
	CALL	CALL_PROG
	RET
;
FIDO_LOST
	LD	HL,M_LOST1
	CALL	LOG_MSG_2
	LD	A,127
	JP	TERMINATE
	JP	LOST_CARRIER
;
SAVE_PACKET
	LD	HL,CMD_CP
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,PKTNAME
	CALL	STRCAT
	LD	HL,FILE_TRAIL1
	CALL	STRCAT
	LD	HL,SPCS
	CALL	STRCAT
	PUSH	DE
	LD	HL,PKTNAME
	CALL	STRCAT
	LD	HL,FILE_TRAIL1
	CALL	STRCAT
;
	POP	DE
	LD	A,'Q'		;for old
	LD	(DE),A
;
	LD	HL,STRING
	CALL	CALL_PROG	;copy file
	OR	A
	JR	NZ,NO_COPY
;
	LD	DE,PKT_FCB	;Open mail packet
	CALL	DOS_KILL
	RET	Z
	LD	HL,M_NORM
	CALL	LOG_MSG_2
	RET
;
NO_COPY
	LD	HL,M_NOCOPY
	CALL	LOG_MSG_2
	RET
;
GET_BYTE
	PUSH	DE
GB_1	LD	D,40		;=1 sec
	LD	A,(TICKER)
	LD	E,A
GB_2	LD	A,(CD_STAT)
	BIT	1,A
	JR	NZ,GB_3
	IN	A,(RDSTAT)
	BIT	DAV,A
	JR	NZ,GB_4
	LD	A,(TICKER)
	CP	E
	LD	E,A
	JR	Z,GB_2
	DEC	D
	JR	NZ,GB_2
	DJNZ	GB_1
GB_3	POP	DE
	SCF		;If timeout or carrier loss
	RET
;
GB_4	IN	A,(RDDATA)
	POP	DE
	OR	A
	RET
;
;send character
PUT_BYTE
	PUSH	AF
BS_1	LD	A,(CD_STAT)
	BIT	1,A
	JR	NZ,BS_2		;Carrier check.
	IN	A,(RDSTAT)
	BIT	CTS,A
	JR	Z,BS_1
BS_2
	POP	AF
	OUT	(WRDATA),A
	RET
;
LOG_MSG_2
	PUSH	HL
	LD	DE,$DO
	CALL	MESS_0
	POP	HL
	CALL	LOG_MSG
	RET
;
LOG_MSG_1
	LD	DE,$DO
	CALL	MESS_0
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
;getpkt: Do all functions required to get a Fidonet
;	 packet
;
; *notreached* - Looks like this fcp.asm is a work in progress
ST_1A
	LD	A,(FAILED)
	OR	A
	JR	NZ,GP_03B	;If fatal error
;
	LD	A,(D_FLAG)
	OR	A
	JP	NZ,GP_03B	;If we called out
;
;Now figure out who is calling, and run "ftalk" with
;the appropriate outgoing packet filename
	CALL	WHICH_LINK
	JR	Z,GP_03A	;there may be return mail
;
;We do not have a link to the machine which is calling.
;So just do this....
	LD	HL,M_NOLINKS
	CALL	LOG_MSG_2
	JR	GP_03B
;
GP_03A				;send return packet/files
;
	LD	HL,CMD_FTALK
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,(HEAD_ORIG_NET)
	CALL	SPUTNUM
	LD	A,'/'
	LD	(DE),A
	INC	DE
	LD	HL,(HEAD_ORIG_NODE)
	CALL	SPUTNUM
;
	LD	HL,STRING	;log the command
	CALL	LOG_MSG_2
;
	LD	HL,STRING
	CALL	CALL_PROG	;Send out packet/file
	OR	A
	JR	Z,GP_03B
	LD	HL,M_TALKBAD
	CALL	LOG_MSG_2
;
GP_03B
;
MAIL_RECV
	LD	HL,CMD_XMF
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,FILENAME
	CALL	STRCAT
;
	LD	HL,STRING
	CALL	LOG_MSG_2
	LD	HL,M_CR
	CALL	LOG_MSG_2
;
	LD	HL,STRING
	CALL	CALL_PROG	;Receive the file.
	OR	A
	JR	NZ,MR_01
;
;Bump packet received count.
	LD	HL,(PKTS_RCVD)
	INC	HL
	LD	(PKTS_RCVD),HL
	CP	A
	RET
;
MR_01
	LD	HL,M_NOXMF	;Couldn't transfer
	CALL	LOG_MSG_2
	LD	A,1
	JP	TERMINATE
;
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	LD	HL,M_BAD
	CALL	LOG_MSG_2
	POP	AF
	JP	TERMINATE
;
OPEN_STATS
	LD	HL,STATS_BUF
	LD	DE,STATS_FCB
	LD	B,16
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(STATS_FCB+1)
	AND	0F8H
	LD	(STATS_FCB+1),A
	LD	HL,STATS_REC
	CALL	DOS_READ_SECT
	JP	NZ,ERROR
	CALL	DOS_REWIND
	RET
;
CLOSE_STATS
;
	CALL	OPEN_STATS
;Set stats file for # of packets received.
	LD	HL,(PKTS_RCVD)
	LD	(ST_PKTS_RCVD),HL
;
	LD	DE,STATS_FCB	;Rewrite record
	LD	HL,STATS_REC
	CALL	DOS_WRIT_SECT
	JP	NZ,ERROR
	CALL	DOS_CLOSE
	JP	NZ,ERROR
	RET
;
MAKE_NAME
	LD	DE,FILENAME+3	;Bypass "pkt"
	LD	HL,(PKTS_RCVD)	;from memory
	INC	HL
	CALL	SPUTNUM
	LD	HL,FILE_TRAIL
	CALL	STRCAT
	RET
;
;Receive any attached files.
FILE_RECV
	LD	B,1
	CALL	GET_BYTE	;Flush
	LD	B,1
	CALL	GET_BYTE	;Flush
FR_01	CALL	MODEM7_FNAME
	JR	NC,FR_FAILED
	CP	ASC_EOT
	RET	Z
;
	LD	HL,M7_FILE
	CALL	LOG_MSG_2
;
	LD	HL,CMD_TELINK
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,M7_FILE
	CALL	STRCAT
;
	LD	HL,STRING
	CALL	CALL_PROG
	OR	A
	JR	Z,FR_02
;
	LD	HL,M_RCVBAD
	CALL	LOG_MSG_2
	LD	A,1
	LD	(FAILED),A
	RET
;
FR_02
	LD	HL,M_RCVOK
	CALL	LOG_MSG_2
	JR	FR_01
;
FR_FAILED
	LD	HL,M_FRFAIL
	CALL	LOG_MSG_2
	LD	A,1
	LD	(FAILED),A
	RET
;
MODEM7_FNAME
	LD	HL,MT_1
	CALL	LOG_MSG_1
	LD	A,(M7_TRY)
	INC	A
	LD	(M7_TRY),A
	CP	20
	JP	Z,M7_FAILED
;;;	IN	A,(0F8H)
;;;	IN	A,(0F8H)	;Flush.
	LD	A,ASC_NAK
	CALL	PUT_BYTE
MF_01
	LD	B,5
	CALL	GET_BYTE
	JR	C,MODEM7_FNAME	;If timeout.
	CP	ASC_ACK
	JR	Z,MF_03
	CP	ASC_SUB
	JR	Z,MF_SUB
	CP	ASC_EOT
	JR	Z,MF_02
;Unknown character.
	PUSH	AF
	LD	A,'"'
	LD	DE,$DO
	CALL	$PUT
	POP	AF
	CALL	$PUT
	LD	A,'"'
	CALL	$PUT
	LD	A,' '
	CALL	$PUT
	JR	MODEM7_FNAME
;
;No files attached.
MF_02
	LD	HL,MT_2
	CALL	LOG_MSG_1
;
	LD	HL,M_NMFILES
	CALL	LOG_MSG_2
	LD	A,ASC_EOT
	SCF
	RET
;
MF_SUB
	LD	HL,MT_5
	CALL	LOG_MSG_1
	LD	A,ASC_ACK
	CALL	PUT_BYTE
	LD	A,ASC_EOT
	SCF
	RET
;
MF_03
	LD	HL,MT_3
	CALL	LOG_MSG_1
	LD	HL,M7_FIELD
	LD	C,0
	LD	(HL),C
MF_04
	LD	B,1
	CALL	GET_BYTE
	JP	C,MODEM7_FNAME	;If timeout
	CP	ASC_EOT
	JR	Z,MF_02		;If ACK then EOT .!?
	CP	ASC_SUB
	JR	Z,MF_05
	CP	'u'
	JP	Z,MODEM7_FNAME
	LD	(HL),A
	INC	HL
	ADD	A,C
	LD	C,A
;
	LD	A,ASC_ACK
	CALL	PUT_BYTE
;
	JR	MF_04
;
MF_05	ADD	A,C		;add ^Z.
	CALL	PUT_BYTE
;;	LD	HL,MT_4
;;	CALL	LOG_MSG_1
MF_06
	LD	B,1
	CALL	GET_BYTE
	JP	C,MODEM7_FNAME
	CP	ASC_ACK
	JR	Z,MF_07		;convert filename.
	JP	MODEM7_FNAME
;
;Create a filename.
MF_07	LD	HL,M7_FIELD
	CALL	FIX_ALPHA
	LD	DE,M7_FILE
	LD	B,8
MF_07A	LD	A,(HL)
	CP	' '
	JR	Z,MF_07B
	CALL	FIX_ALPHANUM
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	MF_07A
MF_07B
	LD	HL,M7_FIELD+8
;;	CALL	FIX_ALPHA
	LD	A,(HL)
	CP	' '
	JR	Z,MF_07D
	CALL	FIX_ALPHA
	LD	A,'.'
	LD	(DE),A
	INC	DE
	LD	B,3
MF_07C	LD	A,(HL)
	CP	' '
	JR	Z,MF_07D
	CALL	FIX_ALPHANUM
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	MF_07C
MF_07D
	XOR	A
	LD	(DE),A
	SCF
	RET
;
FIX_ALPHA
	LD	A,(HL)
	LD	C,A
	AND	5FH	;to 40h-5fh
	CP	'A'
	JR	C,FA_01
	CP	'Z'+1
	RET	C
FA_01	AND	0FH	;0000xxxx
	ADD	A,61H
	LD	(HL),A
	RET
FIX_ALPHANUM
	CP	'0'
	JR	C,FA_02
	CP	'9'+1
	RET	C
	AND	5FH
	CP	'A'
	JR	C,FA_02
	CP	'Z'+1
	RET	C
FA_02	AND	0FH
	ADD	A,61H
	RET
;
M7_FAILED
	XOR	A
	LD	(M7_TRY),A
	SCF
	CCF
	RET
;
WHICH_LINK
	LD	HL,FILENAME	;Open packet just got
	LD	DE,PKT_FCB
	CALL	EXTRACT
	JP	NZ,ERROR
;
	LD	DE,PKT_FCB
	LD	HL,PKT_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
;
	LD	A,(PKT_FCB+1)
	AND	0F8H
	OR	5
	LD	(PKT_FCB+1),A
;
	LD	DE,PKT_FCB
	LD	HL,HEAD
	LD	B,58
WL_01	CALL	$GET		;read header
	JP	NZ,ERROR
	LD	(HL),A
	INC	HL
	DJNZ	WL_01
;
	RET			;All done!!
;Don't bother reading net links file ...
	LD	DE,NETL_FCB	;Open net links
	LD	HL,NETL_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
	LD	A,(NETL_FCB+1)
	AND	0F8H
	OR	5
	LD	(NETL_FCB+1),A
;
	LD	DE,NETL_FCB
	LD	HL,STRING
	CALL	GET_WORD
	JP	NZ,MAYBE_ERROR
;Read NETL file for machine numbers serving links
;and associated filenames.
WL_02	LD	DE,NETL_FCB
	LD	HL,STRING	;Bypass linkname
	CALL	GET_WORD
	JP	NZ,WL_EOF
	LD	HL,STRING
	CALL	GET_WORD	;Get machine number
	JP	NZ,MAYBE_ERROR
;
	LD	HL,STRING	;decode machine number
	LD	DE,0
	LD	A,(HL)
	INC	HL
	CP	'['
	JP	NZ,WL_NOTEQ
	LD	A,(HL)
	CALL	IF_NUM
	JP	NZ,WL_NOTEQ
	INC	HL
WL_03	CALL	ADD_SUM
	LD	A,(HL)
	INC	HL
	CALL	IF_NUM
	JR	Z,WL_03
	CP	'/'
	JP	NZ,WL_NOTEQ
	LD	(CURRENT_NET),DE
	LD	A,(HL)
	INC	HL
	CALL	IF_NUM
	JP	NZ,WL_NOTEQ
	LD	DE,0
WL_04	CALL	ADD_SUM
	LD	A,(HL)
	INC	HL
	CALL	IF_NUM
	JR	Z,WL_04
	CP	']'
	JP	NZ,WL_NOTEQ
	LD	(CURRENT_NODE),DE
;
;Now check the two numbers.
	LD	HL,(CURRENT_NET)
	LD	DE,(HEAD_ORIG_NET)
	OR	A
	SBC	HL,DE
	JP	NZ,WL_NOTEQ
;
	LD	HL,(CURRENT_NODE)
	LD	DE,(HEAD_ORIG_NODE)
	OR	A
	SBC	HL,DE
	JP	NZ,WL_NOTEQ
;
;Are equal! read in the filename & return with Z status.
	LD	DE,NETL_FCB
	LD	HL,LINK_NAME
	CALL	GET_WORD
	JP	NZ,MAYBE_ERROR
	RET
;
WL_NOTEQ
	LD	DE,NETL_FCB
	LD	HL,STRING
	CALL	GET_WORD
	JP	NZ,MAYBE_ERROR
	JP	WL_02		;reloop.
;
MAYBE_ERROR
	PUSH	AF
	LD	HL,M_MAYBE
	LD	DE,$DO
	CALL	MESS_0
	POP	AF
	JR	WL_EOF
;
WL_EOF	CP	1CH
	JR	Z,WL_EOF1
	CP	1DH
	JP	NZ,ERROR
WL_EOF1	XOR	A
	CP	1
	RET			;NZ = no links to him.
;
GET_WORD
	CALL	$GET
	RET	NZ
	CP	' '
	JR	Z,GW_01
	OR	A
	JR	Z,GW_01
	CP	CR
	JR	Z,GW_01
	LD	(HL),A
	INC	HL
	JR	GET_WORD
GW_01	LD	(HL),0
	CP	A
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
; Include globals
*GET	ROUTINES
*GET	SEC10
*GET	SPUTNUM
*GET	STATS
;
D_FLAG	DEFB	0	;1=Dial-out.
FAILED	DEFB	0	;1 = Connection failed somewhere
SENTPKT	DEFB	0	;1 = Outgoing packet was sent
TRIES	DEFB	0	;Count of file send attempts
TO_NET	DEFW	0	;Calling/called net
TO_NODE	DEFW	0	;Calling/called node
FILES	DEFB	0	;1 = Files to send
;
M_ISFILES
	DEFM	'We have files to send',CR,0
M_WHACK
	DEFM	'Whacking CR',CR,0
FS_MT_1	DEFM	'Waiting for their question',CR,0
FS_MT_2	DEFM	'Received nak',CR,0
FS_MT_3	DEFM	'Received other: ',0
FS_MT_4	DEFM	'Received early Tsync',CR,0
FS_MT_5	DEFM	'Gave up on no file send',CR,0
FS_MT_6	DEFM	'Saw "C"',CR,0
FS_MT_7	DEFM	'Received ack',CR,0
FS_MT_8	DEFM	'Sent EOT',CR,0
M_DIAL1	DEFM	CR,'FTalk...',CR,CR,0
M_DIAL2	DEFM	'Fido carrier detected',CR,0
M_DIAL3	DEFM	'** No carrier found',CR,0
M_SAWTS	DEFM	'TSYNC sent',CR,0
M_NOCRS	DEFM	'** No response to whacking CR',CR,0
M_MAILBAD
	DEFM	'Could not send mail packet',CR,0
M_MAILOK
	DEFM	'Mail packet sent successfully',CR,0
M_FILE1	DEFM	'File send ignored',CR,0
M_FNFAIL
	DEFM	'Modem7 filename send failed',CR,0
M_FTFAIL
	DEFM	'File send transfer failed',CR,0
M7_TRY_MSG	DEFM	'Too many tries',CR,0
M7_U	DEFM	'Sending U',CR,0
M_HANG1	DEFM	'Disconnecting from Fido',CR,0
M_LOST1	DEFM	'** Lost Fido carrier',CR,0
M_NOPKT
	DEFM	'** No packet to send to it',CR,0
M_NOCOPY
	DEFM	'** could not copy packet contents',CR,0
M_NORM
	DEFM	'** could not delete packet',CR,0
MT_1	DEFM	'--> trying to get filename',CR,0
MT_2	DEFM	'--> eot seen',CR,0
MT_3	DEFM	' ack ',0
MT_4	DEFM	' crc-sent ',0
MT_5	DEFM	' sub ',0
M_CR		DEFM	CR,0
M_OK		DEFM	'getpkt OK',CR,0
M_BAD		DEFM	'** getpkt bad',CR,0
M_NOXMF		DEFM	'** xmf pkt rcv failed',CR,0
M_XMFOK		DEFM	'xmf rcvd pkt ok',CR,0
M_DISOK		DEFM	'disassembled OK',CR,0
M_NODIS		DEFM	'** could not disassemble packet',CR,0
M_RCVOK		DEFM	'file receive worked',CR,0
M_FRFAIL	DEFM	'** modem7 filename failed',CR,0
M_RCVBAD	DEFM	'** file receive failed',CR,0
M_NMFILES	DEFM	'** no more files to receive',CR,0
M_NOLINKS	DEFM	'** no links to caller',CR,0
M_TALKBAD	DEFM	'** ftalk didn''t work',CR,0
M_MAYBE		DEFM	'** May be an error!',CR,0
;
;
CMD_XMF	DEFM	'xmf -qcs ',0
CMD_CP	DEFM	'cp ',0
CMD_RM	DEFM	'rm ',0
GETPKT_CMD
	DEFM	'Getpkt -d',0
SPCS	DEFM	' ',0
FILE_TRAIL1	DEFM	'.out/poof:2',0
FILE_TRAIL2	DEFM	'.fa/poof:2',0
;
;;MAILCC	DEFB	0
STRING	DEFS	64
PKTNAME	DEFS	64
FA_FILE	DEFS	32
TEMPFN	DEFS	12
;
PKT_FCB	DEFS	32
FA_FCB	DEFS	32
PKT_BUF	DEFS	256
;
DUMMY_PKT
		DEFW	ZETA_NODE
DUMMY_NODE	DEFW	0
		DEFW	1987
		DEFW	7	;Aug
		DEFW	30	;Day
		DEFW	8	;Hr
		DEFW	30	;Min
		DEFW	55	;Sec
		DEFW	0	;Baud
		DEFW	2	;Packet version
		DEFW	ZETA_NET
DUMMY_NET	DEFW	0
		DEFW	1	;Product code
		DC	33,0	;Fill
		DEFW	0	;No messages
;--- End of dummy packet data
;
M7_TRY	DEFB	0	;Tries for modem7 filename.
D_FLAG	DEFB	0	;=1 if we are calling out.
;
FILE_TRAIL	DEFM	'.pkt/poof:1',0
;
FILENAME	DEFM	'PKT00000.xxx/pppppppp',0
;
STATS_FCB	DEFM	'stats.zms',ETX
		DC	32-10,0
PKT_FCB		DEFS	32
NETL_FCB	DEFM	'netl.zms',ETX
		DC	32-9,0
;
STATS_BUF	DEFS	256
PKT_BUF		DEFS	256
NETL_BUF	DEFS	256
;
CMD_XMF		DEFM	'xmf -qocr ',0
CMD_TELINK	DEFM	'xmf -qcr ',0
CMD_PKTDIS	DEFM	'pktdis -r ',0
CMD_FTALK	DEFM	'ftalk ',0
;
;Format of the packet header.....
HEAD
HEAD_ORIG_NODE	DEFS	2
HEAD_DEST_NODE	DEFS	2
HEAD_YMDHMS	DEFS	12
HEAD_RATE	DEFS	2
HEAD_VER	DEFS	2
HEAD_ORIG_NET	DEFS	2
HEAD_DEST_NET	DEFS	2
		DEFS	34
;
CURRENT_NET	DEFW	0
CURRENT_NODE	DEFW	0
;
M7_FILE		DEFS	64
M7_FIELD	DEFS	11	;abcdefghXYZ
STRING		DEFS	64
LINK_NAME	DEFS	64
;
THIS_PROG_END	EQU	$
;
	END	START
