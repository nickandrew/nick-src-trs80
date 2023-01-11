;
;fputs(s,fp)
;char *s;
;FILE *fp;
;
_FPUTS
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)	;Read fp
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)	;Read string
	INC	HL
	LD	B,(HL)
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	BC
	POP	HL
$C_04	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$PUT
;;	RET	NZ
	INC	HL
	JR	$C_04
