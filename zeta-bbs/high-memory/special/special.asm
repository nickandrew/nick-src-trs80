; Some functions and two tables are to be copied into high memory, and
; initialise a jump table (defined in EXTERNAL) so they can be called
; by other programs.
;
; Functions available:
;   This module    Public name    What does it do
;   -----------    -----------    ------------------------------------------
;   DETECT         CARR_DETECT    Test if there's modem carrier
;   HANGUP         TEL_HANGUP     Hang up the phone
;   PICKUP         TEL_PICKUP     Pick up the phone
;   WAIT1          SECOND         Wait 'n' seconds
;   NOCARR         LOST_CARRIER   Jumps to USR_LOGOUT
;   TIMEOUT        IO_TIMEOUT     Jumps to USR_LOGOUT
;   LOGOUT         USR_LOGOUT     Registers a disconnect and jumps away(?)
;   $ALLOC_PAGE    ALLOC_PAGE     Allocate a new 1kb physical page
;   $FREE_PAGE     FREE_PAGE      Free a specified 1kb page
;   $SWAP_PAGE     SWAP_PAGE      Map physical page A into logical page B
;
; Tables copied:
;   $MEM_OWNER     MEM_OWNER      256 bytes of page owners
;   $MEM_TABLE     MEM_TABLE      48 bytes mapping physical to logical page

*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
*GET	RS232
;
	COM	'<Special 1.3g+ 2019-03-15>'
	ORG	BASE+100H
;
START	LD	SP,START	; Provide 256 bytes of stack under this code
				; to avoid clobbering high memory
	LD	HL,(HIMEM)	; Current high memory address
	LD	A,H
	CP	0FFH
	JR	NZ,NOT_FF
	LD	HL,EXTERNALS-1
NOT_FF	LD	DE,EN_CODE-ST_CODE	; Length of the code to be relocated
	OR	A
	SBC	HL,DE
	LD	(HIMEM),HL	; Reserve space for the code to be relocated
;
	INC	HL
	LD	(ORIGIN),HL	; Start of destination addresses
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
	LD	BC,EN_CODE-ST_CODE	; Length of the code to be relocated
	LD	DE,(ORIGIN)		; Start of destination addresses
	LD	HL,ST_CODE		; Start of source addresses
	LDIR				; Copy all the code into place
;
; Patch the addresses of several functions into the high memory jump table.
;
; Calculate the difference between the loaded address of each function
; and the start of the code block to be relocated. This difference is
; added to the destination start address to find the relocated address
; of each function.
;
; new_address = old_address + (ORIGIN) - ST_CODE
	LD	HL,(ORIGIN)
	LD	DE,ST_CODE
	OR	A
	SBC	HL,DE		; HL = (ORIGIN) - ST_CODE
	EX	DE,HL		; DE = (ORIGIN) - ST_CODE
;
	LD	A,0C3H		; 0xc3 is a JP instruction
;
	LD	(CARR_DETECT),A
	LD	HL,DETECT
	ADD	HL,DE
	LD	(CARR_DETECT+1),HL
;
	LD	(TEL_HANGUP),A
	LD	HL,HANGUP
	ADD	HL,DE
	LD	(TEL_HANGUP+1),HL
;
	LD	(TEL_PICKUP),A
	LD	HL,PICKUP
	ADD	HL,DE
	LD	(TEL_PICKUP+1),HL
;
	LD	(SECOND),A
	LD	HL,WAIT1
	ADD	HL,DE
	LD	(SECOND+1),HL
;
	LD	(LOST_CARRIER),A
	LD	HL,NOCARR
	ADD	HL,DE
	LD	(LOST_CARRIER+1),HL
;
	LD	(IO_TIMEOUT),A
	LD	HL,TIMEOUT
	ADD	HL,DE
	LD	(IO_TIMEOUT+1),HL
;
;;	LD	(MESSAGE),A
;;	LD	HL,PMESS
;;	ADD	HL,DE
;;	LD	(MESSAGE+1),HL
;
;;	LD	(LIST),A
;;	LD	HL,L_FILE
;;	ADD	HL,DE
;;	LD	(LIST+1),HL
;
	LD	(USR_LOGOUT),A
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
	LD	(ALLOC_PAGE),A
	LD	HL,$ALLOC_PAGE
	ADD	HL,DE
	LD	(ALLOC_PAGE+1),HL
;
	LD	(FREE_PAGE),A
	LD	HL,$FREE_PAGE
	ADD	HL,DE
	LD	(FREE_PAGE+1),HL
;
	LD	(SWAP_PAGE),A
	LD	HL,$SWAP_PAGE
	ADD	HL,DE
	LD	(SWAP_PAGE+1),HL
;
	JP	DOS
;
ORIGIN	DEFW	0
;
;************************************************************************
; Code from ST_CODE to EN_CODE will be relocated into high memory.
;************************************************************************
ST_CODE

;************************************************************************
;  NAME: DETECT (public 'CALL CARR_DETECT')
;  USES: AF
;  Tests the DSR bit of RDSTAT. If it's set, there's no carrier and
;  so reset bit 2 of SYS_STAT. Otherwise there's carrier and set bit 2
;  of SYS_STAT.
;  RETURNS: Z if carrier, NZ if no carrier.
;************************************************************************
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
	RES	2,(HL)		; no carrier
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
;************************************************************************
;  NAME: WAIT1 (public 'CALL SECOND')
;    IN: Register A: Number of seconds to wait (0 == 256)
;  USES: AF
;  Wait 'n' seconds.
;************************************************************************

WAIT1	PUSH	BC		; BC will be clobbered, so save it
W1_2	PUSH	AF
	LD	B,40		; There are 40 ticks per second
	LD	A,(TICKER)	; TICKER is updated asynchronously
	LD	C,A
W1_3	LD	A,(TICKER)
	CP	C
	LD	C,A
	JR	Z,W1_3		; Loop while the value of TICKER hasn't changed
	DJNZ	W1_3		; Loop until 40 ticks have elapsed
	POP	AF
	DEC	A
	JR	NZ,W1_2		; Loop until 'n' seconds have passed
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
;;	LD	DE,DCB_2O
;;	CALL	$PUT
;;	CALL	$GET
;;	CP	1
;;	JR	NZ,LOOP
;;	LD	A,CR
;;	LD	DE,DCB_2O
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
	JR	Z,_AP_2	;found a free one.
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
	LD	C,10H		; Port 0x10 somehow controls page mapping
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
