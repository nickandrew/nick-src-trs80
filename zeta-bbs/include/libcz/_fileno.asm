;-------------------------------------------------------
;
;int fileno(fp);
;FILE *fp;
;
_FILENO	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	DE,FD_ARRAY
	OR	A
	SBC	HL,DE
	LD	BC,-1
	JR	C,$C_02
	LD	DE,FD_LEN
$C_01	INC	BC
	SBC	HL,DE
	JR	NC,$C_01
$C_02	PUSH	BC
	POP	HL
	RET
