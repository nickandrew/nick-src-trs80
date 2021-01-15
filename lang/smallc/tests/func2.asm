;main() {
	COM	'<small c compiler output>'
*MOD
_MAIN:
	DEBUG	'main'
;   func();
	CALL	_FUNC
;}
	RET
;
;int  *x[5],func() {
_X:
	DC	10,0
_FUNC:
	DEBUG	'func'
;   puts("A function");
	LD	HL,$?2+0
	PUSH	HL
	CALL	_PUTS
	POP	BC
;}
	RET
$?2:	DEFB	65,32,102,117,110,99,116,105,111,110
	DEFB	0
;
	END
