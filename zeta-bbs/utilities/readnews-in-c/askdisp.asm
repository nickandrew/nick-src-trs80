;askdisp/asm: Ask a question
;Valid replies are: CR or ' ' : read article
;		    ';'       : skip article
;		    'n'       : next newsgroup
;		    'q'	      : quit.
;
_ASKDISP
	LD	HL,QUEST
	PUSH	HL
	LD	HL,STDOUT
	PUSH	HL
	CALL	_FPUTS
	POP	IY
	POP	IY
;
	LD	HL,_LINE
	LD	B,1
	CALL	ROM@WAIT_LINE
	JP	C,_ASKDISP
;
	XOR	A
	LD	(_LINE+1),A
;
	LD	A,(HL)
	CP	0DH		;CR
	JR	NZ,AD_1
	LD	(HL),' '
	JR	AD_SET
AD_1	CP	';'
	JR	Z,AD_SET
	AND	5FH
	LD	(HL),A
AD_SET
	LD	(_REPLY),A
	RET
;
QUEST
	DEFM	'? ',0
