;cron2: Other routines for cron
;Last updated: 13 May 90
;
_TOUPPER
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,E
	EX	DE,HL
	LD	H,0
	CP	'a'
	RET	C
	CP	'z'+1
	RET	NC
	AND	05FH
	LD	L,A
	RET
;
;End of cron2.asm
