;Filename: Filename manipulation routines.
;Last modified 03-May-86.
;
;Fn_Make: Make a valid filename out of almost anything.
	IFREF	FN_MAKE
FN_MAKE:
	CALL	_FN_BYP
	LD	IX,_FN_FLAGS
	LD	(IX),0
	LD	C,1
	LD	B,8
	JR	_FN_00
_FN_DOT
	LD	C,4
	LD	B,8
	RES	0,(IX)
	SET	6,(IX)
	LD	(DE),A
	INC	DE
	INC	HL
	JR	_FN_00
_FN_SL
	LD	C,2
	LD	B,3
	RES	0,(IX)
	SET	6,(IX)
	LD	(DE),A
	INC	HL
	INC	DE
;
_FN_00	LD	A,(HL)
	CP	'A'
	JR	C,_FN_00A
	AND	5FH
	CP	'Z'+1
	JR	C,_FN_01
_FN_00A
	DEC	HL
	LD	A,'A'		;Padder.
	JR	_FN_02
;
_FN_01	LD	A,(HL)
	CP	CR
	JR	Z,_FN_END
	OR	A
	JR	Z,_FN_END
	CP	' '
	JR	Z,_FN_END
	CP	':'
	JR	Z,_FN_COL
	BIT	2,C
	JR	NZ,_FN_01A
	CP	'.'
	JR	Z,_FN_DOT
	BIT	1,C
	JR	NZ,_FN_01A
	CP	'/'
	JR	Z,_FN_SL
_FN_01A
	BIT	0,(IX)
	JR	Z,_FN_02
	INC	HL
	JR	_FN_01
_FN_02
	INC	HL
	CALL	ADDVALID
	JR	NZ,_FN_01
	DJNZ	_FN_01
	SET	0,(IX)
	JR	_FN_01
;
ADDVALID:
	CP	'0'
	JR	C,ADDVAL_02
	CP	'9'+1
	JR	C,ADDVAL_01
	CP	'A'
	JR	C,ADDVAL_02
	AND	5FH
	CP	'Z'+1
	JR	NC,ADDVAL_02
ADDVAL_01
	LD	(DE),A
	INC	DE
	RES	6,(IX)
	CP	A
	RET
ADDVAL_02
	XOR	A
	CP	1
	RET
;
_FN_COL:
	SET	6,(IX)
	LD	(DE),A
	INC	DE
	INC	HL
	LD	A,(HL)
	CP	'0'
	JR	C,_FN_END
	CP	'3'+1
	JR	NC,_FN_END
	RES	6,(IX)
	LD	(DE),A
	INC	DE
	JR	_FN_END
;
_FN_END:
	BIT	6,(IX)
	JR	Z,_FN_04
	DEC	DE
_FN_04
	XOR	A
	LD	(DE),A
	RET
;
_FN_FLAGS
	DEFB	0
;
	ENDIF	;fn_make
;
;_fn_byp: Bypass any spaces.
	IFREF	_FN_BYP
_FN_BYP:
	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	_FN_BYP
	ENDIF
;
