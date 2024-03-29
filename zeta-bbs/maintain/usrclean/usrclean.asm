;usrclean: delete inactive non-members.
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info.
;
	COM	'<usrclean 1.0c 18-Apr-87>'
;
	ORG	BASE+100H
START	LD	SP,START
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JP	Z,TERMINATE
;
	LD	A,(4044H)	;year
	LD	(YY),A
	LD	A,(4046H)	;month.
	SUB	2		;Give 2-3 months only.
	CP	1
	JP	P,UC_01
	LD	HL,YY
	DEC	(HL)
	ADD	A,12
UC_01	LD	(MM),A
;
	LD	HL,0
	LD	(USER),HL
;
	CALL	OPEN_FILES
;
LOOP	CALL	POS_DAT
	CALL	READ_DAT
	CALL	ZAP
;
	LD	HL,(USER)
	INC	HL
	LD	(USER),HL
;
	JR	LOOP
;
OPEN_FILES
	LD	HL,BUFF_USER
	LD	DE,FCB_USER
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
;
	LD	HL,BUFF_OUT
	LD	DE,FCB_OUT
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,ERROR
;
	LD	A,(FCB_USER+1)
	AND	0F8H
	OR	40H		;Prevent shrink.
	LD	(FCB_USER+1),A
	LD	HL,M_HEAD1
	LD	DE,FCB_OUT
	CALL	FPUTS
	JP	NZ,ERROR
;
	RET
;
POS_DAT
	LD	HL,(USER)
	LD	E,H
	INC	E
	LD	D,0
	LD	A,56
	CALL	MULTIPLY
	ADD	HL,DE
	LD	DE,FCB_USER
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	RET
;
POS_HASH
	LD	HL,(USER)
	LD	E,L
	LD	L,0
	LD	A,UF_LRL+1
	CALL	MULTIPLY
	LD	C,E
	LD	DE,FCB_USER
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	RET
;
READ_DAT
	LD	HL,US_UBUFF
	LD	DE,FCB_USER
	LD	B,UF_LRL
RD_01	CALL	ROM@GET
	JP	NZ,RD_02
	LD	(HL),A
	INC	HL
	DJNZ	RD_01
	RET
;
RD_02	CP	1CH
	JR	Z,EOF
	CP	1DH
	JP	NZ,ERROR
EOF	LD	DE,FCB_USER
	CALL	DOS_CLOSE
	JP	NZ,ERROR
	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	JP	NZ,ERROR
	JP	TERMINATE
;
ZAP	LD	A,(UF_STATUS)
	BIT	UF_ST_ZERO,A
	RET	Z		;if record unused.
;
	BIT	UF_ST_NOTUSER,A
	RET	NZ		;If locked out.
;
	LD	A,(UF_PRIV2)
	BIT	1,A
	RET	Z		;If not a visitor.
;
	LD	A,(YY)
	LD	B,A
	LD	A,(UF_LASTCALL+2)	;=yy
	CP	B
	JR	C,ZAP_IT
	RET	NZ		;don't zap.
;
	LD	A,(MM)
	LD	B,A
	LD	A,(UF_LASTCALL+1)	;=mm
	CP	B
	RET	NC		;Don't zap.
ZAP_IT
	LD	HL,UF_STATUS
	LD	(HL),0
	CALL	POS_DAT
	CALL	WRITE_DAT
	CALL	POS_HASH
	XOR	A
	CALL	ROM@PUT
	JP	NZ,ERROR
	CALL	REPORT_LINE
	RET
;
WRITE_DAT
	LD	HL,US_UBUFF
	LD	B,UF_LRL
	LD	DE,FCB_USER
WD_01	LD	A,(HL)
	CALL	ROM@PUT
	JP	NZ,ERROR
	INC	HL
	DJNZ	WD_01
	RET
;
REPORT_LINE
	LD	DE,FCB_OUT
	LD	HL,UF_NAME
	LD	B,24
RL_01	LD	A,(HL)
	CP	CR
	JR	Z,RL_02
	OR	A
	JR	Z,RL_02
	CALL	ROM@PUT
	JP	NZ,ERROR
	INC	HL
	DJNZ	RL_01
RL_02	LD	A,CR
	CALL	ROM@PUT
	RET
;
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	LD	DE,FCB_USER
	CALL	DOS_CLOSE
	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	POP	AF
	JP	TERMINATE
;
*GET	FPUTS
*GET	MULTIPLY
*GET	USERFILE
;
;Definitions for UF_STATUS
UF_ST_ZERO	EQU	6	;=1 if record used.
UF_ST_NOTUSER	EQU	5	;1=A fake username or
				;rude disconnection.
;
M_HEAD1	DEFM	'   This is a list of NON-MEMBERS whose accounts were deleted',CR
	DEFM	'due to gross inactivity.',CR,CR,0
;
FCB_USER
	DEFM	'userfile.zms',CR
	DC	32-13,0
;
FCB_OUT
	DEFM	'report',CR
	DC	32-7,0
;
YY	DEFB	0
MM	DEFB	0
USER	DEFW	0
;
BUFF_USER
	DEFS	256
BUFF_OUT
	DEFS	256
;
THIS_PROG_END	EQU	$
;
	END	START
