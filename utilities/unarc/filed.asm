; @(#) filed.asm - Archive file input routines, 29 Apr 89
;
	IFDEF	SHOWD
*LIST	ON
	ELSE
*LIST	OFF
	ENDIF
;
;
	SUBTTL	Archive File Input Routines
;Get counted byte from archive subfile (saves alternate register set)
;The alternate register set normally contains values for the low-level
;output routines (see PUTSET).  This entry to GETC saves these and
;returns with them enstated (for PUT, PUTUP, etc.).  Caller must issue
;EXX after call to return these to the alternate set, and must save and
;restore any needed values from the original register set.
;
;-------------------------------------------------------------------------
; # GETCX: Read one counted byte, exchange registers first
;-------------------------------------------------------------------------
;
GETCX:	EXX			;Swap in alt regs (GETC saves them)
;Get counted byte from component file of archive
;GETC returns with carry set (and a zero byte) upon reaching the
;logical end of the current subfile.  (This relies on the GET routine
;NOT returning with carry set.)
;
;-------------------------------------------------------------------------
; # GETC: Read one counted byte
;-------------------------------------------------------------------------
;
GETC:	PUSH	BC		;Save registers
	PUSH	DE		
	PUSH	HL
;
	LD	HL,SIZE		;Point to remaining bytes in subfile
	LD	B,4		;Setup for long (4-byte) size
GETC1	LD	A,(HL)		;Get size
	DEC	(HL)		;Count it down
	OR	A		;But was it zero? (clears carry)
	JR	NZ,GET1		;No, go get byte (must not set carry!)
;
	INC	HL		;Point to next byte of size
	DJNZ	GETC1		;Loop for multi-precision decrement
;
	LD	B,4		;Size was zero, now it's -1
GETC2	DEC	HL		;Reset size to zero...
	LD	(HL),A		;(SIZE must contain valid bytes to skip
	DJNZ	GETC2		;to get to next subfile in archive)
	JR	GET2		;Go restore registers and return zero
;
GET1	CALL	GET
	POP	HL
	POP	DE
	POP	BC
	RET
GET2
	POP	HL
	POP	DE
	POP	BC
	LD	A,0		;Return value of 0
	SCF			;Carry set to indicate end of subfile
	RET
;
;-------------------------------------------------------------------------
; # GET: Read one byte directly from input file
;-------------------------------------------------------------------------
;
GET
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	DE,IFCB
	CALL	$GET
	SCF
	CCF			;Ensure carry flag is cleared
	POP	HL
	POP	DE
	POP	BC
	RET	Z
	CP	1CH
	JP	NZ,F_ERROR	;Some I/O error
;Unexpected end of file
	LD	DE,EOFERR	;Print Eof message and abort
	JP	PABORT
;
;-------------------------------------------------------------------------
; # SEEK: Seek to file, 32 bit offset, relative to current position
;-------------------------------------------------------------------------
;
;Seek to new random position in file (relative to current position)
;(BCDE = 32-bit byte offset)
SEEK:	LD	A,B		;Can't handle upper 8 bits
	OR	A
	JR	Z,SEEK01
	LD	DE,EOFERR
	JP	PABORT
SEEK01
	LD	A,E
	LD	E,D
	LD	D,C
	LD	C,A		;Is now: 0DEC
;Now.. registers D, E, C have the offset.
	LD	A,(IFCB+5)	;Get next low
	ADD	A,C
	LD	C,A
	LD	HL,(IFCB+10)	;Get next med/high
	ADC	HL,DE
	LD	DE,IFCB
	CALL	DOS_POS_RBA
	JP	NZ,F_ERROR	;File positioning error
	RET			;Return
;
;-------------------------------------------------------------------------
; # GETHDR: Read an archive file header
;-------------------------------------------------------------------------
;
GETHDR:	LD	DE,HDRBUF	;Set to fill header buffer
	LD	B,HDRSIZ	;Setup normal header size
	CP	1		;But test if version 1
	PUSH	AF		;Save test result
	JR	NZ,GETHD2	;Skip if not version 1
	LD	B,HDRSIZ-4	;Else, header is 4 bytes less
	JR	GETHD2		;Go to store loop
GETHD1:	CALL	GET		;Get header byte
GETHD2:	LD	(DE),A		;Store in buffer
	INC	DE
	DJNZ	GETHD1		;Loop for all bytes
	POP	AF		;Version 1?
	RET	NZ		;No, all done
	LD	HL,SIZE		;Yes, point to compressed size
	LD	BC,4		;It's 4 bytes
	LDIR			;Move to uncompressed length
	RET			;Return
;
;-------------------------------------------------------------------------
; # GETNAM: Copy filename from header into OFCB for output
; Massage filename into something reasonable
; Test if it is a filename we desire
;   Return Z if it is, NZ if not (so skip)
;-------------------------------------------------------------------------
;
GETNAM
	LD	DE,NAME		;Point to name in header
	LD	HL,OFCB		;Point to output fcb
	CALL	MASSAGE_FN	;Massage OFCB filename
	LD	HL,OFCB
	CALL	GETN81		;Fix first char of name and extension
	CALL	TESTALL
	RET
;
;-------------------------------
;  Massage a fairly arbitrary filename into something the DOS likes
;-------------------------------
;
MASSAGE_FN
	LD	B,13		;Maximum length
GETN1:	LD	A,(DE)		;Get next name char
	AND	7FH		;Ensure no flags, is it end of name?
	JR	Z,GETN11	;Yes, terminate & return
	CP	' '		;End of name if space
	JR	Z,GETN11	;So terminate & return
	CP	CR		;Or carriage return
	JR	Z,GETN11	;So terminate & return
	INC	DE		;Bump name ptr
	CP	'.'		;If extension separator
	JR	Z,GETN4		;Change to our separator
	CP	'0'		;Is it legal char for file name?
	JR	C,GETN2		;Illegal, change to 'x'
	CP	'9'+1
	JR	C,GETN3		;Ok
	AND	5FH		;fold to upper case.
	CP	'A'
	JR	C,GETN2		;illegal, change to 'x'
	CP	'Z'+1		;or others
	JR	C,GETN3		;Skip if ok
;
GETN2:	LD	A,'x'		;Else, change to something legal
GETN3:	LD	(HL),A		;Store char in output name
	INC	HL		;Bump store ptr
	DJNZ	GETN1		;Loop until FCB name filled
;End of filename or too long
GETN11	LD	(HL),3		;Store terminator
	RET
;
GETN4
	LD	A,SEP		;Replace it with our separator
	JR	GETN3
;
;-------------------------------------------------------------------------
; # GETN81: Fix first character of name and extension
;-------------------------------------------------------------------------
;
GETN81
GETN81A
	LD	A,(HL)
	CP	'0'
	JR	C,GETN82
	CP	'9'+1
	JR	NC,GETN82
	ADD	A,'A'-'0'	;Make a-j from 0-9
	LD	(HL),A
GETN82	LD	A,(HL)
	INC	HL
	CP	ETX
	JR	Z,GETN83
	CP	SEP
	JR	NZ,GETN82
	JR	GETN81A
;
GETN83
	CP	A
	RET
;
;-------------------------------------------------------------------------
; # TESTALL: Test the current subfile name against all parameters
;-------------------------------------------------------------------------
;
TESTALL
	LD	HL,(PARAMX)
	LD	A,(HL)
	CP	CR
	RET	Z		;No args, so do not check
TESTIT
	PUSH	HL		;Push start of filename
	EX	DE,HL
	LD	HL,SFCB_2	;Massage into sfcb_2
	CALL	MASSAGE_FN
	LD	HL,SFCB_2
	CALL	GETN81		;Fix first char of name and extension
	CALL	TEST_1		;Test if equal
	POP	HL		;Pop start of filename
	JR	Z,TEST_OK
	CALL	NEXT_ARG
	JR	NZ,TESTIT
	XOR	A
	CP	1
	RET	;nz
;
TEST_OK
	CP	A
	RET
;
;-------------------------------------------------------------------------
; # TEST_1: Test if the filename in SFCB_2 matches that in OFCB
;-------------------------------------------------------------------------
;
TEST_1
	LD	HL,OFCB
	LD	DE,SFCB_2
TEST_2
	LD	A,(DE)
	CP	(HL)
	RET	NZ
	CP	3
	RET	Z
	INC	HL
	INC	DE
	JR	TEST_2
;
;-------------------------------------------------------------------------
; # NEXT_ARG: 
;-------------------------------------------------------------------------
;
NEXT_ARG
NA_01
	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,NA_02
	CP	CR
	RET	Z		;Z = cr - No match - no more args!
	OR	A
	RET	Z
	JR	NA_01
;
NA_02
	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,NA_02
	CP	CR
	RET	Z		;If CR, no more args.
	OR	A
	RET	Z		;If 0, no more args.
	RET
;
