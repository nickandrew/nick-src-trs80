;Ftalk2:  Zeta implementation of the Fidonet data link protocol
;Incorporating Ftalk and Getpkt.
;
;2.0b   14 Jun 90:      Log the PKTnnnn.NET file into INFILES
;                       Reorganise, add some error logging
;2.0a	19 May 90:      Stop ftalk2 from removing received bundles!
;                       If transfer fails, do not do line turnaround
;2.0	24 Mar 90:      Base version
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
	DEFW	0	;Was fido_lost
;End of program load info.
;
	COM	'<Ftalk2 2.0b 14 Jun 90>'
	ORG	BASE+100H
START	LD	SP,START
;
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JP	Z,TERMINATE
;
;Usage: Ftalk2 -l
;	Ftalk2 -c net/node
;
	LD	A,(HL)
	CP	'-'
	JR	NZ,ST_00B
	INC	HL
	LD	A,(HL)
	INC	HL
	INC	HL
	CALL	TO_UPPER_C
	CP	'L'		;Listen (somebody is calling)
	JR	NZ,ST_00A
	LD	A,1
	LD	(L_FLAG),A
	JR	ST_00C
;
ST_00A
	CP	'C'
	JR	NZ,ST_00B
	LD	A,1
	LD	(C_FLAG),A
	CALL	CONVFILE	;Change nnn/nnn to filename
	JR	ST_00C
;
ST_00B
	CALL	USAGE
	LD	HL,1
	LD	A,1
	JP	EXIT
;
ST_00C
	XOR	A
	LD	(FATAL),A
;
	LD	A,(L_FLAG)	;Are we receiving a call
	OR	A
	JR	Z,ST_00E	;No, send first
;
	CALL	RECVMODE	;Yes, receive first
;
	LD	A,(FATAL)
	OR	A
	JR	NZ,ST_00D	;There was a fatal error
;
	CALL	REREAD		;Read the incoming bundle
;
ST_00E
	CALL	FIXFILENAME	;Determine the filename to send
	CALL	SENDMODE	;Then send stuff
;
	LD	A,(FATAL)
	OR	A
	JR	NZ,ST_00D	;There was a fatal error
;
	LD	A,(L_FLAG)	;Are we listening?
	OR	A
	CALL	Z,RECVMODE	;No, so receive second
;
ST_00D
	CALL	FIX_STATS	;Alter & close stats.
	CALL	CLOSE_INF	;Close INFILES
;
	CALL	SAVE_PACKET	;Save old outgoing mail
	CALL	DISC_FIDO	;Disconnect
;
	LD	HL,0
	JP	EXIT
;
; Receive mode. Call this to do the full receive half.
;
RECVMODE
	XOR	A
	LD	(FATAL),A
;
	CALL	MAIL_RECV		;Receive mail bundle
	CALL	FILE_RECV		;Receive any attached files
	RET
;
; Send mode. Call this to do the full send half.
;
SENDMODE
	CALL	IS_MAIL			;make mail bundle
;
	XOR	A
	LD	(FATAL),A
;
	LD	HL,M_DIAL1		;Ftalk...
	CALL	LOG_MSG_1
;
	CALL	WHACK_CR		;Connection stuff
	CALL	MAIL_SEND		;Send mail bundle
	CALL	FILE_SEND		;Send file attaches
	RET
;
;-------------------------------
EXIT_FTALK
	JP	TERMINATE
EXIT
	JP	TERMINATE
;
USAGE
	LD	HL,M_USAGE
	CALL	LOG_MSG_1
	XOR	A
	JP	EXIT
;
;Convert a string nnnn/nnnn into TO_NET and TO_NODE
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
	RET
;
;Convert the hex bytes in TO_NET and TO_NODE to ascii, and store in the
;8 bytes at PKTNAME - null terminated string.
FIXFILENAME
	LD	HL,(TO_NET)
	LD	DE,PKTNAME
	CALL	TO_HEX
	LD	A,(PKTNAME)		;Convert 1st char to alpha
	ADD	A,11H
	LD	(PKTNAME),A
;
	LD	HL,(TO_NODE)
	LD	DE,PKTNAME+4
	CALL	TO_HEX
	LD	A,(PKTNAME+4)		;Convert 5th char to alpha
	ADD	A,11H
	LD	(PKTNAME+4),A
;
	XOR	A
	LD	(PKTNAME+8),A
	RET
;
;Read the next char from (DE) and update the number in HL
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
;Convert a number in HL to 4 hex digits and store at (DE)
TO_HEX	LD	A,H
	CALL	TO_HEX_1
	LD	A,L
	CALL	TO_HEX_1
	RET
;
;Convert a number in A to 2 hex digits and store at (DE)
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
;Convert hex digit in A to ascii and store at (DE)
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
;Create a dummy bundle if a bundle to the net and node do not already exist
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
	JP	NZ,IM_01
	CALL	DOS_WRITE_EOF
	JP	NZ,IM_01
	RET
;
IM_01
	PUSH	AF
	LD	HL,M_ER4
	CALL	LOG_MSG_2
	POP	AF
	JP	ERROR			;Bomb out
;
;Whack CRs to the remote end if we dialled or we connect
WHACK_CR
	LD	A,(C_FLAG)
	OR	A
	RET	Z		;Neither -d nor -c
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
	RET
;
;Send the outbound bundle
MAIL_SEND
	LD	HL,CMD_XMFS
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,PKTNAME
	CALL	STRCAT
	LD	HL,FILE_TRAIL1
	CALL	STRCAT
	CALL	XMF_S
	JR	NZ,MAIL_01
	LD	HL,G_MAILOK
	CALL	LOG_MSG_2
	LD	A,1
	LD	(SENTPKT),A
	RET
;
MAIL_01
	LD	HL,M_MAILBAD
	CALL	LOG_MSG_2
	LD	A,1
	LD	(FATAL),A
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
	LD	A,(FATAL)
	OR	A
	RET	NZ		;If failed before.
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
	LD	HL,MT1_1
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
	LD	HL,MT1_3
	CALL	LOG_MSG_1
	POP	HL
	LD	DE,$DO
	CALL	PRINT_NUMB
	JR	FS_02
;
FS_03	LD	HL,MT1_2		;Rcvd nak
	CALL	LOG_MSG_1
	JR	FF_06
;
FF_02	LD	HL,MT1_4		;Rcvd Tsync
	CALL	LOG_MSG_1
	RET
;
FF_03	LD	HL,MT1_5		;Gave up
	CALL	LOG_MSG_2
	LD	A,1
	LD	(FATAL),A
	RET
;
FF_04	LD	HL,MT_6		;Rcvd C
	CALL	LOG_MSG_1
	JR	FF_06
FF_05
	LD	HL,MT_7		;Rcvd ACK
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
	LD	HL,MT_8
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
	CALL	CONVFN		;Blank pad
	CALL	MODEM7_FNAME1
	JR	NZ,FF_07A	;Fn send failed
	LD	HL,CMD_XMFS
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,FA_FILE
	CALL	STRCAT
	CALL	XMF_S
	JP	Z,FS_01		;File send OK
	LD	HL,M_FTFAIL
	CALL	LOG_MSG_2
	LD	A,1
	LD	(FATAL),A
	RET
;
FF_07A
	LD	HL,M_FNFAIL
	CALL	LOG_MSG_2
	LD	A,1
	LD	(FATAL),A
	RET
;
MODEM7_FNAME1
	XOR	A
	LD	(TRIES),A
FS_MS0
	LD	A,(TRIES)
	INC	A
	LD	(TRIES),A
	CP	20
	JR	NZ,MF1_00A	;was mf_01
	LD	HL,M7_TRY1	;Tried 20 times
	CALL	LOG_MSG_2
	LD	A,3
	CP	0
	RET	;nz
;
MF1_00A	;Must WAIT for a Nak ... no good just sending ACK!
	LD	B,3
	CALL	GET_BYTE
	JR	C,FS_MS0	;Timeout
	CP	ASC_NAK
	JR	NZ,FS_MS0	;Retry
MF1_01	LD	A,ASC_ACK
	CALL	PUT_BYTE
	LD	HL,TEMPFN
	LD	A,(HL)
	LD	C,A
	PUSH	BC
	INC	HL
	PUSH	HL
	CALL	PUT_BYTE
FS_MS1
	LD	B,2
	CALL	GET_BYTE
	JR	NC,MF1_03
MF1_02	LD	A,'u'
	CALL	PUT_BYTE
	POP	HL		;Discard
	POP	BC
	LD	HL,M7_U
	CALL	LOG_MSG_1
	JR	FS_MS0
MF1_03
	CP	ASC_ACK
	JR	NZ,MF1_02
	POP	HL
	LD	A,(HL)
	OR	A
	JR	Z,MF1_04
	PUSH	HL
	CALL	PUT_BYTE
	POP	HL
	POP	BC
	LD	A,(HL)
	ADD	A,C
	LD	C,A
	PUSH	BC
	INC	HL
	PUSH	HL
	JR	FS_MS1
MF1_04	LD	A,ASC_SUB
	CALL	PUT_BYTE
	LD	A,ASC_SUB
	POP	BC
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
	CP	A
	RET
;
; Blank-pad a filename, and convert it so we can use a Zeta-legal name
; yet send it as a PC-legal name.
CONVFN
	LD	DE,TEMPFN
	PUSH	DE
	LD	A,' '
	LD	B,11
CV_00	LD	(DE),A		;Fill with blanks
	INC	DE
	DJNZ	CV_00
	XOR	A
	LD	(DE),A
	POP	DE
	LD	B,8
	CALL	ZAPNUMBER	;Zap around 0-9 to a-j
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
	INC	HL
	LD	B,3
	CALL	ZAPNUMBER
CV_03	LD	A,(HL)
	OR	A
	JR	Z,CV_06
	CP	':'
	JR	Z,CV_06
	CP	'/'
	JR	Z,CV_06
	CALL	TO_UPPER_C
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	CV_03
;
CV_06
	LD	DE,$DO
	LD	A,''''
	CALL	ROM@PUT
	LD	HL,TEMPFN
	LD	B,11
CV_07	LD	A,(HL)
	CALL	ROM@PUT
	INC	HL
	DJNZ	CV_07
	LD	A,''''
	CALL	ROM@PUT
	LD	A,CR
	CALL	ROM@PUT
	RET
;
; Zap a digit to a corresponding letter
ZAPNUMBER
	LD	A,(HL)
	CP	'0'
	RET	C
	CP	'9'+1
	RET	NC
	LD	(DE),A		;Zap as is!
	ADD	A,31H		;Change to a-j
	LD	(HL),A
	INC	DE
	INC	HL
	DEC	B		;One less time through
	RET
;
;Read the next filename from the file attach file list
READFN
	LD	HL,FA_FILE
	LD	DE,FA_FCB
	LD	B,31
RF_01	CALL	ROM@GET
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
; Disconnect from the system - wait 2 seconds and print a message
;
DISC_FIDO
	LD	A,20
	CALL	SEC10
	LD	HL,M_HANG1
	CALL	LOG_MSG_2
	XOR	A
	RET
;
;We lost carrier!
FIDO_LOST
	LD	HL,M_LOST1
	CALL	LOG_MSG_2
	LD	A,127
	JP	TERMINATE
	JP	LOST_CARRIER
;
;If the mail bundle was sent, copy then remove it.
SAVE_PACKET
	LD	A,(SENTPKT)
	OR	A
	RET	Z			;Return if bundle was not sent
;
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
	LD	DE,PKT_FCB	;The sent mail bundle
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
;Reread the bundle just received
REREAD
	LD	A,(C_FLAG)
	OR	A
	RET	NZ		;If we called out, do not reread bundle
;
;Now figure out who is calling
	CALL	WHICH_LINK
;
;Copy their address into the address we will talk to
	LD	HL,(HEAD_ORIG_NET)
	LD	(TO_NET),HL
	LD	HL,(HEAD_ORIG_NODE)
	LD	(TO_NODE),HL
	RET
;
;Receive an inbound bundle
MAIL_RECV
	CALL	MAKE_NAME		;make filename (PKTnnnn)
	LD	DE,FILENAME
	LD	HL,FILE_TRAIL0
	CALL	STRCAT			;Append .NET to it
	LD	HL,CMD_XMFR
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,FILENAME		;Inbound bundle (PKTnnnn.NET)
	CALL	STRCAT
	LD	HL,FILE_TRAIL		;Append the password
	CALL	STRCAT
;
	LD	HL,STRING
	CALL	LOG_MSG_1
	LD	HL,M_CR
	CALL	LOG_MSG_1
;
	LD	HL,STRING
	CALL	CALL_PROG	;Receive the file.
	OR	A
	JR	NZ,MR_01	;The transfer failed
;
;Bump bundle received count.
	LD	HL,(PKTS_RCVD)
	INC	HL
	LD	(PKTS_RCVD),HL
;
	CALL	OPEN_INF	;Open the INFILES file
;
	LD	HL,FILENAME	;The filename (log it)
	CALL	WRITE_INF
;
	LD	HL,M_XMFOK
	CALL	LOG_MSG_2
	RET
;
MR_01
	LD	HL,M_NOXMF	;Couldn't transfer the bundle
	CALL	LOG_MSG_2
	LD	A,1
	JP	TERMINATE
;
;Display the dos error message, log it and terminate
ERROR
	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	LD	HL,M_BAD
	CALL	LOG_MSG_2
	POP	AF
	JP	TERMINATE
;
;Open the stats file to determine which number bundle to use
OPEN_STATS
	LD	HL,STATS_BUF
	LD	DE,STATS_FCB
	LD	B,16
	CALL	DOS_OPEN_EX
	JP	NZ,OS_01
	LD	A,(STATS_FCB+1)
	AND	0F8H
	LD	(STATS_FCB+1),A
	LD	HL,STATS_REC
	CALL	DOS_READ_SECT
	JP	NZ,OS_01
	CALL	DOS_REWIND
	RET
;
OS_01
	PUSH	AF
	LD	HL,M_ER3
	CALL	LOG_MSG_2
	POP	AF
	JP	ERROR			;Bomb out
;
;Update the stats file for # of bundles received.
;
FIX_STATS
	CALL	OPEN_STATS
;
	LD	HL,(PKTS_RCVD)
	LD	(ST_PKTS_RCVD),HL
;
	LD	DE,STATS_FCB	;Rewrite record
	LD	HL,STATS_REC
	CALL	DOS_WRIT_SECT
	JP	NZ,FXS_01
	CALL	DOS_CLOSE
	JP	NZ,FXS_01
	RET
;
FXS_01
	PUSH	AF
	LD	HL,M_ER2
	CALL	LOG_MSG_2
	POP	AF
	JP	ERROR		;Bomb out
;
;Create the inbound bundle filename (PKTnnnn)
MAKE_NAME
	LD	DE,FILENAME
	LD	HL,S_PKT
	CALL	STRCPY
	LD	HL,(PKTS_RCVD)	;from memory
	INC	HL
	CALL	SPUTNUM
	RET
;
;Receive any attached files.
FILE_RECV
	CALL	OPEN_INF
	LD	B,1
	CALL	GET_BYTE	;Flush
	LD	B,1
	CALL	GET_BYTE	;Flush
FR_01	CALL	MODEM7_FNAME
	JR	NC,FR_03	;Failed
	CP	ASC_EOT
	RET	Z
;
	LD	HL,CMD_TELINK
	LD	DE,STRING
	CALL	STRCPY
	LD	HL,M7_FILE
	CALL	STRCAT
;
	LD	HL,STRING
	CALL	LOG_MSG_2
	LD	HL,M_CR
	CALL	LOG_MSG_2
;
	LD	HL,STRING
	CALL	CALL_PROG
	OR	A
	JR	Z,FR_02
;
	LD	HL,M_RCVBAD
	CALL	LOG_MSG_2
	LD	A,1
	LD	(FATAL),A
	RET
;
FR_02
	LD	HL,M_RCVOK
	CALL	LOG_MSG_1
	LD	HL,M7_FILE	;The received filename
	CALL	WRITE_INF
	JR	FR_01
;
FR_03				;File receive failed
	LD	HL,M_FRFAIL
	CALL	LOG_MSG_2
	LD	A,1
	LD	(FATAL),A
	RET
;
;Open the INFILES file for output then set CANLOG to 1
OPEN_INF
	LD	A,(CANLOG)
	OR	A
	RET	NZ		;If logging is already under way
	LD	HL,BUF_INF
	LD	DE,FCB_INF
	CALL	DOS_OPEN_EX
	RET	NZ
	CALL	DOS_POS_EOF
	RET	NZ
	LD	A,1
	LD	(CANLOG),A
	RET
;
;Write one line to the INFILES file (from HL)
WRITE_INF
	LD	A,(CANLOG)
	OR	A
	RET	Z
	PUSH	HL
	LD	DE,FCB_INF
	LD	A,' '
	CALL	ROM@PUT
	LD	A,' '
	CALL	ROM@PUT
	POP	HL
	CALL	FPUTS
	LD	A,CR
	CALL	ROM@PUT
	RET
;
;Close the INFILES file
CLOSE_INF
	LD	A,(CANLOG)
	OR	A
	RET	Z
	LD	DE,FCB_INF
	CALL	DOS_CLOSE
	RET
;
;Receive a filename with the modem7 handshaking
MODEM7_FNAME
	XOR	A
	LD	(M7_TRY),A
;
MF_00
	LD	HL,MT_1
	CALL	LOG_MSG_1
	LD	A,(M7_TRY)
	INC	A
	LD	(M7_TRY),A
	CP	20
	JP	Z,M7_FAILED
	LD	A,ASC_NAK
	CALL	PUT_BYTE
MF_01
	LD	B,5
	CALL	GET_BYTE
	JR	C,MF_00		;If timeout.
	CP	ASC_ACK
	JR	Z,MF_03
	CP	ASC_SUB
	JP	Z,MF_08
	CP	ASC_EOT
	JR	Z,MF_02
;Unknown character.
	PUSH	AF
	LD	A,'"'
	LD	DE,$DO
	CALL	ROM@PUT
	POP	AF
	CALL	ROM@PUT
	LD	A,'"'
	CALL	ROM@PUT
	LD	A,' '
	CALL	ROM@PUT
	JR	MF_00
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
MF_03
	LD	HL,MT_3
	CALL	LOG_MSG_1
	LD	HL,M7_FIELD
	LD	C,0
	LD	(HL),C
MF_04
	LD	B,1
	CALL	GET_BYTE
	JP	C,MF_00		;If timeout
	CP	ASC_EOT
	JR	Z,MF_02		;If ACK then EOT .!?
	CP	ASC_SUB
	JR	Z,MF_05
	CP	'u'
	JP	Z,MF_00		;If timeout
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
MF_06
	LD	B,1
	CALL	GET_BYTE
	JP	C,MF_00
	CP	ASC_ACK
	JR	Z,MF_07		;convert filename.
	JP	MF_00
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
MF_08
	LD	HL,MT_5
	CALL	LOG_MSG_1
	LD	A,ASC_ACK
	CALL	PUT_BYTE
	LD	A,ASC_EOT
	SCF
	RET
;
M7_FAILED
	XOR	A
	LD	(M7_TRY),A
	SCF
	CCF
	RET
;
;Find out which link is talking to us
WHICH_LINK
	LD	HL,FILENAME	;Open bundle just received
	LD	DE,PKT_FCB
	CALL	STRCPY
	LD	HL,FILE_TRAIL	;Add the password
	CALL	STRCAT
	LD	HL,S_CR
	CALL	STRCAT
;
	LD	DE,PKT_FCB
	LD	HL,PKT_BUF
	LD	B,0
	CALL	DOS_OPEN_EX	;Open the received bundle
	JP	NZ,WL_02	;If unable to open
;
	LD	A,(PKT_FCB+1)	;Ensure it is readable
	AND	0F8H
	OR	5
	LD	(PKT_FCB+1),A
;
;Read the 58 byte header
	LD	DE,PKT_FCB
	LD	HL,HEAD
	LD	B,58
WL_01	CALL	ROM@GET
	JP	NZ,WL_02	;If error
	LD	(HL),A
	INC	HL
	DJNZ	WL_01
;
	CP	A		;Set Z flag
	RET			;All done!!
;
WL_02
	PUSH	AF		;Error value
	LD	HL,M_ER1
	CALL	LOG_MSG_2
	POP	AF
	JP	ERROR		;Bomb out
;
;Get the next word from the file
GET_WORD
	CALL	ROM@GET
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
;Multiply number in (DE) by 10 and add (A - '0')
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
; Log a message to the display and to the log file
LOG_MSG_2
	PUSH	HL
	LD	DE,$DO
	CALL	MESS_0
	POP	HL
	CALL	LOG_MSG
	RET
;
; Log a message to the display only
LOG_MSG_1
	PUSH	DE
	LD	DE,$DO
	CALL	MESS_0
	POP	DE
	RET
;
;Ensure a character (HL) is alphabetical
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
;
;Ensure a character (HL) is alphanumeric
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
; Convert character in 'A' to uppercase
TO_UPPER_C
	CP	'a'
	RET	C
	CP	'z'+1
	RET	NC
	AND	5FH
	RET
;
;Get a timed byte from the modem
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
;Send a character to the modem.
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
; Include globals
*GET	ROUTINES
*GET	CI_CMP
*GET	SEC10
*GET	SPUTNUM
*GET	STATS
;
;- Data -
;
C_FLAG		DEFB	0	;1 = Calling out to NNN/NNN
L_FLAG		DEFB	0	;1 = Listen first (we were called)
FATAL		DEFB	0	;1 = Connection failed somewhere
SENTPKT		DEFB	0	;1 = Outgoing bundle was sent
TRIES		DEFB	0	;Count of file send attempts
;
TO_NET		DEFW	0	;Calling/called net
TO_NODE		DEFW	0	;Calling/called node
FILES		DEFB	0	;1 = Files to send
;
M_USAGE
	DEFM	'Usage: ftalk2 -l              (receive first)',CR
	DEFM	'Or:    ftalk2 -c nnn/nnn      (send to nnn/nnn first)',CR,0
M_ISFILES	DEFM	'We have files to send',CR,0
M_WHACK		DEFM	'Whacking CR',CR,0
MT1_1		DEFM	'Waiting for their question',CR,0
MT1_2		DEFM	'Received nak',CR,0
MT1_3		DEFM	'Received other: ',0
MT1_4		DEFM	'Received early Tsync',CR,0
MT1_5		DEFM	'Gave up on no file send',CR,0
MT_6		DEFM	'Saw "C"',CR,0
MT_7		DEFM	'Received ack',CR,0
MT_8		DEFM	'sent EOT',CR,0
M_DIAL1		DEFM	CR,'Talking now ...',CR,CR,0
M_SAWTS		DEFM	'TSYNC sent',CR,0
M_NOCRS		DEFM	'** No response to whacking CR',CR,0
M_MAILBAD	DEFM	'Could not send mail bundle',CR,0
G_MAILOK	DEFM	'Mail bundle sent successfully',CR,0
M_FILE1		DEFM	'File send ignored',CR,0
M_FNFAIL	DEFM	'Modem7 filename send failed',CR,0
M_FTFAIL	DEFM	'File send transfer failed',CR,0
;
M7_TRY1		DEFM	'FileNAME send failed ... 20 tries',CR,0
M7_U		DEFM	'Sending U',CR,0
M_HANG1		DEFM	'Ftalk: Exiting',CR,0
M_LOST1		DEFM	'** Lost Fido carrier',CR,0
M_NOPKT		DEFM	'** No bundle to send to it',CR,0
M_NOCOPY	DEFM	'** could not copy bundle contents',CR,0
M_NORM		DEFM	'** could not delete bundle',CR,0
;
MT_1		DEFM	'--> filename?',CR,0
MT_2		DEFM	'--> eot seen',CR,0
MT_3		DEFM	' ack ',0
MT_4		DEFM	' crc-sent ',0
MT_5		DEFM	' sub ',0
;
M_CR		DEFM	CR,0
M_OK		DEFM	'finished receive half',CR,0
M_BAD		DEFM	'** getpkt bad',CR,0
M_XMFOK		DEFM	'bundle receive worked',CR,0
M_RCVOK		DEFM	'file receive worked',CR,0
M_FRFAIL	DEFM	'** modem7 filename failed',CR,0
M_NOXMF		DEFM	'** bundle receive failed',CR,0
M_RCVBAD	DEFM	'** file receive failed',CR,0
M_NMFILES	DEFM	'** no more files to receive',CR,0
M_TALKBAD	DEFM	'** ftalk didn''t work',CR,0
M_MAYBE		DEFM	'** May be an error!',CR,0
;
M_ER1		DEFM	'** Unable to reread received bundle',CR,0
M_ER2		DEFM	'** Unable to update STATS file',CR,0
M_ER3		DEFM	'** Unable to open/read STATS file',CR,0
M_ER4		DEFM	'** Unable to write to outgoing bundle',CR,0
;
CMD_XMFS	DEFM	'xmodem -qcs ',0
CMD_CP		DEFM	'cp ',0
CMD_RM		DEFM	'rm ',0
CMD_XMFR	DEFM	'xmodem -qocr ',0
CMD_TELINK	DEFM	'xmodem -qcr ',0
;
SPCS		DEFM	' ',0
;
FILE_TRAIL	DEFM	'/poof',0
FILE_TRAIL0	DEFM	'.NET',0
FILE_TRAIL1	DEFM	'.out/poof:2',0
FILE_TRAIL2	DEFM	'.fa/poof:2',0
S_CR		DEFM	CR,0
;
DUMMY_PKT
		DEFW	ZETA_NODE
DUMMY_NODE	DEFW	0
		DEFW	1990
		DEFW	5	;May (Month - 1)
		DEFW	14	;Day
		DEFW	08	;Hr
		DEFW	30	;Min
		DEFW	55	;Sec
		DEFW	0	;Baud
		DEFW	2	;Packet version
		DEFW	ZETA_NET
DUMMY_NET	DEFW	0
		DEFW	1	;Product code
		DC	33,0	;Fill
		DEFW	0	;No messages
;--- End of dummy bundle data
;
M7_TRY		DEFB	0	;# Tries to receive modem7 filename.
CANLOG		DEFB	0	;=1 If we can open infiles log.
;
S_PKT		DEFM	'PKT',0
;
FILENAME	DC	32,0
;
STATS_FCB	DEFM	'stats.zms',ETX
		DC	32-10,0
PKT_FCB		DEFS	32
;
STATS_BUF	DEFS	256
PKT_BUF		DEFS	256
;
;Format of the bundle header.....
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
;
FCB_INF		DEFM	'infiles:2',CR
		DC	32-10,0
BUF_INF		DEFS	256
;
PKTNAME		DEFS	64
FA_FILE		DEFS	32
TEMPFN		DEFS	12
;
FA_FCB		DEFS	32
;
;-----------------------------------------------------------------
;
THIS_PROG_END	EQU	$
;
	END	START
