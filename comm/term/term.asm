;Term15/asm: Terminal program.
;*************************************
;* term15/asm: Terminal program.     *
;* Nick Andrew, 04-Apr-84.           *
;* Version 1.4b 16-Jun-85.           *
;* Version 1.5  13-May-86            *
;*                                   *
;*                                   *
;* Now working on ascii file send    *
;* and complete UART control         *
;*                                   *
;*************************************
;
*GET	DOSCALLS
;
;I/O Port Assignments.
RDDATA	EQU	0F8H	;Uart Read data port.
WRDATA	EQU	0F8H	;Uart Write data port.
RDSTAT	EQU	0F9H	;Uart Read status port.
WRSTAT	EQU	0F9H	;Uart Write status port.
PTRADD	EQU	0FDH	;Printer port.
;
;Setup info.....
_5_BIT		EQU	00H	;....00..
_6_BIT		EQU	04H	;....01..
_7_BIT		EQU	08H	;....10..
_8_BIT		EQU	0CH	;....11..
_BIT_RESET	EQU	0F3H	;mask bit count bits
;
_1_STOP		EQU	40H	;01......
_2_STOP		EQU	0C0H	;11...... ;1.5=10......
_STOP_RESET	EQU	3FH	;mask stop bits
;
_PAR_ON		EQU	4	;bit 4
_PAR_EV		EQU	5	;bit 5
;
_BAUD_300	EQU	3	;If rts reset
_BAUD_1200	EQU	2	;If rts reset
_BAUD_2400	EQU	2	;If rts set
_BAUD_FAST	EQU	5	;RTS bit
_BAUD_RESET	EQU	0FCH	;Reset _baud_300 etc
;
;Uart Status Bits.
_DSR	EQU	7	;1=DSR set to 0
_BREAK	EQU	6	;1=BREAK signal seen
_FE	EQU	5	;1=framing error
_OE	EQU	4	;1=overrun error
_PE	EQU	3	;1=parity error
_EMPTY	EQU	2	;1=buffer empty
_DAV	EQU	1	;Data Available 1=true
_CTS	EQU	0	;Clear to send: 1=true
;
;Printer Ready & Waiting value.
PTRRDY	EQU	3FH
;Cpu speed (to nearest 100 Khz)
CPU	EQU	35
;Translation Table Hi-Byte addresses.
PDATA	EQU	8000H
TTVDUI	EQU	80H
TTVDUO	EQU	82H
TTKBD	EQU	84H
FLAGS	EQU	8600H
MNAME	EQU	8610H
UARTCD	EQU	8630H	;Codes to program into uart.
PTRBUF	EQU	87H
TTPTR	EQU	88H
;
;Flag Addresses defined.
STATUS	EQU	00H	;Various Status flags.
PSADD	EQU	01H	;Curr. Ptr buffer read locn.
PPADD	EQU	02H	;Current Ptr buffer poke locn.
SNDON	EQU	03H	;Holds Send=on character.
SNDOFF	EQU	04H	;Holds Send=off character.
UARTPG	EQU	05H	;# codes for uart setting.
;
;Bits defined for flag: 'status'
FULDPX	EQU	0	;Full Duplex.
ECHOCR	EQU	1	;Echo c/r on Half duplex.
PTROUT	EQU	2	;Printer output.
WTSND	EQU	3	;Wait-to-send flag.
WTSTAT	EQU	4	;1=allowed to send.
DATAOK	EQU	7	;Must be ON for correct table.
;
;Keyboard Ctrl Character names.
NULL	EQU	00H
EOT	EQU	04H	;Ctrl-D (End of Transmission)
ACK	EQU	06H	;Acknowledge
BELL	EQU	07H	;Bell/Tone
BS	EQU	08H	;Backspace
LF	EQU	0AH	;Line Feed.
CR	EQU	0DH	;Carriage Return.
DLE	EQU	10H	;Data Link Escape.
XON	EQU	11H	;Continue transmission.
XOFF	EQU	13H	;Stop transmission.
NAK	EQU	15H	;Negative Acknowledge.
DEL	EQU	7FH	;Delete
;
;General equates
STACK_LEN	EQU	80H	;Length of Stack.
CLS	EQU	01C9H
GETKEY	EQU	002BH
READLN	EQU	0040H	;Read a whole line from kbd.
NUMCOM	EQU	7	;Number of Commands.
;
	COM	'<Term 1.5  25-May-86>'
;Start of Program.
	ORG	5200H+STACK_LEN
START
	LD	SP,START
	LD	HL,TITLE
	CALL	MESS
	LD	IX,FLAGS
;reset UART.
	CALL	RSUART
;
	LD	(IX+STATUS),0
	JP	MMENU
;Send a single character to the Uart.
SEND1	PUSH	AF
	CP	XOFF
	JR	Z,WSEND1
	CP	XON
	JR	Z,WSEND1
	BIT	WTSND,(IX+STATUS)
	JR	Z,WSEND1
	BIT	WTSTAT,(IX+STATUS)
	JR	NZ,WSEND1
	POP	AF
	JR	RET_NZ
WSEND1	IN	A,(RDSTAT)
	BIT	_CTS,A
	JR	Z,WSEND1
	POP	AF
	CP	(IX+SNDOFF)
	JR	NZ,WSEV01
	RES	WTSTAT,(IX+STATUS)
WSEV01	OUT	(WRDATA),A
	JR	RET_Z
;receive 0 or 1 chars from Uart.
;on exit: NZ set if char recvd.
RECV0	IN	A,(RDSTAT)
	BIT	_DAV,A
	JR	NZ,RECV01
	BIT	_OE,A
	JR	Z,NO_OE
	LD	A,0
	JR	RECV02
NO_OE	BIT	PTROUT,(IX+STATUS)
	LD	A,0
	RET	Z
	CALL	EMPTY
	XOR	A
	RET
RECV01	BIT	_PE,A
	JR	NZ,RECV02
	BIT	_FE,A
	JR	NZ,RECV02
	BIT	_OE,A
	JR	NZ,RECV02
	JR	RECV_1
RECV02	LD	A,(RDDATA)
	LD	A,37H
	OUT	(WRSTAT),A
	XOR	A
	RET
;
RECV_1	IN	A,(RDDATA)
	CP	(IX+SNDON)
	RET	NZ
	SET	WTSTAT,(IX+STATUS)
	JR	RET_NZ
;
RET_Z	CP	A
	RET
RET_NZ	OR	A
	RET	NZ
	CP	1
	RET
;
MESS	LD	A,(HL)
	OR	A
	RET	Z
	CALL	33H
	INC	HL
	JR	MESS
;
;Empty printer buffer character by character.
EMPTY	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	L,(IX+PSADD)
	LD	E,(IX+PPADD)
	LD	H,PTRBUF
	LD	D,H
	LD	A,L
	CP	E
	JR	Z,EMPV02
	PUSH	BC
	LD	B,10H
	DJNZ	$
	POP	BC
	IN	A,(PTRADD)
	CP	PTRRDY
	JR	NZ,EMPV02
	LD	A,(HL)
	OUT	(PTRADD),A
	INC	L
	LD	(IX+PSADD),L
EMPV02	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;expect to receive 1 char from Uart.
RECV1	CALL	RECV0
	JR	Z,RECV1
	RET
;Send chars in A and B to Uart.
SEND2	OR	A
	RET	Z
	CALL	SEND1
	RET	NZ
	LD	A,B
	OR	A
	RET	Z
	CALL	SEND1
	RET
;Delay cpu for a certain time.
DELAY	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	E,CPU
DELV01	LD	BC,1996H
	CALL	0060H
	DEC	E
	JR	NZ,DELV01
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;Translate character.
TRANS	LD	L,A
	LD	A,(HL)
	INC	H
	LD	B,(HL)
	RET
;Translate character in one of four ways.
; 1) Keyboard     -->     Uart
; 2) Keyboard     -->     Screen
; 3) Uart         -->     Screen
; 4) Uart         -->     Printer
; Translation Tables used are
; 1) TTKBD
; 2) TTVDUO
; 3) TTVDUI
;
; 1) Translate char from Kbd to Uart.
TRKBD	LD	H,TTKBD
	JR	TRALL
; 2) Translate from Kbd to Screen
TRVDUO	LD	H,TTVDUO
	JR	TRALL
; 3) Translate from Uart to Screen
TRVDUI	LD	H,TTVDUI
	JR	TRALL
; 4) Translate from Uart to Printer.
TRPTR	LD	H,TTPTR
TRALL	CALL	TRANS
	RET
;Print a single character to the vdu.
PRINT1	PUSH	AF
	PUSH	BC
	CP	BELL
	JR	Z,PRIBEL
	CALL	PRINT_CHAR
	POP	BC
	POP	AF
	RET
PRIBEL	LD	C,10H
PRIV01	LD	A,1
	OUT	(255),A
	LD	B,7*CPU
	DJNZ	$
	XOR	A
	OUT	(255),A
	LD	B,7*CPU
	DJNZ	$
	DEC	C
	JR	NZ,PRIV01
	POP	BC
	POP	AF
	RET
;Print two characters to vdu.
PRINT2	OR	A
	RET	Z
	CALL	PRINT1
	LD	A,B
	OR	A
	RET	Z
	CALL	PRINT1
	RET
;Type two characters on the printer.
	RET	Z
	CALL	TYPE1
	LD	A,B
	OR	A
	RET	Z
	CALL	TYPE1
	RET
; Type send a single character to the printer
; buffer & hope to send up to 4 chars.
TYPE1	LD	C,A
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	L,(IX+PSADD)
	LD	E,(IX+PPADD)
	LD	H,PTRBUF
	LD	D,H
	LD	(DE),A
	INC	E
	LD	(IX+PPADD),E
	LD	B,5
TYPV10	LD	A,L
	CP	E
	JR	Z,TYPV12
	PUSH	BC
	LD	B,40H
	DJNZ	$
	POP	BC
	IN	A,(PTRADD)
	CP	PTRRDY
	JR	NZ,TYPV11
	LD	A,(HL)
	OUT	(PTRADD),A
	INC	L
	LD	(IX+PSADD),L
TYPV11	DJNZ	TYPV10
TYPV12	POP	HL
	POP	DE
	POP	BC
	LD	A,C
	RET
;Send character from Kbd to Uart
SCHAR	LD	C,A
	PUSH	BC
	CALL	TRKBD
	CALL	SEND2
	POP	BC
	RET	NZ
	BIT	FULDPX,(IX+STATUS)
	RET	NZ	;Ret if full duplex
	LD	A,C
	CP	CR
	JR	NZ,SCHV01
	BIT	ECHOCR,(IX+STATUS)
	RET	Z
SCHV01	CALL	TRVDUO
	CALL	PRINT2
	RET
;Receive character from Uart.
RCHAR	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	RECV0
	JR	Z,RCHV02
	LD	C,A
	PUSH	BC
	CALL	TRVDUI
	CALL	PRINT2
	POP	BC
	LD	A,C
	BIT	PTROUT,(IX+STATUS)
	JR	Z,RCHV02
	CALL	TRPTR
;;	CALL	TYPE2
RCHV02	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;Read zero or one key input.
KBDIN0	CALL	GETKEY
	OR	A
	RET	Z
	CP	CR
	RET	NZ
	LD	A,(3880H)	;for SHIFT-CR.
	CP	1
	LD	A,CR
	RET	NZ
	BIT	ECHOCR,(IX+STATUS)
	JR	Z,KBDV10
	RES	ECHOCR,(IX+STATUS)
	RET
KBDV10	SET	ECHOCR,(IX+STATUS)
	OR	A
	RET
;Read a key. Wait for key hit.
KBDIN1	CALL	KBDIN0
	JR	Z,KBDIN1
	RET
;Send a QUIT. signal to the host.
SQUIT	LD	A,3FH
	OUT	(WRSTAT),A
;delay 6 ticks, 3/20 sec.
	LD	A,(4040H)
	ADD	A,6
	LD	B,A
Q_DELAY	LD	A,(4040H)
	CP	B
	JR	NZ,Q_DELAY
	LD	A,37H
	OUT	(WRSTAT),A
	RET
;
;
;
TERM	CALL	SCR_RESTORE
	BIT	DATAOK,(IX+STATUS)
	JR	NZ,TERV20
	LD	HL,NODMES
	CALL	MESS
	RET
NODMES	DEFM	'Terminal Data not in memory.',CR,0
TERV20	SET	WTSTAT,(IX+STATUS)
	CALL	RSUART
	LD	A,14
	CALL	PRINT1
LOOP	CALL	KBDIN0
	JR	Z,LOOV01
	CP	01H
	JR	Z,BREAK
LOOV10	CALL	SCHAR
LOOV01	CALL	RCHAR
	JR	LOOP
;
BREAK	LD	A,(3880H)	;shift
	BIT	0,A
	JR	Z,LOOP_EXIT
	CALL	SQUIT
	JR	LOOV01
;
LOOP_EXIT
	CALL	SCR_SAVE
	RET
;
SCR_SAVE
	LD	HL,(4020H)
	LD	(SAVED_CURS),HL
	LD	HL,3C00H
	LD	DE,SAVED_SCREEN
	LD	BC,1024
	LDIR
	RET
;
;Program Uart for correct parity etc...
RSUART	PUSH	AF
	PUSH	BC
	PUSH	HL
	LD	HL,UART_CLR
	LD	B,(HL)
ULOOP	INC	HL
	LD	A,(HL)
	OUT	(WRSTAT),A
	NOP
	NOP
	NOP
	DJNZ	ULOOP
;
	POP	HL
	POP	BC
	POP	AF
	RET
;
LOADFL	LD	HL,STRBUF
	LD	B,31
	CALL	0040H
	LD	HL,STRBUF
	LD	DE,FCB
	CALL	DOS_EXTRACT
	LD	HL,EXT1
	LD	DE,FCB
	CALL	4473H
	LD	DE,FCB
	CALL	4430H	;LOAD
	RET	Z
	SET	7,A
	CALL	4409H
	RET
;
EXT1	DEFM	'TRM',0
;
PMACH	BIT	DATAOK,(IX+STATUS)
	RET	Z
	LD	HL,MACMES
	CALL	MESS
	LD	HL,8610H
	CALL	MESS
	RET
;
SENDF	;send a file in ascii format.
	BIT	DATAOK,(IX+STATUS)
	RET	Z
	LD	HL,COMBUF+1
SF_01	LD	A,(HL)
	CP	' '
	JR	NZ,SF_02
	INC	HL
	JR	SF_01
SF_02	LD	DE,FCB
	CALL	DOS_EXTRACT
	JP	NZ,FILE_ERR
	LD	HL,FCBBUF
	LD	B,0
	CALL	4424H
	JP	NZ,FILE_ERR
;send loop.
SLOOP	LD	DE,FCB
	CALL	13H
	JP	NZ,SFINI
WS_SF	CALL	SEND1
	BIT	FULDPX,(IX+STATUS)
	JR	NZ,WS_NOECHO
	CALL	TRVDUO
	CALL	PRINT2
WS_NOECHO
	CALL	RCHAR
	BIT	WTSTAT,(IX+STATUS)
	JR	NZ,SLOOP
;get time in seconds.
	LD	A,(4041H)
	DEC	A	;59 seconds.
	JR	NZ,NOT_59
	LD	A,59
NOT_59	LD	(MAX_SEC),A
WAIT_RDY
	LD	HL,MAX_SEC
	LD	A,(4041H)
	CP	(HL)
	JR	Z,SLOOP
	CALL	RCHAR
	BIT	WTSTAT,(IX+STATUS)
	JR	Z,WAIT_RDY
	JR	SLOOP
;
MAX_SEC	NOP
;
FILE_ERR
	OR	80H
	CALL	4409H
	RET
;
SFINI	RET
SEND_STR	LD	A,(HL)
	OR	A
	RET	Z
	PUSH	HL
	CALL	SEND1
	CALL	TRVDUO
	CALL	PRINT2
FIN_03A	CALL	RCHAR
	BIT	WTSTAT,(IX+STATUS)
	JR	Z,FIN_03A
	POP	HL
	INC	HL
	JR	SEND_STR
;
SCR_RESTORE			;restore screen.
	LD	HL,SAVED_SCREEN
	LD	DE,3C00H
	LD	BC,1024
	LDIR
	LD	HL,(SAVED_CURS)
	LD	(4020H),HL
	RET
;
MACMES	DEFM	'Terminal Type: '
	DEFB	0
;Main Menu routine: set up as an infinite loop.
;Breakout must be via subroutine.
MMENU
	LD	SP,START
	LD	HL,MMMES
	CALL	MESS
	LD	HL,COMBUF
	LD	B,59
	CALL	READLN
	JR	C,MMENU	;If <Break> hit.
	CALL	EXCOMM
	JR	MMENU
;Execute command in COMBUF.
EXCOMM	LD	HL,COMBUF
	LD	A,(HL)
	CP	'a'
	JR	C,EXCV01
	AND	5FH
EXCV01	CP	CR
	RET	Z
	LD	HL,COMTAB
	LD	BC,COMEND-COMTAB
	CPIR
	JR	Z,EXCV02
	LD	HL,M_NTFND
	CALL	MESS
	RET
;
M_NTFND	DEFM	'Command Not found.',CR,0
;
EXCV02	DEC	HL
	LD	DE,COMTAB
	OR	A
	SBC	HL,DE
	ADD	HL,HL
	LD	DE,COMVEC
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	JP	(HL)	;Jump to routine.
;
MMMES	DEFM	CR,'Enter command'
	DEFB	CR
	DEFM	'Main => '
	DEFB	0
;Help: prints command names & functions.
HELP	LD	HL,HPMES
	CALL	MESS
	RET
;
PTRTG2	BIT	PTROUT,(IX+STATUS)
	JR	Z,PTRV20
	RES	PTROUT,(IX+STATUS)
	LD	HL,OFFMS2
	CALL	MESS
	RET
;
PTRV20	SET	PTROUT,(IX+STATUS)
	XOR	A
	LD	(IX+PSADD),A
	LD	(IX+PPADD),A
;
	LD	HL,ONMES2
	CALL	MESS
	RET
;
ONMES2	DEFM	'Printer is now ON.',CR,0
OFFMS2	DEFM	'Printer is now OFF.',CR,0
;
;Prepare to go to Terminal Routine.
TERM2	LD	HL,COMBUF+1
	LD	A,(HL)
	CP	CR
	JR	Z,TERM3
	INC	HL
	CALL	LDATA
	JR	Z,TERM3
	RES	DATAOK,(IX+STATUS)
	RET
TERM3	BIT	DATAOK,(IX+STATUS)
	CALL	NZ,TERM
	RET
LOAD2	LD	HL,COMBUF+1
	LD	A,(HL)
	CP	CR
	JR	NZ,LOAD3
	LD	HL,REQMES
	CALL	MESS
	RET
REQMES	DEFM	'Requires filename after command.'
	DEFB	0DH,0
LOAD3	RES	DATAOK,(IX+STATUS)
	INC	HL
	CALL	LDATA
	RET
;
SAVE2	LD	HL,COMBUF+1
	LD	A,(HL)
	CP	CR
	JR	NZ,SAVE3
	LD	HL,REQMES
	CALL	MESS
	RET
;
SAVE3	INC	HL
	CALL	SDATA
	RET
;
;Load data from disk (full sector read)
LDATA	LD	DE,FCB
	CALL	DOS_EXTRACT
	RET	NZ
	LD	HL,EXT1
	LD	DE,FCB
	CALL	4473H	;EXTEND
	LD	DE,FCB
	LD	HL,FCBBUF
	LD	B,0
	CALL	DOS_OPEN_EX
	RET	NZ
	LD	B,10
	LD	DE,PDATA
LDAV01	PUSH	BC
	PUSH	DE
	LD	DE,FCB
	CALL	DOS_READ_SECT
	JR	Z,LDAV02
	POP	DE
	POP	BC
	RET
;
LDAV02	LD	HL,FCBBUF
	POP	DE
	LD	BC,100H
	LDIR
	POP	BC
	DJNZ	LDAV01
	LD	DE,FCB
	CALL	DOS_CLOSE
	RET
;
SDATA	RET
;
NUSEND	DEFS	12
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,C
	CALL	SEND1
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
NURECV
	DEFS	12
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	RECV0
	POP	HL
	POP	DE
	POP	BC
	RET
;
OPTION
;;	CALL	PRINT_STAT
	LD	HL,M_BITS
	CALL	ASK
	JP	C,MMENU
	LD	HL,IN_BUFF
OPT_LOOP
	LD	A,(HL)
	INC	HL
	CP	'7'
	JR	Z,BITS_7
	CP	'8'
	JR	Z,BITS_8
	CP	'1'
	JR	Z,BAUD_1200
	CP	'2'
	JR	Z,BAUD_2400
	CP	'3'
	JR	Z,BAUD_300
	AND	5FH
	CP	'N'
	JR	Z,PARI_NO
	CP	'E'
	JR	Z,PARI_EV
	CP	'O'
	JR	Z,PARI_OD
	JP	RE_SETUP
;
BITS_7
	LD	A,(SETUP_BITS)
	AND	_BIT_RESET
	OR	_7_BIT
	LD	(SETUP_BITS),A
	JP	OPT_LOOP
BITS_8	LD	A,(SETUP_BITS)
	AND	_BIT_RESET
	OR	_8_BIT
	LD	(SETUP_BITS),A
	JP	OPT_LOOP
;
PARI_NO	LD	A,(SETUP_BITS)
	RES	_PAR_ON,A
	LD	(SETUP_BITS),A
	JP	OPT_LOOP
PARI_EV	LD	A,(SETUP_BITS)
	SET	_PAR_ON,A
	SET	_PAR_EV,A
	LD	(SETUP_BITS),A
	JP	OPT_LOOP
;
PARI_OD	LD	A,(SETUP_BITS)
	SET	_PAR_ON,A
	RES	_PAR_EV,A
	LD	(SETUP_BITS),A
	JP	OPT_LOOP
BAUD_1200
	LD	A,(SETUP_BITS)
	AND	_BAUD_RESET
	OR	_BAUD_1200
	LD	(SETUP_BITS),A
	LD	A,(SETUP_SIGS)
	RES	_BAUD_FAST,A
	LD	(SETUP_SIGS),A
	JP	OPT_LOOP
BAUD_2400
	LD	A,(SETUP_BITS)
	AND	_BAUD_RESET
	OR	_BAUD_2400
	LD	(SETUP_BITS),A
	LD	A,(SETUP_SIGS)
	SET	_BAUD_FAST,A
	LD	(SETUP_SIGS),A
	JP	OPT_LOOP
BAUD_300
	LD	A,(SETUP_BITS)
	AND	_BAUD_RESET
	OR	_BAUD_300
	LD	(SETUP_BITS),A
	LD	A,(SETUP_SIGS)
	RES	_BAUD_FAST,A
	LD	(SETUP_SIGS),A
	JP	OPT_LOOP
;
WHAT
	LD	A,CR
	CALL	33H
	LD	B,_BIT_RESET.XOR.255
	LD	A,(SETUP_BITS)
	AND	B
	CP	_7_BIT
	LD	HL,M_7BITS
	JR	Z,BITS_PRINT
	CP	_8_BIT
	LD	HL,M_8BITS
	JR	Z,BITS_PRINT
	LD	HL,M_UNKBITS
BITS_PRINT
	CALL	MESS
;Now print parity status
	LD	A,(SETUP_BITS)
	LD	HL,M_NOPAR
	BIT	_PAR_ON,A
	JR	Z,PAR_PRINT
	LD	HL,M_EVPAR
	BIT	_PAR_EV,A
	JR	NZ,PAR_PRINT
	LD	HL,M_ODPAR
PAR_PRINT
	CALL	MESS
	JP	MMENU
;
ASK	CALL	MESS
	LD	HL,IN_BUFF
	LD	B,60
	CALL	40H
	RET
;
RE_SETUP
	CALL	RSUART
	JP	MMENU
;
PRINT_CHAR
	LD	HL,(BUFF_POS)
	LD	B,A
	LD	(HL),A
	INC	HL
	LD	DE,(4049H)
	LD	A,H
	CP	D
	JR	NZ,PC_1A
	LD	A,L
	CP	E
	JR	NZ,PC_1A
	JR	PC_1
PC_1A
	LD	(BUFF_POS),HL
PC_1	LD	A,B
	CALL	033AH
	RET
;
M_7BITS	DEFM	'Bits:   7',CR,0
M_8BITS	DEFM	'Bits:   8',CR,0
M_UNKBITS DEFM	'Bits:   Unknown',CR,0
M_NOPAR	DEFM	'Parity: NONE',CR,0
M_EVPAR	DEFM	'Parity: EVEN',CR,0
M_ODPAR	DEFM	'Parity: ODD',CR,0
;
M_BITS	DEFM	CR,'Enter desired USART config:',CR
	DEFM	'<7>  7 bits',CR
	DEFM	'<8>  8 bits',CR
	DEFM	'<N>  No   parity',CR
	DEFM	'<E>  Even parity',CR
	DEFM	'<O>  Odd  parity',CR
	DEFM	'<1>  1200 bps',CR
	DEFM	'<2>  2400 bps',CR
	DEFM	'<3>   300 bps',CR
	DEFM	'Usart Opt => ',0
;
;New origin for Command Table and Command Vectors.
COMTAB	DEFB	'X'	;Back to Dos.
	DEFB	'T'	;Terminal.
	DEFB	'P'	;Toggle Printer on/off.
	DEFB	'L'	;Load machine data.
	DEFB	'S'	;Ascii File send.
	DEFB	'?'	;Help on commands.
	DEFB	'M'	;machine type.
	DEFB	'O'	;options.
	DEFB	'W'	;what is status
COMEND	DEFB	NULL
;
COMVEC	DEFW	DOS	;'X': Back to Dos.
	DEFW	TERM2	;'T': Terminal.
	DEFW	PTRTG2	;'P': Toggle Printer.
	DEFW	LOAD2	;'L': Load Data.
	DEFW	SENDF	;'S': Send file.
	DEFW	HELP	;'?': Help message.
	DEFW	PMACH	;'M': Machine
	DEFW	OPTION	;'O': Setup options.
	DEFW	WHAT	;'W': What is status.
	DEFW	0
;
UART_CLR	;codes to clear UART.
	DEFB	4
		DEFB	82H
		DEFB	50H
SETUP_BITS	DEFB	0CEH	;8,n,1
SETUP_SIGS	DEFB	17H
;
HPMES	DEFM	'Allowable Commands',CR
	DEFM	'<X> Return to Dos.             '
	DEFM	'<T> Enter Terminal mode        ',CR
	DEFM	'<P> Toggle Printer output      '
	DEFM	'<L> Load Terminal Data         ',CR
	DEFM	'<S> Send file in ascii         '
	DEFM	'<?> Help (this list)           ',CR
	DEFM	'<M> Print Machine type         '
	DEFM	'<O> Baud rate options          ',CR
	DEFM	'<W> What is Usart status',CR
	DEFB	0
;
TITLE	DEFM	'Terminal Prog Ver 1.5a 30-May-87.',CR,0
;
SAVED_CURS	DEFW	3C00H
SAVED_SCREEN	DEFS	1024
;
FCB		DEFS	32
FCBBUF		DEFS	256
STRBUF		DEFS	32
COMBUF		DEFS	64
;
IN_BUFF	DEFS	64
BUFF_POS	DEFW	8A00H
;
	END	START
