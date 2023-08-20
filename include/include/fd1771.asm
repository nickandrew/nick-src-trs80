; WD1771/FD1771 Floppy Disk Controller registers/commands
; Based on the FD1771 datasheet at https://deramp.com/downloads/floppy_drives/FD1771%20Floppy%20Controller.pdf

FDC_DISK_SELECT$		EQU	37E1H	; Disk drive select
FDC_STATUS$			EQU	37ECH	; FDC Status/Command register
FDC_COMMAND$			EQU	37ECH	; FDC Status/Command register
FDC_TRACK$			EQU	37EDH	; FDC Track register
FDC_SECTOR$			EQU	37EEH	; FDC Sector register
FDC_DATA$			EQU	37EFH	; FDC Data register

FDC_CMD_RESTORE			EQU	000H	; Seek to track 0
FDC_CMD_SEEK			EQU	010H	; Seek to track N
FDC_CMD_STEP			EQU	020H	; Step (same direction as last)
FDC_CMD_STEP_IN			EQU	040H	; Step in (fast stepping rate)
FDC_CMD_STEP_OUT		EQU	060H	; Step in (fast stepping rate)
FDC_CMD_READ			EQU	080H	; Read Command
FDC_CMD_WRITE			EQU	0A0H	; Write Command
FDC_CMD_READ_ADDRESS		EQU	0C4H	; Read Address
FDC_CMD_READ_TRACK		EQU	0E4H	; Read Track
FDC_CMD_WRITE_TRACK		EQU	0F4H	; Write track
FDC_CMD_FORCE_INTERRUPT		EQU	0D0H	; Force Interrupt

; Stepping rates (.OR. this with RESTORE, SEEK, STEP, STEP IN, STEP OUT commands)
FDC_STEP_RATE_0			EQU	0	; The fastest step rate
FDC_STEP_RATE_1			EQU	1
FDC_STEP_RATE_2			EQU	2
FDC_STEP_RATE_3			EQU	3	; The slowest step rate

; Head Load flag (Used with RESTORE, SEEK, STEP, STEP IN, STEP OUT commands)
FDC_LOAD_HEAD			EQU	8

; Verify flag (Used with RESTORE, SEEK, STEP, STEP IN, STEP OUT commands)
FDC_VERIFY			EQU	4	; Verify on last track

; Update Track Register (Used with STEP, STEP IN, STEP OUT commands)
FDC_UPDATE			EQU	10H	; Update track register

; Multiple Record flag (Used with READ, WRITE commands)
FDC_MULTIPLE			EQU	10H	; Multiples

; Block length flag (Used with READ, WRITE commands)
FDC_BLOCK_LENGTH_IBM		EQU	8	; IBM format (128 to 1024 bytes)

; Enable HLD and 10 msec Delay flag
FDC_ENABLE_HLD_DELAY		EQU	4	; Enable HLD, HLT and 10 msec Delay

; Data Address Marks (Used with WRITE command)
FDC_DATA_MARK			EQU	0	; Data Mark
FDC_USER_DEFINED_1		EQU	1	; User defined
FDC_USER_DEFINED_2		EQU	2	; User defined
FDC_DELETED_DATA_MARK		EQU	3	; Deleted Data Mark

; Synchronize flag (Used with READ TRACK command)
FDC_SYNCHRONIZE			EQU	0	; Synchronize to AM
FDC_NO_SYNCHRONIZE		EQU	1	; Do Not Synchronize to AM

; Interrupt Condition flags (Used with FORCE INTERRUPT command)
FDC_INT_NR_TO_R			EQU	1	; Not Ready to Ready Transition
FDC_INT_R_to_NR			EQU	2	; Ready to Not Ready Transition
FDC_INT_INDEX			EQU	4	; Index Pulse
FDC_INT_IMMEDIATE		EQU	8	; Immediate interrupt
