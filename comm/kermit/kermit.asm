;kermit: Main file for Kermit Trs-80
;Kermit-Trs80	(kermit/asm)
;originally based on CP/M-80 Kermit V3.5
;started	10-Oct-83
;updated	04-Jan-84	by Stan Barber
;updated    	29-Nov-85	by Nick Andrew.
;Next Update	23-Mar-86	by Nick Andrew.
;Next Update	30-Jul-86	by Nick Andrew.
;Next Update	13-Aug-86	by Nick Andrew.
;Next Update    05-Jun-87       NA
;
;Changed by Nick Andrew 29-Nov-85 for:
;  - Different RS232 interfaces
;Change on 30-Jul-86 for:
;  - Use of proper 8bit quote '&' if necessary
;    NECESSARY :- Only if PARITY <> NONE.
;  - Use of repeat quote '~' (soon ... not yet)
;  - Rationalised default values
;  - Removing most of the MASSIVE bugs of the old version
;  - Removed file contents conversion
;    File content conversion can easily be done on the
;    host or slave systems... and can be much more
;    sophisticated than Kermit could ever achieve.
;
;Change on 14-Feb-87 for:
;  - Fix to Trs-80 modem reset code
;
;
;Version for:	  YES   1) Trs-80 Model I/III
;		  YES   2) System-80
;		  YES   3) 8251 USART	(Zeta Rtrs)
;		  YES   4) ACIA		(Aterm)
;		  NO	5) Trs-80 Model III only
;
;
;Flags: 1=Active, 0=Inactive. Only one to be set.
F_TRS80	EQU	0		;model 1 or 3
F_SYS80	EQU	0		;System-80
F_ZETA	EQU	1		;Zeta Rtrs
F_ATERM	EQU	0		;6850 ACIA ala Axle
;
;
;Rs-232 port information for all machine types.
	IF	F_TRS80		;trs-80
RESET	EQU	0E8H		;reset uart
BAUDOUT	EQU	0E9H		;set baud rate
RDDATA	EQU	0EBH
WRDATA	EQU	0EBH
RDSTAT	EQU	0EAH
WRSTAT	EQU	0EAH
DAV	EQU	7		;Bit value of INPUT
CTS	EQU	6		;Bit value of OUTPUT
	ENDIF			;f_trs80
;
	IF	F_ZETA		;8251 Usart viz Zeta
RDSTAT	EQU	0F9H		;Read Status
WRSTAT	EQU	0F9H		;Write Command
RDDATA	EQU	0F8H		;Read Data
WRDATA	EQU	0F8H		;Write Data
CTS	EQU	0		;Output bit pattern
DAV	EQU	1		;Input bit pattern
DTR_BIT	EQU	1
RTS_BIT	EQU	5
	ENDIF			;zeta
;
	IF	F_SYS80		;sys80
RESETP	EQU	0F8H		;Port for reset.
RESETB	EQU	04H		;Byte for reset.
RDDATA	EQU	0F8H		;Read Data
WRDATA	EQU	0F9H		;Write Data
RDSTAT	EQU	0F9H		;Read Status
WRSTAT	EQU	00H		;Not Used.
DAV	EQU	0		;(inverted DAV)
CTS	EQU	7
	ENDIF			;sys80
;
	IF	F_ATERM		;aterm
BAUDOUT	EQU	0E9H		;set baud rate
RDDATA	EQU	0EBH
WRDATA	EQU	0EBH
RDSTAT	EQU	0EAH
WRSTAT	EQU	0EAH
DAV	EQU	0		;Bit value of INPUT
CTS	EQU	1		;Bit value of OUTPUT
	ENDIF			;aterm
;
;End of RS232 port info
;
;
;Comments at beginning of command file so EVERYBODY
;knows which version of KERMIT they are listing.
;
	IF	F_TRS80
	COM	'<Kermit 30-Jul-86 for Trs-80 M1/3>'
	ENDIF
	IF	F_SYS80
	COM	'<Kermit 13-Aug-86 for System-80>'
	ENDIF
	IF	F_ZETA
	COM	'<Kermit 05-Jun-87 for Zeta>'
	ENDIF
	IF	F_ATERM
	COM	'<Kermit 13-Aug-86 for Aterm>'
	ENDIF
;
;
	ORG	7000H		;GET OUT OF WAY OF DOS OVERLAYS
;
;Symbol Definitions for some ASCII characters
;
SOH	EQU	01H		;Start of header char.
BELL	EQU	7		;ASCII BEL (Control-G)
CTRLC	EQU	3		;ASCII ETX (Control-C)
TAB	EQU	9		;ASCII Tab (Control-I)
LF	EQU	0AH		;ASCII Line Feed (CTRL-J)
FF	EQU	0CH		;ASCII Form Feed (CTRL-L)
CR	EQU	0DH		;ASCII Carriage Return (CTRL-M)
XON	EQU	21O		;The ASCII character used for XON
XOFF	EQU	23O		;The ASCII char used for XOFF
ESC	EQU	33O		;ASCII ESCape
SUBT	EQU	32O		;ASCII SUB (CTRL-Z)
DEL	EQU	7FH		;ASCII DELete (rubout)
;
DEFESC	EQU	31		;<CLEAR> key on key board
DBAUD	EQU	55H		;Default baud rate (300)
;
;Our defaults. These are the defaults this copy of Kermit
;likes to use for transfers. Labels should not be called
;'S'end or 'R'eceive ... this is misleading.
;
;The following parameters are valid independant of what
;the other system thinks:
;    - Length of pad string REQUIRED BY US
;    - Pad character REQUIRED BY US
;    - EOL char REQUIRED BY US
;    - Quote char WE WILL SEND out
;    - Maximum packet size WE CAN READ
;    - Period YOU should wait before timing ME out
;
;Following parameters must match the other side exactly
;or the protocol default is taken for both sides:
;    - Packet check type '1' or '2' or '3'
;
;Following parameters must be given values (other than
;the default) BY BOTH SIDES if they are to be used,
;otherwise NEITHER side may use them.
;    - Repeat quoting character    '~'
;
;8'th bit quoting (ie. with '&') is done:
;    on SEND :- only if PARITY<>NONE
;    on RECV :- only if PARITY<>NONE
;
;I hope that explains the default values etc...
;
;Protocol defaults for variables ... DO NOT CHANGE.
;These are the default values imposed upon us by the
;protocol ie. if the other side doesn't tell us
;explicitly what its values are for each field then
;we use the values given below.
PDPSIZ	EQU	5EH		;Send packet max size
PDPAD	EQU	00H		;Send padding
PDPADCH EQU	00H		;No pad char
PDEOL	EQU	CR		;Carriage return
PDQUOTE	EQU	'#'		;ordinary quote
PDQUOTE8 EQU	'&'
PDCHK	EQU	'1'		;1-char checksum
PDQUOTER EQU	' '		;no repeat quoting
;
;End of kermit protocol defaults.
;
MAXTRY	EQU	10H		;Default No. of retries on a packet.
IMXTRY	EQU	10H		;Default number of retries send initiate.
DSCHKT	EQU	'1'		;Block check we like
;
;
DRPSIZ	EQU	PDPSIZ		;Default Recv packet size
DSPSIZ	EQU	PDPSIZ		;Default send packet size
DSTIME	EQU	20		;Default send timeout sec
DRTIME	EQU	20		;Default recv timeout sec
;
DSPAD	EQU	PDPAD		;Default send padding.
DRPAD	EQU	PDPAD		;Default receive padding.
DSPADC	EQU	PDPADCH		;Default send pad char.
DRPADC	EQU	PDPADCH		;Default recv pad char.
;
DSEOL	EQU	PDEOL		;Default send EOL char.
DREOL	EQU	PDEOL		;Default recv EOL char.
DSQUOT	EQU	PDQUOTE		;Default send quote char.
DRQUOT	EQU	PDQUOTE		;Default recv quote char.
;
DSQUOTE8  EQU	PDQUOTE8	;Default quote8 (none!)
DRQUOTE8  EQU	PDQUOTE8	;Default quote8 (none!)
DSQUOTER  EQU	PDQUOTER	;Default repeat quote
DRQUOTER  EQU	PDQUOTER	;Default repeat quote
;
;
;Parity related fields
PAREVN	EQU	00H		;Even parity.
PARMRK	EQU	03H		;Mark parity.
PARNON	EQU	06H		;No parity.
PARODD	EQU	09H		;Odd parity.
PARSPC	EQU	0CH		;Space parity.
DEFPAR	EQU	PARNON		;Default parity.
IBMPAR	EQU	PARMRK		;IBM COMTEN's parity.
;
BUFSIZ	EQU	0
DIASW	EQU	01H		;Default is diagnostics on.
;
CMKEY	EQU	01H		;Parse a keyword.
CMIFI	EQU	02H		;Parse an input file spec (can be wild).
CMOFI	EQU	03H		;Parse an output file spec.
CMCFM	EQU	04H		;Parse a confirm.
CMTXT	EQU	05H		;Parse text.
CMIFIN	EQU	10H		;Parse an input file spec (but no
;dos calls (all preceeded by @)
@GET	EQU	13H		;get a byte from a file
@PUT	EQU	1BH		;put a byte in a file
@KBD	EQU	2BH		;scan keyboard and return
@DSP	EQU	33H		;put a character on screen
@PRT	EQU	3BH		;put a character on the printer
@KEYIN	EQU	40H		;get a line from keyboard
@KEY	EQU	49H		;wait for key from keyboard
@EXIT	EQU	402DH		;normal exit to dos
@ABORT	EQU	4030H		;abnormal exit to dos
@CMNDI	EQU	4405H		;execute command =>HL
@ERROR	EQU	4409H		;print dos error
@FSPEC	EQU	441CH		;process filespec
@INIT	EQU	4420H		;initialize a file
@OPEN	EQU	4424H		;open existing file
@CLOSE	EQU	4428H		;close open file
@KILL	EQU	442CH		;kill open file
@VER	EQU	443CH		;write a sector with verify
;
START	LD	(OLDSP),SP
	LD	SP,STACK
	CALL	MDMRST
	XOR	A		;ZERO A
	LD	(FCB),A		;SET FILE CLOSED FLAG
	LD	DE,VERSIO
	CALL	PRTSTR
	CALL	KERMIT
	JP	EXIT1
;
MDMRST
	IF	F_TRS80
	LD	A,(SPEED)	;trs80
	OUT	(RESET),A	;trs80
	OUT	(BAUDOUT),A	;trs80
	LD	A,108		;trs80
	OUT	(WRSTAT),A	;trs80
	ENDIF			;f_trs80
;
	IF	F_ZETA
	LD	A,82H		;zeta
	OUT	(WRSTAT),A	;zeta
	LD	A,40H		;zeta
	OUT	(WRSTAT),A	;zeta
	LD	A,0EH		;zeta
	OUT	(WRSTAT),A	;zeta
	LD	A,07H		;zeta
	OUT	(WRSTAT),A	;zeta
	ENDIF			;zeta
;
	IF	F_SYS80
	LD	A,RESETB	;sys80
	OUT	(RESETP),A	;sys80
	ENDIF			;sys80
;
	IF	F_ATERM
	LD	A,03H		;aterm
	OUT	(WRSTAT),A	;aterm
	LD	A,15H		;aterm
	OUT	(WRSTAT),A	;aterm
	LD	A,(SPEED)	;aterm
	OUT	(BAUDOUT),A	;aterm
	ENDIF
;
	RET
;
CMBLNK	PUSH	DE
	LD	DE,CLRTOP
	CALL	PRTSTR
	POP	DE
QUIT	RET
;
CONOUT	PUSH	DE
	PUSH	HL
	PUSH	BC
	PUSH	AF
	CALL	@DSP
	POP	AF
	POP	BC
	POP	HL
	POP	DE
	RET
;
PRTSTR	LD	A,(DE)
	CP	'$'
	RET	Z
	OR	A
	RET	Z
	CALL	CONOUT
	INC	DE
	JR	PRTSTR
;
CONIN	PUSH	DE
	CALL	@KBD
	POP	DE
	RET
;
KERMIT	LD	DE,FCB
	LD	A,(DE)
	BIT	7,A		;WAS FILE OPEN?
	CALL	NZ,@CLOSE	;CLOSE IT IF IT WAS
	LD	DE,KERM
	CALL	PROMPT
	LD	DE,COMTAB
	LD	HL,TOPHLP
	LD	A,CMKEY
	CALL	COMND
	JP	KERMT2
	LD	HL,KERMTB
	LD	C,A
	LD	B,0
	ADD	HL,BC
	JP	(HL)
;
KERMTB	JP	TELNET
	JP	EXIT
	JP	HELP
	JP	LOG
	JP	READ
	JP	SEND
	JP	SETCOM
	JP	SHOW
	JP	STATUS
	JP	FINISH
	JP	LOGOUT
	JP	BYE
	JP	DIR
	JP	ERA
;
KERMT2	LD	DE,ERMES1
	CALL	PRTSTR
	JP	KERMIT
KERMT3	LD	DE,ERMES3
	CALL	PRTSTR
	JP	KERMIT
;
SETPAR	PUSH	HL
	PUSH	BC
	LD	HL,PARITY
	LD	C,(HL)
	LD	B,0
	LD	HL,PARJMP
	ADD	HL,BC
	JP	(HL)
PARJMP	JP	EVEN
	JP	MARK
	JP	NONE
	JP	ODD
	JP	SPACE
NONE	JP	PARRET
EVEN	AND	7FH
	JP	PE,PARRET
	OR	80H
	JP	PARRET
MARK	OR	80H
	JP	PARRET
ODD	AND	7FH
	JP	PO,PARRET
	OR	80H
	JP	PARRET
SPACE	AND	7FH
PARRET	POP	BC
	POP	HL
	RET
;
;Character sending routines
OUTCHR	PUSH	DE
OUTCHR1
	IN	A,(RDSTAT)
	BIT	CTS,A
	JR	Z,OUTCHR1
	LD	A,E
	CALL	SETPAR
	OUT	(WRDATA),A
	POP	DE
	RET
INCHR
	IN	A,(RDSTAT)
	BIT	DAV,A
;
;System-80 DAV bit is inverted to the others.
	IF	F_SYS80
	JR	Z,INCHR2	;sys80
	ELSE
	JR	NZ,INCHR2	;trs80,Zeta,Aterm
	ENDIF
;
	CALL	CONIN
	OR	A
	JR	Z,INCHR
	CP	CR
	RET	Z
INCHR4	CP	1AH		;CONTROL-Z?
	JR	Z,INCHR5
	CP	18H		;CONTROL-X?
	JR	NZ,INCHR
INCHR5	ADD	A,20H
	LD	(CZSEEN),A
	RET
INCHR2
	IN	A,(RDDATA)
	LD	B,A
	LD	A,(PARITY)
	CP	PARNON
	LD	A,B
	JP	Z,RSKP
	AND	7FH	;if par used, make 7 bits.
	JP	RSKP
;
EXIT	LD	A,CMCFM
	CALL	COMND
	JP	KERMT3
EXIT1	LD	DE,FCB
	LD	A,(FCB)
	BIT	7,A
	CALL	NZ,@CLOSE	;JUST IN CASE
	LD	SP,(OLDSP)
	JP	@EXIT
HELP	LD	DE,TOPHLP
	CALL	PRTSTR
	JP	KERMIT
;
*GET	COMND/ASM		;COMMAND PARSER
*GET	KILLDIR/ASM		;KILL AND DIR COMMANDS
*GET	MORE/ASM		;MOST OF THE NON PROTOCOL RELATED
				;commands.
*GET	GET/ASM			;RECEIVE PROTOCOL
*GET	SEND/ASM		;SEND PROTOCOL
*GET	XFER/ASM		;PROTOCOL COMMON CODE
*GET	KERSTR/ASM		;STRINGS
;
	END	START
