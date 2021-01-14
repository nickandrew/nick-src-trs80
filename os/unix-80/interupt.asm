;interupt/asm: Interrupt handling routine.
; Date: 19-Jul-84.
INTERRUPT	DI
	LD	(TEMP_STACK),SP	;for temporary sp.
	LD	SP,TEMP_REGS	;address of top of
; temporary register table.
	PUSH	AF
	LD	A,(37ECH)	;keep Dos happy!.
	LD	A,(37E0H)	;clear interrupts.
	LD	A,(SYSCALL_LEV)
	OR	A
	JR	Z,NEXT_PROCESS
;
	POP	AF
	LD	SP,(TEMP_STACK)
	EI	;No effect on memory/regs for syscalls.
	RET
;
; Not a system call in progress, so save registers
;for this process & execute next.
;
; Now Save all registers.
NEXT_PROCESS	POP	AF
	IFGT	SAVED_REGS,11
	EXX		;Swap register set.
	EX	AF,AF'
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	EX	AF,AF'	;Swap register set back.
	EXX
	ENDIF
;
	IFGT	SAVED_REGS,7	;if 8 or 12.
	PUSH	IY		;save IX & IY.
	PUSH	IX
	ENDIF
;
	PUSH	HL		;Push standard registers.
	PUSH	DE		;HL,DE,BC,AF,PC,SP.
	PUSH	BC
	PUSH	AF
; Find previous program counter.
	LD	SP,(TEMP_STACK)
	POP	HL	;Reti address.
	LD	(T_REGS_START+2),HL	;Save proc. PC.
;Now save prior process's stack pointer.
	LD	(T_REGS_START),SP	;Save SP.
;
	LD	SP,SYSTEM_STACK	;get system SP.
;
; All registers are now saved so move them to the
;appropriate register table entry.
;
	LD	A,(CURR_PROCESS) ;get current process #.
; If (curr_process)=dummy_pid (ie. to let a non process
;die cleanly, then save registers in dummy_proc_reg
;(just after proc_register table) and effectively
;throw them away.
;
	LD	HL,PROC_REGISTER
	LD	BC,SAVED_REGS*2
	CALL	INDEX
	EX	DE,HL
;
; Now save registers into process's table entry.
	LD	HL,T_REGS_START
	LD	BC,SAVED_REGS*2
	LDIR
;All required registers are saved in the register
;table for the correct process. Now find which
;process is to be executed next.
;
;
*GET PRIORITY	;returns 'A' = next process.
;
; Set next process number to value in A.
	LD	(CURR_PROCESS),A
;
; Find which memory is being used by the next process
;and select the appropriate memory space.
;
	LD	HL,PROC_ADDRESS
	LD	BC,2
	CALL	INDEX
	LD	A,(HL)	;starting block number.
	CALL	SELECT_MEMORY
;
; Now do the opposite of saving the registers.
;Move saved regs. to temporary table & restore them
;from there.
	LD	HL,PROC_REGISTER
	LD	BC,SAVED_REGS*2
	LD	A,(CURR_PROCESS)
	CALL	INDEX
	LD	DE,T_REGS_START
	LD	BC,SAVED_REGS*2
	LDIR
	LD	SP,T_REGS_START
	POP	HL
	LD	(TEMP_STACK),HL
	POP	HL	;pop new pc & save as new jp add.
	LD	(JP_ADDR),HL
	POP	AF
	POP	BC	;pop other registers.
	POP	DE
	POP	HL
;
;Now for optional extra registers.
	IFGT	SAVED_REGS,7
	POP	IX	;Restore IX & IY.
	POP	IY
	ENDIF
;
	IFGT	SAVED_REGS,11
	EXX
	EX	AF,AF'
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	EX	AF,AF'
	EXX
	ENDIF
;
; Get back old SP and use prior pushed PC to execute
;process.
	LD	SP,(TEMP_STACK)
	EI
	JP	0000H	;Jump to process.
JP_ADDR	EQU	$-2	;Address to poke.
;Process is now executing.
;
