;Master Assembly file.
; Date: 19-Jul-84.
; For runtime version: 1.0015.
;
;Complete Source code (through INCLUDEs) for process
; system including kernel and table, buffer structure.
;Now include all master labels (relevant globally).
;
*GET GLOBEQU
;
;Also include macro definitions.
*GET MACROS
;
;KERNEL_ORIGIN is lowest memory address not dedicated
;  to either dos (if running under Newdos/80)
;  or dedicated device memory (in any case).
;
	ORG	KERNEL_ORIGIN
;
; Flags and other data follow...
*GET TABLES
; Tables for processes etc...
*GET FLAGS
;
; Now, the starting point for execution.
UNIX_START	NOP
;
;Include bootstrap code (newdos/80 & otherwise).
*GET BOOTER
;
; If debugging then include the debug module.
	IF	DEBUG
*GET DEBUG
	ENDIF
; Now include the code to handle interrupts
; and run processes.
*GET INTERUPT
;
; Now include general subroutines.
*GET SUBROUT
;
;Include Disk I/O subroutines ie. read/write on
; files, etc...
*GET DISKIO
;
; Lastly, code to enqueue and dequeue processes.
*GET PROCESS
;
;
ZZZZZ	EQU	$	;last address used.
;
; All the code is included, it must now finish.
; The start for execution is 'unix_start'.
	END	UNIX_START
;
; (C) 1984, Nick Andrew.
;
