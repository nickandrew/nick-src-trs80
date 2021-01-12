; LDOS51.ASM ... LDOS symbolic references
; Source materials:
;   1. http://www.manmrk.net/tutorials/TRS80/Software/ldos/trs80/doc/ld51man3.pdf
;       LDOS 5.1.x, Model III, Second Edition.
;   2. ld51manr.djvu

; LDOS for the Model 1 and Model 3 have many different call vectors. The differences,
; so far as they can be determined, are in the top IF blocks.

; The label names are taken from the source materials. The different manuals sometimes
; publish a different name for the same thing:
;   TSTBSY vs RSELCT
;   WRSEC vs WRSECT
;   WRSYS vs WRPROT
;   WECYL vs WRTRK
;   RDSEC vs RDSECT
;   DIVIDE vs @DIV
;   MULT vs @MULT

	IFDEF	MODEL1
@RAMDIR		EQU	4396H	; Read visible files or get freespace (HL, B, C)
@CMD		EQU	4400H	; Normal return to LDOS (same as @EXIT)
@CMNDI		EQU	4405H	; Return to LDOS and execute command line in HL
@ADTSK		EQU	4410H	; Add an interrupt level task to the RTC task table
@RMTSK		EQU	4413H	; Remove interrupt level task from task control block table
@RPTSK		EQU	4416H	; Exit the task process executing and replace task vector address
@KLTSK		EQU	4419H	; Remove task assignment from the task table
@CKEOF		EQU	444BH	; Check for EOF at the current logical record number (DE: FCB)
@WEOF		EQU	444EH	; Update the directory entry with the current EOF (DE: FCB)
@RREAD		EQU	4454H	; Re-read current sector (DE: FCB)
@RWRIT		EQU	4457H	; Rewrite current sector (DE: FCB)
@LOC		EQU	445AH	; Calculate the current logical record number (DE: FCB)
@LOF		EQU	445DH	; Calculate the EOF logical record number (DE: FCB)
@SKIP		EQU	4460H	; Skip next logical record (DE: FCB)
@DODIR		EQU	4463H	; Read visible files or find freespace and display (C, B, HL)
@TIME		EQU	446DH	; Get current time in display format (HL: buffer)
@DATE		EQU	4470H	; Get current date in display format (HL: buffer)
@FEXT		EQU	4473H	; Insert a default file extension (DE: FCB, HL: 3-char ext)
@PARAM		EQU	4476H	; Parse optional parameter string (DE: table, HL: cmdline)
@MSG		EQU	4479H	; Send a message to any device (DE: FCB, HL: buf)
@LOGOT		EQU	447BH	; Display and log a message (HL: buf)
@LOGER		EQU	447EH	; Issue a log message to the Job Log (HL: buf)
@CKDRV		EQU	44B8H	; Check a drive exists and contains a formatted diskette (C: drive)
@FNAME		EQU	44BBH	; Recover filename and extension from directory (DE: buf, B: DEC, C)
MULT		EQU	44C1H	; Multiply 16 bit x 8 bit = 24 bit (HL * A)
DIVIDE		EQU	44C4H	; Divide 16 bit unsigned by 8 bit unsigned (HL / A)
DIRCYL		EQU	4B65H	; Return directory cylinder# for the requested drive
MULTEA		EQU	4B6CH	; Do 8 bit x 8 bit unsigned integer multiplication (A x E)
DIVEA		EQU	4B7BH	; Do 8 bit unsigned integer divide (E / A)
ENDIF

	IFDEF	MODEL3
@DATE		EQU	3033H	; Get current date in display format (HL: buffer)
@TIME		EQU	3036H	; Get current time in display format (HL: buffer)
@ADTSK		EQU	403DH	; Add an interrupt level task to the RTC task table
@RMTSK		EQU	4040H	; Remove interrupt level task from task control block table
@RPTSK		EQU	4043H	; Exit the task process executing and replace task vector address
@KLTSK		EQU	4046H	; Remove task assignment from the task table
@CKDRV		EQU	4209H	; Check a drive exists and contains a formatted diskette (C: drive)
				; Could be documented wrongly as 4290H
@LOGOT		EQU	428AH	; Display and log a message (HL: buf)
@LOGER		EQU	428DH	; Issue a log message to the Job Log (HL: buf)
@RAMDIR		EQU	4290H	; Read visible files or get freespace (HL, B, C)
@FNAME		EQU	4293H	; Recover filename and extension from directory (DE: buf, B: DEC, C)
@CMD		EQU	4296H	; Normal return to LDOS (same as @EXIT)
@CMNDI		EQU	4299H	; Return to LDOS and execute command line in HL
@MSG		EQU	4402H	; Send a message to any device (DE: FCB, HL: buf)
@DODIR		EQU	4419H	; Read visible files or find freespace and display (C, B, HL)
@FEXT		EQU	444BH	; Insert a default file extension (DE: FCB, HL: 3-char ext)
MULT		EQU	444EH	; Multiply 16 bit x 8 bit = 24 bit (HL * A)
DIVIDE		EQU	4451H	; Divide 16 bit unsigned by 8 bit unsigned (HL / A)
@PARAM		EQU	4454H	; Parse optional parameter string (DE: table, HL: cmdline)
@CKEOF		EQU	4458H	; Check for EOF at the current logical record number (DE: FCB)
@WEOF		EQU	445BH	; Update the directory entry with the current EOF (DE: FCB)
@RREAD		EQU	445EH	; Re-read current sector (DE: FCB)
@RWRIT		EQU	4461H	; Rewrite current sector (DE: FCB)
@SKIP		EQU	4464H	; Skip next logical record (DE: FCB)
@LOC		EQU	446DH	; Calculate the current logical record number (DE: FCB)
@LOF		EQU	4470H	; Calculate the EOF logical record number (DE: FCB)
DIRCYL		EQU	4B64H	; Return directory cylinder# for the requested drive
MULTEA		EQU	4B6BH	; Do 8 bit x 8 bit unsigned integer multiplication (A x E)
DIVEA		EQU	4B7AH	; Do 8 bit unsigned integer divide (E / A)
ENDIF

; Program Control Routines

@ABORT		EQU	4030H	; Abnormal program exit and return to LDOS
@EXIT		EQU	402DH	; Normal return to LDOS

; LDOS Control Vectors

@DEBUG		EQU	440DH	; Enter debug
@ERROR		EQU	4409H	; Display an error message and optionally abort

; Disk I/O Primitives

SELECT		EQU	4754H	; Select a drive (C: drive# 0-7)
TSTBSY		EQU	4759H	; Test if last selected drive is in a busy state
SEEK		EQU	475EH	; Seek to a specified cylinder (C: drive#, D: cylinder)
WRSEC		EQU	4763H	; Write a sector to disk (HL: data, D: cyl, E: sec, C: drive)
WRSYS		EQU	4768H	; Write a system sector (directory). Registers as per WRSEC
WRCYL		EQU	476DH	; Format a cylinder (HL: data, D: cyl, C: drive)
VERSEC		EQU	4772H	; Verify a sector (D: cyl, E: sec, C: drive)
RDSEC		EQU	4777H	; Read a sector (HL: buffer, D: cyl, E: sec, C: drive)

; File Control Routines

@CLOSE		EQU	4428H	; Close a file or device (DE: File or Device Control Block)
@FSPEC		EQU	441CH	; Fetch a file or device spec (HL: buffer, DE: FCB)
@INIT		EQU	4420H	; Open an existing file or create new (HL: buffer, DE: FCB, B: LRL)
@KILL		EQU	442CH	; Kill (delete) a file or device (DE: FCB)
@OPEN		EQU	4424H	; Open an existing file (HL: buffer, DE: FCB, B: LRL)

; Program Loading Control Routines

@LOAD		EQU	4430H	; Load a program file (DE: FCB)
@RUN		EQU	4433H	; Load and execute a program file (DE: FCB)

; Disk File Handler Routines

@BKSP		EQU	4445H	; Backspace 1 logical record (DE: FCB)
@PEOF		EQU	4448H	; Position an open file to EOF (DE: FCB)
@POSN		EQU	4442H	; Position a file to a logical record (DE: FCB, BC: LR#)
@READ		EQU	4436H	; Read a logical record from a file (DE: FCB, HL: UREC)
@REW		EQU	443FH	; Rewind a file to the beginning (DE: FCB)
@VER		EQU	443CH	; Write followed by a test read (DE: FCB)
@WRITE		EQU	4439H	; Write next logical record (DE: FCB, HL: UREC)

; General Purpose Routines

@DSPLY		EQU	4467H	; Display a message ending with 0x0d or 0x03. (HL: buf)
@PRINT		EQU	446AH	; Output a message line to the printer (HL: buf)

; Rom-resident I/O routines and vectors

@CTL		EQU	0023H	; Output a control byte to a device or file (DE: FCB, A: byte)
@DSP		EQU	0033H	; Output a byte to the video display (A: byte)
@GET		EQU	0013H	; Fetch a byte from a device or file (DE: FCB)
@KBD		EQU	002BH	; Scan keyboard and return key, if pressed
@KEY		EQU	0049H	; Scan keyboard and wait for a key to be pressed
@KEYIN		EQU	0040H	; Wait for a line of keyboard input (HL: buf, B: len)
@PAUSE		EQU	0060H	; Busy wait (M1:14.67uS, M3:14.796uS) per count (BC: count)
@PRT		EQU	003BH	; Output a byte to the printer (A: byte)
@PUT		EQU	001BH	; Output a byte to device or file (DE: FCB, A: byte)
@WHERE		EQU	000BH	; Resolve relocation address of calling routine

; Special Purpose Routines - Miscellaneous

GETDCT		EQU	478FH	; Return address of drive code table (C: drive)
DCTBYT		EQU	479CH	; Recover a byte field from drive code table (C: drive, A: byte)
DIRRD		EQU	4B10H	; Read a directory sector (B: DEC, C: drive)
DIRWR		EQU	4B1FH	; Write a directory sector (B: DEC, C: drive)
RDSSEC		EQU	4B45H	; Read the system sector (HL: buf, D: cyl, E: sec, C: drive)

; Supervisory Calls (System calls: load A register, do RST 28H)

SVC_RESERVED	EQU	00H	; Reserved for future use
SVC_KEY		EQU	01H	; Scan keyboard, wait for character
SVC_DSP		EQU	02H	; Display character at cursor, advance cursor
SVC_GET		EQU	03H	; Get one byte from a logical device
SVC_PUT		EQU	04H	; Write one byte to a logical device
SVC_CTL		EQU	05H	; Make a control request to a logical device
SVC_PRT		EQU	06H	; Send character to the line printer
SVC_WHERE	EQU	07H	; Locate origin of CALL
SVC_KBD		EQU	08H	; Scan keyboard and return
SVC_KEYIN	EQU	09H	; Accept a line of input
SVC_DSPLY	EQU	0AH	; Display a message line
SVC_LOGER	EQU	0BH	; Issue a log message
SVC_LOGOT	EQU	0CH	; Display and log a message
SVC_MSG		EQU	0DH	; Message line handler
SVC_PRINT	EQU	0EH	; Print a message line
SVC_RES_0F	EQU	0FH
SVC_PAUSE	EQU	10H	; Suspend program execution
SVC_PARAM	EQU	11H	; Parse an optional parameter string
SVC_DATE	EQU	12H	; Get system date in the format MM/DD/YY
SVC_TIME	EQU	13H	; Get system time in the format HH:MM:SS
SVC_RES_14	EQU	14H
SVC_ABORT	EQU	15H	; Abnormal program exit and return to LDOS
SVC_EXIT	EQU	16H	; Normal program exit and return to LDOS
SVC_CMD		EQU	17H	; Accept a new command
SVC_CMNDI	EQU	18H	; Entry to command interpreter
SVC_RES_19	EQU	19H
SVC_ERROR	EQU	1AH	; Entry to post an error message
SVC_DEBUG	EQU	1BH	; Enter the debugging package
SVC_RES_1C	EQU	1CH
SVC_ADTSK	EQU	1DH	; Add an interrupt level task
SVC_RMTSK	EQU	1EH	; Remove an interrupt level task
SVC_RPTSK	EQU	1FH	; Replace the currently executing task vector
SVC_KLTSK	EQU	20H	; Remove the currently executing task
SVC_CKDRV	EQU	21H	; Check for drive availability
SVC_DODIR	EQU	22H	; Do a directory display/buffer
SVC_SELECT	EQU	29H	; Select a new drive
SVC_SEEK	EQU	2EH	; Seek a cylinder
SVC_RSELCT	EQU	2FH	; Test if requested drive is busy
SVC_RDSECT	EQU	31H	; Read a sector
SVC_VERSEC	EQU	32H	; Verify a sector
SVC_WRSECT	EQU	35H	; Write a sector
SVC_WRPROT	EQU	36H	; Write a system sector
SVC_WRTRK	EQU	37H	; Write a cylinder
SVC_KILL	EQU	39H	; Kill a file or device
SVC_INIT	EQU	3AH	; Open or initialize a file or device
SVC_OPEN	EQU	3BH	; Open an existing file or device
SVC_CLOSE	EQU	3CH	; Close a file or device
SVC_BKSP	EQU	3DH	; Backspace one logical record
SVC_CKEOF	EQU	3EH	; Check for end of file
SVC_LOC		EQU	3FH	; Calculate the current logical record number
SVC_LOF		EQU	40H	; Calculate the EOF logical record number
SVC_PEOF	EQU	41H	; Position to the end of file
SVC_POSN	EQU	42H	; Position a file to a logical record
SVC_READ	EQU	43H	; Read a record from a file
SVC_REW		EQU	44H	; Rewind a file to its beginning
SVC_RREAD	EQU	45H	; Reread the current sector
SVC_RWRIT	EQU	46H	; Rewrite the current sector
SVC_SKIP	EQU	48H	; Skip the next record
SVC_VER		EQU	49H	; Write then verify a record to a file
SVC_WEOF	EQU	4AH	; Write end of file
SVC_WRITE	EQU	4BH	; Write a record to a file
SVC_LOAD	EQU	4CH	; Load a program file
SVC_RUN		EQU	4DH	; Load and execute a program file
SVC_FSPEC	EQU	4EH	; Fetch a file or device specification
SVC_FEXT	EQU	4FH	; Set up a default file extension
SVC_FNAME	EQU	50H	; Fetch filename/ext from directory
SVC_GETDCT	EQU	51H	; Get Drive Code Table address
SVC_DIRCYL	EQU	53H	; Get the directory cylinder number
SVC_RDSSEC	EQU	55H	; Read a SYSTEM sector
SVC_DIRRD	EQU	57H	; Directory record read
SVC_DIRWR	EQU	58H	; Directory record write
SVC_MULTEA	EQU	5AH	; 8-bit by 8-bit unsigned integer multiplication
SVC_MULT	EQU	5BH	; 16-bit by 8-bit unsigned integer multiplication
SVC_DIVEA	EQU	5DH	; 8-bit unsigned integer divide
SVC_DIV		EQU	5EH	; 16-bit by 8-bit unsigned integer divide
SVC_HIGH	EQU	64H	; Get or Set the highest unused RAM address
