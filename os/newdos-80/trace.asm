; TRACE utility - 9 Nov 82

HIMEM	EQU	4049H	; top of memory pointer

; Initialization routine - moves trace routine to top of
;	memory, links it into clock interrupt chain, &
;	resets top of memory pointer to below trace routine.

	ORG	5200H
START	LD	HL,TRCEND-1
	LD	DE,(HIMEM)	; find current top of memory
	LD	BC,TRCEND-TRACE
	LDDR			; ..& move trace routine there
	LD	(HIMEM),DE	; set top of mem below trace routine
	INC	DE
	CALL	4410H		; activate interrupt routine
	JP	402DH		; return to DOS

; TRACE routine - this is placed at the top of memory by
;	the initialization routine (above) & set to run
;	every 1/2 sec (20 "ticks") by the clock interrupt.
;	(Note that this routine is relocatable)

TRACE	DEFW	0	; link - used by NEWDOS
	DEFB	20	; nr of ticks per call
	DEFB	20	; initial tick count

	LD	HL,14	; find PC before call
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL	; (HL = value to be displayed)

	LD	DE,3C00H+47	; screen pos to display PC
	LD	B,4		; number of digits

V	XOR	A
	ADD	HL,HL	; shift one hex digit (4 bits)..
	ADC	A,A	; ..out of HL into A
	ADD	HL,HL
	ADC	A,A
	ADD	HL,HL
	ADC	A,A
	ADD	HL,HL
	ADC	A,A

	DAA		; convert digit to ASCII
	CP	10
	SBC	A,-'0'-1

	LD	(DE),A	; place digit on screen
	INC	DE	; next screen pos
	DJNZ	V	; next digit (if any)
	RET
TRCEND	EQU	$

	END	START
