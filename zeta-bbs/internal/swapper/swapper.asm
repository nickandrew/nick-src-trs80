;Swapper: In-256k-memory program swapper....
;(C) Zeta Microcomputer software.
;
;********************************************************
;*							*
;* This program provides the following functions:	*
;*	- CALL a program from another {system()}	*
;*	- OVERLAY a program with another {execl()}	*
;*	- TERMINATE a running program {exit()}		*
;*	- provide ABORT and DISCONNECT signals		*
;*							*
;*  It multiplies the power of Zeta by a factor of 10+. *
;*							*
;********************************************************
;
*GET	EXTERNAL
*GET	DOSCALLS
*GET	ASCII
*GET	PROGNUMB
;
	COM	'<Swapper 1.2a 23-Apr-89>'
	ORG	5200H
;
START
	XOR	A
	LD	(PROCESS),A
;
;Setup routine addresses.
	LD	A,0C3H
	LD	HL,_TERMINATE
	LD	(TERMINATE),A
	LD	(TERMINATE+1),HL
;
	LD	HL,_CALL_PROG
	LD	(CALL_PROG),A
	LD	(CALL_PROG+1),HL
;
	LD	HL,_OVERLAY
	LD	(OVERLAY),A
	LD	(OVERLAY+1),HL
;
	LD	HL,_TERM_ABORT
	LD	(TERM_ABORT),A
	LD	(TERM_ABORT+1),HL
;
	LD	HL,_TERM_DISC
	LD	(TERM_DISCON),A
	LD	(TERM_DISCON+1),HL
;
	LD	HL,ANSWER_CMD
	CALL	CALL_PROG	;Start Zeta! Yay!
	JR	$		;Should never happen!
;back to dos.
;
;
_CALL_PROG
	LD	(NEW_CMD),HL
	LD	A,1
	LD	(IS_CALL),A
PUSH_PROG
	DI
	LD	(SAFE_HL),HL
	LD	HL,0
	ADD	HL,SP		;hl = orig sp
	LD	SP,SAFE_REGS+32	;end of safe regs
	PUSH	HL		;save orig sp
	LD	HL,0		;dummy old pc
	PUSH	HL
	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	HL,(SAFE_HL)
	PUSH	HL
;
	EX	AF,AF'
	EXX
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY
	LD	HL,(PROG_START)
	PUSH	HL
	LD	HL,(PROG_END)
	PUSH	HL
	LD	HL,(ABORT)
	PUSH	HL
	LD	HL,(DISCON)
	PUSH	HL
;
	LD	SP,MY_STACK
	EI
;
;Safe_regs is now loaded with all registers + dummy pc
;
	LD	A,(PROCESS)	;Is anything running now?
	OR	A
	CALL	NZ,SAVE_MEMORY	;Yes, save memory
	JP	NZ,ERROR_5	;If out of memory
;
	CALL	COPY_CMD	;Copy the command
;
	LD	HL,DEFAULT_BLOCK
	LD	DE,PROG_START
	LD	BC,4
	LDIR
;
	LD	HL,CMD_BUFFER
	LD	DE,FCB_IN
	CALL	EXTRACT
	JP	NZ,ERROR_3
;
	LD	HL,CMD_EXT
	CALL	DOS_EXTEND	;lazy!
	LD	HL,BUFF_IN
	LD	B,0
	CALL	DOS_OPEN_EX
	JP	NZ,ERROR_3
;
	LD	A,(FCB_IN+2)	;is it executable?
	BIT	0,A
	JP	Z,ERROR_3	;no, error
;
	LD	HL,FCB_IN+1	;check permissions
	LD	A,(HL)
	AND	7
	CP	7		;lock?
	JP	Z,ERROR_3	;lock, error
;
	CP	6
	JR	NZ,CMD_3A	;full-read is ok
;
	LD	A,(HL)		;set read perms
	AND	0F8H
	OR	5
	LD	(HL),A
;
CMD_3A
	LD	HL,BUFF_IN
	LD	(FILE_POS),HL
;
CMD_4
	CALL	GETFIL		;Read command
	LD	C,A
;
	LD	A,1FH
	CP	C
	JP	C,ERROR_1	;If > 1fh.
;
	CALL	GETFIL		;Read length
	LD	B,A
;
	CALL	GETFIL
	LD	L,A
	LD	H,C
;
	DEC	C
	JR	Z,CMD_5		; 1 => load a block
	DEC	C
	JR	NZ,CMD_7	; not = 2
	CALL	GETFIL		; read exec addr
	LD	H,A
	XOR	A
	JR	CMD_LOADED
;
CMD_5	CALL	GETFIL
	LD	H,A
	DEC	B
	DEC	B
CMD_6	CALL	GETFIL
	LD	(HL),A
	INC	HL
CMD_7
	DJNZ	CMD_6
	JR	CMD_4
;
CMD_LOADED
	PUSH	HL		;Save entry addr
;
	LD	A,(IS_CALL)	;Check if overlay desired
	OR	A
	CALL	Z,ZAP_OVERLAY	;Yes, zap previous prog
;
; We are ready to execute so give it a process number.
	LD	A,(IS_CALL)
	OR	A
	JR	Z,CL_01		;Dont inc PROCESS.
	LD	A,(PROCESS)
	INC	A
	LD	(PROCESS),A
CL_01
;
	POP	HL		;get entry address
	DI
	LD	SP,MY_STACK	;Set so push is right.
	PUSH	HL		;popped by later RET.
;
;The program registers are now taken from safe_regs,
; except HL = (PROGARG), PC = start addr, and SP=MY_STACK
; PROG_START etc have been initialised by loading.
;
	LD	SP,SAFE_REGS+8	;Start of IY.
;
	POP	IY
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EXX
	EX	AF,AF'
;
	POP	HL
	LD	HL,(PROGARG)
	POP	DE
	POP	BC
	POP	AF
;
	LD	SP,MY_STACK-2	;prior push
	EI			;****!!****
	RET			;execute.
;
GETFIL_READ
	LD	HL,BUFF_IN
	LD	(FILE_POS),HL
	LD	DE,FCB_IN
	CALL	DOS_READ_SECT
	RET	Z
	POP	AF	;ret addr getfil_read
	POP	AF	;HL pushed getfil
	POP	AF	;ret addr getfil
	JP	ERROR_1	;send error number one.
;
SAVE_MEMORY
	LD	HL,(PROG_END)
	LD	DE,(PROG_START)
	OR	A
	SBC	HL,DE
	INC	HL
	PUSH	HL		;Length of prog
	LD	DE,32		;Length of saved regs
	ADD	HL,DE		;# bytes of paged ram
;
	DEC	HL		;now "max offset" in ram
	LD	A,H
	SRL	A
	SRL	A
	INC	A		;a now "# pages reqd".
	PUSH	AF
;
	CALL	COUNT_UNUSED	;Count them, into C.
	POP	AF
	CP	C
	JR	Z,SM_01		;barely enough!
	RET	NC		;Not enough, NZ is set.
SM_01
	LD	A,(PROCESS)
	CALL	ALLOC_PAGE
	JP	NZ,ERROR_2
	LD	B,TEMP_PAGEX
	CALL	SWAP_PAGE
	LD	A,C
	LD	(OLDPAGE),A
;
	LD	HL,SAFE_REGS
	LD	DE,TEMP_RAM
	LD	BC,32
	LDIR
;
	POP	BC		;Length of program
	LD	HL,(PROG_START)
;
SM_02
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
;
	DEC	BC
	LD	A,B
	OR	C
	JR	Z,SM_END
;
	LD	A,E
	OR	A
	JR	NZ,SM_02
	LD	A,D
	AND	3
	JR	NZ,SM_02
;
;Allocate another page!
	PUSH	HL
	PUSH	BC
;
	LD	A,(PROCESS)
	CALL	ALLOC_PAGE
	JP	NZ,ERROR_2
	LD	B,TEMP_PAGEX
	CALL	SWAP_PAGE
;
	POP	BC
	POP	HL
	LD	DE,TEMP_RAM
	JR	SM_02
;
SM_END
	LD	A,(OLDPAGE)
	LD	B,TEMP_PAGEX
	CALL	SWAP_PAGE
	CP	A
	RET
;
COUNT_UNUSED
	LD	HL,(MEM_OWNER)
	LD	BC,0
CU_01	LD	A,(HL)
	OR	A
	JR	NZ,CU_02
	INC	C
CU_02
	INC	HL
	DJNZ	CU_01
	RET
;
; Free all pages owned by the current process
FREE_ALL
	LD	HL,(MEM_OWNER)
	LD	A,(PROCESS)
	LD	B,0
FA_01
	LD	C,(HL)
	CP	C
	JR	NZ,FA_02
	LD	(HL),0
FA_02	INC	HL
	DJNZ	FA_01
	RET
;
FIND_PAGE
	LD	A,(PAGENUM)
	LD	E,A
	INC	A
	LD	(PAGENUM),A
	LD	D,0
	LD	HL,(MEM_OWNER)
	ADD	HL,DE
	LD	A,(PROCESS)
	CP	(HL)
	LD	A,E
	RET	Z
	CP	0FFH		;Last page
	JR	NZ,FIND_PAGE
	CP	1
	RET	;nz
;
;Copy command line into CMD_BUFFER
COPY_CMD
	LD	HL,(NEW_CMD)
	LD	DE,CMD_BUFFER
CC_01	LD	A,(HL)
	LD	(DE),A
	CP	CR
	JR	Z,CC_02
	OR	A
	JR	Z,CC_02
	INC	HL
	INC	DE
	JR	CC_01
;
CC_02	LD	A,CR		;Terminate with CR
	LD	(DE),A
	LD	HL,CMD_BUFFER
;Find end of command name
CC_03	LD	A,(HL)
	CP	CR
	JR	Z,CC_05
	CP	' '
	JR	Z,CC_04
	OR	A
	JR	Z,CC_05
	INC	HL
	JR	CC_03
CC_04	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,CC_04
CC_05	LD	(PROGARG),HL
	RET
;
;We wanted overlay so zap the original program away.
ZAP_OVERLAY
	CALL	FREE_ALL	;Is this sufficient?
	RET
;
GETFIL
	PUSH	HL
	LD	HL,(FILE_POS)
	LD	A,L
	CP	BUFF_IN.AND.255
	CALL	Z,GETFIL_READ
	LD	HL,(FILE_POS)
	LD	A,(HL)
	INC	HL
	LD	(FILE_POS),HL
	POP	HL
	RET
;
;********************************************************
;
_OVERLAY
	LD	(NEW_CMD),HL
	LD	A,0
	LD	(IS_CALL),A
	JP	PUSH_PROG
;
;********************************************************
;
_TERMINATE
_TERM_ABORT
	LD	(A_REGISTER),A
	JR	TERM_PROG
_TERM_DISC
	LD	(A_REGISTER),A
;
	LD	A,(CD_STAT)
	SET	CDS_DISCON,A
	LD	(CD_STAT),A
;
	JR	TERM_PROG
;
TERM_PROG
	LD	A,(A_REGISTER)	;Get return code and
	LD	(LASTCC),A	;place in LASTCC.
;
	LD	SP,MY_STACK
;
	LD	A,(PROCESS)
	DEC	A
	LD	(PROCESS),A
	JP	Z,FELL_OFF_END	;Nothing underneath!
;
;Now get back the saved registers and memory contents.
	CALL	RESTORE_MEM
;
	CALL	FREE_ALL	;Free its pages.
;
;Progs memory is back and save_regs has all registers.
;Now get back the program block, restore the registers
; and execute it.
;
	DI
	LD	SP,SAFE_REGS
	POP	HL
	LD	(DISCON),HL
	POP	HL
	LD	(ABORT),HL
	POP	HL
	LD	(PROG_END),HL
	POP	HL
	LD	(PROG_START),HL
;
	POP	IY
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EXX
	EX	AF,AF'
;
	POP	HL
	POP	DE
	POP	BC
	POP	AF		;A and F are ignored
;
	LD	SP,(SAFE_REGS+30)
;
	LD	A,(CD_STAT)
	BIT	CDS_DISCON,A
	JR	Z,TERM_0
	PUSH	HL
	LD	HL,(DISCON)
	LD	A,H
	OR	L
	JR	NZ,SEND_SIGNAL
	POP	HL
;
TERM_0
	LD	A,(A_REGISTER)		;ret code
	CP	A			;Z=exec worked
	EI
	RET
;
SEND_SIGNAL
	EX	(SP),HL		;tos=jump vector
;Now, tos = jump vector, hl = real hl value, under jump
; vector is return address for pc.
	LD	A,(A_REGISTER)
	CP	A
	EI
	RET
;
;
;********************************************************
RESTORE_MEM
	XOR	A
	LD	(PAGENUM),A
	CALL	FIND_PAGE
	JP	NZ,ERROR_4	;Nothing saved?
	LD	B,TEMP_PAGEX
	CALL	SWAP_PAGE
	LD	A,C
	LD	(OLDPAGE),A
;
	LD	HL,TEMP_RAM
	LD	DE,SAFE_REGS
	LD	BC,32
	LDIR
;
	LD	HL,(SAFE_REGS+4)	;prog_end
	LD	DE,(SAFE_REGS+6)	;prog_start
	LD	(PROG_START),DE
	OR	A
	SBC	HL,DE
	INC	HL
	PUSH	HL
	POP	BC		;BC = prog length.
;
	LD	HL,(PROG_START)
	LD	DE,TEMP_RAM+32
;
RM_02
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
;
	DEC	BC
	LD	A,B
	OR	C
	JR	Z,RM_END
;
	LD	A,E
	OR	A
	JR	NZ,RM_02
	LD	A,D
	AND	3
	JR	NZ,RM_02
;
;Find another allocated page!
	PUSH	HL
	PUSH	BC
;
	CALL	FIND_PAGE
	JP	NZ,ERROR_4
	LD	B,TEMP_PAGEX
	CALL	SWAP_PAGE
;
	POP	BC
	POP	HL
	LD	DE,TEMP_RAM
	JR	RM_02
;
RM_END
	LD	A,(OLDPAGE)
	LD	B,TEMP_PAGEX
	CALL	SWAP_PAGE
	RET
;
;********************************************************
;
FELL_OFF_END
	LD	HL,EXITSYS_CMD
	CALL	CALL_PROG	;try to run it
	LD	HL,M_ARGH
	CALL	4467H
	JR	$		;loop forever.
;
EXITSYS_CMD
	DEFM	'Exitsys',0
ANSWER_CMD
	DEFM	'Answer',0
;
M_ARGH
	DEFM	'Swapper fell over the edge.',CR,0
;
;********************************************************
;
;********************************************************
;Error routines...
;
;An error has occurred while reading the file so the
;old process' memory must be swapped in again.
ERROR_1
	LD	A,1
	LD	(A_REGISTER),A
	JR	ERROR_SWAP_1
;
;Cannot allocate a page! Fatal.
ERROR_2
	LD	A,2
	EI
	JR	$
;
;Cannot open or execute the command file.
ERROR_3
	LD	A,3
	LD	(A_REGISTER),A
	JR	ERROR_SWAP_3
;
;Cannot load all the pages to restore a program. Fatal!
ERROR_4
	LD	A,4
	EI
	JR	$
;
;Ran out of memory for a call or overlay.
ERROR_5
	LD	A,5
	LD	(A_REGISTER),A
	JR	ERROR_SWAP_5
;
ERROR_SWAP_1
;
;Now get back the saved registers and memory contents.
	CALL	RESTORE_MEM
;
ERROR_SWAP_3
	CALL	FREE_ALL	;Free its pages.
;
;Progs memory is back and save_regs has all registers.
;Now get back the program block, restore the registers
; and execute it.
;
ERROR_SWAP_5
	DI
	LD	SP,SAFE_REGS
	POP	HL
	LD	(DISCON),HL
	POP	HL
	LD	(ABORT),HL
;
	POP	HL
	LD	(PROG_END),HL
	POP	HL
	LD	(PROG_START),HL
;
	POP	IY
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EXX
	EX	AF,AF'
;
	POP	HL
	POP	DE
	POP	BC
	POP	AF		;A and F are ignored
;
	LD	SP,(SAFE_REGS+30)
;
;Forget signals when an error happens!
	LD	A,(A_REGISTER)
	OR	A
	EI
	RET
;
;********************************************************
;
*GET	ROUTINES
;
;********************************************************
;
NEW_CMD		DEFW	0
IS_CALL		DEFB	0
PROGARG		DEFW	0
PAGENUM		DEFB	0
OLDPAGE		DEFB	0
;
CMD_BUFFER	DEFS	256
;
DEFAULT_BLOCK
	DEFW	5C00H		;Default Start
	DEFW	0F7FFH		;Default End
	DEFW	0		;Abort
	DEFW	0		;Discon.
;
FCB_IN	DEFS	32
BUFF_IN	DEFS	256
;
CMD_EXT		DEFM	'Cmd'
;
A_REGISTER	DEFB	0
FILE_POS	DEFW	0
;
SAFE_REGS	DEFS	32
SAFE_HL		DEFW	0
;
	DEFS	256
MY_STACK	EQU	$
;
;********************************************************
;
	END	START
