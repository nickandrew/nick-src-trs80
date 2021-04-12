;cc: Assemble the Small-C compiler.
;
ZETA	EQU	0
;
*GET	DOSCALLS
;
	IF	ZETA
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info.
	ORG	BASE+100H
	ELSE
	ORG	5200H
;
	ENDIF
	COM	'<cc 1.0a 31-Oct-87>'
;
;;*GET	DEBUG
DEBUG	MACRO	#$STR
	ENDM
;
START
	IF	ZETA
START1	DEC	HL
	LD	A,(HL)
	CP	' '
	JR	NC,START1
	INC	HL		;Pseudo start of cmd line
;
	LD	SP,START	;There is enough stack ?
	LD	(_CMDLINE),HL	;Save cmd line pointer
	LD	HL,1		;Disable redirection
	LD	(_NOREDIR),HL
;
;;	LD	A,(PRIV_1)
;;	BIT	IS_SYSOP,A
;;	LD	A,0
;;	JP	Z,TERMINATE
;
	ELSE
;
	LD	HL,(HIMEM)
	LD	SP,HL
;
	ENDIF
;
*GET	CINIT
*GET	CALL
;
*GET	C0
*GET	C1
*GET	C1A
*GET	C2
*GET	C3
*GET	C4
*GET	C5
*GET	C6
*GET	C7
*GET	C8
*GET	C9
*GET	CX
;
;*GET	INDEX
;*GET	STRCMP
;*GET	STRLEN
;
	IF	ZETA
*GET	ROUTINES
*GET	LIBCZ
	ELSE
*GET	LIBC
	ENDIF
;
_CMDLINE	DEFW	4318H
_NOREDIR	DEFW	0
;
HIGHEST	DEFW	$+2
;
	IF	ZETA
THIS_PROG_END	EQU	$
	ENDIF
;
	END	START