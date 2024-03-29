;Msgconv: Converts from the old message base to the new
;
ZETA	EQU	0
;
*GET	DOSCALLS
;
	IF	ZETA
*GET	EXTERNAL
*GET	ASCII
;
	COM	'<Msgconv 1.0a 14-Dec-87>'
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info.
	ORG	BASE
	ELSE
	ORG	5200H
;
	ENDIF
;
;;*GET	DEBUGF
;
START
	IF	ZETA
START1	DEC	HL
	LD	A,(HL)
	CP	' '
	JR	NC,START1
	INC	HL		;Pseudo start of cmd line
;
	LD	SP,START	;There is plenty of stack
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
*GET	MSGCONV1
;
*GET	ATOI
*GET	CTYPE
*GET	FWRITE
;;*GET	INDEX
*GET	MALLOC
;;*GET	STRCMP
;;*GET	STRLEN
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
