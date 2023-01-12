;Nedasfix/asm: By Nick Andrew (to make Nedas 4.2c).
; Ver 1.3, 28-Jan-85.
;
;Patch number one:
; This is a patch to allow NEDAS to read Edtasm type
;files properly - the original problem was due to a
;Newdos/80 <--> Ldos incompatibility.
;
	ORG	5D65H		;Version Number.
	DEFM	'2c'
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
	JR	NZ,590CH	;jr if Not Equal
	LD	A,1AH		;return a 1AH instead.
	RET
	NOP
	NOP
;
;
;  The reason Nedas worked on its own files was because
;it wrote full sectors. The FCB EOF value will = 00H
;always and the original code in the patch area jumped
;away if FCB EOF=00H. This is presumably to cater
;for non-RBA format FCBs.
;
;*
;Patch number 2: To stop Nedas page formatting.
; Is used for Epson compatible printers with auto
;skip over perforation.
;
	ORG	5BB6H
	RET		;was RET NZ.
;
	END	5800H
;
;/* Patches written by Nick Andrew, 28-Jan-85 */
