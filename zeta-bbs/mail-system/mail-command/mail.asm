;@(#) mail.asm: Private network mail system
;
*GET	DOSCALLS.HDR
*GET	EXTERNAL.HDR
*GET	ASCII.HDR
;
MAX_LINES	EQU	250
MAX_MSGS	EQU	512
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	CLEAN_DISCON
;End of program load info.
;
	COM	'<Mail 1.8a 08-Apr-89>'
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
*GET	LINEIN.LIB
*GET	TIMES.LIB
*GET	ROUTINES.LIB
;
*GET	MAILDATA
;
ZZZZZZZY EQU $		;End of required data
	DEFS	4096	;Text buffer.
ZZZZZZZZ EQU $		;End of 4k buffer.
;
THIS_PROG_END	EQU	$
;
	END	START
