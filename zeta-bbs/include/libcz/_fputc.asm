;
;int fputc(c,fp)
;int c;
;FILE *fp;
;
_FPUTC
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	EX	DE,HL	;hl now points to fdarray
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,C
	CALL	$PUT
	JR	NZ,$C_03
	LD	L,C
	LD	H,0
	RET
$C_03	LD	HL,EOF
	RET
