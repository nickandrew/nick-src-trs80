; doscalls: dos type equates of 2016-08-30
; Also common Dos error messages & numbers.
;
*LIST OFF
;
MODEL1	EQU	-1	;Change to 0 for model III.
			;Change to -1 for model I.
;
MODEL3	EQU	.NOT.MODEL1
;
;
CURSOR		EQU	4020H	; cursor position?
DOS		EQU	402DH	;no error exit
DOS_NOERROR	EQU	402DH	;no error
DOS_DISP_ERROR	EQU	4030H	;error displayed exit
DOS_COMMAND	EQU	4405H	;enter DOS and execute a command
DOS_ERROR	EQU	4409H	;DOS error exit
DOS_DEBUG	EQU	440DH	;enter DEBUG
DOS_ENQUEUE	EQU	4410H	;enqueue user timer interrupt routine
DOS_DEQUEUE	EQU	4413H	;dequeue user timer interrupt routine
DOS_ROTATE	EQU	4416H	;Keep drives rotating
DOS_CALL	EQU	4419H	;dos-call execute a DOS command and return
DOS_EXTRACT	EQU	441CH	;filename extract
DOS_OPEN_NEW	EQU	4420H	;open new/exist file
DOS_OPEN_EX	EQU	4424H	;open existing file
DOS_CLOSE	EQU	4428H	;close file
DOS_KILL	EQU	442CH	;kill FCB's associated file
DOS_LOAD	EQU	4430H	;load a program file
DOS_EXECUTE	EQU	4433H	;load and commence execution of a program file
DOS_READ_SECT	EQU	4436H	;read file's record
DOS_WRIT_SECT	EQU	4439H	;write file's record
DOS_REWIND	EQU	443FH	;set NEXT to 0/0/0.
DOS_POSIT	EQU	4442H	;position to relrec
DOS_BACK_RECD	EQU	4445H	;position back 1 recd
DOS_POS_EOF	EQU	4448H	;position to END
DOS_ALLOCATE	EQU	444BH	;allocate file space
DOS_POS_RBA	EQU	444EH	;position to RBA
DOS_WRITE_EOF	EQU	4451H	;from fcb to directory
DOS_POWERUP	EQU	445BH	;Select and power up the specified drive
DOS_TEST_MOUNT	EQU	445EH	;Test for mounted diskette
DOS_NAME_ENQ	EQU	4461H	;*name routine enqueue
DOS_NAME_DEQ	EQU	4464H	;*name routine dequeue
;
MESS_DO		EQU	4467H
MESS_PR		EQU	446AH
;
DOS_TIME	EQU	446DH	;convert clock time to HH:MM:SS format
DOS_DATE	EQU	4470H	;convert date to MM/DD/YY format
DOS_EXTEND	EQU	4473H	;add deflt extnsn
;
$GET		EQU	0013H	;read byte from dev
DOS_READ_BYTE	EQU	0013H	;read byte from file
$PUT		EQU	001BH	;write byte
DOS_WRIT_BYTE	EQU	001BH	;write byte to file
;
; Dos Errors.
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
	IF	MODEL1
DCB$VDU		EQU	401DH
TICKER		EQU	4040H	;Interrupt tick..
HIMEM		EQU	4049H
COM_BUFF	EQU	4318H
	ENDIF
;
	IF	MODEL3
HIMEM		EQU	4411H
COM_BUFF	EQU	4422H
	ENDIF
;
*LIST ON
