;pktsplit: Optionally split a large packet into two
;smaller packets.
; Usage: pktsplit inpacket outpkt0 [ ... outpkt9 ]
;
	COM	'<Pktsplit 1.1  17-Feb-87>'
;
*GET	DOSCALLS
LF	EQU	0AH
CR	EQU	0DH
;
	ORG	5300H
START	LD	SP,START
;
	PUSH	HL
	LD	HL,FCBS
	LD	(HL),0
	LD	DE,FCBS+1
	LD	BC,319		;length of fcbs -1
	LDIR
	LD	HL,BUFS
	LD	(HL),0
	LD	DE,BUFS+1
	LD	BC,2559		;length of bufs -1
	LDIR
	POP	HL
;
	LD	DE,FCB_IN
	CALL	DOS_EXTRACT
	JP	NZ,USAGE
	LD	DE,FCBS
	CALL	DOS_EXTRACT
	JP	NZ,USAGE
	PUSH	HL
	LD	HL,BUFS
	LD	DE,FCBS
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,ERROR
	POP	HL
;
FILE_LOOP
	LD	A,(HL)
	CP	CR
	JR	Z,FILE_OPEN
	LD	A,(MAX_FCB)
	INC	A
	LD	(MAX_FCB),A
	CP	10
	JP	Z,USAGE
	PUSH	HL
	LD	L,A
	LD	H,0
	ADD	HL,HL	;*2
	ADD	HL,HL	;*4
	ADD	HL,HL	;*8
	ADD	HL,HL	;*16
	ADD	HL,HL	;*32
	LD	DE,FCBS
	ADD	HL,DE	;offset now!
	EX	DE,HL
	POP	HL
	PUSH	DE
	CALL	DOS_EXTRACT
	POP	DE
	JP	NZ,USAGE
	PUSH	HL
	LD	HL,BUFS
	LD	A,(MAX_FCB)
	ADD	A,H		;index 256 bytes
	LD	H,A
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,ERROR
	POP	HL		;recover cmd string
	JR	FILE_LOOP
;
FILE_OPEN
	LD	HL,BUF_IN
	LD	DE,FCB_IN
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR
;
;Copy the 58 byte header...
	LD	B,58
HDR_COP	LD	DE,FCB_IN
	CALL	GETZ
;
	LD	DE,FCBS
HDR_001
	PUSH	AF
	LD	A,(DE)
	OR	A
	JR	Z,HDR_002
	POP	AF
	PUSH	AF
	CALL	PUTZ
	LD	HL,32
	ADD	HL,DE
	EX	DE,HL
	POP	AF
	JR	HDR_001
HDR_002
	POP	AF
	DJNZ	HDR_COP
;
LOOP	CALL	RD_MESSAGE
	JR	Z,EOF		;if end of packet.
;
	CALL	DECIDE
	JR	NZ,LOOP		;If delete required.
	CALL	WR_MESSAGE
	JR	LOOP
;
EOF
	LD	DE,FCBS
EOF_001	LD	A,(DE)
	OR	A
	JR	Z,EOF_002
	XOR	A
	CALL	PUTZ
	XOR	A
	CALL	PUTZ
	LD	HL,32
	ADD	HL,DE
	EX	DE,HL
	JR	EOF_001
EOF_002
	LD	DE,FCBS
EOF_003
	LD	A,(DE)
	OR	A
	JR	Z,EOF_004
	CALL	DOS_CLOSE
	JP	NZ,ERROR
	LD	HL,32
	ADD	HL,DE
	EX	DE,HL
	JR	EOF_003
EOF_004
	JP	DOS
;
PUTZ	CALL	$PUT
	JP	NZ,ERROR
	RET
;
GETZ	CALL	$GET
	JP	NZ,ERROR
	RET
;
USAGE	LD	HL,M_USAGE
	CALL	MESS
	JP	DOS
;
ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	DOS
;
RD_MESSAGE
	LD	A,(FCB_IN+5)
	LD	(INPOS),A
	LD	HL,(FCB_IN+10)
	LD	(INPOS+1),HL
;
	LD	(SPSAFE),SP
RM_ERROR
	LD	HL,(SPSAFE)
	LD	HL,MSG_BUF
	LD	(MSG_PTR),HL
	LD	DE,FCB_IN
	CALL	GETZE
	LD	(HL),A		;Get first msg type
	INC	HL
	PUSH	AF
	CALL	GETZE
	LD	(HL),A		;Get 2nd msg type
	INC	HL
	LD	(MSG_PTR),HL
	POP	BC
	OR	B	;Check if both are zero
	RET	Z	;End of packet.
	LD	B,32
	CALL	READ_NN
;
	CALL	READ_NULL	;Read "tousername"
	CALL	READ_NULL	;Read "fromusername"
	CALL	READ_NULL	;Read "subject"
	CALL	READ_NULL	;Read "text".
;
	XOR	A
	CP	1		;Set NZ to continue
	RET
;
READ_NN
	LD	HL,(MSG_PTR)
	LD	DE,FCB_IN
RN_01	CALL	GETZE
	LD	(HL),A
	INC	HL
	DJNZ	RN_01
	LD	(MSG_PTR),HL
	RET
;
READ_NULL
	LD	HL,(MSG_PTR)
	LD	DE,FCB_IN
RN_02	CALL	GETZE
	LD	(HL),A
	INC	HL
	OR	A
	JR	NZ,RN_02
	LD	(MSG_PTR),HL
	RET
;
GETZE	CALL	$GET
	RET	Z
	OR	80H
	CALL	DOS_ERROR
	LD	A,(INPOS)
	LD	C,A
	LD	HL,(INPOS+1)
	LD	DE,FCB_IN
	CALL	DOS_POS_RBA
	JP	RM_ERROR
;
INPOS	DEFS	3
SPSAFE	DEFW	0
;
WR_MESSAGE
	LD	HL,MSG_BUF
WM_01	PUSH	HL
	PUSH	DE
	LD	DE,(MSG_PTR)
	OR	A
	SBC	HL,DE
	POP	DE
	POP	HL
	JR	Z,WM_02
	LD	A,(HL)
	INC	HL
	CALL	PUTZ
	JR	WM_01
WM_02	RET
;
FCB_IN	DEFS	32
BUF_IN		DEFS	256
BUF_OUT0	DEFS	256
BUF_OUT1	DEFS	256
;
FCBS		DEFS	320	;10 fcbs of 32 bytes
BUFS		DEFS	2560	;10 buffers of 256 bytes
MSG_PTR	DEFW	0
MAX_FCB	DEFB	0
;
M_USAGE	DEFM	'usage: pktsplit in out1 ... outN',CR,0
;
MESS	LD	A,(HL)
	INC	HL
	OR	A
	RET	Z
	CALL	33H
	JR	MESS
;
DECIDE
	LD	HL,DASHES
	CALL	MESS
;
	LD	HL,MSG_BUF+0EH	;date portion
	CALL	MESS
	PUSH	HL
	LD	HL,SPACE3
	CALL	MESS
	LD	HL,TO
	CALL	MESS
	POP	HL
	CALL	MESS		;print tousername
	PUSH	HL
	LD	HL,SPACE3
	CALL	MESS
	LD	HL,FROM
	CALL	MESS
	POP	HL
	CALL	MESS		;print fromusername
	PUSH	HL
	LD	HL,CR1
	CALL	MESS
	LD	HL,ABOUT
	CALL	MESS
	POP	HL
	CALL	MESS		;print subject
	PUSH	HL
	LD	HL,CR2
	CALL	MESS
;
	POP	HL
	LD	(TEXT_PTR),HL	;start of text.
	CALL	MESS_CR
	CALL	MESS_CR
	CALL	MESS_CR
	CALL	MESS_CR
;
DEC_1	LD	HL,PROMPT
	CALL	MESS
	LD	HL,KEY
	LD	B,1
	CALL	40H
	LD	A,(HL)
	CP	'r'
	JR	Z,DEC_1A
;
	CP	'0'
	JR	C,DEC_1
	CP	'9'+1
	JR	NC,DEC_1
	SUB	'0'
	LD	L,A
	LD	H,0
	ADD	HL,HL	;*2
	ADD	HL,HL	;*4
	ADD	HL,HL	;*8
	ADD	HL,HL	;*16
	ADD	HL,HL	;*32
	LD	DE,FCBS
	ADD	HL,DE
	EX	DE,HL
	CP	A
	RET
DEC_1A
	LD	HL,(TEXT_PTR)
DEC_2	LD	A,(HL)
	OR	A
	JR	Z,DEC_1
	CALL	33H
	INC	HL
	LD	BC,3000H
	CALL	60H
	JR	DEC_2
;
TEXT_PTR	DEFW	0
KEY	DEFB	0,0,0
;
MESS_CR	LD	A,(HL)
	OR	A
	RET	Z
	AND	7FH
	INC	HL
	PUSH	AF
	CP	LF
	CALL	NZ,33H
	POP	AF
	CP	CR
	RET	Z
	JR	MESS_CR
;
PROMPT	DEFM	CR,'Do what? ',0
;
DASHES	DEFM	CR,'-------------------------------',CR,0
TO	DEFM	'To:   ',0
FROM	DEFM	'From: ',0
ABOUT	DEFM	'Subj: ',0
CR2	DEFM	CR,CR,0
CR1	DEFM	CR,0
SPACE3	DEFM	'   ',0
;
MSG_BUF	DEFW	0
;
	END	START