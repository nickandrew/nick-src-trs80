;Xfer: Simple way to up- or down-load.
;
; 1.3g 11 Jun 90
;	Changed names of catalogues
; 1.3f 15 Apr 90
;	Base version
;	
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	CLEAN_END
	DEFW	CLEAN_END
;End of program load info.
;
	COM	'<Xfer 1.3g 11 Jun 90>'
;
	ORG	BASE+100H
START	LD	SP,START
;
	LD	A,(OUTPUT_MODE)
	LD	(OLD_MODE),A
;
MAIN
	LD	A,(PRIV_2)
	LD	HL,M_HELP1
	BIT	IS_VISITOR,A
	CALL	Z,MESS		;If not a visitor
;
	LD	HL,M_HELP2
	CALL	MESS
COMMAND
	LD	HL,M_PROMPT1
	CALL	GET_INPUT
	JR	C,COMMAND
;
	LD	HL,CMD_TABLE
	CALL	TAB_SRCH
	JR	Z,MAIN
	JP	(HL)
;
CATALOGUE
	LD	HL,M_CATMENU
	CALL	MESS
CA_01
	LD	HL,M_PROMPT2
	CALL	GET_INPUT
	JR	C,CA_01
	CP	CR
	JR	Z,CA_01
	CP	'/'
	JP	Z,MAIN
;
	LD	HL,CAT_TABLE
	CALL	TAB_SRCH
	JR	Z,CATALOGUE
;
	PUSH	HL
	LD	HL,XM_SEND
	LD	DE,CMD_OUT
	CALL	STRCPY
	POP	HL
	CALL	STRCAT
;
	LD	HL,CMD_OUT
	CALL	CALL_PROG
	JP	CATALOGUE
;
DOWNLOAD
	CALL	CHK_VIS
	LD	HL,M_DOWN
	CALL	MESS
	CALL	GET_FILENAME
	LD	HL,FILE_BUFF
	LD	DE,FCB_TEST
	CALL	EXTRACT
	JP	NZ,DOWNLOAD
	LD	HL,0
	LD	DE,FCB_TEST
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	Z,DOWN_EXISTS
	LD	HL,M_DOWNNON
	CALL	MESS
	JP	COMMAND
DOWN_EXISTS
	JR	DE_01
;
DE_01
	CALL	GET_PROTOCOL
	LD	A,(PROTO)
	CP	'A'
	JR	Z,DOWN_LIST
	JR	DOWN_XMODEM
;
DOWN_LIST
	LD	HL,LIST_MASK
DO_ANYTHING
	LD	DE,CMD_OUT
	CALL	STRCPY
	LD	HL,(EOS)
	LD	(HL),0
	LD	HL,FILE_BUFF
	LD	DE,CMD_OUT
	CALL	STRCAT
	JP	DO_CMD
;
DOWN_XMODEM
	LD	HL,XM_SEND
	JR	DO_ANYTHING
;
UPLOAD
	CALL	CHK_VIS
	LD	HL,M_UP
	CALL	MESS
	CALL	GET_FILENAME
	LD	HL,FILE_BUFF
	LD	DE,FCB_TEST
	CALL	EXTRACT
	JP	NZ,UPLOAD
	LD	HL,0
	LD	DE,FCB_TEST
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	NZ,UP_NONEX
	LD	HL,M_UP_EX
	CALL	MESS
	JR	UPLOAD
;
UP_NONEX
	CALL	GET_PROTOCOL
	LD	A,(PROTO)
	CP	'A'
	JR	Z,UP_UPLOAD
	JR	UP_XMODEM
;
UP_UPLOAD
	LD	HL,CMD_UPLOAD
	JR	DO_ANYTHING
;
UP_XMODEM
	LD	HL,XM_RECV
	JR	DO_ANYTHING
;
GET_INPUT
	LD	A,OM_RAW
	LD	(OUTPUT_MODE),A
;
	LD	HL,M_PROMPT1
	CALL	MESS
;
	LD	A,(OLD_MODE)
	LD	(OUTPUT_MODE),A
;
	LD	HL,IN_BUFF
	LD	B,1
	CALL	ROM@WAIT_LINE
	RET	C
	LD	A,(HL)
	RET
;
CHK_VIS
	LD	A,(PRIV_2)
	BIT	1,A
	RET	Z
	LD	HL,M_NOPRIV
	CALL	MESS
	POP	AF
	JP	COMMAND
;
GET_FILENAME
	LD	HL,FILE_BUFF
	LD	B,32
	CALL	ROM@WAIT_LINE
	JP	C,EXIT
	LD	HL,FILE_BUFF
GF_1
	LD	A,(HL)
	INC	HL
	CP	CR
	JR	NZ,GF_1
	LD	(HL),0		;AFTER the cr.
	DEC	HL
	LD	(EOS),HL
	RET
;
EXIT	XOR	A
	JP	TERMINATE
;
GET_PROTOCOL
	LD	HL,M_PROTOCOL
	CALL	MESS
	LD	HL,IN_BUFF
	LD	B,1
	CALL	ROM@WAIT_LINE
	JP	C,EXIT
	LD	A,(HL)
	AND	5FH
	LD	(HL),A
	LD	(PROTO),A
	RET
;
DO_CMD
	LD	HL,M_EXEC1
	CALL	MESS
	LD	HL,CMD_OUT
	CALL	MESS
	LD	HL,M_EXEC2
	CALL	MESS
;
	LD	HL,CMD_OUT
	CALL	CALL_PROG
	JP	COMMAND
;
MESS	LD	A,(HL)
	OR	A
	RET	Z
	LD	DE,DCB_2O
	CALL	ROM@PUT
	INC	HL
	JR	MESS
;
DIR	LD	HL,CMD_DIR
	LD	DE,CMD_OUT
	CALL	STRCPY
	JR	DO_CMD
;
NEWFILES
	LD	HL,CMD_NEWF
	LD	DE,CMD_OUT
	CALL	STRCPY
	JR	DO_CMD
;
MINIX
	LD	HL,CMD_MINIX
	LD	DE,CMD_OUT
	CALL	STRCPY
	JP	DO_CMD
;
CLEAN_END
	LD	A,(OLD_MODE)
	LD	(OUTPUT_MODE),A
	XOR	A
	JP	TERMINATE
;
TAB_SRCH
	CP	'A'
	JR	C,TS_1
	CP	'Z'+1
	JR	NC,TS_1
	ADD	A,20H		;To lower case
TS_1	LD	B,A
TS_2	LD	A,(HL)
	OR	A
	RET	Z
	CP	B
	JR	Z,TS_3
	INC	HL
	INC	HL
	INC	HL
	JR	TS_2
;
TS_3	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	XOR	A
	CP	1
	RET
;
;
*GET	ROUTINES
;
M_PROTOCOL
	DEFM	'Xmodem or Ascii? [X,a] : ',0
;
M_HELP1
	DEFM	CR
	DEFM	'  <U>   Upload a file to Zeta',CR
	DEFM	'  <D>   Download a file from Zeta',CR
	DEFM	0
;
M_HELP2
	DEFM	'  <F>   Display disk directories',CR
	DEFM	'  <N>   Browse the online files catalogue',CR
	DEFM	'  <C>   Download Zeta''s catalogues',CR
	DEFM	'  <M>   Browse the MINIX archives (very long)',CR
	DEFM	'  <X>   Exit "xfer"',CR
	DEFB	CR,0
;
M_CATMENU
	DEFM	CR
	DEFM	'Select the letter code of a catalogue to download.',CR
	DEFM	'Each catalogue is a text file containing short',CR
	DEFM	'descriptions of files in Zeta''s archives.',CR
	DEFM	'You must use the XMODEM protocol to download catalogues.',CR
	DEFM	CR,CR
	DEFM	'  <A>   46k  Comp.sources.unix Volumes 12 - 19',CR
	DEFM	'  <B>   38k  Comp.sources.misc Volumes 02 - 09',CR
	DEFM	'  <C>    5k  Electronic Otherrealms SF magazines',CR
	DEFM	'  <D>   15k  RISKS Digests, Volumes 06 - 09',CR
	DEFM	'  <E>    7k  Information and Text files (old)',CR
	DEFM	'  <F>   33k  MINIX News, Sources and Updates (old)',CR
	DEFM	'  <G>    2k  Miscellaneous Unix things (old)',CR
	DEFM	'  <H>    3k  Comp.sources.misc Volume 13 (current)',CR
	DEFM	'  <I>    5k  Comp.sources.unix Volume 22 (current)',CR
	DEFM	'  <J>    1k  Risks Digests, Volume 10 (current)',CR
	DEFM	'  <K>   13k  Comp.sources.unix Volumes 20 - 21',CR
	DEFM	'  <L>   15k  Comp.sources.misc Volumes 10 - 12',CR
	DEFM	'  <M>   67k  Minix archives catalogue (most recent)',CR
	DEFM	'  <N>    1k  Comp.sources.sun Volume 02',CR
	DEFM	'  <O>    4k  Comp.sources.games Volume 10 (current)',CR
	DEFM	'   /    Previous menu',CR
	DEFM	CR,0
;
M_PROMPT1
	DEFM	CR,'Xfer <   >',BS,BS,BS,0
M_PROMPT2
	DEFM	'Catalogue  <   >',BS,BS,BS,0
;
M_DOWN	DEFM	'Download which file? ',0
M_UP	DEFM	'Upload to what filename? ',0
M_DOWNNON
	DEFM	'File not in directory. Do "f" to find which files exist',CR,0
M_UP_EX
	DEFM	'Sorry ... file already exists',CR,0
M_NOPRIV
	DEFM	'Sorry, members only.',CR,0
M_EXEC1
	DEFM	'Executing: "',0
M_EXEC2
	DEFM	'".',CR,0
;
CMD_DIR		DEFM	'dirall',0
CMD_UPLOAD	DEFM	'capture ',0
LIST_MASK	DEFM	'cat ',0
XM_SEND		DEFM	'xmodem -s ',0
XM_RECV		DEFM	'xmodem -cr ',0
CMD_NEWF	DEFM	'more online.cat',0
CMD_MINIX	DEFM	'more minarch.cat',0
;
CAT_A	DEFM	'unix1219.cat',0
CAT_B	DEFM	'misc0209.cat',0
CAT_C	DEFM	'orrealms.cat',0
CAT_D	DEFM	'risk0609.cat',0
CAT_E	DEFM	'text.cat',0
CAT_F	DEFM	'minix.cat',0
CAT_G	DEFM	'unix.cat',0
CAT_H	DEFM	'misc13.cat',0
CAT_I	DEFM	'unix22.cat',0
CAT_J	DEFM	'risk10.cat',0
CAT_K	DEFM	'unix2021.cat',0
CAT_L	DEFM	'misc1012.cat',0
CAT_M	DEFM	'minarch.cat',0
CAT_N	DEFM	'sun02.cat',0
CAT_O	DEFM	'game10.cat',0
;
CMD_TABLE
	DEFB	CR
	DEFW	COMMAND
	DEFB	'c'
	DEFW	CATALOGUE
	DEFB	'd'
	DEFW	DOWNLOAD
	DEFB	'u'
	DEFW	UPLOAD
	DEFB	'x'
	DEFW	EXIT
	DEFB	'f'
	DEFW	DIR
	DEFB	'n'
	DEFW	NEWFILES
	DEFB	'm'
	DEFW	MINIX
	DEFB	0,0,0
;
CAT_TABLE
	DEFB	'a'
	DEFW	CAT_A
	DEFB	'b'
	DEFW	CAT_B
	DEFB	'c'
	DEFW	CAT_C
	DEFB	'd'
	DEFW	CAT_D
	DEFB	'e'
	DEFW	CAT_E
	DEFB	'f'
	DEFW	CAT_F
	DEFB	'g'
	DEFW	CAT_G
	DEFB	'h'
	DEFW	CAT_H
	DEFB	'i'
	DEFW	CAT_I
	DEFB	'j'
	DEFW	CAT_J
	DEFB	'k'
	DEFW	CAT_K
	DEFB	'l'
	DEFW	CAT_L
	DEFB	'm'
	DEFW	CAT_M
	DEFB	'n'
	DEFW	CAT_N
	DEFB	'o'
	DEFW	CAT_O
	DEFB	0,0,0
;
IN_BUFF		DEFS	64
FILE_BUFF	DEFS	32
EOS		DEFW	0
OLD_MODE	DEFB	0
;
PROTO	DEFB	0
;
CMD_OUT
	DEFS	64
;
FCB_TEST
	DEFS	32
;
THIS_PROG_END	EQU	$
;
	END	START
