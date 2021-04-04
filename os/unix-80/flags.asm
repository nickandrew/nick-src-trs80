;Flags/asm: Flag names and definitions.
; Date: 19-Jul-84.
;
;
;the 'System-Call Levels' flag. Used with system
;calls to force an interrupt to return to the caller.
;  Possible values:
; 00H: Not running a system routine right now.
; xxH: Running system routine, interrupt handler must
;return without altering anything.
;The value
;of this byte represents the number of levels of
;system calls executing._
	TAB_START	'syscall_lev'
SYSCALL_LEV	DEFB	NULL
;
; 'current process pid' flag. Is set to the number
;of the current process (00-max_process-1).
	TAB_START	'curr_process'
CURR_PROCESS	DEFB	NULL
;
; Current High Memory flag. Is decremented by
;'alloc' and incremented by 'unalloc'. Hopefully,
; system calls using alloc and unalloc will only
;unalloc buffers alloc'ed by itself and will unalloc
;all buffers it allocs.
; Its initially set to the last address of truly
;free memory.
;
	TAB_START	'himem'
UNIX80_HIMEM	DEFW	END_FREE_MEM
;
; sys_busy and sys_unbusy temporary storage.
	TAB_START	'B/U:SP'
SYS_TEMPSP	DEFW	NULL
SYS_UNBUSYSP	DEFW	NULL
;
;
; Assign-(mem,pid,reg) flags.
	TAB_START	'Ass_'
ASS_REPT	DEFB	FALSE
ASS_BLKS	DEFB	NULL
ASS_PID	DEFB	NULL
ASS_MEM	DEFB	NULL
;
; Enqueue flags.
	TAB_START	'Enq_'
ENQ_PID	DEFB	NULL
ENQ_PRI	DEFB	NULL
ENQ_FCB	DEFW	NULL
ENQ_BUFFER	DEFW	NULL
ENQ_BLOCKS	DEFW	NULL
;
; Storage for FCB and FCB_BUFFER addresses.
; used by file open/close/read/write for system only.
	TAB_START	'Fcb'
SYS_FCB	DEFW	NULL
SYS_FCB_BUFF	DEFW	NULL
;
