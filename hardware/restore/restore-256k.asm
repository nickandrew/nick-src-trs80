;Restore: SYSres for 256k ram system.
;
*GET	DOSCALLS
CR	EQU	0DH
;
	COM	'<Restore 1.1  27-Nov-86>'
;
;Newdos/80 Version 2 Function addresses:
COMBUF	EQU	4318H		;Address of command buffer
DOS	EQU	402DH		;No error exit
PATCH	EQU	04BDAH		;Address to patch Dos.
PAGE1	EQU	80H		;table page.
ADDR1	EQU	8000H
OLD1	EQU	10H
PAGE2	EQU	84H		;system file page.
ADDR2	EQU	8400H
OLD2	EQU	11H
TABLE_PAGE	EQU	0FFH
;
;
	ORG	PATCH		;Back off any changes
	LD	HL,4317H
	ORG	5300H
START
	LD	SP,START
	LD	A,(HL)
	CP	CR
	JR	Z,USAGE
	OR	A
	JR	Z,USAGE
;
	PUSH	HL
;
	LD	HL,SLOAD
	LD	(HIMEM),HL
;Swap in table page and first data page.
	LD	B,PAGE1
	LD	C,10H
	LD	A,TABLE_PAGE
	OUT	(C),A
	LD	B,PAGE2
	LD	A,(MIN_PAGE)
	OUT	(C),A
	LD	HL,ADDR1
	LD	(TABLE_PTR),HL
;
	LD	(HL),0		;empty the table.
	LD	HL,ADDR2+100H	;bypass table!
	LD	(RAM_PTR),HL
;
;;;;	CALL	SETUP		;PATCH DOS IN MEMORY
	POP	HL
RDNAME	LD	A,(HL)		;TEST FOR END OF COMMAND LINE.
	CP	CR
	JR	NZ,NOTEND
;
;Re-address original pages
	LD	B,PAGE1
	LD	C,10H
	LD	A,OLD1
	OUT	(C),A
	LD	B,PAGE2
	LD	A,OLD2
	OUT	(C),A
;
	CALL	SETUP		;fix the dos
	LD	HL,MESS1
	CALL	MESS_0
	JP	DOS		;EXIT TO DOS
;
USAGE
	LD	HL,M_USAGE
	CALL	MESS_0
	JP	DOS
;
NOTEND	CALL	GETNUM		;GET NUMBER OF SYSTEM FILE
	PUSH	HL
	CALL	RDSYS		;READ INTO MEMORY & ADD TO TABLE.
	POP	HL
	JR	RDNAME
;
;NEXTWORD: FINDS NEXT COMMAND WORD.
NEXTWORD
	LD	A,(HL)		;BYPASS WORD AT LOCATION HL
	INC	HL		;AND RETURN HL=START OF NEXT
	CP	21H		;WORD.
	JR	NC,NEXTWORD
	DEC	HL
NEXV01	LD	A,(HL)
	INC	HL
	CP	20H
	JR	Z,NEXV01
	DEC	HL
	RET
;
;SUBROUTINE GETNUM: GET SYSTEM FILE NUMBER.
GETNUM	LD	(CST),HL	;SAVE START OF WORD.
	PUSH	HL
	POP	BC
	LD	HL,0
GETV01	CALL	GETCH		;GET DIGIT IN L (OR SP/CR
	JR	Z,GPAST		;WITH NZ FLAG SET).
	LD	A,L
	LD	(CURSYS),A	;SAVE NUMBER OF SYSFILE
	PUSH	BC
	POP	HL
	LD	(CEN),HL	;SAVE END OF CURRENT WORD.
	RET
GPAST	PUSH	HL		;MULTIPLY HL BY 10 AND ADD L
	POP	DE
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	ADD	HL,HL
	ADD	A,L
	LD	L,A
	JR	GETV01		;CONTINUE SEARCH FOR NUMBERS
GETCH	LD	A,(BC)
	INC	BC
	CP	CR		;TEST FOR CR CHARACTER
	JR	Z,CHEND		;IF SO, EXIT WITH NZ FLAG SET.
	CP	20H
	JR	NZ,GCHV01
GCHL01	LD	A,(BC)		;BYPASS ANY SPACES THEN EXIT
	INC	BC		;WITH NZ SET.
	CP	20H
	JR	Z,GCHL01
CHEND	LD	A,0FFH		;SET NZ FLAG AND RETURN.
	DEC	BC
	OR	A
	RET
GCHV01	CP	3AH
	JR	NC,GETCH	;DISREGARD ALPHA CHARACTERS:
	CP	30H
	JR	C,GETCH		;NUMBERS ONLY FALL THROUGH.
	SUB	30H		;GET ACTUAL VALUE OF NUMBER
	LD	D,A
	XOR	A		;SET Z FLAG.
	LD	A,D
	RET
;
RDSYS	LD	HL,(CST)
	LD	DE,FCB
	CALL	DOS_EXTRACT	;EXTRACT 'SYSX' INTO FILE FCB.
	LD	HL,DEFEXT
	LD	DE,FCB
	CALL	DOS_EXTEND	;ADD DEFAULT EXTENSION '/SYS'.
	LD	HL,BUFF1
	LD	DE,FCB
	LD	B,0
	CALL	DOS_OPEN_EX	;OPEN FILE 'SYSXX/SYS'.
	RET	NZ		;don't add if cannot open
	LD	A,(CURSYS)	;GET NUMBER OF SYSFILE.
	LD	HL,(TABLE_PTR)
LV00
	LD	(HL),A		;poke sys number
	INC	HL
	LD	A,(MIN_PAGE)
	LD	(HL),A		;poke page number.
	INC	HL
	LD	DE,(RAM_PTR)
	LD	A,D
	AND	3		;convert to 1k offset
	LD	D,A
	LD	(HL),E		;poke load address
	INC	HL
	LD	(HL),D
LV01	LD	DE,FCB
	CALL	DOS_READ_SECT	;READ A RECORD INTO 'BUFF1'
	JR	NZ,LV02		;IF DISK ERROR,OR EOF.
	LD	B,0		;POKE BUFFER B/WARDS INTO
	CALL	POKE		;LOADING AREA.
	JR	LV01
LV02	CP	1DH		;TEST FOR PARTIAL SECTOR
	JR	NZ,LV05
	LD	A,(FCB+8)
	LD	B,A
LV03	CALL	POKE		;POKE IN PARTIAL SECTOR.
LV04
	LD	HL,(TABLE_PTR)
	LD	BC,4
	ADD	HL,BC
	LD	(TABLE_PTR),HL
	LD	(HL),0
	LD	HL,(CEN)
	RET
;
LV05	CP	1CH		;TEST FOR FULL LAST SECTOR.
	JP	NZ,DOS_ERROR	;IF NOT, THEN TAKE ERROR EXIT.
	JR	LV04
;
POKE	LD	DE,BUFF1	;POKE #B BYTES
	LD	HL,(RAM_PTR)
POKV01	LD	A,(DE)		;FROM BUFF1 UPWARDS
	LD	(HL),A
	INC	HL
	LD	A,L
	OR	A
	JR	NZ,POKV02
	LD	A,H
	AND	3
	JR	NZ,POKV02
;Switch to next lower page of ram.
	PUSH	BC
	LD	HL,ADDR2
	LD	(RAM_PTR),HL
	LD	A,(MIN_PAGE)
	DEC	A
	LD	(MIN_PAGE),A
	LD	B,PAGE2
	LD	C,10H
	OUT	(C),A
	LD	HL,ADDR2
;
	POP	BC
POKV02
	INC	DE
	DJNZ	POKV01
	LD	(RAM_PTR),HL
	RET
;
SETUP	LD	HL,PATCH	;setup dos for restore.
	LD	(HL),195	;poke 'JP sload' into
	LD	HL,SLOAD	;dos.
	LD	(PATCH+1),HL
	RET
;
;Variables etc used only by initial loader.
BUFF1	DEFS	256
FCB	DEFS	32
MESS1	DEFM	'"Restore" for 256k paged ram,',CR
	DEFM	'Author: N.P Andrew.',CR
	DEFM	'Now patching Newdos/80 for SYStem loader',CR,0
M_USAGE	DEFM	'Usage: restore sys1 sys2 ... sysn',CR,0
;
;Dos jumps to sload when it requires a system file.
	ORG	0FA00H
SLOAD	LD	HL,4317H	;TEST IF SYSFILE ALREADY
	CP	(HL)		;IN MEMORY.
	JP	Z,4C19H		;IF SO, THEN EXECUTE.
	LD	(HL),A		;SET SYSFILE # IN MEMORY
	LD	C,A
	DEC	C
	DEC	C		;FIND TRUE SYSTEM NUMBER
;
;Address the table.
	PUSH	BC
	LD	B,PAGE1
	LD	C,10H
	LD	A,TABLE_PAGE
	OUT	(C),A
	POP	BC
	LD	HL,ADDR1
SEARCH	LD	A,(HL)		;SEARCH TABLE CONTENTS
	OR	A
	JR	Z,NOTFOUND
	CP	C
	JR	Z,MLOAD
	INC	HL		;ELSE FIND NEXT ENTRY.
	INC	HL
	INC	HL
	INC	HL
	JR	SEARCH
;
NOTFOUND
	PUSH	BC
;Re-address old memory there.
	LD	B,PAGE1
	LD	C,10H
	LD	A,OLD1
	OUT	(C),A
	POP	BC
;
	LD	A,C		;IF END OF TABLE, GET SYSFILE #
	ADD	A,2
	LD	HL,4317H
	JP	4BE1H		;LET DOS LOAD SYSTEM FILE.
MLOAD	INC	HL		;GET address from table
	LD	A,(HL)
	LD	(THIS_PAGE),A
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
;
;Address the starting page.
	LD	B,PAGE1
	LD	C,10H
	OUT	(C),A
;
	LD	HL,ADDR1	;offset...
	ADD	HL,DE
	LD	(RAM_PTR),HL
;
MLOV01	CALL	GET_BYTE	;read block type.
	CP	2
	JR	NZ,MLOV02
	CALL	GET_BYTE
	CALL	GET_BYTE
	LD	E,A
	CALL	GET_BYTE
	LD	D,A
	EX	DE,HL
	LD	(4C1EH),HL	;set exec address
;
;Readdress original page.
	LD	B,PAGE1
	LD	C,10H
	LD	A,OLD1
	OUT	(C),A
;
	JP	4C19H		;execute the sys file.
;
MLOV02	CP	1
	JR	Z,MLOV04	;LOAD BLOCK INTO MEMORY
	CALL	GET_BYTE	;skip block
	LD	B,A
MLOV03	CALL	GET_BYTE
	DJNZ	MLOV03
	JR	MLOV01
MLOV04	CALL	GET_BYTE	;get length of load block
	LD	B,A
	CALL	GET_BYTE	;get load addr
	LD	E,A
	CALL	GET_BYTE
	LD	D,A
	DEC	B
	DEC	B
MLOV05	CALL	GET_BYTE
	LD	(DE),A
	INC	DE		;DE IS INCREASING
	DJNZ	MLOV05
	JR	MLOV01
;
GET_BYTE
	LD	HL,(RAM_PTR)
	LD	A,(HL)
	PUSH	AF
	INC	HL
	LD	(RAM_PTR),HL
	LD	A,L
	OR	A
	JR	NZ,GB_01
	LD	A,H
	AND	3
	JR	NZ,GB_01
;Load next page in.
	PUSH	BC
	LD	B,PAGE1
	LD	C,10H
	LD	A,(THIS_PAGE)
	DEC	A
	LD	(THIS_PAGE),A
	OUT	(C),A
;
	LD	HL,ADDR1
	LD	(RAM_PTR),HL
	POP	BC
;
GB_01	POP	AF
	RET
;
MESS_0	LD	A,(HL)
	OR	A
	RET	Z
	CALL	33H
	INC	HL
	JR	MESS_0
;
;
;Start of pointers, buffers etc...
MIN_PAGE	DEFB	0FFH	;use highest page #
TABLE_PTR	DEFW	0
RAM_PTR		DEFW	0
THIS_PAGE	DEFB	0
;
CST	DEFW	0
CEN	DEFW	0
DEFEXT	DEFM	'SYS'
CURSYS	DEFB	0
CKEN	DEFB	41H
;
	END	START
