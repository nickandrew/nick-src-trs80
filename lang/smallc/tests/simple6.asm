;int x,y;
	COM	'<small c compiler output>'
*MOD
_X:
	DC	2,0
_Y:
	DC	2,0
;
;main() {
_MAIN:
	DEBUG	'main'
; x = ++y;
	LD	HL,(_Y)
	INC	HL
	LD	(_Y),HL
	LD	(_X),HL
;
; x = --y;
	LD	HL,(_Y)
	DEC	HL
	LD	(_Y),HL
	LD	(_X),HL
;
; x = y++;
	LD	HL,(_Y)
	INC	HL
	LD	(_Y),HL
	DEC	HL
	LD	(_X),HL
;
; x = y--;
	LD	HL,(_Y)
	DEC	HL
	LD	(_Y),HL
	INC	HL
	LD	(_X),HL
;
;}
	RET
;
	END
