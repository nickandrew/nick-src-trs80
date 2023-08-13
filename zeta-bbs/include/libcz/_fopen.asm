;
;FILE *fopen(file,mode)
;char *file,*mode;
;
_FOPEN
	XOR	A
	LD	($C_07V),A	;Device name or 0.
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,(DE)
	LD	($C_06V),A
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	DE,(_BRKSIZE)
	LD	A,(HL)
	CP	':'
	JR	NZ,$C_07
	INC	HL
	LD	A,(HL)
	AND	5FH
	LD	($C_07V),A
	CP	'D'
	LD	DE,NULL_DCB
	JR	Z,$C_11B
	CP	'L'
	LD	DE,DCB_PTR$
	JR	Z,$C_11B
	CP	'C'
	JR	NZ,$C_13
	LD	A,($C_06V)	;Mode
	CP	'r'
	LD	DE,DCB_KBD$
	JR	Z,$C_11B
	LD	DE,DCB_VDU$
	JR	$C_11B
;
$C_07	LD	A,(HL)
	OR	A
	JR	Z,$C_09
;;	CP	'/'
;;	JR	Z,$C_08
	LD	(DE),A
	INC	HL
	INC	DE
	JR	$C_07
;;$C_08	LD	A,'.'
;;	LD	(DE),A
;;	INC	HL
;;	INC	DE
;;	JR	$C_07
$C_09	LD	A,3
	LD	(DE),A
;
	LD	HL,32
	LD	DE,(_BRKSIZE)
	ADD	HL,DE
	LD	B,0
	LD	A,($C_06V)
	CP	'a'
	JR	Z,$C_10		;append mode
	CP	'w'
	JR	Z,$C_10		;write mode
;
;Open for reading.
	CALL	DOS_OPEN_EX	;assume read
	LD	HL,NULL
	RET	NZ
	LD	HL,256+32
	ADD	HL,DE
	LD	(_BRKSIZE),HL	;update end of memory
	CALL	FIX_PROG_END
	JR	$C_11A
;
;Open for write and append
$C_10
	CALL	DOS_OPEN_NEW	;Write & append
	LD	HL,NULL
	RET	NZ
	LD	HL,256+32
	ADD	HL,DE
	LD	(_BRKSIZE),HL
	CALL	FIX_PROG_END
	LD	A,($C_06V)
	CP	'a'
	JR	NZ,$C_11	;If not append
	CALL	DOS_POS_EOF	;Append, so position to EOF
	JR	$C_11A
$C_11
	;Truncate the file??
$C_11A	INC	DE
	LD	A,(DE)
	SET	6,A		;Ensure writes do not bugger eof
	LD	(DE),A
	DEC	DE
$C_11B
	LD	($C_08V),DE
	LD	B,MAX_FILES
	LD	HL,FD_ARRAY
	LD	DE,FD_LEN
$C_12
	LD	A,(HL)
	OR	A
	JR	Z,$C_14
	ADD	HL,DE
	DJNZ	$C_12
$C_13	LD	HL,NULL
	RET
$C_14
	LD	(HL),1
	LD	A,($C_07V)
	OR	A
	JR	Z,$C_16
	SET	IS_TERM,(HL)
$C_16
	PUSH	HL
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	DE,($C_08V)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	POP	HL
	RET
$C_06V	DEFB	0
$C_07V	DEFB	0	;Type of special device C,D,L
$C_08V	DEFW	0	;Addr of dcb/fcb.
;
NULL_DCB	DC	8,0
;
