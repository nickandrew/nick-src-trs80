;ex300/asm: Extended xmodem protocol file transfer.
; Newdos-80 copy.
;
*GET	DOSCALLS
*GET	ASCII
;
TERMINATE	EQU	DOS
;
BASE	EQU	5200H
;UART equates...
RDDATA	EQU	0F8H
WRDATA	EQU	0F8H
RDSTAT	EQU	0F9H
WRSTAT	EQU	0F9H
DAV	EQU	1
CTS	EQU	0
;
;XMODEM protocol type equates...
SOH	EQU	01H
EOT	EQU	04H
ENQ	EQU	05H
ACK	EQU	06H
NAK	EQU	15H
CAN	EQU	18H
CRCNAK	EQU	'C'	;Initial NAK ala CRC mode
SUB	EQU	1AH	;Control char for modem7
;
;Constants
MAX_NAKS	EQU	0AH
MAX_BLOCKS	EQU	18H	;Was 14H.
;
	COM	'<Ex 1.10a 24-Dec-86>'
	ORG	BASE+100H
START	LD	SP,START
;
	PUSH	HL
	CALL	CHK_USAGE
	POP	HL
	JP	NZ,NO_PAR
;
	LD	A,(HL)
	CP	CR
	JP	Z,NO_PAR	;No parameters.
;
;Loop for sending or receiving to follow.....
	LD	A,'S'		;assume sending first
	LD	(B_TYPE),A
	XOR	A
	LD	(QUIET),A
	LD	(CRCMODE),A
	LD	(ARG),HL
	LD	(OVERWRITE),A
XFER_LOOP
	LD	HL,(ARG)
XL_01	LD	A,(HL)
	CP	CR
	JR	Z,XFER_FINI
	OR	A
	JR	Z,XFER_FINI
	CP	'-'
	JR	NZ,XFER_FILE
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
;flag unknown. bypass rest of flags
	CALL	BYP_WORD
	JR	XL_01
;
SET_DIRECTION
	LD	(B_TYPE),A
	INC	HL
	JR	XL_02
;
SET_QUIET
	LD	A,1
	LD	(QUIET),A
	INC	HL
	JR	XL_02
;
SET_CRC
	LD	A,1
	LD	(CRCMODE),A
	INC	HL
	JR	XL_02
;
SET_OVERWRITE
	LD	A,1
	LD	(OVERWRITE),A
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
	CALL	MESS_0
NP_01	LD	HL,M_S_OR_R	;cmd mode
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
;
NO_TRANSFER
	LD	A,0
EXIT_EXMF
	PUSH	AF
	CALL	CONFIG
	LD	A,10
	CALL	SEC10
	POP	AF
	JP	TERMINATE
;
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
	CP	'O'
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
;
;
	CALL	XFER_INIT
	CALL	START2
	JR	TELINK_RECV
;
START2
	LD	A,(B_TYPE)
	CP	'R'
	JP	NZ,SEND		;send if not 'R'
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
	CALL	DOS_EXTRACT
	JR	Z,RECV_0
;If bad extract
	LD	HL,M_ERROR
	CALL	MESS_0
	LD	HL,M_BDFL
	CALL	MESS_0
	LD	A,1		;bad filename on recv.
	JP	EXIT_EXMF
;
RECV_0
	LD	DE,FCB_1	;Try to open existing.
	LD	HL,BUFF_1	;Should fail.
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	Z,EXISTS
	CP	18H		;de_fnid
	JR	Z,GETDESC
	PUSH	AF
	LD	HL,M_ERROR
	CALL	MESS_0
	POP	AF		;unknown error on initial
	JP	DOSERR		;file open, receive.
;
;ask for description.
GETDESC
;
NODESC
	LD	HL,BUFF_1	;open new file for recv.
	LD	DE,FCB_1
	LD	B,0H
	CALL	DOS_OPEN_NEW
	JR	Z,AEZ
	PUSH	AF		;error opening RECV file
	LD	HL,M_ERROR
	CALL	MESS_0
	POP	AF
	JP	DOSERR		;error opening for RECV.
;
;
EXISTS				;recv file exists
	LD	A,(OVERWRITE)
	OR	A
	JR	Z,EXIST_1
	JR	AEZ		;accept it anyway.
EXIST_1
	LD	HL,M_SENDEX
	CALL	MESS_0
	LD	HL,M_EXISTS	;file already exists
	CALL	MESS_0
	LD	A,2
	JP	EXIT_EXMF
;
AEZ	LD	HL,M_RRDY	;file is now open OK.
	CALL	QUIET_0
;delay a bit.
	LD	A,50		;pre-initial NAK delay.
	CALL	SEC10
	CALL	CONFIG
;
;send initial NAK
	CALL	INITIAL_NAK
;
	CALL	POSS_ABRT
;
RCV_LP	CALL	AFK		;get block
	JR	C,RCV_OK	;if EOT
	CALL	WRITE_BLK	;Store
	CALL	INC_SNT		;inc send block number
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
	LD	HL,M_ENQ	;signal enq ACK
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
	JR	RCV_LP
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
M7R_2A	LD	A,(HL)
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
	LD	A,'/'
	LD	(DE),A
	INC	DE
	LD	B,3
M7R_2C	LD	A,(HL)
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
;
;
;
SEND	LD	HL,M_SENDING
	CALL	QUIET_0
	LD	HL,B_FILE
	CALL	QUIET_0
	LD	A,CR
	CALL	QUIET_PUT
;
	LD	HL,B_FILE
	LD	DE,FCB_1	;extract
	CALL	DOS_EXTRACT
	JR	Z,SEND_1
;
	LD	HL,M_ERROR
	CALL	MESS_0
	LD	HL,M_BDFL	;If bad extract (send)
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
	CALL	MESS_0
	LD	HL,M_FNID
	CALL	MESS_0
	LD	A,20
	CALL	SEC10
	RET			;loop to next file.
;
IS_ERROR
	PUSH	AF
	LD	HL,M_ERROR
	CALL	MESS_0
	POP	AF
	JP	DOSERR
;
AFF				;check file access.
	LD	A,(FCB_1+1)	;must have read or better
	AND	7
	CP	6		;0=all,...6=exec,7=lock
	JR	NC,BUST_EM	;if exec|lock then bust.
	JR	AFF_2		;anybody can send stuff
				;on drive 2
;ha! Stop this transfer!
BUST_EM
	LD	HL,M_BUSTED
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
SND_LP	CALL	READ_BLK		;get block data
	JR	C,S_E_I		;if no blks to send
	CALL	INC_SNT		;inc sending block number
	XOR	A
	LD	(NNAKS),A	;zero NAK count
AFH	CALL	SEND_HDR	;print No & send header
	CALL	SEND_BLK
	CALL	SEND_CHECK
	CALL	AFX		;wait for ack,nak,can
	CALL	C,SHOW_NAK	;Show if a NAK seen.
	JR	C,AFH
	JR	SND_LP
;
;******* Start of Exmodem mods *******
S_E_I
;
	LD	HL,M_S_ENQ
	CALL	VDU_PUTS
	LD	A,ENQ
	CALL	PUT_BYTE	;send exmodem ENQ?
	CALL	AFX		;ack/nak/can check.
	JR	C,SND_EOT_FIRST	;if NAK or timeout.
	LD	HL,M_ACK
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
	CALL	AFX
	JR	C,S_E_I
;
	LD	HL,M_EXMODEM
	CALL	VDU_PUTS
;
	JR	S_E_2	;OK....
;
;******* End of Exmodem mods *******
;
SND_EOT_FIRST
	LD	HL,M_NAK
	CALL	VDU_PUTS
;
SND_EOT
	LD	HL,M_S_EOT
	CALL	VDU_PUTS
;
	LD	A,EOT
	CALL	PUT_BYTE
	CALL	POSS_ABRT
	CALL	AFX		;wait for ack,nak,can
	JR	NC,S_E_2	;if ACK.
	JR	SND_EOT	;another go
;
;
S_E_2
	LD	HL,M_ACK
	CALL	VDU_PUTS
	LD	HL,M_FINI
	JP	MSG_EX
;
AFK	XOR	A
	LD	(NNAKS),A	;No of NAKs sent
	LD	A,(BLK_SNT)
	INC	A
	CALL	BLK_NUMB	;expect to recv next blk
AFL	LD	B,0AH	 	;wait 10 sec for SOH
	CALL	GET_BYTE
	JR	C,AFM		;if no char recvd
	CALL	POSS_ABRT
	CP	SOH
	JR	Z,AFO
	OR	A
	JR	Z,AFL		;ignore padding zeroes.
				;but why???
	CP	CAN
	JR	Z,SNDR_CANCELS	;the sender cancels it.
	CP	EOT		;scf & ret if EOT
	SCF	
	RET	Z
;******* Start of Exmodem mods *******
	CP	ENQ
	SCF
	RET	Z
;******* End of Exmodem mods *******
;
CHECK_BAD
AFM	LD	B,1H		;wait for no chars recvd.
	CALL	GET_BYTE
	CALL	POSS_ABRT
	JR	NC,AFM
	CALL	LOAD_NAK
	CALL	PUT_BYTE
;
	LD	HL,M_S_NAK
	CALL	VDU_PUTS
	LD	A,(NNAKS)	;increment NAK count
	INC	A
	LD	(NNAKS),A
	CP	MAX_NAKS
	JR	C,AFL		;try again.
;I cancel.
	CALL	AGD		;send CAN codes
	JP	AHD
;
SNDR_CANCELS
;the sender cancels the transfer, or the receiver (me)
;sends 10 NAKs in a row.
	LD	HL,M_CAN
	CALL	VDU_PUTS
	LD	HL,M_CAN_HIM	;He cancels
	CALL	VDU_PUTS
	CALL	AGD		;send CAN codes
	JP	AHD		;aborted.
;
AFO	LD	B,1H		;try to get block number
	CALL	GET_BYTE
	JR	C,AFM
	LD	(CRCBLK1),A
	LD	D,A
	LD	B,1H		;get inverse.
	CALL	GET_BYTE
	JR	C,AFM
	LD	(CRCBLK2),A
	CPL	
	CP	D
	JR	NZ,AFM
;
AFP	LD	A,D
	LD	(BLK_RCV),A	;block # being received.
	LD	C,0H
	LD	HL,DATABUF
	LD	B,128
AFQ	PUSH	BC
	LD	B,1
	CALL	GET_BYTE
	LD	D,C		;save checksum
	POP	BC
	LD	C,D		;restore
	JP	C,AFM		;if no char recvd
	LD	(HL),A
	INC	HL
	DJNZ	AFQ
;Calculate the checksum
	LD	HL,DATABUF
	LD	B,128
	XOR	A
AFQ_1	ADD	A,(HL)
	INC	HL
	DJNZ	AFQ_1
;;	LD	D,A
;;	LD	D,C
;
;;	LD	A,C		;a is checksum
	LD	(CHECKSUM),A
;
	LD	A,(CRCMODE)
	OR	A
	JR	NZ,TRY_R_CRC
	LD	B,1H
	CALL	GET_BYTE	;recv checksum
	JP	C,AFM
	LD	D,A
	LD	A,(CHECKSUM)
	CP	D
	JR	Z,CHECK_OK
	JP	CHECK_BAD
TRY_R_CRC
	LD	B,1
	CALL	GET_BYTE
	JP	C,AFM		;if none
	LD	(CRC_LOW+1),A
	LD	B,1
	CALL	GET_BYTE
	JP	C,AFM
	LD	(CRC_LOW),A	;backwards! msb first!
	CALL	FIND_CRC
	LD	DE,(CRC_LOW)
	OR	A
	SBC	HL,DE		;compare HL to (crc_low)
	JP	NZ,AFM		;if wrong
CHECK_OK
	LD	A,(BLK_RCV)	;block just received
	LD	B,A
	LD	A,(BLK_SNT)	;previous last block OK
	CP	B
	JR	Z,AFR		;if same ACK & discard
	INC	A
	CP	B
	JP	NZ,AGC		;abort if out of sequence
	RET	
;
AFR	CALL	SEND_ACK	;send ACK
	JP	AFK		;throw away.
;
SEND_ACK
	LD	A,ACK
	CALL	PUT_BYTE
	RET	
;
SEND_HDR
	LD	A,(BLK_SNT)
	CALL	BLK_NUMB	;print block number
	LD	A,SOH
	CALL	PUT_BYTE	;send SOH
	LD	A,(BLK_SNT)
	LD	(CRCBLK1),A
	CALL	PUT_BYTE	;send BLOCK number
	LD	A,(BLK_SNT)
	CPL			;send complement.
	LD	(CRCBLK2),A
	CALL	PUT_BYTE
	RET	
;
SEND_BLK
	LD	C,0H
	LD	HL,DATABUF
	LD	B,80H
AFV	LD	A,(HL)
	CALL	PUT_BYTE
	INC	HL
	DJNZ	AFV
	CALL	POSS_ABRT
	RET	
;
SEND_CHECK
	LD	A,(CRCMODE)
	OR	A
	JR	NZ,SEND_CRC
	XOR	A
	LD	HL,DATABUF
	LD	B,80H
SC_01	ADD	A,(HL)
	INC	HL
	DJNZ	SC_01
	CALL	PUT_BYTE
	CALL	POSS_ABRT	;check if abort desired.
	RET	
SEND_CRC
	CALL	FIND_CRC
	PUSH	HL
	LD	A,H		;backwards! msb first!
	CALL	PUT_BYTE
	POP	HL
	LD	A,L		;backwards!
	CALL	PUT_BYTE
	CALL	POSS_ABRT
	RET
;
AFX	LD	B,10		;wait 10 sec
	CALL	GET_BYTE
	CALL	POSS_ABRT
	JR	C,AFY
	CP	ACK
	RET	Z
	CP	CAN
	JP	Z,HE_RCVR_CANS
AFY	LD	A,(NNAKS)
	INC	A
	LD	(NNAKS),A
	CP	MAX_NAKS
	RET	C
;
	LD	HL,M_10_NAKS
	CALL	VDU_PUTS
	JR	AGC
;
KEY_ABRT
	PUSH	AF		;abort if break hit.
	LD	A,(3840H)
	BIT	02H,A
	JR	NZ,KA_001
	POP	AF
	RET	
;
KA_001	LD	A,1
	LD	(XFABRT),A
	POP	AF
	RET
;
POSS_ABRT
	PUSH	AF
	LD	A,(XFABRT)
	OR	A
	JR	NZ,PA_001
	POP	AF
	RET
;
PA_001	POP	AF
AGC
	LD	HL,M_CAN_WHO
	CALL	VDU_PUTS
	CALL	AGD
	JP	AHD
;
;I'm sending and HE cancels the transfer.
HE_RCVR_CANS
	LD	HL,M_CAN
	CALL	VDU_PUTS
	CALL	AGD
	JP	AHD
;
AGD	CALL	WAIT_ONE	;wait for no chars
	LD	A,CAN
	CALL	PUT_BYTE
	LD	HL,M_S_CAN
	CALL	VDU_PUTS
	CALL	WAIT_ONE
	LD	A,CAN		;send another
	CALL	PUT_BYTE
	RET
;
WAIT_ONE
	LD	B,1
	CALL	GET_BYTE
	RET	C
	JR	WAIT_ONE
;
INC_SNT	LD	A,(BLK_SNT)
	INC	A
	LD	(BLK_SNT),A
	RET	
;
F_CLOSE
	LD	DE,FCB_1
	CALL	DOS_CLOSE
	RET	Z
	PUSH	AF
	LD	HL,M_ERROR
	CALL	MESS_0
	POP	AF
	JP	DOSERR
;
READ_BLK	LD	A,(BLK_STORED)
	DEC	A
	LD	(BLK_STORED),A
	JP	M,AGI
	LD	HL,(AID)
	LD	DE,DATABUF
	CALL	MV_128
	LD	(AID),HL
	RET	
;
AGI	LD	A,(FIL_EOF)
	CP	1H
	SCF	
	RET	Z
				;This is the READ file.
	LD	C,0H
	LD	DE,BIG_BUFF
AGJ	LD	B,80H
AGK	PUSH	DE
	LD	DE,FCB_1
	CALL	$GET
	POP	DE
	JR	Z,AGL
	CP	1CH
	JR	Z,AGM
	PUSH	AF
	CALL	AGD		;cancel
	LD	HL,M_ERROR
	CALL	MESS_0
	POP	AF
	CALL	DISP_DOS_ERROR
	JP	AHD
;
AGL	LD	(DE),A
	INC	DE
	DJNZ	AGK
	INC	C
	LD	A,C
	CP	MAX_BLOCKS
	JP	Z,AGP
	JR	AGJ
;
AGM	LD	A,B
	CP	80H
	JR	Z,AGO
	XOR	A
AGN	LD	(DE),A
	INC	DE
	DJNZ	AGN
	INC	C
AGO	LD	A,1H
	LD	(FIL_EOF),A
	LD	A,C
AGP	LD	(BLK_STORED),A
	LD	HL,BIG_BUFF
	LD	(AID),HL
	JP	READ_BLK
;
WRITE_BLK	LD	HL,(AID)
	EX	DE,HL
	LD	HL,DATABUF
	CALL	MV_128
	EX	DE,HL
	LD	(AID),HL
	LD	A,(BLK_STORED)
	INC	A
	LD	(BLK_STORED),A
	CP	MAX_BLOCKS
	RET	NZ
AGR	LD	A,(BLK_STORED)
	OR	A
	RET	Z
	LD	C,A
	LD	DE,BIG_BUFF
AGS	LD	B,80H
AGT	PUSH	DE
	LD	A,(DE)
	LD	DE,FCB_1
	CALL	$PUT
	POP	DE
	JR	Z,AGU
	PUSH	AF
	CALL	AGD		;cancel sent
	LD	HL,M_ERROR
	CALL	MESS_0
	POP	AF
	CALL	DISP_DOS_ERROR
	JP	AHD
;
AGU	INC	DE
	DJNZ	AGT
	DEC	C
	JP	NZ,AGS
	XOR	A
	LD	(BLK_STORED),A
	LD	HL,BIG_BUFF
	LD	(AID),HL
	RET	
;
;Carry flag is set if there is a timeout.
GET_BYTE
	PUSH	DE
GB_1	LD	D,40		;=1 sec
	LD	A,(TICKER)
	LD	E,A
	CALL	KEY_ABRT	;if abort
GB_2
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
	SCF	
	RET	
;
GB_4	IN	A,(RDDATA)
	PUSH	AF
;;	ADD	A,C
;;	LD	C,A
	POP	AF
	POP	DE
	OR	A
	RET
;
AHC	CALL	KEY_ABRT
	CALL	POSS_ABRT
	LD	B,1H
	CALL	GET_BYTE
	JR	C,AHC_1
	CP	NAK
	RET	Z
	CP	CAN
	JP	Z,AGC
AHC_1	DEC	E
	JP	Z,AGC
	JR	AHC
;
INIT_AHC
	CALL	KEY_ABRT
	CALL	POSS_ABRT
	LD	B,1H
	CALL	GET_BYTE
	JR	C,IAHC_1
	CP	NAK
	RET	Z
	CP	CAN
	JP	Z,AGC
	CP	CRCNAK
	JR	NZ,IAHC_1
	LD	A,1
	LD	(CRCMODE),A
	LD	A,NAK		;to fool the rest
	CP	A
	RET
IAHC_1	DEC	E
	JP	Z,AGC
	JR	INIT_AHC
;
AHD				;filexfer aborted exit.
	LD	HL,M_ABORTED
	CALL	MESS_0
	LD	A,(B_TYPE)
	CP	'R'
	JR	NZ,AHD_2
;
	LD	DE,FCB_1	;Kill bad file
	CALL	DOS_KILL
	JR	Z,K_OK
	CALL	DISP_DOS_ERROR
;
K_OK	LD	HL,M_KILLED
	CALL	MESS_0
;
AHD_2
	LD	HL,M_ABRT
;File transfer aborted. forget the rest of the requests.
	CALL	QUIET_0
	LD	A,8
	JP	EXIT_EXMF
;
;
MSG_EX	PUSH	HL
	LD	A,20
	CALL	SEC10
	POP	HL
	CALL	MESS_0
	RET		;back to xfer_loop....
;
;
QUIET_0	LD	A,(QUIET)
	OR	A
	CALL	Z,MESS_0
	RET
QUIET_PUT
	PUSH	BC
	LD	B,A
	LD	A,(QUIET)
	OR	A
	LD	A,B
	CALL	Z,$PUT
	POP	BC
	RET
;
BLK_NUMB
	PUSH	DE
	PUSH	BC
	PUSH	AF
	CALL	KEY_ABRT
	CALL	POSS_ABRT
;
	POP	AF
	PUSH	AF
	RRCA			;Print hex block number.
	RRCA
	RRCA
	RRCA
	LD	DE,MSGBLK	;buffer.
	CALL	TO_HEX
	POP	AF
	LD	DE,MSGBLK+1	;buffer+1.
	CALL	TO_HEX
;
	LD	HL,MSGBLK
	CALL	VDU_PUTS
;
	POP	BC
	POP	DE
	RET	
;
SHOW_NAK
	PUSH	HL
	PUSH	AF
	LD	HL,M_NAK
	CALL	VDU_PUTS
	POP	AF
	POP	HL
	RET	
;
TO_HEX	AND	0FH
	CP	0AH
	JR	C,TH_1
	ADD	A,7
TH_1	ADD	A,'0'
	PUSH	DE
	PUSH	BC
	LD	(DE),A		;to screen.
	POP	BC
	POP	DE
	RET	
;
MV_128	LD	B,80H		;128 byte block move.
MV_2	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	B
	JR	NZ,MV_2
	RET	
;
CONFIG
	PUSH	AF
	LD	A,82H
	OUT	(WRSTAT),A
	LD	A,40H
	OUT	(WRSTAT),A
	LD	A,0FH		;1 stop, 300 baud.
	OUT	(WRSTAT),A
	LD	A,05H
	OUT	(WRSTAT),A
	POP	AF
	RET
;
FILE_STATS			;print file length etc..
	LD	HL,M_SRDY	;Ready to send
	CALL	MESS_0
	LD	HL,FCB_1+12
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	ADD	HL,HL		;*2
	EX	DE,HL		;into DE
	LD	A,(FCB_1+8)
	OR	A
	JR	Z,NUM_SECT	;is correct.
	INC	DE		;+1 for byte 0..
	DEC	A
	AND	80H
	JR	Z,NUM_SECT
	INC	DE		;+1 for byte 80h
NUM_SECT
	PUSH	DE
	EX	DE,HL
	LD	DE,STRING
	CALL	SPUTNUM
	LD	HL,STRING
	CALL	MESS_0
;
	LD	HL,M_SRDY2
	CALL	MESS_0
;
	POP	HL
	PUSH	HL
	ADD	HL,HL		;*2
	ADD	HL,HL		;*4
	POP	DE
	ADD	HL,DE		;*5.
	LD	BC,60		;60 sec in a minute.
	LD	DE,0
MIN_LP	OR	A
	INC	DE
	SBC	HL,BC
	JR	NC,MIN_LP
	DEC	DE
	ADD	HL,BC
	LD	A,L
	OR	A
	JR	Z,MIN_2
	INC	DE
MIN_2
	EX	DE,HL
	LD	DE,STRING
	CALL	SPUTNUM
	LD	HL,STRING
	CALL	MESS_0
;
	LD	HL,M_SRDY3
	CALL	MESS_0
	RET
;
;send character
PUT_BYTE
	PUSH	AF
	CALL	KEY_ABRT	;check if abort reqd.
;;	ADD	A,C
;;	LD	C,A
BS_1
	IN	A,(RDSTAT)
	BIT	CTS,A
	JR	Z,BS_1
BS_2
	POP	AF
	OUT	(WRDATA),A
	RET
;
FIND_CRC
	LD	HL,0
	LD	(OLD_CRC),HL
	LD	HL,DATABUF
	LD	B,130
FC_01	LD	A,(HL)
	INC	HL
	PUSH	HL
	PUSH	BC
	LD	HL,(OLD_CRC)
	LD	C,A
	LD	B,8
FC_02	LD	A,C
	RLCA
	LD	C,A
	LD	A,L
	RLA
	LD	L,A
	LD	A,H
	RLA
	LD	H,A
	JR	NC,FC_03
	LD	A,H
	XOR	10H
	LD	H,A
	LD	A,L
	XOR	21H
	LD	L,A
FC_03
	LD	(OLD_CRC),HL
	DJNZ	FC_02
	POP	BC
	POP	HL
	DJNZ	FC_01
	LD	HL,(OLD_CRC)
	RET
;
DOSERR	PUSH	AF
	CALL	CONFIG
	LD	A,30
	CALL	SEC10		;token delay
	POP	AF
	PUSH	AF
	CALL	DISP_DOS_ERROR
	POP	AF
	OR	80H
	JP	EXIT_EXMF
;
DISP_DOS_ERROR
	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	RET
;
;
MESS_NOCR
	LD	A,(HL)
	CP	ETX
	RET	Z
	CP	CR
	RET	Z
	OR	A
	RET	Z
	CALL	$$PUT
	INC	HL
	JR	MESS_NOCR
;
$$PUT	JP	33H
MESS_0	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$$PUT
	INC	HL
	JR	MESS_0
;Get useful routines.
;SPUTNUM: Put a decimal integer into a string.
	IFREF	SPUTNUM
SPUTNUM:
	LD	(_SPPOS),DE
	XOR	A
	LD	(_SPBLANK),A
	LD	DE,10000
	CALL	_SP_DIGIT
	LD	DE,1000
	CALL	_SP_DIGIT
	LD	DE,100
	CALL	_SP_DIGIT
	LD	DE,10
	CALL	_SP_DIGIT
	LD	(_SPTENS),A
	LD	DE,1
	LD	A,E
	LD	(_SPBLANK),A
	CALL	_SP_DIGIT
	LD	(_SPONES),A
	XOR	A
	LD	DE,(_SPPOS)
	LD	(DE),A		;null terminator
	RET
;
_SP_DIGIT
	LD	B,'0'-1
_SP1	INC	B
	OR	A
	SBC	HL,DE
	JR	NC,_SP1
	ADD	HL,DE
	LD	A,(_SPBLANK)
	OR	A
	JR	NZ,_SP2
	LD	A,B
	CP	'0'
	RET	Z
_SP2	LD	(_SPBLANK),A
	LD	A,B
	LD	DE,(_SPPOS)
	LD	(DE),A
	INC	DE
	LD	(_SPPOS),DE
	RET
;
_SPBLANK	DEFB	0
_SPTENS		DEFB	0
_SPONES		DEFB	0
_SPPOS		DEFW	0
;
	ENDIF	SPUTNUM
;
	IFREF	SEC10
SEC10:		;Wait 'B'x 0.1 seconds
	PUSH	BC
S1_1	PUSH	AF
	LD	A,(TICKER)
	LD	C,A
	LD	B,4
S1_2	LD	A,(TICKER)
	CP	C
	LD	C,A
	JR	Z,S1_2
	DJNZ	S1_2
	POP	AF
	DEC	A
	JR	NZ,S1_1
	POP	BC
	RET
	ENDIF	SEC10
;
;
;Special values for CRC implementation.
QUIET	DEFB	0		;Quiet flag
OVERWRITE DEFB	0		;O/write existing file
CRCMODE	DEFB	0		;1=In CRC mode
TELINK	DEFB	0		;1=In Telink mode
CRC_LOW	DEFW	0		;CRC as received
OLD_CRC	DEFW	0		;CRC calculated.
CHECKSUM DEFB	0		;Checksum calculated
;
M_S_ACK	DEFM	'ACK ',0
M_S_ENQ	DEFM	'ENQ ',0
M_ENQ	DEFM	'enq ',0
M_EXMODEM
	DEFM	'Exmodem! ',0
M_S_EOT	DEFM	'EOT ',0
M_ACK	DEFM	'ack ',0
M_S_NAK	DEFM	'NAK ',0
M_NAK	DEFM	'nak ',0
M_S_CAN	DEFM	'CAN ',0
M_CAN	DEFM	'can ',0
M_CAN_WHO
	DEFM	'(Someone cancels) ',0
M_CAN_HIM
	DEFM	'(He cancels) ',0
M_10_NAKS
	DEFM	'(he sends too many naks) ',0
;
ARG	DEFW	0
NEWARG	DEFW	0
M7_TRY	DEFB	0
M7_POSN	DEFW	0
M7_FIELD DEFS	11	;FFFFFFFFeee
;
M_RECVNG
	DEFM	'xmf: receiving file ',0
M_SENDING
	DEFM	'xmf: sending file ',0
;
M_USAGE	DEFM	CR
	DEFM	'xmf:   Illegal arguments given. Usage is:',CR
	DEFM	'Single file interactive mode:   XMF',CR
	DEFM	'For multi file send/receive mode:',CR
	DEFM	'     XMF [-s files ...] [-r files ...]',CR,CR
	DEFM	'Putting you into interactive mode now:',CR,0
M_BDFL	DEFM	'Illegal Filename for a Zeta file!',CR
	DEFM	'Use a name like ABCDEFGH/EXT',CR,0
M_ABRT	DEFM	CR,'>> File transfer aborted! <<',CR,CR,0
M_SRDY	DEFM	CR,'File found. Length is ',0
M_SRDY2	DEFM	' Blocks. Transfer time approx. ',0
M_SRDY3	DEFM	' min.',CR,0
;
M_RRDY	DEFM	CR,'Ready to receive file - start your XMODEM module',CR,0
M_EXISTS	DEFM	'That filename already exists',CR
	DEFM	'Upload with a different name',CR,0
M_FINI
	DEFM	CR,'File transfer Completed.',CR,CR,0
M_BLK	DEFM	CR,'Block Number:   ',0
M_KILLED
	DEFM	'XMF killed file',CR,0
M_ABORTED
	DEFM	'<Aborted....>',CR,0
M_BUSTED
	DEFM	'<Busted.....>',CR,0
M_SENDEX
	DEFM	'<Exists.....>',CR,0
M_RECVNO
	DEFM	'<Nonexistant>',CR,0
M_ERROR	DEFM	'<Dos Error..>',CR,0
M_DISAL	DEFM	'<Disallowed.>',CR,0
M_FNID
	DEFM	'File requested not in directory.',CR
	DEFM	'May be on a different (not mounted) disk',CR
	DEFM	'Do "DIR" for a list of available files.',CR,0
M_S_OR_R
	DEFM	'Tell Zeta to Send or Receive file (S or R): ',0
M_FILE	DEFM	'Filename? ',0
M_SIGNON	DEFM	CR,'xmf: EXmodem File Transfer utility',CR
	DEFM	'Christensen protocol transfers.',CR
	DEFM	'usage is: xmf [-s files ...] [-r files ...]',CR,CR,0
M_NOVIS	DEFM	CR,'Sorry, you need to be a MEMBER to Send files.',CR,0
;
;This must come immediately before DATABUF.
CRCBLK1	DEFB	0
CRCBLK2	DEFB	0
DATABUF	DC	80H,0		;Block buffer.
	DEFW	0		;Must be imm. after DATABUF
;
AID	DEFW	BIG_BUFF	;Current read/write addr.
BLK_RCV	DEFB	0		;block # being received
BLK_SNT	DEFB	0		;block # being sent
NNAKS	DEFB	0		;number of NAKs sent
FIL_EOF	DEFB	0		;1=no more blks to read
BLK_STORED	DEFB	0	;# blocks stored
XFABRT		DEFB	0	;flag 1=abort desired.
EOFB		DEFB	0	;EOF value 1-128 of blk.
;
M_DOCU	DEFM	'Want to document this upload for Zeta''s file catalog? ',0
;
M_NODOCU
	DEFM	'Whoops ... can''t run doc program',CR,0
DOCUM	DEFM	'Document '
DOC_FIL	DC	32,0
;
FCB_1	DEFS	32		;FCB.
BUFF_1	DEFS	256		;File Buffer...
;
FCB_LOG	DEFM	'XFERLOG/ZMS',CR
	DC	32-12,0
BUFF_LOG DEFS	256
;
B_DATE	DEFM	'DD-MMM-YY '
B_TIME	DEFM	'HH:MM:SS ',0
;
B_TYPE	DEFM	'S '
B_FILE	DEFM	'abcdefgh/xyz.password:1',CR,0
;
MSGBLK	DEFM	'xx  ',0
;
STRING	DEFS	64
;
IN_BUFF	DC	64,0
;
BIG_BUFF
	NOP
;
	END	START
