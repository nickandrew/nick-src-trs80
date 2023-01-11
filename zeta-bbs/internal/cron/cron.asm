;Cron: Execute commands at certain times and at certain intervals
;
ZETA		EQU	1
DEBUGF		EQU	0	;Function call debugging
DEBUGG		EQU	0	;Loop at start debug
SYSOPONLY	EQU	1	;Only the Sysop may run
REDIRDIS	EQU	1	;1 to disable redirection
STACKSIZE	EQU	100H	;Size of the stack
;
*GET	DOSCALLS
;
	IF	ZETA
*GET	EXTERNAL
*GET	ASCII
;
	COM	'<Cron 1.1  12 May 90>'
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info.
	ORG	BASE+STACKSIZE
	ELSE
	ORG	5200H+STACKSIZE
;
	ENDIF
;
TOPSTACK	EQU	$
;
	IF	DEBUGF
*GET	DEBUGF
	ELSE
DEBUG	MACRO	#STR
	ENDM
	ENDIF
;
START
	IF	ZETA
START1	DEC	HL
	LD	A,(HL)
	CP	' '
	JR	NC,START1
	INC	HL		;Pseudo start of cmd line
;
	LD	SP,TOPSTACK	;There is plenty of stack
	LD	(_CMDLINE),HL	;Save cmd line pointer
	LD	HL,REDIRDIS	;Disable redirection
	LD	(_NOREDIR),HL
;
	IF	SYSOPONLY
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	LD	A,0
	JP	Z,TERMINATE
	ENDIF
;
	ELSE
;
	LD	HL,(HIMEM)
	LD	SP,HL
;
	ENDIF
;
	IF	DEBUGG
DB_LOOP
	JP	DB_LOOP
	ENDIF
;
*GET	CINIT
*GET	CALL
;
*GET	CRON1
*GET	CRON2
;;*GET	ARCSUBS
;;*GET	ATOI		;Requires ctype
;;*GET	CTYPE		;Required by atoi
;;*GET	FTELL
;;*GET	FWRITE
;;*GET	GETOPT
*GET	GETTIME
;;*GET	GETW
;;*GET	INDEX
;;*GET	PNUMB
*GET	SAVEPOS
;;*GET	STRCHR
;;*GET	STRCMP
;;*GET	STRLEN
*GET	_SYSTEM
;;*GET	_UNLINK
;;*GET	WILD
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
_BRKSIZE	DEFW	$+2
;
	IF	ZETA
THIS_PROG_END	EQU	$
	ENDIF
;
	END	START
