;Setreal: Set the Real-Time clock.
;V 1.0 on 17-May-85
;(C) Nick Andrew.
;** Read from ports 64 through 79 will set HOLD
;** Read from ports 80 through 95 will reset HOLD
;ports 64/80 to 79/95 are MSM5832rs registers.
;
;
	ORG	5300H
START	LD	SP,START
D_1	LD	HL,M_DATE
	CALL	MESSAGE
	LD	HL,IN_BUFF
	LD	B,8
	CALL	40H
	JR	C,D_1
	LD	A,(IN_BUFF+2)
	CP	'/'
	JR	NZ,D_1
	LD	A,(IN_BUFF+5)
	CP	'/'
	JR	NZ,D_2
;
	IN	A,(0+64)
	LD	B,0
	DJNZ	$
;
	LD	A,(IN_BUFF)
	LD	B,8
	CALL	SET
	LD	A,(IN_BUFF+1)
	LD	B,7
	CALL	SET
	LD	A,(IN_BUFF+3)
	LD	B,10
	CALL	SET
	LD	A,(IN_BUFF+4)
	LD	B,9
	CALL	SET
	LD	A,(IN_BUFF+6)
	LD	B,12
	CALL	SET
	LD	A,(IN_BUFF+7)
	LD	B,11
	CALL	SET
;
	IN	A,(16+64)
	LD	B,0
	DJNZ	$
;
D_2	LD	HL,M_TIME
	CALL	MESSAGE
	LD	HL,IN_BUFF
	LD	B,5
	CALL	40H
	JR	C,D_2
	LD	A,(IN_BUFF+2)
	CP	':'
	JR	NZ,D_2
;
	IN	A,(0+64)
	LD	B,0
	DJNZ	$
;
	LD	A,(IN_BUFF)
	OR	8
	LD	B,5
	CALL	SET
	LD	A,(IN_BUFF+1)
	LD	B,4
	CALL	SET
	LD	A,(IN_BUFF+3)
	LD	B,3
	CALL	SET
	LD	A,(IN_BUFF+4)
	LD	B,2
	CALL	SET
	LD	A,'0'
	LD	B,1
	CALL	SET
	LD	A,'0'
	LD	B,0
	CALL	SET
;
	DI
;
	LD	BC,0
	CALL	60H
	LD	HL,M_HITKEY
	CALL	MESSAGE
WAIT	LD	A,'0'
	LD	B,0
	CALL	SET
	LD	A,(38FFH)
	OR	A
	JR	Z,WAIT
;
	IN	A,(64+16)
	LD	B,0
	DJNZ	$
	EI
	JP	402DH
;
MESSAGE	LD	A,(HL)
	CP	03H
	RET	Z
	INC	HL
	CALL	33H
	JR	MESSAGE
;
M_DATE	DEFM	'Enter date in form DD/MM/YY: ',03H
M_TIME	DEFM	'Enter time in form HH:MM: ',03H
M_HITKEY
	DEFM	'Hit any key to restart clock',0DH,03H
;
IN_BUFF	DC	16,0
;
SET	CP	'0'
	RET	C
	CP	'9'+2	;YES! See H10 (24h).
	RET	NC
	PUSH	AF
	LD	A,B
	ADD	A,64
	LD	C,A
	POP	AF
	OUT	(C),A
	RET
;
	END	START
