;doscalls: dos type equates of 20-Nov-87
*LIST OFF
;
; Also common Dos error messages & numbers.
;
MODEL1	EQU	-1	;Change to 0 for model III.
			;Change to -1 for model I.
;
MODEL3	EQU	.NOT.MODEL1
;
;
DOS		EQU	402DH	;no error exit
DOS_DISP_ERROR	EQU	4030H	;error displayed exit
DOS_NOERROR	EQU	402DH	;no error
DOS_ERROR	EQU	4409H	;error exit
DOS_CALL	EQU	4419H	;dos-call
DOS_EXTRACT	EQU	441CH	;filename extract
DOS_OPEN_NEW	EQU	4420H	;open new/exist file
DOS_OPEN_EX	EQU	4424H	;open existing file
DOS_CLOSE	EQU	4428H	;close file
DOS_KILL	EQU	442CH	;kill file
DOS_READ_SECT	EQU	4436H	;read file's record
DOS_WRIT_SECT	EQU	4439H	;write file's record
DOS_REWIND	EQU	443FH	;set NEXT to 0/0/0.
DOS_POSIT	EQU	4442H	;position to relrec
DOS_BACK_RECD	EQU	4445H	;position back 1 recd
DOS_POS_EOF	EQU	4448H	;position to END
DOS_POS_RBA	EQU	444EH	;position to RBA
DOS_WRITE_EOF	EQU	4451H	;from fcb to directory
DOS_POWERUP	EQU	445BH	;spin drive
DOS_EXTEND	EQU	4473H	;add deflt extnsn
$GET		EQU	0013H	;read byte from dev
$PUT		EQU	001BH	;write byte
DOS_ENQUEUE	EQU	4410H	;enqueue INT rtn
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
TICKER		EQU	4040H	;Interrupt tick..
HIMEM		EQU	4049H
COM_BUFF	EQU	4318H
DCB$VDU		EQU	401DH
	ENDIF
;
	IF	MODEL3
HIMEM		EQU	4411H
COM_BUFF	EQU	4422H
	ENDIF
;
MESS_DO		EQU	4467H
MESS_PR		EQU	446AH
;
*LIST ON
