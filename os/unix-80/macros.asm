;Macros/asm: Macro definitions.
; Date: 19-Jul-84.
;'TEST_FLAG': Test the value of a flag for true/false
; and jump if the condition is met.
; ie. 'test_flag     flagname,true,loop'
;
TEST_FLAG	MACRO	#FLAG,#VALUE,#ADDRESS
	LD	A,(#FLAG)
	OR	A
	IF	F_#VALUE
	JP	NZ,#ADDRESS
	ELSE
	JP	Z,#ADDRESS
	ENDIF
	ENDM
;
;'SET_FLAG': Set a flag to either true or false.
; ie. 'set_flag     flagname,true'
;
SET_FLAG	MACRO	#FLAG,#VALUE
	LD	A,F_#VALUE
	LD	(#FLAG),A
	ENDM
;
;'mess': Display message.
MESS	MACRO	#ADDRESS
	LD	HL,#ADDRESS
	CALL	MESSAGE_DO
	ENDM
;
;'messag': Print message.
MESSAG	MACRO	#MSG
	IF	MESSAGES
	LD	HL,#MSG
	CALL	MESSAGE_DO
	ENDIF
	ENDM
;
;
; tab_start: Show the start of a table if option show
;is TRUE.
TAB_START	MACRO	#TEXT
	IF	SHOW
	DEFM	#TEXT,'>'
	ENDIF
	ENDM
;
