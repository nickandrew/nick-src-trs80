;bb7: BB text file handling routines, 14-Dec-87.
;
_BLKPOS		DEFW	0
_THISBLK	DEFW	0
_NEXTBLK	DEFW	0
_NEWBLK		DEFW	0
_THISMSG	DEFW	0
_PRIORMSG	DEFW	0
_NEXTMSG	DEFW	0
;
_BLOCK		DEFS	256
_FREEMAP	DEFS	256
;
_GETINT
	LD	DE,_BLOCK
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	RET
;
_SETINT
	PUSH	DE
	LD	DE,_BLOCK
	ADD	HL,DE
	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	RET
;
_BPUTS
_BPUTS_1
	LD	A,(HL)
	OR	A
	JR	Z,_BPUTS_2
;
	PUSH	HL
	LD	HL,(_BLKPOS)
	LD	A,H
	OR	L
	JR	NZ,_BPUTS_3
;
	CALL	_GETFREE
	LD	(_NEXTBLK),HL
	LD	A,H
	AND	L
	CP	0FFH
	JR	Z,_BPUTS_4	;Disk full.
	EX	DE,HL
	LD	HL,0
	CALL	_SETINT
	CALL	_WRITEBLK
	JR	NZ,_BPUTS_4
	LD	HL,(_NEXTBLK)
	CALL	_SEEKTO
	LD	HL,_BLOCK
	PUSH	HL
	LD	HL,256
	PUSH	HL
	CALL	_ZEROMEM
	POP	HL
	POP	HL
	LD	HL,2
	LD	(_BLKPOS),HL
;
_BPUTS_3
	LD	DE,(_BLKPOS)
	LD	HL,_BLOCK
	ADD	HL,DE
	INC	E
	LD	(_BLKPOS),DE
	POP	DE
	LD	A,(DE)
	LD	(HL),A
	EX	DE,HL
	INC	HL
	JR	_BPUTS_1
;
_BPUTS_2
	LD	HL,0
	RET
_BPUTS_4
	POP	HL
	LD	HL,-1
	RET
;
_BPUTC
_BPUTC_1
	PUSH	HL
	LD	HL,(_BLKPOS)
	LD	A,H
	OR	L
	JR	NZ,_BPUTC_3
;
	CALL	_GETFREE
	LD	(_NEXTBLK),HL
	LD	A,H
	AND	L
	CP	0FFH
	JR	Z,_BPUTC_4	;Disk full.
	EX	DE,HL
	LD	HL,0
	CALL	_SETINT
	CALL	_WRITEBLK
	JR	NZ,_BPUTC_4
	LD	HL,(_NEXTBLK)
	CALL	_SEEKTO
	LD	HL,_BLOCK
	PUSH	HL
	LD	HL,256
	PUSH	HL
	CALL	_ZEROMEM
	POP	HL
	POP	HL
	LD	HL,2
	LD	(_BLKPOS),HL
;
_BPUTC_3
	LD	DE,(_BLKPOS)
	LD	HL,_BLOCK
	ADD	HL,DE
	INC	E
	LD	(_BLKPOS),DE
	POP	DE
	LD	(HL),E
_BPUTC_2
	LD	HL,0
	RET
_BPUTC_4
	POP	HL
	LD	HL,-1
	RET
;
_BFLUSH
	LD	HL,(_BLKPOS)
	LD	A,H
	OR	L
	JR	NZ,_BFLUSH_1
	LD	HL,256
	LD	(_BLKPOS),HL
_BFLUSH_1
	CALL	_WRITEBLK
	RET
;
_BGETC
	LD	HL,(_BLKPOS)
	LD	A,L
	OR	A
	JR	NZ,_BGETC_1
;
	LD	HL,0
	CALL	_GETINT
	LD	(_THISBLK),HL
	LD	A,H
	OR	L
	LD	HL,-1
	RET	Z
	LD	HL,(_THISBLK)
	CALL	_SEEKTO
	CALL	_READBLK
	LD	HL,-1
	RET	NZ
	LD	HL,2
	LD	(_BLKPOS),HL
;
_BGETC_1
	LD	DE,(_BLKPOS)
	LD	HL,_BLOCK
	ADD	HL,DE
	INC	E
	LD	(_BLKPOS),DE
	LD	L,(HL)
	LD	H,0
	RET
;
_GETFREE
	LD	DE,0
	LD	B,0
	LD	HL,_FREEMAP
_GF_1
	LD	A,(HL)
	CP	0FFH
	JR	NZ,_GF_2
	INC	HL
	DJNZ	_GF_1
	LD	HL,-1
	RET
;
_GF_2	DEC	B
	LD	A,B
	XOR	0FFH
	PUSH	HL
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	C,L
	LD	B,H
	POP	HL
	LD	E,1
_GF_3
	LD	A,(HL)
	AND	E
	JR	Z,_GF_4
	INC	BC
	ADD	A,A
	LD	E,A
	JR	_GF_3
;
_GF_4
	LD	A,(HL)
	OR	E
	LD	(HL),A
	PUSH	BC
	POP	HL
	RET
;
_PUTFREE
;
	LD	A,L
	AND	7
	LD	C,A	;low 3 bits
;
	SRL	H
	RR	L
	SRL	H
	RR	L
	SRL	H
	RR	L
;
	LD	DE,_FREEMAP
	ADD	HL,DE
	LD	E,1
_PF_1	LD	A,C
	OR	A
	JR	Z,_PF_2
	SLA	E
	DEC	C
	JR	_PF_1
_PF_2
	LD	A,E
	CPL
	AND	(HL)
	LD	(HL),A
	RET
;
_READBLK
	LD	DE,TXT_FCB
	CALL	DOS_READ_SECT
	LD	HL,0
	RET	Z
	LD	HL,-1
	RET
;
_WRITEBLK
	LD	DE,TXT_FCB
	CALL	DOS_WRIT_SECT
	LD	HL,0
	RET	Z
	LD	HL,-1
	RET
;
_SEEKTO
	LD	C,0
	LD	DE,TXT_FCB
	CALL	DOS_POS_RBA
	LD	HL,0
	RET	Z
	LD	HL,-1
	RET
;
_READFREE
	LD	DE,TXT_FCB
	CALL	DOS_REWIND
	CALL	DOS_READ_SECT
	LD	HL,_BLOCK
	LD	DE,_FREEMAP
	LD	BC,256
	LDIR
	RET
;
_WRITEFRE
	LD	HL,_FREEMAP
	LD	DE,_BLOCK
	LD	BC,256
	LDIR
	LD	DE,TXT_FCB
	CALL	DOS_REWIND
	CALL	DOS_WRIT_SECT
	RET
;
_ZEROMEM
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	D,0
ZMEM1	LD	A,B
	OR	C
	RET	Z
	LD	(HL),D
	INC	HL
	DEC	BC
	JR	ZMEM1
;
BGETC
	PUSH	HL
	CALL	_BGETC
	LD	A,H
	OR	A
	LD	A,L
	POP	HL
	RET
;
BPUTC
	PUSH	HL
	LD	L,A
	LD	H,0
	CALL	_BPUTC
	LD	A,H
	OR	A
	POP	HL
	RET
;
;End of bb7
