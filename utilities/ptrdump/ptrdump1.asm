;ptrdump: dump file to printer.
*GET	DOSCALLS
	ORG	5300H
START	LD	SP,START
	LD	DE,FCB
	CALL	DOS_EXTRACT
	LD	HL,BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,DOS_ERROR
LOOP	LD	DE,FCB
	CALL	$GET
	JP	NZ,DOS_NOERROR
	CALL	PTR
	JR	LOOP
;
PTR	JP	05B4H
FCB	DEFS	32
BUF	DEFS	256
;
	END	START
