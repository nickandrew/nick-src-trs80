;real: get time off real time clock.
;
*GET	EXTERNAL
*GET	DOSCALLS
;
	COM	'<Real 2.1c 25-Jun-86>'
	ORG	BASE+100H
START
	LD	HL,(HIMEM)
	LD	A,H
	CP	0FFH
	JR	NZ,SET_HIMEM
	LD	HL,EXTERNALS-1
SET_HIMEM
	LD	DE,EN_CODE-ST_CODE
	OR	A
	SBC	HL,DE
	LD	(HIMEM),HL
	INC	HL
	EX	DE,HL
	PUSH	HL
	POP	BC
	PUSH	DE
;
	LD	HL,TO_BIN-ST_CODE
	ADD	HL,DE
	LD	(RC_1+1),HL
	LD	(RC_2+1),HL
	LD	(RC_3+1),HL
	LD	(RC_4+1),HL
	LD	(RC_5+1),HL
	LD	(RC_6+1),HL
	LD	HL,ST_CODE
	LDIR
	POP	HL
	DI
	LD	A,0C3H
	LD	(44DDH),A
	LD	(44DEH),HL
	LD	A,14H
	LD	(44CBH),A
	LD	(44A2H),A
	EI
	JP	DOS_NOERROR
;
ST_CODE
INTRPT
;
	IN	A,(0+64)
	LD	B,0
	DJNZ	$
	IN	A,(0+64)
	LD	B,A
	IN	A,(1+64)
RC_1	CALL	TO_BIN
	LD	(4041H),A
	IN	A,(2+64)
	LD	B,A
	IN	A,(3+64)
RC_2	CALL	TO_BIN
	LD	(4042H),A
	IN	A,(4+64)
	LD	B,A
	IN	A,(5+64)
	AND	7
RC_3	CALL	TO_BIN
	LD	(4043H),A
	IN	A,(7+64)
	LD	B,A
	IN	A,(8+64)
RC_4	CALL	TO_BIN
	LD	(4045H),A
	IN	A,(9+64)
	LD	B,A
	IN	A,(10+64)
RC_5	CALL	TO_BIN
	LD	(4046H),A
	IN	A,(11+64)
	LD	B,A
	IN	A,(12+64)
RC_6	CALL	TO_BIN
	LD	(4044H),A
	IN	A,(16+64)
	RET
;
TO_BIN	AND	0FH
	LD	C,A
	LD	A,B
	AND	0FH
	LD	B,A
	LD	A,C
	ADD	A,A
	ADD	A,A
	ADD	A,C
	ADD	A,A
	ADD	A,B
	RET
;
;
EN_CODE	NOP
;
	END	START
