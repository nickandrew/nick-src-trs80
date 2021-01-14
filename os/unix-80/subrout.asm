;Subrout/asm: General Subroutines.
; Date: 19-Jul-84.
;
; Display a message on the screen. Uses rom call 0033H.
MESSAGE_DO	CALL	SYS_BUSY
V1_MESS_DO	LD	A,(HL)
	INC	HL
	CP	NULL
	JR	Z,V2_MESS_DO
	CP	EOT
	JR	Z,V2_MESS_DO
	CALL	0033H
	CP	CR
	JR	NZ,V1_MESS_DO
V2_MESS_DO	CALL	SYS_UNBUSY
	RET
;
; Fill memory from HL with value of A. Number of bytes
;to fill is in BC.
FILL_MEM	PUSH	DE
	PUSH	HL
	POP	DE
	INC	DE
	LD	(HL),A
	DEC	BC	;because 1 byte is filled.
	LDIR
	POP	DE
	RET
;
; 'Alloc': Allocate BC bytes from High Memory and
;returns address in HL.
ALLOC	LD	HL,(UNIX80_HIMEM)
	OR	A
	SBC	HL,BC
	PUSH	HL
	PUSH	DE
	LD	DE,ZZZZZ	;Last Address used.
	OR	A
	SBC	HL,DE
	POP	DE
	POP	HL
	JR	C,ERR_ALLOC	;Not enough memory.
	LD	(UNIX80_HIMEM),HL	;Store new HIMEM.
	INC	HL
	CP	A		;Set Z no error status.
	RET
;
ERR_ALLOC	LD	A,6
; 'Cant ALLOC - Out of memory!'
	OR	A	;Set NZ error status.
	RET
;
; Unalloc: Re-allocate BC bytes.
UNALLOC	PUSH	HL
	LD	HL,(UNIX80_HIMEM)
	ADD	HL,BC
	PUSH	HL
	LD	DE,END_FREE_MEM+1	;Last address.
	OR	A
	SBC	HL,DE
	POP	HL
	JR	NC,ERR_UNALLOC	;Can't UNALLOC stack!
	LD	(UNIX80_HIMEM),HL
	POP	HL
	CP	A	;Set Z no error status.
	RET
;
ERR_UNALLOC	LD	A,8
;'Cant UNALLOC - past end of memory!'
	OR	A	;Set NZ error status.
	POP	HL
	RET
;
;
; Sys_busy: Increment 'syscall_lev' byte.
SYS_BUSY	PUSH	HL
	LD	HL,SYSCALL_LEV
	INC	(HL)
	PUSH	AF
	LD	A,(HL)
	CP	1
	JR	Z,V1_BUSY
	POP	AF
	POP	HL
	RET
V1_BUSY	POP	AF
	POP	HL
	LD	(SYS_TEMPSP),SP
	LD	SP,SYSTEM_STACK-2
	PUSH	HL
	PUSH	AF
	LD	SP,(SYS_TEMPSP)
	POP	HL
	LD	(SYS_TEMPSP),SP
	LD	(SYSTEM_STACK-2),HL
	LD	SP,SYSTEM_STACK-6
	POP	AF
	POP	HL
	RET
;
;
; 'sys_unbusy': Decrement 'syscall_lev' flag.
SYS_UNBUSY	PUSH	AF
	LD	A,(SYSCALL_LEV)
	OR	A
	JR	NZ,V1_UNBUSY
	POP	AF
	RET
V1_UNBUSY	CP	1
	JR	Z,V2_UNBUSY
	DEC	A
	LD	(SYSCALL_LEV),A
	POP	AF
	RET
V2_UNBUSY	POP	AF
	LD	(SYS_UNBUSYSP),SP
	LD	SP,(SYS_TEMPSP)
	PUSH	AF
	PUSH	AF
	LD	SP,(SYS_UNBUSYSP)
	POP	AF	;ret addr
	LD	SP,(SYS_TEMPSP)
	PUSH	AF
	DEC	SP
	DEC	SP
	XOR	A
	LD	(SYSCALL_LEV),A
	POP	AF
	RET
;
;
; Error routine. Print an error message.
;A=Error Number. If A>80H, then print the appropriate
;Dos error. If A>max_error then print error 0.
;
ERROR	OR	A
	RET	Z
	CALL	SYS_BUSY
	PUSH	AF
	CP	80H
	JR	NC,ERROR_DOS	;Print Dos error.
	CP	MAX_ERROR+1
	JR	C,V1_ERROR
	XOR	A	;Otherwise Undefined Error.
V1_ERROR	ADD	A,A
	LD	E,A
	LD	D,0
	LD	HL,ERROR_TABLE
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	CALL	MESSAGE_DO
	POP	AF
	CALL	SYS_UNBUSY
	RET
;
; Print a Dos-Oriented error message.
ERROR_DOS	CALL	DOS_ERROR	;Disp. Message.
	POP	AF
	CALL	SYS_UNBUSY
	RET
;
; Select appropriate memory space.
SELECT_MEMORY	PUSH	AF
	PUSH	HL
	AND	80H
	RRA
	RRA
	LD	H,A
	LD	A,(403DH)
	AND	0DFH
	OR	H
	LD	(403DH),A
	OUT	(255),A
	POP	HL
	POP	AF
	RET
;
; Move a line of text from HL to DE.
MOVE_LINE	PUSH	AF
V1_MOVE	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	CP	CR
	JR	NZ,V1_MOVE
	POP	AF
	RET
;
; Index: find the address of 'table(subscript)'.
;in: HL=address of start of table,
;    BC=length of each table entry,
;     A=subscript number (from 0 to #subscripts-1).
INDEX	OR	A
	JR	Z,V2_INDEX
V1_INDEX	ADD	HL,BC
	DEC	A
	JR	NZ,V1_INDEX
V2_INDEX	RET
;
; Sign_on: Print signing on message.
SIGN_ON	LD	HL,M_SIGN_ON
	CALL	MESSAGE_DO
	RET
M_SIGN_ON	DEFM	'Now executing Unix 1.00',CR
;
; Set_intrpt: Setup Interrupt catching mechanism.
SET_INTRPT	LD	HL,INTERRUPT	;address
	LD	(4013H),HL
	LD	A,0C3H
	LD	(4012H),A
	RET
;
; 'Vdu_out': Print byte in A to screen.
VDU_OUT	CALL	SYS_BUSY
	CALL	0033H
	CALL	SYS_UNBUSY
	RET
;
;
; Death of a process... (Ha Ha)
; 1) clean_death: for termination of system programs
;with no process to return to (eg. Booter).
;
CLEAN_DEATH	LD	A,1
	LD	(SYSCALL_LEV),A
	LD	A,DUMMY_PID
	LD	(CURR_PROCESS),A
	XOR	A
	LD	(SYSCALL_LEV),A
	JR	$
;
; 2) die: To let a running process finish itself off.
;
DIE	CALL	SYS_BUSY
	CALL	GETPID
V1_DIE	CALL	DEQUEUE
	JR	CLEAN_DEATH
;
; 3) kill: let a process kill another process.
;
KILL	CALL	SYS_BUSY
	PUSH	BC
	LD	B,A
	CALL	GETPID
	CP	B	;Is it killing itself?
	POP	BC
	JR	Z,V1_DIE	;if so, then die instead.
; Kill is meant to return to the caller!
	CALL	SYS_UNBUSY
	RET
;
;
; getpid: Get current processes ID.
GETPID	LD	A,(CURR_PROCESS)
	RET
;
