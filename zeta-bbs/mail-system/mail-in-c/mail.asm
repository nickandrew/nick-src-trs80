;mail: Assemble mail (read & send)
;
ZETA	EQU	0
;
*GET	DOSCALLS
;
	IF	ZETA
*GET	EXTERNAL
*GET	ASCII
;
	COM	'<Mail 1.0  04-Oct-87 Zeta>'
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
;;*GET	DEBUG
DEBUG	MACRO	#STR
	ENDM
;
START
	LD	HL,(HIMEM)
	LD	SP,HL
;
*GET	CINIT
*GET	CALL
;
*GET	MAIL1
*GET	MAIL2
*GET	MAIL3
*GET	MAIL4
*GET	MAIL5
;
*GET	ASCTIME
*GET	ATOI
*GET	CTYPE
*GET	FREAD
*GET	FWRITE
*GET	FTELL
*GET	GETTIME
*GET	GETUID
*GET	GETUNAME
*GET	SEEKTO
*GET	STRCMP
*GET	STRLEN
;
	IF	ZETA
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
