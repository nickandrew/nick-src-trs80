;echo: Echo command line input to remote user
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
	COM	'<Echo 1.1d 19-Aug-87>'
	ORG	BASE+100H
;
START
	LD	SP,START
	LD	A,(HL)
	CP	CR
	JR	NZ,ECHO
	LD	HL,M_USAGE
	LD	DE,($STDOUT_DEF)
	CALL	MESS_0
	XOR	A
	JP	TERMINATE
;
ECHO	PUSH	HL
	LD	A,(HL)
	CP	CR
	JR	Z,ECHO_CR
	CP	'/'
	JR	Z,ECHO_CTL
	CP	'\'
	JR	Z,ECHO_BSL
	CP	'A'
	JR	C,ECH_001
	CP	'Z'+1
	JR	NC,ECH_001
	OR	20H		;to lower case
ECH_001
	CALL	OUT_CHAR
E_NEXT
	POP	HL
	INC	HL
	JR	ECHO
;
ECHO_CR
	LD	A,CR
	CALL	OUT_CHAR
	LD	A,0
	JP	TERMINATE
;
ECHO_BSL
	INC	HL
	LD	A,(HL)
	CP	CR
	JR	Z,ECHO_CR
	CP	'A'
	JR	C,EBSL_1
	CP	'Z'+1
	JR	NC,EBSL_1
EBSL_1
	PUSH	HL
	CALL	OUT_CHAR
	JR	E_NEXT
;
ECHO_CTL
	INC	HL
	LD	(WORD_ST),HL
	LD	HL,SYM_TABLE
ECTL_1
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,D
	OR	E
	JR	Z,ECTL_2
	PUSH	HL
	LD	HL,(WORD_ST)
	CALL	CMP_SYM
	JR	Z,ECTL_3
	POP	HL
	JR	ECTL_1
ECTL_2
	LD	A,'/'
	CALL	OUT_CHAR
	LD	A,'?'
	CALL	OUT_CHAR
	CALL	OUT_CHAR
	CALL	OUT_CHAR
	LD	A,'/'
	CALL	OUT_CHAR
	JR	ECHO_CR
;
ECTL_3
	POP	AF
	INC	DE
	LD	A,(DE)
	CALL	OUT_CHAR
	PUSH	HL
	JR	E_NEXT
;
OUT_CHAR
	PUSH	HL
	PUSH	DE
	LD	DE,($STDOUT)
	CP	20H
	JR	NC,OC_1
	LD	HL,SYS_STAT
	BIT	6,(HL)
	JR	NZ,OC_1
	CP	CR
	JR	Z,OC_1
	CP	BS
	JR	Z,OC_1
	CP	TAB
	JR	Z,OC_1
	LD	DE,($STDOUT)		;urk!
OC_1	CALL	ROM@PUT
	POP	DE
	POP	HL
	RET
;
CMP_SYM
	LD	A,(DE)
	OR	A
	JR	Z,CMP_1
	CP	(HL)
	RET	NZ
	INC	DE
	INC	HL
	JR	CMP_SYM
CMP_1
	LD	A,(HL)
	CP	'/'
	RET
;
*GET	ROUTINES
;
WORD_ST	DEFW	0
M_USAGE	DEFM	'Usage: ECHO [text|/NAK/|\char] ...',CR,0
;
SYM_TABLE
	DEFW	S_NUL,S_SOH,S_STX,S_ETX,S_EOT,S_ENQ,S_ACK
	DEFW	S_BEL,S_BS,S_HT,S_LF,S_VT,S_FF,S_CR,S_SO
	DEFW	S_SI,S_DLE,S_DC1,S_DC2,S_DC3,S_DC4,S_NAK
	DEFW	S_SYN,S_ETB,S_CAN,S_EM,S_SUB,S_ESC,S_FS
	DEFW	S_GS,S_RS,S_US,S_SPACE,S_DEL
;Auxiliary ones follow.. (different spelling)...
	DEFW	S_BELL
	DEFW	0
;
S_NUL	DEFB	'NUL',0,0
S_SOH	DEFB	'SOH',0,1
S_STX	DEFB	'STX',0,2
S_ETX	DEFB	'ETX',0,3
S_EOT	DEFB	'EOT',0,4
S_ENQ	DEFB	'ENQ',0,5
S_ACK	DEFB	'ACK',0,6
S_BEL	DEFB	'BEL',0,7
S_BS	DEFB	'BS',0,8
S_HT	DEFB	'HT',0,9
S_LF	DEFB	'LF',0,0AH
S_VT	DEFB	'VT',0,0BH
S_FF	DEFB	'FF',0,0CH
S_CR	DEFB	'CR',0,0DH
S_SO	DEFB	'SO',0,0EH
S_SI	DEFB	'SI',0,0FH
S_DLE	DEFB	'DLE',0,10H
S_DC1	DEFB	'DC1',0,11H
S_DC2	DEFB	'DC2',0,12H
S_DC3	DEFB	'DC3',0,13H
S_DC4	DEFB	'DC4',0,14H
S_NAK	DEFB	'NAK',0,15H
S_SYN	DEFB	'SYN',0,16H
S_ETB	DEFB	'ETB',0,17H
S_CAN	DEFB	'CAN',0,18H
S_EM	DEFM	'EM',0,19H
S_SUB	DEFB	'SUB',0,1AH
S_ESC	DEFB	'ESC',0,1BH
S_FS	DEFB	'FS',0,1CH
S_GS	DEFB	'GS',0,1DH
S_RS	DEFB	'RS',0,1EH
S_US	DEFB	'US',0,1FH
S_SPACE	DEFB	'SPACE',0,20H
S_DEL	DEFB	'DEL',0,7FH
;
;Auxiliary names..
S_BELL	DEFB	'BELL',0,7
;
THIS_PROG_END	EQU	$
;
	END	START
