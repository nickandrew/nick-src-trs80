; @(#) help.asm - Mediocre user help program
;
;1.5j	11 Sep 89
;	Fix crashing when doing such as 'help fidonet'
;1.5i	07 May 89
;	Add - more - option & base version
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
	COM	'<Help 1.5j 11-Sep-89>'
	ORG	BASE+100H
START	LD	SP,START
;
	PUSH	HL
	CALL	INIT_MORE
	POP	HL
;
	LD	A,(HL)
	CP	CR
	JR	Z,NO_NAME
	OR	A
	JR	Z,NO_NAME
;
	CALL	NAME_XLATE
;
NO_NAME
	PUSH	HL
	CALL	SIGNON
	POP	HL
	CALL	DEFAULT
;
HELP_LOOP
	XOR	A
	LD	(SCRDONE),A
	LD	(RB_STATE),A	;Set command state
	CALL	MOREPIPE
	LD	A,(RB_STATE)
	OR	A
	JR	NZ,IGNORE	;If no longer in command state, ignore
CONTROL
	LD	A,(RB_SAVED)
	LD	(CTRL),A
	CP	'0'		;0
	JR	Z,FILE_EXIT
	CP	'1'		;1xxText....
	JR	Z,CHOICE
	CP	'2'		;2xxFilename
	JR	Z,SWAPFILE
	CP	'3'		;3xxComment...
	JP	Z,SECTION_ID
	CP	'4'		;4xxComment...
	JR	Z,JUMP
	CP	'5'		;5
	JP	Z,PAUSE
	CP	'6'		;6xxFilename
	JP	Z,JUMPINTO
	CP	CR
	JR	Z,IGN_01	;A null line
;is not a control byte so find a valid control byte
IGNORE
	CALL	READBYTE
	CP	CR
	JR	NZ,IGNORE
IGN_01
	CALL	READBYTE	;Read possible control byte
	LD	(RB_SAVED),A
	JR	CONTROL
;
JUMP
	CALL	READ_SCNM
	CALL	FILE_POSN
	JP	HELP_LOOP
;
FILE_EXIT
	CALL	CLOSE_F
	LD	A,0
	CALL	TERMINATE
;
SWAPFILE
	CALL	READ_SCNM
	CALL	GET_FNAME
	JP	HELP_LOOP
;
JUMPINTO
	CALL	READ_SCNM
	CALL	GET_FNAME
	CALL	FILE_POSN
	JP	HELP_LOOP
;
CHOICE	LD	HL,M_SELECT
	LD	DE,DCB_2O
	CALL	MESS_0
	CALL	Z_PTR
;Read all choices until end of section
NXT_CHOICE
	CALL	INC_NUM
	CALL	READ_SCNM
	CALL	STOR_SCNM
	CALL	PRINT_CHOICE	;Print this choice
	CALL	READBYTE
	CP	'1'
	JR	Z,NXT_CHOICE
;
CH_LOOP
	LD	HL,M_CHOICE
	LD	DE,DCB_2O
	CALL	MESS_0
	CALL	ENTR_NUMB
	JR	NZ,CH_LOOP
	LD	A,(NUM)
	CALL	RETRV_SCNM
	CALL	FILE_POSN
	JP	HELP_LOOP
;
;Bypass the line for a section identifier
SECTION_ID
SI_01
	CALL	READBYTE
	CP	CR
	JR	NZ,SI_01
	JP	HELP_LOOP
;
; Initialise the data and all variables required to use - more -
;
INIT_MORE
	LD	HL,READ_MORE
	LD	(INFUNC),HL
	LD	HL,KEY_MORE
	LD	(KEYFUNC),HL
	XOR	A
	LD	(RB_STATE),A
	LD	(RB_SAVED),A
	RET
;
; Read_more - a read function for more
;
READ_MORE
	LD	HL,RB_STATE
	LD	A,(HL)
	OR	A
	JR	Z,RM_02
;
;Not in control byte state
	CALL	READBYTE
	RET	NZ		;If eof
RM_03
	CP	CR
	JR	NZ,RM_01
	LD	(HL),0		;Set control byte state
RM_01
	CP	A
	RET
;
;In control byte state
RM_02
	LD	(HL),1
	CALL	READBYTE
	LD	(RB_SAVED),A
	RET	NZ
	CALL	IF_NUM
	JR	NZ,RM_03	;Test if CR
	LD	(HL),0
	JP	RET_NZ		;Fool more into thinking end of file
;
RET_Z
	CP	A
	RET
;
RET_NZ
	OR	A
	RET	NZ
	CP	1
	RET
;
; Key_more - a key action function for more
;
KEY_MORE
	AND	5FH
	CP	'?'
	JR	Z,KEY_HELP
	CP	'H'
	JR	Z,KEY_HELP
	XOR	A
	RET
;
KEY_HELP
	LD	HL,M_MOREHELP
	LD	DE,DCB_2O
	CALL	MESS_0
	XOR	A
	RET
;
PAUSE
PA_01	CALL	READBYTE
	JP	NZ,ERROR
	CP	CR
	JR	NZ,PA_01
	LD	HL,M_PAUSE
	LD	DE,DCB_2O
	CALL	MESS_0
;
PA_02	LD	DE,DCB_2I
	CALL	$GET
	CP	1
	JR	Z,PA_04		;Terminate
	CP	3
	JR	Z,PA_04		;Terminate
	CP	CR
	JR	Z,PA_03
	CP	' '
	JR	Z,PA_03
	JR	PA_02
PA_03
	JP	HELP_LOOP
;
PA_04	CALL	CLOSE_F
	XOR	A
	JP	TERMINATE
;
SIGNON
	RET
;
DEFAULT
	LD	HL,F_DEFLT
	CALL	SETFILE
	RET
;
SETFILE
	PUSH	HL
	CALL	CLOSE_F
	POP	HL
	LD	DE,FCB_H
	CALL	EXTRACT
	JP	NZ,OPEN_ERROR
	LD	DE,FCB_H
	LD	HL,HLP
	CALL	DOS_EXTEND
;
	LD	HL,FCB_H
	LD	DE,FCB_COPY
	LD	BC,32
	LDIR
	LD	DE,FCB_H
	LD	HL,BUFF_H
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,OPEN_ERROR
;check if file is proper HELP file
	LD	A,(FCB_H+2)
	BIT	1,A
	RET	NZ
	LD	HL,M_FILBAD
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,1
	JP	TERMINATE
;
OPEN_ERROR
	LD	HL,M_NOTHELP
	LD	DE,DCB_2O
	CALL	MESS_0
	LD	A,1
	JP	TERMINATE
;
FILE_POSN
	LD	A,(CTRL)
	CP	'1'
	JR	Z,CTRL_2	;no rewind if multiple choice
;first rewind FCB.
	LD	DE,FCB_H
	CALL	DOS_REWIND
	JP	NZ,ERROR
;
CTRL_2	CALL	READBYTE
	RET	NZ		;return if EOF...
	CP	'3'		;section id.
	JR	Z,FP_2
;Ignore the rest of the line
FP_1	CP	CR
	JR	Z,CTRL_2
	CALL	READBYTE
	JR	FP_1
;
FP_2	CALL	READBYTE
	LD	E,A
	CALL	READBYTE
	LD	D,A
	LD	A,(SCNM_1)
	LD	L,A
	LD	A,(SCNM_2)
	LD	H,A
	OR	A
	SBC	HL,DE		;2 character compare.
	JR	Z,FP_3		;Section name found
	CALL	READBYTE
	JR	FP_1		;Ignore the rest of the line
;
;found! Ignore the rest of the line.
FP_3	CALL	READBYTE
	CP	CR
	JR	NZ,FP_3
	RET
;
GET_FNAME
	LD	HL,FILE_NAME
GF_1	PUSH	HL
	CALL	READBYTE
	POP	HL
	LD	(HL),A
	INC	HL
	CP	CR
	JR	NZ,GF_1
	LD	HL,FILE_NAME
	CALL	SETFILE
	RET
;
CLOSE_F
	LD	DE,FCB_H
	LD	A,(DE)
	AND	80H
	CALL	NZ,DOS_CLOSE
	JP	NZ,ERROR
	RET
;
READ_SCNM
	CALL	READBYTE
	LD	(SCNM_1),A
	CALL	READBYTE
	LD	(SCNM_2),A
	RET
;
Z_PTR	LD	HL,SCNM_BUFF
	LD	(SCNM_PTR),HL
	XOR	A
	LD	(NUMBER),A
	RET
;
INC_NUM	LD	A,(NUMBER)
	INC	A
	LD	(NUMBER),A
	RET
;
;Store the section name into a table in memory
STOR_SCNM
	LD	HL,(SCNM_PTR)
	LD	A,(SCNM_1)
	LD	(HL),A
	INC	HL
	LD	A,(SCNM_2)
	LD	(HL),A
	INC	HL
	LD	(SCNM_PTR),HL
	RET
;
;Print the description associated with this choice
PRINT_CHOICE
	LD	A,(NUMBER)
	CALL	TO_DEC
	LD	DE,DCB_2O
PC_1	CALL	READBYTE
	PUSH	AF
	CALL	$PUT
	POP	AF
	CP	CR
	JR	NZ,PC_1
	RET
;
;Let the user enter a one-or-two digit number
ENTR_NUMB
	LD	HL,NUM_BUFF
	LD	B,2
	CALL	40H
	LD	A,0
	JP	C,TERMINATE
	JR	EN_2
EN_1	XOR	A
	CP	1
	RET
EN_2	LD	B,0
EN_3	LD	A,(HL)
	CP	CR
	JR	Z,EN_4
	SUB	'0'
	CP	10
	JR	NC,EN_1
	LD	C,A
	LD	A,B
	ADD	A,A
	ADD	A,A
	ADD	A,B
	ADD	A,A
	ADD	A,C
	LD	B,A
	INC	HL
	JR	EN_3
EN_4	LD	A,B
	CP	0
	JR	Z,EN_1
	LD	A,(NUMBER)
	CP	B
	JR	C,EN_1
	LD	A,B
	LD	(NUM),A
	CP	A
	RET
;
RETRV_SCNM
	DEC	A
	ADD	A,A
	LD	C,A
	LD	B,0
	LD	HL,SCNM_BUFF
	ADD	HL,BC
	LD	A,(HL)
	LD	(SCNM_1),A
	INC	HL
	LD	A,(HL)
	LD	(SCNM_2),A
	RET
;
TO_DEC
	LD	B,A
TD_1	XOR	A
	LD	(FLAG),A
	LD	C,100
	CALL	DEC_1
	LD	C,10
	CALL	DEC_1
	LD	A,1
	LD	(FLAG),A
	LD	C,1
	CALL	DEC_1
	LD	HL,M_COLON
	LD	DE,DCB_2O
	CALL	MESS_0
	RET
;
DEC_1	LD	A,B
	LD	D,'0'-1
D1_1	INC	D
	SUB	C
	JR	NC,D1_1
	ADD	A,C
	LD	B,A
	LD	A,D
	CP	'0'
	JR	NZ,D1_3
	LD	A,(FLAG)
	OR	A
	JR	NZ,D1_2
	LD	D,' '
D1_2	PUSH	BC
	LD	A,D
	LD	DE,DCB_2O
	CALL	$PUT
	POP	BC
	RET
D1_3	LD	A,1
	LD	(FLAG),A
	JR	D1_2
;
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	LD	HL,M_SORRY
	LD	DE,DCB_2O
	CALL	MESS_0
;
	LD	HL,M_ERROR
	CALL	LOG_MSG
	POP	AF
	CALL	PRINT_DEC	;Sorry, boss!
	LD	HL,FCB_COPY
	CALL	LOG_MSG
;
	LD	DE,FCB_H
	LD	A,(DE)
	AND	80H
	CALL	NZ,DOS_CLOSE
	LD	A,1
	JP	TERMINATE
;
PRINT_DEC
	LD	H,'0'-1
PD_1	INC	H
	SUB	10
	JR	NC,PD_1
	ADD	A,10
	ADD	A,'0'
	PUSH	AF
	LD	A,H
	LD	(LOG_DEC_1),A
	POP	AF
	LD	(LOG_DEC_2),A
	LD	HL,LOG_DEC
	CALL	LOG_MSG
	RET
;
NAME_XLATE
	LD	(SAVED_NAME),HL
	LD	DE,XLATE_TABLE
XLATE_LOOP
	LD	A,(DE)
	OR	A
	JR	Z,NO_XLATE		;If end of table
;
	LD	HL,(SAVED_NAME)
	CALL	STR_CI_CMP_CR
	JR	Z,DO_XLATE
;Upon leaving the routine, DE can be on the 0 byte, or before it.
;
;Bypass the 0 byte
XL_01	LD	A,(DE)
	INC	DE
	OR	A
	JR	NZ,XL_01
;
;Bypass the 'goto' string
XL_02	LD	A,(DE)
	INC	DE
	OR	A
	JR	NZ,XL_02
;
	JR	XLATE_LOOP
;
NO_XLATE
	LD	HL,(SAVED_NAME)
	RET
;
DO_XLATE
;Bypass the rest of the source string (impossible!)
XL_03
	LD	A,(DE)
	INC	DE
	OR	A
	JR	NZ,XL_03
;
	LD	A,(DE)
	LD	(SCNM_1),A
	INC	DE
	LD	A,(DE)
	LD	(SCNM_2),A
	INC	DE
	EX	DE,HL
	CALL	SETFILE		;Open the appropriate file
	CALL	FILE_POSN
	JP	HELP_LOOP	;I hope!
;
STR_CI_CMP_CR
	LD	A,(DE)
	OR	A
	JR	Z,POSS_COMPARE	;End of table string, maybe equal
	CALL	CI_CMP		;(hl) to (de)
	RET	NZ
	INC	HL
	INC	DE
	JR	STR_CI_CMP_CR
POSS_COMPARE
	LD	A,(HL)
	CP	' '
	RET	Z
	OR	A
	RET	Z
	CP	CR
	RET	;z or nz
;
;Read one byte from the file. Return NZ on EOF (and A = '0')
;
READBYTE
	PUSH	DE
	LD	DE,FCB_H
	CALL	$GET
	POP	DE
	RET	Z
;error. Must be 1ch or 1dh
	CP	1CH
	JR	Z,RB_EOF
	CP	1DH
	JP	NZ,ERROR
RB_EOF	LD	A,'0'
	OR	A		;Set NZ flag
	RET
;
*GET	MOREPIPE	;Pagination routine
*GET	ROUTINES	;Other routines
;
;data follows.
;
SAVED_NAME	DEFW	0
;
XLATE_TABLE
;First generic names & random things people will type
	DEFM	'acsnet',0,'STnetwork',ETX,0
	DEFM	'fidonet',0,'STnetwork',ETX,0
	DEFM	'file',0,'STxfer',ETX,0
	DEFM	'transfer',0,'STxfer',ETX,0
	DEFM	'upload',0,'STxfer',ETX,0
	DEFM	'usenet',0,'STnetwork',ETX,0
	DEFM	'zeta',0,'STdefault',ETX,0
;Then the names of real commands & help files
	DEFM	'addlf',0,'A1commands',ETX,0
	DEFM	'bb',0,'STbb.hlp',ETX,0
	DEFM	'bye',0,'STbye.hlp',ETX,0
	DEFM	'capture',0,'STcapture.hlp',ETX,0
	DEFM	'cat',0,'A2commands',ETX,0
	DEFM	'chat',0,'A1command2',ETX,0
	DEFM	'cmds',0,'STcmds.hlp',ETX,0
	DEFM	'command2',0,'STcommand2.hlp',ETX,0
	DEFM	'commands',0,'STcommands.hlp',ETX,0
	DEFM	'comment',0,'A3commands',ETX,0
	DEFM	'date',0,'A2command2',ETX,0
	DEFM	'default',0,'STdefault.hlp',ETX,0
	DEFM	'dir',0,'STdir.hlp',ETX,0
	DEFM	'dirall',0,'A3command2',ETX,0
	DEFM	'echo',0,'STecho.hlp',ETX,0
	DEFM	'formats',0,'STformats.hlp',ETX,0
	DEFM	'free',0,'A5commands',ETX,0
	DEFM	'grep',0,'STgrep.hlp',ETX,0
	DEFM	'help',0,'A5command2',ETX,0
	DEFM	'id',0,'A6command2',ETX,0
	DEFM	'join',0,'STjoin.hlp',ETX,0
	DEFM	'list',0,'A6commands',ETX,0
	DEFM	'logout',0,'STlogout.hlp',ETX,0
	DEFM	'ls',0,'STls.hlp',ETX,0
	DEFM	'mail',0,'STmail.hlp',ETX,0
	DEFM	'menu',0,'A9command2',ETX,0
	DEFM	'misc',0,'STmisc.hlp',ETX,0
	DEFM	'more',0,'STdefault',ETX,0
	DEFM	'network',0,'STnetwork.hlp',ETX,0
	DEFM	'passwd',0,'B0command2',ETX,0
	DEFM	'rm',0,'STrm.hlp',ETX,0
	DEFM	'scrub',0,'STscrub.hlp',ETX,0
	DEFM	'shell',0,'STshell.hlp',ETX,0
	DEFM	'stty',0,'STstty.hlp',ETX,0
	DEFM	'survey',0,'STdefault',ETX,0
	DEFM	'upgrades',0,'STupgrades.hlp',ETX,0
	DEFM	'userlist',0,'B2command2',ETX,0
	DEFM	'wisdom',0,'STdefault',ETX,0
	DEFM	'xfer',0,'STxfer.hlp',ETX,0
	DEFM	'xmodem',0,'STxmodem.hlp',ETX,0
;
	DEFM	0
;
M_NOTHELP	DEFM	'Help subject not found, sorry.',CR
		DEFM	'Type "HELP" for general help information.',CR,0
;
M_COLON		DEFM	': ',0
;
M_FILBAD	DEFM	'Requested file not a proper HELP format file!',CR,0
;
M_PAUSE		DEFM	'- enter -',CR,0
M_SELECT	DEFM	CR,0
M_CHOICE	DEFM	CR,'Help # ',0
M_HELP		DEFM	CR,CR,0
M_SORRY		DEFM	'Sorry about that!',CR,0
M_ERROR		DEFM	'(HELP) Error # ',0
M_MOREHELP
	DEFM	CR,'The following keys are accepted:',CR,CR
	DEFM	'  <space>     Display the next page of text',CR
	DEFM	'  <enter>     Display another line of text',CR
	DEFM	'     Q        Quit',CR
	DEFM	'     ?        Print this help message',CR,CR,0
;
CTRL		DEFB	0
CHAR		DEFB	0
NUM		DEFB	0
SCNM_1		DEFB	0
SCNM_2		DEFB	0
NUMBER		DEFB	0
FLAG		DEFB	0
SCNM_PTR	DEFW	0
RB_STATE	DEFB	0	;0 = column 1, 1 = not column 1
RB_SAVED	DEFB	0	;Saved control byte
;
FCB_H		DC	32,0
FCB_COPY	DC	32,0
BUFF_H		DC	256,0
FILE_NAME	DC	16,0
NUM_BUFF	DC	5,0
;
F_DEFLT		DEFM	'DEFAULT',CR
HLP		DEFM	'HLP'
;
LOG_DEC
LOG_DEC_1	DEFB	'x'
LOG_DEC_2	DEFB	'x'
		DEFM	'. In file ',CR,0
;
SCNM_BUFF
	DEFS	1024
	NOP
;
THIS_PROG_END	EQU	$
;
	END	START
