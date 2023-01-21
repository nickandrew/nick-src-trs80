;*******************************************
;* UNCRC/EDT: Find passwords to encode to  *
;* any given crc code. Crc to be checked   *
;* against is stored in 5200H - 5201H.     *
;* Passwords are displayed surrounded by ' *
;* Version 1.00, 24-June-84.               *
;*******************************************

*GET	DOSCALLS

	ORG	5200H
BYTE	DEFB	0E0H	;Encoded password value
	DEFB	42H	;equals E042H.
START	LD	HL,TABLE
	LD	(HL),20H
	LD	DE,TABLE+1
	LD	BC,7
	LDIR	
LOOP	CALL	COMPARE
	CALL	Z,PRINT
	LD	A,(3840H)
	OR	A
	JP	NZ,402DH
	CALL	INCREM
	JR	LOOP
PRINT	LD	A,27H
	CALL	ROM@PUT_VDU
	LD	HL,TABLE
	LD	B,8
PRINT8	PUSH	BC
	PUSH	HL
	LD	A,(HL)
	CALL	ROM@PUT_VDU
	POP	HL
	POP	BC
	INC	HL
	DJNZ	PRINT8
	LD	A,27H
	CALL	ROM@PUT_VDU
	LD	A,20H
	CALL	ROM@PUT_VDU
	RET	
INCREM	LD	HL,TABLE
	LD	C,0
STEPIN	LD	A,(HL)
	CP	'Z'
	JR	Z,NEXTIN
	CP	'9'
	JR	NZ,SKIP1
	LD	(HL),40H
SKIP1	INC	(HL)
	RET	
NEXTIN	LD	A,C
	OR	A
	LD	(HL),'A'	;First letter from A-Z.
	JR	Z,BYP1
	LD	(HL),'0'	;All others 0-9,A-Z.
BYP1	INC	C
	INC	HL
	JR	STEPIN
COMPARE	LD	HL,TABLE+7
	LD	DE,0FFFFH
	DI
	CALL	CRYPT
	EI
	LD	HL,(BYTE)
	OR	A
	SBC	HL,DE
	RET	
CRYPT	LD	B,8
LOOP8	PUSH	BC
	LD	A,E
	AND	7
	LD	C,A
	LD	A,E
	RLCA	
	RLCA	
	RLCA	
	XOR	C
	RLCA	
	LD	C,A
	AND	0F0H
	LD	B,A
	LD	A,C
	RLCA	
	AND	1FH
	XOR	B
	XOR	D
	LD	E,A
	LD	A,C
	AND	0FH
	LD	B,A
	LD	A,C
	RLCA	
	RLCA	
	RLCA	
	RLCA	
	XOR	B
	POP	BC
	XOR	(HL)
	LD	D,A
	DEC	HL
	DJNZ	LOOP8
	RET	
TABLE	DEFS	10H
TABLE2	DEFS	10H
	END	START
