; doscalls: dos type equates of 2021-01-12
; Also common Dos error messages & numbers.
;

CURSOR$		EQU	4020H	; cursor position?
DOS_NOERROR	EQU	402DH	;no error
DOS_DISP_ERROR	EQU	4030H	;error displayed exit
DOS_COMMAND	EQU	4405H	;enter DOS and execute a command
DOS_ERROR	EQU	4409H	;DOS error exit
DOS_DEBUG	EQU	440DH	;enter DEBUG
;DOS_ENQUEUE	EQU	4410H	;Model 1/3 specific; see below
DOS_DEQUEUE	EQU	4413H	;dequeue user timer interrupt routine
DOS_ROTATE	EQU	4416H	;Keep drives rotating
DOS_CALL	EQU	4419H	;dos-call execute a DOS command and return
DOS_EXTRACT	EQU	441CH	;extract a filespec
DOS_OPEN_NEW	EQU	4420H	;open new/existing file
DOS_OPEN_EX	EQU	4424H	;open existing file
DOS_CLOSE	EQU	4428H	;close file
DOS_KILL	EQU	442CH	;kill FCB's associated file
DOS_LOAD	EQU	4430H	;load a program file
DOS_EXECUTE	EQU	4433H	;load and commence execution of a program file
DOS_READ_SECT	EQU	4436H	;read file's record
DOS_WRIT_SECT	EQU	4439H	;write file's record
DOS_WRIT_VRFY	EQU	443CH	;write file's record with verify read
DOS_REWIND	EQU	443FH	;set NEXT to 0/0/0.
DOS_POSIT	EQU	4442H	;position FCB to a specified file record
DOS_BACK_RECD	EQU	4445H	;position back 1 record
DOS_POS_EOF	EQU	4448H	;position FCB to EOF
DOS_ALLOCATE	EQU	444BH	;allocate file space (incompatible with TRSDOS/LDOS)
DOS_POS_RBA	EQU	444EH	;position to RBA
DOS_WRITE_EOF	EQU	4451H	;from fcb to directory (incompatible with TRSDOS/LDOS)
DOS_POWERUP	EQU	445BH	;Select and power up the specified drive
DOS_TEST_MOUNT	EQU	445EH	;Test for mounted diskette
DOS_NAME_ENQ	EQU	4461H	;*name routine enqueue
DOS_NAME_DEQ	EQU	4464H	;*name routine dequeue
;
MESS_DO		EQU	4467H	;send a message to the display
MESS_PR		EQU	446AH	;send a message to the printer
;
DOS_TIME	EQU	446DH	;convert clock time to HH:MM:SS format
DOS_DATE	EQU	4470H	;convert date to MM/DD/YY format
DOS_EXTEND	EQU	4473H	;Insert default name extension into filespec
;
ROM@GET		EQU	0013H	;read byte from device/file
ROM@PUT		EQU	001BH	;write byte to device/file
ROM@CTL		EQU	0023H	;write control byte to device/file
ROM@KEY_NOWAIT	EQU	002BH	;non-blocking read keyboard; return 0 if no key pressed
ROM@PUT_VDU	EQU	0033H	;write a byte to the video display
ROM@WAIT_LINE	EQU	0040H	;wait for a line of input from the keyboard
ROM@WAIT_KEY	EQU	0049H	;wait for a key to be pressed and return it
ROM@PAUSE	EQU	0060H	;busy wait (M1:14.67uS, M3:14.796uS) per count (BC: count)
ROM@CLS		EQU	01C9H	;clear the screen
;
; Dos Errors.
DE_DR_NF_DR	EQU	05H
DE_DEV_NA	EQU	08H
DE_UNDEF	EQU	09H
DE_WRIT_PROT	EQU	0FH
DE_DEV_NA_2	EQU	10H
DE_NOT_FOUND	EQU	18H
DE_DISK_FULL	EQU	1BH
DE_EOF		EQU	1CH
DE_PAST_EOF	EQU	1DH
DE_NOT_OPEN	EQU	26H
DE_BAD_PARAM	EQU	2FH
DE_BAD_FSPEC	EQU	30H
DE_EXISTS	EQU	35H
;
; Common addresses.
	IFDEF	MODEL1
TICKER		EQU	4040H	;Interrupt tick..
HIMEM		EQU	4049H
COM_BUFF	EQU	4318H
DOS_ENQUEUE	EQU	4410H	;enqueue user timer interrupt routine
	ENDIF
;
	IFDEF	MODEL3
HIMEM		EQU	4411H
COM_BUFF	EQU	4422H
DOS_ENQUEUE	EQU	447BH	;enqueue user timer interrupt routine
	ENDIF
;
