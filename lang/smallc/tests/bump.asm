;char *cptr;
	COM	'<small c compiler output>'
*MOD
_CPTR:
	DC	2,0
;int  *iptr;
_IPTR:
	DC	2,0
;main() {
_MAIN:
	DEBUG	'main'
;	char c;
;	int  i;
;	c=cptr;
	DEC	SP
	PUSH	BC
	LD	HL,2
	ADD	HL,SP
	PUSH	HL
	LD	HL,(_CPTR)
	POP	DE
	LD	A,L
	LD	(DE),A
;	c= *cptr;
	LD	HL,2
	ADD	HL,SP
	PUSH	HL
	LD	HL,(_CPTR)
	CALL	CCGCHAR
	POP	DE
	LD	A,L
	LD	(DE),A
;	c = *(cptr + 3);
	LD	HL,2
	ADD	HL,SP
	PUSH	HL
	LD	HL,(_CPTR)
	LD	DE,3
	ADD	HL,DE
	CALL	CCGCHAR
	POP	DE
	LD	A,L
	LD	(DE),A
;	i = *(iptr + 3);
	LD	HL,0
	ADD	HL,SP
	PUSH	HL
	LD	HL,(_IPTR)
	LD	DE,6
	ADD	HL,DE
	CALL	CCGINT
	POP	DE
	CALL	CCPINT
;}
	INC	SP
	POP	BC
	RET
;
	END
