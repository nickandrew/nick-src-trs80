; @(#) fileh.asm - Routines - 30 Apr 89
;
; Output next byte decoded from crunched file
;
PUTCR:	EXX			; Swap in output registers
	JP	0		; Vector to the appropriate routine
PUTCRP	EQU	$-2		; (ptr to PUT or PUTUP stored here)
;
; Low-level output routines
; Register usage (once things get going):
;
;  B  = Flag for repeated byte expansion (1 = repeat count expected)
;  C  = Last byte output (saved for repeat expansion)
;  DE = Output buffer pointer
;  HL = CRC value
; Setup registers for output (preserves AF)
PUTSET:	LD	HL,(BUFPAG-1)	; Get buffer start address (in H)
	LD	L,0		; (It's always page aligned)
	EX	DE,HL
	LD	H,E		; Clear the CRC
	LD	L,E
	LD	B,E		; Clear repeat flag
	RET			; Return
;
; Table of starting output buffer pages
; (No. of entries must match ARCVER)
OBUFT:				; Header version:
	DB	BUFF/16/16	; 1 - Uncompressed (obsolete)
	DB	BUFF/16/16	; 2 - Uncompressed
	DB	BUFF/16/16	; 3 - Packed
	DB	BUFFSQ/16/16	; 4 - Squeezed
	DB	BUFFCX/16/16	; 5 - Crunched (unpacked) (old)
	DB	BUFFCX/16/16	; 6 - Crunched (packed) (old)
	DB	BUFFCX/16/16	; 7 - Crunched (packed, faster) (old)
	DB	BUFFCR/16/16	; 8 - Crunched (new)
;
	PAGE
; Unpack and output packed byte
PUTUP:	DJNZ	PUTUP4		; Expecting a repeat count?
	LD	B,A		; Yes ("byte REP count"), save count
	OR	A		; But is it zero?
	JR	NZ,PUTUP2	; No, enter expand loop (did one before)
	LD	A,REP		; Else ("REP 0"), put rep code
	JR	PUT		; Go output REP code as data
;
PUTUP1:	LD	A,C		; Get repeated byte
	CALL	PUT		; Output it
PUTUP2:	DJNZ	PUTUP1		; Loop until repeat count exhausted
	RET			; Return when done
;
PUTUP3:	INC	B		; Set flag for repeat count next
	RET			; Return (must wait for next call)
;
PUTUP4:	INC	B		; Normal byte, reset repeat flag
	CP	REP		; But is it the special flag code (REP)?
	JR	Z,PUTUP3	; Yes, go wait for next byte
	LD	C,A		; Save output byte for later repeat
; Output byte (and update CRC)
PUT:	LD	(DE),A		; Store byte in buffer
	XOR	L		; Include byte in lower CRC
	LD	L,A		;  to get lookup table index
	LD	A,H		; Save high (becomes new low) CRC byte
	PUSH	BC
	LD	C,L
	LD	B,0
	LD	HL,CRCTAB
	ADD	HL,BC
	POP	BC
	XOR	(HL)		; Include in CRC
	INC	H		; Point to table value high byte
	LD	H,(HL)		; Fetch to get new high CRC byte
	LD	L,A		; Copy new low CRC byte
	INC	E		; Now that CRC updated, bump buffer ptr
	RET	NZ		; Return if not end of page
	INC	D		; Point to next buffer page
	LD	A,(BUFLIM)	; Get buffer limit page
	CP	D		; Buffer full?
	RET	NZ		; No, return
;
; Output buffer
PUTBUF:	PUSH	HL		; Save register (i.e. CRC)
	LD	HL,(BUFPAG-1)	; Get buffer start address
	XOR	A		; (it's always page-aligned)
	LD	L,A
	EX	DE,HL		; Swap with buffer end ptr
	SBC	HL,DE		; HL=computed buffer length
	JR	Z,PUTB2		; But skip all the work if it's empty
	PUSH	BC		; Save register (i.e. repeat flag/byte)
	LD	B,H		; BC= buffer length
	LD	C,L
	LD	HL,(LEN)	; Get (remaining) output file length
	SBC	HL,BC		; Subtract size of buffer
	LD	(LEN),HL	; (Should be zero when we're all done)
	JR	NC,PUTB1	; Skip if double-precision not needed
	LD	HL,(LEN+2)	; Update upper word of length
	DEC	HL
	LD	(LEN+2),HL
PUTB1:	PUSH	DE		; Save buffer start
	CALL	WRTBUF		; Write the buffer
	POP	DE		; Reset output ptr for next refill
	POP	BC		;Pop repeat flag/byte
PUTB2:	POP	HL
	RET			; Return to caller
;
;-------------------------------------------------------------------------
; # WRTBUF: Write buffer to disk
;-------------------------------------------------------------------------
;
WRTBUF:	LD	A,(OFLAG)	; Output file open?
	OR	A
	JR	Z,TYPBUF	; No, go typeout buffer instead
	LD	H,D		; Get buffer end ptr
	LD	L,E
	ADD	HL,BC
	JR	WRTB2		; Enter loop
;
WRTB2:	LD	A,L		; Buffer ends on a CPM record boundary?
	OR	B		; At least one page to write?
	JR	Z,WRTB4		; Skip if not
WRTB3:	PUSH	BC		; Save remaining byte count
	EX	DE,HL
	PUSH	HL
	LD	DE,OFCB_BUF
	LD	BC,256
	LDIR
	PUSH	HL
	POP	BC
	POP	HL
	PUSH	BC		;BC=next addr in buffer.
	LD	DE,OFCB		;Write a full sector.
	CALL	DOS_WRIT_SECT
	JP	NZ,WRTREC_2
	POP	DE		;Next addr.
	POP	BC		; Restore count
	DJNZ	WRTB3		; Loop for all (full) pages in buffer
WRTB4:	OR	C		; Any bytes left?
	RET	Z		; No, return
; Write record to disk
;*******************************
	EX	DE,HL
	LD	B,C
	LD	DE,OFCB
WRTREC_1
	LD	A,(HL)
	CALL	ROM@PUT
	JR	NZ,WRTREC_2
	INC	HL
	DJNZ	WRTREC_1
;*******************************
	EX	DE,HL		;Swap addresses back again
	RET
;
WRTREC_2
	CP	1BH		;Disk space full
	JP	NZ,F_ERROR
	LD	DE,DSKFUL	; Disk is full, report error
	CALL	PRINTX
	LD	DE,ABOMSG
	CALL	PRINTL
	CALL	ICLOSE
	LD	DE,OFCB
	CALL	DOS_KILL
	LD	A,4
	JP	_ERROR
;
; Typeout buffer
; Note:	The file typeout facility was originally added to this program
;	as an afterthought, and it is admittedly primitive.  This is an
;	obvious area for future improvements (e.g., a la the public
;	domain TYPEL program which is widely used on RCPM's).
TYPBUF:	LD	A,(DE)		; Fetch next byte from buffer
	CP	CTLZ		; Is it CPM end-of-file?
	JP	Z,EXIT		; Yes, exit program early
	PUSH	BC		; Save remaining byte count
	INC	A		; Bump ASCII code (simplifies DEL test)
	AND	7FH		; Mask to 7 bits
	CP	' '+1		; Is it a printable char?
	DEC	A		; (Restore code)
	JR	C,TYPB3		; Skip if non-printable
TYPB1:	CALL	PCHAR		; Type char
TYPB2:	INC	DE		; Bump ptr to next byte
	POP	BC		; Restore byte count
	DEC	BC		; Reduce count
	LD	A,B		; Done all bytes?
	OR	C
	JR	NZ,TYPBUF	; No, loop for next
	RET			; Yes, return to caller
TYPB3:	CP	HT		; Is (non-printing) char a tab?
	JR	Z,TYPB1		; Yes, go type it
	JR	C,TYPB2		; But ignore if low control char
	CP	CR		; Does char generate a new line?
	JR	NC,TYPB2	; No, ignore control char (incl. CR)
	CALL	CRLF		; Yes (LF,VT,FF), start a new line
	PUSH	DE		; Save buffer ptr
	CALL	CABORT		; Good place to check for CTRL-C abort
	POP	DE		; Restore ptr
	LD	HL,LINCT	; Point to line count
	INC	(HL)		; Bump for one more line
	JR	Z,TYPB2		; But skip if 256 (must be no limit)
	LD	A,(TYLIM)	; Get max allowed lines
	CP	(HL)		; Reached limit (e.g. for RCPM)?
	JR	NZ,TYPB2	; No, go back to typeout loop
	CALL	WHLCK		; But is wheel byte set?
	JR	Z,TYPB2		; Yes, do not enforce limit
	LD	DE,TYPERR	; Else, report too many lines
	JP	PABORT		;  and abort
;
;
	SUBTTL	Listing Routines
; List file information
LIST:	LD	HL,(TFILES)	; Get total files so far
	LD	A,H		; Test if this is first file
	OR	L
	INC	HL		; Add one more
	LD	(TFILES),HL	; Update total files
	LD	DE,TITLES	; If first file,
	CALL	Z,PRINTX	;  print column titles
	LD	DE,SIZE		; Point to compressed file size
	PUSH	DE		; Save for later
	LD	HL,TSIZE	; Update total compressed size
	CALL	LADD
	LD	DE,LEN		; Point to uncompressed length
	PUSH	DE		; Save for later
	LD	HL,TLEN		; Update total length
	CALL	LADD
	LD	HL,LINE		; Setup listing line pointer
	LD	DE,OFCB		; List file name from output FCB
	LD	C,0		; (with blank fill)
	CALL	LNAME
	POP	DE		; Recover file length ptr
	PUSH	DE		; Save again for factor calculation
	CALL	LTODA		; List file length
;;	CALL	LDISK		; Compute and list disk space
	CALL	LSTOW		; List stowage method and version
	POP	BC		; Restore uncompressed length ptr	
	POP	DE		; Restore compressed size ptr
	CALL	LSIZE		; List size and compression factor
	LD	A,(DATE)	; Check for valid file date
	OR	A		; (This anticipates no-date CPM files)
	JR	NZ,LIST1	; Skip if valid
;;	LD	B,19		; Else, clear out date and time fields
;;	CALL	FILLB
	JR	LIST2		; Skip
LIST1:	CALL	LDATE		; List file date
;;	CALL	LTIME		; List file time
LIST2:	;;CALL	LCRC		; List CRC value
	PAGE
; Terminate and print listing line
LISTL:	LD	DE,LINE		; Setup listing line ptr
	JR	LIST3		; Go finish up and list it
; List file totals
LISTT:	LD	HL,LINE		; Setup listing line ptr
	LD	DE,(TFILES)	; List total files
	CALL	WTODA
	LD	DE,TLEN		; List total file length
	PUSH	DE		;  and save ptr for factor calculation
	CALL	LTODA
;;	LD	DE,(TDISK)	; List total disk space
;;	CALL	LDISK1
	LD	B,13		; Fill next columns with blanks
	CALL	FILLB	
	POP	BC		; Recover total uncompressed length ptr
	LD	DE,TSIZE	; Get total compressed size ptr
	CALL	LSIZE		; List overall size, compression factor
	LD	DE,TOTALS	; Point to totals string (precedes line)
LIST3:	LD	(HL),0		; Terminate listing line
; Print string, then start new line
PRINTL:	CALL	PRINTS
	CALL	CRLF
	RET
;
; Start new line
; Note:	Must preserve DE
CRLF:	LD	A,CR
	CALL	PCHAR
	RET
;
; Print character
PCHAR:	PUSH	DE		; Save register
	CALL	33H
	POP	DE		; Restore register
	RET			; Return
;
; Print string on new line, then start another
;
PRINTX:	CALL	CRLF
	CALL	PRINTS
	CALL	CRLF
	RET
;
; Print string on new line
PRINT:	CALL	CRLF
	CALL	PRINTS
	RET
;
; Print NUL-terminated string
PRINTS:	LD	A,(DE)
	OR	A
	RET	Z
	PUSH	DE
	CALL	33H
	POP	DE
	INC	DE
	JR	PRINTS
;
; Output warning message about extracted file
OWARN:	PUSH	DE
	LD	DE,WARN
	CALL	PRINTS
	POP	DE
	CALL	PRINTS
	CALL	CRLF
	LD	A,1
	LD	(WARNFLAG),A
	RET
;
; List file name
; Note:	We use name in output file FCB, rather than original name in
;	archive header (illegal chars already filtered by GETNAM).
LNAME:	LD	B,12		; Setup count for name.
LNAME1:	LD	A,(DE)		;If end of name
	CP	3		;ETX delimiter
	LD	A,' '
	JR	Z,LNAME2	; Yes, go fill rest
	LD	A,(DE)		; Get next char
	INC	DE
LNAME2:	LD	(HL),A		; Store char
	INC	HL
LNAME3:	DJNZ	LNAME1		; Loop for all chars in name and type
	RET			; Return to caller
;
	PAGE
; Compute and list disk space for uncompressed file
LDISK:	PUSH	HL		; Save line ptr
	LD	HL,(LEN)	; Convert file length to 1k disk space
	LD	A,(LEN+2)	; (Most we can handle here is 16 Mb)
	LD	DE,1023		; First, round up to next 1k
	ADD	HL,DE
	ADC	A,0
	RRA			; Now, shift to divide by 1k	
	RR	H
	RRA
	RR	H
	AND	3FH
	LD	L,H		; Result -> HL
	LD	H,A
;;	LD	A,(LBLKSZ)	; Get disk block size
	LD	A,1		;1k block size? Its 1.25k!
	DEC	A		; Round up result accordingly
	LD	E,A
	LD	D,0
	ADD	HL,DE
	CPL			; Form mask for lower bits
	AND	L
	LD	E,A		; Final result -> DE
	LD	D,H
	LD	HL,(TDISK)	; Update total disk space used
	ADD	HL,DE
	LD	(TDISK),HL
	POP	HL		; Restore line ptr
LDISK1:	CALL	WTODA		; List result
	LD	(HL),'k'
	INC	HL
	RET
	PAGE
;
; List stowage method and version
LSTOW:	CALL	FILL2B		; Blanks first
	EX	DE,HL
	LD	HL,STOWTX	; Point to stowage text table
	LD	A,(VER)		; Get header version no.
	PUSH	AF		; Save for next column
	LD	BC,8		; Use to get correct text ptr
	CP	3
	JR	C,LSTOW1
	ADD	HL,BC
	JR	Z,LSTOW1
	ADD	HL,BC
	CP	4
	JR	Z,LSTOW1
	ADD	HL,BC
	CP	9
	JR	C,LSTOW1
	ADD	HL,BC
LSTOW1:	LDIR			; List stowage text
	EX	DE,HL		; Restore line ptr
	POP	AF		; Recover version no.
	LD	B,3
	JP	BTODB		; List and return
	PAGE
; List compressed file size and compression factor
LSIZE:	PUSH	DE		; Save compressed size ptr
	PUSH	BC		; Save uncompressed length ptr
	CALL	LTODA		; List compressed size
	POP	DE		; Recover length ptr
	EX	(SP),HL		; Save line ptr, recover size ptr
; Compute compression factor = 100 - [100*size/length]
; (HL = ptr to size, DE = ptr to length, A = result)
	PUSH	DE		; Save length ptr
	CALL	LGET		; Get BCDE = size
	LD	H,B		; Compute 100*size
	LD	L,C		;  in HLIX:
	PUSH	DE
	POP	IX		;     size
	ADD	IX,IX
	ADC	HL,HL		;   2*size
	ADD	IX,DE
	ADC	HL,BC		;   3*size
	ADD	IX,IX
	ADC	HL,HL		;   6*size
	ADD	IX,IX
	ADC	HL,HL		;  12*size
	ADD	IX,IX
	ADC	HL,HL		;  24*size
	ADD	IX,DE
	ADC	HL,BC		;  25*size
	ADD	IX,IX
	ADC	HL,HL		;  50*size
	ADD	IX,IX
	ADC	HL,HL		; 100*size
	EX	(SP),HL		; Swap back length ptr, save upper
	CALL	LGET		; Get BCDE = length
	PUSH	IX
	POP	HL		; Now have (SP),HL = 100*size
	LD	A,B		; Length = 0?
	OR	C		; (Unlikely, but possible)
	OR	D
	OR	E
	JR	Z,LSIZE2	; Yes, go return result = 0
	LD	A,101		; Initialize down counter for result
LSIZE1:	DEC	A		; Divide by successive subtractions
	SBC	HL,DE
	EX	(SP),HL
	SBC	HL,BC
	EX	(SP),HL
	JR	NC,LSIZE1	; Loop until remainder < length
LSIZE2:	POP	HL		; Clean stack
	POP	HL		; Restore line ptr
	CALL	BTODA		; List the factor
	LD	(HL),'%'
	INC	HL
	RET			; Return
	PAGE
; List file creation date
; ARC files use MS-DOS 16-bit date format:
;
; Bits [15:9] = year - 1980
; Bits  [8:5] = month of year
; Bits  [4:0] = day of month
;
; (All zero means no date, checked before call to this routine)
LDATE:	LD	A,(DATE)	; Get date
	AND	1FH		; List day
	CALL	BTODA
	LD	(HL),'-'	; Then a separator
	INC	HL
	EX	DE,HL		; Save listing line ptr
	LD	HL,(DATE)	; Get date again
	PUSH	HL		; Save for listing year (in upper byte)
	ADD	HL,HL		; Shift month into upper byte
	ADD	HL,HL
	ADD	HL,HL
	LD	A,H		; Get month
	AND	0FH
	CP	13		; Make sure it's valid
	JR	C,LDATE1
	XOR	A		; (Else will show as "???")
LDATE1:	LD	C,A		; Use to index to 3-byte string table
	LD	B,0
	LD	HL,MONTX
	ADD	HL,BC
	ADD	HL,BC
	ADD	HL,BC
	LD	C,3
	LDIR			; Move month text into listing line
	EX	DE,HL		; Restore line ptr
	LD	(HL),'-'	; Then a separator
	INC	HL
	POP	AF		; Recover high byte of date
	SRL	A		; Get 1980-relative year
	ADD	A,80		; Get true year in century
LDATE2:	LD	BC,256*2+'0'	; Setup for 2 digits with high-zero fill
	JR	BTOD		;  and convert binary to decimal ASCII
	PAGE
; List file creation time
; ARC files use MS-DOS 16-bit time format:
;
; Bits [15:11] = hour
; Bits [10:5]  = minute
; Bits  [4:0]  = second/2 (not shown here)
LTIME:	EX	DE,HL		; Save listing line ptr
	LD	HL,(TIME)	; Fetch time
	LD	A,H		; Copy high byte
	RRA			; Get hour
	RRA
	RRA
	AND	1FH
	LD	B,' '		; Assume 24 hour format!
;;	JR	Z,LTIME1	; Skip if 0 (12 midnight)
;;	CP	12		; Is it 1-11 am?
;;	JR	C,LTIME2	; Yes, skip
;;	LD	B,' '		; Else, it's pm
;;	SUB	12		; Convert to 12-hour clock
;;	JR	NZ,LTIME2	; Skip if not 12 noon
;;LTIME1:	LD	A,12		; Convert 0 to 12
LTIME2:	PUSH	BC		; Save am/pm indicator
	ADD	HL,HL		; Shift minutes up to high byte
	ADD	HL,HL
	ADD	HL,HL
	PUSH	HL		; Save minutes
	EX	DE,HL		; Recover listing line ptr
	CALL	BTODA		; List hour
	LD	(HL),':'	; Then ":"
	INC	HL
	POP	AF		; Restore and list minutes
	AND	3FH
	CALL	LDATE2
	POP	AF		; Restore and list am/pm letter
	LD	(HL),A
	INC	HL
	RET			; Return
;
	PAGE
; List hex CRC value
LCRC:	CALL	FILL2B
	LD	DE,(CRC)
	CALL	DHEX
	LD	D,E
; List hex byte in D
DHEX:	LD	(HL),D
	RLD
	CALL	AHEX
	LD	A,D
; List hex nibble in A
AHEX:	OR	0F0H
	DAA
	CP	60H
	SBC	A,1FH
	LD	(HL),A
	INC	HL
	RET
;
