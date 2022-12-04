;bb7func.asm:  BB7 functions for C programs
;Last updated: 18-Jun-89
;
_CREATEF		;create a file if nonex
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)	;de == filename
	EX	DE,HL
	LD	DE,CF_FCB
	CALL	EXTRACT
	LD	HL,-1
	RET	NZ
	LD	HL,0
	LD	B,0
	CALL	DOS_OPEN_NEW
	LD	HL,-1
	RET	NZ
	CALL	DOS_CLOSE
	LD	HL,0
	RET
;
CF_FCB	DEFS	32
;
_FIXPERM		;set file to be readable/writable
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)	;de == fp
;
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)	;de == fcb
	INC	DE
	LD	A,(DE)
	AND	0F8H
	OR	0
	LD	(DE),A
	RET
;
_GETFREE
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL		;hl == freemap
	LD	DE,0
	LD	B,0
GF_1
	LD	A,(HL)
	CP	0FFH
	JR	NZ,GF_2
	INC	HL
	DJNZ	GF_1
	LD	HL,-1
	RET
;
GF_2	DEC	B
	LD	A,B
	XOR	0FFH
	PUSH	HL	;addr of free bit(s)
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	C,L
	LD	B,H
	POP	HL	;addr of free bit(s)
	LD	E,1
GF_3
	LD	A,(HL)
	AND	E
	JR	Z,GF_4
	INC	BC
	ADD	A,A
	LD	E,A
	JR	GF_3
;
GF_4
	LD	A,(HL)
	OR	E
	LD	(HL),A
	PUSH	BC
	POP	HL
	RET
;
_PUTFREE
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL	;hl == block number
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
	PUSH	HL
	LD	HL,6
	ADD	HL,SP	;push,ret,parm 2,parm 1
	LD	E,(HL)
	INC	HL
	LD	D,(HL)	;de == freemap
	POP	HL
;
	ADD	HL,DE
	LD	E,1
PF_1	LD	A,C
	OR	A
	JR	Z,PF_2
	SLA	E
	DEC	C
	JR	PF_1
PF_2
	LD	A,E
	CPL
	AND	(HL)
	LD	(HL),A
	RET
;
_SECREAD
	LD	HL,4
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = fp
;
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = fcb
;
;Load HL with the buffer address in case the file is
;in byte-by-byte I/O mode.
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	PUSH	BC
	POP	HL
;
	CALL	DOS_READ_SECT
	LD	HL,-1
	RET	NZ
;
;If file is in byte I/O mode, buffer is already loaded!
	INC	DE
	LD	A,(DE)
	DEC	DE
	BIT	7,A
	JR	Z,SECR_01
	LD	HL,0
	RET
;
;In full sector mode, so copy buffers.
SECR_01
;Copy from the FCB buffer to our buffer
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc == buffer
;
	LD	HL,3
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = fcb buffer
;
	PUSH	BC
	POP	HL
	EX	DE,HL
	LD	BC,256
	LDIR
	LD	HL,0
	RET
;
_SECWRITE
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc == buffer
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de == fp
;
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de == fcb
;
	INC	DE
	LD	A,(DE)
	DEC	DE
	BIT	7,A
	JR	Z,SECW_01	;not byte I/O mode
;
;Byte I/O therefore load hl with buffer and de with fcb.
	PUSH	BC
	POP	HL
	JR	SECW_02
;
SECW_01
	PUSH	DE		;fcb
	LD	HL,3
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de == fcb buffer
	PUSH	BC		;buffer
	POP	HL		;hl == buffer
;
	LD	BC,256
	LDIR
	POP	DE		;fcb
;
SECW_02
	CALL	DOS_WRIT_SECT
	LD	HL,0
	RET	Z
	DEC	HL
	RET
;
_SECSEEK
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc == sector #
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de == fp
;
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de == fcb
;
	PUSH	BC
	POP	HL
	LD	C,0
	CALL	DOS_POS_RBA
	LD	HL,0
	RET	Z
	LD	HL,-1
	RET
;
_ZEROMEM
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;Count
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;Address
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
_USER_SEA
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	CALL	USER_SEARCH
	LD	HL,-1
	RET	NZ
;
	LD	HL,UF_NAME
	LD	(_USER_FIE),HL	;user_field
	LD	HL,(UF_UID)
	RET
;
;End of bb7func
