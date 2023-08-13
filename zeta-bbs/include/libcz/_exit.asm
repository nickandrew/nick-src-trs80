;
;exit(errcode)
;char errcode;
;
_EXIT
	CALL	CLOSEALL
	LD	HL,2
	ADD	HL,SP
	LD	A,(HL)
	OR	A
	JP	TERMINATE
;
CLOSEALL			;Close all open files
	LD	B,MAX_FILES
	LD	HL,FD_ARRAY
CL_1	PUSH	BC
	PUSH	HL
	PUSH	HL
	CALL	_FCLOSE
	POP	IY
	POP	HL
	LD	DE,FD_LEN
	ADD	HL,DE
	POP	BC
	DJNZ	CL_1
	RET
;