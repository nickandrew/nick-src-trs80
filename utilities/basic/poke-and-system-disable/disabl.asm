	ORG	3C00H
	DEFB	39
	DEFM	'POKE'
	DEFB	39
	DEFM	' AND '
	DEFB	39
	DEFM	'SYSTEM'
	DEFB	39
	DEFM	' DISABLE, (C) 1982 ZETA MICROCOMPUTER'
	DEFM	' SOFTWARE.'
	ORG	4000H
	JP	START
	ORG	32640
START	EXX
	POP	BC
	LD	A,B
	CP	2CH
	JR	NZ,NOTIT
	LD	A,C
	CP	0B6H
	JR	NZ,NOTIT
	LD	HL,MESS
	CALL	28A7H
	EXX
	JP	301
NOTIT	PUSH	BC
	EXX
	JP	1C96H
MESS	DEFM	'DON'
	DEFB	39
	DEFM	'T POKE.'
	DEFB	0DH
	DEFB	0
	ORG	41E2H
	JP	06CCH
	END	0674H
