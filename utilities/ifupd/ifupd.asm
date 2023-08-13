;ifupd: Execute some command ONLY if a file is updated.
;Usage:  IFUPD filename command
;
;Environment: Trs-80 Model 1/3, Newdos-80.
;
*GET	DOSCALLS
CR	EQU	0DH
;
	COM	'<ifupd 1.0  28-Dec-86, >'
;
	ORG	5300H
START	LD	SP,START
;
	LD	A,(HL)
	CP	CR
	JR	Z,USAGE
;
	LD	DE,FCB
	CALL	DOS_EXTRACT
	JP	NZ,USAGE
;
IF_1	LD	A,(HL)
	INC	HL
	CP	' '
	JR	Z,IF_1
	CP	CR
	JP	Z,USAGE
	DEC	HL
	LD	(COMMAND),HL
;
	LD	HL,0		;Null buffer.
	LD	DE,FCB
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,USAGE
;
	LD	A,(FCB+2)	;Updated bit
	BIT	5,A
	JP	Z,DOS_NOERROR		;Exit if not updated.
;
	LD	HL,(COMMAND)
	JP	4405H		;Execute the command.
;
USAGE	LD	HL,M_USAGE
	CALL	MSG
	JP	DOS_NOERROR
;
MSG	LD	A,(HL)
	OR	A
	RET	Z
	CALL	ROM@PUT_VDU
	INC	HL
	JR	MSG
;
M_USAGE	DEFM	'IFUPD: Execute a dos command if a file has been updated',CR
	DEFM	'Usage: IFUPD filename command',CR
	DEFM	'For: Trs-80 Model 1/3, Newdos-80',CR
	DEFM	'This program is public domain.',CR
	DEFM	'Source code is available from Zeta (Fido [620/602])',CR,0
;
FCB	DEFS	32
COMMAND	DEFW	0
;
	END	START
