;Zorkfix: A rough patch to Zork1 to stop crashing
;attempts via:
; (1) 'read all' or 'read x and y'
; (2) $ commands (just which ones? - unknown)
;
;ALSO :- if Zeta, disallow some usage of Zork, and
;   if a visitor limit to 30 moves.
;
;
;Ver 1.1 on 15-Feb-86.
;Usage:
;       LD   HL,CMDBUF
;       CALL CMDFIX
;       JP   NZ,CMDGET
;
CMDFIX	LD	(BUFF_POS),HL
	CALL	CHECKD
	JR	NZ,WARN_1
	CALL	CHECKR
	RET	Z
;Warn 2.
	LD	HL,M_WARN2
	JR	MSG_NZ
WARN_1	LD	HL,M_WARN1
MSG_NZ	LD	A,(HL)
	OR	A
	JR	NZ,MSG_NZ2
	CP	1
	RET
MSG_NZ2	PUSH	HL
	CALL	33H
	POP	HL
	INC	HL
	JR	MSG_NZ
;
M_WARN1	DEFM	'You cannot use a $ sign here.',0DH,0
M_WARN2	DEFM	'Please rephrase your last "read" command.',0DH,0
;
BUFF_POS	DEFW	0
SRCH_POS	DEFW	0
;
; Check for a '$' character in an input string pointed to by HL
; and terminated by 0x0d or 0x00. If a '$' is found then
; substitute with '%' and return NZ, otherwise return Z.
CHECKD	LD	A,(HL)
	CP	0DH
	RET	Z
	OR	A
	RET	Z
	INC	HL
	CP	'$'
	JR	NZ,CHECKD
	DEC	HL
	LD	(HL),'%'	;Destroy!
	CP	0
	RET
;
CHECKR
	LD	HL,(BUFF_POS)
	LD	DE,X_READ
	CALL	FIND_STR
	RET	Z
	PUSH	HL
	LD	DE,X_ALL
	CALL	FIND_STR
	POP	HL
	RET	NZ
;Make sure only ONE word is left in the sentence.
CKR_1	LD	A,(HL)
	CP	0DH
	JP	Z,RET_NZ
	CP	'.'
	JP	Z,RET_NZ
	INC	HL
	CP	' '
	JR	Z,CKR_1
	CP	','
	JR	Z,CKR_1
;Assume start of word here.
CKR_2	LD	A,(HL)
	INC	HL
	CP	'.'
	RET	Z
	CP	0DH
	RET	Z
	CP	','
	JR	Z,CKR_3
	CP	' '
	JR	Z,CKR_3
	JR	CKR_2
;
RET_NZ	XOR	A
	CP	1
	RET
;
;
CKR_3				;Bad.
	XOR	A
	CP	1
	RET
;
	RET
;
FIND_STR
	LD	(SRCH_POS),DE
;
FS_1
	LD	A,(DE)
	OR	A
	JR	Z,FIND_END
	LD	A,(HL)
	OR	A
	RET	Z
	CP	0DH
	RET	Z
	LD	A,(DE)
	CP	(HL)
	JR	Z,MATCH
	LD	DE,(SRCH_POS)
	INC	HL
	JR	FS_1
;
MATCH	INC	HL
	INC	DE
	JR	FS_1
;
FIND_END
	LD	A,(HL)
	CP	'a'
	RET	C	;NZ
	CP	'z'+1
	JR	C,RET_OK
	XOR	A
	CP	1
	RET
RET_OK	XOR	A
	RET
;
X_READ	DEFM	'read',0
X_ALL	DEFM	'all',0
;
;If Zeta then MAY_I_PLAY is used and also LIMIT_MOVES.
	IF	ZETA
;
MAY_I_PLAY
	LD	A,(PRIV_2)
	BIT	DEN_GAMES,A
	RET	Z		;games allwd.
	LD	HL,M_CANT_PLAY
	LD	DE,$2
	CALL	MESSAGE
	JP	DOS
;
M_CANT_PLAY
	DEFM	CR
	DEFM	'Sorry, you lack permissions to play Zork1.',CR,ETX
;
LIMIT_MOVES
	LD	A,(PRIV_2)
	BIT	PRIV_VISITOR,A
	RET	Z		;if not a visitor.
;
;Get number of moves in HL
	LD	A,12H
	CALL	H4588
;
	LD	DE,25
	OR	A
	SBC	HL,DE
	RET	C
	PUSH	HL
	CALL	LIGHT_DIMMING
	POP	HL
	LD	DE,5
	OR	A
	SBC	HL,DE
	RET	C		;ret if <30.
	LD	HL,M_NO_MORE
	LD	DE,$2
	CALL	MESSAGE
	JP	DOS
;
LIGHT_DIMMING
	LD	A,(FLICKER_FLAG)
	OR	A
	RET	NZ
	LD	A,1
	LD	(FLICKER_FLAG),A
	LD	HL,M_LIGHT_DIMMING
	LD	DE,$2
	CALL	MESSAGE
	RET
;
FLICKER_FLAG	DEFB	0
;is set to 1 when the LIGHT DIMMING message appears
;so it only appears once.
;
;
M_LIGHT_DIMMING
	DEFM	CR
	DEFM	'Your lantern is starting to flicker and fade. Must be one of',CR
	DEFM	'these new VISITOR lamps. You can purchase a full access lamp',CR
	DEFM	'from Zeta for $5 (free membership included!)',CR,CR,ETX
;
M_NO_MORE
	DEFM	CR,CR
	DEFM	'Your light burns bright for a moment and then dies. Out from',CR
	DEFM	'the darkness springs a lurking grue, who rends you with his',CR
	DEFM	'slavering fangs. I told you these visitor access lamps were',CR
	DEFM	'useless. You can''t get any more than 30 moves out of a lamp',CR
	DEFM	'unless you join Zeta as a member.',CR
	DEFM	CR,ETX
;
	ENDIF	;zeta
;
