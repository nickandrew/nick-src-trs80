;asctime: convert time/date into ascii
_ASCTIME
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	A,(4045H)	;DD
	CALL	ASC_1
	LD	(HL),' '
	INC	HL
	LD	A,(4046H)	;MM
	CALL	ASC_2
	LD	(HL),' '
	INC	HL
	LD	A,(4044H)	;YY
	CALL	ASC_1
	LD	(HL),' '
	INC	HL
	LD	A,(4043H)	;hh
	CALL	ASC_1
	LD	(HL),':'
	INC	HL
	LD	A,(4042H)
	CALL	ASC_1
	LD	(HL),':'
	INC	HL
	LD	A,(4041H)
	CALL	ASC_1
	LD	(HL),0
	RET
;
ASC_1	LD	(HL),2FH
ASC_1A	INC	(HL)
	SUB	10
	JR	NC,ASC_1A
	INC	HL
	ADD	A,3AH
	LD	(HL),A
	INC	HL
	RET
;
ASC_2
	PUSH	HL
	LD	HL,ASC_MONTH
	LD	E,A
	LD	D,0
	ADD	HL,DE
	ADD	HL,DE
	ADD	HL,DE
	POP	DE
	LD	BC,3
	LDIR
	EX	DE,HL
	RET
;
ASC_MONTH
	DEFM	'***JanFebMarAprMayJunJulAugSepOctNovDec'
;