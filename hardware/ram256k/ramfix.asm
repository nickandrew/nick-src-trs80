;ramfix: Adjust ram in absence of fix on bootup.
;Version 1.0  on 01-Mar-87.
;
;    Terms used:  Talking about ram which can be moved
;is hard unless terms are defined.
;  PAGE:  Noun, referring to 1k contiguous ram.
;LOGICAL: Adj,  "as the Z80 sees the memory"
;PHYSICAL: Adj, relative to the 256k ram chips
;
;
	ORG	5200H
START	DI
;
;Signal that I am running.
	LD	HL,3C00H
	LD	DE,3C01H
	LD	(HL),20H
	LD	BC,03FFH
	LDIR
	LD	HL,MSG_1
	LD	DE,3E12H
	LD	BC,28
	LDIR
;
;set logical page 17 to physical page 1.
	LD	BC,4410H	;4400-47FFh, port 16
	LD	A,1		;physical page one.
	OUT	(C),A
;
;Copy initialisation code
; from: logical page 16 (4200h), physical UNKNOWN!
; to:   logical page 17 (4700h), physical page 1
;				 (physical ram 00700h)
	LD	HL,5200H
	LD	DE,5700H
	LD	BC,0100H
	LDIR
;Jump to logical page 17 (47xxh)
	JP	START2+500H
;
;Now in 47xxh block.
;
;
;Now set all pages such that:
;   logical page (16+x) = physical page x
START2
	LD	HL,MSG_2
	LD	DE,3E65H
	LD	BC,22
	LDIR
	LD	BC,4010H	;logical page 16
	LD	D,0H		;physical page 0
LOOP	OUT	(C),D
	INC	D		;next physical page
	LD	A,B
	ADD	A,4
	LD	B,A
	JR	NZ,LOOP		;loop until after FC00h.
;
;All ordinary ram is now addressed, now fake the rom boot
;code & jump into it.
;
	LD	HL,MSG_3
	LD	DE,3EAEH
	LD	BC,13
	LDIR
;
	JP	402DH
;
MSG_1	DEFM	'Now booting 256k ram machine'
MSG_2	DEFM	'Now running from 4700h'
MSG_3	DEFM	'Now rebooting'
;
	END	START
