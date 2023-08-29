;Microsoft Adventure original Boot Sector source
;code - using encoded track & sector numbers.
;
;

*GET	DOSCALLS

NULL	EQU	00H
CR	EQU	0DH
;
S_SECT	EQU	1
S_TRK	EQU	0
DRIVE0	EQU	1
DRIVE1	EQU	2
DRIVE2	EQU	4
DRIVE3	EQU	8
DRIVE	EQU	DRIVE0
RD_SECT	EQU	88H
STEPIN	EQU	5BH
SK_TK0	EQU	0BH
;
OFFSET	EQU	82H
LOADADD	EQU	4300H
END_PR	EQU	82H
PROGRAM	EQU	5A00H
;
REBOOT	EQU	0000H
DISK	EQU	37E1H
DSK_CR	EQU	37ECH
DSK_TR	EQU	37EDH
DSK_SR	EQU	37EEH
DSK_DR	EQU	37EFH
;
	ORG	4200H
START:
CUR_SEC	EQU	$
CUR_TRK	EQU	$+1
	JR	EXEC
MESS_1	DEFB	1CH,1FH,CR
	DEFM	"* *  MICROSOFT'S TRS-80 ADVENTURE  V1.1  * *",CR
	DEFM	"* *           BY  * SOFTWIN *            * *",CR
	DEFM	CR,NULL
EXEC	LD	A,S_SECT
	LD	(CUR_SEC),A
	XOR	A
	LD	(CUR_TRK),A
	LD	HL,MESS_1
M_LOOP	LD	A,(HL)
	CALL	ROM@PUT_VDU
	INC	HL
	LD	A,(HL)
	AND	A
	JR	NZ,M_LOOP
	LD	BC,DSK_CR
	LD	DE,DSK_DR
	LD	HL,LOADADD
	LD	SP,HL
LOOP	LD	A,DRIVE
	LD	(DISK),A
	LD	A,(CUR_SEC)
	ADD	A,A
	JR	Z,ZERO_1
	CPL	
	ADD	A,OFFSET
ZERO_1	LD	(DSK_SR),A
	LD	A,(CUR_TRK)
	ADD	A,A
	JR	Z,ZERO_2
	CPL	
	ADD	A,OFFSET
ZERO_2	LD	(DSK_TR),A
	LD	A,RD_SECT
	LD	(BC),A
	EX	(SP),HL
	EX	(SP),HL
	EX	(SP),HL
	EX	(SP),HL
R_LOOP	LD	A,(BC)
	RRCA	
	JR	NC,NOT_BSY
	RRCA	
	JR	NC,R_LOOP
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	JR	R_LOOP
NOT_BSY	LD	A,(BC)
	AND	1CH
	JP	NZ,REBOOT
	LD	A,(CUR_SEC)
	INC	A
	CP	10
	JR	NZ,NXT_SEC
	LD	A,STEPIN
	LD	(BC),A
	EX	(SP),HL
	EX	(SP),HL
	EX	(SP),HL
	EX	(SP),HL
NOT_RDY	LD	A,(BC)
	RRA	
	JR	C,NOT_RDY
	LD	A,(CUR_TRK)
	INC	A
	LD	(CUR_TRK),A
	XOR	A
NXT_SEC	LD	(CUR_SEC),A
	LD	A,END_PR
	CP	H
	JP	Z,PROGRAM
	JR	LOOP
	PUSH	BC
	POP	BC
	PUSH	BC
	POP	BC
	RET	
	LD	A,(64ADH)
	LD	(DISK),A
	LD	A,04H
	CALL	63E9H
	LD	A,SK_TK0
	LD	(DSK_CR),A
	CALL	63C5H
	LD	A,(DSK_CR)
	RRA	
	JP	C,63DDH
	XOR	A
	LD	(64ABH),A
	RET	
	END	START
