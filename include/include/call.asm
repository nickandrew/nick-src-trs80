;Call/asm: Small C arithmetic & logical library.
; Last modified: 23-Mar-87
;
CCDDGC:
	ADD	HL,DE
	JP	CCGCHAR
;
CCDSGC:
	INC	HL
	INC	HL
	ADD	HL,SP
;
;	fetch a single byte from the address
;	in HL and sign extend into HL
;
CCGCHAR:
	LD	A,(HL)
;
;	put the accumulator into HL and sign
;	extend into HL
;
CCARGC:
CCSXT:
	LD	L,A
	SLA	A	;was rlc / rla / sla
	SBC	A,A
	LD	H,A
	RET
;
CCDDGI:
	ADD	HL,DE
	JP	CCGINT
;
CCDSGI:
	INC	HL
	INC	HL
	ADD	HL,SP
;
;	fetch a 16-bit integer from the address
;	in HL into HL
;
CCGINT:
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	RET
;
CCDECC:
	INC	HL
	INC	HL
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGCHAR
	DEC	HL
	LD	A,L
	LD	(DE),A
	RET
;
CCINCC:
	INC	HL
	INC	HL
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGCHAR
	INC	HL
	LD	A,L
	LD	(DE),A
	RET
;
CCDDPDPC:
	ADD	HL,DE
CCPDPC:
	POP	BC	; return address
	POP	DE
	PUSH	BC
;
;	Store a single byte from HL at the
;	address in DE
;
CCPCHAR:
PCHAR:
	LD	A,L
	LD	(DE),A
	RET
;
CCDECI:
	INC	HL
	INC	HL
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	DEC	HL
	JP	CCPINT
;
CCINCI:
	INC	HL
	INC	HL
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	INC	HL
	JP	CCPINT
;
CCDDPDPI:
	ADD	HL,DE
CCPDPI:
	POP	BC	; return address
	POP	DE
	PUSH	BC
;
;	Store a 16-bit integer in HL at the
;	address in DE
;
CCPINT:
PINT:
	LD	A,L
	LD	(DE),A
	INC	DE
	LD	A,H
	LD	(DE),A
	RET
;
;	Inclusive OR of HL and DE into HL
;
CCOR:
	LD	A,L
	OR	E
	LD	L,A
	LD	A,H
	OR	D
	LD	H,A
	RET
;
;	Exclusive OR of HL and DE into HL
;
CCXOR:
	LD	A,L
	XOR	E
	LD	L,A
	LD	A,H
	XOR	D
	LD	H,A
	RET
;
;	AND of HL and DE into HL
;
CCAND:
	LD	A,L
	AND	E
	LD	L,A
	LD	A,H
	AND	D
	LD	H,A
	RET
;
;	In all the following compare routines,
;	HL is set to 1 if the condition is true,
;	otherwise HL is set to 0.
;
;	Test if HL = DE
;
CCEQ:
	CALL	CCCMP
	RET	Z
	DEC	HL
	RET
;
;	Test if DE != HL
;
CCNE:
	CALL	CCCMP
	RET	NZ
	DEC	HL
	RET
;
;	Test if DE > HL (signed)
;
CCGT:
	EX	DE,HL
	CALL	CCCMP
	RET	C
	DEC	HL
	RET
;
;	Test if DE <= HL (signed)
;
CCLE:
	CALL	CCCMP
	RET	Z
	RET	C
	DEC	HL
	RET
;
;	Test if DE >= HL (signed)
;
CCGE:
	CALL	CCCMP
	RET	NC
	DEC	HL
	RET
;
;	Test if DE < HL (signed)
;
CCLT:
	CALL	CCCMP
	RET	C
	DEC	HL
	RET
;
;	Common routine to perform a signed
;	compare of DE and HL
;
;	This routine performs DE - HL and sets
;	the conditions:
;		Carry reflects sign of difference (set DE < HL)
;		Zero/Nonzero set according to equality
;
CCCMP:
	LD	A,H	;; invert sign of HL
	XOR	80H
	LD	H,A
	LD	A,D	;; invert sign of DE
	XOR	80H
	CP	H	;; compare MSBs
	JR	NZ,CCCMP1
	LD	A,E	;; compare LSBs
	CP	L
CCCMP1:
	LD	HL,1	;; preset true condition
	RET
;
;	Test if DE >= HL (unsigned)
;
CCUGE:
	CALL	CCUCMP
	RET	NC
	DEC	HL
	RET
;
;	Test if DE < HL (unsigned)
;
CCULT:
	CALL	CCUCMP
	RET	C
	DEC	HL
	RET
;
;	Test if DE > HL (unsigned)
;
CCUGT:
	EX	DE,HL
	CALL	CCUCMP
	RET	C
	DEC	HL
	RET
;
;	Test if DE <= HL (unsigned)
;
CCULE:
	CALL	CCUCMP
	RET	Z
	RET	C
	DEC	HL
	RET
;
;	Common routine to perform unsigned
;	compare of DE and HL
;
;	Carry set if DE < HL
;	Zero/Nonzero set accordingly
;
CCUCMP:
	LD	A,D
	CP	H
	JR	NZ,CCUCMP1
	LD	A,E
	CP	L
CCUCMP1:
	LD	HL,1
	RET
;
;	Shift de arithmetically right by
;	hl and return in HL
;
CCASR:
	EX	DE,HL
CCASR1	DEC	E
	RET	M
	LD	A,H
	SRA	A	;was rar / rrca / sra
	LD	H,A
	LD	A,L
	RRA		;was rar / rrca / rra
	LD	L,A
	JR	CCASR1
;
;	Shift de arithmetically left by
;	hl and return in HL
;
CCASL:
	EX	DE,HL
CCASL1	DEC	E
	RET	M
	ADD	HL,HL
	JR	CCASL1
;
;	Subtract HL from DE and return in HL
;
CCSUB:
	LD	A,E
	SUB	L
	LD	L,A
	LD	A,D
	SBC	A,H	;was sbb
	LD	H,A
	RET
;
;	Form the 2's complement of HL
;
CCNEG:
	LD	A,H
	CPL
	LD	H,A
	LD	A,L
	CPL
	LD	L,A
	INC	HL
	RET
;
;	Form the 1's complement of HL
;
CCCOM:
	LD	A,H
	CPL
	LD	H,A
	LD	A,L
	CPL
	LD	L,A
	RET
;
;	Multiply DE by HL and return in HL
;	(signed multiply)
;
CCMULT:
MULT:
	LD	B,H
	LD	C,L
	LD	HL,0
CCMULT1:
	LD	A,C
	RRA		;was rrc
	JR	NC,CCMULT2
	ADD	HL,DE
CCMULT2:
	XOR	A
	LD	A,B
	SRL	A	;was rar
	LD	B,A
	LD	A,C
	RRA		;was rar
	LD	C,A
	OR	B
	RET	Z
	XOR	A
	LD	A,E
	RLA		;was ral
	LD	E,A
	LD	A,D
	RLA		;was ral
	LD	D,A
	OR	E
	RET	Z
	JR	CCMULT1
;
;	Divide DE by HL and return quotient
;	in HL and remainder in DE
;	(signed divide)
;
CCDIV:
DIV:
	LD	B,H
	LD	C,L
	LD	A,D
	XOR	B
	PUSH	AF
	LD	A,D
	OR	A
	CALL	M,CCDNEG
	LD	A,B
	OR	A
	CALL	M,CCBNEG
	LD	A,16
	PUSH	AF
	EX	DE,HL
	LD	DE,0
CCDIV1:
	ADD	HL,HL
	CALL	CCRDEL
	JR	Z,CCDIV2
	CALL	CCCMPBCDE
	JP	M,CCDIV2
	LD	A,L
	OR	1
	LD	L,A
	LD	A,E
	SUB	C
	LD	E,A
	LD	A,D
	SBC	A,B	;was sbb b
	LD	D,A
CCDIV2:
	POP	AF
	DEC	A
	JR	Z,CCDIV3
	PUSH	AF
	JR	CCDIV1
CCDIV3:
	POP	AF
	RET	P
	CALL	CCDNEG
	EX	DE,HL
	CALL	CCDNEG
	EX	DE,HL
	RET
;
;
;	Negate the integer in DE
;	(internal routine)
;
CCDNEG:
	LD	A,D
	CPL
	LD	D,A
	LD	A,E
	CPL
	LD	E,A
	INC	DE
	RET
;
;	Negate the integer in BC
;	(internal routine)
;
CCBNEG:
	LD	A,B
	CPL
	LD	B,A
	LD	A,C
	CPL
	LD	C,A
	INC	BC
	RET
;
;	Rotate DE left one bit
;	(internal routine)
;
CCRDEL:
	LD	A,E
	RLA		;was ral / rlca / rla
	LD	E,A
	LD	A,D
	RLA		;was ral / rlca / rla
	LD	D,A
	OR	E
	RET
;
;	Compare BC to DE
;	(internal routine)
;
CCCMPBCDE
	LD	A,E
	SUB	C
	LD	A,D
	SBC	A,B	;was sbb b
	RET
;
;	Logical negation
;
CCLNEG:
	LD	A,H
	OR	L
	JR	NZ,CCLNEG1
	LD	L,1
	RET
CCLNEG1	LD	HL,0
	RET
;
;	Execute "switch" statement
;
;	 HL  =  switch value
;	(SP) -> switch table
;		DefW	ADDR1, VALUE1
;		DefW	ADDR2, VALUE2
;		...
;		DefW	0
;		[JP	default]
;		continuation
;
CCSWITCH:
	EX	DE,HL		;; DE = switch value
	POP	HL	;; HL -> switch table
SWLOOP:
	LD	C,(HL)
	INC	HL
	LD	B,(HL)	;; BC -> case address, else 0
	INC	HL
	LD	A,B
	OR	C
	JR	Z,SWEND	;; default or continuation code
	LD	A,(HL)
	INC	HL
	CP	E
	LD	A,(HL)
	INC	HL
	JR	NZ,SWLOOP
	CP	D
	JR	NZ,SWLOOP
	LD	H,B	;; case matched
	LD	L,C
SWEND:
	JP	(HL)
;
;End of call/asm
