;stty: Set TTY status and display.
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	TERM_ABORT
	DEFW	0
;End of program load info.
;
	COM	'<Stty 1.1e 17-May-87>'
	ORG	BASE+100H
;
START	LD	SP,START
	LD	A,(HL)
	CP	CR
	JR	Z,USAGE
	OR	A
	JR	Z,USAGE
;Do parameters...
	LD	(ARGP),HL
	LD	A,(TFLAG2)
	LD	(S_TFLAG2),A
;
PARAM	LD	HL,(ARGP)
	LD	A,(HL)
	CP	CR
	JR	Z,EXIT
;
	LD	DE,PAR_TBL
	LD	(TBL_PTR),DE
;
;Check this parameter.
NEXT	LD	HL,(TBL_PTR)
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	A,B
	OR	C		;End of table.
	JR	Z,USAGE
	INC	BC
	INC	BC
	PUSH	BC
	POP	HL
	LD	DE,(ARGP)
	CALL	PAR_CMP
	JR	Z,EXEC
	LD	HL,(TBL_PTR)
	INC	HL
	INC	HL
	LD	(TBL_PTR),HL
	JR	NEXT
;
EXEC
	LD	HL,(ARGP)
	CALL	BYP_WORD
	CALL	BYP_SP
	LD	(ARGP),HL
;
	LD	HL,(TBL_PTR)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	IX,S_TFLAG2
	JP	(HL)
;
USAGE
	LD	HL,M_USAGE
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,0
	JP	TERMINATE
;
BYP_SP
	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	BYP_SP
;
BYP_WORD
	LD	A,(HL)
	OR	A
	RET	Z
	CP	' '
	RET	Z
	CP	CR
	RET	Z
	INC	HL
	JR	BYP_WORD
;
EXIT
	LD	A,(S_TFLAG2)
	LD	(TFLAG2),A
	LD	DE,US_FCB
	LD	A,(DE)
	BIT	7,A
	CALL	NZ,DOS_CLOSE
	JP	NZ,INT_ERROR
	XOR	A
	JP	TERMINATE
;
PAR_CMP
	LD	A,(HL)
	OR	A
	JR	Z,PAR_EOS
	LD	A,(DE)
	CALL	CI_CMP
	RET	NZ
	INC	HL
	INC	DE
	JR	PAR_CMP
PAR_EOS
	LD	A,(DE)
	CP	' '
	RET	Z
	OR	A
	RET	Z
	CP	CR
	RET	Z
	RET		;NZ...
;
CMD_LOAD
	LD	A,(US_FCB)
	BIT	7,A
	CALL	Z,FIND
	LD	A,(UF_TFLAG2)
	LD	(S_TFLAG2),A
_PARAM	JP	PARAM
;
CMD_BELL
	SET	TF_BELL,(IX)
	JR	_PARAM
;
CMD_LF
	SET	TF_CRLF,(IX)
	JR	_PARAM
;
CMD_CURSOR
	RES	TF_CURSOR,(IX)
	JR	_PARAM
;
CMD_ECHOE
	SET	TF_BS,(IX)
	JR	_PARAM
;
CMD_16
	RES	TF_HEIGHT,(IX)
	JR	_PARAM
;
CMD_24
	SET	TF_HEIGHT,(IX)
	JR	_PARAM
;
CMD_32
	LD	A,(IX)
	AND	0FCH
	LD	(IX),A
	JR	_PARAM
;
CMD_40
	LD	A,(IX)
	AND	0FCH
	OR	1
	LD	(IX),A
	JP	PARAM
;
CMD_64
	LD	A,(IX)
	AND	0FCH
	OR	2
	LD	(IX),A
	JP	PARAM
;
CMD_80
	LD	A,(IX)
	AND	0FCH
	OR	3
	LD	(IX),A
	JP	PARAM
;
CMD_300
	JP	PARAM	;do nothing
CMD_1200
	JP	NOT_IMP
CMD_ANS
	JP	PARAM	;do nothing
CMD_ORIG
	JP	NOT_IMP
;
CMD_SAVE
	LD	A,(US_FCB)
	BIT	7,A
	CALL	Z,FIND
;
	LD	A,(S_TFLAG2)
	LD	(TFLAG2),A
	LD	(UF_TFLAG2),A
	LD	HL,US_RBA
	LD	C,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	DE,US_FCB
	CALL	DOS_POS_RBA
	JP	NZ,INT_ERROR
	LD	B,UF_LRL
	LD	HL,US_UBUFF
CS_1	LD	A,(HL)
	PUSH	BC
	CALL	$PUT
	POP	BC
	JP	NZ,INT_ERROR
	INC	HL
	DJNZ	CS_1
	JP	PARAM
;
CMD_NBELL
	RES	TF_BELL,(IX)
	JP	PARAM
;
CMD_NLF
	RES	TF_CRLF,(IX)
	JP	PARAM
;
CMD_NCURSOR
	SET	TF_CURSOR,(IX)
	JP	PARAM
;
CMD_NECHOE
	RES	TF_BS,(IX)
	JP	PARAM
;
;
NOT_IMP
	LD	HL,M_NOTIMP
	LD	DE,($STDOUT)
	CALL	MESS_0
	LD	A,0
	JP	TERMINATE
;
CMD_SHOW
	LD	A,(IX)
	LD	(TFLAG2),A
;
	LD	HL,PAR_BELL+2
	LD	DE,PAR_NBELL+2
	BIT	TF_BELL,(IX)
	CALL	MESS_NZ		;for HL
	LD	HL,PAR_LF+2
	LD	DE,PAR_NLF+2
	BIT	TF_CRLF,(IX)
	CALL	MESS_NZ
	LD	HL,PAR_CURSOR+2
	LD	DE,PAR_NCURSOR+2
	BIT	TF_CURSOR,(IX)
	CALL	MESS_Z
	LD	HL,PAR_ECHOE+2
	LD	DE,PAR_NECHOE+2
	BIT	TF_BS,(IX)
	CALL	MESS_NZ
	LD	HL,PAR_16+2
	LD	DE,PAR_24+2
	BIT	TF_HEIGHT,(IX)
	CALL	MESS_Z
	LD	A,(IX)
	AND	3
	LD	HL,PAR_32+2
	JR	Z,MWIDTH
	LD	HL,PAR_40+2
	CP	1
	JR	Z,MWIDTH
	LD	HL,PAR_64+2
	CP	2
	JR	Z,MWIDTH
	LD	HL,PAR_80+2
MWIDTH	CALL	MESS_HL
;	LD	HL,PAR_300+2
;	CALL	MESS_HL
;	LD	HL,PAR_ANS+2
;	CALL	MESS_HL
	LD	A,CR
	CALL	STD_OUT
	JP	PARAM
;
MESS_NZ
	EX	DE,HL
MESS_Z
	JR	Z,MESS_HL
	EX	DE,HL
MESS_HL	LD	DE,($STDOUT)
	CALL	MESS_0
	LD	A,' '
	CALL	$PUT
	RET
;
FIND				;Find user record.
	LD	HL,(USR_NAME)
	LD	DE,MY_NAME
FIND_1	LD	A,(HL)
	CP	CR
	JR	Z,FIND_2
	OR	A
	JR	Z,FIND_2
	CP	ETX
	JR	Z,FIND_2
	LD	(DE),A
	INC	HL
	INC	DE
	JR	FIND_1
FIND_2	XOR	A
	LD	(DE),A
	LD	HL,MY_NAME
	CALL	USER_SEARCH
	JP	NZ,INT_ERROR
	RET
;
INT_ERROR
	LD	DE,US_FCB
	CALL	DOS_CLOSE
	LD	HL,M_INTERR
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,130
	JP	TERMINATE
;
*GET	ROUTINES
;
M_INTERR
	DEFM	'stty: Internal error!',CR,0
MY_NAME
	DEFS	24
;
M_NOTIMP
	DEFM	'stty: Baud rate / Frequency selection setting not implemented.',CR,0
;
PAR_TBL
	DEFW	PAR_LOAD,PAR_BELL,PAR_LF,PAR_CURSOR
	DEFW	PAR_ECHOE,PAR_16,PAR_24,PAR_32
	DEFW	PAR_40,PAR_64,PAR_80,PAR_300
	DEFW	PAR_1200,PAR_ANS,PAR_ORIG,PAR_SAVE
	DEFW	PAR_NBELL,PAR_NLF,PAR_NCURSOR,PAR_NECHOE
	DEFW	PAR_SHOW
	DEFW	0
;
PAR_LOAD
	DEFW	CMD_LOAD
	DEFM	'load',0
PAR_BELL
	DEFW	CMD_BELL
	DEFM	'bell',0
PAR_LF
	DEFW	CMD_LF
	DEFM	'lf',0
PAR_CURSOR
	DEFW	CMD_CURSOR
	DEFM	'cursor',0
PAR_ECHOE
	DEFW	CMD_ECHOE
	DEFM	'echoe',0
PAR_16
	DEFW	CMD_16
	DEFM	'16',0
PAR_24
	DEFW	CMD_24
	DEFM	'24',0
PAR_32
	DEFW	CMD_32
	DEFM	'32',0
PAR_40
	DEFW	CMD_40
	DEFM	'40',0
PAR_64
	DEFW	CMD_64
	DEFM	'64',0
PAR_80
	DEFW	CMD_80
	DEFM	'80',0
PAR_300
	DEFW	CMD_300
	DEFM	'300',0
PAR_1200
	DEFW	CMD_1200
	DEFM	'1200',0
PAR_ANS
	DEFW	CMD_ANS
	DEFM	'ans',0
PAR_ORIG
	DEFW	CMD_ORIG
	DEFM	'orig',0
PAR_SAVE
	DEFW	CMD_SAVE
	DEFM	'save',0
PAR_NBELL
	DEFW	CMD_NBELL
	DEFM	'-bell',0
PAR_NLF
	DEFW	CMD_NLF
	DEFM	'-lf',0
PAR_NCURSOR
	DEFW	CMD_NCURSOR
	DEFM	'-cursor',0
PAR_NECHOE
	DEFW	CMD_NECHOE
	DEFM	'-echoe',0
PAR_SHOW
	DEFW	CMD_SHOW
	DEFM	'show',0
;
M_USAGE
	DEFM	'STTY:  Setup your terminal characteristics',CR
	DEFM	'Usage: STTY [load] [[-]bell] [[-]lf] [[-]cursor] [[-]echoe] [16] [24] [32] [40]   [64] [80] [show] [save]',CR
	DEFM	'Eg:    STTY -bell 80 show',CR,0
;
ARGP	DEFW	0
TBL_PTR	DEFW	0
S_TFLAG2
	DEFB	0
;
THIS_PROG_END	EQU	$
;
	END	START
