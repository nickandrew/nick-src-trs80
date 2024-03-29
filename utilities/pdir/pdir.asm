;pdir/asm: do a printer oriented 'DIR I P'
; Ver 1.4 on 29-Dec-84
;

*GET	DOSCALLS

	ORG	5200H
START	LD	A,(HL)
	SUB	'0'
	CP	4
	LD	B,A
	LD	A,32	;Illegal/Missing drive #
	JP	NC,DOS_ERROR
	LD	A,B
	CALL	DOS_POWERUP
	JP	NZ,DOS_ERROR
	LD	HL,MESS
	CALL	MESS_DO
KEY	CALL	ROM@WAIT_KEY
	CP	5BH	;Escape
	JP	Z,DOS_NOERROR
	CP	0DH	;New Line
	JR	Z,PD_1
	CP	' '	;Spacebar
	JR	Z,PD_2
	SUB	'0'
	CP	4
	JR	NC,KEY
	PUSH	AF
	CALL	DOS_POWERUP
	JP	NZ,DOS_ERROR
	LD	HL,MESS_2
	CALL	MESS_DO
	POP	AF
	ADD	A,'0'
	CALL	ROM@PUT_VDU
	LD	A,0DH
	CALL	ROM@PUT_VDU
	JP	KEY
PD_1	CALL	PAGE_THROW
PD_2	XOR	A
	CALL	490AH		;read directory sector?
	JP	NZ,DOS_ERROR
	XOR	A
	LD	(NUM_X),A
	LD	A,0EH
	CALL	PRINT		;set EXPANDED mode
	LD	HL,42D0H
	LD	B,8
PD_3	LD	A,(HL)
	CALL	PRINT
	INC	HL
	DJNZ	PD_3
	LD	B,8
PD_4	LD	A,' '
	CALL	PRINT
	DJNZ	PD_4
	LD	B,8
PD_5	LD	A,(HL)
	CALL	PRINT
	INC	HL
	DJNZ	PD_5
	LD	A,0DH
	CALL	PRINT
	LD	A,1
	CALL	490AH		;read directory sector?
	LD	A,(421FH)
	ADD	A,8
	LD	(SECS),A
	LD	A,2
	LD	(SECTOR),A
LOOP	LD	A,(SECTOR)
	CALL	490AH		;read directory sector?
	CALL	PRINT_8
	LD	A,(SECTOR)
	INC	A
	LD	(SECTOR),A
	LD	A,(SECS)
	DEC	A
	LD	(SECS),A
	JR	NZ,LOOP
	LD	A,(NUM_X)
	OR	A
	LD	A,0DH
	CALL	NZ,PRINT
	LD	A,0DH
	CALL	PRINT
	JP	KEY
;
PRINT	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	ROM@PUT_PRT
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
PRINT_8	LD	B,8
	LD	HL,4200H
P8_1	LD	A,(HL)
	PUSH	BC
	AND	0D0H
	CP	10H
	PUSH	HL
	CALL	Z,PRINT_1
	POP	HL
	LD	DE,32
	ADD	HL,DE
	POP	BC
	DJNZ	P8_1
	RET
;
PRINT_1	LD	DE,5
	ADD	HL,DE
	PUSH	HL
	XOR	A
	LD	(CHARS),A
	LD	B,8
P1_1	LD	A,(HL)
	CP	' '
	JR	Z,P11_1
	CALL	PRINT
	INC	HL
	DJNZ	P1_1
P11_1	LD	A,8
	SUB	B
	LD	(CHARS),A
	POP	HL
	LD	DE,8
	ADD	HL,DE
	LD	A,(HL)
	CP	' '
	JR	Z,P11_3
	LD	A,'/'
	CALL	PRINT
	LD	A,(CHARS)
	ADD	A,4
	LD	(CHARS),A
	LD	B,3
P11_2	LD	A,(HL)
	CALL	PRINT
	INC	HL
	DJNZ	P11_2
P11_3	LD	A,(CHARS)
	NEG
	ADD	A,16
	LD	B,A
	JR	Z,P11_5
P11_4	LD	A,' '
	CALL	PRINT
	DJNZ	P11_4
P11_5	LD	A,(NUM_X)
	INC	A
	LD	(NUM_X),A
	CP	5
	RET	NZ
	XOR	A
	LD	(NUM_X),A
	LD	A,0DH
	CALL	PRINT
	RET
;
PAGE_THROW
	LD	A,0CH
	CALL	PRINT
	RET
;
NUM_X	DEFB	0
SECS	DEFB	0
SECTOR	DEFB	0
CHARS	DEFB	0
;
MESS	DEFM	'Super Directory 1.4 by Nick Andrew',0DH
MESS_2	DEFM	'Now using drive ',03H
;
;
	END	START
