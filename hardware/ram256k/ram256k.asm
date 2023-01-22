;ram256K: Address ram where it should be addressed.
;Version 1.1b on 08-Jan-87.
;
;    Terms used:  Talking about ram which can be moved
;is hard unless terms are defined.
;  PAGE:  Noun, referring to 1k contiguous ram.
;LOGICAL: Adj,  "as the Z80 sees the memory"
;PHYSICAL: Adj, relative to the 256k ram chips
;
;This code should be read in from track 0 sector 0
;of a system disk BEFORE the dos is loaded ... if not,
;havoc will ensue. After setting memory, it reruns the
;rom IPL code to load a different sector of track 0.
;   The dos boot sector should be copied to that sector.
;NOTE: For a double density Model 1 disk the sectors
; which are modified must be on the REAL track 0 (single
; density) not the double density track which the DOS
; makes. Use Super Utility to write the real track 0.
;

*GET	DOSCALLS

NEWDOS	EQU	01H		;use sector 1 as boot.
DIRTRK	EQU	40
SECTOR	EQU	NEWDOS
;
	ORG	4200H
START	NOP
	CP	DIRTRK
	DI
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
	LD	HL,4200H
	LD	DE,4700H
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
	LD	DE,3E55H
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
	LD	DE,3E9AH
	LD	BC,13
	LDIR
;
	LD	A,1
	LD	(37E1H),A
	LD	HL,37ECH
	LD	(HL),0D0H	;interrupt controller.
	LD	DE,37EFH	;data register
	LD	(HL),00H	;restore r/w head FAST!
	LD	BC,0
	CALL	ROM@PAUSE		;delay
LOOP2	BIT	0,(HL)		;wait till done
	JR	NZ,LOOP2
;
	LD	A,SECTOR
	LD	(37EEH),A	;load sector register.
;
	JP	06BAH		;jump to IPL code.
;
MSG_1	DEFM	'Now booting 256k ram machine'
MSG_2	DEFM	'Now running from 4700h'
MSG_3	DEFM	'Now rebooting'
;
	END	START
