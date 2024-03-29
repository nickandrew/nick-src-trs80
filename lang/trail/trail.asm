; trail2/asm: Remove trailing tab from Disassem created
; files.
;
; Version 1.1 on 06-Feb-85. Written by Nick Andrew.
;
; Edtasm source files created by Newdos Disassem package
; contain a trailing tab on lines containing NOPs etc..
; This program will remove a tab immediately preceding
; carriage return on source file lines.
;
; Usage: TRAIL sourcefile destfile
;
*GET	DOSCALLS
;
	ORG	5200H
START	LD	DE,FCB_INP
	CALL	DOS_EXTRACT
	LD	DE,FCB_OUT
	CALL	DOS_EXTRACT
;
	LD	HL,INBK_END
	LD	(GET_NEXT),HL
;
	LD	HL,BUF_INP
	LD	DE,FCB_INP
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,DOS_ERROR
	LD	HL,BUF_OUT
	LD	DE,FCB_OUT
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,DOS_ERROR
LOOP	CALL	GET_LINE
	JR	Z,EXIT
	CALL	TRAIL
	CALL	PUT_LINE
	JR	LOOP
EXIT	LD	A,1AH
	LD	DE,FCB_OUT
	CALL	ROM@PUT
	JP	NZ,DOS_ERROR
	LD	A,0DH
	CALL	ROM@PUT_VDU
	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	LD	DE,FCB_INP
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	JP	DOS_NOERROR
;
GET_LINE
	LD	DE,FCB_INP
	CALL	GET_ONE
	JP	NZ,DOS_ERROR
	CP	1AH
	RET	Z
	LD	HL,LINE
	LD	(HL),A
	INC	HL
GL_1	PUSH	HL
	LD	DE,FCB_INP
	CALL	GET_ONE
	JP	NZ,DOS_ERROR
	POP	HL
	LD	(HL),A
	INC	HL
	CP	0DH
	JR	NZ,GL_1
	OR	A
	RET
;
GET_ONE
	LD	HL,(GET_NEXT)
	LD	DE,INBK_END
	RST	18H	;cp hl,de
	JR	Z,REREAD
	LD	A,(HL)
	INC	HL
	LD	(GET_NEXT),HL
	CP	A
	RET
REREAD
	LD	HL,IN_BLOCK
	LD	(GET_NEXT),HL
	LD	B,20
RD_LP	PUSH	BC
	PUSH	HL
	LD	DE,FCB_INP
	CALL	DOS_READ_SECT
	POP	DE
	POP	BC
	JR	NZ,ERR_CHK
ERR_OK
	PUSH	BC
	LD	HL,BUF_INP
	LD	BC,100H
	LDIR
	PUSH	DE
	POP	HL
	POP	BC
	DJNZ	RD_LP
	JR	GET_ONE
;
ERR_CHK	CP	1CH
	JR	Z,ERR_OK
	CP	1DH
	JR	Z,ERR_OK
	RET
;
;
GET_NEXT	DEFW	INBK_END
;
TRAIL	DEC	HL
	DEC	HL
	LD	A,(HL)
	CP	09H
	RET	NZ
	LD	(HL),0DH
	LD	A,'.'
	CALL	ROM@PUT_VDU
	RET
;
PUT_LINE
	LD	HL,LINE
PL_1	LD	A,(HL)
	PUSH	HL
	LD	DE,FCB_OUT
	CALL	ROM@PUT
	JP	NZ,DOS_ERROR
	POP	HL
	LD	A,(HL)
	INC	HL
	CP	0DH
	JR	NZ,PL_1
	RET
;
LINE	DEFS	128
;
FCB_INP	DEFS	32
FCB_OUT	DEFS	32
BUF_INP	DEFS	256
BUF_OUT	DEFS	256
;
IN_BLOCK	DEFS	256*20
INBK_END	NOP
;
	END	START
