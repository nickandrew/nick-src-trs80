; Tables/asm: Process and other tables.
; Date: 19-Jul-84.
;
; The most important table: for system call addresses
;so this source may be re-assembled without requiring
;re-assembly of all the applications programs!
; Used for things like opening files, creating new
;processes etc...
;
SYSCALL_TABLE	EQU	$
SYS_ASSIGN_PROC	JP	ASSIGN_PROC
SYS_ENQUEUE	JP	ENQUEUE
SYS_VDU_OUT	JP	VDU_OUT
SYS_MESSAGE_DO	JP	MESSAGE_DO
SYS_ERROR	JP	ERROR
SYS_GETPID	JP	GETPID
SYS_DIE	JP	DIE
SYS_KILL	JP	KILL
END_SYS_TABLE	DEFB	NULL,NULL,NULL
;
;
; 1) Process assigned table. One byte for each
;process. is 'TRUE' if the process is assigned, 'FALSE'
;otherwise.
	TAB_START	'Pid'
PID_ASSIGNED	DEFS	MAX_PROCESS
;
; 2) Process priority table. 1 Byte each pid, values
;from 'min_priority' to max_priority', or 'null' if
;no process assigned this pid.
	TAB_START	'Pri'
PROC_PRIORITY	DEFS	MAX_PROCESS
;
; 3) Process address space table. 2 bytes each pid,
;first byte is starting block, 2nd byte is ending
;block. Permissible block contents are:
; 00H - 7FH: Range 8000 - FFFF memory zero.
; 80H - FFH: Range 8000 - FFFF memory one.
; A process must fit entirely within one memory space.
	TAB_START	'Add'
PROC_ADDRESS	DEFS	MAX_PROCESS*2
;
; 4) Saved register table. The number of registers
;saved for each process will be either:
; 6: SP, PC, AF BC DE HL, or
; 8: Above plus IX & IY,  or
;12: Above plus alternate AF BC DE HL.
; In that order, too.
;
	TAB_START	'Reg'
PROC_REGISTER	DEFS	MAX_PROCESS*SAVED_REGS*2
DUMMY_PROC_REG	DEFS	SAVED_REGS*2
; 'dummy_proc_reg' is the same length as one entry
;in the process register table and is used when
;transferring from executing system code to executing
;processes and there is no specific process to which
;the system code may return.
;
;
; Memory Assigned Table. 256 Bytes long, values
;'TRUE' if that block (see proc_address) is assigned,
;'FALSE' otherwise.
	TAB_START	'Mem'
MEM_ASSIGNED	DEFS	256
;
; Temporary Register table. Used only by interrupt
;handler for quick storage of registers.
	TAB_START	'TReg'
T_REGS_START	DEFS	SAVED_REGS*2
TEMP_REGS	EQU	$	;top of previous table.
;
TEMP_STACK	DEFW	0	;previous SP value.
;
; Process I-O redirection table. Contains 3 bytes for
;each process standard file: stdin,stdout & stderr.
;for non running processes, the 3 bytes are set to
; 0,1,2 (as with most assigned processes too).
	TAB_START	'IO'
REDIRECT_TABLE	DEFS	MAX_PROCESS*3
;
; System command & general buffer.
	TAB_START	'Buff'
SYS_BUFFER	DEFS	80H
;
; Errors: Table of error messages & addresses.
;
; Maximum error message number.
MAX_ERROR	EQU	7
;
	TAB_START	'Err'
ERROR_TABLE	DEFW	ERR_00
	DEFW	ERR_01
	DEFW	ERR_02
	DEFW	ERR_03
	DEFW	ERR_04
	DEFW	ERR_05
	DEFW	ERR_06
	DEFW	ERR_07
	DEFW	NULL
;
	TAB_START	'Msg'
ERR_00	DEFM	'Undefined Error Code.',CR
ERR_01	DEFM	'Process Enqueueing error.',CR
ERR_02	DEFM	'Rebooting system.',CR
ERR_03	DEFM	'Bootstrapping error.',CR
ERR_04	DEFM	'INIT process 0 file does not exist!',CR
ERR_05	DEFM	'No more processes!',CR
ERR_06	DEFM	'Cant ALLOC - out of memory!',CR
ERR_07	DEFM	'Cant extract filespec.',CR
;
