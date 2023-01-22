;textdiff: Difference of two text files.
*GET	DOSCALLS
;
	ORG	5300H
START	LD	SP,START
	LD	DE,FCB_IN1
	CALL	DOS_EXTRACT
	LD	DE,FCB_IN2
	CALL	DOS_EXTRACT
	LD	HL,BUFF_IN1
	LD	DE,FCB_IN1
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,DOS_ERROR
	LD	HL,BUFF_IN2
	LD	DE,FCB_IN2
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,DOS_ERROR
;
;
LOOP
	CALL	READ_1
	CALL	READ_2
	CALL	IF_EOF
	JR	NZ,EOF_FOUND
	CALL	STR_CMP
	JR	Z,LOOP
	JR	DIFF
EOF_FOUND
	JP	DOS_NOERROR
;
MESS	LD	A,(HL)
	CP	03H
	RET	Z
	CALL	ROM@PUT_VDU
	INC	HL
	JR	MESS
;
DIFF
	LD	HL,M_DIF1
	CALL	MESS
	CALL	PUT_1
	CALL	PUT_2
	JR	LOOP
;
M_DIF1	DEFM	'Lines differ:',0DH,03H
READ_1	LD	DE,FCB_IN1
	LD	HL,BUFF1
R1_1	CALL	ROM@GET
	JR	NZ,R1_2
	LD	(HL),A
	INC	HL
	CP	0DH
	JR	NZ,R1_1
	RET
;
READ_2	LD	DE,FCB_IN2
	LD	HL,BUFF2
R2_1	CALL	ROM@GET
	JR	NZ,R2_2
	LD	(HL),A
	INC	HL
	CP	0DH
	JR	NZ,R2_1
	RET
;
R1_2
R2_2	LD	A,1
	LD	(EOF_FLAG),A
	RET
;
IF_EOF
	LD	A,(EOF_FLAG)
	OR	A
	RET
;
STR_CMP
	LD	HL,BUFF1
	LD	DE,BUFF2
SC_1	LD	A,(DE)
	CP	(HL)
	RET	NZ
	CP	0DH
	RET	Z
	INC	HL
	INC	DE
	JR	SC_1
;
PUT_1	LD	HL,BUFF1
MESS_CR	LD	A,(HL)
	CALL	ROM@PUT_VDU
	LD	A,(HL)
	INC	HL
	CP	0DH
	JR	NZ,MESS_CR
	RET
;
PUT_2	LD	HL,BUFF2
	JR	MESS_CR
;
FCB_IN1	DEFS	32
FCB_IN2	DEFS	32
BUFF_IN1	DEFS	256
BUFF_IN2	DEFS	256
BUFF1	DEFS	256
BUFF2	DEFS	256
EOF_FLAG	DEFB	0
;
	END	START
