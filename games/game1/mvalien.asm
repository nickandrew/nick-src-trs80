; mvalien:1
; 19-Dec-84
;

*GET	DOSCALLS

MOVE_ALIEN_2
	LD	HL,AL_TAB
	LD	A,(TOP_ALIEN)
	OR	A
	JR	Z,MA_NONE
	LD	B,A
	LD	C,0
MA_LOOP	PUSH	BC
	LD	A,C
	LD	(ALIEN),A
	LD	A,(HL)
	PUSH	HL
	OR	A
	CALL	NZ,MOVE_ONE
	POP	HL
	LD	DE,5
	ADD	HL,DE
	POP	BC
	INC	C
	DJNZ	MA_LOOP
MA_NONE	RET
;
MOVE_ONE
	AND	1
	RET	Z
	LD	(_TABST),HL
EXECUT	INC	HL
	INC	HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(_TABEND),HL
	LD	A,(DE)
	CP	24
	RET	NC
	ADD	A,A
	PUSH	DE
	PUSH	HL
	LD	E,A
	LD	D,0
	LD	HL,I_TABLE
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	POP	HL
	PUSH	DE
	POP	IX
	POP	DE
	JP	(IX)
;
I_TABLE	DEFW	I_DISAP,I_GOTO,I_UP,I_DOWN,I_LEFT
	DEFW	I_RIGHT,I_INV,I_VIS,I_JUMP,I_REPT
	DEFW	I_ENDR,I_CALL,I_RETN,I_RNDJP,I_NULL
	DEFW	I_REPTD,I_ENDRD,I_CALLD,I_RETND,I_SYNC
	DEFW	I_REPTA,I_ENDRA,I_REPTB,I_ENDRB
;
I_DISAP	LD	HL,(_TABST)
	XOR	A
	LD	(HL),A
	LD	A,(ALIEN)
	LD	C,A
	CALL	RELS_LOOPS
	RET
;
I_GOTO	INC	DE
	LD	HL,(_TABST)
	INC	HL
	LD	A,(DE)
	LD	(HL),A
	INC	DE
	INC	HL
	LD	A,(DE)
	LD	(HL),A
	INC	DE
	INC	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	RET
;
I_UP	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	DEC	HL
	DEC	(HL)
	RET
;
I_DOWN	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	DEC	HL
	INC	(HL)
	RET
;
I_LEFT	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	DEC	HL
	DEC	HL
	DEC	(HL)
	DEC	(HL)
	RET
;
I_RIGHT	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	DEC	HL
	DEC	HL
	INC	(HL)
	INC	(HL)
	RET
;
I_INV
	RET
I_VIS
	RET
;
I_JUMP	INC	DE
	LD	A,(DE)
	DEC	HL
	LD	(HL),A
	INC	DE
	INC	HL
	LD	A,(DE)
	LD	(HL),A
	LD	HL,(_TABST)
	JP	EXECUT
;
I_REPT	INC	DE
	LD	A,(DE)
	INC	DE
	LD	(DE),A
	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	LD	HL,(_TABST)
	JP	EXECUT
;
I_ENDR	INC	DE
	INC	DE
	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	DEC	DE
	EX	DE,HL
	LD	B,(HL)
	DEC	HL
	LD	C,(HL)
	INC	BC
	INC	BC
	LD	A,(BC)
	DEC	A
	LD	(BC),A
	LD	HL,(_TABST)
	JP	Z,EXECUT
	PUSH	BC
	POP	HL
	EX	DE,HL
	INC	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,(_TABST)
	JP	EXECUT
;
I_CALL	INC	DE
	EX	DE,HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,H
	LD	(BC),A
	INC	BC
	LD	A,L
	LD	(BC),A
	INC	BC
	EX	DE,HL
	LD	(HL),B
	DEC	HL
	LD	(HL),C
	LD	HL,(_TABST)
	JP	EXECUT
;
I_RETN	INC	DE
	EX	DE,HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	PUSH	BC
	POP	HL
	INC	HL
	LD	A,(HL)
	LD	(DE),A
	DEC	HL
	DEC	DE
	LD	A,(HL)
	LD	(DE),A
	LD	HL,(_TABST)
	JP	EXECUT
;
I_RNDJP	JP	I_DISAP
;
I_NULL	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	RET
;
I_REPTD
	RET
	INC	DE
	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	LD	HL,(LOOP_PTR)
	LD	A,(ALIEN)
	LD	(HL),A
	INC	HL
	DEC	DE
	DEC	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	INC	DE
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	LD	(LOOP_PTR),HL
	LD	HL,(_TABST)
	JP	EXECUT
;
I_ENDRD
	RET
	INC	DE
	EX	DE,HL
	LD	(_INSADDR),HL
	LD	HL,LOOP_STK
I_E_1	CALL	CP_END_L
	JP	Z,ERROR
	PUSH	HL
	CALL	CK_1_L
	POP	HL
	JR	Z,I_E_2
	LD	DE,4
	ADD	HL,DE
	JR	I_E_1
I_E_2	INC	HL
	INC	HL
	INC	HL
	DEC	(HL)
	JR	Z,I_E_3
	LD	HL,(_INSADDR)
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	DE
	INC	DE
	LD	HL,(_TABEND)
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	LD	HL,(_TABST)
	JP	EXECUT
I_E_3	CALL	MV_STK_L
	LD	HL,(_INSADDR)
	INC	HL
	INC	HL
	EX	DE,HL
	LD	HL,(_TABEND)
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	LD	HL,(_TABST)
	JP	EXECUT
;
CK_1_L	LD	A,(ALIEN)
	CP	(HL)
	RET	NZ
	INC	HL
	EX	DE,HL
	LD	HL,(_INSADDR)
	LD	A,(DE)
	CP	(HL)
	RET	NZ
	INC	DE
	INC	HL
	LD	A,(DE)
	CP	(HL)
	RET
;
ERROR	JP	DOS_NOERROR
;
CP_END_L
	EX	DE,HL
	LD	HL,(LOOP_PTR)
	EX	DE,HL
	LD	A,H
	CP	D
	RET	NZ
	LD	A,L
	CP	E
	RET
;
MV_STK_L
	INC	HL
	PUSH	HL
	LD	D,H
	LD	E,L
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	PUSH	HL
	LD	HL,(LOOP_PTR)
	OR	A
	SBC	HL,DE
	LD	A,H
	OR	L
	JR	NZ,MSL_1
	POP	AF
	POP	AF
	JR	MSL_2
MSL_1	PUSH	HL
	POP	BC
	POP	DE
	POP	HL
	LDIR
MSL_2	LD	HL,(LOOP_PTR)
	LD	DE,-4
	ADD	HL,DE
	LD	(LOOP_PTR),HL
	RET
;
I_CALLD	RET
I_RETND	RET
;
I_REPTA	INC	DE
	LD	A,(DE)
	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	LD	C,A
	LD	HL,LOOP_A
	LD	A,(ALIEN)
	LD	E,A
	LD	D,0
	ADD	HL,DE
	LD	(HL),C
	LD	HL,(_TABST)
	JP	EXECUT
;
I_ENDRA	PUSH	HL
	PUSH	DE
	LD	HL,LOOP_A
	LD	A,(ALIEN)
	LD	E,A
	LD	D,0
	ADD	HL,DE
	DEC	(HL)
	JR	Z,I_ENA
	POP	DE
	EX	DE,HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	DE
	INC	DE
	POP	HL
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	LD	HL,(_TABST)
	JP	EXECUT
I_ENA	POP	DE
	INC	DE
	INC	DE
	INC	DE
	POP	HL
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	LD	HL,(_TABST)
	JP	EXECUT
;
I_REPTB	INC	DE
	LD	A,(DE)
	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	LD	C,A
	LD	HL,LOOP_B
	LD	A,(ALIEN)
	LD	E,A
	LD	D,0
	ADD	HL,DE
	LD	(HL),C
	LD	HL,(_TABST)
	JP	EXECUT
;
I_ENDRB	PUSH	HL
	PUSH	DE
	LD	HL,LOOP_B
	LD	A,(ALIEN)
	LD	E,A
	LD	D,0
	ADD	HL,DE
	DEC	(HL)
	JR	Z,I_ENB
	POP	DE
	EX	DE,HL
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	DE
	INC	DE
	POP	HL
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	LD	HL,(_TABST)
	JP	EXECUT
I_ENB	POP	DE
	INC	DE
	INC	DE
	INC	DE
	POP	HL
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	LD	HL,(_TABST)
	JP	EXECUT
;
I_SYNC	INC	DE
	INC	DE
	INC	DE
	INC	DE
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	EX	DE,HL
	DEC	HL
	LD	D,(HL)
	DEC	HL
	LD	E,(HL)
	DEC	HL
	LD	A,(HL)
	CALL	SYNCHRON
	LD	HL,(_TABST)
	JP	EXECUT
;
