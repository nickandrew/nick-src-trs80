;CHANGE: CONVERTS AN EDTASM /EDT TYPE FILE
; TO A /FOR FORMAT FILE.
; Assembled OK 30-Mar-85.
*GET	DOSCALLS
	ORG	5200H
CONVERT	LD	HL,COM_BUFF
	CALL	NEXTWORD
	INC	HL
	PUSH	HL
	LD	DE,BUFFER1
	CALL	DOS_EXTRACT
	POP	HL
	CALL	NEXTWORD
	INC	HL
	LD	DE,BUFFER2
	CALL	DOS_EXTRACT
	LD	DE,BUFFER2
	LD	HL,DEFEXT2
	CALL	DOS_EXTEND
	LD	DE,BUFFER1
	LD	HL,DEFEXT1
	CALL	DOS_EXTEND
	CALL	PART1
	LD	HL,BUFFER1
	CALL	MESS_DO
	LD	A,20H
	CALL	ROM@PUT_VDU
	CALL	PART2
	LD	HL,BUFFER2
	CALL	MESS_DO
	LD	A,'.'
	CALL	ROM@PUT_VDU
	LD	A,0DH
	CALL	ROM@PUT_VDU
	LD	DE,BUFFER1
	LD	HL,BUFFRD1
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,DOS_ERROR
	LD	DE,BUFFER2
	LD	HL,BUFFWR2
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,DOS_ERROR
	CALL	READ1
	CP	211
	LD	A,32	;'FORMAT ERROR'
	JP	NZ,DOS_ERROR
	CALL	READ1
	CP	211
	LD	A,32
	JP	Z,DOS_ERROR
	LD	B,5
READNAME	PUSH	BC
	CALL	READ1
	POP	BC
	DJNZ	READNAME
LOOP	CALL	READ1
	CP	1AH
	JR	NZ,BYPASS
	LD	DE,BUFFER1
	CALL	DOS_CLOSE
	LD	DE,BUFFER2
	CALL	DOS_CLOSE
	JP	DOS_NOERROR
BYPASS	CALL	WRITE2
	LD	B,4
LINE$NO	PUSH	BC
	CALL	READ1
	CALL	WRITE2
	POP	BC
	DJNZ	LINE$NO
	CALL	READ1
	LD	A,89H
	CALL	WRITE2
LOOP2	CALL	READ1
	PUSH	AF
	CALL	WRITE2
	POP	AF
	CP	0DH
	JR	Z,LOOP
	JR	LOOP2
NEXTWORD	INC	HL
	LD	A,(HL)
	CP	21H
	JR	NC,NEXTWORD
	RET
READ1	LD	DE,BUFFER1
	CALL	ROM@GET
	RET	Z
	CP	28
	JP	NZ,DOS_ERROR
	LD	DE,BUFFER1
	CALL	DOS_CLOSE
	LD	DE,BUFFER2
	CALL	DOS_CLOSE
	JP	DOS_NOERROR
	RET
WRITE2	LD	DE,BUFFER2
	CALL	ROM@PUT
	JP	NZ,DOS_ERROR
	RET
PART1	LD	HL,PM1
PARV01	CALL	MESSAGE
	RET
PART2	LD	HL,PM2
	JR	PARV01
MESSAGE	LD	A,(HL)
	OR	A
	RET	Z
	CALL	ROM@PUT_VDU
	INC	HL
	CP	0DH
	JR	NZ,MESSAGE
	RET
PM1	DEFM	'CONVERTING '
	DEFB	00H
PM2	DEFM	'TO '
	DEFB	00H
DEFEXT1	DEFM	'EDT'
DEFEXT2	DEFM	'FOR'
BUFFER1	DEFS	32
BUFFER2	DEFS	32
BUFFRD1	DEFS	256
BUFFWR2	DEFS	256
	END	CONVERT
