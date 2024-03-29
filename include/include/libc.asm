;libc: Standard I-O library for Small-C, Trs-80
;
	COM	'<libc dated 17 Jun 90>'
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
DCB_KBD$		EQU	4015H
DCB_VDU$		EQU	401DH
DCB_PTR$		EQU	4025H
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
;putchar(c)
;int  c;
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
;
_PUTC
	JP	_FPUTC
;
;int fputc(int c, FILE *fp)
;  -> Warning: this function implements _FPUTC with args backwards
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
	CALL	ROM@PUT
	JR	NZ,$C_03
	LD	L,C
	LD	H,0
	RET
$C_03	LD	HL,EOF
	RET
;
_GETCHAR
	LD	HL,STDIN
	PUSH	HL
	CALL	_FGETC
	POP	BC
	RET
;
;int getc(fp)
;FILE *fp;
;
_GETC
	JP	_FGETC
;
;fgets(s,n,ioptr)
;char *s;
;int  n;
;FILE *ioptr;
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
;
;fread(ptr,sizeof ptr, nitems, ioptr)
;char *ptr;
;int  nitems;
;FILE *ioptr;
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
	BIT	IS_TERM,(HL)
	JR	NZ,FG_01		;If terminal
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	ROM@GET
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
FG_02	CALL	ROM@GET
	OR	A
	JR	Z,FG_02
	LD	L,A
	LD	H,0
	CP	04H		;eof char
	RET	NZ
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
	CALL	ROM@PUT
;;	RET	NZ
	INC	HL
	JR	$C_04
;
;exit(errcode)
;char errcode;
;
_EXIT
	CALL	CLOSEALL
	LD	HL,2
	ADD	HL,SP
	LD	A,(HL)
	OR	A
	JP	Z,DOS_NOERROR
	JP	DOS_DISP_ERROR
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
;
;FILE *fopen(file,mode)
;char *file,*mode;
;
_FOPEN
	XOR	A
	LD	($C_07V),A	;Device name or 0.
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)		; Get pointer to mode
	INC	HL
	LD	D,(HL)
	LD	A,(DE)
	LD	($C_06V),A	; Store 1st char as mode
	INC	HL		; Get pointer to file
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	LD	DE,(_BRKSIZE)
	LD	A,(HL)
	CP	':'
	JR	NZ,$C_07	; Copy the filename into new FCB
	INC	HL		; Devices are represented as ":x"
	LD	A,(HL)
	AND	5FH
	LD	($C_07V),A
	CP	'D'		; ":D" is null device
	LD	DE,NULL_DCB
	JR	Z,$C_11B
	CP	'L'		; ":L" is line printer
	LD	DE,DCB_PTR$
	JR	Z,$C_11B
	CP	'C'		; ":C" is console
	JR	NZ,$C_13
	LD	A,($C_06V)	; Get mode
	CP	'r'
	LD	DE,DCB_KBD$	; If 'r' then use keyboard
	JR	Z,$C_11B
	LD	DE,DCB_VDU$	; Otherwise, use VDU
	JR	$C_11B

; Copy the filename into the FCB pointed to by DE
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
$C_09	LD	A,3		; Terminate the filename with 0x03
	LD	(DE),A
;
	LD	HL,32
	LD	DE,(_BRKSIZE)
	ADD	HL,DE		; HL now points to 256-byte file buffer
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
	JR	$C_11A
;
;Open for write and append
$C_10
	CALL	DOS_OPEN_NEW	;Write & append
	LD	HL,NULL
	RET	NZ
	LD	HL,256+32
	ADD	HL,DE
	LD	(_BRKSIZE),HL	; Update end of memory
	LD	A,($C_06V)	; Get file mode
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

; At this point, DE contains the address of a DCB or open FCB.
$C_11B
	LD	($C_08V),DE	; Store the pointer to FCB or DCB
; Search for a free file descriptor
	LD	B,MAX_FILES
	LD	HL,FD_ARRAY
	LD	DE,FD_LEN
$C_12
	LD	A,(HL)
	OR	A
	JR	Z,$C_14
	ADD	HL,DE
	DJNZ	$C_12
$C_13	LD	HL,NULL		; No free file descriptor was found; abort
				; BUG: Leaks 32+256 bytes of high memory
	RET
$C_14
	LD	(HL),1		; Mark file descriptor in use
	LD	A,($C_07V)
	OR	A
	JR	Z,$C_16
	SET	IS_TERM,(HL)	; Mark it's a device
$C_16
	PUSH	HL
	LD	DE,FD_FCBPTR
	ADD	HL,DE
	LD	DE,($C_08V)	; Get pointer to FCB or DCB
	LD	(HL),E		; Store it in file descriptor table
	INC	HL
	LD	(HL),D
	POP	HL		; Return value is pointer to FCB or DCB
	RET

$C_06V	DEFB	0	; Mode byte
$C_07V	DEFB	0	;Type of special device C,D,L
$C_08V	DEFW	0	;Addr of dcb/fcb.
;
NULL_DCB	DC	8,0
;
;
;int feof(fp)
;FILE *fp;
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
;
;fflush(fp)
;FILE *fp
_FFLUSH
	RET
;
;fseek(fp,offset,n)
;FILE *fp;
;int offset;   /* should be long */
;int n;
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
	RET
;
;rewind(ioptr)
;char *ioptr;
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
;
;_brk: Set the end of the data space allocated to this program
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
;
;fix_prog_end: Update the end of the program according to the _brksize
FIX_PROG_END
	LD	HL,(_BRKSIZE)
;;	ld	(prog_end),hl		;Not needed as not Zeta!
	RET
;
;sprintf(string,format,args)
;char *string,*format;
;unkn args;
_SPRINTF
	RET
;
;fprintf(fp,format,args)
;FILE *fp;
;char *format;
;???? args;
;
_FPRINTF
	RET
;
;printf(format,args)
;char *format;
;???? args;
;
_PRINTF
	RET
;
;-----------------------------
;end of libc.asm
