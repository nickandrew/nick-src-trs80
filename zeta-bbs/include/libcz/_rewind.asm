;
;rewind(ioptr)
;char *ioptr;
_REWIND
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	DOS_REWIND
	RET
