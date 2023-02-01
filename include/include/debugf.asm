;debugf: Help debug C compiler output
;Last updated: 12-Jun-89
;
; Function TOVDU scrolls the string in memory which immediately
; follows the function call, to the VDU 1 line from the top, from
; right to left. The function returns by jumping past the end of
; the string.
; Clobbers AF, BC, DE, HL, maybe more
;
; Usage:
;	CALL	TOVDU
;	DEFM	'String-to-print', ' ', 0
;
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
	CALL	ROM@PAUSE
	POP	HL
	INC	HL
	JR	TOVDU1
TOVDU3
	LD	BC,0		;Delay per call
	CALL	ROM@PAUSE
	CALL	ROM@PAUSE
	INC	HL
	JP	(HL)		;Jump past the string
;
;End of debugf
