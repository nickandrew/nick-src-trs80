;routines.lib: Common routines for global label search.
;Last updated: 28 Jun 89.

*GET	RS232		; routines.asm depends on constants defined in rs232.asm

;
;PRINT_NUMB. Print a number in HL to unit $stdout_def.
;sets up TENS&ONES for suffix printing.
;Also PRINT_NUMB_DEV for printing to a device.
;
	IFREF	PRINT_NUMB
PRINT_NUMB
	LD	DE,DCB_2O
	JR	PRINT_NUMB_DEV
;
	ENDIF	;print_numb
;
	IFREF	PRINT_NUMB_DEV
PRINT_NUMB_DEV
	LD	(_PRNU_DEV),DE
	XOR	A
	LD	(BLANK),A
	LD	DE,10000
	CALL	PRT_DIGIT
	LD	DE,1000
	CALL	PRT_DIGIT
	LD	DE,100
	CALL	PRT_DIGIT
	LD	DE,10
	CALL	PRT_DIGIT
	LD	A,(DIGIT)
	LD	(TENS),A
	LD	DE,1
	LD	A,E
	LD	(BLANK),A
	CALL	PRT_DIGIT
	LD	A,(DIGIT)
	LD	(ONES),A
	RET
;
PRT_DIGIT
	LD	B,'0'-1
PD_1	INC	B
	OR	A
	SBC	HL,DE
	JR	NC,PD_1
	ADD	HL,DE
	LD	A,(BLANK)
	OR	A
	JR	NZ,PD_2
	LD	A,B
	LD	(DIGIT),A
	CP	'0'
	RET	Z
PD_2	LD	(BLANK),A
	LD	A,B
	LD	(DIGIT),A
	LD	DE,(_PRNU_DEV)
	CALL	$PUT
	RET
;
BLANK	DEFB	0
DIGIT	DEFB	0
TENS	DEFB	0
ONES	DEFB	0
_PRNU_DEV DEFW	0
;
	ENDIF	;print_numb_dev
;
;PRINT_SUFF. Print suffix related to TENS & ONES values.
	IFREF	PRINT_SUFF
;
	IFNDEF	PRINT_NUMB
	ERR	'Cant use PRINT_SUFF without PRINT_NUMB!!
	ENDIF
;
PRINT_SUFF
	LD	A,(TENS)
	CP	'1'
	LD	A,0
	JR	Z,SUFF_1
	LD	A,(ONES)
	CP	'4'
	LD	A,0
	JR	NC,SUFF_1
	LD	A,(ONES)
	SUB	'0'
SUFF_1	ADD	A,A
	LD	E,A
	LD	D,0
	LD	HL,SUFF_TBL
	ADD	HL,DE
	LD	A,(HL)
	LD	DE,(_PRNU_DEV)
	CALL	$PUT
	INC	HL
	LD	A,(HL)
	CALL	$PUT
	RET
;
SUFF_TBL DEFM	'th','st','nd','rd'
;
	ENDIF	;ifref print_suff
;
;SPRINT_NUMB. Print a number in HL to a string at DE.
;
	IFREF	SPRINT_NUMB
SPRINT_NUMB
	LD	($SPRNU_DEV),DE
	XOR	A
	LD	($SBLANK),A
	LD	DE,10000
	CALL	$SPRT_DIGIT
	LD	DE,1000
	CALL	$SPRT_DIGIT
	LD	DE,100
	CALL	$SPRT_DIGIT
	LD	DE,10
	CALL	$SPRT_DIGIT
	LD	DE,1
	LD	A,E
	LD	($SBLANK),A
	CALL	$SPRT_DIGIT
	XOR	A
	LD	(DE),A
	RET
;
$SPRT_DIGIT
	LD	B,'0'-1
$SPD_1	INC	B
	OR	A
	SBC	HL,DE
	JR	NC,$SPD_1
	ADD	HL,DE
	LD	A,($SBLANK)
	OR	A
	JR	NZ,$SPD_2
	LD	A,B
	LD	($SDIGIT),A
	CP	'0'
	RET	Z
$SPD_2	LD	($SBLANK),A
	LD	A,B
	LD	($SDIGIT),A
	LD	DE,($SPRNU_DEV)
	LD	(DE),A
	INC	DE
	LD	($SPRNU_DEV),DE
	RET
;
$SBLANK		DEFB	0
$SDIGIT		DEFB	0
$SPRNU_DEV	DEFW	0
;
	ENDIF	;sprint_numb
;
;MESS_CR: Print a CR terminated msg on device.
	IFREF	MESS_CR
MESS_CR
	LD	A,(HL)
	CP	ETX
	RET	Z
	OR	A
	RET	Z
	CALL	$PUT
	LD	A,(HL)
	INC	HL
	CP	CR
	JR	NZ,MESS_CR
	RET
;
	ENDIF
;
;mess_nocr: print a message UNTIL a CR is seen.
	IFREF	MESS_NOCR
MESS_NOCR:
	LD	A,(HL)
	OR	A
	RET	Z
	CP	ETX
	RET	Z
	CP	CR
	RET	Z
	CALL	$PUT
	INC	HL
	JR	MESS_NOCR
	ENDIF	;ifref mess_nocr
;
;X_today: put today's date as in dd-mmm-yy in buffer.
	IFREF	X_TODAY
X_TODAY
	PUSH	HL
	CALL	4470H
	POP	HL
	PUSH	HL
	CALL	X_DATE
	POP	HL
	RET
	ENDIF	;ifref X_TODAY
;
;X_date: convert mm/dd/yy to dd-mmm-yy.
	IFREF	X_DATE
X_DATE
	PUSH	HL
	LD	DE,7
	ADD	HL,DE
	PUSH	HL
	POP	DE
	INC	DE
	LD	BC,2
	LDDR
	EX	DE,HL
	LD	(HL),'-'
	POP	HL
	PUSH	HL
	LD	A,(HL)
	CP	'1'
	LD	A,0
	JR	NZ,XTOD_1
	LD	A,10
XTOD_1	PUSH	HL
	INC	HL
	LD	B,(HL)
	ADD	A,B
	SUB	'0'
	LD	C,A
	ADD	A,A
	ADD	A,C
	LD	C,A
	INC	HL
	INC	HL
	LD	A,(HL)
	POP	DE
	LD	(DE),A
	INC	HL
	INC	DE
	LD	A,(HL)
	LD	(DE),A
	INC	DE
	LD	A,'-'
	LD	(DE),A
	INC	DE
	LD	HL,X_DATA
	LD	B,0
	ADD	HL,BC
	LD	C,3
	LDIR
	POP	HL
	RET
;
X_DATA	DEFM	'***JanFebMarAprMay'
	DEFM	'JunJulAugSepOctNov'
	DEFM	'Dec***************'
	DEFM	'******************'
;
	ENDIF	;ifref X_DATE
;
;str_cmp: compare two strings for equality.
	IFREF	STR_CMP
STR_CMP
	LD	A,(DE)
	CP	(HL)
	RET	NZ
	OR	A
	RET	Z
	CP	ETX
	RET	Z
	CP	CR
	RET	Z
	INC	HL
	INC	DE
	JR	STR_CMP
;
	ENDIF	;ifref STR_CMP
;
;ZERO_SEARCH: Search the USERFILE for an empty slot?
; Sets the US_ZERO flag, and does not set US_HASH.
	IFREF	ZERO_SEARCH
ZERO_SEARCH
	LD	A,1
	LD	(US_ZERO),A
	JP	COMMON_SEARCH
;
	ENDIF	;ifref ZERO_SEARCH
;
;USER_SEARCH: Search the USERFILE for a particular name.
; On input: HL contains the username, terminated by CR, ETX or NUL
	IFREF	USER_SEARCH
USER_SEARCH
	LD	A,0
	LD	(US_ZERO),A
	LD	(US_NSTR),HL
_US_01	LD	A,(HL)
	OR	A
	JR	Z,_US_02
	CP	CR
	JR	Z,_US_02
	CP	ETX
	JR	Z,_US_02
	INC	HL
	JR	_US_01
_US_02	LD	(HL),0
	LD	HL,(US_NSTR)
	CALL	CI_HASH
	LD	(US_HASH),A
	JP	COMMON_SEARCH
;
	ENDIF	;ifref USER_SEARCH
;
;COMMON_SEARCH: Search the USERFILE for a particular name.
; This module is common between USER_SEARCH and ZERO_SEARCH.
	IFREF	COMMON_SEARCH
COMMON_SEARCH
	LD	HL,0
	LD	(US_POSN),HL
;
;Open file if necessary.
	LD	A,(US_FCB)
	BIT	7,A
	JR	NZ,_US_04
	LD	DE,US_FCB
	LD	HL,US_BUFF
	LD	B,0
	CALL	DOS_OPEN_EX
	SCF
	RET	NZ
	LD	A,(US_FCB+1)
	AND	0F8H		;Unprotect
	LD	(US_FCB+1),A
_US_04	LD	A,(US_FCB+1)	;Prevent shrink on write
	OR	0C0H		;and force lrl read.
	LD	(US_FCB+1),A
	LD	BC,1
	LD	DE,US_FCB
	CALL	DOS_POSIT
	SCF
	RET	NZ
	CALL	_US_RDREC
	RET	NZ
	LD	HL,(UF_UID)
	LD	(US_UMAX),HL
	LD	HL,(UF_NCALLS)	;max. rrecno posn.
	LD	(US_PMAX),HL
;
_US_LOOP	LD	DE,(US_POSN)
	LD	HL,(US_PMAX)
	CALL	CPHLDE
	JR	NC,_US_05
	CCF
	RET	;nz
_US_05	LD	HL,(US_POSN)
	LD	A,L
	OR	A
	JR	NZ,_US_06
;
;Read hash sector into buffer.
	LD	A,UF_LRL+1
	CALL	MULTIPLY
	LD	DE,US_FCB
	CALL	DOS_POS_RBA
	SCF
	RET	NZ
	LD	HL,US_HBUFF
	CALL	DOS_READ_SECT	;256 bytes.
	SCF
	RET	NZ
;
_US_06	LD	A,(US_POSN)	;low.
	LD	HL,US_HBUFF
	ADD	A,L
	LD	L,A
	LD	A,0
	ADC	A,H
	LD	H,A
	LD	B,(HL)
	LD	A,(US_ZERO)
	OR	A
	JR	Z,_US_06A
;check if b=0
	XOR	A
	CP	B
	JR	NZ,_US_INC
	JR	_US_07
_US_06A	LD	A,(US_HASH)
	CP	B
	JR	Z,_US_07
;
;Increment position
_US_INC	LD	HL,(US_POSN)
	INC	HL
	LD	(US_POSN),HL
	JR	_US_LOOP
;
_US_07	LD	HL,(US_POSN)
	PUSH	HL
	INC	H
	LD	L,0
	EX	DE,HL
	POP	HL
	LD	A,UF_LRL
	CALL	MULTIPLY
	LD	A,D
	ADD	A,L
	LD	L,A
	LD	A,0
	ADC	A,H
	LD	H,A
;Store RBA in C,L,H form.
	LD	A,C
	LD	(US_RBA),A
	LD	(US_RBA+1),HL
;
	LD	DE,US_FCB
	CALL	DOS_POS_RBA
	SCF
	RET	NZ
	CALL	_US_RDREC
	RET	NZ
	LD	A,(US_ZERO)
	OR	A
	JR	Z,_US_07A
;Bit 6 of (uf_status) must be 0 for Zero else NO GO.
	LD	A,(UF_STATUS)
	BIT	UF_ST_ZERO,A
	JR	NZ,_US_INC
	RET			;is OK. (Z)
_US_07A	LD	A,(UF_STATUS)
	BIT	UF_ST_ZERO,A	;if Z, recd unused.
	JR	Z,_US_INC
	CALL	_US_CHKNM
	RET	Z
	JR	_US_INC
;
_US_RDREC	LD	B,UF_LRL
	LD	HL,US_UBUFF
	LD	DE,US_FCB
_US_08	CALL	$GET
	SCF
	RET	NZ
	LD	(HL),A
	INC	HL
	DJNZ	_US_08
	CP	A
	RET
;
_US_CHKNM	LD	HL,(US_NSTR)
	LD	DE,UF_NAME
_US_09	CALL	CI_CMP
	RET	NZ
	LD	A,(HL)
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	_US_09
;
US_POSN		DEFW	0	;Relrecno in ufile
US_HASH		DEFB	0	;Hash for user name.
US_HBUFF	DEFS	256	;Hash codes buffer.
US_RBA		DEFB	0,0,0	;RBA of name start.
US_FCB		DEFM	'USERFILE.ZMS',CR
		DC	32-13,0
US_BUFF		DEFS	256
US_NSTR		DEFW	0	;Name location.
US_UMAX		DEFW	0	;Maximum UID so far
US_PMAX		DEFW	0	;Maximum RRECNO.
;
US_ZERO		DEFB	0	;Zero search flag.
;
*GET	USERFILE		;Data definitions.
;
	ENDIF	;COMMON_SEARCH
;
;strcmp_ci - Case Independant STRCMP
	IFREF	STRCMP_CI
STRCMP_CI:
	CALL	CI_CMP
	RET	NZ
	LD	A,(HL)
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	STRCMP_CI
	ENDIF	;strcmp_ci
;
;CI_CMP: Case independent    CP (hl),(de) for Z,NZ
	IFREF	CI_CMP
CI_CMP
	LD	A,(DE)
	XOR	(HL)
	RET	Z
	CP	20H
	RET	NZ
	LD	A,(HL)
	RES	5,A	;UC/LC bit
;;	DEC	A	;now 40 to 59h
	CP	41H
	RET	C
	CP	5AH	;59h='Z'=Zero Flag.
	RET	NC
	CP	A
	RET
;
	ENDIF	;ci_cmp
;
;HASH: Calculate 8-bit hash of a string
	IFREF	HASH
HASH
	LD	C,0
HASH_1	LD	A,(HL)
	OR	A
	JR	Z,HASH_2
	CP	CR
	JR	Z,HASH_2
	XOR	C
	RLCA
	LD	C,A
	INC	HL
	JR	HASH_1
HASH_2	LD	A,C
	OR	A
	JR	NZ,HASH_3	;use 0 = no user here.
	INC	A
HASH_3	LD	C,A
	RET
;
	ENDIF	;ifref HASH
;
;Multiply: Multiply HL by A, result in HLC like Newdos
	IFREF	MULTIPLY
MULTIPLY
	PUSH	DE
	EX	DE,HL
	LD	C,80H
	LD	HL,0
_MULT1	RRCA
	JR	NC,_MULT2
	ADD	HL,DE
_MULT2	SRL	H
	RR	L
	RR	C
	JR	NC,_MULT1
	POP	DE
	RET
	ENDIF	;multiply
;
;CPHLDE: Compare HL to DE.
	IFREF	CPHLDE
CPHLDE
	LD	A,H
	CP	D
	RET	NZ
	LD	A,L
	CP	E
	RET
	ENDIF	;cphlde
;
;CI_HASH: Case independant hash.
	IFREF	CI_HASH
CI_HASH
	LD	C,0
CIH_1	LD	A,(HL)
	OR	A
	JR	Z,CIH_3
	CP	CR
	JR	Z,CIH_3
	CP	ETX
	JR	Z,CIH_3
	CP	'a'
	JR	C,CIH_2
	CP	'z'+1
	JR	NC,CIH_3
	AND	5FH		;To U/C
CIH_2	XOR	C
	RLCA
	LD	C,A
	INC	HL
	JR	CIH_1
CIH_3	LD	A,C
	OR	A
	JR	NZ,CIH_4
	INC	A
	LD	C,A
CIH_4	RET
;
	ENDIF	;ci_hash
;
;TO_UPPER: String to upper case conversion
	IFREF	TO_UPPER
TO_UPPER:
	LD	A,(HL)
	OR	A
	RET	Z
	CP	CR
	RET	Z
	CP	ETX
	RET	Z
	INC	HL
	CP	'a'
	JR	C,TO_UPPER
	CP	'z'+1
	JR	NC,TO_UPPER
	DEC	HL
	AND	5FH
	LD	(HL),A
	INC	HL
	JR	TO_UPPER
;
	ENDIF	;to_upper
;
;terminate_s: Put 00H byte on the end of a string.
	IFREF	TERMINATE_S
TERMINATE_S
	LD	A,(HL)
	OR	A
	RET	Z
	CP	ETX
	JR	Z,_TERM_01
	CP	CR
	JR	Z,_TERM_01
	INC	HL
	JR	TERMINATE_S
_TERM_01	LD	(HL),0
	RET
;
	ENDIF	;terminate_s
;
;str_len: Find the 0-255 length of a string.
	IFREF	STR_LEN
	ERR	'Should use STRLEN instead of STR_LEN'
STR_LEN
	LD	C,0
_STR_01	LD	A,(HL)
	OR	A
	JR	Z,_STR_02
	INC	C
	INC	HL
	JR	_STR_01
_STR_02	LD	A,C
	RET
;
	ENDIF	;str_len
;
;mess_0: Print a message until NULL terminator.
	IFREF	MESS_0
MESS_0
	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$PUT
	INC	HL
	JR	MESS_0
;
	ENDIF	;mess_0
;
;puts: Put a string to $stdout_def.
	IFREF	PUTS
PUTS
	PUSH	DE
	LD	DE,DCB_2O
	CALL	FPUTS
	POP	DE
	RET
	ENDIF	;puts
;
;fputs: Put a string to a device or file.
	IFREF	FPUTS
FPUTS
	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$PUT
	RET	NZ
	INC	HL
	JR	FPUTS
	ENDIF	;fputs
;
;Fgets: get a string of length in 'B' (max 256)
	IFREF	FGETS
FGETS
_FG1	CALL	$GET
	RET	NZ
	LD	(HL),A
	OR	A
	JR	Z,_FG2
	CP	CR
	JR	Z,_FG2
	INC	HL
	DJNZ	_FG1
	LD	(HL),0
	RET
_FG2	LD	(HL),0
	RET
	ENDIF	;fgets
;
;List: List a file to DCB_2O, allow abort with ^C
	IFREF	LIST_FILE
LIST_FILE
	LD	DE,_L_DCB
	CALL	EXTRACT
	LD	HL,_L_BUFF
	LD	B,0
	CALL	DOS_OPEN_EX
	RET	NZ
_L_LP	LD	DE,_L_DCB
	CALL	$GET
	JR	Z,_L_NE
	CP	1CH
	RET	Z
	CP	1DH
	RET
_L_NE	OR	A
	RET	Z
	LD	DE,DCB_2O
	CALL	$PUT
	CALL	$GET
	CP	1
	JR	NZ,_L_LP
	LD	A,CR
	LD	DE,DCB_2O
	CALL	$PUT
	RET
;
_L_DCB	DEFS	32
_L_BUFF	DEFS	256
;
	ENDIF	;ifref list_file
;
;Extract: Extract a filespec... Doesn't use SYS1.
	IFREF	EXTRACT
EXTRACT:
	PUSH	DE
	LD	B,24
_EXT_01	LD	A,(HL)
	CP	CR
	JR	Z,_EXT_02
	CP	' '
	JR	Z,_EXT_02
	CP	ETX
	JR	Z,_EXT_02
	OR	A
	JR	Z,_EXT_02
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	_EXT_01
;Filename too long.
	LD	A,30H	;bad filespec
	POP	DE
	OR	A
	RET
;
_EXT_02	LD	A,ETX		;For the dos.
	LD	(DE),A
_EXT_03	LD	A,(HL)		;bypass extra spaces
	CP	' '
	JR	NZ,_EXT_04
	INC	HL
	JR	_EXT_03
_EXT_04	POP	DE
	CP	A
	RET
	ENDIF	;extract
;
;std_out: Output byte to $STDOUT
	IFREF	STD_OUT
STD_OUT
	LD	DE,DCB_2O
	CALL	$PUT
	RET
	ENDIF
;
;std_in: Input byte from $STDIN
	IFREF	STD_IN
STD_IN
	LD	DE,DCB_2O
	CALL	$PUT
	RET
	ENDIF
;
;Strcpy: Copy string at HL to DE up to null.
	IFREF	STRCPY
STRCPY:
	LD	A,(HL)
	LD	(DE),A
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	STRCPY
	ENDIF	;strcpy
;
;Shuffle: Display a 64 byte window on the screen.
	IFREF	SHUFFLE
SHUFFLE:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	HL,3C41H	;line 1 + 1
	LD	DE,3C40H
	LD	BC,63
	LDIR
	LD	(3C7FH),A
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
	ENDIF	;shuffle.
;
;strcat: Concatenate HL string on end of DE string.
	IFREF	STRCAT
STRCAT
	LD	A,(DE)
	OR	A
	JR	Z,_STRCAT_1
	INC	DE
	JR	STRCAT
_STRCAT_1	LD	A,(HL)
	LD	(DE),A
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	_STRCAT_1
	ENDIF	;strcat
;
;strlen: Find (in HL) the length of the string in DE
	IFREF	STRLEN
STRLEN
	LD	HL,0
_STRLEN_1	LD	A,(DE)
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	_STRLEN_1
	ENDIF	;strlen
;
;get_number: Convert a string ptd to by HL to a number HL
	IFREF	GET_NUMBER
GET_NUMBER
	LD	DE,0
$GN_01	LD	A,(HL)
	CALL	IF_NUM
	JR	NZ,$GN_02
	CALL	$GN_03
	INC	HL
	JR	$GN_01
;
$GN_02	PUSH	DE
	POP	HL
	RET
;
$GN_03	PUSH	HL
	SUB	'0'
	PUSH	DE
	POP	HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	ADD	HL,HL
	LD	E,A
	LD	D,0
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	RET
;
	ENDIF	;get_number
;
;
;if_num: Check if contents of A is numeric
	IFREF	IF_NUM
IF_NUM:		;check if ascii numeric
	CP	'0'
	RET	C
	CP	'9'
	RET	NC
	CP	A
	RET
	ENDIF	;ifref IF_NUM
;
;list_nostop: list a file without allowing aborting.
	IFREF	LIST_NOSTOP
LIST_NOSTOP:
	LD	DE,_LN_FCB
	CALL	DOS_EXTRACT
	LD	HL,_LN_BUFF
	LD	B,0
	CALL	DOS_OPEN_EX
	RET	NZ
;
_LN_LOOP	LD	DE,_LN_FCB
	CALL	$GET
	JR	Z,_LN_NEOF
	CP	1CH
	RET	Z
	CP	1DH
	RET	Z
	OR	80H
	CALL	DOS_ERROR
	RET
;
_LN_NEOF	LD	DE,DCB_2O
	CALL	$PUT
	CALL	$GET
	JR	_LN_LOOP
;
_LN_FCB	DEFS	32
_LN_BUFF	DEFS	256
;
	ENDIF		;ifref list_nostop
;
;twirl: Reselect & spin the last selected drive.
	IFREF	TWIRL
TWIRL
	LD	A,(4308H)
	CALL	445BH
	RET
	ENDIF	;twirl
;
; dtr_off: Turn off DTR usually to drop carrier on modem
	IFREF	DTR_OFF
DTR_OFF
	LD	A,82H
	OUT	(WRSTAT),A
	LD	A,40H
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT1)
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT2)
	RES	DTR_BIT,A
	LD	(MODEM_STAT2),A
	OUT	(WRSTAT),A
	RET
	ENDIF	;dtr_off
;
; dtr_on: Turn on DTR
	IFREF	DTR_ON
DTR_ON
	LD	A,82H		;Re-init USART
	OUT	(WRSTAT),A
	LD	A,40H
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT1)
	OUT	(WRSTAT),A
	LD	A,(MODEM_STAT2)
	SET	DTR_BIT,A
	LD	(MODEM_STAT2),A
	OUT	(WRSTAT),A
	RET
	ENDIF	;dtr_on
;
;End of routines.lib
