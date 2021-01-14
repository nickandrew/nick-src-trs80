; Inittab/asm: Initialise all tables & flags.
; Date: 17-Jul-84.
	IF	DEBUG
	MESS	M1_INITTAB
	JR	P1_INITTAB
M1_INITTAB	DEFM	'Now init-tables.',0DH
P1_INITTAB	NOP
	ENDIF
;
	LD	HL,PID_ASSIGNED
	LD	BC,MAX_PROCESS
	LD	A,FALSE
	CALL	FILL_MEM
;
; Clear Process Priority table.
	LD	HL,PROC_PRIORITY
	LD	BC,MAX_PROCESS
	LD	A,FALSE
	CALL	FILL_MEM
;
; Clear Process Address table.
	LD	HL,PROC_ADDRESS
	LD	BC,MAX_PROCESS*2
	LD	A,NULL
	CALL	FILL_MEM
;
; Clear Process Register table.
	LD	HL,PROC_REGISTER
	LD	BC,MAX_PROCESS*SAVED_REGS*2
	LD	A,NULL
	CALL	FILL_MEM
;
; Clear Memory Assigned Table.
	LD	HL,MEM_ASSIGNED
	LD	BC,0100H
	LD	A,FALSE
	CALL	FILL_MEM
;
; Clear temporary register and stack storage table/flag.
	LD	HL,T_REGS_START
	LD	BC,SAVED_REGS*2
	LD	A,NULL
	CALL	FILL_MEM
;
	LD	HL,TEMP_STACK
	LD	BC,2
	LD	A,NULL
	CALL	FILL_MEM
;
; Clear redirection table (0=stdin,1=stdout,2=stderr).
	LD	HL,REDIRECT_TABLE
	LD	B,MAX_PROCESS
V0_INIT	LD	(HL),STDIN
	INC	HL
	LD	(HL),STDOUT
	INC	HL
	LD	(HL),STDERR
	INC	HL
	DJNZ	V0_INIT
;
; Now clear sys_buffer (system buffer).
	LD	HL,SYS_BUFFER
	LD	BC,80H
	LD	A,NULL
	CALL	FILL_MEM
;
; Now clear flags.
	LD	HL,HIGH_MEMORY-STACK_LEN
	LD	(UNIX80_HIMEM),HL
;
