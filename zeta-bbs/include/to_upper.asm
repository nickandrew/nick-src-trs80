;
;TO_UPPER: String to upper case conversion
TO_UPPER:
	LD	A,(HL)
	OR	A
	RET	Z
	CP	CR
	RET	Z
	CP	ETX
	RET	Z
	INC	HL
	CP	'a'
	JR	C,TO_UPPER
	CP	'z'+1
	JR	NC,TO_UPPER
	DEC	HL
	AND	5FH
	LD	(HL),A
	INC	HL
	JR	TO_UPPER
;
