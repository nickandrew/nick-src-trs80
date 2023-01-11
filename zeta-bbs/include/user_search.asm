;
;USER_SEARCH: Search the USERFILE for a particular name.
; On input: HL contains the username, terminated by CR, ETX or NUL
USER_SEARCH
	LD	A,0
	LD	(US_ZERO),A
	LD	(US_NSTR),HL
_US_01	LD	A,(HL)
	OR	A
	JR	Z,_US_02
	CP	CR
	JR	Z,_US_02
	CP	ETX
	JR	Z,_US_02
	INC	HL
	JR	_US_01
_US_02	LD	(HL),0
	LD	HL,(US_NSTR)
	CALL	CI_HASH
	LD	(US_HASH),A
	JP	COMMON_SEARCH
;
