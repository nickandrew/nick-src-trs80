;filed/asm
WHLCK1:	XOR	A		; If non-zero, he's a big wheel
	RET			; Return A=0 (Z)
	PAGE
; Close input and output files (called at program exit)
IFLAG	DEFB	0		;IFLAG moved.
OFLAG	DEFB	0		;OFLAG moved.
;
ICLOSE:	LD	DE,IFCB		; Setup ARC file FCB
	CALL	CLOSE
; Close output file
OCLOSE:	LD	DE,OFCB		; Setup output file FCB
; Close a file if open
CLOSE:	LD	A,(DE)		;File is open?
	OR	A
	RET	Z
	CALL	DOS_CLOSE
	RET			; Return to caller (NZ if error)
;	
; BDOS file functions for output file
;;OFDOS:	LD	DE,OFCB		; Setup output file FCB
;; BDOS file functions
;;FDOS:	CALL	BDOS		; Perform function
;;	INC	A		; Test directory code
;;	RET			; Return (Z set if file not found)
; Set DMA address for file input/output
;NOW only read char from keyboard.
SETDMA:
; Check for CTRL-C abort (and/or read console char if any)
CABORT:	CALL	002BH		;read char from keyboard
	CP	CTLC		; Is it CTRL-C?
	RET	NZ		; No, return char (and NZ) to caller
	JP	ABORT		; Yes, go abort program
	PAGE
	SUBTTL	Archive File Input Routines
; Get counted byte from archive subfile (saves alternate register set)
; The alternate register set normally contains values for the low-level
; output routines (see PUTSET).  This entry to GETC saves these and
; returns with them enstated (for PUT, PUTUP, etc.).  Caller must issue
; EXX after call to return these to the alternate set, and must save and
; restore any needed values from the original register set.
; Note:	At first glance, all this might seem unnecessary, since BDOS
;	(might be called by GETREC) does not use the Z80 alternate
;	register set (at least with Digital Research CP/M).  But some
;	CBIOS implementations (e.g. Osborne's) assume these are fair
;	game, so we are extra cautious here.
GETCX:	EXX			; Swap in alt regs (GETC saves them)
; Get counted byte from component file of archive
; GETC returns with carry set (and a zero byte) upon reaching the
; logical end of the current subfile.  (This relies on the GET routine
; NOT returning with carry set.)
GETC:	PUSH	BC		; Save registers
	PUSH	DE		
	PUSH	HL
	LD	HL,SIZE		; Point to remaining bytes in subfile
	LD	B,4		; Setup for long (4-byte) size
GETC1:	LD	A,(HL)		; Get size
	DEC	(HL)		; Count it down
	OR	A		; But was it zero? (clears carry)
	JR	NZ,GET1		; No, go get byte (must not set carry!)
;
	INC	HL		; Point to next byte of size
	DJNZ	GETC1		; Loop for multi-precision decrement
	LD	B,4		; Size was zero, now it's -1
GETC2:	DEC	HL		; Reset size to zero...
	LD	(HL),A		; (SIZE must contain valid bytes to skip
	DJNZ	GETC2		;  to get to next subfile in archive)
	SCF			; Set carry to indicate end of subfile
	JR	GET2		; Go restore registers and return zero
	PAGE
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
; Get next sequential byte from archive file
; Note:	GET and SEEK rely on the fact that the default DMA buffer
;	used for file input (DBUF) begins on a half-page boundary.
;	I.e. DBUF address = nn80H (nn = 00 for standard CP/M).
;;GET:	PUSH	BC		; Save registers
;;	PUSH	DE		
;;	PUSH	HL
;;GET1:	LD	HL,(GETPTR)	; Point to last byte read
;;	INC	L		; At end of buffer?
;;	CALL	Z,GETNXT	; Yes, read next record and reset ptr
;;	LD	(GETPTR),HL	; Save new buffer ptr
;;	LD	A,(HL)		; Fetch byte from there
;;GET2:	POP	HL		; Restore registers
;;	POP	DE
;;	POP	BC
;;	RET			; Return
;;; Get next sequential record from archive file
;;GETNXT:	LD	C,$READ		; Setup read-sequential function code
;;; Get record (sequential or random) from archive file
;;GETREC:	LD	DE,DBUF		; Point to default buffer
;;	PUSH	DE		; Save ptr
;;	PUSH	BC		; Save read function code
;;	CALL	SETDMA		; Set DMA address
;;	LD	DE,IFCB		; Setup FCB address
;;	POP	BC		; Restore read function
;;	CALL	BDOS		; Do it
;;	POP	HL		; Restore buffer ptr
;;	OR	A		; End of file?
;;	RET	Z		; Return if not
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
; Unexpected end of file
EOF:	LD	DE,EOFERR	; Print message and abort
	JP	PABORT		; (not much else we can do)
	PAGE
; Seek to new random position in file (relative to current position)
; (BCDE = 32-bit byte offset)
SEEK:	LD	A,B		; Most CP/M (2.2) can handle is 23 bits
	OR	A		; So highest bits of offset must be 0
	JR	NZ,EOF		; Else, that's certainly past eof!
;*******************************
	LD	A,E
	LD	E,D
	LD	D,C
	LD	C,A
;Now.. registers D, E, C have the offset.
	LD	A,(IFCB+5)
	ADD	A,C
	LD	C,A
	LD	HL,(IFCB+10)	;Get next med/high
	ADC	HL,DE
	LD	DE,IFCB
	CALL	DOS_POS_RBA
	JP	NZ,F_ERROR	;File positioning error
;;	LD	A,E		; Get low bits of offset in A
;;	LD	L,D		; Get middle bits in HL
;;	LD	H,C
;;	ADD	A,A		; LSB of record offset -> carry
;;	ADC	HL,HL		;Record offset -> HL
;;	JR	C,EOF		; If too big, report unexpected eof
;;	RRA			; Get byte offset
;;	EX	DE,HL		; Save record offset
;;	LD	HL,GETPTR	; Point to offset (+80H) of last byte in
;;	ADD	A,(HL)		; Add byte offsets
;;	LD	(HL),A		; Update buffer ptr for new position
;;	INC	A		; But does it overflow current record?
;;	JP	P,SEEK1		; Yes, skip
;;	LD	A,D		; Check record offset
;;	OR	E
;;	RET	Z		; Return if none (still in same record)
;;	DEC	DE		; Get offset from next record
;;	JR	SEEK2		; Go compute new record no.
;;SEEK1:	ADD	A,7FH		; Get proper byte offset in DMA page
;;	LD	(HL),A		; Save new buffer pointer
;;SEEK2:	PUSH	DE		; Save record offset
;;	LD	DE,IFCB
;;	LD	C,$RECORD	; Compute current "random" record no.
;;	CALL	BDOS		; (I.e. next sequential record to read)
;;	LD	HL,(IFCB+@RN)	; Get result
;;	POP	DE		; Restore record offset
;;	ADD	HL,DE		; Compute new record no.
;;	JR	C,EOF		; If >64k, it's past largest (8 Mb) file
;;	LD	(IFCB+@RN),HL	; Save new record no.
;;	LD	C,$READR	; Read the random record
;;	CALL	GETREC
;;	LD	HL,IFCB+@CR	; Point to current record in extent
;;	INC	(HL)		; Bump for subsequent sequential read
	RET			; Return
	PAGE
; Get archive file header
GETHDR:	LD	DE,HDRBUF	; Set to fill header buffer
	LD	B,HDRSIZ	; Setup normal header size
	CP	1		; But test if version 1
	PUSH	AF		; Save test result
	JR	NZ,GETHD2	; Skip if not version 1
	LD	B,HDRSIZ-4	; Else, header is 4 bytes less
	JR	GETHD2		; Go to store loop
GETHD1:	CALL	GET		; Get header byte
GETHD2:	LD	(DE),A		; Store in buffer
	INC	DE
	DJNZ	GETHD1		; Loop for all bytes
	POP	AF		; Version 1?
	RET	NZ		; No, all done
	LD	HL,SIZE		; Yes, point to compressed size
	LD	C,4		; It's 4 bytes
	LDIR			; Move to uncompressed length
	RET			; Return
	PAGE
; Get, save, and test file name from archive header
GETNAM:	LD	DE,NAME		; Point to name in header
	LD	HL,OFCB		; Point to output file name
;Was..	ld	hl,ofcb+@fn
	LD	IX,TNAME	; Point to test pattern
	LD	B,11		; Set count for name and type
GETN1:	LD	A,(DE)		; Get next name char
	AND	7FH		; Ensure no flags, is it end of name?
	JR	Z,GETN4		; Yes, go store blank
	INC	DE		; Bump name ptr
	CP	' '+1		; Is it legal char for file name?
	JR	C,GETN2		; No, if blank or non-printing,
	CP	DEL		;  or this
	JR	NZ,GETN3	; Skip if ok
GETN2:	LD	A,'_'		; Else, change to something legal
GETN3:	CALL	UPCASE		; Ensure it's upper case
	CP	'.'		; But is it type separator?
	JR	NZ,GETN5	; No, go store name char
	LD	A,B		; Get count of chars left
	CP	4		; Reached type yet?
	JR	C,GETN1		; Yes, bypass the separator
	DEC	DE		; Backup to re-read separator
GETN4:	LD	A,' '		; Set to store a blank
GETN5:	LD	(HL),A		; Store char in output name
	LD	A,(IX)		;Get pattern char
	INC	IX		; Bump pattern ptr
	CP	'?'		; Pattern matches any char?
	JR	Z,GETN6		; Yes, skip
	CP	(HL)		; Matches this char?
	RET	NZ		; Return (NZ) if not
GETN6:	INC	HL		; Bump store ptr
	DJNZ	GETN1		; Loop until FCB name filled
;**********
	RET		;No fill the rest of the fcb.
;
;**********
;;BCVALUE	EQU	@FCBSZ-@FN-11
;;	LD	BC,256*BCVALUE
;;	JP	FILL		; Zero rest of FCB, return (Z still set)
	RET
	PAGE
	SUBTTL	File Output Routines
; Check output drive and setup for file output
OUTSET	;;:	LD	A,(HODRV)	; Get highest allowed output drive
;;	LD	B,A		; Save for later test
;;	CALL	WHLCK		; Check wheel byte
;;	DEC	A		; Is user privileged?
;;	JR	NZ,OUTS1	; Yes, skip
;;	LD	B,A		; Else, no output drive allowed
;;	LD	A,(TYFLG)	; Fetch flag for typeout allowed
;;OUTS1:	LD	C,A		; Save typeout flag (always if wheel)
;;	LD	A,(OFCB)	; Any output drive?
;;	OR	A
;;	JR	Z,CKTYP		; No, go see if typeout permitted
;;;	
;;	DEC	A		; Get zero-relative drive no.
;;	CP	B		; In range of allowed drives?
;;	LD	DE,BADODR	; No, report bad output drive
;;	JP	NC,PABORT	;  and abort
;;	LD	E,A		; Save output drive
;;	PUSH	DE
;;	ADD	A,'0'		; Convert to ASCII
;;	LD	(OUTDRV),A	; Store drive letter for message
	LD	DE,OUTMSG	; Show output drive
	CALL	PRINTL
;;	LD	C,$DISK		; Get default drive
;;	CALL	BDOS
;;	POP	DE		; Recover output drive
;;	CP	E		; Test if same as default
;;	PUSH	AF		; Save default drive (and test result)
;;	LD	C,$SELECT	; Select output drive
;;	CALL	NZ,BDOS		;  (if different than default)
;;	CALL	GETBLS		; Get its block size for listing
;;	POP	AF		; Restore original default drive
;;	LD	E,A
;;	LD	C,$SELECT	; Reselect it
;;	CALL	NZ,BDOS		;  (if changed)
	PAGE
; Initialize lookup table for CRC generation
; Note:	For maximum speed, the CRC routines rely on the fact that the
;	lookup table (CRCTAB) is page-aligned.
X16	EQU	0		; x^16 (implied)
X15	EQU	1	;1 SHL (15-15)	; x^15
X2	EQU	8192	;1 SHL (15-2)	; x^2
X0	EQU	32768	;1 SHL (15-0)	; x^0 = 1
POLY	EQU	X16+X15+X2+X0	; Polynomial (CRC-16)
CRCINI:	LD	HL,CRCTAB+256	; Point to 2nd page of lookup table
	LD	A,H		; Check enough memory to store it
	CALL	CKMEM
	LD	DE,POLY		; Setup polynomial
; Loop to compute CRC for each possible byte value from 0 to 255
CRCIN1:	LD	A,L		; Init low CRC byte to table index
	LD	BC,256*8	; Setup bit count, clear high CRC byte
; Loop to include each bit of byte in CRC
CRCIN2:	SRL	C		; Shift CRC right 1 bit (high byte)
	RRA			; (low byte)
