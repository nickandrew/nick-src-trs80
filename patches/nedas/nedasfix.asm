;Nedasfix/asm: By Nick Andrew (to make Nedas 4.2b).
; Ver 1.2, 14-Sep-84.
;
;Patch number one:
; This is a patch for NEDAS to fix up a problem
;with handling of Fcb Eof and Next values.
; Specifically, when Nedas 4.1b read a file created
;by Edtasm/Edtasm+ or a file which does not finish on
;a sector boundary Nedas will either:
;   Read the file a sector short, or
;   Replace one byte of the text with 1AH.
;
	ORG	5D65H		;Version Number.
	DEFM	'2b'		;1b-->2b.
;
	ORG	58F4H		;Patch start addr.
	LD	IY,(56CAH)	;IY=FCB addr.
	LD	A,(IY+0AH)	;Middle order NEXT
	DEC	A		;***********
; A is decremented to find the 'NEXT' value of the
;LAST sector read NOT the next sector to be read.
	CP	(IY+0CH)	;Middle order EOF
	JR	C,590CH		;jr if M(N) < M(E)
	LD	A,(IY+08H)	;Low order EOF
	CP	L		;low order NEXT
;L contains the low order address of the next byte
;to be read from the file buffer NOT the Fcb's
;next value (which is always 00H).
	JR	NZ,590CH	;jr if NˆNE.
	LD	A,1AH		;return a 1AH instead.
	RET
	NOP
	NOP
;
;
;  What the above code does is check if the next byte
;to be read is past EOF.
; If so, then return a 1AH byte to hopefully tell Nedas
;to stop reading. If that doesn't work then Nedas will
;return with some sort of error.
;
; Previously, the code would return a 1AH byte a full
;sector before the end of the file was reached ALWAYS.
;  The reason Nedas worked on its own files was because
;it wrote full sectors. The FCB EOF value will = 00H
;always and the original code in the patch area jumped
;away if FCB EOF=00H. This is presumably to cater
;for non-RBA format FCBs.
;
;*
;Patch number 2: To fix bad page formatting when
;Listing text onto the printer. May not be
;necessary for all computers/printers.
	ORG	4028H
	DEFB	66	;Page Length.
	DEFB	0	;Line number at start.
	END	5800H
;
;/* Patches written by Nick Andrew, 14-Sep-84 */
;
