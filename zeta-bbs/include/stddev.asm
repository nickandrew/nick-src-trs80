;Stddev.hdr: Routines for standard device usage.
;Last modified: 13-Apr-86
;
;
;set_stdout: Setup a new standard output
SET_STDOUT
	LD	A,(DE)
	BIT	7,A
	JR	NZ,SS_01
	LD	($STDOUT),DE
	RET
SS_01
	EX	DE,HL
	LD	DE,($STDOUT_FCB)
	LD	($STDOUT),DE
	LD	BC,32
	PUSH	DE
	LDIR
	POP	HL
	LD	DE,3		;Buffer address ptr
	ADD	HL,DE
	LD	DE,($STDOUT_BUFF)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	RET
;
;save_stdout: Save current STDOUT into buffer.
SAVE_STDOUT
	LD	DE,($STDOUT)
	LD	HL,STDOUTBUFF
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	A,(DE)
	BIT	7,A
	JR	NZ,SS_02
	LD	(HL),0
	RET
SS_02
	EX	DE,HL
	LD	BC,32
	LDIR
	LD	BC,256
	LD	HL,($STDOUT_BUFF)
	LDIR
	RET
;
;rest_stdout: Restore original (saved) STDOUT.
REST_STDOUT
	LD	DE,($STDOUT)
	LD	A,(DE)
	BIT	7,A		;if file then...
	CALL	NZ,DOS_CLOSE	;close it.
	LD	HL,STDOUTBUFF
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	($STDOUT),DE
	INC	HL
	LD	A,(HL)
	OR	A
	RET	Z
	LD	BC,32
	LDIR
	LD	DE,($STDOUT_BUFF)
	LD	BC,256
	LDIR
	RET
;
;set_stdin: Setup a new standard input
SET_STDIN
	LD	A,(DE)
	BIT	7,A
	JR	NZ,SS_03
	LD	($STDIN),DE
	RET
SS_03
	EX	DE,HL
	LD	DE,($STDIN_FCB)
	LD	($STDIN),DE
	LD	BC,32
	PUSH	DE
	LDIR
	POP	HL
	LD	DE,3		;Buffer address ptr
	ADD	HL,DE
	LD	DE,($STDIN_BUFF)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	RET
;
;save_stdin: Save current STDIN into buffer.
SAVE_STDIN
	LD	DE,($STDIN)
	LD	HL,STDINBUFF
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	A,(DE)
	BIT	7,A
	JR	NZ,SS_04
	LD	(HL),0
	RET
SS_04
	EX	DE,HL
	LD	BC,32
	LDIR
	LD	BC,256
	LD	HL,($STDIN_BUFF)
	LDIR
	RET
;
;rest_stdin: Restore original (saved) STDin.
REST_STDIN
	LD	DE,($STDIN)
	LD	A,(DE)
	BIT	7,A		;if file then...
				;Do nothing to it!!!
	LD	HL,STDINBUFF
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	($STDIN),DE
	INC	HL
	LD	A,(HL)
	OR	A
	RET	Z
	LD	BC,32
	LDIR
	LD	DE,($STDIN_BUFF)
	LD	BC,256
	LDIR
	RET
;
STDOUTBUFF
	DEFS	256+32+2
STDINBUFF
	DEFS	256+32+2
;
;End of standard IO routines.
