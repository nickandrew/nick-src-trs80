;xmodem1: Xmf source code file 1
;Last updated: 22-Aug-87
;
START	LD	SP,START
;
	PUSH	HL
	CALL	FLAGS_RESET
	CALL	CHK_USAGE
	POP	HL
	JP	NZ,NO_PAR
;
	LD	A,(HL)
	CP	CR
	JP	Z,NO_PAR	;No parameters.
;
;Loop for sending or receiving to follow.....
	LD	(ARG),HL
XFER_LOOP
	LD	HL,(ARG)
XL_01	LD	A,(HL)
	CP	CR
	JP	Z,XFER_FINI
	OR	A
	JP	Z,XFER_FINI
	CP	'-'
	JP	NZ,XFER_FILE
	INC	HL
XL_02	LD	A,(HL)		;check value of flag
	CP	'S'
	JR	Z,SET_DIRECTION
	CP	'R'
	JR	Z,SET_DIRECTION
	CP	'Q'
	JR	Z,SET_QUIET
	CP	'C'
	JR	Z,SET_CRC
	CP	'O'
	JR	Z,SET_OVERWRITE
	CP	'T'		;Telink mode
	JR	Z,SET_TELINK
	CP	'E'
	JR	Z,SET_EXMODEM
;flag unknown. bypass rest of flags
	CALL	BYP_WORD
	JR	XL_01
;
FLAGS_RESET
	LD	A,'S'		;assume sending first
	LD	(B_TYPE),A
	XOR	A
	LD	(QUIET),A
	LD	(CRCMODE),A
	LD	(OVERWRITE),A
	LD	(NOLOG),A
	RET
;
SET_DIRECTION
	LD	(B_TYPE),A
	LD	(3D30H),A
	INC	HL
	JR	XL_02
;
SET_QUIET
	LD	A,1
	LD	(QUIET),A
	INC	HL
	LD	A,'Q'
	LD	(3D31H),A
	JR	XL_02
;
SET_CRC
	LD	A,1
	LD	(CRCMODE),A
	LD	A,'C'
	LD	(3D32H),A
	INC	HL
	JR	XL_02
;
SET_OVERWRITE
	LD	A,1
	LD	(OVERWRITE),A
	LD	A,'O'
	LD	(3D33H),A
	INC	HL
	JR	XL_02
;
SET_TELINK
	LD	A,1
	LD	(TELINK),A
	LD	(CRCMODE),A
	INC	HL
	JR	XL_02
;
SET_EXMODEM
	LD	A,1
	LD	(EX_FLAG),A
	INC	HL
	JP	XL_02
;
;Jump to XFER_FINI when no more args to process.
XFER_FINI
	LD	A,(TELINK)
	OR	A
	JR	Z,XE_1
	LD	A,(B_TYPE)
	CP	'R'
	JP	Z,TELINK_RECV
XE_1
	XOR	A
	JP	EXIT_EXMF
;
XFER_FILE
	PUSH	HL
	CALL	BYP_WORD
	LD	(NEWARG),HL
	POP	HL
;
	CALL	SET_FILENAME
;
	CALL	XFER_INIT	;Initialise.
	CALL	START2		;Do the transfer.
;Next argument please
NEW_ARG
	LD	HL,(NEWARG)
	LD	(ARG),HL
	JP	XFER_LOOP
;
SET_FILENAME
	LD	DE,B_FILE
	LD	B,22
XF_01	LD	A,(HL)
	CP	CR
	JR	Z,XF_02
	CP	' '
	JR	Z,XF_02
	OR	A
	JR	Z,XF_02
	LD	(DE),A
	INC	DE
	INC	HL
	DJNZ	XF_01
XF_02	XOR	A
	LD	(DE),A
	RET
;
XFER_INIT
	CALL	CONFIG
	LD	A,10
	LD	(MAX_TOREAD),A	;Quick startup, SENDING
;
	XOR	A
	LD	(BLK_RCV),A
	LD	(BLK_SNT),A
	LD	(FIL_EOF),A
	LD	(NNAKS),A
	LD	(BLK_STORED),A
	LD	(XFABRT),A
	LD	(EOFB),A
	LD	HL,BIG_BUFF
	LD	(AID),HL
	LD	B,128
	LD	HL,DATABUF
	XOR	A
XI_01	LD	(HL),A
	INC	HL
	DJNZ	XI_01
	RET
;
BYP_SP	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	BYP_SP
BYP_WORD
	LD	A,(HL)
	CP	CR
	RET	Z
	OR	A
	RET	Z
	CP	' '
	JR	Z,BYP_SP
	INC	HL
	JR	BYP_WORD
;
NO_PAR
	LD	HL,M_SIGNON	;Print signon msg.
	LD	DE,$2
	CALL	MESS_0
NP_01	LD	HL,M_S_OR_R	;cmd mode
	LD	DE,$2
	CALL	MESS_0
	LD	HL,B_TYPE	;Get S or R.
	LD	B,1
	CALL	40H
	JP	C,NO_TRANSFER
	LD	A,(HL)
	CP	CR
	JP	Z,NO_TRANSFER
	AND	5FH
	LD	(HL),A
	INC	HL
	LD	(HL),' '
	CP	'S'
	JR	Z,NP_02
	CP	'R'
	JR	NZ,NP_01
NP_02	LD	HL,M_FILE
	LD	DE,$2
	CALL	MESS_0
	LD	HL,B_FILE	;Get filename.
	LD	B,23
	CALL	40H
	JP	C,NO_TRANSFER
	CALL	BYP_SP
	CP	CR
	JR	Z,NP_02
;Null terminate the filename.
NP_03	LD	A,(HL)
	CP	CR
	JR	Z,NP_04
	INC	HL
	JR	NP_03
NP_04	LD	(HL),0
;
	CALL	XFER_INIT
	CALL	START2
	XOR	A
	JP	EXIT_EXMF
;
NO_TRANSFER
	LD	A,0
EXIT_EXMF
	PUSH	AF
	CALL	LOG_CLOSE
	CALL	CONFIG
	POP	AF
	JP	TERMINATE
;
LOG_CLOSE
	LD	A,(FCB_LOG)
	BIT	7,A
	RET	Z
	LD	DE,FCB_LOG
	CALL	DOS_CLOSE
	RET
;
CHK_USAGE
	LD	A,(HL)
	CP	CR
	RET	Z
	OR	A
	RET	Z
CU_01	LD	A,(HL)
	OR	A
	RET	Z
	CP	CR
	RET	Z
	CP	'-'
	JR	Z,CU_02
	CALL	BYP_WORD
	JR	CU_01
CU_02	INC	HL
CU_02A	LD	A,(HL)
	CP	'S'
	JR	Z,CU_03
	CP	'R'
	JR	Z,CU_03
	CP	'Q'		;quiet mode. Shh!
	JR	Z,CU_03
	CP	'C'		;CRC mode.
	JR	Z,CU_03
	CP	'O'		;Overwrite existing file
	JR	Z,CU_03
	CP	'T'		;Telink mode
	JR	Z,CU_03
	JP	USAGE
CU_03	INC	HL
	LD	A,(HL)
	CP	CR
	RET	Z
	OR	A
	RET	Z
	CP	' '
	JR	NZ,CU_02A
	CALL	BYP_SP
	JR	CU_01
;
USAGE
	LD	HL,M_USAGE
	LD	DE,$2
	CALL	MESS_0
	XOR	A
	CP	1		;send to interactive
	RET
;
;
VDU_PUTS
VP_01
	LD	A,(HL)
	OR	A
	RET	Z
	PUSH	DE
	PUSH	HL
	LD	HL,3C41H
	LD	DE,3C40H
	LD	BC,63
	LDIR
	LD	(3C7FH),A
	POP	HL
	POP	DE
	INC	HL
	JR	VP_01
;
TELINK_RECV
	XOR	A
	LD	(M7_TRY),A
	CALL	M7R_FILE
	JP	NC,EXIT_EXMF
	CP	EOT
	JP	Z,EXIT_EXMF
	CALL	XFER_INIT
	CALL	START2
	JR	TELINK_RECV
;
LOG_OPEN
	LD	DE,FCB_LOG
	LD	A,(DE)
	BIT	7,A
	RET	NZ		;if already open.
	LD	HL,BUFF_LOG
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,DOSERR
	LD	A,(FCB_LOG+1)	;unprotect.
	AND	0F8H
	LD	(FCB_LOG+1),A
	CALL	DOS_POS_EOF
	JP	NZ,DOSERR
	RET			;log is open.
;
START2
	CALL	LOG_OPEN
;*-*
	LD	HL,B_DATE	;log date
	CALL	X_TODAY		;Use nice date format
	LD	HL,B_TIME
	CALL	446DH
;
	LD	HL,B_DATE
	CALL	LOG_2
;
;Log users name.
	LD	HL,(USR_NAME)
	LD	DE,FCB_LOG
	CALL	MESS_NOCR
	LD	A,' '
	CALL	$PUT
	LD	HL,B_TYPE	;Log S|R and filename.
	CALL	LOG_2
	LD	A,CR
	CALL	$PUT
;
	CALL	SCREEN_SETUP	;setup host screen.
;
	LD	A,(B_TYPE)
	CP	'S'
	JP	Z,SEND		;recv if not 'S'
;
	LD	HL,M_RECVNG	;receive a file
	CALL	QUIET_0
	LD	HL,B_FILE
	CALL	QUIET_0
	LD	A,CR
	CALL	QUIET_PUT
;
	LD	HL,B_FILE
	LD	DE,FCB_1
	CALL	EXTRACT
	JR	Z,RECV_0
;If bad extract
	LD	HL,M_ERROR
	CALL	LOG_2
	LD	HL,M_BDFL
	LD	DE,$2
	CALL	MESS_0
	LD	A,1		;bad filename on recv.
	JP	EXIT_EXMF
;
RECV_0
	LD	HL,FCB_1
	CALL	NODRIVE		;Remove ':D' from fname.
	LD	DE,FCB_1	;Try to open existing.
	LD	HL,BUFF_1
	LD	B,0
	CALL	DOS_OPEN_EX	;Should fail.
	JP	Z,EXISTS
	CP	18H		;de_fnid
	JR	Z,GETDESC
	PUSH	AF
	LD	HL,M_ERROR
	CALL	LOG_2
	POP	AF		;unknown error on initial
	JP	DOSERR		;file open, receive.
;
;ask for description.
GETDESC
	LD	A,(QUIET)
	OR	A
	JR	NZ,NODESC	;none if quiet
;
NODESC
	LD	HL,BUFF_1	;open new file for recv.
	LD	DE,FCB_1
	LD	B,0H
	CALL	DOS_OPEN_NEW
	JR	Z,AEZ
	PUSH	AF		;error opening RECV file
	LD	HL,M_ERROR
	CALL	LOG_2
	POP	AF
	JP	DOSERR		;error opening for RECV.
;
NODRIVE	LD	A,(HL)		;remove :D from name
	CP	CR
	RET	Z
	OR	A
	RET	Z
	INC	HL
	CP	':'
	JR	NZ,NODRIVE
	DEC	HL
	LD	(HL),CR
	RET
;
EXISTS				;recv file exists
	LD	A,(OVERWRITE)
	OR	A
	JR	Z,EXIST_1
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JR	NZ,AEZ		;allow overwrite
EXIST_1
	LD	HL,M_SENDEX
	CALL	LOG_2
	LD	HL,M_EXISTS	;file already exists
	LD	DE,$2
	CALL	MESS_0
	LD	A,2
	JP	EXIT_EXMF
;
AEZ	LD	HL,M_RRDY	;file is now open OK.
	CALL	QUIET_0
;delay a bit. Not if quiet though.
	LD	A,(QUIET)
	OR	A
	LD	A,50		;pre-initial NAK delay.
	CALL	Z,SEC10
	CALL	CONFIG
;
	LD	A,1
	LD	(FIRST_BLK),A
;
	CALL	INITIAL_NAK	;Send initial NAK
;
	CALL	POSS_ABRT
;
RCV_LP	CALL	GET_BLK		;get block
	JR	C,RCV_OK	;if EOT
	XOR	A
	LD	(FIRST_BLK),A
	CALL	POSS_ABRT
	CALL	WRITE_BLK	;Store
	CALL	INC_SNT		;inc send block number
	LD	A,(BLK_SNT)
	CALL	BLK_NUMB
	CALL	SEND_ACK
	JR	RCV_LP
;
;******* Start of Exmodem mods *******
RCV_OK	PUSH	AF
	CALL	AGR		;save all blocks
				;fixup EOF in FCB....
	POP	AF
	CP	ENQ
	JR	NZ,ROK_3
	LD	A,ACK
	CALL	PUT_BYTE
;
	LD	HL,M_R_ENQ	;signal enq ACK
	CALL	VDU_PUTS
	LD	HL,M_S_ACK
	CALL	VDU_PUTS
;
	LD	B,10		;wait for EOFB
	CALL	GET_BYTE
	JR	C,ROK_4
	LD	(EOFB),A
	LD	B,1
	CALL	GET_BYTE
	JR	C,ROK_4
	CPL
	LD	B,A
	LD	A,(EOFB)
	CP	B
	JR	C,ROK_4
ROK_1
	LD	A,(EOFB)
	AND	7FH
	JR	Z,ROK_5
	LD	B,A
	LD	A,(FCB_1+8)
	AND	80H
	JR	Z,ROK_2
	LD	A,B
	LD	(FCB_1+8),A
	JR	ROK_5
ROK_2
	LD	HL,(FCB_1+12)
	DEC	HL
	LD	(FCB_1+12),HL
	LD	A,B
	OR	80H
	LD	(FCB_1+8),A
	JR	ROK_5
ROK_3
	LD	A,128
	LD	(EOFB),A
	JR	ROK_1
ROK_4
	CALL	LOAD_NAK
	CALL	PUT_BYTE
;
	LD	HL,M_S_NAK
	CALL	VDU_PUTS
	JP	RCV_LP
;
;******* End of Exmodem mods *******
;
ROK_5
	LD	HL,M_S_ACK	;send an ACK
	CALL	VDU_PUTS
	CALL	SEND_ACK
	CALL	F_CLOSE
	LD	HL,M_FINI
	CALL	QUIET_0
	RET			;go for next file.
;
INITIAL_NAK
	LD	A,(CRCMODE)
	OR	A
	LD	A,NAK
	JR	Z,INAK_1
	LD	A,CRCNAK
INAK_1
	CALL	PUT_BYTE
	RET
;
LOAD_NAK
	LD	A,(CRCMODE)
	OR	A
	LD	A,NAK
;;	RET	Z
	RET
	LD	A,CRCNAK
	RET
;
;Modem-7 receive filename gathering.
M7R_FILE
M7R_MR0
	LD	A,(M7_TRY)
	INC	A
	LD	(M7_TRY),A
	CP	20
	JR	Z,M7R_FAILED
	IN	A,(RDDATA)
	IN	A,(RDDATA)
	LD	A,NAK
	CALL	PUT_BYTE
M7R_MR1
	LD	B,5
	CALL	GET_BYTE
	JR	C,M7R_MR0
	CP	ACK
	JR	Z,M7R_MR2
	CP	EOT
	JR	Z,M7R_NOFILES
	JR	M7R_MR0
;
M7R_NOFILES
	LD	A,EOT
	SCF
	RET
;
M7R_FAILED
	XOR	A
	SCF
	CCF
	RET
;
M7R_MR2
	LD	HL,M7_FIELD
	LD	C,0
	LD	(HL),C
	LD	(M7_POSN),HL
M7R_1
	LD	B,1
	CALL	GET_BYTE
	JP	C,M7R_MR0
	CP	EOT
	JR	Z,M7R_NOFILES
	CP	SUB
	JR	Z,M7R_MR3
	CP	'u'
	JP	Z,M7R_MR0
	LD	HL,(M7_POSN)
	LD	(HL),A
	INC	HL
	LD	(M7_POSN),HL
	LD	(HL),0
	ADD	A,C
	LD	C,A
;
	LD	A,ACK
	CALL	PUT_BYTE
;
	JR	M7R_1
;
M7R_MR3
	ADD	A,C
	CALL	PUT_BYTE
;
	LD	B,1
	CALL	GET_BYTE
	JP	C,M7R_MR0
	CP	ACK
	JR	Z,M7R_2
	JP	M7R_MR0
;
;Fix the filename so its standard.
M7R_2
	LD	HL,M7_FIELD
	LD	DE,B_FILE
	LD	B,8
M7R_2A
	LD	A,(HL)
	CP	' '
	JR	Z,M7R_2B
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	M7R_2A
M7R_2B
	LD	HL,M7_FIELD+8
	LD	A,(HL)
	CP	' '
	JR	Z,M7R_2D
	LD	A,'.'	;Sep
	LD	(DE),A
	INC	DE
	LD	B,3
M7R_2C
	LD	A,(HL)
	CP	' '
	JR	Z,M7R_2D
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	M7R_2C
M7R_2D
	XOR	A
	LD	(DE),A
	SCF
	RET
;
SEND
	LD	HL,B_FILE
	LD	DE,FCB_1	;extract
	CALL	EXTRACT
	JR	Z,SEND_1
;
	LD	HL,M_ERROR
	CALL	LOG_2
	LD	HL,M_BDFL	;If bad extract (send)
	LD	DE,$2
	CALL	MESS_0
	RET			;loop to send next file.
;
SEND_1	LD	HL,BUFF_1	;File buffer.
	LD	DE,FCB_1	;FCB Address.
	LD	B,0H		;LRL=256.
	CALL	DOS_OPEN_EX
	JR	Z,AFF		;If file found
;Check if not existing.
	CP	18H		;de_fnid
	JR	NZ,IS_ERROR
;Special stuff....
	LD	HL,M_RECVNO
	CALL	LOG_2
	LD	HL,M_FNID
	LD	DE,$2
	CALL	MESS_0
	LD	A,20
	CALL	SEC10
	RET			;loop to next file.
;
IS_ERROR
	PUSH	AF
	LD	HL,M_ERROR
	CALL	LOG_2
	POP	AF
	JP	DOSERR
;
AFF				;check file access.
	LD	A,(FCB_1+1)	;must have read or better
	AND	7
	CP	6		;0=all,...6=exec,7=lock
	JR	NC,BUST_EM	;if exec|lock then bust.
;
	LD	A,(FCB_1+6)	;which drive is it on?
	CP	1		;The members only drive
	JR	NZ,AFF_2	;Anybody can send
	LD	A,(PRIV_2)
	BIT	IS_VISITOR,A	;check for visitor.
	JR	Z,AFF_2		;must not be visitor.
;ha! Stop this transfer!
BUST_EM
	LD	HL,M_BUSTED
	CALL	LOG_2
	LD	HL,M_CANNOT
	LD	DE,$2
	CALL	MESS_0
	LD	A,19H
	JR	IS_ERROR
;
AFF_2
;Print file send statistics...
	LD	A,(QUIET)
	OR	A
	CALL	Z,FILE_STATS
;
	CALL	CONFIG
;
	LD	E,100		;wait 100 seconds.
	CALL	INIT_AHC	;wait for NAK, CAN or 'C'
;
SND_LP	CALL	READ_BLK	;get block data
	JR	C,S_E_I		;if no blks to send
	CALL	INC_SNT		;inc sending block number
;
	XOR	A
	LD	(NNAKS),A	;zero NAK count
;
AFH	CALL	SEND_HDR	;print No & send header
	CALL	SEND_BLK
	CALL	SEND_CHECK
	CALL	AFX		;wait for ack,nak,can
	JR	C,AFH
	JR	SND_LP
;
S_E_I
;
	LD	A,(EX_FLAG)
	OR	A
	JR	Z,SND_EOT	;Not '-e' exmodem
;
	LD	HL,M_S_ENQ
	CALL	VDU_PUTS
	LD	A,ENQ
	CALL	PUT_BYTE	;send exmodem ENQ?
	CALL	AFX		;ack/nak/can check.
	JR	C,SND_EOT_FIRST	;if NAK or timeout.
	LD	HL,M_R_ACK
	CALL	VDU_PUTS
	LD	A,(FCB_1+8)
	AND	7FH
	JR	NZ,SEI_1
	OR	80H
SEI_1	LD	(EOFB),A
	CALL	PUT_BYTE
	LD	A,(EOFB)
	CPL
	CALL	PUT_BYTE
	CALL	AFX		;ack/nak/can check
	JR	C,S_E_I
;
	LD	HL,M_EXMODEM
	CALL	VDU_PUTS
;
	JR	S_E_2	;OK....
;
SND_EOT_FIRST
;;	LD	HL,M_NAK
;;	CALL	VDU_PUTS
;
SND_EOT
	XOR	A
	LD	(NNAKS),A
SND_EOT_0
	LD	HL,M_S_EOT
	CALL	VDU_PUTS
;
	LD	A,EOT
	CALL	PUT_BYTE
	CALL	POSS_ABRT
	CALL	AFX		;wait for ack,nak,can
	JR	NC,S_E_2	;if ACK.
	LD	A,(NNAKS)
	INC	A
	LD	(NNAKS),A
	CP	MAX_NAKS
	JR	NZ,SND_EOT_0
	JR	S_E_3
;
S_E_2
	LD	HL,M_R_ACK
	CALL	VDU_PUTS
S_E_3
	LD	HL,M_FINI
	CALL	QUIET_0
	RET			;go for more
;
GET_BLK	XOR	A
	LD	(NNAKS),A	;No of NAKs sent
AFL	LD	B,10	 	;wait 10 sec for SOH
	CALL	GET_BYTE
	JP	C,SEND_NAK	;if no char recvd
	CALL	POSS_ABRT
	OR	A
	JR	Z,AFL		;ignore padding zeroes.
	CP	SOH
	JR	Z,AFO		;Block header seen
	CP	16H		;SYN
	JP	Z,TL_HDR
	CP	CAN
	JP	Z,SNDR_CANCELS	;the sender cancels it.
	CP	EOT
	SCF	
	RET	Z		;scf & ret if EOT
;******* Start of Exmodem mods *******
	CP	ENQ
	SCF
	RET	Z		;scf & ret if ENQ
;******* End of Exmodem mods *******
	JP	SEND_NAK
;
AFO	LD	B,1H		;try to get block number
	CALL	GET_BYTE
	JP	C,SEND_NAK
	LD	(BLK1),A
	LD	B,1		;get inverse.
	CALL	GET_BYTE
	JP	C,SEND_NAK
	CPL	
	LD	D,A
	LD	A,(BLK1)
	CP	D
	JP	NZ,SEND_NAK
;
	LD	(BLK_RCV),A	;block # being received.
	LD	HL,DATABUF
	LD	B,128
AFQ	PUSH	BC
	LD	B,1
	CALL	GET_BYTE
	POP	BC
	JP	C,SEND_NAK	;if no char recvd
	LD	(HL),A
	INC	HL
	DJNZ	AFQ
;
	LD	A,(CRCMODE)
	OR	A
	JR	NZ,TRY_R_CRC
;Get, calculate, and compare an 8 bit checksum.
	LD	B,1H
	CALL	GET_BYTE	;recv checksum
	JP	C,SEND_NAK
	LD	(CHECKSUM),A
	CALL	CALC_SUM
	LD	D,A
	LD	A,(CHECKSUM)
	CP	D
	JR	Z,CHECK_SEQ
	JP	SEND_NAK
;
TRY_R_CRC
	LD	B,1
	CALL	GET_BYTE
	JP	C,SEND_NAK	;if none
	LD	(CRC_LOW+1),A
	LD	B,1
	CALL	GET_BYTE
	JP	C,SEND_NAK
	LD	(CRC_LOW),A	;backwards! msb first!
	CALL	CALC_CRC
	LD	DE,(CRC_LOW)
	OR	A
	SBC	HL,DE		;compare HL to (crc_low)
	JP	NZ,SEND_NAK	;if wrong
	JR	CHECK_SEQ
;
CHECK_SEQ
	LD	A,(BLK_RCV)	;block just received
	LD	B,A
	LD	A,(BLK_SNT)	;previous last block OK
	CP	B
	JR	Z,AFR		;if same ACK & discard
	INC	A
	CP	B
	JP	NZ,AGC		;abort if out of sequence
	RET			;store & ACK later.
;
AFR	CALL	SEND_ACK	;send ACK
	JP	GET_BLK		;throw away.
;
TL_HDR
	LD	B,131
TLH_1
	PUSH	BC
	LD	B,1
	CALL	GET_BYTE
	POP	BC
	DJNZ	TLH_1
	CALL	SEND_ACK
	JP	GET_BLK
