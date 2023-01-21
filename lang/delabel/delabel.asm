;Delabel/asm ver 1.1 06-Feb-85. Written by Nick Andrew.
; This program removes extraneous labels from source
;code created using Newdos Disassem package.
; Usage: DELABEL sourcefile destfile
;
; For model III users, DOSCALLS/ASM must be changed
;to reflect model 3 status (ie. HIMEM=4411H ...)
;
;
*GET	DOSCALLS
;
	ORG	5200H
START	LD	DE,FCB_INP
	CALL	DOS_EXTRACT
	DEC	HL
ST_1	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,ST_1
	LD	DE,FCB_OUT
	CALL	DOS_EXTRACT
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
;
	CALL	PASS_ONE
	CALL	PASS_TWO
;
EXIT	LD	DE,FCB_INP
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	LD	DE,FCB_OUT
	CALL	DOS_CLOSE
	JP	NZ,DOS_ERROR
	JP	DOS_NOERROR
;
;
PASS_ONE
	LD	HL,PASS1
	CALL	4467H
	LD	HL,0
	LD	(NUM_LABELS),HL
	LD	HL,TABLE
	LD	(TOP_TABLE),HL
PO_1	CALL	GET_LINE
	JR	Z,PASS1_END
	CALL	CHK_EQU
	JR	NZ,PO_1
	CALL	ADD_EQU
	LD	HL,(TOP_TABLE)
	LD	DE,30
	ADD	HL,DE
	EX	DE,HL
	LD	HL,(4049H)
	LD	A,H
	CP	D
	JR	C,MEM_FULL
	JR	NZ,PO_1
	LD	A,L
	CP	C
	JR	C,MEM_FULL
	JR	PO_1
;
MEM_FULL
	LD	HL,MESS_FULL
	CALL	4467H
	JP	EXIT
;
PASS1_END
	LD	HL,PASS1_E
	CALL	4467H
	RET
;
;
PASS_TWO
	LD	HL,PASS2
	CALL	4467H
	LD	DE,FCB_INP
	CALL	DOS_REWIND
	JP	NZ,DOS_ERROR
PT_1	CALL	GET_LINE
	JR	Z,PASS2_END
	CALL	CHK_EQU
	JR	Z,PT_1
	CALL	CHK_REF
	JR	Z,PT_3
PT_2	CALL	PUT_LINE
	JR	PT_1
PT_3	CALL	SEARCH
	JR	NZ,PT_2
	CALL	REPLACE
	JR	PT_2
;
PASS2_END
	LD	DE,FCB_OUT
	LD	A,1AH	;write eof byte.
	CALL	001BH
	LD	HL,PASS2_E
	CALL	4467H
	RET
;
CHK_EQU	LD	HL,IN_LINE+6
	LD	B,3
CE_1	CALL	IS_LETTER
	RET	NZ
	DJNZ	CE_1
	LD	A,(HL)
	CP	09H
	RET	NZ
	INC	HL
	LD	DE,EQU_TEXT
	LD	B,4
CE_2	CALL	IS_EQ
	RET	NZ
	DJNZ	CE_2
	LD	B,4
CE_3	CALL	IS_HEX
	RET	NZ
	DJNZ	CE_3
	CALL	IS_HEX
	JR	Z,CE_4
	DEC	HL
CE_4	LD	A,(HL)
	CP	'H'
	RET	NZ
	INC	HL
	LD	A,(HL)
	OR	A
	RET
;
IS_LETTER
	LD	A,(HL)
	INC	HL
	CP	'A'
	JR	C,_NZ
	CP	'z'+1
	JR	NC,_NZ
	CP	'a'
	JR	NC,_Z
	CP	'Z'+1
	JR	NC,_NZ
	JR	_Z
;
IS_EQ	LD	A,(DE)
	CP	(HL)
	RET	NZ
	INC	HL
	INC	DE
	RET
;
IS_HEX	LD	A,(HL)
	INC	HL
	CP	'0'
	JR	C,_NZ
	CP	'9'+1
	JR	C,_Z
	CP	'A'
	JR	C,_NZ
	CP	'F'+1
	JR	C,_Z
	CP	'a'
	JR	C,_NZ
	CP	'f'+1
	JR	C,_Z
	JR	_NZ
;
_Z	CP	A
	RET
_NZ	OR	A
	RET	NZ
	CP	1
	RET
;
ADD_EQU	LD	HL,(NUM_LABELS)
	INC	HL
	LD	(NUM_LABELS),HL
	LD	HL,(TOP_TABLE)
	EX	DE,HL
	LD	HL,IN_LINE+6
	LD	BC,3
	LDIR
	LD	HL,IN_LINE+14
	LD	A,(HL)
AE_1	CP	'0'
	JR	NZ,AE_2
	INC	HL
	LD	A,(HL)
	CP	'9'+1
	JR	C,AE_1
	DEC	HL
AE_2	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	NZ,AE_2
	LD	HL,(TOP_TABLE)
	LD	DE,10
	ADD	HL,DE
	LD	(TOP_TABLE),HL
	RET
;
CHK_REF	LD	HL,IN_LINE+6
CR_1	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,CR_5
	CP	09H
	JR	NZ,CR_1
CR_2	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,CR_5
	CP	09H
	JR	NZ,CR_2
CR_3	LD	B,3
CR_4	LD	A,(HL)
	OR	A
	JR	Z,CR_5
	CALL	IS_LETTER
	JR	NZ,CR_3
	DJNZ	CR_4
	CALL	IS_LETTER
	JR	Z,CR_5
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
	CP	A
	RET
CR_5	XOR	A
	CP	1
	RET
;
SEARCH	PUSH	HL
	LD	HL,(NUM_LABELS)
	PUSH	HL
	POP	BC
	LD	HL,TABLE
	POP	DE
SE_1	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	B,3
SE_2	LD	A,(DE)
	CP	(HL)
	JR	NZ,SE_3
	INC	HL
	INC	DE
	DJNZ	SE_2
	POP	AF
	POP	BC
	POP	AF
	CP	A
	RET
SE_3	POP	BC
	POP	DE
	POP	HL
	PUSH	DE
	LD	DE,10
	ADD	HL,DE
	POP	DE
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,SE_1
	XOR	A
	CP	1
	RET
;
REPLACE	PUSH	BC
	PUSH	HL
	LD	HL,END_CHARS
	EX	DE,HL
RE_1	LD	A,(HL)
	LD	(DE),A
	OR	A
	JR	Z,RE_2
	INC	HL
	INC	DE
	JR	RE_1
RE_2	POP	HL
	POP	DE
RE_3	LD	A,(HL)
	OR	A
	JR	Z,RE_4
	LD	(DE),A
	INC	HL
	INC	DE
	JR	RE_3
RE_4	LD	HL,END_CHARS
RE_5	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	NZ,RE_5
	LD	A,'.'
	CALL	ROM@PUT_VDU
	RET
;
GET_LINE
	LD	DE,FCB_INP
	CALL	0013H
	JP	NZ,DOS_ERROR
	CP	1AH
	RET	Z
	LD	HL,IN_LINE
	LD	(HL),A
	INC	HL
GL_1	PUSH	HL
	LD	DE,FCB_INP
	CALL	0013H
	JP	NZ,DOS_ERROR
	POP	HL
	LD	(HL),A
	INC	HL
	CP	0DH
	JR	NZ,GL_1
	DEC	HL
	LD	(HL),0
	INC	HL
	CP	1
	RET
;
PUT_LINE
	LD	HL,IN_LINE
PL_1	PUSH	HL
	LD	A,(HL)
	OR	A
	JR	Z,PL_2
	LD	DE,FCB_OUT
	CALL	001BH
	JP	NZ,DOS_ERROR
	POP	HL
	INC	HL
	JR	PL_1
PL_2	LD	A,0DH
	POP	HL
	LD	DE,FCB_OUT
	CALL	001BH
	JP	NZ,DOS_ERROR
	LD	A,''
	CALL	ROM@PUT_VDU
	RET
;
FCB_INP	DEFS	32
FCB_OUT	DEFS	32
BUF_INP	DEFS	256
BUF_OUT	DEFS	256
PASS1	DEFM	'Pass one:',0DH
PASS2	DEFM	'Pass two:',0DH
PASS1_E	DEFM	'Finished Pass 1',0DH
PASS2_E	DEFM	'Finished Pass 2',0DH
	DEFM	'end_chars>'
END_CHARS	DEFS	50H
	DEFM	'in_line>'
IN_LINE	DEFS	128
	DEFM	'num_labels>'
NUM_LABELS	DEFW	0
	DEFM	'top_table>'
TOP_TABLE	DEFW	0
MESS_FULL	DEFM	'Memory Full. Sorry!',0DH
EQU_TEXT	DEFM	'EQU',09H
;
	DEFM	'TABLE>'
TABLE	DEFB	0
;
	END	START
