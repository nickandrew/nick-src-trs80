;
_GETCHAR
	LD	HL,STDIN
	PUSH	HL
	CALL	_FGETC
	POP	BC
	RET
