;xmodem2: Xmf source code file 2
;Last updated: 09-Oct-87
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
SN_1	LD	A,NAK
	CALL	PUT_BYTE
	LD	HL,M_S_NAK
	CALL	VDU_PUTS
	JR	SN_6
;
SN_2
	LD	A,(FIRST_BLK)
	OR	A
	JR	Z,SN_1		;send ordinary NAK
	LD	A,(NNAKS)
	CP	5
	JR	NC,SN_1
;
SN_3	LD	A,CRCNAK
	CALL	PUT_BYTE
	LD	HL,M_S_CRCNAK
	CALL	VDU_PUTS
SN_6	LD	A,(NNAKS)	;increment NAK count
	INC	A
	LD	(NNAKS),A
	CP	MAX_NAKS
	JP	C,AFL		;try again.
;I cancel.
	CALL	AGD		;send CAN codes
	JP	AHD
;
SEND_ACK
	LD	A,ACK
	CALL	PUT_BYTE
	RET	
;
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
	LD	A,SOH
	CALL	PUT_BYTE	;send SOH
	LD	A,(BLK_SNT)
	CALL	PUT_BYTE	;send BLOCK number
	LD	A,(BLK_SNT)
	CPL			;send complement.
	CALL	PUT_BYTE
	RET	
;
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
;
AFX	LD	B,10		;wait 10 sec
	CALL	GET_BYTE
	CALL	POSS_ABRT
	LD	HL,M_TIME2
	JR	C,AFY
	CP	ACK
	RET	Z
	CP	CAN
	JP	Z,HE_RCVR_CANS
	CP	NAK
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
	LD	A,(CD_STAT)	;or if carrier falls
	BIT	1,A
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
	LD	B,1
	CALL	GET_BYTE
	JP	C,AFX		;Nothing received
	CP	CAN
	JP	NZ,AFX		;Didnt get 2nd CAN
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
	CALL	LOG_2
	POP	AF
	JP	DOSERR
;
READ_BLK
	LD	A,(BLK_STORED)
	DEC	A
	LD	(BLK_STORED),A
	JP	M,AGI
	JR	NZ,RB_01	;If >0 blocks now stored
	CALL	TWIRL		;Start the drive up
RB_01
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
	CALL	TWIRL		;Spin the disk
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
	JR	NZ,FULL_SECTOR
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
	CALL	AGD		;send cancel
	LD	HL,M_DSKFUL
	CALL	LOG_2
	POP	AF
	CALL	DISP_DOS_ERROR
	JP	AHD
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
	CP	NAK
	JR	Z,IAHC_2
	CP	CAN
	JP	Z,AGC
	CP	CRCNAK
	JR	NZ,IAHC_1
	LD	A,1
	LD	(CRCMODE),A	;Set CRC mode
	LD	HL,M_CRCNAK
	CALL	VDU_PUTS
	LD	A,NAK		;to fool the rest
	CP	A
	RET
IAHC_1	DEC	E
	JR	NZ,INIT_AHC
	LD	HL,M_TIME1	;timeout waiting for
	CALL	LOG_2		;initial nak.
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
;send character
PUT_BYTE
	PUSH	AF
	CALL	KEY_ABRT	;check if abort reqd.
BS_1
	LD	A,(CD_STAT)
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
$$PUT	LD	DE,$2
	JP	$PUT
MESS_0	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$$PUT
	INC	HL
	JR	MESS_0
;
;Get useful routines.
*GET	ROUTINES
;
;Special flags & stuff.
QUIET		DEFB	0	;1=Quiet output
OVERWRITE	DEFB	0	;1=O/write existing file
CRCMODE		DEFB	0	;1=In CRC mode
TELINK		DEFB	0	;1=In Telink mode
EX_FLAG		DEFB	0	;1=Exmodem on sending
NOLOG		DEFB	0	;No logging actions.
;
CRC_LOW		DEFW	0	;CRC as received
OLD_CRC		DEFW	0	;CRC calculated.
CHECKSUM	DEFB	0	;Checksum calculated
MAX_TOREAD	DEFB	0	;blks to read firstly.
;
M_S_ACK	DEFM	'ACK ',0
M_R_ACK	DEFM	'ack ',0
M_S_ENQ	DEFM	'ENQ ',0
M_R_ENQ	DEFM	'enq ',0
M_EXMODEM
	DEFM	'Exmodem! ',0
M_S_EOT	DEFM	'EOT ',0
M_R_EOT	DEFM	'eot ',0
M_S_NAK	DEFM	'NAK ',0
M_NAK	DEFM	'nak ',0
M_CRCNAK	DEFM	'crcnak ',0
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
M_ABRT	DEFM	'Aborted!',CR,0
;
ARG	DEFW	0
NEWARG	DEFW	0
M7_TRY	DEFB	0
M7_POSN	DEFW	0
M7_FIELD DEFS	11	;FFFFFFFFeee
;
M_RECVNG
	DEFM	'xmodem: receiving ',0
M_SENDING
	DEFM	'xmodem: sending ',0
M_LOG_ERROR
	DEFM	'*** xmf log file error',0
;
M_USAGE	DEFM	CR
	DEFM	' Illegal arguments given. Usage is:',CR
	DEFM	'Single file interactive mode:',CR
	DEFM	'xmodem',CR
	DEFM	'For multi file send/receive mode:',CR
	DEFM	'xmodem [-coqn] [-s files ...] [-r files ...]',CR,CR
	DEFM	'Putting you into interactive mode now:',CR,0
M_BDFL	DEFM	'Illegal Filename for a Zeta file!',CR
	DEFM	'Use a name like ABCDEFGH.EXT',CR,0
;
M_SRDY1	DEFM	'Sending ',0
M_SRDY2	DEFM	', ',0
M_SRDY3	DEFM	' blocks (',0
M_SRDY4	DEFM	'K). Start your local XMODEM receive now.',CR,0
;
M_RRDY	DEFM	CR,'Ready to receive - start your XMODEM module',CR,0
M_CANNOT	DEFM	'You must be a member to download that',CR,0
M_EXISTS	DEFM	'That filename already exists',CR
	DEFM	'Upload with a different name',CR,0
M_FINI
	DEFM	CR,'File transfer completed.',CR,CR,0
M_KILLED
	DEFM	'XMF killed file',CR,0
M_ABORTED
	DEFM	'<Aborted>',CR,0
M_BUSTED
	DEFM	'<Busted>',CR,0
M_SENDEX
	DEFM	'<Exists>',CR,0
M_RECVNO
	DEFM	'<Nonexistant>',CR,0
M_ERROR	DEFM	'<Dos Error>',CR,0
M_DSKFUL
	DEFM	'<Disk Full>',CR,0
M_TIME1
	DEFM	'init-nak timeout ',CR,0
M_DISAL	DEFM	'<Disallowed>',CR,0
M_FNID
	DEFM	'File requested not in directory.',CR
	DEFM	'Check filename and disk directory.',CR,0
M_S_OR_R
	DEFM	'Tell Zeta to Send or Receive file (S or R): ',0
M_FILE	DEFM	'Filename? ',0
M_SIGNON	DEFM	CR,'xmodem: EXmodem File Transfer utility plus CRC checking.',CR
	DEFM	'Xmodem protocol transfers only.',CR
	DEFM	'usage is: xmodem [-coqn] [-s files ...] [-r files ...]',CR,CR,0
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
FCB_1	DEFS	32		;FCB.
BUFF_1	DEFS	256		;File Buffer...
;
FCB_LOG	DEFM	'xferlog.zms:2',CR
	DC	32-12,0
BUFF_LOG DEFS	256
;
B_DATE	DEFM	'DD-MMM-YY '
B_TIME	DEFM	'HH:MM:SS ',0
;
B_TYPE	DEFM	'S '
B_FILE	DEFM	'abcdefgh.xyz/password:1',CR,0
;
MSGBLK	DEFM	'xx  ',0
;
STRING	DEFS	64
;
IN_BUFF	DC	64,0
;
;End of Xmf2
