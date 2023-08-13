; @(#) morepipe.lib - Pagination and word wrap for general use - 14 May 89
;
	COM	'<Morepipe, 14 May 89>'
;
WIDTH		DEFB	80		;Screen width
HEIGHT		DEFB	24		;Screen height
INFUNC		DEFW	NULLFUNC	;Character input routine
KEYFUNC		DEFW	NULLFUNC	;Keypress handling function
OLDSTACK	DEFW	0		;Stack pointer before 'morepipe'
SCRPRINT	DEFB	0		;Screen lines to print
SCRDONE		DEFB	0		;Screen lines printed before more
MOREMSG		DEFW	M_MORE1		;Message to display
MORECLEAR	DEFW	M_MORE2		;Clears the more message
MO_PTR		DEFW	0		;Pointer into MOREBUFF
MO_EOF		DEFB	0		;EOF seen
MO_LEN		DEFW	0
MO_I		DEFB	0
MO_SAVED	DEFW	0		;Nr of saved characters from line
MO_STRING	DEFS	82		;82 For safety
MO_ENDSTR	DEFW	0		;Last char of string
;
M_MORE1		DEFM	'- More -',0
M_MORE2		DEFM	CR,'        ',CR,0
;
MOREPIPE
	LD	HL,0
	ADD	HL,SP
	LD	(OLDSTACK),HL
	XOR	A
	LD	(MO_EOF),A
	LD	HL,0
	LD	(MO_SAVED),HL
;
	CALL	FIX_STTY		;Get width and length from memory
;
	LD	A,(SCRDONE)
	LD	B,A
	LD	A,(HEIGHT)
	SUB	B
	JR	NC,MORE_01
;More lines were printed before calling morepipe than on screen!
	LD	A,(HEIGHT)
MORE_01
	DEC	A			;Less one for -more- line
	LD	(SCRPRINT),A
;
MORE_02
	CALL	MORELINE		;Read one line from the file
	LD	A,(MO_EOF)
	OR	A
	JR	NZ,MORE_02A		;If end of file, return
	CALL	MOREPRINT
	CALL	MOREPAUSE
	JR	MORE_02
;
MORE_02A
	XOR	A			;Return code of zero
	RET
;
;moreline - read one line (at most) from the input
;set MO_EOF if end-of-file
MORELINE
	LD	A,(WIDTH)
	LD	L,A
	LD	H,0
	LD	DE,(MO_SAVED)
	OR	A
	SBC	HL,DE
	PUSH	HL		;width-saved in hl
	POP	BC		;width-saved in bc
;
	LD	HL,MO_STRING
	LD	DE,(MO_SAVED)
	ADD	HL,DE		;string+saved
;
MORE_03
	PUSH	BC
	PUSH	HL
MORE_04
	LD	HL,MORE_05
	PUSH	HL		;make jp like call
	LD	HL,(INFUNC)
	JP	(HL)		;return to more_05
MORE_05
	JR	NZ,MORE_07	;eof if error
	AND	7FH
	JR	Z,MORE_07	;eof if null
	CP	LF
	JR	Z,MORE_04	;ignore lf
	POP	HL		;end of string address
	POP	BC		;length allowed
	LD	(HL),A
	INC	HL
	CP	CR
	JR	Z,MORE_06	;Finished if CR
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,MORE_03	;loop for more
;CR read in, or string full.
MORE_06
	LD	(HL),0
	DEC	HL
	LD	(MO_ENDSTR),HL
	RET
;
MORE_07
	POP	HL		;end of string address
	POP	BC		;length allowed
	LD	(HL),0
	DEC	HL
	LD	(MO_ENDSTR),HL	;Should be ineffectual
	LD	A,1
	LD	(MO_EOF),A
	RET
;
;Print one screen line of text and adjust the contents of string
MOREPRINT
	LD	DE,MO_STRING
	CALL	STRLEN
	LD	(MO_LEN),HL
;
	LD	HL,(MO_ENDSTR)
	LD	A,(HL)
	CP	CR
	JR	NZ,MORE_08
;
;entire line fits in 'width' chars. Print the whole thing.
	LD	DE,DCB_2O
	LD	HL,MO_STRING
	CALL	MESS_0
	LD	HL,0
	LD	(MO_SAVED),HL
	RET
;
MORE_08
	LD	B,20		;look back 20 chars
MORE_09
	LD	A,(HL)		;Look for last space in 20 chars
	CP	' '
	JR	Z,MORE_10
	DEC	HL
	DJNZ	MORE_09
;No space found - print the whole lot anyway, followed by CR
	LD	DE,DCB_2O
	LD	HL,MO_STRING
	CALL	MESS_0
	LD	A,CR
	CALL	ROM@PUT
	LD	HL,0
	LD	(MO_SAVED),HL
	RET
;
;We found a convenient place to wrap the line around.
MORE_10
;Terminate the string early.
	LD	(MO_ENDSTR),HL
	LD	(HL),0
; Print the left string
	LD	HL,MO_STRING
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,CR
	CALL	ROM@PUT
;
; Copy the right half back to the start of the string
	LD	HL,(MO_ENDSTR)
	INC	HL
	LD	DE,MO_STRING
	CALL	STRCPY
;
;Set mo_saved to the length of the new string.
	LD	DE,MO_STRING
	CALL	STRLEN
	LD	(MO_SAVED),HL
	RET
;
;Ok, a line has just been printed. If necessary, pause and accept
;user input.
; if ' ', set lines to print to screen height - 1
; if CR, set lines to print to 1
; if 'Q', set stack again and return to morepipe's caller
MOREPAUSE
	LD	A,(SCRPRINT)		;Dec # lines to print
	DEC	A
	LD	(SCRPRINT),A
	RET	NZ			;If more to go, return
;
MORE_10A
	LD	A,OM_DISPLAY		;Set display simulate mode
	LD	(OUTPUT_MODE),A
;
	LD	HL,(MOREMSG)		;Print - more -
	LD	DE,DCB_2O
	CALL	MESS_0
;
;Wait for a keypress
; if ' ', set lines to print to screen height - 1
; if CR, set lines to print to 1
; (dummy) if 'Q', set stack again and return to morepipe's caller
MORE_11
	LD	DE,DCB_2I
	CALL	ROM@GET
	OR	A
	JR	Z,MORE_11
	CP	' '
	JR	Z,MORE_13
	CP	CR
	JR	Z,MORE_14
	PUSH	AF
	CALL	MORE_ERASE
	POP	AF
	LD	HL,MORE_12
	PUSH	HL
	LD	HL,(KEYFUNC)
	JP	(HL)		;Returns to more_12
MORE_12
	CP	0
	JR	Z,MORE_10A	;Redisplay the - more - prompt
	CP	1
	RET	Z		;Return to display more text
	RET			;Catch the rest.
;
;Spacebar hit - full page
MORE_13
	CALL	MORE_ERASE
	LD	A,(HEIGHT)
	SUB	2		;1 line of context
	LD	(SCRPRINT),A
	RET
;
;CR hit - one line
MORE_14
	CALL	MORE_ERASE
	LD	A,1
	LD	(SCRPRINT),A
	RET
;
;User can jp here when Q hit, to exit from more
MORE_Q
	CALL	MORE_ERASE
	LD	HL,(OLDSTACK)
	LD	SP,HL
	RET
;
;Erase the - more - message just printed.
MORE_ERASE
	PUSH	AF
	LD	HL,(MORECLEAR)
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,OM_COOKED
	LD	(OUTPUT_MODE),A
	POP	AF
	RET
;
;A function returning nothing and doing nothing
NULLFUNC
	XOR	A
	RET
;
;Set width and length on current stty values
FIX_STTY
	LD	A,(TFLAG2)
	LD	B,16			;Height 16 lines
	BIT	TF_HEIGHT,A
	JR	Z,FS_01
	LD	B,24			;Height 24 lines
FS_01
	LD	HL,HEIGHT
	LD	(HL),B
;
	LD	A,(TFLAG2)
	LD	B,32			;Width 32 chars
	AND	TF_WIDTH
	JR	Z,FS_02
	LD	B,40			;Width 40 chars
	DEC	A
	JR	Z,FS_02
	LD	B,64			;Width 64 chars
	DEC	A
	JR	Z,FS_02
	LD	B,80			;Width 80 chars
FS_02
	LD	HL,WIDTH
	LD	(HL),B
	RET
;
;End of morepipe
