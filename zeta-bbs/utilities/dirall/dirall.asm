;dirall: DIR of all drives
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
;
	COM	'<DIRALL 1.5a 25-Sep-86>'
	ORG	BASE+100H
START
	LD	SP,START
	PUSH	HL
;
;set the 'Print volume contents' flag.
	LD	A,1
	LD	(VOL_PRT),A
;
	LD	HL,MESS_1
	LD	DE,DCB_2O
	CALL	MESS_0
	POP	HL
	PUSH	HL
	LD	DE,ABY
	LD	BC,0
DI_1	LD	A,(HL)
	CP	CR
	JR	Z,DI_2
	INC	HL
	INC	BC
	JR	DI_1
DI_2	POP	HL
	LD	A,(HL)
	CP	'H'
	JP	Z,HELP
	CP	'?'
	JP	Z,HELP
	CP	CR
	JR	Z,DI_3
	INC	BC
	LDIR
;
;setup 'VOLUMES.ZMS' file.
DI_3	LD	DE,FCB_VOL
	LD	HL,BUFF_VOL
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	Z,CAN_OPEN
	XOR	A
	LD	(VOL_PRT),A
	JR	DI_4
CAN_OPEN
	LD	A,(FCB_VOL+1)
	AND	0F8H
	OR	5		;allow read permission.
	LD	(FCB_VOL+1),A
	LD	HL,BIG_BUFF
CO_1	PUSH	HL
	LD	DE,FCB_VOL
	CALL	ROM@GET
	POP	HL
	JR	NZ,CO_2
	LD	(HL),A
	INC	HL
	JR	CO_1
CO_2	LD	(HL),0
	JR	DI_4
;
DI_4
	LD	A,(VOL_PRT)
	OR	A
	JP	Z,DI_5	;no volume identification.
;get disk name.
;select desired drive.
	LD	A,(DISK)
	SUB	'0'
	CALL	445EH	;spin and test for disk.
	JR	NZ,DI_5	;if no disk.
	LD	A,0
	CALL	490AH	;read sector 0 of DIR
	JR	NZ,DI_5	;if no good.
;copy disk name into buffer.
	LD	HL,42D0H
	LD	B,8
	LD	DE,DBUFF
DN_COP	LD	A,(HL)
	CP	'a'
	JR	C,DN_NXT
	AND	5FH
DN_NXT	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	DN_COP
;check out contents of VOLUMES file for disk name.
	LD	DE,BIG_BUFF
CK_0	LD	B,8
	LD	HL,DBUFF
	PUSH	DE
CK_1	LD	A,(DE)
	CP	(HL)
	JR	Z,IS_EQU
	POP	HL
CK_2	OR	A
	JR	Z,UNKNOWN
;search for CR or 00h
	CP	CR
	INC	DE
	JR	Z,CK_0
	LD	A,(DE)
	JR	CK_2
IS_EQU	INC	HL
	INC	DE
	DJNZ	CK_1
;equal!
	POP	HL	;set this string as printed.
	LD	(HL),80H
	INC	DE
	LD	A,1
	LD	(KNOWN_FL),A	;volume known.
	PUSH	DE	;=start of description.
	JR	KNOWN
;print disk name.
UNKNOWN
	LD	A,0
	LD	(KNOWN_FL),A
KNOWN
	LD	DE,DCB_2O
	LD	A,CR
	CALL	ROM@PUT
	LD	B,8
	LD	HL,42D0H
PR_1	LD	A,(HL)
	CALL	ROM@PUT
	INC	HL
	DJNZ	PR_1
	LD	A,':'
	CALL	ROM@PUT
	LD	A,' '
	CALL	ROM@PUT
	LD	A,(KNOWN_FL)
	OR	A
	JR	NZ,PR_1A
	LD	HL,M_UNKN
	JR	PR_2
;print until 0dh
PR_1A	POP	HL
PR_2	LD	A,(HL)
	CALL	ROM@PUT
	LD	A,(HL)
	INC	HL
	CP	CR
	JR	NZ,PR_2
;do DIR on this drive.
DI_5
;
	LD	HL,ABV
	CALL	CALL_PROG
	JP	NZ,TERMINATE
	OR	A
	JR	NZ,DIR_ERR
NEXT	LD	A,(DISK)
	INC	A
	LD	(DISK),A
	CP	'8'
	JP	NZ,DI_4
;;	jr	other_disks
	XOR	A
	JP	TERMINATE
;
DIR_ERR
	CP	20H	;illegal/missing drive #
	JR	NZ,DE_1
	XOR	A
	JP	TERMINATE
DE_1
	CP	10H	;device not available
	JR	Z,NEXT
	CP	8	;device not available
	JR	Z,NEXT
	CP	34H	;illegal keyword ...
	JR	Z,HELP
	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	TERMINATE
;
HELP	LD	HL,MESS_2
	LD	DE,DCB_2O
	CALL	MESS_0
	XOR	A
	JP	TERMINATE
;
;print descriptions for other disks.
OTHER_DISKS
	LD	A,(VOL_PRT)
	OR	A
	JR	NZ,OD_0
	XOR	A
	JP	TERMINATE
OD_0	LD	HL,BIG_BUFF
OD_1	LD	A,(HL)
	OR	A
	JR	NZ,PAST_2
	XOR	A
	JP	TERMINATE
PAST_2	CP	80H
	JR	NZ,PRINT
OD_2	INC	HL
	LD	A,(HL)
	OR	A
	JR	NZ,PAST_3
	XOR	A
	JP	TERMINATE
PAST_3	CP	CR
	JR	NZ,OD_2
	INC	HL
	JR	OD_1
;
PRINT	LD	B,8
	LD	A,CR
	LD	DE,DCB_2O
	CALL	ROM@PUT
OD_3	LD	A,(HL)
	CALL	ROM@PUT
	INC	HL
	DJNZ	OD_3
	INC	HL
	PUSH	HL
	LD	HL,M_MNTD
	CALL	MESS_0
	POP	HL
OD_4	LD	A,(HL)
	CALL	ROM@PUT
	LD	A,(HL)
	INC	HL
	CP	CR
	JR	NZ,OD_4
	JR	OD_1
;
*GET	ROUTINES
;
MESS_1	DEFM	'Dirall 1.5  24-Aug-86 - Hit <ESC> to abort',CR,0
;
MESS_2	DEFM	'dirall: Show all files on the system',CR
	DEFM	'usage:  dirall [a] [.ext]',CR
	DEFM	'eg:     dirall .bas',CR
	DEFM	'For help on DIRALL see HELP COMMANDS',CR,0
;
;
M_MNTD	DEFM	': (Not currently mounted)',CR,0
M_UNKN	DEFM	'Unknown. No description available',CR
;
ABV	DEFM	'DIR '	;Call program DIR.
DISK	DEFM	'0'
	DEFM	' '
ABY	DEFM	CR
	DC	80-7,0
;
VOL_PRT	DEFB	0
KNOWN_FL	DEFB	0
;
FCB_VOL	DEFM	'volumes.zms',CR
	DC	32-12,0
;
DBUFF	DEFM	'ABCDEFGH'
;
BUFF_VOL
	DEFS	256
;
BIG_BUFF	EQU	$
;
	DEFS	1024	;max??
THIS_PROG_END	EQU	$
;
	END	START
