;Unarc88 ... by Bob Freed ... Modified for Trs-80 by
;Nick Andrew, 29-Nov-86.
;	      31-Dec-86
;	      29-Jan-86
;	      14-Aug-87 Convert 1st char of filename
;	      13-Sep-87 Convert 1st char of extension
;             29-Apr-89 Many improvements and some bugfixes
;
*GET	DOSCALLS
;
SEP	EQU	'.'
TBASE	EQU	5200H
; system equates
MEMTOP	EQU	4049H		; himem for model 1
;
;SHOWC	EQU	1
;SHOWD	EQU	1
;SHOWE	EQU	1
;SHOWF	EQU	1
;
	COM	'<Unarc 1988 release, 06-May-89>'
	ORG	TBASE
_EXIT
	JP	DOS
_ERROR
	JP	DOS
;
*GET	FILEA
*GET	FILEB
*GET	FILEC
*GET	FILED
*GET	FILEE
*GET	FILEF
*GET	FILEG
*GET	FILEH
*GET	FILEI
*GET	FILEJ
*GET	FILEK
;
	END	BEGIN
