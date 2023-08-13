;
;Extract: Extract a filespec... Doesn't use SYS1.
EXTRACT:
	PUSH	DE
	LD	B,24
_EXT_01	LD	A,(HL)
	CP	CR
	JR	Z,_EXT_02
	CP	' '
	JR	Z,_EXT_02
	CP	ETX
	JR	Z,_EXT_02
	OR	A
	JR	Z,_EXT_02
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	_EXT_01
;Filename too long.
	LD	A,30H	;bad filespec
	POP	DE
	OR	A
	RET
;
_EXT_02	LD	A,ETX		;For the dos.
	LD	(DE),A
_EXT_03	LD	A,(HL)		;bypass extra spaces
	CP	' '
	JR	NZ,_EXT_04
	INC	HL
	JR	_EXT_03
_EXT_04	POP	DE
	CP	A
	RET
