;
;_fn_byp: Bypass any spaces.
_FN_BYP:
	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	_FN_BYP
