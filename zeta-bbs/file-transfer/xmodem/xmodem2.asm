;xmodem2: Xmodem source code file 2
;Last updated: 05 Aug 89
;
GET_BLK	XOR	A
	LD	(NNAKS),A	;No of NAKs sent
;
GBL_01	LD	B,9	 	;wait 9 sec for SOH
;(exact 10 second wait seems to confuse Prophet TBBS / Binkley ?)
	CALL	GET_BYTE
	JR	C,GBL_02	;Nothing received
;
	CALL	POSS_ABRT
	OR	A
	JR	Z,GBL_01	;ignore padding zeroes.
	CP	SOH
	JR	Z,GBL_03	;Block header seen
	CP	SYN
	JP	Z,TL_HDR	;Telink header
	CP	CAN
	JP	Z,SNDR_CANCELS	;the sender cancels it.
	CP	EOT
	SCF	
	RET	Z		;scf & ret if EOT
	JP	GBL_12		;Junk received so NAK
;
GBL_03
	LD	B,CHARTIMEOUT	;try to get block number
	CALL	GET_BYTE
	JR	C,GBL_04	;No block number
	LD	(BLK1),A
	LD	B,CHARTIMEOUT	;get inverse.
	CALL	GET_BYTE
	JR	C,GBL_04	;No inverse block number
	CPL	
	LD	D,A
	LD	A,(BLK1)
	CP	D
	JR	NZ,GBL_05	;Inverse does not match
;
	LD	(BLK_RCV),A	;block # being received.
	LD	HL,DATABUF
	LD	B,128
AFQ	PUSH	BC
	LD	B,CHARTIMEOUT
	CALL	GET_BYTE
	POP	BC
	JR	C,GBL_06	;No character received
	LD	(HL),A
	INC	HL
	DJNZ	AFQ
;
	LD	A,(CRCMODE)
	OR	A
	JR	NZ,TRY_R_CRC
;Get, calculate, and compare an 8 bit checksum.
	LD	B,CHARTIMEOUT
	CALL	GET_BYTE
	JR	C,GBL_07	;no checksum
	LD	(CHECKSUM),A
	CALL	CALC_SUM
	LD	D,A
	LD	A,(CHECKSUM)
	CP	D
	JR	Z,CHECK_SEQ
	JR	NZ,GBL_09	;bad checksum
;
GBL_02
	LD	HL,MR_NOSOH
	JR	MSG_NAK
;
GBL_04
	LD	HL,MR_NOBN
	JR	MSG_NAK
;
GBL_05
	LD	HL,MR_NOINV
	JR	MSG_NAK
;
GBL_06
	LD	HL,MR_NOCHAR
	JR	MSG_NAK
;
GBL_07
	LD	HL,MR_NOSUM
	JR	MSG_NAK
;
GBL_08
	LD	HL,MR_NOCRC
	JR	MSG_NAK
;
GBL_09
	LD	HL,MR_BADSUM
	JR	MSG_NAK
;
GBL_10
	LD	HL,MR_BADCRC
	JR	MSG_NAK
;
GBL_11
	LD	HL,MR_BADSEQ
	JR	MSG_NAK
;
GBL_12
	LD	HL,MR_JUNK
	JR	MSG_NAK
;
MSG_NAK
	CALL	LOG_MSG_2
	CALL	SEND_NAK
	JP	NZ,GBL_01	;NOT too many NAKs
;I cancel.
	CALL	SEND_CANS
	JP	AHD
;
;
TRY_R_CRC
	LD	B,CHARTIMEOUT
	CALL	GET_BYTE
	JR	C,GBL_08
	LD	(CRC_LOW+1),A
	LD	B,CHARTIMEOUT
	CALL	GET_BYTE
	JR	C,GBL_08
	LD	(CRC_LOW),A	;backwards! msb first!
	CALL	CALC_CRC
	LD	DE,(CRC_LOW)
	OR	A
	SBC	HL,DE		;compare HL to (crc_low)
	JR	NZ,GBL_10
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
	JP	NZ,GBL_11	;if out of sequence
	RET			;store & ACK later.
;
AFR	CALL	SEND_ACK	;send ACK
	JP	GET_BLK		;throw away.
;
TL_HDR
	LD	B,131
TLH_1
	PUSH	BC
	LD	B,CHARTIMEOUT
	CALL	GET_BYTE
	POP	BC
	JR	C,TLH_2		;Ignore loop if a timeout
	DJNZ	TLH_1
TLH_2
	CALL	SEND_ACK	;Ack the shit anyway
	JP	GET_BLK
;
;-------------------------------
;
SEND_NAK
SN_0
	LD	B,1		;wait 1 second for clear line
	CALL	GET_BYTE
	CALL	POSS_ABRT
	JR	NC,SN_0
;
;Send "C" if first block && nnaks<6
;
	LD	A,(FIRST_BLK)
	OR	A
	JR	Z,SN_1		;send NAK
;
	LD	A,(NNAKS)
	CP	6
	JR	NC,SN_1		;send NAK
;
SN_3	LD	A,CRCNAK
	CALL	PUT_BYTE
	LD	HL,M_S_CRCNAK
	CALL	VDU_PUTS
	JR	SN_6
;
SN_1	LD	A,NAK
	CALL	PUT_BYTE
	LD	HL,M_S_NAK
	CALL	VDU_PUTS
	JR	SN_6
;
SN_6	LD	A,(NNAKS)	;increment NAK count
	INC	A
	LD	(NNAKS),A
	CP	MAX_NAKS
	RET	C		;live to try another day
	RET			;Z.
;
;-------------------------------
SEND_ACK
	LD	A,ACK
	CALL	PUT_BYTE
;
	IF	SEALINK.EQ.1
	LD	A,(BLK_SNT)
	CALL	PUT_BYTE
	LD	A,(BLK_SNT)
	CPL
	CALL	PUT_BYTE
	ENDIF
;
	RET	
;
;-------------------------------
SNDR_CANCELS
;the sender cancels the transfer, or the receiver (me)
;sends 10 NAKs in a row.
	LD	HL,M_CAN
	CALL	VDU_PUTS
	LD	HL,M_CAN_HIM	;He cancels
	CALL	VDU_PUTS
	CALL	SEND_CANS
	JP	AHD		;aborted.
;
;-------------------------------
;
SEND_HDR
	LD	A,(BLK_SNT)
	CALL	BLK_NUMB	;print block number
	LD	A,SOH
	CALL	PUT_BYTE	;send SOH
	LD	A,(BLK_SNT)
	CALL	PUT_BYTE	;send BLOCK number
	LD	A,(BLK_SNT)
	CPL			;send complement.
	CALL	PUT_BYTE
	RET	
;
;-------------------------------
SEND_BLK
	LD	HL,DATABUF
	LD	B,80H
SB_01	LD	A,(HL)
	CALL	PUT_BYTE
	INC	HL
	DJNZ	SB_01
	RET	
;
;-------------------------------
;
SEND_CHECK
	LD	A,(CRCMODE)
	OR	A
	JR	NZ,SEND_CRC
	CALL	CALC_SUM
	CALL	PUT_BYTE
	CALL	POSS_ABRT	;check if abort desired.
	RET	
;
SEND_CRC
	CALL	CALC_CRC
	PUSH	HL
	LD	A,H		;msb first!
	CALL	PUT_BYTE
	POP	HL
	LD	A,L		;lsb second!
	CALL	PUT_BYTE
	CALL	POSS_ABRT
	RET
;
;-------------------------------
;
WAIT_RESP
	LD	B,11		;wait 10 sec
	CALL	GET_BYTE
	CALL	POSS_ABRT
	LD	HL,M_TIME2
	JR	C,AFY_2		;timeout
	CP	ACK
	RET	Z		;ack
	CP	CAN
	JR	Z,AFY_4		;cancel
	CP	NAK
	JR	Z,AFY_0		;nak
	CP	CRCNAK
	JR	Z,AFY_1		;crcnak
	JR	WAIT_RESP	;some other character
;
AFY_0
	LD	HL,M_NAK
	JR	AFY_2
AFY_1	LD	HL,M_CRCNAK
	JR	AFY_2
AFY_2
AFY
	LD	A,(NNAKS)
	INC	A
	LD	(NNAKS),A
	CP	MAX_NAKS
	JR	C,AFY_3
;
	LD	HL,M_10_NAKS
	CALL	VDU_PUTS
	JR	AGC
;
AFY_3	CALL	VDU_PUTS
	SCF
	RET
;
;I'm sending and HE cancels the transfer.
AFY_4
	LD	B,1
	CALL	GET_BYTE
	JR	C,WAIT_RESP	;Nothing received
	CP	CAN
	JR	NZ,WAIT_RESP	;Didnt get 2nd CAN
	LD	HL,M_CAN
	CALL	VDU_PUTS
	LD	HL,MS_RCAN
	CALL	LOG_MSG_2
;
	CALL	SEND_CANS
	JP	AHD
;
KEY_ABRT
	PUSH	AF		;abort if break hit.
	LD	A,(3840H)
	BIT	02H,A
	JR	NZ,KA_001
	LD	A,(CD_STAT)	;or if carrier falls
	BIT	CDS_DISCON,A
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
	CALL	SEND_CANS
	JP	AHD
;
SEND_CANS
	CALL	WAIT_ONE	;wait for no chars
	LD	A,CAN
	CALL	PUT_BYTE
	LD	HL,M_S_CAN
	CALL	VDU_PUTS
	LD	A,CAN		;send another
	CALL	PUT_BYTE
	LD	HL,M_S_CAN
	CALL	VDU_PUTS
	RET
;
;Wait until the line was clear for 1/10 second
;
WAIT_ONE
	LD	B,1
	CALL	GET_BYTE
	RET	C
	JR	WAIT_ONE
;
INC_SNT
	LD	A,(BLK_SNT)
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
	CALL	LOG_2
	POP	AF
	JP	DOSERR
;
;-------------------------------
;
XTWIRL
	RET			;Intentional !!
	LD	A,0
	LD	(37E0H),A
	RET
;
;-------------------------------
;
READ_BLK
	LD	A,(BLK_STORED)
	DEC	A
	LD	(BLK_STORED),A
	JP	M,AGI		;If empty, fill buffer
	JR	NZ,RB_01	;If >0 blocks now stored
	CALL	XTWIRL		;Start the drive up
RB_01
	LD	HL,(AID)
	LD	DE,DATABUF
	CALL	MV_128
	LD	(AID),HL
	RET	
;
AGI
	LD	A,(FIL_EOF)
	CP	1
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
	CALL	SEND_CANS
	LD	HL,M_ERROR
	CALL	LOG_2
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
;-------------------------------
;
WRITE_BLK
	LD	DE,(AID)
	LD	HL,DATABUF
	CALL	MV_128
	EX	DE,HL
	LD	(AID),HL
	LD	A,(BLK_STORED)
	INC	A
	LD	(BLK_STORED),A
	CP	MAX_BLOCKS	;Max blocks to store
	JR	Z,AGR		;Write them to disk
	CP	MAX_BLOCKS-1
	RET	NZ		;not "nearly full"
	CALL	XTWIRL		;Spin the disk
	RET
;
AGR
	LD	HL,BIG_BUFF
	LD	(AID),HL
AGR_0	LD	A,(BLK_STORED)
	OR	A
	JR	Z,WROTE_ALL
	LD	C,A
	CP	1
	JR	NZ,FULL_SECTOR		;Write a full sector
	LD	DE,(AID)
AGS	LD	B,80H
AGT	PUSH	DE
	LD	A,(DE)
	LD	DE,FCB_1
	CALL	$PUT
	POP	DE
	JR	NZ,CANT_WRITE
AGU	INC	DE
	DJNZ	AGT
;;	DEC	C
;;	JR	NZ,AGS
WROTE_ALL
	XOR	A
	LD	(BLK_STORED),A
	LD	HL,BIG_BUFF
	LD	(AID),HL
	RET	
;
FULL_SECTOR
	PUSH	BC
	LD	HL,(AID)
	LD	DE,BUFF_1
	LD	BC,256
	LDIR
	LD	(AID),HL
	LD	DE,FCB_1
	CALL	DOS_WRIT_SECT
	POP	BC
	JR	NZ,CANT_WRITE
	DEC	C
	DEC	C
	LD	A,C
	LD	(BLK_STORED),A
	JR	AGR_0
;
CANT_WRITE
	PUSH	AF
	CALL	SEND_CANS
	LD	HL,M_DSKFUL
	CALL	LOG_2
	POP	AF
	CALL	DISP_DOS_ERROR
	JP	AHD
;
;-------------------------------
;
;Carry flag is set if there is a timeout.
GET_BYTE
	PUSH	DE
GB_1	LD	D,40		;=1 sec
	LD	A,(TICKER)
	LD	E,A
	CALL	KEY_ABRT	;if abort
GB_2
	LD	A,(CD_STAT)
	BIT	CDS_DISCON,A
	JR	NZ,GB_3		;If disconnect
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
;-------------------------------
;
INIT_AHC
	CALL	KEY_ABRT
	CALL	POSS_ABRT
	LD	B,1
	CALL	GET_BYTE
	JR	C,IAHC_1	;timeout
	CP	NAK
	JR	Z,IAHC_2	;nak
	CP	CAN
	JP	Z,AGC		;can
	CP	CRCNAK
	JR	NZ,IAHC_1	;anything not CRCNAK
	LD	A,1
	LD	(CRCMODE),A	;Set CRC mode
	LD	HL,M_CRCNAK
	CALL	VDU_PUTS
	LD	A,NAK		;to fool the rest
	CP	A
	RET
;
IAHC_1	DEC	E
	JR	NZ,INIT_AHC
	LD	HL,M_TIME1	;timeout waiting for
	CALL	LOG_2		;initial nak.
	LD	HL,M_TIME1
	CALL	VDU_PUTS
	CALL	SEND_CANS
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
;-------------------------------
;
AHD				;filexfer aborted exit.
	LD	HL,M_ABORTED
	CALL	LOG_2
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
	CALL	LOG_MSG
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
	LD	DE,$2
	CALL	MESS_0
	RET		;back to xfer_loop....
;
SCREEN_SETUP
	LD	HL,(USR_NAME)
	LD	DE,$DO
	CALL	MESS_NOCR
	LD	A,CR
	CALL	$PUT
	RET
;
QUIET_0	LD	A,(QUIET)
	LD	DE,$2
	OR	A
	CALL	Z,MESS_0
	RET
;
QUIET_PUT
	PUSH	BC
	LD	B,A
	LD	A,(QUIET)
	OR	A
	LD	A,B
	LD	DE,$2
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
	LD	A,1
	CALL	SEC10
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
	LD	HL,M_SRDY1
	LD	DE,$2
	CALL	MESS_0
;
	LD	HL,B_FILE
	CALL	MESS_0
;
	LD	HL,M_SRDY2
	CALL	MESS_0
;
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
	LD	DE,$2
	CALL	MESS_0
;
	LD	HL,M_SRDY3
	CALL	MESS_0
;
	POP	HL		;# of blocks
	LD	DE,4		;Round to nearest K
	ADD	HL,DE
	SRL	H		;Divide by 8
	RR	L
	SRL	H
	RR	L
	SRL	H
	RR	L
	LD	DE,STRING
	CALL	SPUTNUM
	LD	HL,STRING
	LD	DE,$2
	CALL	MESS_0
;
	LD	HL,M_SRDY4
	CALL	MESS_0
	RET
;
;-------------------------------
;send character
PUT_BYTE
	PUSH	AF
	CALL	KEY_ABRT	;check if abort reqd.
BS_1
	LD	A,(CD_STAT)
	BIT	CDS_DISCON,A
	JR	NZ,BS_2		;Carrier check.
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
	LD	A,50
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
LOG_2
	LD	DE,FCB_LOG
	CALL	FPUTS
	JR	NZ,LOG_ERR
	RET
;
LOG_ERR	PUSH	AF
	CALL	LOG_CLOSE
	POP	AF
	LD	HL,M_LOG_ERROR
	CALL	LOG_MSG
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
MESS_NOCR
	LD	A,(HL)
	CP	ETX
	RET	Z
	CP	CR
	RET	Z
	OR	A
	RET	Z
	CALL	$PUT
	INC	HL
	JR	MESS_NOCR
;
MESS_0	LD	A,(HL)
	OR	A
	RET	Z
	LD	DE,$2
	CALL	$PUT
	INC	HL
	JR	MESS_0
;
;End of Xmodem2
