;
;puts: Put a string to $stdout_def.
PUTS
	PUSH	DE
	LD	DE,DCB_2O
	CALL	FPUTS
	POP	DE
	RET
