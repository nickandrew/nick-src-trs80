;Fileh - Last updated 14-Jan-88
;
; (circular) entries past that of the last duplicate.
	EX	(SP),HL		; Save collision ptr, swap its index
	LD	E,101		; Move 101 entries past it
	ADD	HL,DE
HASH2:	RES	4,H		; Mask table index to 12 bits
	PUSH	HL		; Save index
	CALL	STRPTR		; Point to string table entry
	POP	DE		; Restore its index
	LD	A,(HL)		; Fetch byte from entry
	OR	A		; Is it empty?
	JR	Z,HASH3		; Yes, found a spot in table
	EX	DE,HL		; Else,
	INC	HL		; Bump index to next entry
	JR	HASH2		; Loop until we find one free
; We now have the index (DE) and pointer (HL) for an available entry
; in the string table.  We just need to add the index to the chain of
; duplicates for this hash key, and then return the pointer to caller.
HASH3:	EX	(SP),HL		; Swap ptr to last duplicate key entry
	LD	(HL),D		; Add this index to duplicate chain
	DEC	HL
	LD	(HL),E
	POP	HL		; Recover string table ptr
	RET			; Return it to caller
	PAGE
; Get fixed-length code from (old-style) crunched file
; These codes are packed in left-to-right order (msb first).  Two codes
; fit in three bytes, so we alternate processing every other call based
; on a rotating flag word in BITS (initialized to 55H).  Location BITSAV
; holds the middle byte between calls (coding assumes BITSAV = BITS-1).
OGETCR:	CALL	GETCX		; Get next input byte
	EXX			; Save output regs
	RET	C		; Return (carry set) if end of file
	LD	E,A		; Copy byte (high or low part of code)
	LD	HL,BITS		; Point to rotating bit pattern
	RRC	(HL)		; Rotate it
	JR	C,OGETC1	; Skip if this is high part of code
	DEC	HL		; Point to saved byte from last call
	LD	A,(HL)		; Fetch saved byte
	AND	0FH		; Mask low nibble (high 4 bits of code)
	EX	DE,HL		; Get new byte in L (low 8 bits of code)
	LD	H,A		; Form 12-bit code in HL
	RET			; Return (carry clear from mask)
OGETC1:	PUSH	DE		; Save byte just read (high 8 code bits)
	CALL	GETCX		; Get next byte
	EXX			; Save output regs
	POP	HL		; Restore previous byte in L
	RET	C		; But return if eof
	LD	(BITSAV),A	; Save new byte for next call
	AND	0F0H		; Mask high nibble (low 4 bits of code)
	RLA			; Rotate once through carry
	LD	H,A		; Set for circular rotate of HL & carry
	ADC	HL,HL		;;Form the 12-bit code
	ADC	HL,HL
	ADC	HL,HL
	ADC	HL,HL
	RET			; Return (carry clear after last rotate)
; Output next byte decoded from crunched file
;
PUTCR:	EXX			; Swap in output registers
	JP	0		; Vector to the appropriate routine
PUTCRP	EQU	$-2		; (ptr to PUT or PUTUP stored here)
	PAGE
; Low-level output routines
; Register usage (once things get going):
;
;  B  = Flag for repeated byte expansion (1 = repeat count expected)
;  C  = Last byte output (saved for repeat expansion)
;  DE = Output buffer pointer
;  HL = CRC value
; Setup registers for output (preserves AF)
PUTSET:	LD	HL,(BUFPAG-1)	; Get buffer start address
	LD	L,0		; (It's always page aligned)
	EX	DE,HL
	LD	H,E		; Clear the CRC
	LD	L,E
	LD	B,E		; Clear repeat flag
	RET			; Return
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
	PAGE
; Unpack and output packed byte
PUTUP:	DJNZ	PUTUP4		; Expecting a repeat count?
	LD	B,A		; Yes ("byte REP count"), save count
	OR	A		; But is it zero?
	JR	NZ,PUTUP2	; No, enter expand loop (did one before)
	LD	A,REP		; Else ("REP 0"),
	JR	PUT		; Go output REP code as data
PUTUP1:	LD	A,C		; Get repeated byte
	CALL	PUT		; Output it
PUTUP2:	DJNZ	PUTUP1		; Loop until repeat count exhausted
	RET			; Return when done
PUTUP3:	INC	B		; Set flag for repeat count next
	RET			; Return (must wait for next call)
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
	POP	BC
PUTB2:	POP	HL
	RET			; Return to caller
;
; Write buffer to disk
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
	CALL	$PUT
	JR	NZ,WRTREC_2
	INC	HL
	DJNZ	WRTREC_1
;*******************************
	EX	DE,HL		;Swap addresses back again
	RET
WRTREC_2
	LD	DE,DSKFUL	; Disk is full, report error
	JP	PABORT		;  and abort
	PAGE
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
	PAGE
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
	LD	DE,OFCB	; List file name from output FCB
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
