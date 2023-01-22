;setclock: set the real time clock.

*GET	DOSCALLS

	COM	'<HW RealTime Clock setter V1 30-Jan-85>'
	ORG	5200H
START	LD	HL,M_TIME
	CALL	MESS_DO
	LD	HL,IN_BUFF
	LD	B,10
	CALL	ROM@WAIT_LINE
	JR	C,START
	LD	A,(IN_BUFF+2)
	CP	':'
	JR	NZ,START
	LD	A,(IN_BUFF+5)
	CP	':'
	JR	NZ,START
	LD	HL,IN_BUFF
	CALL	CHK_NUM
	JR	NZ,START
	CALL	CHK_NUM
	JR	NZ,START
	INC	HL
	CALL	CHK_NUM
	JR	NZ,START
	CALL	CHK_NUM
	JR	NZ,START
	INC	HL
	CALL	CHK_NUM
	JR	NZ,START
	CALL	CHK_NUM
	JR	NZ,START
;
;number is ok.
	DI
	LD	HL,IN_BUFF
	CALL	GET_NUM
	LD	(HRS),A
	INC	HL
	CALL	GET_NUM
	LD	(MIN),A
	INC	HL
	CALL	GET_NUM
	LD	(SEC),A
	XOR	A
	LD	(4040H),A
	LD	A,1
	LD	(44A3H),A	;to sync.
	LD	HL,M_ENTER
	CALL	MESS_DO
LOOP	LD	A,(38FFH)
	OR	A
	JR	Z,LOOP
	LD	A,(37E0H)
LOOP2	LD	A,(37E0H)
	BIT	7,A
	JR	Z,LOOP2
	LD	A,(37E0H)
	LD	(37E4H),A
	EI
	JP	402DH
;
M_ENTER	DEFM	'Hit any key when seconds are exact',0DH
M_TIME	DEFM	'Enter time HH:MM:SS : ',03H
;
CHK_NUM	LD	A,(HL)
	INC	HL
	CP	'0'
	RET	C
	CP	'9'+1
	JR	NC,BAD
	CP	A
	RET
BAD	XOR	A
	CP	1
	RET
;
GET_NUM	LD	A,(HL)
	INC	HL
	SUB	30H
	LD	B,A
	ADD	A,A
	ADD	A,A
	ADD	A,B
	ADD	A,A
	LD	B,A
	LD	A,(HL)
	INC	HL
	SUB	30H
	ADD	A,B
	RET
;
IN_BUFF	DC	10,0
SEC	EQU	4041H
MIN	EQU	4042H
HRS	EQU	4043H
	END	START
