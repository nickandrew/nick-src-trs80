;special: set up special routines.
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
*GET	RS232
;
	COM	'<Special 1.3g 02-Apr-88>'
	ORG	BASE+100H
;
START	LD	SP,START
	LD	HL,(HIMEM)
	LD	A,H
	CP	0FFH
	JR	NZ,NOT_FF
	LD	HL,EXTERNALS-1
NOT_FF	LD	DE,EN_CODE-ST_CODE
	OR	A
	SBC	HL,DE
	LD	(HIMEM),HL
;
	INC	HL
	LD	(ORIGIN),HL
	LD	DE,ST_CODE
	OR	A
	SBC	HL,DE
	EX	DE,HL
;
;;	LD	HL,(RELOC1+1)
;;	ADD	HL,DE
;;	LD	(RELOC1+1),HL
;
;;	LD	HL,(RELOC2+1)
;;	ADD	HL,DE
;;	LD	(RELOC2+1),HL
;
;;	LD	HL,(RELOC3+1)
;;	ADD	HL,DE
;;	LD	(RELOC3+1),HL
;
;;	LD	HL,(RELOC4+1)
;;	ADD	HL,DE
;;	LD	(RELOC4+1),HL
;
	LD	BC,EN_CODE-ST_CODE
	LD	DE,(ORIGIN)
	LD	HL,ST_CODE
	LDIR
;
	LD	A,0C3H
	LD	(CARR_DETECT),A
	LD	(TEL_HANGUP),A
	LD	(TEL_PICKUP),A
	LD	(SECOND),A
;;	LD	(MESSAGE),A
;;	LD	(LIST),A
	LD	(LOST_CARRIER),A
	LD	(IO_TIMEOUT),A
	LD	(USR_LOGOUT),A
	LD	(ALLOC_PAGE),A
	LD	(FREE_PAGE),A
	LD	(SWAP_PAGE),A
;
	LD	HL,(ORIGIN)
	LD	DE,ST_CODE
	OR	A
	SBC	HL,DE
	EX	DE,HL
;
	LD	HL,DETECT
	ADD	HL,DE
	LD	(CARR_DETECT+1),HL
;
	LD	HL,HANGUP
	ADD	HL,DE
	LD	(TEL_HANGUP+1),HL
;
	LD	HL,PICKUP
	ADD	HL,DE
	LD	(TEL_PICKUP+1),HL
;
	LD	HL,WAIT1
	ADD	HL,DE
	LD	(SECOND+1),HL
;
	LD	HL,NOCARR
	ADD	HL,DE
	LD	(LOST_CARRIER+1),HL
;
	LD	HL,TIMEOUT
	ADD	HL,DE
	LD	(IO_TIMEOUT+1),HL
;
;;	LD	HL,PMESS
;;	ADD	HL,DE
;;	LD	(MESSAGE+1),HL
;
;;	LD	HL,L_FILE
;;	ADD	HL,DE
;;	LD	(LIST+1),HL
;
	LD	HL,LOGOUT
	ADD	HL,DE
	LD	(USR_LOGOUT+1),HL
;
	LD	HL,$MEM_OWNER
	ADD	HL,DE
	LD	(MEM_OWNER),HL
;
	LD	HL,$MEM_TABLE
	ADD	HL,DE
	LD	(MEM_TABLE),HL
;
	LD	HL,$ALLOC_PAGE
	ADD	HL,DE
	LD	(ALLOC_PAGE+1),HL
;
	LD	HL,$FREE_PAGE
	ADD	HL,DE
	LD	(FREE_PAGE+1),HL
;
	LD	HL,$SWAP_PAGE
	ADD	HL,DE
	LD	(SWAP_PAGE+1),HL
;
	JP	DOS
;
ORIGIN	DEFW	0
;
ST_CODE
DETECT
	PUSH	HL
	LD	HL,SYS_STAT
;
	IN	A,(RDSTAT)
	BIT	DSR,A		;Test carrier detect
;
	JR	NZ,DETECT_LOST	;if b7=1, no carrier
	SET	2,(HL)		;carrier
	POP	HL
	RET
DETECT_LOST
	RES	2,(HL)
	POP	HL
	RET
;
HANGUP	PUSH	AF
	PUSH	BC
	LD	HL,SYS_STAT
	RES	0,(HL)		;hung up.
	LD	A,4		;signal action
	LD	(3C00H),A
;
	LD	A,(MODEM_STAT2)
	RES	DTR,A		;turn off DTR to hangup
	LD	(MODEM_STAT2),A
	OUT	(WRSTAT),A
;
	LD	A,4		;little down arrow
	LD	(3C01H),A
;
	POP	BC
	POP	AF
	RET
;
PICKUP	PUSH	AF
	PUSH	BC
;
	LD	A,3
	LD	(3C00H),A
;
	LD	A,(SYS_STAT)	;Next action debatable
	AND	0F8H		;!
	OR	1
	LD	(SYS_STAT),A
;
	LD	A,(MODEM_STAT2)
	SET	DTR,A		;turn on dtr to allow
	LD	(MODEM_STAT2),A
	OUT	(WRSTAT),A
;
	LD	A,3
	LD	(3C01H),A
;
	POP	BC
	POP	AF
	RET
;
;wait 'A' seconds routine.
WAIT1	PUSH	BC
W1_2	PUSH	AF
	LD	B,40
	LD	A,(TICKER)
	LD	C,A
W1_3	LD	A,(TICKER)
	CP	C
	LD	C,A
	JR	Z,W1_3
	DJNZ	W1_3
	POP	AF
	DEC	A
	JR	NZ,W1_2
	POP	BC
	RET
;
NOCARR
	JP	USR_LOGOUT	;exit.
;
TIMEOUT
	JP	USR_LOGOUT
;
;;PMESS	LD	A,(HL)
;;	CP	ETX
;;	JR	Z,PMESS_ETX
;;	OR	A
;;	JR	Z,PMESS_ETX
;;	CALL	$PUT
;;	INC	HL
;;	JR	PMESS
;;
;;PMESS_ETX		;show all calls to "message".
;;	PUSH	DE
;;	LD	DE,$DO
;;	LD	A,'%'
;;	CALL	$PUT
;;	LD	A,'%'
;;	CALL	$PUT
;;	POP	DE
;;	RET
;
LOGOUT				;do disconnect exit.
	LD	HL,CD_STAT
	SET	CDS_DISCON,(HL)
	LD	A,0
	JP	TERMINATE	;Pass the word brothers
;
;;L_FILE				;List file.
;;RELOC2	LD	DE,DCB1
;;	CALL	DOS_EXTRACT
;;RELOC3	LD	HL,BUFF1
;;	LD	B,0
;;	CALL	DOS_OPEN_EX
;;	RET	NZ
;;
;;LOOP
;;RELOC4	LD	DE,DCB1
;;	CALL	$GET
;;	JR	Z,LP_NEOF
;;	CP	1CH
;;	JR	Z,CLOSIT
;;	CP	1DH
;;	JR	Z,CLOSIT
;;	RET
;;
;;LP_NEOF	OR	A
;;	JR	Z,CLOSIT
;;	LD	DE,$2
;;	CALL	$PUT
;;	CALL	$GET
;;	CP	1
;;	JR	NZ,LOOP
;;	LD	A,CR
;;	LD	DE,$2
;;	CALL	$PUT
;;
;;CLOSIT		;dont close we're only reading it.
;;	RET
;;
;alloc_page: allocate a new page. Output number in A.
;return NZ if memory full. Input program number in A.
$ALLOC_PAGE
	LD	C,A	;=program number.
	LD	HL,(MEM_OWNER)
	LD	D,0	;=physical page number.
	LD	B,0	;=256 pages to search.
_AP_1	LD	A,(HL)
	OR	A
	JR	Z,_AP_2	 ;found a free one.
	INC	HL
	INC	D
	DJNZ	_AP_1
	XOR	A
	CP	1	;set NZ flag
	RET
_AP_2	LD	(HL),C	;alloc page to program number.
	LD	A,D	;A=physical page number
	CP	A
	RET		;Z flag set.
;
$FREE_PAGE
	LD	E,A
	LD	D,0
	LD	HL,(MEM_OWNER)
	ADD	HL,DE
	LD	(HL),0
	RET
;
;swap_page: move physical page
;physical page "A" into logical page "B" (b=0-47)
$SWAP_PAGE
	LD	C,A
	LD	E,B
	LD	A,16
	ADD	A,B
	ADD	A,A	;*2
	ADD	A,A	;*4
	LD	B,A
	LD	A,C
	LD	C,10H
	DI
	OUT	(C),A
	LD	HL,(MEM_TABLE)
	LD	D,0
	ADD	HL,DE
	LD	C,(HL)
	LD	(HL),A
	EI
	RET
;
;;DCB1	DEFS	32
;;BUFF1	DEFS	256
;
;mem_owner: 256 bytes saying which "program number"
;owns which page of memory.
$MEM_OWNER
	DC	48,0FFH		;System owns all that.
	DC	256-48,0	;Rest is free.
;
;mem_table: 48 bytes saying which physical page is
;swapped into each logical page.
$MEM_TABLE
	DEFB	00,01,02,03,04,05,06,07,08,09
	DEFB	10,11,12,13,14,15,16,17,18,19
	DEFB	20,21,22,23,24,25,26,27,28,29
	DEFB	30,31,32,33,34,35,36,37,38,39
	DEFB	40,41,42,43,44,45,46,47
;
EN_CODE	NOP
;
	END	START
