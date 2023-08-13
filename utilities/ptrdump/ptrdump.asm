;ptrdump version 2 because I lost version 1.
;  Prints the contents of a file on the printer
;
*GET	DOSCALLS
@PRT	EQU	003BH	; Output a byte to the printer (A: byte)
;
	ORG	5200H
	DEFM	'<ptrdump 2.0  07-Jan-86 Trs-80 M1>'
	DEFM	'<usage: ptrdump filename>'
	ORG	5300H
START	LD	SP,START
	LD	DE,FCB
	CALL	DOS_EXTRACT
	JP	NZ,DOS_ERROR
	LD	HL,BUFF
	LD	DE,FCB
	CALL	DOS_OPEN_EX
	JP	NZ,DOS_ERROR
;
LOOP	LD	DE,FCB
	CALL	ROM@GET
	JP	NZ,DOS_NOERROR
	CALL	@PRT
	JR	LOOP
;
BUFF	DEFS	256
FCB	DEFS	32
;
	END	START
