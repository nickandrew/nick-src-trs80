;pcopy: Copy contents of file to printer.
;V1.0 on 28-Apr-85.
*GET	DOSCALLS
;
	ORG	5200H
START	LD	DE,FCB
	CALL	DOS_EXTRACT
	LD	HL,BUFF
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,DOS_ERROR
LOOP	LD	DE,FCB
	CALL	13H
	JR	NZ,END_FILE
	CALL	PRINT
	JR	LOOP
;
END_FILE
	LD	DE,FCB
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	JP	DOS_NOERROR
;
PRINT	PUSH	AF
P_LOOP	LD	A,(37E8H)
	AND	0F0H
	CP	30H
	JR	NZ,P_LOOP
	POP	AF
	LD	(37E8H),A
	RET
;
FCB	DC	32,0
BUFF	DC	256,0
	END	START
