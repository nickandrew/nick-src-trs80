;Unarc ... by Bob Freed ... Modified for Trs-80 by
;Nick Andrew, 29-Nov-86.
;	      31-Dec-86
;	      29-Jan-86
;	      14-Aug-87 Convert 1st char of filename
;	      13-Sep-87 Convert 1st char of extension
;
*GET	DOSCALLS
;
SEP	EQU	'.'
TBASE	EQU	5200H
;
;SHOWC	EQU	1
;SHOWD	EQU	1
;SHOWE	EQU	1
;SHOWF	EQU	1
;
	ORG	TBASE
_EXIT
	JP	DOS
;
*GET	FILEA:2
*GET	FILEB:2
*GET	FILEC:2
*GET	FILED:2
*GET	FILEE:2
*GET	FILEF:2
*GET	FILEG:2
*GET	FILEH:2
*GET	FILEI:2
*GET	FILEJ:2
*GET	FILEK:2
;
	END	BEGIN
