; LDOS51.ASM ... LDOS technical details
; Source: http://www.manmrk.net/tutorials/TRS80/Software/ldos/trs80/doc/ld51man3.pdf
; Manual is LDOS 5.1.x, Model III, Second Edition.
;
; Data is for the LDOS 5.1.x, Model 3

; Program Control Routines

@ABORT		EQU	4030H	; Abnormal program exit and return to LDOS
@EXIT		EQU	402DH	; Normal return to LDOS

; LDOS Control Vectors

@ADTSK		EQU	403DH	; Add an interrupt level task to the RTC task table
@CMD		EQU	4296H	; Normal return to LDOS (same as @EXIT)
@CMNDI		EQU	4299H	; Return to LDOS and execute command line in HL
@DEBUG		EQU	440DH	; Enter debug
@ERROR		EQU	4409H	; Display an error message and optionally abort
@KLTSK		EQU	4046H	; Remove task assignment from the task table
@RMTSK		EQU	4040H	; Remove interrupt level task from task control block table
@RPTSK		EQU	4043H	; Exit the task process executing and replace task vector address

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
@FEXT		EQU	444BH	; Insert a default file extension (DE: FCB, HL: 3-char ext)
@FSPEC		EQU	441CH	; Fetch a file or device spec (HL: buffer, DE: FCB)
@INIT		EQU	4420H	; Open an existing file or create new (HL: buffer, DE: FCB, B: LRL)
@KILL		EQU	442CH	; Kill (delete) a file or device (DE: FCB)
@OPEN		EQU	4424H	; Open an existing file (HL: buffer, DE: FCB, B: LRL)

; Program Loading Control Routines

@LOAD		EQU	4430H	; Load a program file (DE: FCB)
@RUN		EQU	4433H	; Load and execute a program file (DE: FCB)

; Disk File Handler Routines

@BKSP		EQU	4445H	; Backspace 1 logical record (DE: FCB)
@CKEOF		EQU	4458H	; Check for EOF at the current logical record number (DE: FCB)
@LOC		EQU	446DH	; Calculate the current logical record number (DE: FCB)
@LOF		EQU	4470H	; Calculate the EOF logical record number (DE: FCB)
@PEOF		EQU	4448H	; Position an open file to EOF (DE: FCB)
@POSN		EQU	4442H	; Position a file to a logical record (DE: FCB, BC: LR#)
@READ		EQU	4436H	; Read a logical record from a file (DE: FCB, HL: UREC)
@REW		EQU	443FH	; Rewind a file to the beginning (DE: FCB)
@RREAD		EQU	445EH	; Re-read current sector (DE: FCB)
@RWRIT		EQU	4461H	; Rewrite current sector (DE: FCB)
@SKIP		EQU	4464H	; Skip next logical record (DE: FCB)
@VER		EQU	443CH	; Write followed by a test read (DE: FCB)
@WEOF		EQU	445BH	; Update the directory entry with the current EOF (DE: FCB)
@WRITE		EQU	4439H	; Write next logical record (DE: FCB, HL: UREC)

; General Purpose Routines

@CKDRV		EQU	4290H	; Check a drive exists and contains a formatted diskette (C: drive)
@DATE		EQU	3033H	; Get current date in display format (HL: buffer)
@DODIR		EQU	4419H	; Read visible files or find freespace and display (C, B, HL)
@DSPLY		EQU	4467H	; Display a message ending with 0x0d or 0x03. (HL: buf)
@FNAME		EQU	4293H	; Recover filename and extension from directory (DE: buf, B: DEC, C)
@LOGER		EQU	428DH	; Issue a log message to the Job Log (HL: buf)
@LOGOT		EQU	428AH	; Display and log a message (HL: buf)
@MSG		EQU	4402H	; Send a message to any device (DE: FCB, HL: buf)
@PARAM		EQU	4454H	; Parse optional parameter string (DE: table, HL: cmdline)
@PRINT		EQU	446AH	; Output a message line to the printer (HL: buf)
@TIME		EQU	3036H	; Get current time in display format (HL: buffer)

; Rom-resident I/O routines and vectors

@CTL		EQU	0023H	; Output a control byte to a device or file (DE: FCB, A: byte)
@DSP		EQU	0033H	; Output a byte to the video display (A: byte)
@GET		EQU	0013H	; Fetch a byte from a device or file (DE: FCB)
@KBD		EQU	002BH	; Scan keyboard and return key, if pressed
@KEY		EQU	0049H	; Scan keyboard and wait for a key to be pressed
@KEYIN		EQU	0040H	; Wait for a line of keyboard input (HL: buf, B: len)
@PAUSE		EQU	0060H	; Busy wait ~14.796uS per count (BC: count)
@PRT		EQU	003BH	; Output a byte to the printer (A: byte)
@PUT		EQU	001BH	; Output a byte to device or file (DE: FCB, A: byte)
@WHERE		EQU	000BH	; Resolve relocation address of calling routine

; Special Purpose Routines - Miscellaneous

GETDCT		EQU	478FH	; Return address of drive code table (C: drive)
DCTBYT		EQU	479CH	; Recover a byte field from drive code table (C: drive, A: byte)
DIRRD		EQU	4B10H	; Read a directory sector (B: DEC, C: drive)
DIRWR		EQU	4B1FH	; Write a directory sector (B: DEC, C: drive)
RDSSEC		EQU	4B45H	; Read the system sector (HL: buf, D: cyl, E: sec, C: drive)
DIRCYL		EQU	4B64H	; Return directory cylinder# for the requested drive
MULTEA		EQU	4B6BH	; Do 8 bit x 8 bit unsigned integer multiplication (A x E)
DIVEA		EQU	4B7AH	; Do 8 bit unsigned integer divide (E / A)
MULT		EQU	444EH	; Multiply 16 bit x 8 bit = 24 bit (HL * A)
DIVIDE		EQU	4451H	; Divide 16 bit unsigned by 8 bit unsigned (HL / A)
