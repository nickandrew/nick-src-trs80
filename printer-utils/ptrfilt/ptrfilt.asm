;Ptrfilt/asm: Filter ctrl-N & ctrl-O characters
;and send the rest to the printer.
; Version 1.0
; Converted to /asm format on 27-Aug-84.
;
	ORG	0FF00H
	DEFS	12
START	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY
	LD	A,C
	AND	07FH
	CP	20H
	JR	NC,PRINT
	CP	14
	JR	NZ,BYP1
	XOR	A
BYP1	CP	15
	JR	NZ,PRINT
	XOR	A
PRINT	CALL	003BH
	POP	IY
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
	END	402DH
