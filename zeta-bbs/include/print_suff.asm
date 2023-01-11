;
;PRINT_SUFF. Print suffix related to TENS & ONES values.
;
PRINT_SUFF
	LD	A,(TENS)
	CP	'1'
	LD	A,0
	JR	Z,SUFF_1
	LD	A,(ONES)
	CP	'4'
	LD	A,0
	JR	NC,SUFF_1
	LD	A,(ONES)
	SUB	'0'
SUFF_1	ADD	A,A
	LD	E,A
	LD	D,0
	LD	HL,SUFF_TBL
	ADD	HL,DE
	LD	A,(HL)
	LD	DE,(_PRNU_DEV)
	CALL	$PUT
	INC	HL
	LD	A,(HL)
	CALL	$PUT
	RET
;
SUFF_TBL DEFM	'th','st','nd','rd'
;
