;filed - last updated 14-Jan-88
;
	IFDEF	SHOWD
*LIST	ON
	ELSE
*LIST	OFF
	ENDIF
;
WHLCK1:	XOR	A		;If non-zero, he's a big wheel
	RET			;Return A=0 (Z)
;;
;Close input and output files (called at program exit)
IFLAG	DEFB	0		;IFLAG moved.
OFLAG	DEFB	0		;OFLAG moved.
;
ICLOSE:	LD	DE,IFCB		;Setup ARC file FCB
	CALL	CLOSE
;Close output file
OCLOSE:	LD	DE,OFCB		;Setup output file FCB
	CALL	CLOSE
	RET
;
;Close a file if open
CLOSE:	LD	A,(DE)		;File is open?
	OR	A
	RET	Z
	CALL	DOS_CLOSE
	RET			;Return to caller (NZ if error)
;	
;Set DMA address for file input/output
;NOW only read char from keyboard.
SETDMA:
	RET
;Check for CTRL-C abort (and/or read console char if any)
CABORT:	CALL	002BH		;read char from keyboard
	CP	CTLC		;Is it CTRL-C?
	JP	Z,ABORT
	CP	CTLS		;Is it pause?
	RET	NZ		;No, return char (and NZ) to caller
CABORT2	CALL	2BH
	CP	CTLQ
	JR	NZ,CABORT2
	CP	1
	RET
;
	SUBTTL	Archive File Input Routines
;Get counted byte from archive subfile (saves alternate register set)
;The alternate register set normally contains values for the low-level
;output routines (see PUTSET).  This entry to GETC saves these and
;returns with them enstated (for PUT, PUTUP, etc.).  Caller must issue
;EXX after call to return these to the alternate set, and must save and
;restore any needed values from the original register set.
GETCX:	EXX			;Swap in alt regs (GETC saves them)
;Get counted byte from component file of archive
;GETC returns with carry set (and a zero byte) upon reaching the
;logical end of the current subfile.  (This relies on the GET routine
;NOT returning with carry set.)
GETC:	PUSH	BC		;Save registers
	PUSH	DE		
	PUSH	HL
	LD	HL,SIZE		;Point to remaining bytes in subfile
	LD	B,4		;Setup for long (4-byte) size
GETC1:	LD	A,(HL)		;Get size
	DEC	(HL)		;Count it down
	OR	A		;But was it zero? (clears carry)
	JR	NZ,GET1		;No, go get byte (must not set carry!)
;
	INC	HL		;Point to next byte of size
	DJNZ	GETC1		;Loop for multi-precision decrement
	LD	B,4		;Size was zero, now it's -1
GETC2:	DEC	HL		;Reset size to zero...
	LD	(HL),A		;(SIZE must contain valid bytes to skip
	DJNZ	GETC2		;to get to next subfile in archive)
	SCF			;Set carry to indicate end of subfile
	JR	GET2		;Go restore registers and return zero
;
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
	LD	A,0
	SCF
	RET
;
GET	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	DE,IFCB
	CALL	$GET
	SCF
	CCF
	POP	HL
	POP	DE
	POP	BC
	RET	Z
	CP	1CH
	JR	Z,EOF
	JP	F_ERROR
;Unexpected end of file
EOF:	LD	DE,EOFERR	;Print message and abort
	JP	PABORT
;
;Seek to new random position in file (relative to current position)
;(BCDE = 32-bit byte offset)
SEEK:	LD	A,B		;Can't handle upper 8 bits
	OR	A
	JR	NZ,EOF
;*******************************
	LD	A,E
	LD	E,D
	LD	D,C
	LD	C,A		;Is now: 0DEC
;Now.. registers D, E, C have the offset.
	LD	A,(IFCB+5)
	ADD	A,C
	LD	C,A
	LD	HL,(IFCB+10)	;Get next med/high
	ADC	HL,DE
	LD	DE,IFCB
	CALL	DOS_POS_RBA
	JP	NZ,F_ERROR	;File positioning error
	RET			;Return
;
;Get archive file header
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
;
;
;Get, save, and test file name from archive header
GETNAM:	LD	DE,NAME		;Point to name in header
	LD	HL,OFCB		;Point to output fcb
	LD	IX,TNAME	;Point to test pattern
	LD	B,11		;Set count for name and type
GETN1:	LD	A,(DE)		;Get next name char
	AND	7FH		;Ensure no flags, is it end of name?
	JR	Z,GETN77	;Yes, check afn & exit.
	INC	DE		;Bump name ptr
	CP	'.'		;If separator
	JR	Z,GETN8
	CP	'0'		;Is it legal char for file name?
	JR	C,GETN2		;No, if blank or non-printing,
	CP	'9'+1
	JR	C,GETN3		;numeric is OK
	AND	5FH		;to upper case.
	CP	'A'
	JR	C,GETN2		;illegal.
	CP	'Z'+1		;or ‚others
	JR	C,GETN3		;Skip if ok
GETN2:	LD	A,'x'		;Else, change to something legal
GETN3:
	JR	GETN5
GETN8
	LD	A,B
	CP	4
	JR	C,GETN9
	DEC	DE		;Reread the dot later
	LD	A,(IX)
	INC	IX
	CP	' '
	JR	Z,GETN10
	LD	A,(IX-1)	;it was incremented
	CP	'?'
	JR	Z,GETN10
	RET			;NZ .. failed.
GETN9
;
	LD	(HL),SEP
;
	INC	HL
;*******************************
	LD	IX,TNAME+8	;Check ext next
	JR	GETN1		;Loop for next name char.
;
GETN5:	LD	(HL),A		;Store char in output name
GETN7	LD	A,(IX)		;Get pattern char
	INC	IX		;Bump pattern ptr
	CP	'?'		;Pattern matches any char?
	JR	Z,GETN6		;Yes, skip
	CP	(HL)		;Matches this char?
	RET	NZ		;Return (NZ) if not
GETN6:	INC	HL		;Bump store ptr
GETN10	DJNZ	GETN1		;Loop until FCB name filled
;**********
	LD	(HL),3		;Store terminator
	JR	GETN81		;Fix first character
	RET
;
GETN77	LD	A,(IX)		;Must be ' ' or '?'
	INC	IX
	CP	' '
	JR	Z,GETN78
	CP	'?'
	RET	NZ
GETN78	DJNZ	GETN77
	LD	(HL),3
GETN81				;Fix first char of fname
	LD	HL,OFCB
	LD	A,(HL)
	CP	'0'
	JR	C,GETN82
	CP	'9'+1
	JR	NC,GETN82
	ADD	A,11H		;Make A-J from 0-9
	LD	(HL),A
GETN82	LD	A,(HL)
	INC	HL
	CP	3
	JR	Z,GETN83
	CP	SEP
	JR	NZ,GETN82
	LD	A,(HL)
	CP	'0'
	JR	C,GETN83
	CP	'9'+1
	JR	NC,GETN83
	ADD	A,11H		;Make 0-9 into A-J
	LD	(HL),A
GETN83
	CP	A
	RET
;
;
;
	SUBTTL	File Output Routines
;Check output drive and setup for file output
OUTSET
;
;Initialize lookup table for CRC generation
;Note:	For maximum speed, the CRC routines rely on the fact that the
;	lookup table (CRCTAB) is page-aligned.
X16	EQU	0		;x^16 (implied)
X15	EQU	1	;1 SHL (15-15)	;x^15
X2	EQU	8192	;1 SHL (15-2)	;x^2
X0	EQU	32768	;1 SHL (15-0)	;x^0 = 1
POLY	EQU	X16+X15+X2+X0	;Polynomial (CRC-16)
CRCINI:	LD	HL,CRCTAB+256	;Point to 2nd page of lookup table
	LD	A,H		;Check enough memory to store it
	CALL	CKMEM
	LD	DE,POLY		;Setup polynomial
;Loop to compute CRC for each possible byte value from 0 to 255
CRCIN1:	LD	A,L		;Init low CRC byte to table index
	LD	BC,256*8	;Setup bit count, clear high CRC byte
;Loop to include each bit of byte in CRC
CRCIN2:	SRL	C		;Shift CRC right 1 bit (high byte)
	RRA			;(low byte)
