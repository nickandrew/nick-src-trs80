;libc/asm: Standard I-O library for Small-C, Trs-80
;
	COM	'<libc dated 22 Mar 87>'
;
;
EOF	EQU	-1
NULL	EQU	0
;_EOF	EQU	-1
_NULL	EQU	0
;
;File descriptor array
;
MAX_FILES	EQU	20
FD_LEN		EQU	3
KBD_DCB		EQU	4015H
VDU_DCB		EQU	401DH
PTR_DCB		EQU	4025H
;
FD_ARRAY	DEFS	MAX_FILES*FD_LEN
;
;Contents:
FD_FLAG		EQU	0
FD_FCBPTR	EQU	1
;
IS_USED	EQU	0	;bits of fd_flag
IS_TERM	EQU	1	;its a terminal or dcb.
;
STDIN	EQU	0*FD_LEN+FD_ARRAY
STDOUT	EQU	1*FD_LEN+FD_ARRAY
STDERR	EQU	2*FD_LEN+FD_ARRAY
_STDIN	EQU	STDIN
_STDOUT	EQU	STDOUT
_STDERR	EQU	STDERR
BUFSIZ	EQU	256
;-------------------------------------------------------
;
;int fileno(fp);
;FILE *fp;
;
_FILENO	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	DE,FD_ARRAY
	OR	A
	SBC	HL,DE
	LD	BC,-1
	JR	C,$C_02
	LD	DE,FD_LEN
$C_01	INC	BC
	SBC	HL,DE
	JR	NC,$C_01
$C_02	PUSH	BC
	POP	HL
	RET
;
;int fputc(c,fp)
;int c;
;FILE *fp;
;
_FPUTC
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	EX	DE,HL	;hl now points to fdarray
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,C
	CALL	$PUT
	JR	NZ,$C_03
	LD	L,C
	LD	H,0
	RET
$C_03	LD	HL,EOF
	RET
;
;int fgetc(fp)
;FILE *fp;
;
_FGETC
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	$GET
	LD	L,A
	LD	H,0
	RET	Z
	LD	HL,EOF
	RET
;
;fputs(s,fp)
;char *s;
;FILE *fp;
;
_FPUTS
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)	;Read fp
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)	;Read string
	INC	HL
	LD	B,(HL)
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	BC
	POP	HL
$C_04	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$PUT
	RET	NZ
	INC	HL
	JR	$C_04
;
;exit(errcode)
;char errcode;
;
_EXIT
	LD	HL,2
	ADD	HL,SP
	LD	A,(HL)
	OR	A
	JP	Z,DOS
	JP	DOS_DISP_ERROR
;
;strcpy(out,in)
;char *out,*in;
;
_STRCPY
	LD	HL,2
	ADD	HL,SP
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
$C_05	LD	A,(BC)
	LD	(DE),A
	INC	BC
	INC	DE
	OR	A
	JR	NZ,$C_05
	RET
;
;fclose(fp)
;FILE *fp;
_FCLOSE
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	BIT	IS_TERM,(HL)
	LD	(HL),0
	RET	NZ
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	DOS_CLOSE
	RET
;
;int getc(fp)
;FILE *fp;
;
_GETC
	JP	_FGETC
;
;fprintf(fp,format,args)
;FILE *fp;
;char *format;
;???? args;
;
_FPRINTF
	RET
;
;FILE *fopen(file,mode)
;char *file,*mode;
;
_FOPEN
	XOR	A
	LD	($C_07V),A	;Device name or 0.
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	A,(DE)
	LD	($C_06V),A
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	DE,(HIGHEST)
	LD	A,(HL)
	CP	':'
	JR	NZ,$C_07
	INC	HL
	LD	A,(HL)
	AND	5FH
	LD	($C_07V),A
	CP	'D'
	LD	DE,NULL_DCB
	JR	Z,$C_11
	CP	'L'
	LD	DE,PTR_DCB
	JR	Z,$C_11
	CP	'C'
	JR	NZ,$C_13
	LD	A,($C_06V)	;Mode
	CP	'r'
	LD	DE,KBD_DCB
	JR	Z,$C_11
	LD	DE,VDU_DCB
	JR	$C_11
;
$C_07	LD	A,(HL)
	OR	A
	JR	Z,$C_09
	CP	'.'
	JR	Z,$C_08
	LD	(DE),A
	INC	HL
	INC	DE
	JR	$C_07
$C_08	LD	A,'/'
	LD	(DE),A
	INC	HL
	INC	DE
	JR	$C_07
$C_09	LD	A,3
	LD	(DE),A
;
	LD	HL,32
	LD	DE,(HIGHEST)
	ADD	HL,DE
	LD	B,0
	LD	A,($C_06V)
	CP	'a'
	JR	Z,$C_10
	CP	'w'
	JR	Z,$C_10
	CALL	DOS_OPEN_EX	;assume read
	LD	HL,EOF
	RET	NZ
	LD	HL,256+32
	ADD	HL,DE
	LD	(HIGHEST),HL
	JR	$C_11
$C_10
	CALL	DOS_OPEN_NEW	;Write & append
	LD	HL,EOF
	RET	NZ
	LD	HL,256+32
	ADD	HL,DE
	LD	(HIGHEST),HL
	LD	A,($C_06V)
	CP	'a'
	JR	NZ,$C_11
	CALL	DOS_POS_EOF
$C_11
	LD	($C_08V),DE
	LD	B,MAX_FILES
	LD	HL,FD_ARRAY
	LD	DE,FD_LEN
$C_12
	LD	A,(HL)
	OR	A
	JR	Z,$C_14
	ADD	HL,DE
	DJNZ	$C_12
$C_13	LD	HL,EOF
	RET
$C_14
	LD	(HL),1
	LD	A,($C_07V)
	OR	A
	JR	Z,$C_16
	SET	IS_TERM,(HL)
$C_16
	PUSH	HL
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	DE,($C_08V)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	POP	HL
	RET
$C_06V	DEFB	0
$C_07V	DEFB	0	;Type of special device C,D,L
$C_08V	DEFW	0	;Addr of dcb/fcb.
;
NULL_DCB	DC	8,0
;
;int feof(fp)
;FILE *fp;
_FEOF
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	POP	IX
	LD	A,(IX+11)
	CP	(IX+13)
	JR	NZ,$C_15
	LD	A,(IX+10)
	CP	(IX+12)
	JR	NZ,$C_15
	LD	A,(IX+8)
	CP	(IX+5)
	JR	NZ,$C_15
	LD	HL,0
	RET
$C_15	LD	HL,1
	RET
;
;fflush(fp)
;FILE *fp
_FFLUSH
	RET
;
;sprintf(string,format,args)
;char *string,*format;
;unkn args;
_SPRINTF
	RET
;
