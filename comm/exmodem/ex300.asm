;ex300/asm: Extended xmodem protocol file transfer.
; Newdos-80 copy.
;
*GET	DOSCALLS
*GET	ASCII
;
TERMINATE	EQU	DOS
BASE		EQU	5200H
;
;UART equates...
RDDATA	EQU	0F8H
WRDATA	EQU	0F8H
RDSTAT	EQU	0F9H
WRSTAT	EQU	0F9H
DAV	EQU	1
CTS	EQU	0
;
;XMODEM protocol type equates...
ASC_SOH	EQU	01H
ASC_EOT	EQU	04H
ASC_ENQ	EQU	05H
ASC_ACK	EQU	06H
ASC_NAK	EQU	15H
ASC_CAN	EQU	18H
CRCNAK	EQU	'C'	;Initial NAK ala CRC mode
ASC_SUB	EQU	1AH	;Control char for modem7
;
;Constants
MAX_NAKS	EQU	0AH
MAX_BLOCKS	EQU	18H	;Was 14H.
;
	COM	'<Ex 1.10b 12-Jan-87>'
	ORG	BASE+100H
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
	JR	Z,XFER_FINI
	OR	A
	JR	Z,XFER_FINI
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
	CALL	MESS_0_VDU
NP_01	LD	HL,M_S_OR_R	;cmd mode
	CALL	MESS_0_VDU
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
	CALL	MESS_0_VDU
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
	CALL	CONFIG
;;	LD	A,10
;;	CALL	SEC10
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
	CALL	MESS_0_VDU
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
	CP	ASC_EOT
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
	CALL	DOS_EXTRACT
	JR	Z,RECV_0
;If bad extract
	LD	HL,M_ERROR
	CALL	MESS_0_VDU
	LD	HL,M_BDFL
	CALL	MESS_0_VDU
	LD	A,1		;bad filename on recv.
	JP	EXIT_EXMF
;
RECV_0
	LD	DE,FCB_1	;Try to open existing.
	LD	HL,BUFF_1
	LD	B,0
	CALL	DOS_OPEN_EX	;Should fail.
	JP	Z,EXISTS
	CP	18H		;de_fnid
	JR	Z,GETDESC
	PUSH	AF
	LD	HL,M_ERROR
	CALL	MESS_0_VDU
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
	CALL	MESS_0_VDU
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
	JR	AEZ		;accept it anyway.
EXIST_1
	LD	HL,M_SENDEX
	CALL	MESS_0_VDU
	LD	HL,M_EXISTS	;file already exists
	CALL	MESS_0_VDU
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
	CALL	INITIAL_NAK	;Send initial NAK
;
	CALL	POSS_ABRT
;
RCV_LP	CALL	GET_BLK		;get block
	JR	C,RCV_OK	;if EOT
	XOR	A
	LD	(FIRST_BLK),A
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
	CP	ASC_ENQ
	JR	NZ,ROK_3
	LD	A,ASC_ACK
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
	LD	A,ASC_NAK
	JR	Z,INAK_1
	LD	A,CRCNAK
INAK_1
	CALL	PUT_BYTE
	RET
;
LOAD_NAK
	LD	A,(CRCMODE)
	OR	A
	LD	A,ASC_NAK
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
	LD	A,ASC_NAK
	CALL	PUT_BYTE
M7R_MR1
	LD	B,5
	CALL	GET_BYTE
	JR	C,M7R_MR0
	CP	ASC_ACK
	JR	Z,M7R_MR2
	CP	ASC_EOT
	JR	Z,M7R_NOFILES
	JR	M7R_MR0
;
M7R_NOFILES
	LD	A,ASC_EOT
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
	CP	ASC_EOT
	JR	Z,M7R_NOFILES
	CP	ASC_SUB
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
	LD	A,ASC_ACK
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
	CP	ASC_ACK
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
	LD	A,'/'
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
	CALL	MESS_0_VDU
	LD	HL,M_BDFL	;If bad extract (send)
	CALL	MESS_0_VDU
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
	CALL	MESS_0_VDU
	LD	HL,M_FNID
	CALL	MESS_0_VDU
	LD	A,20
	CALL	SEC10
	RET			;loop to next file.
;
IS_ERROR
	PUSH	AF
	LD	HL,M_ERROR
	CALL	MESS_0_VDU
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
	CALL	MESS_0_VDU
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
	LD	HL,M_S_ENQ
	CALL	VDU_PUTS
	LD	A,ASC_ENQ
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
	LD	HL,M_NAK
	CALL	VDU_PUTS
;
SND_EOT
	LD	HL,M_S_EOT
	CALL	VDU_PUTS
;
	LD	A,ASC_EOT
	CALL	PUT_BYTE
	CALL	POSS_ABRT
	CALL	AFX		;wait for ack,nak,can
	JR	NC,S_E_2	;if ACK.
	JR	SND_EOT		;another go
;
;
S_E_2
	LD	HL,M_R_ACK
	CALL	VDU_PUTS
	LD	HL,M_FINI
	CALL	QUIET_0
	RET			;go for more
;
GET_BLK	XOR	A
	LD	(NNAKS),A	;No of NAKs sent
	LD	A,(BLK_SNT)	;Next block to receive.
	INC	A
	CALL	BLK_NUMB	;print it in hex.
AFL	LD	B,10		;wait 10 sec for SOH
	CALL	GET_BYTE
	JR	C,SEND_NAK	;if no char recvd
	CALL	POSS_ABRT
	OR	A
	JR	Z,AFL		;ignore padding zeroes.
				;but why???
	CP	ASC_SOH
	JR	Z,AFO
	CP	ASC_CAN
	JP	Z,SNDR_CANCELS	;the sender cancels it.
	CP	ASC_EOT		;scf & ret if EOT
	SCF	
	RET	Z
;******* Start of Exmodem mods *******
	CP	ASC_ENQ
	SCF
	RET	Z
;******* End of Exmodem mods *******
;
SEND_NAK
	LD	B,1H		;wait for no chars recvd.
	CALL	GET_BYTE
	CALL	POSS_ABRT
	JR	NC,SEND_NAK
;
;Send "C" if CRC && first block && nnaks<5
	LD	A,(CRCMODE)
	OR	A
	JR	NZ,SN_2
SN_1	LD	A,ASC_NAK
	CALL	PUT_BYTE
	JR	SN_5
SN_2
	LD	A,(FIRST_BLK)
	OR	A
	JR	Z,SN_1		;send ordinary NAK
	LD	A,(NNAKS)
	CP	5
	JR	NC,SN_1
SN_3	LD	A,CRCNAK
	CALL	PUT_BYTE
SN_5
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
AFO	LD	B,1H		;try to get block number
	CALL	GET_BYTE
	JR	C,SEND_NAK
	LD	(BLK1),A
	LD	B,1		;get inverse.
	CALL	GET_BYTE
	JR	C,SEND_NAK
	CPL	
	LD	D,A
	LD	A,(BLK1)
	CP	D
	JR	NZ,SEND_NAK
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
	RET	
;
AFR	CALL	SEND_ACK	;send ACK
	JP	GET_BLK		;throw away.
;
SEND_ACK
	LD	A,ASC_ACK
	CALL	PUT_BYTE
	RET	
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
SEND_HDR
	LD	A,(BLK_SNT)
	CALL	BLK_NUMB	;print block number
	LD	A,ASC_SOH
	CALL	PUT_BYTE	;send SOH
	LD	A,(BLK_SNT)
	CALL	PUT_BYTE	;send BLOCK number
	LD	A,(BLK_SNT)
	CPL			;send complement.
	CALL	PUT_BYTE
	RET	
;
SEND_BLK
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
	CALL	CALC_SUM
	CALL	PUT_BYTE
	CALL	POSS_ABRT	;check if abort desired.
	RET	
SEND_CRC
	CALL	CALC_CRC
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
	LD	HL,M_TIME2
	JR	C,AFY
	CP	ASC_ACK
	RET	Z
	CP	ASC_CAN
	JP	Z,HE_RCVR_CANS
	CP	ASC_NAK
	JR	Z,AFY_0
	CP	CRCNAK
	JR	Z,AFY_1
	JR	AFX
;
AFY_0
	LD	HL,M_NAK
	JR	AFY
AFY_1	LD	HL,M_CRCNAK
	JR	AFY
AFY	LD	A,(NNAKS)
	INC	A
	LD	(NNAKS),A
	CP	MAX_NAKS
	JR	C,AFY_2
;
	LD	HL,M_10_NAKS
	CALL	VDU_PUTS
	JR	AGC
;
AFY_2	CALL	VDU_PUTS
	SCF
	RET
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
	LD	A,ASC_CAN
	CALL	PUT_BYTE
	LD	HL,M_S_CAN
	CALL	VDU_PUTS
	CALL	WAIT_ONE
	LD	A,ASC_CAN		;send another
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
	CALL	MESS_0_VDU
	POP	AF
	JP	DOSERR
;
READ_BLK
	LD	A,(BLK_STORED)
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
	CALL	MESS_0_VDU
	POP	AF
	CALL	DISP_DOS_ERROR
	JP	AHD
;
AGL	LD	(DE),A
	INC	DE
	DJNZ	AGK
	INC	C
	LD	A,(MAX_TOREAD)	;Max blocks to read in
	CP	C
	JP	Z,AGP		;If read maximum
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
AGO	LD	A,1
	LD	(FIL_EOF),A
	LD	A,C
AGP	LD	(BLK_STORED),A
;
	LD	A,MAX_BLOCKS
	LD	(MAX_TOREAD),A
;
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
	CP	MAX_BLOCKS	;Max blocks to store
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
	CALL	MESS_0_VDU
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
	POP	DE
	OR	A
	RET
;
INIT_AHC
	CALL	KEY_ABRT
	CALL	POSS_ABRT
	LD	B,1
	CALL	GET_BYTE
	JR	C,IAHC_1
	CP	ASC_NAK
	JR	Z,IAHC_2
	CP	ASC_CAN
	JP	Z,AGC
	CP	CRCNAK
	JR	NZ,IAHC_1
	LD	A,1
	LD	(CRCMODE),A	;Set CRC mode
	LD	HL,M_CRCNAK
	CALL	VDU_PUTS
	LD	A,ASC_NAK		;to fool the rest
	CP	A
	RET
IAHC_1	DEC	E
	JR	NZ,INIT_AHC
	LD	HL,M_TIME1	;timeout waiting for
	CALL	MESS_0_VDU		;initial nak.
	LD	HL,M_TIME1
	CALL	VDU_PUTS
	CALL	AGD
	JP	AHD
;
IAHC_2
	XOR	A
	LD	(CRCMODE),A	;Set checksum mode
	LD	HL,M_NAK
	CALL	VDU_PUTS
	CP	A
	RET
;
AHD				;filexfer aborted exit.
	LD	HL,M_ABORTED
	CALL	MESS_0_VDU
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
	CALL	MESS_0_VDU
;
AHD_2
	LD	HL,M_ABRT
;File transfer aborted. forget the rest of the requests.
	CALL	QUIET_0
	LD	A,8
	JP	EXIT_EXMF
;
MSG_EX	PUSH	HL
	LD	A,(QUIET)
	OR	A
	LD	A,20
	CALL	Z,SEC10
	POP	HL
	CALL	MESS_0_VDU
	RET		;back to xfer_loop....
;
SCREEN_SETUP
	RET
;
QUIET_0	LD	A,(QUIET)
	OR	A
	CALL	Z,MESS_0_VDU
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
MV_128	LD	B,128
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
	LD	A,(MODEM_STAT1)
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT2)
	OUT	(WRSTAT),A
	POP	AF
	RET
;
FILE_STATS			;print file length etc..
	LD	HL,M_SRDY	;Ready to send
	CALL	MESS_0_VDU
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
	CALL	MESS_0_VDU
;
	LD	HL,M_SRDY2
	CALL	MESS_0_VDU
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
	CALL	MESS_0_VDU
;
	LD	HL,M_SRDY3
	CALL	MESS_0_VDU
	RET
;
;send character
PUT_BYTE
	PUSH	AF
	CALL	KEY_ABRT	;check if abort reqd.
BS_1
	IN	A,(RDSTAT)
	BIT	CTS,A
	JR	Z,BS_1
BS_2
	POP	AF
	OUT	(WRDATA),A
	RET
;
CALC_CRC
	LD	HL,0
	LD	(OLD_CRC),HL
	LD	(ZEROCRC),HL
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
CALC_SUM
	LD	C,0
	LD	HL,DATABUF
	LD	B,128
FC_04	LD	A,(HL)
	ADD	A,C
	LD	C,A
	INC	HL
	DJNZ	FC_04
	LD	A,C
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
$$PUT	JP	33H
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
; Include globals
*GET	MESS_0_VDU
*GET	SEC10
*GET	SPUTNUM
;
;Special flags & stuff.
QUIET		DEFB	0	;Quiet flag
OVERWRITE	DEFB	0	;O/write existing file
CRCMODE		DEFB	0	;1=In CRC mode
TELINK		DEFB	0	;1=In Telink mode
CRC_LOW		DEFW	0	;CRC as received
OLD_CRC		DEFW	0	;CRC calculated.
CHECKSUM	DEFB	0	;Checksum calculated
NOLOG		DEFB	0	;No logging actions.
MAX_TOREAD	DEFB	0	;blks to read firstly.
;
M_S_ACK	DEFM	'ACK ',0
M_S_ENQ	DEFM	'ENQ ',0
M_R_ENQ	DEFM	'enq ',0
M_EXMODEM
	DEFM	'Exmodem! ',0
M_S_EOT	DEFM	'EOT ',0
M_R_ACK	DEFM	'ack ',0
M_S_NAK	DEFM	'NAK ',0
M_NAK	DEFM	'nak ',0
M_CRCNAK	DEFM	'CRCnak ',0
M_S_CRCNAK	DEFM	'CRCNAK ',0
M_S_CAN	DEFM	'CAN ',0
M_CAN	DEFM	'can ',0
M_CAN_WHO
	DEFM	'(Someone cancels) ',0
M_CAN_HIM
	DEFM	'(He cancels) ',0
M_10_NAKS
	DEFM	'(he sends too many naks) ',0
M_TIME2	DEFM	'timeout ',0
;
ARG	DEFW	0
NEWARG	DEFW	0
M7_TRY	DEFB	0
M7_POSN	DEFW	0
M7_FIELD	DEFS	11	;FFFFFFFFeee
;
M_RECVNG
	DEFM	'xmf: receiving file ',0
M_SENDING
	DEFM	'xmf: sending file ',0
M_LOG_ERROR
	DEFM	'*** xmf log file error',0
;
M_USAGE	DEFM	CR
	DEFM	'xmf:   Illegal arguments given. Usage is:',CR
	DEFM	'Single file interactive mode:   XMF',CR
	DEFM	'For multi file send/receive mode:',CR
	DEFM	'XMF [-coqn] [-s files ...] [-r files ...]',CR,CR
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
	DEFM	CR,'File transfer completed.',CR,CR,0
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
M_DSKFUL
	DEFM	'<Disk Full..>',CR,0
M_TIME1
	DEFM	'init-nak timeout ',CR,0
M_DISAL	DEFM	'<Disallowed.>',CR,0
M_FNID
	DEFM	'File requested not in directory.',CR
	DEFM	'May be on another disk or filename misspelled.',CR,0
	DEFM	'Do "DIR" for a list of available files.',CR,0
M_S_OR_R
	DEFM	'Tell Zeta to Send or Receive file (S or R): ',0
M_FILE	DEFM	'Filename? ',0
M_SIGNON	DEFM	CR,'xmf: EXmodem File Transfer utility plus CRC checking.',CR
	DEFM	'Christensen protocol transfers only.',CR
	DEFM	'usage is: xmf [-coqn] [-s files ...] [-r files ...]',CR,CR,0
M_NOVIS	DEFM	CR,'Sorry, you must be a MEMBER to send files.',CR,0
;
BLK1	DEFB	0
;
DATABUF	DC	80H,0		;Block buffer.
ZEROCRC	DEFW	0		;Must be imm. after DATABUF
;
AID	DEFW	BIG_BUFF	;Current read/write addr.
FIRST_BLK	DEFB	0	;1=First blk of transfer
BLK_RCV		DEFB	0	;block # being received
BLK_SNT		DEFB	0	;block # being sent
NNAKS		DEFB	0	;number of NAKs sent
FIL_EOF		DEFB	0	;1=no more blks to read
BLK_STORED	DEFB	0	;# blocks stored
XFABRT		DEFB	0	;flag 1=abort desired.
EOFB		DEFB	0	;EOF value 1-128 of blk.
;
MODEM_STAT1	DEFB	0FH	;300 baud, 1 stop.
MODEM_STAT2	DEFB	05H	;DTR & RTS.
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
FCB_LOG	DEFM	'XFERLOG/ZMS:2',CR
	DC	32-12,0
BUFF_LOG	DEFS	256
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
