;
;str_len: Find the 0-255 length of a string.
	ERR	'Should use STRLEN instead of STR_LEN'
STR_LEN
	LD	C,0
_STR_01	LD	A,(HL)
	OR	A
	JR	Z,_STR_02
	INC	C
	INC	HL
	JR	_STR_01
_STR_02	LD	A,C
	RET
;
