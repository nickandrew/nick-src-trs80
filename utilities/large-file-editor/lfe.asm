;lfe: Large File editor ... can edit a file up to 128k.
;Uses pages 64-191...
;
*GET	DOSCALLS
;
NULL	EQU	00H
LF	EQU	0AH
CR	EQU	0DH
CPMEOF	EQU	1AH
;
	COM	'<lfe 1.0  26-Jan-87>'
;
	ORG	5300H
START	LD	SP,START
;
	CALL	INIT		;Initialise buffer.
;
COMMAND
	LD	SP,START
	LD	HL,M_PROMPT
	CALL	MESS
	LD	HL,CMD_BUFF
	LD	B,62
	CALL	40H
	JP	C,COMMAND
;
	LD	HL,0		;Set range defaults.
	LD	(FIRST),HL
	LD	(LAST),HL
;
	LD	HL,CMD_BUFF
	CALL	FIRST_LINE
	CALL	LAST_LINE
;
	PUSH	HL
	LD	HL,(LAST)	;Check that first<=last
	LD	DE,(FIRST)
	OR	A
	SBC	HL,DE
	JP	C,COMMAND
	POP	HL
;
	CALL	DO_COMMAND
	JR	COMMAND
;
M_PROMPT
	DEFM	'>',0
;
CMD_BUFF
	DEFS	80
;
;initialise 128k buffer & all pointers.
INIT
	LD	HL,LINE_INDEX
	LD	(HL),0
	INC	HL
	LD	(HL),0
	INC	HL
	LD	(HL),0
;
	LD	HL,PAGE1
	LD	A,64		;first page used
	LD	(PAGE1_NUM),A
	CALL	SET_PAGE
	XOR	A
	LD	(PAGE1),A	;set EOF.
	RET
;
FIRST_LINE
	LD	A,(HL)
	CP	'.'
	JR	Z,F_DOT_REL
	CP	'$'
	JR	Z,F_DLR_REL
	CALL	IFDIGIT
	RET	NZ
	CALL	GET_NUM
	LD	(FIRST),DE
	LD	(LAST),DE
	CALL	CHECK_RANGE
	RET
F_DOT_REL
	LD	DE,(DOT)
	LD	(FIRST),DE
	JR	F_REL
F_DLR_REL
	LD	DE,(DLR)
	LD	(FIRST),DE
	JR	F_REL
;
F_REL	INC	HL
	LD	(LAST),DE
	LD	A,(HL)
	CP	'-'
	JR	Z,F_REL_SUB
	CP	'+'
	RET	NZ
	INC	HL
	LD	A,(HL)
	CALL	IFDIGIT
	JP	NZ,COMMAND
	CALL	GET_NUM
	PUSH	HL
	LD	HL,(FIRST)
	ADD	HL,DE
	LD	(FIRST),HL
	LD	(LAST),HL
	LD	DE,(FIRST)
	CALL	CHECK_RANGE
	POP	HL
	RET
;
F_REL_SUB
	INC	HL
	LD	A,(HL)
	CALL	IFDIGIT
	JP	NZ,COMMAND
	CALL	GET_NUM
	PUSH	HL
	LD	HL,(FIRST)
	OR	A
	SBC	HL,DE
	LD	(FIRST),HL
	LD	(LAST),HL
	LD	DE,(FIRST)
	CALL	CHECK_RANGE
	POP	HL
	RET
;
;Get a number into DE from HL.
GET_NUM
	LD	DE,0
GN_01	LD	A,(HL)
	CALL	IFDIGIT
	RET	NZ
	PUSH	HL
;
	PUSH	DE	;do de*=10
	POP	HL	;hl=de
	ADD	HL,HL	;hl=de*2
	ADD	HL,HL	;hl=de*4
	ADD	HL,DE	;hl=de*5
	ADD	HL,HL	;hl=de*10
	SUB	'0'
	LD	E,A
	LD	D,0
	ADD	HL,DE	;add digit
	EX	DE,HL
;
	POP	HL
	INC	HL
	JR	GN_01
;
IFDIGIT
	CP	'0'
	RET	C	;NZ set.
	CP	'9'
	RET	NC	;Z set if '9', otherwise NZ if >
	CP	A
	RET
;
LAST_LINE
	LD	A,(HL)
	CP	','
	RET	NZ
	INC	HL
	LD	A,(HL)
	CP	'.'
	JR	Z,L_DOT_REL
	CP	'$'
	JR	Z,L_DLR_REL
	CALL	IFDIGIT
	RET	NZ
	CALL	GET_NUM
	LD	(LAST),DE
	CALL	CHECK_RANGE
	RET
L_DOT_REL
	LD	DE,(DOT)
	LD	(LAST),DE
	JR	L_REL
L_DLR_REL
	LD	DE,(DLR)
	LD	(LAST),DE
	JR	L_REL
;
L_REL	INC	HL
	LD	A,(HL)
	CP	'-'
	JR	Z,L_REL_SUB
	CP	'+'
	RET	NZ
	INC	HL
	LD	A,(HL)
	CALL	IFDIGIT
	JP	NZ,COMMAND
	CALL	GET_NUM
	PUSH	HL
	LD	HL,(LAST)
	ADD	HL,DE
	LD	(LAST),HL
	EX	DE,HL
	CALL	CHECK_RANGE
	POP	HL
	RET
;
L_REL_SUB
	INC	HL
	LD	A,(HL)
	CALL	IFDIGIT
	JP	NZ,COMMAND
	CALL	GET_NUM
	PUSH	HL
	LD	HL,(LAST)
	OR	A
	SBC	HL,DE
	LD	(LAST),HL
	EX	DE,HL
	CALL	CHECK_RANGE
	POP	HL
	RET
;
;Check a number is within the range 1..(DLR)
CHECK_RANGE
	LD	A,D
	OR	E
	JP	Z,COMMAND
	PUSH	HL
	LD	HL,(DLR)
	OR	A
	SBC	HL,DE
	POP	HL
	JP	C,COMMAND
	RET
;
FIRST		DEFW	0	;FIRST,LASTcommand
LAST		DEFW	0	;FIRST,LASTcommand
DOT		DEFW	0	;current line
DLR		DEFW	0	;last line
;
DOT_NUM		DEFB	0
DOT_PTR		DEFW	0
;
;print a message
MESS	LD	A,(HL)
	OR	A
	RET	Z
	CALL	PUT
	INC	HL
	JR	MESS
;
PUT	JP	33H
;
DO_COMMAND
	LD	A,(HL)
	CP	CR
	JP	Z,DOWN_1_LINE
	CP	'+'
	JP	Z,PLUS_1_LINE
	CP	'-'
	JP	Z,MINUS_1_LINE
	CP	'='
	JP	Z,EQUALS
	CP	'/'
	JP	Z,SLASH
	AND	5FH
	CP	'A'
	JP	Z,APPEND
	CP	'D'
	JP	Z,DELETE
	CP	'I'
	JP	Z,INSERT
	CP	'P'
	JP	Z,PRINT_LINES
	CP	'Q'
	JP	Z,QUIT
	CP	'R'
	JP	Z,READ_FILE
	CP	'W'
	JP	Z,WRITE_FILE
	RET
;
DOWN_1_LINE
	CALL	NLB
	LD	HL,(FIRST)
	LD	A,H
	OR	L
	JR	NZ,D1L_1
	LD	HL,(DOT)
	INC	HL
D1L_1
	EX	DE,HL
	CALL	CHECK_RANGE
	LD	(DOT),DE
	CALL	PRINT_DOT
	JP	COMMAND
;
READ_FILE
	INC	HL
	CALL	BYP_SP
	LD	DE,FCB_FILE
	CALL	DOS_EXTRACT
	JP	NZ,COMMAND
	LD	HL,BUF_FILE
	LD	DE,FCB_FILE
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,RF_ERR
;
	LD	HL,0
	LD	(DOT),HL
	LD	(DLR),HL
;
	LD	HL,LINE_INDEX
	LD	(LINE_PTR),HL
;
	LD	A,64
	LD	(LAST_NUM),A
	LD	HL,0
	LD	(LAST_PTR),HL
;
	LD	A,(LAST_NUM)
	LD	(PAGE1_NUM),A
	LD	HL,(LAST_PTR)
	LD	DE,PAGE1
	ADD	HL,DE
	LD	(PAGE1_PTR),HL
	CALL	SET_PAGE
;
RF_01	LD	DE,FCB_FILE
	CALL	ROM@GET
	JP	NZ,RF_ERR
RF_02	CP	CR
	JR	Z,RF_CR
	CP	LF
	JR	Z,RF_LF
	CP	NULL
	JP	Z,RF_EOF
	CP	CPMEOF
	JP	Z,RF_EOF
	CALL	PAGE1_PUT
	JR	RF_01
;
RF_CR	CALL	PAGE1_PUT
;
	LD	HL,(DLR)
	INC	HL
	LD	(DLR),HL
	LD	(DOT),HL
;
	LD	HL,(LINE_PTR)
	LD	A,(LAST_NUM)
	LD	DE,(LAST_PTR)
	LD	(HL),A
	INC	HL
	LD	A,D
	AND	3
	LD	(HL),E
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(LINE_PTR),HL
;
	LD	A,(PAGE1_NUM)
	LD	(LAST_NUM),A
	LD	HL,(PAGE1_PTR)
	LD	DE,PAGE1
	OR	A
	SBC	HL,DE
	LD	(LAST_PTR),HL
;
	LD	DE,FCB_FILE
	CALL	ROM@GET
	JP	NZ,RF_ERR
	CP	LF
	JR	NZ,RF_02
	JR	RF_01
;
RF_LF	LD	A,CR
	CALL	PAGE1_PUT
;
	LD	HL,(DLR)
	INC	HL
	LD	(DLR),HL
	LD	(DOT),HL
;
	LD	HL,(LINE_PTR)
	LD	A,(LAST_NUM)
	LD	DE,(LAST_PTR)
	LD	(HL),A
	INC	HL
	LD	A,D
	AND	3
	LD	(HL),E
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(LINE_PTR),HL
;
	LD	A,(PAGE1_NUM)
	LD	(LAST_NUM),A
	LD	HL,(PAGE1_PTR)
	LD	DE,PAGE1
	OR	A
	SBC	HL,DE
	LD	(LAST_PTR),HL
;
	JP	RF_01
;
RF_ERR	CP	1CH
	JR	Z,RF_EOF
	CP	1DH
	JR	Z,RF_EOF
	OR	80H
	CALL	DOS_ERROR
	JP	COMMAND
RF_EOF	XOR	A
	CALL	PAGE1_PUT
;
	LD	HL,(LINE_PTR)
	LD	(HL),0
	INC	HL
	LD	(HL),0
	INC	HL
	LD	(HL),0
;
	JP	COMMAND
;
SET_PAGE
	LD	B,H
	LD	C,10H
	OUT	(C),A
	RET
;
PAGE1_PUT
	LD	HL,(PAGE1_PTR)
	LD	(HL),A
	INC	HL
	LD	(PAGE1_PTR),HL
	LD	A,L
	OR	A
	RET	NZ
	LD	A,H
	AND	3
	RET	NZ
	LD	HL,PAGE1
	LD	(PAGE1_PTR),HL
	LD	A,(PAGE1_NUM)
	INC	A
	LD	(PAGE1_NUM),A
	CALL	SET_PAGE
	RET
;
PAGE1_PTR	DEFW	0
PAGE1_NUM	DEFB	0
PAGE2_PTR	DEFW	0
PAGE2_NUM	DEFB	0
;
PAGE1	EQU	0A000H
PAGE2	EQU	0A400H
OLD1	EQU	24
OLD2	EQU	25
;
FCB_FILE	DEFS	32
BUF_FILE	DEFS	256
;
BYP_SP	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	BYP_SP
;
;
COUNT		DEFW	0
;
PRINT_DOT
	LD	HL,(DOT)
	DEC	HL
	PUSH	HL
	POP	DE
	ADD	HL,HL
	ADD	HL,DE
	LD	DE,LINE_INDEX
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,PAGE2
	ADD	HL,DE
	LD	(PAGE2_PTR),HL
	LD	(PAGE2_NUM),A
	LD	HL,PAGE2
	CALL	SET_PAGE
;
PD_01	CALL	PAGE2_GET
	CALL	PUT
	CP	CR
	JR	NZ,PD_01
	RET
;
PAGE2_PUT
	LD	HL,(PAGE2_PTR)
	LD	(HL),A
	INC	HL
	LD	(PAGE2_PTR),HL
	LD	A,L
	OR	A
	RET	NZ
	LD	A,H
	AND	3
	RET	NZ
	LD	HL,PAGE2
	LD	(PAGE2_PTR),HL
	LD	A,(PAGE2_NUM)
	INC	A
	LD	(PAGE2_NUM),A
	CALL	SET_PAGE
	RET
;
PAGE2_GET
	LD	HL,(PAGE2_PTR)
	LD	A,(HL)
	INC	HL
	LD	(PAGE2_PTR),HL
	LD	B,A
	LD	A,L
	OR	A
	JR	Z,P2G_02
P2G_01	LD	A,B
	RET
P2G_02	LD	A,H
	AND	3
	JR	NZ,P2G_01
	PUSH	BC
	LD	HL,PAGE2
	LD	(PAGE2_PTR),HL
	LD	A,(PAGE2_NUM)
	INC	A
	LD	(PAGE2_NUM),A
	CALL	SET_PAGE
	POP	BC
	LD	A,B
	RET
;
LAST_NUM	DEFB	0
LAST_PTR	DEFW	0
START_NUM	DEFB	0
START_PTR	DEFW	0
LINE_PTR	DEFW	0
;
	DEFM	'line_index>'
LINE_INDEX
	DEFS	3*1024		;Max 1024 lines.
;
EQUALS	LD	HL,(FIRST)
	CALL	PUT_NUM
	LD	A,CR
	CALL	PUT
	JP	COMMAND
;
PUT_NUM
	LD	DE,10000
	CALL	PUT_DIGIT
	LD	DE,1000
	CALL	PUT_DIGIT
	LD	DE,100
	CALL	PUT_DIGIT
	LD	DE,10
	CALL	PUT_DIGIT
	LD	DE,1
	CALL	PUT_DIGIT
	RET
;
PUT_DIGIT
	LD	B,2FH
PD_02	INC	B
	OR	A
	SBC	HL,DE
	JR	NC,PD_02
	ADD	HL,DE
	LD	A,B
	CALL	PUT
	RET
;
FLAG_1	DEFB	0
;Definitions of flag_1
F1_NUMBER	EQU	0
F1_UPDATED	EQU	1
F1_CPMEOF	EQU	2
F1_LF		EQU	3
;
PLUS_1_LINE
	CALL	NLB
	LD	DE,(DOT)
P1L_01	INC	DE
	INC	HL
	LD	A,(HL)
	CP	'+'
	JR	Z,P1L_01
	CALL	CHECK_RANGE
	LD	(DOT),DE
	CALL	PRINT_DOT
	JP	COMMAND
;
MINUS_1_LINE
	CALL	NLB
	LD	DE,(DOT)
M1L_01	DEC	DE
	INC	HL
	LD	A,(HL)
	CP	'-'
	JR	Z,M1L_01
	CALL	CHECK_RANGE
	LD	(DOT),DE
	CALL	PRINT_DOT
	JP	COMMAND
;
PRINT_LINES
	CALL	NLB
	LD	HL,(FIRST)
	LD	A,H
	OR	L
	JR	NZ,PL_01
;
;No range given so assume: .,.+14p
	LD	HL,(DOT)
	LD	(FIRST),HL
	LD	DE,14
	ADD	HL,DE
	LD	(LAST),HL
	LD	DE,(DLR)
	OR	A		;if $<.+14 use $ instead
	EX	DE,HL
	SBC	HL,DE
	JR	NC,PL_01
	LD	HL,(DLR)
	LD	(LAST),HL
;
PL_01
	LD	HL,(FIRST)
	LD	(DOT),HL
PL_02
	CALL	PRINT_DOT
	LD	HL,(LAST)
	LD	DE,(DOT)
	OR	A
	SBC	HL,DE
	JP	Z,COMMAND
	INC	DE
	LD	(DOT),DE
	JR	PL_02
;
WRITE_FILE
	CALL	NLB
	INC	HL
	CALL	BYP_SP
	LD	DE,FCB_FILE
	CALL	DOS_EXTRACT
	JP	NZ,COMMAND
	LD	HL,BUF_FILE
	LD	DE,FCB_FILE
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,WF_ERR
;
	LD	HL,(FIRST)
	LD	A,H
	OR	L
	JR	NZ,WF_01
;
;No range given so assume: 1,$w filename
	LD	HL,1
	LD	(FIRST),HL
	LD	HL,(DLR)
	LD	(LAST),HL
WF_01
	LD	HL,(FIRST)
	DEC	HL
	PUSH	HL
	POP	DE
	ADD	HL,HL
	ADD	HL,DE
	LD	DE,LINE_INDEX
	ADD	HL,DE
	LD	(LINE_PTR),HL
;
;*******************************************************
WF_02	CALL	WRITE_FIRST
	JP	NZ,WF_ERR
	LD	HL,(LAST)
	LD	DE,(FIRST)
	OR	A
	SBC	HL,DE
	JP	Z,WF_EOF
	INC	DE
	LD	(FIRST),DE
;
	LD	HL,(LINE_PTR)
	INC	HL
	INC	HL
	INC	HL
	LD	(LINE_PTR),HL
;
	JR	WF_02
;
;
WF_ERR
	OR	80H
	CALL	DOS_ERROR
	JP	COMMAND
WF_EOF
	LD	DE,FCB_FILE
	CALL	DOS_CLOSE
	JP	COMMAND
;
WRITE_FIRST
	LD	HL,(LINE_PTR)
	LD	A,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(PAGE2_NUM),A
	EX	DE,HL
	LD	DE,PAGE2
	ADD	HL,DE
	LD	(PAGE2_PTR),HL
	EX	DE,HL
	CALL	SET_PAGE
;
WF_03	CALL	PAGE2_GET
	CP	CR
	JR	Z,WF_04
	LD	DE,FCB_FILE
	CALL	ROM@PUT
	JP	NZ,WF_ERR
	JR	WF_03
WF_04	LD	DE,FCB_FILE
	CALL	ROM@PUT
;* code for CRLF here I suppose *
	RET
;
QUIT
	LD	A,OLD1
	LD	HL,PAGE1
	CALL	SET_PAGE
	LD	A,OLD2
	LD	HL,PAGE2
	CALL	SET_PAGE
	JP	DOS_NOERROR
;
;Delete lines: default is .,.d
;after deleting DOT is set to line after last deleted,
;if last line is $ then DOT is set to new $.
DELETE
	CALL	NLB
	LD	HL,(FIRST)
	LD	A,H
	OR	L
	JR	NZ,DE_01
;
;No range given so assume: .,.d
	LD	HL,(DOT)
	LD	(FIRST),HL
	LD	(LAST),HL
;
DE_01
	LD	HL,(FIRST)
	LD	(DOT),HL
DE_02
	CALL	DELETE_DOT	;.d;--$
	LD	HL,(LAST)
	LD	DE,(FIRST)
	OR	A
	SBC	HL,DE
	JP	Z,DE_03
	INC	DE
	LD	(FIRST),DE
	JR	DE_02
;
DE_03	LD	HL,(DLR)
	LD	DE,(DOT)
	OR	A
	SBC	HL,DE
	JR	NC,DE_04
	DEC	DE
	LD	(DOT),DE
DE_04
	CALL	PRINT_DOT
	JP	COMMAND
;
DELETE_DOT
	LD	HL,(DOT)
	DEC	HL
	PUSH	HL
	POP	DE
	ADD	HL,HL
	ADD	HL,DE
	LD	DE,LINE_INDEX
	ADD	HL,DE
	PUSH	HL		;addr of index to "."
	LD	HL,(DLR)
	INC	HL
	LD	DE,(DOT)
	OR	A
	SBC	HL,DE		;=1/3 of bytes to move.
	PUSH	HL
	POP	DE
	ADD	HL,HL
	ADD	HL,DE
	PUSH	HL
	POP	BC
	POP	DE
	PUSH	DE
	POP	HL
	INC	HL
	INC	HL
	INC	HL
	LDIR		;move table down.
	LD	HL,(DLR)
	DEC	HL
	LD	(DLR),HL
	RET
;
NLB	PUSH	AF
	PUSH	HL
	LD	HL,(DLR)
	LD	A,H
	OR	L
	JR	Z,NLB_NLB
	POP	HL
	POP	AF
	RET
NLB_NLB
	LD	HL,M_NLB
	CALL	MESS
	JP	COMMAND
;
M_NLB	DEFM	'No lines in the buffer',CR,0
;
INSERT				;Default is .i
	LD	HL,(FIRST)
	LD	A,H
	OR	L
	JR	Z,IN_01
	LD	(DOT),HL
IN_01
	LD	HL,INS_BUFF
	LD	B,80
	CALL	40H
	JR	C,IN_01
	LD	A,(HL)
	CP	'.'
	JR	NZ,IN_02
	INC	HL
	LD	A,(HL)
	CP	CR
	JP	Z,COMMAND
IN_02
	LD	HL,(DLR)
	LD	DE,(DOT)
	OR	A
	SBC	HL,DE
	INC	HL
	INC	HL
	PUSH	HL
	POP	DE		;hl,de=$-.+2
	ADD	HL,HL
	ADD	HL,DE
	PUSH	HL
	POP	BC		;bc=count to move.
	LD	DE,(DLR)
	LD	HL,LINE_INDEX
	ADD	HL,DE
	ADD	HL,DE
	ADD	HL,DE
	INC	HL
	INC	HL
	PUSH	HL
	INC	HL
	INC	HL
	INC	HL
	EX	DE,HL
	POP	HL
	LDDR
;
	LD	HL,(DOT)
	DEC	HL
	EX	DE,HL
	LD	HL,LINE_INDEX
	ADD	HL,DE
	ADD	HL,DE
	ADD	HL,DE
	LD	A,(LAST_NUM)
	LD	(HL),A
	INC	HL
	LD	DE,(LAST_PTR)
	LD	(HL),E
	INC	HL
	LD	A,D
	AND	3
	LD	(HL),A
;
	LD	HL,(DOT)
	INC	HL
	LD	(DOT),HL
	LD	HL,(DLR)
	INC	HL
	LD	(DLR),HL
;
	LD	A,(LAST_NUM)
	LD	(PAGE1_NUM),A
	LD	HL,(LAST_PTR)
	LD	DE,PAGE1
	ADD	HL,DE
	LD	(PAGE1_PTR),HL
	CALL	SET_PAGE
;
	LD	HL,INS_BUFF
IN_03	PUSH	HL
	LD	A,(HL)
	CALL	PAGE1_PUT
	POP	HL
	LD	A,(HL)
	INC	HL
	CP	CR
	JR	NZ,IN_03
;
	LD	A,(PAGE1_NUM)
	LD	(LAST_NUM),A
	LD	HL,(PAGE1_PTR)
	LD	DE,PAGE1
	OR	A
	SBC	HL,DE
	LD	(LAST_PTR),HL
	JP	IN_01
;
INS_BUFF	DEFS	256
;
APPEND				;Default is .a
	LD	HL,(FIRST)
	LD	A,H
	OR	L
	JR	Z,AP_01
	LD	(DOT),HL
AP_01
	LD	HL,INS_BUFF
	LD	B,80
	CALL	40H
	JR	C,AP_01
	LD	A,(HL)
	CP	'.'
	JR	NZ,AP_02
	INC	HL
	LD	A,(HL)
	CP	CR
	JP	Z,COMMAND
AP_02
	LD	HL,(DLR)
	LD	DE,(DOT)
	OR	A
	SBC	HL,DE
	INC	HL
;;	INC	HL	;Append this is, not insert!
	PUSH	HL
	POP	DE		;hl,de=$-.+1
	ADD	HL,HL
	ADD	HL,DE
	PUSH	HL
	POP	BC		;bc=count to move.
	LD	DE,(DLR)
	LD	HL,LINE_INDEX
	ADD	HL,DE
	ADD	HL,DE
	ADD	HL,DE
	INC	HL
	INC	HL
	PUSH	HL
	INC	HL
	INC	HL
	INC	HL
	EX	DE,HL
	POP	HL
	LDDR
;
	LD	DE,(DOT)
;;	DEC	HL		;Its append not insert
;;	EX	DE,HL
	LD	HL,LINE_INDEX
	ADD	HL,DE
	ADD	HL,DE
	ADD	HL,DE
	LD	A,(LAST_NUM)
	LD	(HL),A
	INC	HL
	LD	DE,(LAST_PTR)
	LD	(HL),E
	INC	HL
	LD	A,D
	AND	3
	LD	(HL),A
;
	LD	HL,(DOT)
	INC	HL
	LD	(DOT),HL
	LD	HL,(DLR)
	INC	HL
	LD	(DLR),HL
;
	LD	A,(LAST_NUM)
	LD	(PAGE1_NUM),A
	LD	HL,(LAST_PTR)
	LD	DE,PAGE1
	ADD	HL,DE
	LD	(PAGE1_PTR),HL
	CALL	SET_PAGE
;
	LD	HL,INS_BUFF
AP_03	PUSH	HL
	LD	A,(HL)
	CALL	PAGE1_PUT
	POP	HL
	LD	A,(HL)
	INC	HL
	CP	CR
	JR	NZ,AP_03
;
	LD	A,(PAGE1_NUM)
	LD	(LAST_NUM),A
	LD	HL,(PAGE1_PTR)
	LD	DE,PAGE1
	OR	A
	SBC	HL,DE
	LD	(LAST_PTR),HL
	JP	AP_01
;
;slash: Default is  .,$/text/
SLASH
	CALL	NLB
	LD	(CMD_PTR),HL
	LD	HL,(FIRST)
	LD	A,H
	OR	L
	JR	NZ,SL_01
	LD	HL,(DOT)
SL_01	LD	(FIRST),HL
	LD	HL,(LAST)
	LD	A,H
	OR	L
	JR	NZ,SL_02
	LD	HL,(DLR)
SL_02	LD	(LAST),HL
;
	LD	HL,(CMD_PTR)
	LD	DE,INS_BUFF
	INC	HL
SL_03	LD	A,(HL)
	CP	CR
	JR	Z,SL_05
	CP	'/'
	JR	Z,SL_05		;end of string.
	CP	'\'
	JR	Z,SL_04
	LD	(DE),A
	INC	DE
	INC	HL
	JR	SL_03
;
SL_04	INC	HL
	LD	A,(HL)
	CP	CR
	JR	Z,SL_05
	LD	(DE),A
	INC	DE
	INC	HL
	JR	SL_03
;
SL_05	XOR	A
	LD	(DE),A
;
;Cop out..........***!*!!$&%'$&#%'$&%&'&$%'
	JP	COMMAND
;
CMD_PTR	DEFW	0
;
	END	START
