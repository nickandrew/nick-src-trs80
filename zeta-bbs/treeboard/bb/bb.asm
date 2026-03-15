; @(#) bb.asm: News and echomail system
;1.10:
;	Assemble under modern Linux with zmac
;1.9:
;	Flatten out the tree to become a list of topics!
;1.8c:
;	Base version
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
MAX_LINES	EQU	250
MAX_MSGS	EQU	1024
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	CLEAN_DISCON
;End of program load info.
;
	COM	'<BB 1.10  2026-03-15>'
;
	ORG	BASE+100H
;
*GET	BB1		;Code 1
*GET	BB2		;Code 2
*GET	BB3		;Code 3
*GET	BB4		;Message entry
*GET	BB5		;Subroutines
*GET	BB6		;Resend command
*GET	BB7		;Text file routines
;
*GET	$MONTH_NAME
*GET	$TWO_DIGIT
*GET	CI_CMP
*GET	CI_HASH
*GET	COMMON_SEARCH
*GET	DMY_ASCII
*GET	GETDATE
*GET	GETTIME
*GET	HMS_ASCII
*GET	LINEIN
*GET	MESS_0
*GET	MESS_NOCR
*GET	MOREPIPE	;Pipe output through - more - filter
*GET	MULTIPLY
*GET	PRINT_NUMB
*GET	PRINT_NUMB_DEV
*GET	STRCMP_CI
*GET	STRCPY
*GET	STRLEN
*GET	USER_SEARCH
;
*GET	BBDATA
;
ZZZZZZZY	EQU	$		;End of required data
	DEFS	4096	;Text buffer.
ZZZZZZZZ	EQU	$		;End of 4k buffer.
;
THIS_PROG_END	EQU	$
;
	END	START
