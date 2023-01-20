;compact.asm: Compress & remove patches on a /CMD file.
; Creation Date: Wednesday 28th December, 1983.
; Assembled OK 2021-01-13.
*GET	DOSCALLS
	ORG	5200H
	DEFS	256			; Use a low stack between DOS and the start
COMPACT	LD	SP,COMPACT-2
	CALL	SIGNON
	LD	HL,COMBUFF
	CALL	NEXTWORD
	PUSH	HL
	LD	DE,FCB1
	CALL	EXTRACT	;EXTRACT FILESPEC.
	POP	HL
	LD	DE,FCB2
	CALL	EXTRACT
	XOR	A
	LD	(COUNT_T),A
	LD	(N),A
	LD	(NUM),A
	LD	HL,BLKTBL2
	LD	(BLK2),HL
	LD	IX,BLKTBL+4
	LD	HL,DEFEXT1
	LD	DE,FCB1
	CALL	EXTEND
	LD	HL,DEFEXT2
	LD	DE,FCB2
	CALL	EXTEND
	LD	HL,BUFFER1
	LD	DE,FCB1
	LD	B,0
	CALL	OPEN$EX
	JP	NZ,DOSERR
	LD	HL,BLKTBL3
	LD	DE,BLKTBL3+1
	LD	(HL),0
	LD	BC,1023
	LDIR
SEARCH	CALL	READ1
	CP	2
	JR	Z,EXECADD
	CP	5
	JR	Z,SKIP
	CP	31
	JR	Z,SKIP
;ASSUME LOAD BLOCK.
	CALL	READ1
	LD	B,A
	CALL	READ1
	LD	L,A
	CALL	READ1
	LD	H,A
	CALL	SAVALL
	LD	(IX+0),L
	LD	(IX+1),H
	INC	IX
	INC	IX
	DEC	B
	DEC	B
LDBLK	CALL	READ1
	INC	HL
	DJNZ	LDBLK
	LD	(IX+0),L
	LD	(IX+1),H
	INC	IX
	INC	IX
	LD	A,(N)
	INC	A
	LD	(N),A
	JR	SEARCH
SKIP	CALL	READ1
	LD	B,A
SKYP	CALL	READ1
	DJNZ	SKYP
	JR	SEARCH
EXECADD	CALL	READ1
	CALL	READ1
	LD	L,A
	CALL	READ1
	LD	H,A
	LD	(EXEC),HL
	LD	DE,FCB1
	CALL	CLOSE
	JP	NZ,DOSERR
	LD	A,(N)
	LD	(SAFE),A
	CALL	BUBBLE
	LD	A,(SAFE)
	LD	(N),A
	LD	HL,BLKTBL+4
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
L110	CALL	INCT
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,BLKTBL
	ADD	HL,DE
	CALL	GET2
	EX	DE,HL
	LD	(ST),HL
	CALL	POKNTB
	EX	DE,HL
	CALL	GET2
	EX	DE,HL
	LD	(EN),HL
	EX	DE,HL
LOST	CALL	GET2
	EX	DE,HL
	LD	(ST1),HL
	EX	DE,HL
	CALL	GET2
	EX	DE,HL
	LD	(EN1),HL
	EX	DE,HL
	LD	A,(N)
	LD	B,A
	LD	A,(COUNT_T)
	CP	B
	JR	NZ,LOSV01
	LD	HL,(EN)
	CALL	POKNTB
	JP	PART2
LOSV01	LD	HL,(ST1)
	EX	DE,HL
	LD	HL,(EN)
	OR	A
	SBC	HL,DE
	JR	NC,LOSV12
	LD	HL,(EN)
	CALL	POKNTB
	JR	L110
LOSV12	LD	HL,(EN)
	EX	DE,HL
	LD	HL,(EN1)
	OR	A
	SBC	HL,DE
	JR	C,LOSV03
	LD	HL,(EN1)
	LD	(EN),HL
LOSV03	CALL	INCT
	INC	HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,BLKTBL
	ADD	HL,DE
	JR	LOST
INCT	LD	A,(COUNT_T)
	INC	A
	LD	L,A
	LD	(COUNT_T),A
	LD	H,0
	RET
GET2	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	RET
NEXTWORD	LD	A,(HL)
	CP	20H
	INC	HL
	JR	NZ,NEXTWORD
NEXV01	LD	A,(HL)
	CP	20H
	INC	HL
	JR	Z,NEXV01
	DEC	HL
	RET
READ1	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	DE,FCB1
	CALL	READ$BY
	POP	HL
	POP	DE
	POP	BC
	RET	Z
	JP	DOSERR
GETIX2	LD	L,(IX+0)
	LD	H,(IX+1)
	RET
GETIX3	LD	E,(IX+4)
	LD	D,(IX+5)
	RET
POKNTB	PUSH	DE
	EX	DE,HL
	LD	HL,(BLK2)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(BLK2),HL
	LD	(HL),255
	INC	HL
	LD	(HL),255
	EX	DE,HL
	PUSH	AF
	LD	A,(NUM)
	INC	A
	LD	(NUM),A
	POP	AF
	POP	DE
	RET
BUBBLE	LD	A,(N)
	DEC	A
	LD	(N),A
	RET	Z
	LD	B,A
	LD	C,0
	LD	IX,BLKTBL+4
BUBV01	CALL	GETIX2
	CALL	GETIX3
	EX	DE,HL
	OR	A
	SBC	HL,DE
	JR	NC,NOSWAP
	ADD	HL,DE
	LD	(IX+0),L
	LD	(IX+1),H
	LD	(IX+4),E
	LD	(IX+5),D
	INC	IX
	INC	IX
	CALL	GETIX2
	CALL	GETIX3
	LD	(IX+0),E
	LD	(IX+1),D
	LD	(IX+4),L
	LD	(IX+5),H
	DEC	IX
	DEC	IX
	LD	C,255
NOSWAP	INC	IX
	INC	IX
	INC	IX
	INC	IX
	DJNZ	BUBV01
	LD	A,255
	CP	C
	JR	Z,BUBBLE
	RET
VDUOUT	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	0033H
	POP	HL
	POP	DE
	POP	BC
	RET
SAVALL	PUSH	HL
	PUSH	DE
	PUSH	AF
	EX	DE,HL
	LD	HL,(CURSAV)
	LD	(HL),255
	INC	HL
	LD	(HL),B
	INC	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	A,(FCB1+5)
	LD	(HL),A
	INC	HL
	LD	A,(FCB1+10)
	LD	(HL),A
	INC	HL
	LD	A,(FCB1+11)
	LD	(HL),A
	INC	HL
	INC	HL
	LD	(CURSAV),HL
	POP	AF
	POP	DE
	POP	HL
	RET
PART2	LD	DE,FCB1
	LD	HL,BUFFER1
	LD	B,80H
	CALL	OPEN$EX
	JP	NZ,DOSERR
	LD	DE,FCB2
	LD	HL,BUFFER2
	LD	B,80H
	CALL	OPEN$NW
	JP	NZ,DOSERR
	LD	HL,BLKTBL2
	LD	(BCURR),HL
BKLOOP	LD	HL,(BCURR)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	DEC	HL
	LD	A,D
	AND	E
	CP	255
	JR	Z,FINISH
	CALL	CREATBK
	CALL	FILLBLK
	CALL	WRITBLK
	LD	HL,(BCURR)
	LD	DE,4
	ADD	HL,DE
	LD	(BCURR),HL
	JR	BKLOOP
FINISH	LD	HL,ENDATA
	LD	DE,FCB2
	LD	A,4
	LD	(LRECL2),A
	CALL	WRIT$RC
	JP	NZ,DOSERR
	LD	DE,FCB2
	CALL	CLOSE
	JP	NZ,DOSERR
	JP	DOS
CREATBK	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(BSTART),DE
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	DEC	DE
	LD	(BEND),DE
	LD	HL,(BSTART)
	EX	DE,HL
	OR	A
	SBC	HL,DE
	INC	HL
	LD	(VLNGTH),HL
	RET
FILLBLK	LD	HL,BLKTBL3
	LD	(BCURR3),HL
FILV81	LD	HL,(BCURR3)
	LD	DE,8
	ADD	HL,DE
	LD	(BCURR3),HL
	OR	A
	SBC	HL,DE
	LD	A,(HL)
	OR	A
	RET	Z
	INC	HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	DEC	HL
	DEC	HL
	PUSH	HL
	PUSH	DE
	LD	HL,(BSTART)
	OR	A
	EX	DE,HL
	SBC	HL,DE
	POP	DE
	POP	HL
	JR	C,FILV81
	PUSH	HL
	PUSH	DE
	LD	HL,(BEND)
	OR	A
	SBC	HL,DE
	POP	DE
	POP	HL
	JR	C,FILV81
	LD	A,(HL)
	DEC	A
	DEC	A
	LD	(LRECL1),A
	PUSH	HL
	LD	HL,(BSTART)
	EX	DE,HL
	OR	A
	SBC	HL,DE
	LD	DE,BUFF
	ADD	HL,DE
	PUSH	HL
	POP	IX
	POP	HL
	PUSH	IX
	INC	HL
	INC	HL
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	DE,FCB1
	CALL	POS$FCB
	POP	HL
	LD	DE,FCB1
	CALL	READ$RC
	JP	NZ,DOSERR
	JR	FILV81
WRITBLK	LD	A,(VLNGTH+1)
	LD	B,A
	LD	DE,BUFF
	LD	HL,(BSTART)
	OR	A
	JR	Z,WRIV82
WRIV81	PUSH	BC
	CALL	WRTBLK
	POP	BC
	DJNZ	WRIV81
WRIV82	LD	A,(VLNGTH)
	OR	A
	RET	Z
	LD	A,1
	CALL	WRITE2
	LD	A,(VLNGTH)
	LD	B,A
	INC	A
	INC	A
	CALL	WRITE2
	LD	A,L
	CALL	WRITE2
	LD	A,H
	CALL	WRITE2
WRIV83	LD	A,(DE)
	INC	DE
	CALL	WRITE2
	DJNZ	WRIV83
	RET
WRTBLK	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,1
	CALL	WRITE2
	LD	A,2
	CALL	WRITE2
	LD	A,L
	CALL	WRITE2
	LD	A,H
	CALL	WRITE2
	XOR	A
	LD	(LRECL2),A
	EX	DE,HL
	LD	DE,FCB2
	CALL	WRIT$RC
	JP	NZ,DOSERR
	POP	HL
	POP	DE
	POP	BC
	INC	H
	INC	D
	POP	AF
	RET
WRITE2	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	AF
	LD	A,1
	LD	(LRECL2),A
	LD	HL,TEMP
	LD	DE,FCB2
	POP	AF
	LD	(HL),A
	CALL	WRIT$RC
	JP	NZ,DOSERR
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
TEMP	DEFB	0
SIGNON	LD	HL,M$SIGN
	CALL	MESS$DI
	RET
M$SIGN	DEFM	'COMPACT: FILE COMPRESS AND PATCHING PROGRAM:'
	DEFB	0AH
	DEFM	'COPYRIGHT (C) 1983, ZETA MICROCOMPUTER SOFTWARE'
	DEFB	0AH
	DEFM	'P.O BOX 177, RIVERSTONE NSW 2765.'
	DEFB	0DH
N	DEFB	0
COUNT_T	DEFB	0
NUM	DEFB	0
ST	DEFW	0
EN	DEFW	0
ST1	DEFW	0
EN1	DEFW	0
BLK2	DEFW	BLKTBL2
CURSAV	DEFW	BLKTBL3
SAFE	DEFW	0
ENDATA	DEFB	2
	DEFB	2
EXEC	DEFW	0
BCURR	DEFW	0
BCURR3	DEFW	0
BSTART	DEFW	0
BEND	DEFW	0
VLNGTH	DEFW	0
DEFEXT1	DEFM	'ORI'
DEFEXT2	DEFM	'CMD'
FCB1	DEFS	32
FCB2	DEFS	32
LRECL1	EQU	FCB1+9
LRECL2	EQU	FCB2+9
BUFFER1	DEFS	256
BUFFER2	DEFS	256
BLKTBL	DEFW	0
	DEFW	0
	DEFW	0
	DEFW	0
	DEFS	504
BLKTBL2	DEFW	0
	DEFW	0
	DEFW	0
	DEFW	0
	DEFS	100
BLKTBL3	DEFS	1024
BUFF	DEFB	0
; NEWDOS/80 VERSION 2 FUNCTION ADDRESSES
COMBUFF	EQU	4318H	;ADDRESS OF COMMAND BUFFER
DOSCOM	EQU	4405H	;ENTER DOS AND EXECUTE COMMAND
DOSERR	EQU	4409H	;DOS ERROR EXIT
DEBUG	EQU	440DH	;ENTER DEBUG
ENQUEUE	EQU	4410H	;ENQUEUE USER INTERRUPT ROUTINE
DEQUEUE	EQU	4413H	;DEQUEUE USER INTERRUPT ROUTINE
ROTATE	EQU	4416H	;KEEP DRIVES ROTATING
DOSCMD	EQU	4419H	;EXECUTE DOS COMMAND AND RETURN
EXTRACT	EQU	441CH	;EXTRACT A FILESPEC
OPEN$NW	EQU	4420H	;OPEN A NEW OR EXISTING FILE
OPEN$EX	EQU	4424H	;OPEN AN EXISTING FILE
CLOSE	EQU	4428H	;CLOSE A FILE
KILL	EQU	442CH	;KILL A FILE
LOAD	EQU	442CH	;LOAD A FILE
EXECUTE	EQU	4433H	;LOAD THEN EXECUTE A FILE
READ$RC	EQU	4436H	;READ A FILE'S RECORD
WRIT$RC	EQU	4439H	;WRITE A RECORD TO A FILE
REWIND	EQU	443FH	;REWIND FCB
POS$FCB	EQU	4442H	;POSITION FCB TO SPECIFIED RECORD
BACKSP	EQU	4445H	;BACKSPACE FCB ONE RECORD
POS$EOF	EQU	4448H	;POSITION FCB TO EOF
ALLOCAT	EQU	444BH	;ALLOCATE FILE SPACE
SELECT	EQU	445BH	;SELECT A DRIVE
MOUNT	EQU	445EH	;TEST FOR MOUNTED DISK
NAM$ENQ	EQU	4461H	;ENQUEUE *NAME ROUTINE
NAM$DEQ	EQU	4464H	;DEQUEUE *NAME ROUTINE
MESS$DI	EQU	4467H	;SEND MESSAGE TO DISPLAY
MESS$PR	EQU	446AH	;SEND MESSAGE TO PRINTER
TIME	EQU	446DH	;GET CURRENT TIME
DATE	EQU	4470H	;GET CURRENT DATE
EXTEND	EQU	4473H	;INSERT DEFAULT EXTENSION
READ$BY	EQU	0013H	;READ A BYTE FROM A FILE
WRIT$BY	EQU	001BH	;WRITE A BYTE TO A FILE
; END OF DOS ROUTINE CALL ADDRESSES.
	END	COMPACT
