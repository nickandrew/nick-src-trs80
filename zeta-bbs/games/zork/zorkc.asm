;Zorkc.asm
;Zork 1 for TRS-80 I, File 3.
;Last updated 15-Feb-86

*GET	DOSCALLS

	LD	A,D
	LD	HL,H58E7
	CALL	ADDHLA
	LD	(HL),E
	LD	A,B
	LD	HL,H5927
	CALL	ADDHLA
	LD	(HL),C
	LD	A,E
	INC	A
	JP	Z,H5119
	LD	HL,H5927-1
	CALL	ADDHLA
	LD	(HL),D
	RET
H5119	LD	A,D
	LD	(H5969),A
	RET
ADDHLA	ADD	A,L
	LD	L,A
	LD	A,0
	ADC	A,H
	LD	H,A
	RET
LOOKUP1	LD	HL,H5967
	LD	B,(HL)
	LD	C,0
	LD	HL,H58A7
H512E	CP	(HL)
	JP	Z,H513D
	INC	C
	INC	HL
	DEC	B
	JP	NZ,H512E
	LD	A,(H5969)
	SCF
	RET
H513D	LD	A,C
	RET
H513F	XOR	A
	LD	(H596B),A
	LD	(H596C),A
	DEC	A
	LD	(H596A),A
H514A	CALL	H5201
	RET	C
	LD	B,A
	OR	A
	JP	Z,H51A4		;if 0
	CP	1
	JP	Z,H51A9		;if 1
	CP	4
	JP	C,H51B3		;IF 2 OR 3
	CP	6
	JP	C,H51C2		;if 4 or 5
	CALL	H51F0
	OR	A
	JP	NZ,H5173
	LD	A,'['
H516B	ADD	A,B
	LD	C,A
H516D	CALL	VDUOUT_1
	JP	H514A
H5173	DEC	A
	JP	NZ,H517C
	LD	A,';'
	JP	H516B
H517C	LD	A,B
	CP	6
	JP	Z,H518C
	LD	HL,H51D7-7
	CALL	ADDHLA
	LD	C,(HL)
	JP	H516D
H518C	CALL	H5201
	RRCA
	RRCA
	RRCA
	LD	C,A
	PUSH	BC
	CALL	H5201
	POP	BC
	ADD	A,C
	LD	C,A
	CP	9
	JP	NZ,H516D
	LD	C,' '
	JP	H516D
H51A4	LD	C,' '
	JP	H516D
H51A9	LD	C,0DH
	CALL	VDUOUT_1
	LD	C,0AH
	JP	H516D
H51B3	CALL	H51F0
	ADD	A,2
	ADD	A,B
	CALL	AMOD3
	LD	(H596A),A
	JP	H514A
H51C2	CALL	H51F0
	ADD	A,B
	CALL	AMOD3
	LD	(H596B),A
	JP	H514A
AMOD3	CP	3
	RET	C
	SUB	3
	JP	AMOD3
H51D7	DEFM	'0123456789.,!?'
	DEFM	'_#'
	DEFB	27H,'"'
	DEFM	'/\'
	DEFB	']'
	DEFM	'-:('
H51EF	DEFM	')'
H51F0	LD	A,(H596A)
	INC	A
	LD	A,(H596B)
	RET	Z
	PUSH	HL
	LD	HL,H596A
	LD	A,(HL)
	LD	(HL),0FFH
	POP	HL
	RET
H5201	LD	A,(H596C)
	OR	A
	SCF
	RET	M
	JP	NZ,H521A
	INC	A
	LD	(H596C),A
	CALL	H5048
	LD	(H596D),HL
	LD	A,H
	RRCA
	RRCA
	AND	1FH
	RET
H521A	DEC	A
	JP	NZ,H522D
	LD	A,2
	LD	(H596C),A
	LD	HL,(H596D)
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	A,H
	AND	1FH
	RET
H522D	XOR	A
	LD	(H596C),A
	LD	HL,(H596D)
	LD	A,H
	OR	A
	JP	P,H523E
	LD	A,0FFH
	LD	(H596C),A
H523E	LD	A,L
	AND	1FH
	RET
H5242	XOR	A
	LD	(H596B),A
	LD	HL,H596F
	LD	B,6
H524B	LD	(HL),5
	INC	HL
	DEC	B
	JP	NZ,H524B
	LD	B,6
	LD	DE,H596F
	LD	HL,H587F
H525A	LD	C,(HL)
	INC	HL
	LD	A,C
	OR	A
	LD	A,5
	JP	Z,H52D1
	LD	A,C
	CP	' '
	LD	A,0
	JP	Z,H52D1
	LD	A,C
	CP	0DH
	JP	NZ,H527D
	LD	A,(HL)
	CP	0AH
	JP	NZ,H527D
	INC	HL
	LD	A,1
	JP	H52D1
H527D	PUSH	DE
	LD	A,C
	CALL	CHARTEST
	LD	E,A
	LD	A,(H596B)
	CP	E
	JP	Z,H52C5
	LD	A,(HL)
	CALL	CHARTEST
	CP	E
	JP	NZ,H52B0
	PUSH	HL
	LD	HL,H596B
	SUB	(HL)
	POP	HL
	ADD	A,3
	CALL	AMOD3
	ADD	A,3
	LD	D,A
	LD	A,E
	LD	(H596B),A
	LD	A,D
	POP	DE
	LD	(DE),A
	INC	DE
	DEC	B
	JP	Z,H533C
	PUSH	DE
	JP	H52C5
H52B0	LD	A,E
	PUSH	HL
	LD	HL,H596B
	SUB	(HL)
	POP	HL
	ADD	A,3
	CALL	AMOD3
	INC	A
	POP	DE
	LD	(DE),A
	INC	DE
	DEC	B
	JP	Z,H533C
	PUSH	DE
H52C5	LD	A,C
	POP	DE
	CALL	CHARTEST
	DEC	A
	JP	P,H52DA
	LD	A,C
	SUB	'['
H52D1	LD	(DE),A
	INC	DE
	DEC	B
	JP	NZ,H525A
	JP	H533C
H52DA	JP	NZ,H52E3
	LD	A,C
	SUB	';'
	JP	H52D1
H52E3	LD	A,C
	CALL	LOOKUP2
	JP	NZ,H52D1
	LD	A,6
	LD	(DE),A
	INC	DE
	DEC	B
	JP	Z,H533C
	LD	A,C
	RLCA
	RLCA
	RLCA
	AND	3
	LD	(DE),A
	INC	DE
	DEC	B
	JP	Z,H533C
	LD	A,C
	AND	1FH
	JP	H52D1
;
LOOKUP2	PUSH	BC
	PUSH	HL
	LD	HL,H51EF
	LD	B,19H
H530B	CP	(HL)
	JP	Z,H5317
	DEC	HL
	DEC	B
	JP	NZ,H530B
	POP	HL
	POP	BC
	RET
H5317	LD	A,B
	ADD	A,6
	POP	HL
	POP	BC
	RET
CHARTEST	CP	'a'
	JP	C,H5329
	CP	7BH
	JP	NC,H5329
	XOR	A
	RET
H5329	CP	'A'
	JP	C,H5336
	CP	'['
	JP	NC,H5336
	LD	A,1
	RET
H5336	OR	A
	RET	Z
	RET	M
	LD	A,2
	RET
H533C	LD	BC,H596F
	LD	HL,0000H
	LD	D,H
	CALL	H535F
	CALL	H535F
	CALL	H535F
	LD	(H596F),HL
	LD	HL,0001H
	CALL	H535F
	CALL	H535F
	CALL	H535F
	LD	(H5971),HL
	RET
H535F	LD	A,(BC)
	INC	BC
	LD	E,A
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE	;HL=HL*32 + (BC) + D*256
	RET		;A=(BC), BC++
;
CRASH	LD	HL,0000H
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	SP,STACK
	LD	BC,3C3CH
	LD	A,D
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	H5391
	LD	A,D
	CALL	H5391
	LD	A,E
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	H5391
	LD	A,E
	CALL	H5391
H538E	JP	H538E
H5391	AND	0FH
	ADD	A,'0'
	LD	(BC),A
	INC	BC
	RET
;
GETHIMEM	PUSH	BC
	PUSH	DE
;Tell ZORK to obey Himem.
	LD	HL,(4049H)
;should be sufficient.
H53B1	POP	DE
	POP	BC
	DEC	H
	LD	L,0FFH
	LD	A,(H58A5)
	XOR	H
	AND	1
	RET	NZ
	DEC	H
	RET
;
WAIT_KEY	PUSH	DE	;Keyboard input.
	CALL	ROM@WAIT_KEY
	POP	DE
	RET
;
H5442	PUSH	BC
	PUSH	DE
	PUSH	HL
H5445	LD	HL,3C00H
	LD	(CURSOR),HL
	LD	BC,0400H
	LD	A,0DH
	LD	(LINE_CNT),A
H5453	LD	(HL),' '
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,H5453
	LD	HL,(CURSOR)
	LD	(HL),8CH	;new cursor.
	POP	HL
	POP	DE
	POP	BC
	RET
;
NEW_LINE	PUSH	HL
	LD	HL,LINE_CNT
	DEC	(HL)
	CALL	M,DO_MORE
	POP	HL
	RET
;
H546F	LD	B,0DH
	LD	DE,3C00H
	LD	HL,3C40H
H5477	LD	C,'@'
H5479	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	C
	JP	NZ,H5479
	DEC	B
	JP	NZ,H5477
	LD	HL,3FF8H
	LD	B,8
	CALL	H5499
	LD	HL,3F40H
	LD	(CURSOR),HL
	LD	BC,0040H
	JP	H5453
;
H5499	LD	(HL),' '
	INC	HL
	DEC	B
	JP	NZ,H5499
	RET
;
DO_MORE	LD	(HL),0DH
	LD	HL,MORE	;more.
	CALL	MSG_NUL	;was H54b6
	CALL	ROM@WAIT_KEY	;wait for key hit.
	LD	HL,HAAAD
	CALL	MSG_NUL
	RET
;
H54B6	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	B
	JP	NZ,H54B6
	RET
;
MORE	DEFM	'(MORE)',00H
HAAAD	DEFM	8,8,8,8,8,8,00H	;more backspace.
M_ROOM	DEFM	'Where:  ',00H
M_SCOR	DEFM	'   SCORE: ',00H
M_MOVE	DEFM	'  MOVES: ',00H
;
H54D8
	LD	A,8
	CALL	ROM@PUT_VDU
	LD	A,(4020H)
	AND	3FH
	RET	NZ
	LD	A,1	;no script.
	LD	(SCRIPT_1),A
;
;Do move number checking ... lamp fading etc...
;only if running under Zeta....................
	IF	ZETA
	CALL	LIMIT_MOVES
	ENDIF
;
;
	LD	HL,M_ROOM	;Room.
	CALL	MSG_NUL	;was H54b6
;
	LD	A,10H	;Room II.
	CALL	H4588
	LD	A,L
	CALL	H484A
;
	LD	HL,M_SCOR	;Score.
	CALL	MSG_NUL	;was H54b6.
	LD	A,11H	;Score II.
	CALL	H5532	;set cursor & call h4588.
	LD	HL,M_MOVE	;Moves.
	CALL	MSG_NUL	;was H54b6.
	LD	A,12H	;Moves II.
	CALL	H5532	;set cursor & call h4588.
	LD	C,0DH
	CALL	VDUOUT_1
	XOR	A
	LD	(SCRIPT_1),A	;script on.
	RET
H5532
;;;;	ld	(h5282),hl
	CALL	H4588
	JP	H4DBA
H553B	LD	A,(SCRIPT_1)
	OR	A
	RET	NZ
	LD	DE,0000H
H5543	LD	A,(37E8H)
	AND	80H
	JP	Z,H555A
	PUSH	HL
	POP	HL
	PUSH	HL
	POP	HL
	DEC	DE
	LD	A,D
	OR	E
	JP	NZ,H5543
	LD	A,(HL)
	AND	0FEH
	LD	(HL),A
	RET
H555A	LD	A,C
	LD	(37E8H),A
	RET
H555F	LD	C,0DH
VDUOUT_1	PUSH	BC
	PUSH	DE
	PUSH	HL
;new VDU driver.
	JP	NEW_VDU
;
;;H5564	LD	HL,(H58A4)
;;	LD	DE,0011H
;;	ADD	HL,DE
;;	LD	A,(HL)
;;	AND	1
;;	CALL	NZ,H553B
;;	LD	A,C
;;	CP	0CH
;;	JP	Z,H5445
;;	LD	HL,(CURSOR)
;;	LD	(HL),' '
;;	CP	8
;;	JP	Z,H55C5
;;	CP	0DH
;;	JP	Z,H55C9
;;	CP	' '
;;	JP	Z,H55B6
;;	JP	C,H55A0
;;	CP	'`'
;;	JP	C,H559E
;;	LD	B,A
;;	LD	A,(LCASE_F)
;;	OR	A
;;	LD	A,B
;;	JP	NZ,H559E
;;	AND	0DFH
H559E	LD	(HL),A
H559F	INC	HL
H55A0	LD	(CURSOR),HL
	LD	A,L
	AND	'?'
	CALL	Z,NEW_LINE
	LD	DE,0C080H
	ADD	HL,DE
	LD	A,L
	OR	H
	JP	Z,H546F
	POP	HL
	POP	DE
	POP	BC
	RET
H55B6	LD	A,(CURSOR)
	AND	'?'
	CP	'4'
	LD	C,0DH
;;	JP	NC,H5564
	JP	H559F
H55C5	DEC	HL
	JP	H55A0
H55C9	LD	A,L
	AND	0C0H
	LD	L,A
	LD	DE,0040H
	ADD	HL,DE
	JP	H55A0
H55D4	CALL	H5442
	LD	HL,H56A8
	CALL	MSG_NUL
	CALL	WAIT_KEY
	LD	C,A
	CALL	VDUOUT_1
	LD	A,C
	SUB	'0'
	JP	C,H55D4
	CP	4
	JP	NC,H55D4
	LD	D,A
	LD	A,80H
H55F2	RLCA
	DEC	D
	JP	P,H55F2
	LD	(H42ED),A
	CALL	H555F
	CALL	H5021
H5600	CALL	H42D7
	XOR	A
	LD	(H42EE),A
	LD	(H42EF),A
	CALL	H42BD
	LD	DE,0000H
H5610	LD	A,(37ECH)
	AND	2
	RET	NZ
	DEC	DE
	LD	A,D
	OR	E
	JP	NZ,H5610
	POP	HL
	JP	H460F
H5620	CALL	H55D4
	LD	A,(37ECH)
	AND	'@'
	JP	NZ,H460F
	CALL	H5021
	LD	HL,(H589E)
	LD	(H42F3),HL
	EX	DE,HL
	LD	HL,(H58A4)
	LD	BC,0000H
	ADD	HL,BC
	LD	A,(HL)
	LD	(DE),A
	INC	DE
	LD	HL,H5854
	LD	B,'+'
H5644	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	B
	JP	NZ,H5644
	CALL	H4323
	JP	NZ,H460F
	LD	HL,(H58A4)
	LD	DE,0004H
	ADD	HL,DE
	LD	B,(HL)
	LD	HL,(H58A4)
	LD	(H42F3),HL
H5660	PUSH	BC
	CALL	H5699
	CALL	H4323
	POP	BC
	JP	NZ,H460F
	LD	HL,H42F4
	INC	(HL)
	DEC	B
	JP	P,H5660
H5673	LD	A,(H42ED)
	DEC	A
	JP	NZ,H568E
	LD	HL,H56D7
	CALL	MSG_NUL
	CALL	WAIT_KEY
	CP	0DH
	JP	NZ,H5673
H5688	CALL	H555F
	JP	ENTRY
H568E	LD	A,1
	LD	(H42ED),A
	CALL	H5600
	JP	H5688
H5699	LD	HL,H42EF
	INC	(HL)
	LD	A,(HL)
	CP	0AH
	RET	NZ
	LD	(HL),0
	LD	HL,H42EE
	INC	(HL)
	RET
H56A8	DEFM	'LOAD SAVE DISK, THEN TYPE '
	DEFM	'DRIVE NUMBER (0 - 3)'
	DEFB	0
H56D7	DEFM	'LOAD ZORK DISK, THEN TYPE '
	DEFM	'<ENTER>'
	DEFB	0
H56F9	CALL	H55D4
	LD	HL,(H589E)
	LD	(H42F0),HL
	CALL	H4256
	LD	HL,(H58A4)
	LD	DE,0000H
	ADD	HL,DE
	LD	A,(HL)
	LD	HL,(H589E)
	CP	(HL)
	JP	NZ,H460F
	INC	HL
	LD	DE,H5854
	LD	B,'+'
H571A	LD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	DEC	B
	JP	NZ,H571A
	LD	HL,(H58A4)
	LD	DE,0004H
	ADD	HL,DE
	LD	B,(HL)
	LD	HL,(H58A4)
	LD	(H42F0),HL
H5730	PUSH	BC
	CALL	H5699
	CALL	H4256
	LD	HL,H42F1
	INC	(HL)
	POP	BC
	DEC	B
	JP	P,H5730
	XOR	A
	LD	(H5899),A
	JP	H5673
H5747	JP	402DH	;quit/killed3 exit point.
H574A	JP	402DH
;
H574D	LD	A,(H584D)
	OR	A
	CALL	Z,H57C4
	LD	A,0DH
	LD	(LINE_CNT),A
	LD	HL,(H5889)
	LD	D,'d'		;???
	LD	E,0
	INC	HL
;
;New keyboard input routine.
HAAAC	LD	A,'>'
	CALL	ROM@PUT_VDU
	LD	HL,(H5889)
	INC	HL
	LD	B,62
	CALL	40H
	JR	C,HAAAC
	PUSH	BC
HAAAA	LD	A,(HL)
	INC	HL
	CP	0DH
	JR	Z,HAAAB
	CP	'a'
	JR	NC,HAAAA
	CP	'A'
	JR	C,HAAAA
	ADD	A,20H
	DEC	HL
	LD	(HL),A
	INC	HL
	JR	HAAAA
;
HAAAB
;Check input string.
;Prevents READ ALL, READ x AND y, $VERIFY etc...
	LD	HL,(H5889)
	INC	HL
	CALL	CMDFIX
	POP	BC
	JR	NZ,HAAAC
;OK
	LD	A,B
	RET
;End of new kbd input routine.
;
H5761	PUSH	HL
	LD	HL,(CURSOR)
	LD	(HL),8CH	;new cursor.
	POP	HL
	CALL	WAIT_KEY
	CP	8
	JP	Z,H57A0
	CP	0DH
	JP	Z,H57AF
	CP	0AH
	JP	Z,H57AF
	CP	0CH
	JP	Z,H57BC
	CP	' '
	JP	C,H5761
	LD	C,A
	LD	A,D
	CP	E
	JP	Z,H5761
	CALL	VDUOUT_1
	LD	A,C
	CP	'A'
	JP	C,H579A
	CP	'['
	JP	NC,H579A
	ADD	A,' '
H579A	LD	(HL),A
	INC	HL
	INC	E
	JP	H5761
H57A0	LD	A,E
	OR	A
	JP	Z,H5761
	DEC	E
	DEC	HL
	LD	C,8
	CALL	VDUOUT_1
	JP	H5761
H57AF	LD	A,D
	CP	E
	JP	Z,H57B7
	INC	E
	LD	(HL),0DH
H57B7	CALL	H555F
	LD	A,E
	RET
H57BC	LD	C,0CH
	CALL	VDUOUT_1
	JP	H5761
;
;New randomising routine.
H57C4	LD	A,R
	LD	B,A
HAAAE	PUSH	BC
	CALL	H4E11	;randomise.
	POP	BC
	DJNZ	HAAAE
	LD	A,1
	LD	(H584D),A
	RET
;
H57D2
	LD	A,0FFH
	LD	(LCASE_F),A
	RET
;
MSG_NUL	LD	A,(HL)
	OR	A
	RET	Z
	LD	C,A
	CALL	VDUOUT_1
	INC	HL
	JP	MSG_NUL
;
GETBLOCK	JP	READ_FILE
;
;Start of data area.
H584D	DEFB	0
H584E	DEFB	0
H584F	DEFB	0
LINE_CNT	DEFB	0DH	;Line counter
LCASE_F	DEFB	0		;L/case flag.
CURSOR	DEFW	3C00H		;Cursor position.
H5854	DC	1EH,0
H5872	DEFB	0
H5873	DEFB	0
H5874	DEFB	0
H5875	DEFW	0FFFFH
H5877	DEFW	0FFFFH
H5879	DEFB	1
H587A	DEFW	H41FE
H587C	DEFW	0
H587E	DEFB	0
H587F	DEFB	1EH
	DC	5,0
	DEFB	0FFH
SCRIPT_1	DEFB	1	;Script flag.
	DEFB	0
H5888	DEFB	0
H5889	DEFB	0
H588A	DEFB	0
H588B	DEFW	0
H588D	DEFW	0
H588F	DEFW	0
H5891	DEFB	0
H5892	DEFB	0
H5893	DEFW	0
H5895	DEFW	0
H5897	DEFW	0
H5899	DEFB	0
H589A	DEFB	0
H589B	DEFB	0
H589C	DEFB	0
H589D	DEFB	0
H589E	DEFW	0
H58A0	DEFB	0
H58A1	DEFB	0
H58A2	DEFW	0
H58A4	DEFB	0
H58A5	DEFB	0
H58A6	DEFB	0
H58A7	DC	40H,0
H58E7	DC	40H,0
;I added these definitions to help with relocation.
;Defines the working set completely now.
H5927	DC	40H,0
H5967	DEFB	0
H5968	DEFB	0
H5969	DEFB	0
H596A	DEFB	0
H596B	DEFB	0
H596C	DEFB	0
H596D	DEFW	0
H596F	DEFB	0
H5970	DEFB	0
H5971	DEFB	0
H5972	DEFB	0,0,0
H5975	DEFB	0,0
H5977
*GET	ZORKSEC1	;Get checksum data.
H5A77	DEFB	0
; End of new data definitions.
