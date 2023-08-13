;Prime2/asm: Finds primes to 65535.
; Changed to /asm on 27-Aug-84
;

*GET	DOSCALLS

MAXPRIME	EQU	10000
	ORG	5200H
PRIME	DI
	CALL	CLEAR
	LD	HL,0
L1	CALL	TEST0
	JR	Z,PR1
L2	CALL	TEST500
	JR	C,PAST
	EI
	JP	DOS_NOERROR
PAST	INC	HL
	JR	L1
PR1	CALL	DISPLAY
	CALL	SETALL
WAIT1	LD	A,(3840H)
	OR	A
	JR	NZ,WAIT1
	JR	L2
DISPLAY	CALL	GETNUM
	PUSH	HL
	PUSH	DE
	EX	DE,HL
	LD	DE,LA1
	OR	A
	SBC	HL,DE
	JR	C,DISV01
	EI
	JP	DOS_NOERROR
DISV01	POP	DE
	POP	HL
	CALL	SCREEN
	RET
GETNUM	PUSH	HL
	ADD	HL,HL
	LD	DE,3
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	RET
CLEAR	LD	HL,BUFFER
	LD	DE,BUFFER+1
	LD	BC,LA2
	LD	(HL),0
	LDIR
	RET
TEST0	PUSH	HL
	LD	DE,BUFFER
	ADD	HL,DE
	LD	A,(HL)
	POP	HL
	OR	A
	RET
TEST500	PUSH	HL
	LD	DE,LA3
	OR	A
	SBC	HL,DE
	POP	HL
	RET
SETALL	CALL	GETNUM
	PUSH	HL
	PUSH	DE
	POP	BC
SETV01	ADD	HL,BC
	CALL	TEST500
	JR	NC,SETOUT
	PUSH	HL
	LD	DE,BUFFER
	ADD	HL,DE
	LD	(HL),255
	POP	HL
	JR	SETV01
SETOUT	POP	HL
	RET
SCREEN	PUSH	HL
	EX	DE,HL
	CALL	BINDEC
	LD	A,32
	CALL	ROM@PUT_VDU
	POP	HL
	RET
BINDEC
	LD	DE,10000
	CALL	GET1
	LD	DE,1000
	CALL	GET1
	LD	DE,100
	CALL	GET1
	LD	DE,10
	CALL	GET1
	LD	DE,1
	CALL	GET1
	RET
GET1	LD	B,2FH
GETV01	INC	B
	OR	A
	SBC	HL,DE
	JR	NC,GETV01
	ADD	HL,DE
	PUSH	HL
	LD	A,B
	CALL	ROM@PUT_VDU
	POP	HL
	RET
LA3	EQU	MAXPRIME
LA1	EQU	LA3+LA3
LA2	EQU	LA3+10
BUFFER	DEFS	512
	END	PRIME
