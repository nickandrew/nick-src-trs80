;*************************************
;* term15/asm: terminal program.     *
;* Nick Andrew, 04-Apr-84.           *
;* Version 1.5  17-Dec-85.           *
;*                                   *
;*                                   *
;* Now working on ascii file send    *
;* and complete UART control         *
;*                                   *
;*************************************
;I/O Port Assignments.
RDDATA	EQU	0F8H	;Uart Read data port.
WRDATA	EQU	0F8H	;Uart Write data port.
RDSTAT	EQU	0F9H	;Uart Read status port.
WRSTAT	EQU	0F9H	;Uart Write status port.
PTRADD	EQU	0FDH	;Printer port.
;Uart Status Bits.
_DSR	EQU	7	;1=DSR set to 0
_BREAK	EQU	6	;1=BREAK signal seen
_FE	EQU	5	;1=framing error
_OE	EQU	4	;1=overrun error
_PE	EQU	3	;1=parity error
_EMPTY	EQU	2	;1=buffer empty
DAV	EQU	1	;Data Available 1=true
CTS	EQU	0	;Clear to send: 1=true
;Printer Ready & Waiting value.
PTRRDY	EQU	3FH
;Cpu speed (to nearest 100 Khz)
CPU	EQU	30
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
;Flag Addresses defined.
STATUS	EQU	00H	;Various Status flags.
PSADD	EQU	01H	;Curr. Ptr buffer read locn.
PPADD	EQU	02H	;Current Ptr buffer poke locn.
SNDON	EQU	03H	;Holds Send=on character.
SNDOFF	EQU	04H	;Holds Send=off character.
UARTPG	EQU	05H	;# codes for uart setting.
;Bits defined for flag: 'status'
FULDPX	EQU	0	;1=Full Duplex.
ECHOCR	EQU	1	;Echo c/r on Half duplex.
PTROUT	EQU	2	;Printer output.
WTSND	EQU	3	;Wait-to-send flag.
WTSTAT	EQU	4	;1=allowed to send.
DATAOK	EQU	7	;Must be ON for correct table.
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
;General equates
STAKLN	EQU	80H	;Length of Stack.
CLS	EQU	01C9H
SCRMES	EQU	4467H
GETKEY	EQU	002BH
READLN	EQU	0040H	;Read a whole line from kbd.
NUMCOM	EQU	7	;Number of Commands.
;Start of Program.
	ORG	5200H
STACK	DEFS	STAKLN
START
	LD	HL,TITLE
	CALL	SCRMES
	LD	SP,STACK+STAKLN
	LD	IX,FLAGS
;reset UART.
	LD	HL,UART_CLR
	LD	B,(HL)
ULOOP	INC	HL
	LD	A,(HL)
	OUT	(WRSTAT),A
	DJNZ	ULOOP
;
	LD	(IX+STATUS),0
	JP	MMENU
;
UART_CLR	;codes to clear UART.
	DEFB	4
	DEFB	82H,50H,0CEH,37H
;
TITLE	DEFM	'Terminal Prog Ver 1.5  12-May-85.',CR
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
	BIT	CTS,A
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
	BIT	DAV,A
	JR	NZ,RECV01
	BIT	_OE,A
	JR	Z,NO_OE
	LD	A,0
NO_OE	BIT	PTROUT,(IX+STATUS)
	LD	A,0
	RET	Z
	CALL	EMPTY
	XOR	A
	RET
RECV01	BIT	_PE,A
	JR	Z,RECV_1
	BIT	_FE,A
	JR	Z,RECV_1
	LD	A,(RDDATA)
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
TYPE2	OR	A
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
	CALL	TYPE2
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
	LD	HL,M_QUIT
	CALL	SCRMES
;delay 1/10 sec (= 4 ticks)
	LD	A,(4040H)
	ADD	A,4
	LD	B,A
Q_DELAY	LD	A,(4040H)
	CP	B
	JR	NZ,Q_DELAY
	LD	A,37H
	OUT	(WRSTAT),A
	RET
;
M_QUIT	DEFM	LF,'Quit.',CR
;
;
TERM	CALL	CLS
	BIT	DATAOK,(IX+STATUS)
	JR	NZ,TERV20
	LD	HL,NODMES
	CALL	SCRMES
	RET
NODMES	DEFM	'Terminal Data not in memory.'
	DEFB	CR
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
	RET	Z
	CALL	SQUIT
	JR	LOOV01
;
;Program Uart for correct parity etc...
RSUART	PUSH	AF
	PUSH	BC
	PUSH	HL
	LD	B,(IX+UARTPG)
	LD	HL,UARTCD
RSUV01	LD	A,(HL)
	OUT	(WRSTAT),A
	INC	HL
	DJNZ	RSUV01
	POP	HL
	POP	BC
	POP	AF
	RET
FCB	DEFS	32
FCBBUF	DEFS	256
STRBUF	DEFS	32
COMBUF	DEFS	64
LOADFL	LD	HL,STRBUF
	LD	B,31
	CALL	0040H
	LD	HL,STRBUF
	LD	DE,FCB
	CALL	441CH	;EXTRACT
	LD	HL,EXT1
	LD	DE,FCB
	CALL	4473H
	LD	DE,FCB
	CALL	4430H	;LOAD
	RET	Z
	SET	7,A
	CALL	4409H
	RET
EXT1	DEFM	'TRM'
	DEFB	00H
;
PMACH	BIT	DATAOK,(IX+STATUS)
	RET	Z
	LD	HL,MACMES
	CALL	SCRMES
	LD	HL,8610H
	CALL	SCRMES
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
	CALL	441CH
	JP	NZ,FILE_ERR
	LD	HL,FCBBUF
	LD	B,0
	CALL	4424H
	JP	NZ,FILE_ERR
;send loop.
SLOOP	LD	DE,FCB
	CALL	13H
	JP	NZ,SFINI
WS_SF	PUSH	AF
	CALL	SEND1
	CALL	TRVDUO
	CALL	PRINT2
	POP	AF
	CALL	CHAR_DELAY
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
CHAR_DELAY
	CP	0DH
	LD	BC,0
	PUSH	AF
	CALL	Z,0060H
	POP	AF
	CALL	Z,0060H
	LD	BC,1800H
	CALL	0060H
	RET
;
MAX_SEC	DEFB	0
;
FILE_ERR
	OR	80H
	CALL	4409H
	RET
;
SFINI	LD	A,(FLAGS+STATUS)
	BIT	FULDPX,A
	RET	NZ	;Test for Honeywell!!
	LD	HL,EOF_STRING
FIN_LP	LD	A,(HL)
	OR	A
	RET	Z
	PUSH	HL
FIN_01	CALL	SEND1
	CALL	TRVDUO
	CALL	PRINT2
FIN_03A	CALL	RCHAR
	BIT	WTSTAT,(IX+STATUS)
	JR	Z,FIN_03A
	POP	HL
	INC	HL
	JR	FIN_LP
;
;
EOF_STRING
	DEFM	'***','EOF','***',CR,NULL
CHAR	NOP
;
;
MACMES	DEFM	'Terminal Type: '
	DEFB	03H
;Main Menu routine: set up as an infinite loop.
;Breakout must be via subroutine.
MMENU
	LD	HL,MMMES
	CALL	SCRMES
	LD	HL,COMBUF
	LD	B,59
	CALL	READLN
	JR	C,MMENU	;If <Break> hit.
	CALL	EXCOMM
	JR	MMENU
;Execute command in COMBUF.
EXCOMM	LD	HL,COMBUF
	LD	A,(HL)
	CP	60H	;Lower Case only
	JR	C,EXCV01
	SUB	20H
EXCV01	CP	CR
	RET	Z
	LD	HL,COMTAB
	LD	BC,NUMCOM
	CPIR
	JR	Z,EXCV02
	LD	HL,M_NTFND
	CALL	SCRMES
	RET
;
M_NTFND	DEFM	'Command Not found.',CR
;
EXCV02	DEC	L
	LD	A,L
	ADD	A,A
	LD	L,A
	LD	DE,COMVEC
	LD	H,0
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	JP	(HL)	;Jump to routine.
MMMES	DEFM	LF,'Enter command, or ? if unknown.'
	DEFB	LF
	DEFM	'=> '
	DEFB	03H
;Help: prints command names & functions.
HELP	LD	HL,HPMES
	CALL	SCRMES
	RET
HPMES	DEFM	'Main Menu: Allowable Commands'
	DEFB	LF
	DEFM	'<D> Return to Dos.             '
	DEFM	'<T> Enter Terminal mode        '
	DEFB	LF
	DEFM	'<P> Toggle Printer on/off      '
	DEFM	'<L> Load Terminal Data         '
	DEFB	LF
	DEFM	'<S> Send file in ascii         '
	DEFM	'<?> Help (this list)           '
	DEFB	LF
	DEFM	'<M> Print Machine type         '
	DEFB	CR
PTRTG2	BIT	PTROUT,(IX+STATUS)
	JR	Z,PTRV20
	RES	PTROUT,(IX+STATUS)
	LD	HL,OFFMS2
	CALL	SCRMES
	RET
PTRV20	SET	PTROUT,(IX+STATUS)
	XOR	A
	LD	(IX+PSADD),A
	LD	(IX+PPADD),A
;
	LD	HL,ONMES2
	CALL	SCRMES
	RET
ONMES2	DEFM	'Printer is now ON.'
	DEFB	0DH
OFFMS2	DEFM	'Printer is now OFF.'
	DEFW	0DH
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
	CALL	SCRMES
	RET
REQMES	DEFM	'Requires filename after command.'
	DEFB	0DH
LOAD3	RES	DATAOK,(IX+STATUS)
	INC	HL
	CALL	LDATA
	RET
SAVE2	LD	HL,COMBUF+1
	LD	A,(HL)
	CP	CR
	JR	NZ,SAVE3
	LD	HL,REQMES
	CALL	SCRMES
	RET
SAVE3	INC	HL
	CALL	SDATA
	RET
;Load data from disk (full sector read)
LDATA	LD	DE,FCB
	CALL	441CH	;EXTRACT
	RET	NZ
	LD	HL,EXT1
	LD	DE,FCB
	CALL	4473H	;EXTEND
	LD	DE,FCB
	LD	HL,FCBBUF
	LD	B,0
	CALL	4424H	;OPEN>EX
	RET	NZ
	LD	B,10
	LD	DE,PDATA
LDAV01	PUSH	BC
	PUSH	DE
	LD	DE,FCB
	CALL	4436H	;READ>SC
	JR	Z,LDAV02
	POP	DE
	POP	BC
	RET
LDAV02	LD	HL,FCBBUF
	POP	DE
	LD	BC,100H
	LDIR
	POP	BC
	DJNZ	LDAV01
	LD	DE,FCB
	CALL	4428H
	RET
SDATA	RET
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
NURECV	DEFS	12
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	RECV0
	POP	HL
	POP	DE
	POP	BC
	RET
;New origin for Command Table and Command Vectors.
	ORG	7F00H
COMTAB	DEFB	'D'	;Back to Dos.
	DEFB	'T'	;Terminal.
	DEFB	'P'	;Toggle Printer on/off.
	DEFB	'L'	;Load machine data.
	DEFB	'S'	;Ascii File send.
	DEFB	'?'	;Help on commands.
	DEFB	'M'	;machine type.
	DEFB	NULL
	ORG	7F40H
COMVEC	DEFW	402DH	;'D': Back to Dos.
	DEFW	TERM2	;'T': Terminal.
	DEFW	PTRTG2	;'P': Toggle Printer.
	DEFW	LOAD2	;'L': Load Data.
	DEFW	SENDF	;'S': Send file.
	DEFW	HELP	;'?': Help message.
	DEFW	PMACH	;'M': Machine
	DEFW	0000H
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
	RET
;
BUFF_POS
	DEFW	8A00H
;
	END	START
