;rtclock: implement realtime clock feature.
; only for hardware-modified machines.
	COM	'<HW RealTime Clock driver V1 30-Jan-85>'
	ORG	5200H
START
;move clock routine into high memory
	DI
	CALL	MOVE_UP
;get time & date as a string
	CALL	GET_TIMDAT
;set time & date.
	CALL	PUT_TIMDAT
;finished!
	JP	402DH
;
MOVE_UP	LD	HL,(4049H)
	LD	DE,EN_CODE-ST_CODE
	OR	A
	SBC	HL,DE
	LD	(4049H),HL
	INC	HL
	EX	DE,HL
	LD	HL,ST_CODE
	LD	BC,EN_CODE-ST_CODE
	LDIR
;chance to relocate anything
	LD	HL,(4049H)
	INC	HL
	LD	(44CEH),HL	;save jp addr.
	LD	A,0C3H	;jp
	LD	(44CDH),A
	LD	A,1		;each interrupt
	LD	(44CBH),A
	XOR	A
	LD	(4613H),A	;stop use of 4040h
	RET
;
SEC40	EQU	4040H
SEC	EQU	4041H
MIN	EQU	4042H
HRS	EQU	4043H
DAY	EQU	4045H
MON	EQU	4046H
YEAR	EQU	4044H
;
REAL	EQU	37E4H
;
;
ST_CODE
	LD	HL,4041H
	LD	DE,43ACH
	LD	BC,6
	LDIR
	LD	DE,SEC40
	LD	A,(DE)
	LD	B,A
	LD	A,(REAL)
	AND	3FH	;take only lower 6 bits
	LD	(REAL),A
	ADD	A,B
SEC_OV	LD	HL,SEC
LOOP1	SUB	40
	JR	C,LT_40
	INC	(HL)
	ADD	A,0	;pushforward per second
;synchronise clock display
	LD	B,A
	LD	A,1
	LD	(44A3H),A
	LD	A,B
	JR	LOOP1
;
LT_40	ADD	A,40
	LD	(DE),A
;now check sec -> min
	LD	A,(HL)
	LD	HL,MIN
LOOP2	CP	60
	RET	C
	SUB	60
	LD	(SEC),A
	INC	(HL)
	LD	A,(DE)
	ADD	A,0	;pushforward per min
	LD	(DE),A
	LD	A,(HL)	;=min
	LD	HL,HRS
	CP	60
	RET	C
	XOR	A
	LD	(MIN),A
	INC	(HL)
	LD	A,(DE)
	ADD	A,0	;plus per hour
	LD	(DE),A
	LD	A,(HL)
	CP	24
	RET	C
	LD	(HL),0
	LD	HL,DAY
	LD	A,(HL)
	INC	A
	LD	(HL),A
	CP	32
	JR	Z,INC_MON
	CP	31
	JR	Z,IF_30
	CP	30
	JR	Z,IF_LEAP
	CP	29
	RET	NZ
;must be FEB and year/4 <>0
	LD	A,(MON)
	CP	2
	RET	NZ
	LD	A,(YEAR)
	AND	3
	RET	Z
	JR	INC_MON
;
IF_30	LD	A,(MON)
	AND	1
	LD	B,A
	LD	A,(MON)
	AND	8
	SRL	A
	SRL	A
	SRL	A
	XOR	B
	RET	NZ
INC_MON	LD	(HL),1
	LD	A,(MON)
	INC	A
	LD	(MON),A
	CP	13
	RET	C
	LD	A,1
	LD	(MON),A
	LD	A,(YEAR)
	INC	A
	LD	(YEAR),A
;happy new year
	RET	;finally!
;
IF_LEAP	LD	A,(MON)
	CP	2
	RET	NZ
	LD	A,(YEAR)
	AND	3
	RET	NZ
	JR	INC_MON
;
EN_CODE	NOP
;
GET_TIMDAT
	RET
;
PUT_TIMDAT
	EI
	RET
;
	END	START
