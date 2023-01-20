;***********
; 09-Mar-86: This is the Authorised, Verified, master
;copy of the REGIONS source.
;
	ORG	5200H
*GET	DOSCALLS
; CREATION DATE: TUESDAY 12TH JULY, 1983.
;REGIONS/EDT: FINDS OUT ALL BLOCKS OF MEMORY USED BY
; A /CMD FILE. TO RUN TYPE 'REGIONS FILESPEC'.
; IF FILE ON ANOTHER DISK, THEN 'REGIONS $FILESPEC'.
; FOR LOTS OF FILES, 'REGIONS *'
REGIONS	LD	HL,COM_BUFF
	CALL	NEXTWORD
	INC	HL
	XOR	A
	LD	(MULTIP),A
	LD	A,(HL)
	CP	'$'
	JR	NZ,OP_FILE
	INC	HL
	PUSH	HL
	LD	HL,DSKMESS
	CALL	MESS_DO
KBD	LD	A,(3840H)
	AND	1
	JR	Z,KBD
	POP	HL
OP_FILE	CP	'*'
	JR	NZ,OP_V01
	LD	A,255
	LD	(MULTIP),A
	JP	INPFILE
OP_V01	LD	DE,FCB
	CALL	DOS_EXTRACT
	XOR	A
	LD	(COUNT_T),A
	LD	(N),A
	LD	(OVERLAP),A
	LD	IX,BLKTBL+4
	LD	HL,DEFEXT
	LD	DE,FCB
	CALL	DOS_EXTEND
	LD	HL,BUFFER
	LD	DE,FCB
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,DOS_ERROR
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
	PUSH	HL
	LD	HL,STMESS
	CALL	MESS_DO
	POP	HL
	CALL	HEX
	LD	A,0DH
	CALL	0033H
	LD	DE,FCB
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	LD	A,(N)
	LD	(SAFE),A
	CALL	BUBBLE
	LD	A,(SAFE)
	LD	(N),A
	LD	HL,BASMESS
	CALL	MESS_DO
	LD	HL,BLKTBL+4
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	CALL	HEX
	LD	A,0DH
	CALL	0033H
L110	CALL	INCT
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,BLKTBL
	ADD	HL,DE
	CALL	GET2
	EX	DE,HL
	LD	(ST),HL
	PUSH	HL
	PUSH	DE
	CALL	PRINT1
	POP	DE
	POP	HL
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
	CALL	PRINT2
	LD	A,(OVERLAP)
	OR	A
	JR	NZ,OVER
	LD	HL,NVMESS
	CALL	MESS_DO
	JP	OUT
OVER	LD	HL,OVMESS
	CALL	MESS_DO
OUT	LD	A,(MULTIP)
	OR	A
	JP	Z,DOS_NOERROR
	JP	INPFILE
	JP	DOS_NOERROR
LOSV01	LD	HL,(ST1)
	EX	DE,HL
	LD	HL,(EN)
	OR	A
	SBC	HL,DE
	JR	NC,LOSV02
	CALL	PRINT2
	JR	L110
LOSV02	JR	Z,LOSV12
	LD	A,255
	LD	(OVERLAP),A
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
NEXTWORD	INC	HL
	LD	A,(HL)
	CP	21H
	JR	NC,NEXTWORD
	RET
READ1	LD	DE,FCB
	CALL	$GET
	RET	Z
	JP	DOS_ERROR
PRINT2	LD	HL,(EN)
	CALL	HEX
	LD	A,0DH
	CALL	0033H
	RET
PRINT1	LD	HL,P1MESS
	CALL	MESS_DO
	LD	HL,(ST)
	CALL	HEX
	LD	HL,P2MESS
	CALL	MESS_DO
	RET
GETIX2	LD	L,(IX+0)
	LD	H,(IX+1)
	RET
GETIX3	LD	E,(IX+4)
	LD	D,(IX+5)
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
HEX	PUSH	HL
	LD	A,H
	CALL	HEX1
	POP	HL
	LD	A,L
	CALL	HEX1
	LD	A,'H'
	PUSH	HL
	PUSH	DE
	CALL	0033H
	POP	DE
	POP	HL
	RET
HEX1	PUSH	AF
	AND	0F0H
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	CP	10
	JR	C,HEXV01
	ADD	A,7
HEXV01	ADD	A,30H
	PUSH	DE
	PUSH	HL
	CALL	0033H
	POP	HL
	POP	DE
	POP	AF
	AND	0FH
	CP	10
	JR	C,HEXV02
	ADD	A,7
HEXV02	ADD	A,30H
	PUSH	DE
	PUSH	HL
	CALL	0033H
	POP	HL
	POP	DE
	RET
INPFILE	LD	HL,INPMESS
	CALL	MESS_DO
	LD	HL,BUFFER
	LD	B,31
	CALL	0040H
	JP	C,DOS_NOERROR
	LD	HL,BUFFER
	JP	OP_V01
INPMESS	DEFM	'INPUT FILESPEC OR <BREAK>: '
	DEFB	03H
DSKMESS	DEFM	'INSERT DESTINATION DISK AND HIT <ENTER>'
	DEFB	0DH
STMESS	DEFM	'EXECUTION ADDRESS IS '
	DEFB	03H
BASMESS	DEFM	'BASE ADDRESS OF CODE '
	DEFB	03H
P1MESS	DEFM	'LOADS FROM '
	DEFB	03H
P2MESS	DEFM	' TO '
	DEFB	03H
NVMESS	DEFM	'FILE DOES NOT OVERLAP ITSELF'
	DEFB	0DH
OVMESS	DEFM	'FILE OVERLAPS ITSELF'
	DEFB	0DH
N	DEFB	0
COUNT_T	DEFB	0
ST	DEFW	0
EN	DEFW	0
ST1	DEFW	0
EN1	DEFW	0
SAFE	DEFW	0
OVERLAP	DEFB	0
MULTIP	DEFB	0
DEFEXT	DEFM	'CMD'
FCB	DEFS	32
BUFFER	DEFS	256
BLKTBL	DEFW	0
	DEFW	0
	DEFW	0
	DEFW	0
	END	REGIONS
