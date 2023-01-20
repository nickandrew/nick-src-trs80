;Spool: Spool a file to the 'spooler' program.
;(C) 1986, Zeta Microcomputer Software. Model I.
;
;
*GET	DOSCALLS
*GET	SPOOLHDR
;
	ORG	5200H
START
	LD	A,(HL)
	CP	0DH
	JP	Z,DOS_NOERROR
;
SPOOL_LOOP
	DI
	LD	A,(QUEUE)
	CP	16
	JP	Z,Q_FULL
	LD	(CMD_ARGS),HL
;
	LD	HL,MAX_QUEUE-1*32+QUEUE_PTR-1
	LD	DE,MAX_QUEUE*32+QUEUE_PTR-1
	LD	BC,MAX_QUEUE-1*32
	LDDR
;
NO_SHIFT
	LD	A,(QUEUE)
	INC	A
	LD	(QUEUE),A
;
	LD	DE,QUEUE_PTR
	LD	HL,(CMD_ARGS)
SP_1	LD	A,(HL)
	CP	0DH
	JR	Z,SP_2
	CP	' '
	JR	Z,SP_2
	LD	(DE),A
	INC	HL
	INC	DE
	JR	SP_1
SP_2
	LD	A,03H
	LD	(DE),A
	LD	A,(HL)
	CP	' '
	JR	NZ,SPOOL_DONE
SP_3	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,SP_3
	JP	SPOOL_LOOP
;
;Done.
SPOOL_DONE
	EI
	JP	DOS_NOERROR
;
Q_FULL
	LD	HL,M_QF
	CALL	4467H
	EI
	JP	DOS_NOERROR
;
M_QF	DEFM	'Spool: Queue is full. Try later.',0DH
;
CMD_ARGS	DEFW	0
;
	END	START
