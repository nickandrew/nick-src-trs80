;grep: Search for a string of chars in a file.
;usage: grep pattern filename
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	TERMINATE
	DEFW	TERMINATE
;End of program load info.
;
	COM	'<GREP 1.1e 03-Jun-87>'
	ORG	BASE+100H
;
START	LD	SP,START
	LD	A,(HL)
	CP	CR
	JP	Z,USAGE
	OR	A
	JP	Z,USAGE
;
;decide whether string is quoted or not.
	LD	A,' '
	LD	(EOS),A
	LD	A,(HL)
	CP	''''		;single quote
	JR	NZ,SAVE_1
	LD	(EOS),A
	INC	HL
;
;save string.
SAVE_1	LD	DE,STRING
SAVE_2	LD	A,(HL)
	CP	CR
	JP	Z,USAGE		;(no filename).
	OR	A
	JP	Z,USAGE
	CP	'\'
	JR	NZ,SAVE_3
	INC	HL
	LD	A,(HL)
	INC	HL
	CP	CR
	JR	Z,USAGE		;\<CR> no filename.
	OR	A
	JR	Z,USAGE
	LD	(DE),A
	INC	DE
	JR	SAVE_2
SAVE_3
	LD	B,A
	LD	A,(EOS)
	CP	B
	JR	Z,SAVE_6	;string got.
;
	LD	A,B
	LD	(DE),A
	INC	DE
	INC	HL
	JR	SAVE_2
;
SAVE_6				;string finished.
	XOR	A
	LD	(DE),A
SAVE_7	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,SAVE_7
	CP	CR
	JR	Z,USAGE		;still no filename.
	OR	A
	JR	Z,USAGE
;
	LD	DE,FCB_IN_NAME
	LD	B,23		;nchars in filespec.
MOVE_1	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	CP	CR
	JR	Z,MOVE_2
	OR	A
	JR	Z,MOVE_2
	CP	' '
	JR	Z,MOVE_2
	DJNZ	MOVE_1		;ensure valid length.
	JR	USAGE		;filename too long.
MOVE_2
	DEC	DE
	XOR	A		;terminate string
	LD	(DE),A
;
;Extract filespec.
	LD	HL,FCB_IN_NAME
	LD	DE,FCB_IN
	CALL	EXTRACT
	LD	A,130		;can't extract
	JR	NZ,FILE_ERROR
;Now try to open file.
	LD	HL,BUFF_IN
	LD	DE,FCB_IN
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	Z,OPEN_1
;
;print open error message.
FILE_ERROR
	PUSH	AF
	LD	HL,M_GREP
	LD	DE,$2
	CALL	MESS_0
	LD	HL,FCB_IN_NAME
	CALL	MESS_0
	LD	A,':'
	CALL	$PUT
	LD	A,' '
	CALL	$PUT
	POP	AF
	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	TERMINATE
;
;
USAGE
	LD	HL,M_USAGE
	LD	DE,$2
	CALL	MESS_0
	LD	A,1
	JP	TERMINATE
;
OPEN_1
				;setup pointers.
	LD	HL,BIG_BUFF
	LD	(NEXT_PTR),HL
	LD	(LAST_PTR),HL
	XOR	A
	LD	(ERROR_CODE),A
;
NEXT_LINE
	CALL	READ_LINE	;read a line of the file
	JR	Z,NEXT_1
	CP	1CH
	JR	NZ,FILE_ERROR
;end!
	LD	A,0
	JP	TERMINATE
;
NEXT_1
	LD	HL,LINE_BUFF
COMP_1
	LD	DE,STRING
COMP_2
	LD	A,(HL)
	OR	A
	JR	Z,NEXT_LINE	;not found!
	CALL	CI_CMP
	JR	Z,COMP_3
	INC	HL
	JR	COMP_2
COMP_3
	PUSH	HL
COMP_4
	INC	HL
	INC	DE
	LD	A,(DE)
	OR	A
	JR	Z,FOUND
	CALL	CI_CMP
	JR	Z,COMP_4
	POP	HL
	INC	HL
	JR	COMP_1
;
FOUND
	POP	HL
	LD	HL,LINE_BUFF
	LD	DE,$2
FOUN_1	LD	A,(HL)
	OR	A
	JR	Z,FOUN_4
	CP	' '
	JR	C,FOUN_2
	CP	80H
	JR	C,FOUN_3
	JR	FOUN_3
FOUN_2	LD	A,'.'
FOUN_3
	CALL	STD_OUT
	INC	HL
	JR	FOUN_1
FOUN_4	LD	A,CR
	CALL	STD_OUT
	JR	NEXT_LINE
;
;
READ_LINE
	LD	HL,LINE_BUFF
	LD	B,0		;256
RL_1	PUSH	HL
	PUSH	BC
	CALL	READ_CHAR
	POP	BC
	POP	HL
	JR	NZ,RL_4
	CP	CR
	JR	Z,RL_3
	CP	LF
	JR	Z,RL_3
	OR	A
	JR	NZ,RL_2
	LD	A,1		;stop putting 00 in
				;line buffer.
RL_2
	LD	(HL),A
	INC	HL
	DJNZ	RL_1		;after 256 assume eol.
RL_3	LD	(HL),0
	CP	A
	RET
;
RL_4	RET
;above is error if you want to be able to get the
;contents of a partial last line of the file.
;
;
READ_CHAR
	LD	HL,(NEXT_PTR)
	LD	DE,(LAST_PTR)
	OR	A
	SBC	HL,DE
	LD	A,H
	OR	L
	JR	Z,READ_1
	LD	HL,(NEXT_PTR)
	LD	A,(HL)
	INC	HL
	LD	(NEXT_PTR),HL
	CP	A
	RET
READ_1
	LD	A,(ERROR_CODE)
	OR	A
	RET	NZ
	LD	HL,BIG_BUFF
	LD	(LAST_PTR),HL
	LD	B,16		;4096 bytes.
READ_2
	LD	DE,FCB_IN
	CALL	DOS_READ_SECT
	JR	NZ,READ_4
;compare next <--> eof fields.
	LD	HL,(FCB_IN+10)	;next
	LD	DE,(FCB_IN+12)	;eof
	OR	A
	SBC	HL,DE
	JR	NZ,READ_2A1	;c=if next < eof
	LD	A,(FCB_IN+8)	;low eof
	LD	D,A
	LD	A,(FCB_IN+5)	;low next
	CP	D
READ_2A1
	JR	C,READ_2B
;next >= eof so therefore must have reached end.
	LD	A,1CH
	LD	(ERROR_CODE),A
	LD	A,(FCB_IN+8)	;=count of valid bytes (eof)
	JR	READ_2C
READ_2B
	LD	A,(FCB_IN+5)	;low next
READ_2C
	PUSH	BC
	LD	DE,BUFF_IN
	LD	HL,(LAST_PTR)
	LD	B,A
READ_2A	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	DJNZ	READ_2A
	LD	(LAST_PTR),HL
	POP	BC
	LD	A,(ERROR_CODE)
	OR	A
	JR	NZ,READ_3
	DJNZ	READ_2
READ_3
	LD	HL,BIG_BUFF
	LD	(NEXT_PTR),HL
	JP	READ_CHAR	;gotta do it again!
;
READ_4
	CP	1CH
	JR	Z,READ_4B
	CP	1DH
	JR	Z,READ_4B
	LD	(ERROR_CODE),A
	JR	READ_3
READ_4B
	LD	A,1
	LD	(ERROR_CODE),A
	JR	READ_3
;
;
*GET	ROUTINES
;
EOS		DEFB	0
ERROR_CODE	DEFB	0
LAST_PTR	DEFW	0
NEXT_PTR	DEFW	0
;
FCB_IN_NAME	DEFS	32
FCB_IN		DEFS	32
BUFF_IN		DEFS	256
;
M_GREP		DEFM	'grep: ',0
M_USAGE
	DEFM	'Grep: Search for a string within a file',CR
	DEFM	'Usage: GREP  string  filename',CR
	DEFM	'Eg:    GREP  ''unix'' filelist.zms',CR,0
;
STRING		DEFS	80
;
LINE_BUFF	DEFS	257
;
BIG_BUFF	DEFS	4096
;
THIS_PROG_END	EQU	$
	END	START
