; @(#) bb.asm: News and echomail system
*GET	DOSCALLS.HDR
*GET	EXTERNAL.HDR
*GET	ASCII.HDR
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
	COM	'<BB 1.8a 14-May-89>'
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
*GET	LINEIN.LIB
*GET	MOREPIPE.LIB	;Pipe output through - more - filter
*GET	TIMES.LIB
*GET	ROUTINES.LIB
;
*GET	BBDATA
;
ZZZZZZZY EQU $		;End of required data
	DEFS	4096	;Text buffer.
ZZZZZZZZ EQU $		;End of 4k buffer.
;
THIS_PROG_END	EQU	$
;
	END	START
