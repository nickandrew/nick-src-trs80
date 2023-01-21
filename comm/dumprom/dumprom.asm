;dumprom: Dump the nicemodem rom
;  Usage: dumprom filename/bin

*GET	DOSCALLS
CR	EQU	0DH
LF	EQU	0AH
;
	ORG	5200H
	DEFM	'<dumprom 1.0  2021-01-13 from 11-Nov-86>'
	DEFS	256			; 256 bytes of low stack
START	LD	SP,START
	LD	DE,FCB_OUT
	CALL	DOS_EXTRACT
	JP	NZ,DOS_ERROR
;
	LD	HL,BUF_OUT
	LD	DE,FCB_OUT
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,DOS_ERROR
;
;
	LD	HL,M_SETDUMP
	CALL	MODEM_PUTS
;
	LD	B,35
DELAY1	PUSH	BC
	LD	BC,0
	CALL	60H
	CALL	MODEM_GETC
	POP	BC
	DJNZ	DELAY1
	LD	B,16
DELAY2	CALL	MODEM_GETC
	DJNZ	DELAY2
;
	XOR	A
	LD	(BLOCK),A
;
LOOP	LD	HL,M_DUMP
	CALL	MODEM_PUTS
	LD	HL,XBUFF
	LD	(XB_POS),HL
	LD	B,16
LOOP2
	PUSH	BC
	CALL	MODEM_GETS
	CALL	WRITE_LINE
	POP	BC
	DJNZ	LOOP2
;
	CALL	MODEM_GETS
	LD	HL,ZERO
	LD	DE,BUFFER
	CALL	STR_CMP
	JP	NZ,ERROR
;
	LD	B,0
	LD	HL,XBUFF
	LD	DE,FCB_OUT
LOOP3	LD	A,(HL)
	INC	HL
	CALL	ROM@PUT
	JP	NZ,DOS_ERROR
	DJNZ	LOOP3
;
	LD	A,(BLOCK)
	INC	A
	LD	(BLOCK),A
	CP	64		;16k total memory!
	JR	NZ,LOOP
;
	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	JP	DOS_NOERROR
;
MODEM_PUTS
	LD	A,(HL)
	OR	A
	RET	Z
	PUSH	HL
	CALL	MODEM_PUTC
	POP	HL
	INC	HL
	JR	MODEM_PUTS
;
MODEM_GETS
	LD	A,255
	LD	(BUFFER+78),A
	LD	HL,BUFFER
MG_01
	PUSH	HL
MG_02
	CALL	MODEM_GETC
	OR	A
	JR	Z,MG_02
	POP	HL
	LD	(HL),A
	INC	HL
	CP	LF
	JR	NZ,MG_01
	LD	(HL),0
	RET
;
STR_CMP
	LD	A,(DE)
	CP	(HL)
	RET	NZ
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	STR_CMP
;
WRITE_LINE
	LD	A,(BUFFER+3)
	CP	'0'
	JP	NZ,ERROR
	LD	A,(BUFFER+4)
	CP	' '
	JP	NZ,ERROR
	LD	A,(BUFFER+78)
	OR	A
	JP	NZ,ERROR
	LD	HL,BUFFER+7	;first one
	LD	B,16		;16 bytes
WL_01	PUSH	BC
	CALL	WRITE_BYTE
	POP	BC
	DJNZ	WL_01
	RET
;
WRITE_BYTE
	LD	A,(HL)
	CALL	33H
	CP	'A'
	JR	C,WB_01
	SUB	7
WB_01	AND	0FH
	RLA
	RLA
	RLA	
	RLA
	LD	B,A
	INC	HL
	LD	A,(HL)
	CALL	33H
	CP	'A'
	JR	C,WB_02
	SUB	7
WB_02	AND	0FH
	OR	B
	PUSH	HL
	LD	HL,(XB_POS)
	LD	(HL),A
	INC	HL
	LD	(XB_POS),HL
	POP	HL
	INC	HL
	LD	A,(HL)
	CP	' '
	JP	NZ,ERROR
	INC	HL
	RET
;
MODEM_GETC
	IN	A,(0F9H)
	BIT	1,A	;dav
	LD	A,0
	RET	Z
	IN	A,(0F8H)
	RET
;
MODEM_PUTC
	LD	C,A
PC_01	IN	A,(0F9H)
	BIT	0,A	;cts
	JR	Z,PC_01
	LD	A,C
	OUT	(0F8H),A
	RET
;
ERROR	LD	HL,M_ERROR
	CALL	4467H
	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	JP	DOS_NOERROR
;
M_ERROR	DEFM	'error ....',CR,0
ZERO	DEFM	'0',CR,LF,0
M_SETDUMP
	DEFM	'atv0e1db1dmff00',CR,0
M_DUMP
	DEFM	'atdm',CR,0
;
BLOCK	DEFB	0
;
FCB_OUT	DEFS	32
BUF_OUT	DEFS	256
;
BUFFER	DEFS	1024
XB_POS	DEFW	XBUFF
XBUFF	DEFS	256
	END	START
