;main() {
	COM	'<small c compiler output>'
*MOD
_MAIN:
	DEBUG	'main'
;    int a;
;    a = 1;
	PUSH	BC
	LD	HL,0
	ADD	HL,SP
	PUSH	HL
	LD	HL,1
	POP	DE
	CALL	CCPINT
;}
	POP	BC
	RET
;
	END
