	COM	'<small c compiler output>'
*MOD
_GETW:
	DEBUG	'getw'
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGCHAR
	PUSH	HL
	LD	HL,255
	POP	DE
	CALL	CCAND
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	INC	HL
	CALL	CCGCHAR
	PUSH	HL
	LD	HL,255
	POP	DE
	CALL	CCAND
	PUSH	HL
	LD	HL,8
	POP	DE
	CALL	CCASL
	POP	DE
	ADD	HL,DE
	RET
_PUTW:
	DEBUG	'putw'
	LD	HL,4
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	INC	HL
	CALL	CCPINT
	DEC	HL
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,255
	POP	DE
	CALL	CCAND
	POP	DE
	LD	A,L
	LD	(DE),A
	LD	HL,4
	ADD	HL,SP
	LD	D,H
	LD	E,L
	CALL	CCGINT
	INC	HL
	CALL	CCPINT
	DEC	HL
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,8
	POP	DE
	CALL	CCASR
	PUSH	HL
	LD	HL,255
	POP	DE
	CALL	CCAND
	POP	DE
	LD	A,L
	LD	(DE),A
	RET
	END
