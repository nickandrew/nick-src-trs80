;DIRECT: Add, List, and Unpack directories.
;
;********************************************************
;* Direct.asm:  Source code for DIRECT.                 *
;* Environment: Zeta.					*
;* Other files required:                                *
;*       DIRECT.DOC       Documentation for DIRECT      *
;*       DOSCALLS.ASM     Dos routines definition.      *
;*                                                      *
;* Version:     1.3, 09-Aug-86                          *
;* Assembler:   Nedas.                                  *
;* Program:     (C) 1986 by Zeta Microcomputer Software *
;*              Released into public domain 11-Mar-86   *
;*  If you like this program and you are an honest      *
;* person then you may consider sending a donation to   *
;* the author at P.O Box 177, Riverstone NSW 2765.      *
;* Recommended amount: $5                               *
;*                                                      *
;* This program is compatible with DIRECT.C for Unix.   *
;********************************************************
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
	COM	'<Direct - directory file processor>'
	COM	'<Version 1.3a of 22-Oct-86>'
	COM	'<Zeta>'
;
	ORG	BASE+100H
;
START	LD	SP,START
MAIN	CALL	PROMPT
	LD	HL,IN_BUFF
	LD	A,(HL)
	CALL	TO_UPPER
	CP	'S'		;Set directory name
	JP	Z,SET_DIR
	CP	'X'		;Exit
	JP	Z,EXIT
	CP	'L'		;List contents
	JP	Z,LIST_DIR
	CP	'A'		;Add file
	JP	Z,ADD_DIR
	CP	'E'		;Extract file
	JP	Z,EXT_DIR
	CP	':'		;Doscall escape.
	JP	Z,CALL_DOS
	CP	'!'		;Doscall escape.
	JP	Z,CALL_DOS
;Unknown command.
BAD_CMD
	LD	HL,M_BADCMD
	CALL	MESS
	JR	MAIN
;
USAGE	LD	HL,M_USAGE
	CALL	MESS
	JR	MAIN
;
BAD_ERROR
	OR	80H
	CALL	DOS_ERROR
	JR	START
;
CALL_DOS
	CALL	NEXT_SPACE
	CALL	CALL_PROG
	JP	MAIN
;
NEXT_SPACE
	INC	HL
	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	LD	A,(HL)
	RET
;
MESS	LD	A,(HL)
	OR	A
	RET	Z
	CALL	PUTCHAR
	INC	HL
	JR	MESS
;
PUTCHAR
	LD	DE,($STDOUT_DEF)
	CALL	ROM@PUT
	RET
;
TO_UPPER
	CP	'a'
	RET	C
	CP	'z'+1
	RET	NC
	AND	5FH
	RET
;
PROMPT	LD	HL,M_PROMPT
	CALL	MESS
	LD	HL,IN_BUFF
	LD	B,60
	CALL	ROM@WAIT_LINE
	JP	C,EXIT
	CALL	STR_CLEAN
	RET
;
STR_CLEAN
	PUSH	HL
	PUSH	HL
	POP	DE
;eliminate leading blanks..
SC_1	LD	A,(HL)
	CP	' '
	INC	HL
	JR	Z,SC_1
	LD	(DE),A
	INC	DE
	CP	CR
	JR	Z,SC_4
SC_2	LD	A,(HL)
	CP	CR
	JR	Z,SC_4
	CP	' '
	JR	Z,SC_3
	LD	(DE),A
	INC	HL
	INC	DE
	JR	SC_2
SC_3	LD	(DE),A
	INC	HL
	INC	DE
	JR	SC_1
SC_4	LD	(DE),A
	DEC	DE
	POP	HL
	LD	A,(DE)
	CP	' '
	RET	NZ
	LD	A,CR
	LD	(DE),A
	RET
;
SET_DIR
	CALL	NEXT_SPACE
	JP	NZ,USAGE
	PUSH	HL
	LD	A,(IS_OPEN)
	OR	A
	CALL	NZ,CLOSE_DIR
	POP	HL
	LD	DE,DIRECTORY
	CALL	DOS_EXTRACT
	JP	NZ,USAGE
	CALL	OPEN_DIR	;Open DIR & DAT files
	JR	NZ,NEW_DIR
	JP	MAIN
;
NEW_DIR
	CP	18H		;File not in directory.
	JP	NZ,BAD_ERROR
;
	LD	HL,M_NONEX
	CALL	MESS
;
;If not SYSOP then jump to main.
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JP	Z,MAIN
;
	LD	HL,M_CREA
	CALL	ASK
	CP	'Y'
	JP	NZ,MAIN
;create new...
	CALL	CREATE_DIR
	JP	NZ,BAD_ERROR
	JP	MAIN
;
;Open XX.DIR and XX.DAT files...
OPEN_DIR
	LD	HL,DIRECTORY
OD_0A	LD	A,(HL)
	OR	A
	JR	Z,OD_0C
	CP	ETX
	JR	Z,OD_0C
	CP	CR
	JR	Z,OD_0C
	CP	'.'
	JR	Z,OD_0B
	INC	HL
	JR	OD_0A
OD_0B	LD	HL,M_NODOT
	CALL	MESS
	JP	MAIN
OD_0C
	LD	HL,DIRECTORY
	LD	DE,DIR_DIR
	CALL	DOS_EXTRACT
	RET	NZ
	LD	HL,TXT_DIR
	CALL	DOS_EXTEND
;
	LD	HL,DIRECTORY
	LD	DE,DIR_DAT
	CALL	DOS_EXTRACT
	RET	NZ
	LD	HL,TXT_DAT
	CALL	DOS_EXTEND
;
	LD	HL,BUFF_DIR
	LD	DE,DIR_DIR
	LD	B,64
	CALL	DOS_OPEN_EX
	RET	NZ
	LD	HL,BUFF_DAT
	LD	DE,DIR_DAT
	LD	B,0
	CALL	DOS_OPEN_EX
	RET	NZ
	LD	A,1
	LD	(IS_OPEN),A
	RET
;
BUFF_DIR
	DEFS	256
BUFF_DAT
	DEFS	256
BUFF_FILE
	DEFS	256
DIRECTORY
	DEFS	32
DIR_DIR
	DEFS	32
DIR_DAT
	DEFS	32
FILE
	DEFS	32
;
BUFF2_DIR
D_FNAME	DC	16,0
D_START	DEFB	0,0,0
D_EOF	DEFB	0,0,0
D_DESCR	DC	42,0
;
IN_BUFF
	DEFS	64
M_BADCMD
	DEFM	'Bad command. Use S,A,X,E,L,!',CR,0
;
M_USAGE	DEFM	CR,'Command usage is:',CR
	DEFM	'<Set>:     S  filename',CR
	DEFM	'<Add>:     A  mach-file dir-file',CR
	DEFM	'<Extract>: E  dir-file',CR
	DEFM	'<Exit>:    X',CR
	DEFM	'<List>:    L',CR
	DEFM	'<Escape>:  !command',CR,CR,0
;
M_PROMPT
	DEFM	'Direct 1.3 >',0
M_NONEX
	DEFM	'DIRECTory file non-existant!',CR,0
M_CREA	DEFM	'Create it? ',0
M_WHERE	DEFM	'Write to which file? ',0
;
TXT_DIR	DEFM	'DIR'
TXT_DAT	DEFM	'DAT'
;
EXIT
	CALL	CLOSE_DIR
	XOR	A
	JP	TERMINATE
;
CLOSE_DIR
	LD	A,(IS_OPEN)
	OR	A
	RET	Z
	LD	DE,DIR_DIR
	CALL	DOS_CLOSE
	JP	NZ,BAD_ERROR
	LD	DE,DIR_DAT
	CALL	DOS_CLOSE
	JP	NZ,BAD_ERROR
	LD	A,0
	LD	(IS_OPEN),A
	RET
;
ASK
	LD	(ASK_ADD),HL
ASK_1	LD	HL,(ASK_ADD)
	CALL	MESS
	LD	HL,ASK_BUFF
	LD	B,3
	CALL	ROM@WAIT_LINE
	JR	C,ASK_1
	LD	A,(HL)
	AND	5FH
	RET
;
ASK_ADD	DEFW	0
STR_1	DEFW	0
;
ASK_BUFF
	DEFS	4
;
CREATE_DIR
	LD	DE,DIR_DIR
	LD	HL,BUFF_DIR
	LD	B,64
	CALL	DOS_OPEN_NEW
	RET	NZ
	LD	DE,DIR_DAT
	LD	HL,BUFF_DAT
	LD	B,0
	CALL	DOS_OPEN_NEW
	RET	NZ
	LD	A,1
	LD	(IS_OPEN),A
;Setup 1st (dummy) self-referential entry.
	LD	HL,DUMMY_RECD
	LD	DE,BUFF2_DIR
	LD	BC,64
	LDIR
	LD	HL,DUMMY_NAME
	LD	DE,BUFF2_DIR
	LD	BC,16
	LDIR
;Ask for description...
CD_1	LD	HL,M_DESC
	CALL	MESS
	LD	HL,D_DESCR
	LD	B,40
	CALL	ROM@WAIT_LINE
	JP	C,CD_1
;Write record...
	LD	DE,DIR_DIR
	LD	HL,BUFF2_DIR
	CALL	DOS_WRIT_SECT
	JP	NZ,BAD_ERROR
	RET
;
DUMMY_RECD
	DC	16,' '
	DEFB	0,0,0
	DEFB	0,0,0
	DC	42,' '
;
DUMMY_NAME
	DEFM	'this_dir        '
;
IS_OPEN	DEFB	0
M_DESC	DEFM	'Description? ',0
;
LIST_DIR
	LD	A,(IS_OPEN)
	OR	A
	JP	Z,NOT_OPEN
	LD	DE,DIR_DIR
	CALL	DOS_REWIND
	JP	NZ,BAD_ERROR
;Loop.
LD_1	LD	DE,DIR_DIR
	LD	HL,BUFF2_DIR
	CALL	DOS_READ_SECT
	JR	Z,LD_2
	CP	1CH
	JP	Z,MAIN
	CP	1DH
	JP	Z,MAIN
	JP	BAD_ERROR
LD_2
	LD	HL,D_FNAME
	LD	DE,DIRL_FN
	LD	BC,16
	LDIR
	LD	HL,D_DESCR
	LD	DE,DIRL_DE
	LD	BC,42
	LDIR
	LD	HL,DIRLIST
LD_3	LD	A,(HL)
	CP	ETX
	RET	Z
	CALL	ROM@PUT_VDU
	LD	A,(HL)
	INC	HL
	CP	CR
	JR	NZ,LD_3
	JR	LD_1
;
DIRLIST
DIRL_FN	DC	16,0
	DEFM	' : '
DIRL_DE	DC	42,0
	DEFB	CR,ETX
;
ADD_DIR
;
;If not sysop then don't allow it.
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JP	Z,SYSOP_ONLY
;
	LD	A,(IS_OPEN)
	OR	A
	JP	Z,NOT_OPEN
;
	CALL	NEXT_SPACE
	PUSH	HL
	LD	DE,FILE
	CALL	DOS_EXTRACT
	JP	NZ,USAGE
	PUSH	HL
	LD	HL,BUFF_FILE
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,BAD_ERROR
;create new entry.
	LD	DE,DIR_DIR
	CALL	DOS_POS_EOF
	JP	NZ,BAD_ERROR
;move dummy record.
	LD	HL,DUMMY_RECD
	LD	DE,BUFF2_DIR
	LD	BC,64
	LDIR
;Move in name..
	POP	HL
	LD	A,(HL)
	CP	CR
	JR	NZ,AD_1
	POP	HL
	JR	AD_2
AD_1	POP	IY
AD_2
	LD	DE,D_FNAME
AD_3	LD	A,(HL)
	CP	CR
	JR	Z,AD_4
	CP	' '
	JR	Z,AD_4
	LD	(DE),A
	INC	HL
	INC	DE
	JR	AD_3
AD_4
;Get description....
	LD	HL,M_DESC
	CALL	MESS
	LD	HL,D_DESCR
	LD	B,40
	CALL	ROM@WAIT_LINE
	JR	C,AD_4
;
;Posn DAT file to eof. Record EOF.
	LD	DE,DIR_DAT
	CALL	DOS_POS_EOF
	LD	A,(DIR_DAT+8)
	LD	(D_START+0),A
	LD	A,(DIR_DAT+12)
	LD	(D_START+1),A
	LD	A,(DIR_DAT+13)
	LD	(D_START+2),A
;
;Get EOF of file to add. Record.
	LD	A,(FILE+8)
	LD	(D_EOF+0),A
	LD	A,(FILE+12)
	LD	(D_EOF+1),A
	LD	A,(FILE+13)
	LD	(D_EOF+2),A
;OK write DIR file record...
	LD	DE,DIR_DIR
	LD	HL,BUFF2_DIR
	CALL	DOS_WRIT_SECT
	JP	NZ,BAD_ERROR
;
;
;Assume that stuff above is correct. Write file
;byte by byte to DAT file.
AD_5	LD	DE,FILE
	CALL	ROM@GET		;**** Patch Place ****
	JR	NZ,AD_6
	LD	DE,DIR_DAT
	CALL	ROM@PUT
	JP	NZ,BAD_ERROR
	JR	AD_5
AD_6	CP	1CH
	JR	Z,AD_7
	CP	1DH
	JR	Z,AD_7
	JP	BAD_ERROR
AD_7	JP	MAIN
;
EXT_DIR
;Extract...
	LD	A,(IS_OPEN)
	OR	A
	JP	Z,NOT_OPEN
;
	CALL	NEXT_SPACE
	JP	NZ,USAGE
	LD	(STR_1),HL
	LD	DE,DIR_DIR
	CALL	DOS_REWIND
	JP	NZ,BAD_ERROR
;
ED_1	LD	DE,DIR_DIR
	LD	HL,BUFF2_DIR
	CALL	DOS_READ_SECT
	JR	Z,ED_2
	CP	1CH
	JP	Z,MAIN
	CP	1DH
	JP	Z,MAIN
	JP	BAD_ERROR
ED_2	LD	HL,(STR_1)
	LD	DE,D_FNAME
	EX	DE,HL
	LD	B,16
ED_3	LD	A,(DE)
	CP	CR
	JR	Z,ED_3A
	CP	(HL)
	JR	NZ,ED_1
	INC	HL
	INC	DE
	DJNZ	ED_3
	JR	ED_4
;
ED_3A	LD	A,(HL)
	CP	' '
	JR	NZ,ED_1
;Found! Where to, lady?
ED_4
;If sysop then ask where ... else put to 'TEMPFILE'.
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JR	NZ,ED_4A
;
;Use TEMPFILE instead....
	LD	HL,M_TOTEMP
	CALL	MESS
	LD	HL,TEMPFILE
	JR	ED_4B
;
ED_4A
	LD	HL,M_WHERE
	CALL	MESS
	LD	HL,IN_BUFF
	LD	B,20
	CALL	ROM@WAIT_LINE
	JR	C,ED_4
	LD	HL,IN_BUFF
ED_4B
	LD	DE,FILE
	CALL	DOS_EXTRACT
	JP	NZ,BAD_ERROR
;Open
	LD	HL,BUFF_FILE
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,BAD_ERROR
;Set buffer pointer to the start of the buffer.
	LD	HL,START_BUFFER
	LD	(OUT_POS),HL
;
;Position DAT file.
	LD	A,(D_START+0)
	LD	C,A
	LD	A,(D_START+1)
	LD	L,A
	LD	A,(D_START+2)
	LD	H,A
	LD	DE,DIR_DAT
	CALL	DOS_POS_RBA
	JP	NZ,BAD_ERROR
;Setup byte count.
	LD	A,(D_EOF+0)
	LD	C,A
	LD	A,(D_EOF+1)
	LD	L,A
	LD	A,(D_EOF+2)
	LD	H,A
;Loop.
ED_5	LD	A,H
	OR	L
	OR	C
	JR	Z,ED_7
	DEC	C
	LD	A,C
	CP	255
	JR	NZ,ED_6
	DEC	HL
ED_6	LD	DE,DIR_DAT
	CALL	ROM@GET		;**** Patch Place ****
	JP	NZ,BAD_ERROR
	PUSH	HL
	PUSH	BC
	CALL	OUTPUT_FILE
	POP	BC
	POP	HL
	JP	NZ,BAD_ERROR
	JR	ED_5
ED_7
	CALL	OUTPUT_FLUSH
	LD	DE,FILE
	CALL	DOS_CLOSE
	JP	NZ,BAD_ERROR
	JP	MAIN
;
NOT_OPEN
	LD	HL,M_NOTOPEN
	CALL	MESS
	JP	MAIN
;
OUTPUT_FILE
	PUSH	AF
	LD	HL,(OUT_POS)
	LD	DE,END_BUFFER
	OR	A
	SBC	HL,DE
	CALL	Z,OUTPUT_FLUSH
	LD	HL,(OUT_POS)
	POP	AF
	LD	(HL),A
	INC	HL
	LD	(OUT_POS),HL
	CP	A
	RET
;
OUTPUT_FLUSH
	LD	HL,START_BUFFER
OF_1	PUSH	HL
	LD	DE,(OUT_POS)
	OR	A
	SBC	HL,DE
	POP	HL
	JR	Z,OF_2
	LD	A,(HL)
	LD	DE,FILE
	INC	HL
	CALL	ROM@PUT
	JR	Z,OF_1
	JP	BAD_ERROR
OF_2	LD	HL,START_BUFFER
	LD	(OUT_POS),HL
	CP	A
	RET
;
SYSOP_ONLY
	LD	HL,M_NOTSYSOP
	CALL	MESS
	JP	MAIN
;
*GET	ROUTINES
;
M_TOTEMP
	DEFM	'Extracting desired file to real filename "TEMPFILE".',CR,0
TEMPFILE
	DEFM	'TEMPFILE',CR,0
M_NOTSYSOP
	DEFM	'Sorry... only the Sysop can (currently)',CR,0
M_NOTOPEN
	DEFM	'File not open. <S>et a file first.',CR,0
M_NODOT
	DEFM	'No filename extension is allowed or required.',CR,0
;
OUT_POS	DEFW	START_BUFFER
START_BUFFER	DEFW	0
THIS_PROG_END	EQU	$
END_BUFFER	EQU	START_BUFFER+1000H
;
	END	START
