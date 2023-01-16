;Booter/asm: Bootstrap program.
; Date: 19-Jul-84.
;
;Performs the following actions:
; 1) Initialise all status (flags, tables etc...)
; 2) Setup all links into Dos (if Dos-based).
; 3) Setup 'INIT' process as pid #0.
; 4) Execute INIT.
;
	DI	;How to start every program!
	XOR	A
	LD	SP,SYSTEM_STACK	;init SP.
;
	IF	STAND_ALONE	;initialise devices
*GET	INITDEV
	ENDIF
;
; Set syscall level to 1 to print messages.
	LD	A,1
	LD	(SYSCALL_LEV),A
;
; Now initialise interrupts.
	CALL	SET_INTRPT
;
; Now initialise all tables & flags.
*GET	INITTAB
;
; Set 'system call level' to 1 to stop the interrupt
;handler trying to execute nonexistent processes.
; Set the 'current' process number to dummy_pid to
;leave registers in a dummy pid register table entry
;when an interrupt is next recognized.
;
	LD	A,1
	LD	(SYSCALL_LEV),A
	LD	A,DUMMY_PID
	LD	(CURR_PROCESS),A
;
; Enable interrupts (now its okay).
	IM	1	;Jump to 0038H on interrupt.
	EI	;Interrupt invariably occurs here!
;
; Print 'Hello' message.
	CALL	SIGN_ON
;
; Now start a process running. Name is 'init',
;process Id is 0.
	LD	HL,BOOT_BUFFER	;Name is 'init'.
	LD	A,MAX_PRIORITY	;Maximum Priority.
	CALL	SYS_ENQUEUE	;load & start process.
	JR	NZ,BOOT_ERROR
;
; 'A' now holds process number of init (must be zero).
; sys_enqueue returns NZ if an error encountered.
;
	IF	DEBUG
; Start another process (init2).
	LD	HL,BOOT_BUFFER2
	LD	A,MAX_PRIORITY
	CALL	SYS_ENQUEUE
	JR	NZ,BOOT_ERROR
	ENDIF
;
; Now die gracefully (ie. start processes going).
	JP	CLEAN_DEATH
;
; If debug enabled, execute 'init2' as well as 'init'
;as background processes.
;
	IF	DEBUG
BOOT_BUFFER2	DEFM	'INIT2/PR',CR
	ENDIF
;
; If an error occurs while booting, jump here.
BOOT_ERROR	CALL	ERROR
	LD	A,2	;'Rebooting system'.
	CALL	ERROR
	JP	EXIT_ADDR
;
	IF	NEWDOS_80
BOOT_BUFFER	DEFM	'INIT/PR',CR
	ELSE
BOOT_BUFFER	DEFM	'init',CR
	ENDIF
