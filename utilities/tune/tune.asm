;MUSIC ROUTINE (C) NICK
; tune: play a tune.
; Assembled OK 30-Mar-85.
	ORG	7FF6H
START	LD	HL,SHEET
	DI
	PUSH	HL
PLAY	POP	HL
	LD	A,(3840H)
	CP	4
	JP	Z,402DH
	LD	BC,0010H
	CALL	60H
	LD	A,(HL)
	CP	255
	JR	Z,COMAND
	CP	58
	JP	NC,402DH
	LD	C,A
	LD	B,0
	INC	HL
	LD	E,(HL)
	INC	HL
	PUSH	HL
	LD	HL,FTABLE
	ADD	HL,BC
	LD	D,(HL)
	OR	A
	RL	C
	LD	HL,DTABLE
	ADD	HL,BC
	LD	C,D
	LD	B,E
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	POP	HL
	DEC	B
	JR	Z,BYPASS
	PUSH	HL
	POP	DE
LOOP2	ADD	HL,DE
	DJNZ	LOOP2
BYPASS	PUSH	HL
	POP	DE
	CALL	LOOP
	JR	PLAY
;	FILE	1 BEEP SOUND ROUTINE
;	PARAMETERS:	C=FREQ. DE=DURATION OF SOUND
LOOP	LD	A,1
	OUT	(255),A
	LD	B,C
	DJNZ	$
	LD	A,0
	OUT	(255),A
	LD	B,C
	DJNZ	$
	LD	A,2
	OUT	(255),A
	LD	B,C
	DJNZ	$
	LD	A,0
	OUT	(255),A
	LD	B,C
	DJNZ	$
	DEC	DE
	LD	A,D
	OR	E
	RET	Z
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,LOOP
	RET
;	END	OF BEEP ROUTINE
COMAND	INC	HL
	LD	A,(HL)
	OR	A
	JP	Z,402DH
	INC	HL
	LD	A,(HL)
	INC	HL
	PUSH	HL
	LD	D,A
	CALL	WAITD
	JR	PLAY
;NOW	FTABLE;	TABLE OF FREQUENCIES
FTABLE	DEFW	61951
	DEFW	55011
	DEFW	49098
	DEFW	43700
	DEFW	39073
	DEFW	34703
	DEFW	30848
	DEFW	27506
	DEFW	24677
	DEFW	21850
	DEFW	19536
	DEFW	17480
	DEFW	15424
	DEFW	13881
	DEFW	12339
	DEFW	11053
	DEFW	9768
	DEFW	8740
	DEFW	7712
	DEFW	6940
	DEFW	6169
	DEFW	5399
	DEFW	4884
	DEFW	4370
	DEFW	3856
	DEFW	3342
	DEFW	3085
	DEFW	2827
	DEFW	2314
;	END	OF FREQUENCY TABLE F, START OF DTABLE DURATION.
DTABLE	DEFW	20
	DEFW	21
	DEFW	22
	DEFW	23
	DEFW	25
	DEFW	26
	DEFW	28
	DEFW	29
	DEFW	31
	DEFW	33
	DEFW	35
	DEFW	37
	DEFW	39
	DEFW	42
	DEFW	44
	DEFW	47
	DEFW	49
	DEFW	52
	DEFW	55
	DEFW	59
	DEFW	62
	DEFW	66
	DEFW	70
	DEFW	74
	DEFW	78
	DEFW	83
	DEFW	88
	DEFW	93
	DEFW	99
	DEFW	105
	DEFW	111
	DEFW	118
	DEFW	125
	DEFW	132
	DEFW	140
	DEFW	148
	DEFW	157
	DEFW	166
	DEFW	176
	DEFW	187
	DEFW	198
	DEFW	209
	DEFW	222
	DEFW	235
	DEFW	249
	DEFW	264
	DEFW	279
	DEFW	296
	DEFW	314
	DEFW	332
	DEFW	352
	DEFW	373
	DEFW	395
	DEFW	419
	DEFW	444
	DEFW	470
	DEFW	498
	DEFW	528
	DEFB	0
;	FILE	1 BEEP SOUND ROUTINE
;	PARAMETERS:	C=FREQ. DE=DURATION OF SOUND
WAITD	PUSH	DE
	LD	DE,20
WAIT1	LD	C,0
	OUT	(155),A
	LD	B,C
	DJNZ	$
	LD	A,0
	OUT	(155),A
	LD	B,C
	DJNZ	$
	LD	A,2
	OUT	(155),A
	LD	B,C
	DJNZ	$
	LD	A,0
	OUT	(155),A
	LD	B,C
	DJNZ	$
	DEC	DE
	LD	A,D
	OR	E
	JR	NZ,WAIT1
	POP	DE
	DEC	D
	JR	NZ,WAITD
	RET
SHEET	EQU	$
	END	START
