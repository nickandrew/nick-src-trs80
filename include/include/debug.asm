;debug: Help debug C compiler output
;Last updated: 06-Mar-89
;
; Function TOVDU prints out the string in memory which immediately
; follows CALL TOVDU, and jumps past the string to return.
TOVDU	POP	HL
TOVDU1
	LD	A,(HL)
	OR	A
	JR	Z,TOVDU3
TOVDU2
	PUSH	HL
	LD	HL,3C41H
	LD	DE,3C40H
	LD	BC,63
	LDIR
	LD	(3C7FH),A
	LD	BC,0800H	;Delay per letter
	CALL	60H
	POP	HL
	INC	HL
	JR	TOVDU1
TOVDU3
	LD	BC,0		;Delay per function
	CALL	60H
	CALL	60H
;;	CALL	60H
	INC	HL
	JP	(HL)

DEBUG	MACRO	#STR
	CALL	TOVDU
	DEFM	#STR,' ',0
	ENDM
;
