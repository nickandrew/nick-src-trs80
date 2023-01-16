;Newc/Edt: Get rid of undesirable
;      Shift/Down Arrow effects...
; Nick Andrew, 07/03/84.
; Assembled OK 30-Mar-85.
ORIGIN	EQU	5200H	;Origin of code
CODORG	EQU	4054H	;8 Free bytes in dos for filter.
KBDVR	EQU	4016H	;Addr of Kbd Drvr address.
	ORG	ORIGIN
	LD	HL,(KBDVR)	;Modify filter to call Kbd.
	LD	(GETKBD),HL
	LD	HL,CODORG	;Modify Dos to call filter.
	LD	(KBDVR),HL
	LD	DE,CODE
	EX	DE,HL
	LD	BC,0008H
	LDIR			;Block move filter.
	JP	402DH
CODE	DEFB	0CDH	;Call opcode
GETKBD	DEFW	0	;Call Dos keyboard routine.
	CP	26	;Throw out Shft/Ctrl alone.
	RET	NZ
	JR	CODE
	END	ORIGIN
