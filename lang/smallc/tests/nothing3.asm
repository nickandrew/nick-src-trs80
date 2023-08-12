;main() {
	COM	'<small c compiler output>'
*MOD
_MAIN:
	DEBUG	'main'
;    char a;
;    a = 1;
	DEC	SP
	LD	HL,0
	ADD	HL,SP
	PUSH	HL
	LD	HL,1
	POP	DE
	LD	A,L
	LD	(DE),A
;}
	INC	SP
	RET
;
	END
