;Fortyhex: Rewrite of routine at 0040H except
;uses standard devices (not 33H) and CAN terminate
;the string with a null rather than CR.
;Last modified on 20-Jan-87 for no-echo.
;
	IFREF	FORTYHEX
;
FORTYHEX:
	LD	A,B
	LD	(_40H_LEN),A
	LD	(_40H_BUF),HL
;Turn cursor on.
;
_40H_LOOP
	LD	DE,$2
	CALL	$GET
	OR	A
	JR	Z,_40H_LOOP
	CP	80H
	JR	NC,_40H_LOOP
	CP	1
	JR	Z,_40H_BREAK
	CP	8
	JR	Z,_40H_BS
	CP	18H
	JR	Z,_40H_SBS
	CP	CR
	JR	Z,_40H_CR	;And NC set too.
	CP	' '
	JR	C,_40H_LOOP	;ignore control.
	LD	C,A
	LD	A,B
	OR	A
	JR	Z,_40H_LOOP	;String full.
	LD	(HL),C
	LD	A,C
	INC	HL
	CALL	PUT_VISIBLE
	DEC	B
	JR	_40H_LOOP
;
_40H_CR
	IFDEF	NULL_STR
	LD	(HL),0
	ELSE
	LD	(HL),CR
	ENDIF
;
	PUSH	AF
	LD	A,CR
	LD	DE,$2
	CALL	$PUT
;
	XOR	A
	LD	(_40H_INV),A
;
	POP	AF
	LD	HL,(_40H_BUF)
	RET
;
_40H_BS
	CALL	_40H_BKSP
	JR	_40H_LOOP
;
_40H_SBS
	CALL	_40H_BKSP
	JR	NZ,_40H_SBS
	JR	_40H_LOOP
;
_40H_BKSP
	LD	A,(_40H_LEN)
	CP	B
	RET	Z
	DEC	HL
	INC	B
	LD	A,8
	CALL	PUT_VISIBLE
	XOR	A
	CP	1
	RET
;
_40H_BREAK
	SCF
	JR	_40H_CR
;
PUT_VISIBLE
	PUSH	BC
	LD	B,A
	LD	A,(_40H_INV)
	OR	A
	LD	A,B
	POP	BC
	RET	NZ
	LD	DE,$2
	CALL	$PUT
	RET
;
;Data
_40H_INV	DEFB	0
_40H_LEN	DEFB	0
_40H_BUF	DEFW	0
;
	ENDIF
