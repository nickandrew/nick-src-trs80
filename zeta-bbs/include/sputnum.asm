;
;
;SPUTNUM: Put a decimal integer into a string.
SPUTNUM:
	LD	(_SPPOS),DE
	XOR	A
	LD	(_SPBLANK),A
	LD	DE,10000
	CALL	_SP_DIGIT
	LD	DE,1000
	CALL	_SP_DIGIT
	LD	DE,100
	CALL	_SP_DIGIT
	LD	DE,10
	CALL	_SP_DIGIT
	LD	(_SPTENS),A
	LD	DE,1
	LD	A,E
	LD	(_SPBLANK),A
	CALL	_SP_DIGIT
	LD	(_SPONES),A
	XOR	A
	LD	DE,(_SPPOS)
	LD	(DE),A		;null terminator
	RET
;
_SP_DIGIT	LD	B,'0'-1
_SP1	INC	B
	OR	A
	SBC	HL,DE
	JR	NC,_SP1
	ADD	HL,DE
	LD	A,(_SPBLANK)
	OR	A
	JR	NZ,_SP2
	LD	A,B
	CP	'0'
	RET	Z
_SP2	LD	(_SPBLANK),A
	LD	A,B
	LD	DE,(_SPPOS)
	LD	(DE),A
	INC	DE
	LD	(_SPPOS),DE
	RET
;
_SPBLANK	DEFB	0
_SPTENS		DEFB	0
_SPONES		DEFB	0
_SPPOS		DEFW	0
;
