;@(#) mail.asm: Private network mail system
;
;1.10	20 Aug 89	Fix crashing bug in editor
;1.9c	24 Jul 89	Base version
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
MAX_LINES	EQU	250
MAX_MSGS	EQU	400
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	CLEAN_DISCON
;End of program load info.
;
	COM	'<Mail 1.10  20-Aug-89>'
;
	ORG	BASE+100H
;
*GET	MAIL1		;Code 1
*GET	MAIL2		;Code 2
*GET	MAIL3		;Code 3
*GET	MAIL4		;Message entry
*GET	MAIL5		;Subroutines
*GET	MAIL6		;Resend command
*GET	MAIL7		;Text file routines
;
*GET	LINEIN
*GET	MOREPIPE	;Pipe output through - more - filter
*GET	TIMES
*GET	ROUTINES
;
*GET	MAILDATA
;
ZZZZZZZY EQU $		;End of required data
	DEFS	5120	;Text buffer.
ZZZZZZZZ EQU $		;End of 4k buffer.
;
THIS_PROG_END	EQU	$
;
	END	START
