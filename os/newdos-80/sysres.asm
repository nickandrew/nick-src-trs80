;SYSRES/EDT: LOADS IN VARIOUS SYSTEM FILES
;TO MEMORY THEN ACTS AS SYSLOAD.
ORIG	EQU	0FC00H
	ORG	ORIG
SYSRES	LD	HL,4BDAH
	LD	(HL),21H	;RESET OLD
	INC	HL
	LD	(HL),17H
	INC	HL
	LD	(HL),43H
	LD	HL,4318H
	CALL	NEXTWORD
	PUSH	HL
	LD	HL,TABLE
	PUSH	HL
	POP	DE
	INC	DE
	LD	(HL),0
	LD	BC,255
	LDIR
	POP	HL
RDSYS	LD	A,(HL)
	CP	0DH
	JP	NZ,NODOS
	LD	HL,(CRLOAD)
	LD	(HIMEM),HL
	CALL	SETUP
	LD	HL,MESS1
	CALL	MESS>DI
	JP	DOS
NODOS	CALL	GETNUM
	CALL	READSYS
	JR	RDSYS
NEXTWORD LD	A,(HL)
	INC	HL
	CP	21H
	JR	NC,NEXTWORD
	DEC	HL
NEXV01	LD	A,(HL)
	INC	HL
	CP	20H
	JR	Z,NEXV01
	DEC	HL
	RET
GETNUM	LD	(CST),HL
	PUSH	HL
	POP	BC
	LD	HL,0
GETV01	CALL	GETCH
	JR	Z,GPAST
	LD	A,L
	LD	(CURSYS),A
	PUSH	BC
	POP	HL
	LD	(CEN),HL
	RET
GPAST	PUSH	HL
	POP	DE
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	ADD	HL,HL
	ADD	A,L
	LD	L,A
	JR	GETV01
GETCH	LD	A,(BC)
	INC	BC
	CP	0DH
	JR	Z,CHEND
	CP	20H
	JR	NZ,GCHV01
GCHL01	LD	A,(BC)
	INC	BC
	CP	20H
	JR	Z,GCHL01
CHEND	LD	A,0FFH
	DEC	BC
	OR	A
	RET
GCHV01	CP	3AH
	JR	NC,GETCH
	CP	30H
	JR	C,GETCH
	SUB	30H
	LD	D,A
	XOR	A
	LD	A,D
	RET
READSYS	LD	A,(CURSYS)
	LD	HL,(CRTPS)
	LD	(HL),A
	INC	HL
	PUSH	HL
	LD	HL,(CRLOAD)
	EX	DE,HL
	POP	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(CRTPS),HL
	LD	HL,(CST)
	LD	DE,BUFF1
MV01	LD	A,(HL)
	CP	20H
	JR	Z,MV02
	LD	(DE),A
	INC	HL
	INC	DE
	JR	MV01
MV02	LD	A,0DH
	LD	(DE),A
	LD	HL,BUFF1
	LD	DE,FCB
	CALL	EXTRACT
	LD	HL,DEFEXT
	LD	DE,FCB
	CALL	EXTEND
	LD	HL,BUFF1
	LD	DE,FCB
	LD	B,0
	CALL	OPEN>EX
	JP	NZ,DOSERR
	LD	HL,(CRLOAD)
LV01	LD	DE,FCB
	CALL	READ>RC
	JR	NZ,LV02
	LD	B,0
	CALL	POKE
	JR	LV01
LV02	CP	1DH
	JR	NZ,LV05
	LD	A,(FCB+8)
	LD	B,A
LV03	CALL	POKE
LV04	LD	(CRLOAD),HL
;	LD	DE,FCB	;WAS TO CLOSE FCB
;	CALL	CLOSE	;NOW DISCARDED: WASTES TIME.
	LD	HL,(CEN)
	RET
LV05	CP	1CH
	JP	NZ,DOSERR
	JR	LV04
POKE	LD	DE,BUFF1
POKV01	LD	A,(DE)
	LD	(HL),A
	INC	DE
	DEC	HL
	DJNZ	POKV01
	RET
SETUP	LD	HL,4BDAH
	LD	(HL),195
	LD	HL,SLOAD
	LD	(4BDBH),HL
	RET
SLOAD	LD	HL,4317H
	CP	(HL)
	JP	Z,4C19H
	LD	(HL),A
	LD	B,A
	DEC	B
	DEC	B
	LD	HL,TABLE
SEARCH	LD	A,(HL)
	OR	A
	JR	NZ,BYPE
	LD	A,B
	INC	A
	INC	A
	LD	HL,4317H
	JP	4BE1H
BYPE	CP	B
	JR	Z,MLOAD
	INC	HL
	INC	HL
	INC	HL
	JR	SEARCH
MLOAD	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
MLOV01	LD	A,(HL)
	DEC	HL
	CP	2
	JR	NZ,MLOV02
	DEC	HL
	LD	E,(HL)
	DEC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	(4C1EH),HL
	JP	4C19H
MLOV02	CP	1
	JR	Z,MLOV04
	LD	B,(HL)
	DEC	HL
MLOV03	DEC	HL
	DJNZ	MLOV03
	JR	MLOV01
MLOV04	LD	B,(HL)
	DEC	HL
	LD	E,(HL)
	DEC	HL
	LD	D,(HL)
	DEC	HL
	DEC	B
	DEC	B
MLOV05	LD	A,(HL)
	LD	(DE),A
	DEC	HL
	INC	DE
	DJNZ	MLOV05
	JR	MLOV01
MESS1	DEFM	'NOW PATCHING DOS FOR SYSTEM AUTO-LOAD'
	DEFB	0AH
	DEFM	'SYSRES VERSION 1.01 (AUGUST 28, 1983).'
	DEFB	0DH
CST	DEFW	0
CEN	DEFW	0
CRTPS	DEFW	TABLE
TABLE	EQU	ORIG-256
DEFEXT	DEFM	'SYS'
CURSYS	DEFB	0
CRLOAD	DEFW	TABLE-1
BUFF1	DEFS	256
FCB	DEFS	32
	END	SYSRES
