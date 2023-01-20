;fileupd: Update a file with lines from another file.
;Both files assumed sorted (updates performed in order).
;Trs-80 Model 1 Newdos-80
;
*GET	DOSCALLS
CR	EQU	0DH
;
	COM	'<Fileupd 1.0  28-Jan-87 Trs-80 Newdos>'
;
	ORG	5300H
START	LD	SP,START
	LD	A,(HL)
	CP	CR
	JP	Z,USAGE
;
	LD	DE,FCB_IN	;Input file
	CALL	DOS_EXTRACT
	JP	NZ,USAGE
	LD	DE,FCB_OUT	;Output file
	CALL	DOS_EXTRACT
	JP	NZ,USAGE
	LD	DE,FCB_CHG	;File of changes
	CALL	DOS_EXTRACT
	JP	NZ,USAGE
;
	LD	HL,BUF_IN
	LD	DE,FCB_IN
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
;
	LD	HL,BUF_OUT
	LD	DE,FCB_OUT
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,ERROR
;
	LD	HL,BUF_CHG
	LD	DE,FCB_CHG
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
;
LOOP_CHG
	CALL	GET_CHG
LOOP_IN
	CALL	GET_IN
	JP	NZ,EOF
	CALL	IF_MATCH
	JR	NZ,LOOP_1
	CALL	WRITE_CHG
	JR	LOOP_CHG
LOOP_1
	CALL	WRITE_IN
	JR	LOOP_IN
;
EOF	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	JP	NZ,ERROR
	JP	DOS_NOERROR
;
USAGE	LD	HL,M_USAGE
	CALL	MESS
	JP	DOS_NOERROR
;
MESS	LD	A,(HL)
	OR	A
	RET	Z
	CALL	33H
	INC	HL
	JR	MESS
;
GET_CHG
	LD	HL,STR_CHG
	LD	(HL),0
	LD	DE,FCB_CHG
GC_1	CALL	$GET
	JR	NZ,GC_2
	CP	CR
	JR	Z,GC_3
	LD	(HL),A
	INC	HL
	JR	GC_1
GC_2	CP	1CH
	JP	NZ,ERROR
	OR	A
	RET
;
GC_3	LD	(HL),0
	RET
;
GET_IN
	LD	HL,STR_IN
	LD	(HL),0
	LD	DE,FCB_IN
GI_1	CALL	$GET
	JR	NZ,GI_2
	CP	CR
	JR	Z,GI_3
	LD	(HL),A
	INC	HL
	JR	GI_1
GI_2	CP	1CH
	JP	NZ,ERROR
	OR	A
	RET
;
GI_3	LD	(HL),0
	RET
;
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	DOS_NOERROR
;
WRITE_CHG
	LD	HL,STR_CHG
	JR	WRITE
WRITE_IN
	LD	HL,STR_IN
	JR	WRITE
;
WRITE
	LD	DE,FCB_OUT
WR_1	LD	A,(HL)
	OR	A
	JR	Z,WR_2
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	JR	WR_1
;
WR_2	LD	A,CR
	CALL	$PUT
	JP	NZ,ERROR
	RET
;
IF_MATCH
	LD	HL,STR_IN
	LD	DE,STR_CHG
	LD	B,13		;length to compare.
IM_1	LD	A,(DE)
	CP	(HL)
	RET	NZ
	INC	DE
	INC	HL
	DJNZ	IM_1
	CP	A
	RET
;
M_USAGE	DEFM	'Usage: fileupd infile outfile changefile',CR
	DEFM	'Match performed on first 13 chars of each line',CR,0
;
FCB_IN	DEFS	32
FCB_OUT	DEFS	32
FCB_CHG	DEFS	32
;
BUF_IN	DEFS	256
BUF_OUT	DEFS	256
BUF_CHG	DEFS	256
;
STR_IN	DEFS	256
STR_OUT	DEFS	256
STR_CHG	DEFS	256
;
	END	START
