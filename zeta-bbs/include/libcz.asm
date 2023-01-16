;libcz: Standard I-O library for Small-C, Zeta
;
	COM	'<libcz dated 26-Nov-87>'
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
KBD_DCB		EQU	DCB_2I
VDU_DCB		EQU	DCB_2O
PTR_DCB		EQU	4025H
;
FD_ARRAY	DC	MAX_FILES*FD_LEN,0
;
;Contents:
FD_FLAG		EQU	0
FD_FCBPTR	EQU	1
;
IS_USED	EQU	0	;bits of fd_flag
IS_TERM	EQU	1	;its a terminal or dcb.
IS_CHAR	EQU	1	;Is a character device
ECHO	EQU	2
CBREAK	EQU	3
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
	IFREF	_FILENO
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
	ENDIF	;_fileno
;
;putchar(c)
;int  c;
	IFREF	_PUTCHAR
_PUTCHAR
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	LD	HL,STDOUT
	PUSH	HL
	CALL	_FPUTC
	POP	BC
	POP	BC
	RET
	ENDIF	;_putchar
;
	IFREF	_PUTC
_PUTC
	JP	_FPUTC
	ENDIF	;_putc
;
;int fputc(c,fp)
;int c;
;FILE *fp;
;
	IFREF	_FPUTC
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
	ENDIF	;_fputc
;
	IFREF	_GETCHAR
_GETCHAR
	LD	HL,STDIN
	PUSH	HL
	CALL	_FGETC
	POP	BC
	RET
	ENDIF	;_getchar
;
;int getc(fp)
;FILE *fp;
;
	IFREF	_GETC
_GETC
	JP	_FGETC
	ENDIF	;_getc
;
;fgets(s,n,ioptr)
;char *s;
;int  n;
;FILE *ioptr;
	IFREF	_FGETS
_FGETS
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;DE = ioptr
	LD	(FG_IO),DE
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;BC = n
	LD	(FG_N),BC
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL		;HL = s
	LD	(FG_S),HL
	LD	A,B
	OR	C
	JP	Z,FG_8		;if count = 0
FG_1
	DEC	BC
	LD	A,B
	OR	C
	JP	Z,FG_8
	PUSH	HL
	PUSH	BC
	LD	DE,(FG_IO)
	PUSH	DE
	CALL	_FGETC
	POP	IY
	POP	BC
	EX	DE,HL		;de = char or EOF
	LD	HL,EOF
	OR	A
	SBC	HL,DE
	JR	NZ,FG_2
;Eof seen....
	POP	HL		;string *
FG_8	LD	(HL),0
	LD	DE,(FG_S)
	OR	A
	SBC	HL,DE		;if hl = 0 then return HL
	RET	Z
	EX	DE,HL		;else return S (de)
	RET
;
FG_2
	POP	HL		;hl = string *
	LD	(HL),E
	INC	HL
	LD	A,E
	CP	0DH		;NL,CR, whatever
	JR	NZ,FG_1
	JR	FG_8
;
FG_N	DEFW	0
FG_IO	DEFW	0
FG_S	DEFW	0
;
	ENDIF	;_fgets
;
;fread(ptr,sizeof ptr, nitems, ioptr)
;char *ptr;
;int  nitems;
;FILE *ioptr;
	IFREF	_FREAD
_FREAD
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(FR_IO),DE
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	(FR_NI),BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	(FR_SI),BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(FR_PTR),DE
	LD	HL,0
	LD	(FR_NREAD),HL
	EX	DE,HL
	LD	BC,(FR_NI)
FR_01
	LD	A,B
	OR	C
	JR	Z,FR_99		;Read NITEMS items
	PUSH	BC
;
	LD	BC,(FR_SI)
FR_02
	PUSH	BC
	PUSH	HL
;
	LD	HL,(FR_IO)
	PUSH	HL
	CALL	_FGETC
	POP	IY
;
	LD	A,H
	OR	A
	JR	NZ,FR_98	;Hit EOF
	LD	A,L
;
	LD	HL,(FR_NREAD)
	INC	HL
	LD	(FR_NREAD),HL
;
	POP	HL
	LD	(HL),A
	INC	HL
;
	POP	BC
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,FR_02
;
	POP	BC
	DEC	BC
	JR	FR_01
;
FR_98
	POP	IY
	POP	IY
	POP	IY
FR_99
	LD	HL,(FR_NREAD)
	RET
;
FR_NI	DEFW	0
FR_IO	DEFW	0
FR_SI	DEFW	0
FR_PTR	DEFW	0
FR_NREAD	DEFW	0
;
	ENDIF	;_fread
;
;int fgetc(fp)
;FILE *fp;
;
	IFREF	_FGETC
_FGETC
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	BIT	IS_TERM,(HL)
	JR	NZ,FG_01		;If terminal
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
FG_01				;fgetc from terminal
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
FG_02	CALL	$GET
	OR	A
	JR	Z,FG_02
	LD	L,A
	LD	H,0
	CP	04H		;eof char
	RET	NZ
	LD	HL,EOF
	RET
	ENDIF	;_fgetc
;
;fputs(s,fp)
;char *s;
;FILE *fp;
;
	IFREF	_FPUTS
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
;;	RET	NZ
	INC	HL
	JR	$C_04
	ENDIF	;_fputs
;
;exit(errcode)
;char errcode;
;
	IFREF	_EXIT
_EXIT
	CALL	CLOSEALL
	LD	HL,2
	ADD	HL,SP
	LD	A,(HL)
	OR	A
	JP	TERMINATE
;
CLOSEALL			;Close all open files
	LD	B,MAX_FILES
	LD	HL,FD_ARRAY
CL_1	PUSH	BC
	PUSH	HL
	PUSH	HL
	CALL	_FCLOSE
	POP	IY
	POP	HL
	LD	DE,FD_LEN
	ADD	HL,DE
	POP	BC
	DJNZ	CL_1
	RET
;
	ENDIF	;_exit
;
;strcpy(out,in)
;char *out,*in;
;
	IFREF	_STRCPY
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
	ENDIF	;_strcpy
;
;fclose(fp)
;FILE *fp;
	IFREF	_FCLOSE
_FCLOSE
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	BIT	IS_USED,(HL)
	RET	Z
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
	ENDIF	;_fclose
;
;FILE *fopen(file,mode)
;char *file,*mode;
;
	IFREF	_FOPEN
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
	LD	DE,(_BRKSIZE)
	LD	A,(HL)
	CP	':'
	JR	NZ,$C_07
	INC	HL
	LD	A,(HL)
	AND	5FH
	LD	($C_07V),A
	CP	'D'
	LD	DE,NULL_DCB
	JR	Z,$C_11B
	CP	'L'
	LD	DE,PTR_DCB
	JR	Z,$C_11B
	CP	'C'
	JR	NZ,$C_13
	LD	A,($C_06V)	;Mode
	CP	'r'
	LD	DE,KBD_DCB
	JR	Z,$C_11B
	LD	DE,VDU_DCB
	JR	$C_11B
;
$C_07	LD	A,(HL)
	OR	A
	JR	Z,$C_09
;;	CP	'/'
;;	JR	Z,$C_08
	LD	(DE),A
	INC	HL
	INC	DE
	JR	$C_07
;;$C_08	LD	A,'.'
;;	LD	(DE),A
;;	INC	HL
;;	INC	DE
;;	JR	$C_07
$C_09	LD	A,3
	LD	(DE),A
;
	LD	HL,32
	LD	DE,(_BRKSIZE)
	ADD	HL,DE
	LD	B,0
	LD	A,($C_06V)
	CP	'a'
	JR	Z,$C_10		;append mode
	CP	'w'
	JR	Z,$C_10		;write mode
;
;Open for reading.
	CALL	DOS_OPEN_EX	;assume read
	LD	HL,NULL
	RET	NZ
	LD	HL,256+32
	ADD	HL,DE
	LD	(_BRKSIZE),HL	;update end of memory
	CALL	FIX_PROG_END
	JR	$C_11A
;
;Open for write and append
$C_10
	CALL	DOS_OPEN_NEW	;Write & append
	LD	HL,NULL
	RET	NZ
	LD	HL,256+32
	ADD	HL,DE
	LD	(_BRKSIZE),HL
	CALL	FIX_PROG_END
	LD	A,($C_06V)
	CP	'a'
	JR	NZ,$C_11	;If not append
	CALL	DOS_POS_EOF	;Append, so position to EOF
	JR	$C_11A
$C_11
	;Truncate the file??
$C_11A	INC	DE
	LD	A,(DE)
	SET	6,A		;Ensure writes do not bugger eof
	LD	(DE),A
	DEC	DE
$C_11B
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
$C_13	LD	HL,NULL
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
	ENDIF	;_fopen
;
;int feof(fp)
;FILE *fp;
	IFREF	_FEOF
_FEOF
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)	;DE = fp (pointer to fdarray)
	EX	DE,HL
	BIT	IS_TERM,(HL)
	JR	NZ,$C_17
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	POP	IX
	LD	A,(IX+11)	;Next high
	CP	(IX+13)		;EOF  high
	JR	NZ,$C_15
	LD	A,(IX+10)	;Next mid
	CP	(IX+12)		;EOF  mid
	JR	NZ,$C_15
	LD	A,(IX+5)	;Next low
	CP	(IX+8)		;EOF  low
	JR	NZ,$C_15
	LD	HL,1
	RET
$C_15	LD	HL,1
	RET	NC
$C_17	LD	HL,0
	RET
	ENDIF	;_feof
;
;fflush(fp)
;FILE *fp
	IFREF	_FFLUSH
_FFLUSH
	RET
	ENDIF	;_fflush
;
;fseek(fp,offset,n)
;FILE *fp;
;int offset;   /* should be long */
;int n;
	IFREF	_FSEEK
_FSEEK
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;de = N
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc = offset
	INC	HL
	PUSH	BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc = ioptr
	LD	HL,FD_FCBPTR
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)		;bc = fcb
	PUSH	BC
	POP	IX
	LD	A,E
	OR	A
	JR	Z,FSE_0
	DEC	A
	JR	Z,FSE_1
	LD	C,(IX+13)	;eof high
	LD	H,(IX+12)	;eof mid
	LD	L,(IX+8)	;eof low
	JR	FSE_N
FSE_1
	LD	C,(IX+11)
	LD	H,(IX+10)
	LD	L,(IX+5)
	JR	FSE_N
FSE_0
	LD	C,0
	LD	H,C
	LD	L,C
FSE_N
	POP	DE
	LD	B,0
	BIT	7,D	;check if signed
	JR	Z,FSE_N1
	LD	B,0FFH
FSE_N1
	ADD	HL,DE
	LD	A,B
	ADC	A,C
	LD	C,L
	LD	L,H
	LD	H,A
	PUSH	IX
	POP	DE
	CALL	DOS_POS_RBA
;Return eof value
	PUSH	DE
	POP	IX
	LD	L,(IX+5)
	LD	H,(IX+10)
	RET
	ENDIF	;_fseek
;
;rewind(ioptr)
;char *ioptr;
	IFREF	_REWIND
_REWIND
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	DOS_REWIND
	RET
	ENDIF	;_rewind
;
;_brk: Set the end of the data space allocated to this program
	IFREF	_BRK
_BRK
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)		;DE = endds
	LD	HL,(HIMEM)
	OR	A
	SBC	HL,DE
	JR	C,$C_20		;HIMEM - endds < 0
;
	LD	HL,(_BRKSIZE)
	OR	A
	SBC	HL,DE
	JR	NC,$C_19	;_BRKSIZE - endds >= 0

;Must zero the intermediate storage. HL = number of bytes to zero
	PUSH	HL
	POP	BC
	LD	HL,(_BRKSIZE)
$C_18
	LD	(HL),0
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,$C_18
$C_19
	EX	DE,HL		;HL = endds
	LD	(_BRKSIZE),HL
	LD	HL,0
	RET
;
$C_20
	LD	HL,-1		;Tried to allocate above HIMEM
	RET
;
	ENDIF	;_brk
;
;fix_prog_end: Update the end of the program according to the _brksize
	IFREF	FIX_PROG_END
FIX_PROG_END
	LD	HL,(_BRKSIZE)
	LD	(PROG_END),HL
	RET
	ENDIF	;fix_prog_end
;
;sprintf(string,format,args)
;char *string,*format;
;unkn args;
	IFREF	_SPRINTF
_SPRINTF
	RET
	ENDIF	;_sprintf
;
;fprintf(fp,format,args)
;FILE *fp;
;char *format;
;???? args;
;
	IFREF	_FPRINTF
_FPRINTF
	RET
	ENDIF
;
;printf(format,args)
;char *format;
;???? args;
;
	IFREF	_PRINTF
_PRINTF
	RET
	ENDIF
;
;-----------------------------
;end of libcz.asm
