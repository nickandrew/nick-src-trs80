;main() {
	COM	'<small c compiler output>'
*MOD
_MAIN:
	DEBUG	'main'
;	int	(*fp)(),func1(),func2();
;	int	func3();
;
;	fp = func1;
	PUSH	BC
	LD	HL,0
	ADD	HL,SP
	PUSH	HL
	LD	HL,_FUNC1
	POP	DE
	CALL	CCPINT
;
;	(*fp)(4);
	LD	HL,0
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,4
	EX	(SP),HL
	PUSH	HL
	LD	HL,$+5
	EX	(SP),HL
	JP	(HL)
	POP	BC
;	(fp)(4);
	LD	HL,0
	ADD	HL,SP
	CALL	CCGINT
	PUSH	HL
	LD	HL,4
	EX	(SP),HL
	PUSH	HL
	LD	HL,$+5
	EX	(SP),HL
	JP	(HL)
	POP	BC
;}
	POP	BC
	RET
;
;func1(arg)
;int	arg;
_FUNC1:
	DEBUG	'func1'
;{
;	return arg;
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	RET
;}
;
	END
