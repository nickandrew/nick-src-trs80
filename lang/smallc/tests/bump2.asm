;int  *iptr;
	COM	'<small c compiler output>'
*MOD
_IPTR:
	DC	2,0
;main() {
_MAIN:
	DEBUG	'main'
;	char c,*cptr;
;	int  i;
;	c=cptr;
	DEC	SP
	PUSH	BC
	PUSH	BC
	LD	HL,4
	ADD	HL,SP
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	POP	DE
	LD	A,L
	LD	(DE),A
;	c= *cptr;
	LD	HL,4
	ADD	HL,SP
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGCHAR
	POP	DE
	LD	A,L
	LD	(DE),A
;	c = *(cptr + 3);
	LD	HL,4
	ADD	HL,SP
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
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
	POP	BC
	RET
;
	END
