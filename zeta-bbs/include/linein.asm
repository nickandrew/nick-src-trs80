;linein: A sophisticated line input routine.
;Last modified: 28-Dec-86.
;
;Usage is: CALL LINEIN
;Output  : in buffer LI_BUF, null terminated.
;Other   : LI_PRE	1=pre-input in buffer.
;
	IFREF	LINEIN
LINEIN	LD	A,(LI_PRE)
	OR	A
	JR	Z,_LI_01
	XOR	A
	LD	(LI_PRE),A
	LD	HL,LI_INBUFF
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0		;until null.
	LD	(LI_POS),HL
	JR	_LI_01A
;
_LI_01	;(other setup)
	LD	HL,LI_INBUFF
	LD	(LI_POS),HL
_LI_01A
	LD	HL,(LI_POS)
	LD	(HL),0
	LD	A,(TFLAG2)
	AND	TF_WIDTH	;bits 0 & 1.
	LD	HL,LI_INBUFF+29
;Assume 2 char prompt ": " at start & 1 char no-scroll.
	JR	Z,_LI_SETW
	LD	HL,LI_INBUFF+37
	CP	1
	JR	Z,_LI_SETW
	LD	HL,LI_INBUFF+61
	CP	2
	JR	Z,_LI_SETW
	LD	HL,LI_INBUFF+77
_LI_SETW
	LD	(LI_ENBUFF),HL
;
_LI_LOOP
	LD	DE,($STDIN_DEF)
	CALL	$GET
	OR	A
	JR	Z,_LI_LOOP
;
	CP	1
	JR	NZ,_LI_03
;Break handling
	LD	A,CR
	LD	DE,($STDOUT_DEF)
	CALL	$PUT
	SCF
	RET
;
_LI_03	CP	CR
	JR	NZ,_LI_04
;CR handling
	LD	HL,LI_INBUFF
	LD	DE,LI_BUF
	CALL	STRCPY
	LD	A,CR
	LD	DE,($STDOUT_DEF)
	CALL	$PUT
	XOR	A		;clear carry flag
	RET
;
_LI_04	CP	BS
	JR	NZ,_LI_05
;Backspace handling
	LD	DE,(LI_POS)
	LD	HL,LI_INBUFF	;start
	OR	A
	SBC	HL,DE
	JP	Z,_LI_LOOP	;if at start
	DEC	DE
	XOR	A
	LD	(DE),A		;fill with null
	LD	(LI_POS),DE
	LD	A,8
	LD	DE,($STDOUT_DEF)
	CALL	$PUT		;backspace
	JP	_LI_LOOP
;
_LI_05	CP	18H
	JR	NZ,_LI_07
_LI_06	LD	DE,(LI_POS)
	LD	HL,LI_INBUFF
	OR	A
	SBC	HL,DE
	JP	Z,_LI_LOOP
	DEC	DE
	XOR	A
	LD	(DE),A
	LD	(LI_POS),DE
	LD	A,8
	LD	DE,($STDOUT_DEF)
	CALL	$PUT
	JR	_LI_06		;repeat it.
;
_LI_07	CP	20H
	JR	NC,_LI_07Z	;not control char.
;
_LI_07A	CP	9		;tab
	JP	NZ,_LI_LOOP
;
;What do we do with a tab??
;Find position after tab.
	LD	HL,(LI_POS)
	LD	DE,LI_INBUFF
	OR	A
	SBC	HL,DE		;zero offset.
	LD	A,L
	LD	B,L
	ADD	A,8
	AND	0F8H
	LD	L,A		;new position offset.
	SUB	B
	LD	B,A
;ensure it will not overflow the end of the buffer.
	ADD	HL,DE		;would be next LI_POS
	LD	DE,(LI_ENBUFF)
	OR	A
	SBC	HL,DE
	JP	NC,_LI_LOOP	;too long!
	LD	HL,(LI_POS)
	LD	DE,($STDOUT_DEF)
_LI_07B
	LD	A,' '
	LD	(HL),A
	INC	HL
	LD	(HL),0
	CALL	$PUT
	DJNZ	_LI_07B
	LD	(LI_POS),HL
	JP	_LI_LOOP
;
;Add this to buffer.
;
_LI_07Z
	PUSH	AF
	LD	DE,($STDOUT_DEF)
	CALL	$PUT
	POP	AF
	LD	HL,(LI_POS)
	LD	(HL),A
	INC	HL
	LD	(HL),0
	LD	(LI_POS),HL
	LD	DE,(LI_ENBUFF)
	OR	A
	SBC	HL,DE
	JP	NZ,_LI_LOOP
;
;Hit end. have to remove the last word.
	LD	HL,(LI_POS)
_LI_08	DEC	HL
	PUSH	HL
	LD	DE,LI_INBUFF
	OR	A
	SBC	HL,DE
	POP	HL
	JR	Z,_LI_LONG	;a word width wide!
	LD	A,(HL)
	CP	' '
	JR	NZ,_LI_08
;
	PUSH	HL		;1st space before last word.
	LD	(HL),0		;set null.
	LD	HL,LI_INBUFF
	LD	DE,LI_BUF
	CALL	STRCPY		;copy first part.
;
	POP	HL
	INC	HL
	LD	DE,LI_INBUFF
	CALL	STRCPY		;next line start.
;
	LD	A,1
	LD	(LI_PRE),A
;
;Backspace over bad word
	LD	HL,LI_INBUFF
	LD	DE,($STDOUT_DEF)
_LI_10	LD	A,(HL)		;fwd & bkwd
	OR	A
	JR	Z,_LI_11	;if end of string
	LD	A,8
	CALL	$PUT
	INC	HL
	JR	_LI_10
_LI_11	LD	(LI_POS),HL
	LD	A,CR
	CALL	$PUT
	XOR	A		;clear carry
	RET
;
_LI_LONG			;word too long.
	LD	HL,LI_INBUFF
	LD	DE,LI_BUF
	CALL	STRCPY
	LD	A,CR
	LD	DE,($STDOUT_DEF)
	CALL	$PUT
	OR	A		;clear carry
	RET
;
LI_PRE	DEFB	0		;preinput flag
LI_BUF	DEFS	80
LI_INBUFF
	DEFS	80
LI_POS	DEFW	LI_INBUFF
LI_ENBUFF
	DEFW	0
;
	IFREF	STRCPY
STRCPY	LD	A,(HL)
	LD	(DE),A
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	STRCPY
	ENDIF			;str_cpy
	ENDIF			;linein
;
