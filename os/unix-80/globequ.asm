;Globequ/asm: Global Equates file.
; Date: 19-Jul-84.
;True & False values for flags and otherwise.
TRUE	EQU	1	;Normal true & false.
FALSE	EQU	0
F_TRUE	EQU	TRUE	;Flag true & false.
F_FALSE	EQU	FALSE
;
; Miscellaneous values.
NULL	EQU	00H
EOT	EQU	04H
CR	EQU	0DH
;
;Assembly type (running under Newdos/80 or standalone).
;Set NEWDOS_80 = TRUE to run under Newdos/80.
;Set NEWDOS_80 = FALSE for standalone system.
NEWDOS_80	EQU	TRUE
STAND_ALONE	EQU	NEWDOS_80.XOR.1
;
; Debugging type constants (for ifs & endifs).
; Set 'debug' equal to 'TRUE' if debugging, 'FALSE'
;otherwise.
DEBUG	EQU	TRUE
; Set 'messages' = 'TRUE' if messages are to be used.
MESSAGES	EQU	TRUE
; Show puts '**' between each table.
SHOW	EQU	TRUE
;
;
;Memory allocation.
	IF	NEWDOS_80
LOW_MEMORY	EQU	5200H
HIGH_MEMORY	EQU	7FFFH
EXIT_ADDR	EQU	402DH
	ELSE
LOW_MEMORY	EQU	4300H
HIGH_MEMORY	EQU	7FFFH
EXIT_ADDR	EQU	0000H
	ENDIF
;
;Kernel origin is at LOW_MEMORY.
KERNEL_ORIGIN	EQU	LOW_MEMORY
;
; Data on Maximum processes & process priority.
MAX_PROCESS	EQU	10H
MAX_PRIORITY	EQU	01H
MIN_PRIORITY	EQU	0FH
DUMMY_PID	EQU	MAX_PROCESS
; 'The process which can execute but is unassigned'.
;
; How long should the stack be?
STACK_LEN	EQU	0100H
;
; Number of registers to save for each process.
; Must be one of (6,8,12). Registers are saved in this
; order: SP  PC  AF  BC  DE  HL  IX  IY  AF' BC' DE' HL'.
SAVED_REGS	EQU	6
;
; File Descriptors for process stdin,stdout & stderr.
STDIN	EQU	0
STDOUT	EQU	1
STDERR	EQU	2
;
; System device numbers... (File Descriptors for
;process use, must be >=3 otherwise std files are used.
DEV_CONSOLE	EQU	3	;Kbd/Vdu In-Out.
DEV_PRINTER	EQU	4	;Printer - Output only.
DEV_RS232	EQU	5	;RS-232 - In-Out.
;
; System stack pointer address.
SYSTEM_STACK	EQU	HIGH_MEMORY+1
;
; Set the top of free memory for use by HIMEM, alloc
;and unalloc.
END_FREE_MEM	EQU	HIGH_MEMORY-STACK_LEN
;
