;main(argc,argv) {
	COM	'<small c compiler output>'
*MOD
_MAIN:
	DEBUG	'main'
              /\
**** wrong number of arguments
;	puts("Start");
	LD	HL,$?1+0
	PUSH	HL
	CALL	_PUTS
	POP	BC
;	func1();
	CALL	_FUNC1
;	puts("End");
	LD	HL,$?1+6
	PUSH	HL
	CALL	_PUTS
	POP	BC
;}
	RET
$?1:	DEFB	83,116,97,114,116,0,69,110,100,0
;
;func1() {}
_FUNC1:
	DEBUG	'func1'
	RET
;
	END
