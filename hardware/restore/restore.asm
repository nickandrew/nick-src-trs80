;********************************************
;* ************* For Newdos/80 Version two. *
;* ** Restore ** Written by Nicholas Andrew *
;* ************* Submitted on 16-May-1984   *
;* Requires: System-80/Trs-80 Model I       *
;* with 32K or 48K Ram, Newdos/80 Version 2 *
;* and an Editor/Assembler (such as Edtasm) *
;********************************************
;Newdos/80 Version 2 Function addresses:
COMBUF	EQU	4318H	;Address of command buffer
DOS	EQU	402DH	;No error exit
DOSERR	EQU	4409H	;Dos error exit
EXTRCT	EQU	441CH	;Extract a filespec
OPENEX	EQU	4424H	;Open an existing file
READRC	EQU	4436H	;Read a file's record
MESSDI	EQU	4467H	;Send message to display
EXTEND	EQU	4473H	;Insert default extension
HIMEM	EQU	4049H	;Address of Dos himem
;Program dependent equates follow:
ORIG48	EQU	0FC00H	;Origin for 48K machine.
ORIG32	EQU	0BC00H	;Origin for 32K machine.
CKSM48	EQU	0C842H	;For 48K machine
CKSM32	EQU	0BF02H	;For 32K machine
PATCH	EQU	04BDAH	;Address to patch Dos.
;These two equates must be set for memory size:
ORIGIN	EQU	ORIG48	;ORIG32 for 32K memory
CKSM	EQU	CKSM48	;CKSM32 for 32K memory
;Equate for system file lookup table.
TABLE	EQU	ORIGIN-256 ;System file lookup table.
;End of equates.
;Start of 'RESTORE/asm' program:
	ORG	PATCH
	LD	HL,4317H
	ORG	TABLE
	DEFW	0	;clear start of table.
	ORG	ORIGIN
RESTOR	LD	HL,COMBUF
	CALL	NXTWRD	;Bypass 'restore' command
	PUSH	HL
	LD	HL,TABLE
	PUSH	HL
	LD	(CRTPS),HL	;setup pointers
	DEC	HL
	LD	(CRLOAD),HL
	INC	HL
	POP	DE
	INC	DE
	LD	(HL),0
	LD	BC,255
	LDIR		;CLEAR SYSTEM FILE TABLE.
	CALL	SETUP	;PATCH DOS IN MEMORY
	POP	HL
RDNAME	LD	A,(HL)	;TEST FOR END OF COMMAND LINE.
	CP	0DH
	JR	NZ,NODOS
	LD	HL,(CRLOAD)  ;SET FINAL HIMEM VALUE
	LD	(HIMEM),HL
	LD	HL,MESS1
	CALL	MESSDI		;PRINT MESSAGE
	JP	DOS		;EXIT TO DOS
NODOS	CALL	GETNUM	;GET NUMBER OF SYSTEM FILE
	CALL	RDSYS	;READ INTO MEMORY & ADD TO TABLE.
	JR	RDNAME
;
;SUBROUTINE NEXTWORD: FINDS NEXT COMMAND WORD.
NXTWRD	LD	A,(HL)	;BYPASS WORD AT LOCATION HL
	INC	HL	;AND RETURN HL=START OF NEXT
	CP	21H	;WORD.
	JR	NC,NXTWRD
	DEC	HL
NEXV01	LD	A,(HL)
	INC	HL
	CP	20H
	JR	Z,NEXV01
	DEC	HL
	RET
;SUBROUTINE GETNUM: GET SYSTEM FILE NUMBER.
GETNUM	LD	(CST),HL  ;SAVE START OF WORD.
	PUSH	HL
	POP	BC
	LD	HL,0
GETV01	CALL	GETCH    ;GET DIGIT IN L (OR SP/CR
	JR	Z,GPAST  ;WITH NZ FLAG SET).
	LD	A,L
	LD	(CURSYS),A  ;SAVE NUMBER OF SYSFILE
	PUSH	BC
	POP	HL
	LD	(CEN),HL    ;SAVE END OF CURRENT WORD.
	RET
GPAST	PUSH	HL	;MULTIPLY HL BY 10 AND ADD L
	POP	DE
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	ADD	HL,HL
	ADD	A,L
	LD	L,A
	JR	GETV01	;CONTINUE SEARCH FOR NUMBERS
GETCH	LD	A,(BC)
	INC	BC
	CP	0DH	;TEST FOR CR CHARACTER
	JR	Z,CHEND	;IF SO, EXIT WITH NZ FLAG SET.
	CP	20H
	JR	NZ,GCHV01
GCHL01	LD	A,(BC)	;BYPASS ANY SPACES THEN EXIT
	INC	BC	;WITH NZ SET.
	CP	20H
	JR	Z,GCHL01
CHEND	LD	A,0FFH	;SET NZ FLAG AND RETURN.
	DEC	BC
	OR	A
	RET
GCHV01	CP	3AH
	JR	NC,GETCH ;DISREGARD ALPHA CHARACTERS:
	CP	30H
	JR	C,GETCH  ;NUMBERS ONLY FALL THROUGH.
	SUB	30H	;GET ACTUAL VALUE OF NUMBER
	LD	D,A
	XOR	A	;SET Z FLAG.
	LD	A,D
	RET
RDSYS	LD	HL,(CST)
	LD	DE,FCB
	CALL	EXTRCT	;EXTRACT 'SYSX' INTO FILE FCB.
	LD	HL,DEFEXT
	LD	DE,FCB
	CALL	EXTEND  ;ADD DEFAULT EXTENSION '/SYS'.
	LD	HL,BUFF1
	LD	DE,FCB
	LD	B,0
	CALL	OPENEX  ;OPEN FILE 'SYSXX/SYS'.
	JP	NZ,DOSERR ;IF DOS CAN'T OPEN THE FILE.
	LD	A,(CURSYS) ;GET NUMBER OF SYSFILE.
	LD	HL,(CRTPS)
LV00	LD	BC,0
	ADD	HL,BC
	LD	(HL),A	;POKE INTO TABLE
	INC	HL
	LD	DE,(CRLOAD)
	LD	(HL),E	;POKE ADDRESS OF LOADING
	INC	HL	;AREA INTO TABLE.
	LD	(HL),D
	INC	HL
	LD	(CRTPS),HL  ;SET TABLE POINTER.
	EX	DE,HL
	LD	(HIMEM),HL  ;SET HIMEM TEMPORARILY.
LV01	LD	DE,FCB
	CALL	READRC	;READ A RECORD INTO 'BUFF1'
	JR	NZ,LV02 ;IF DISK ERROR,OR EOF.
	LD	B,0	;POKE BUFFER B/WARDS INTO
	CALL	POKE	;LOADING AREA.
	JR	LV01
LV02	CP	1DH	;TEST FOR PARTIAL SECTOR
	JR	NZ,LV05
	LD	A,(FCB+8)
	LD	B,A
LV03	CALL	POKE	;POKE IN PARTIAL SECTOR.
LV04	LD	(CRLOAD),HL
	LD	HL,(CEN)
	RET
LV05	CP	1CH	;TEST FOR FULL LAST SECTOR.
	JP	NZ,DOSERR  ;IF NOT, THEN TAKE ERROR EXIT.
	JR	LV04
POKE	LD	DE,BUFF1  ;POKE #B BYTES
POKV01	LD	A,(DE)	  ;FROM BUFF1 UPWARDS
	LD	(HL),A	  ;TO HL DOWNWARDS.
	INC	DE
	DEC	HL
	DJNZ	POKV01
	RET
SETUP	LD	HL,PATCH	;SETUP DOS FOR RESTORE.
	LD	(HL),195	;POKE 'JP SLOAD' INTO
	LD	HL,SLOAD	;DOS MEMORY.
	LD	(PATCH+1),HL
	RET
SLOAD	LD	HL,4317H	;TEST IF SYSFILE ALREADY
	CP	(HL)		;IN MEMORY.
	JP	Z,4C19H		;IF SO, THEN EXECUTE.
	LD	(HL),A	;SET SYSFILE # IN MEMORY
	LD	C,A
	DEC	C
	DEC	C	;FIND TRUE SYSTEM NUMBER
	LD	HL,TABLE
SEARCH	LD	A,(HL)  ;SEARCH TABLE CONTENTS
	OR	A
	JR	NZ,BYPE
	LD	A,C	;IF END OF TABLE, GET SYSFILE #
	INC	A
	INC	A	;ADD 2
	LD	HL,4317H
	JP	4BE1H	;LET DOS LOAD SYSTEM FILE.
BYPE	CP	C
	JR	Z,MLOAD	;IF CORRECT NUMBER IN TABLE
	INC	HL	;ELSE FIND NEXT ENTRY.
	INC	HL
	INC	HL
	JR	SEARCH
MLOAD	INC	HL	;GET LOAD ADDRESS FROM TABLE
	LD	E,(HL)	;FILE IS WRITTEN IN STANDARD
	INC	HL	;FORMAT, BUT DOWNWARDS IN MEMORY.
	LD	D,(HL)
	EX	DE,HL
MLOV01	LD	A,(HL)	;READ BLOCK CODE
	DEC	HL
	CP	2
	JR	NZ,MLOV02
	DEC	HL	;GET EXECUTION ADDRESS
	LD	E,(HL)
	DEC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	(4C1EH),HL ;POKE INTO DOS MEMORY.
	JP	4C19H	;EXECUTE 'SYSXX/SYS'.
MLOV02	CP	1
	JR	Z,MLOV04 ;LOAD BLOCK INTO MEMORY
	LD	B,(HL)	;SKIP BLOCK: GET LENGTH
	DEC	HL
MLOV03	DEC	HL	;BYPASS APPROPRIATE NUMBER
	DJNZ	MLOV03	;OF BYTES.
	JR	MLOV01
MLOV04	LD	B,(HL)	;GET LENGTH OF LOAD BLOCK.
	DEC	HL
	LD	E,(HL)	;GET LOAD ADDRESS.
	DEC	HL
	LD	D,(HL)
	DEC	HL
	DEC	B
	DEC	B
MLOV05	LD	A,(HL)	;POKE INTO DESTINATION
	LD	(DE),A	;(USUALLY 4D00H-51FFH).
	DEC	HL	;HL IS DECREASING
	INC	DE	;DE IS INCREASING
	DJNZ	MLOV05
	JR	MLOV01
;Start of user messages.
MESS1	DEFM	'"Restore" Version 1.02 (15-Jan-84),'
	DEFB	0AH
	DEFM	'written by Nick Andrew.'
	DEFB	0AH
	DEFM	'Now patching Newdos/80 for System loader'
	DEFB	0DH
;Start of pointers, buffers etc...
CST	DEFW	0
CEN	DEFW	0
CRTPS	DEFW	TABLE
DEFEXT	DEFM	'SYS'
CURSYS	DEFB	0
CRLOAD	DEFW	TABLE-1
CKEN	DEFB	41H
BUFF1	DEFS	256
FCB	DEFS	32
;End of program.
	END	RESTOR