;errlog: Log most errors.
;**************************************************
;* This program is letting through BUGS because   *
;* Errors are handled by SYS4 which ...           *
;*   1) Uses the previous progs stack             *
;*   2) will stuff up if you abort or discon      *
;* Or will it??????????????????????????           *
;**************************************************
;
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	COM	'<ERRLOG 1.0d 16-Apr-86>'
	ORG	BASE+100H
START	LD	SP,START
	LD	HL,(HIMEM)
	LD	A,H
	CP	0FFH
	JR	NZ,HI_OK
	LD	HL,EXTERNALS-1
HI_OK	LD	DE,EN_CODE-ST_CODE
	PUSH	DE
	OR	A
	SBC	HL,DE
	LD	(HIMEM),HL
	INC	HL
;do relocation.
	PUSH	HL
;
	LD	DE,ST_CODE
	OR	A
	SBC	HL,DE
	EX	DE,HL
	LD	HL,(RELOC1+1)
	ADD	HL,DE
	LD	(RELOC1+1),HL
	LD	HL,(RELOC2+1)
	ADD	HL,DE
	LD	(RELOC2+1),HL
	LD	HL,(RELOC3+1)
	ADD	HL,DE
	LD	(RELOC3+1),HL
	POP	DE
;
	LD	HL,ST_CODE
	POP	BC
	LDIR
;setup error handling now.
	LD	A,0C3H
	LD	(4409H),A	;Original handler.
	LD	HL,(HIMEM)
	INC	HL
	LD	(440AH),HL
;
	JP	DOS
;
ST_CODE
	PUSH	AF
	AND	7FH
;1. Log all errors except USER errors.
	CP	18H	;File not in Directory
	JR	Z,USR_ERR
	CP	19H	;File access denied
	JR	Z,USR_ERR
	CP	25H	;Illegal access tried...
	JR	Z,USR_ERR
	CP	30H	;Bad filespec
	JR	Z,USR_ERR
;log error number now..
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	AF
RELOC1	LD	HL,ERR_MSG
	CALL	LOG_MSG		;Send to system log.
	POP	AF
	PUSH	AF
	AND	0F0H
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	ADD	A,'0'
RELOC2	LD	HL,HEX_CODE
	LD	(HL),A
	INC	HL
	POP	AF
	AND	0FH
	CP	10
	JR	C,NOT_A
	ADD	A,7
NOT_A	ADD	A,'0'
	LD	(HL),A
RELOC3	LD	HL,HEX_CODE
	CALL	LOG_MSG
SYS4	POP	HL
	POP	DE
	POP	BC
;Stop any program abort during this message.
	POP	AF
	OR	80H
	PUSH	HL
	LD	HL,0
	LD	(ABORT),HL
	POP	HL
	PUSH	AF
	LD	A,026H	;do sys4.
	RST	28H
	RET
;
USR_ERR
	PUSH	BC
	PUSH	DE
	PUSH	HL
;
	JR	SYS4
;
ERR_MSG	DEFM	'** ERROR **, Dos Error # ',0
HEX_CODE	DEFM	'xxH',CR,0
;
EN_CODE	NOP
;
	END	START
