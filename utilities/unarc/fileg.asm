;Fileg - Last updated 14-Jan-88
;
;	added to the table sequentially with the newer crunch method.
;	This routine's main responsibility is to update the bit-length
;	for expected input codes, and to bypass the table entry for
;	code 256 (reserved for adaptive reset), at appropriate times.
NHASH:	LD	A,L		; Copy low byte of string count in HL
	DEC	L		; Get table offset for new entry
	OR	A		; But is count a multiple of 256?
	JR	NZ,STRPTR	; No, just return the table pointer
	LD	A,H		; Copy high byte of count
	DEC	H		; Complete double-register decrement
	LD	DE,STRCT	; Set to bump string count (bypasses
	JR	Z,NHASH1	;  next entry) if exactly 256
	CP	4096/16/16	;Else, is count the full 4k?
	JR	Z,STRPTR	; Yes (last table entry), skip
; Note the following cute test.  (It's mentioned in K & R, ex. 2-9.)
	AND	H		; Is count a power-of-two?
	JR	NZ,STRPTR	; No, skip
	LD	DE,BITS		; Yes, next input code is one bit longer
; Note:	By definition, there can be no input code residue at this point.
;	I.e. (BITSAV) = 0, since we have read a power-of-two (> 256) no.
;	of codes at the old length (total no. of bits divisible by 8).
;	By the same argument, (CODES) = 0 modulo 8 (see NGETCR).
NHASH1:	EX	DE,HL		; Swap in address value to increment
	INC	(HL)		; Bump the value (STRCT or BITS)
	EX	DE,HL		; Recover table offset
; Get pointer to string table entry
; This routine is input a 12-bit code in HL (or -1 for the null string).
; It returns a pointer in HL to the middle byte of the string table
; entry for that code (STRT-2 for the null string).  Destroys DE only.
STRPTR:	LD	D,H		; Copy code
	LD	E,L
	ADD	HL,HL		; Get 2 * code
	ADD	HL,DE		; Get 3 * code
	LD	DE,STRT+1	; Point to table base entry (2nd byte)
	ADD	HL,DE		; Compute pointer
	RET			; Return
	PAGE
; Get variable-length code from (new-style) crunched file
;These codes are packed in right-to-left order (lsb first).  The code 
;length (stored in BITS) begins at 9 bits and increases up to a maximum 
;of 12 bits as the string table grows (maintained by NHASH).  Location 
;BITSAV holds the residue bits remaining in the last input byte after 
;each call (must be initialized to 0, code assumes BITSAV = BITS-1).
;In comparison, the MS-DOS ARC program buffers 8 codes at a time (i.e.  
;n bytes, where n = bits/code) and flushes this buffer whenever the code 
;length changes (so that first code at new length begins on an even byte 
;boundary).  By coincidence (see NHASH) this buffer is always empty when 
;the code length increases as a result of normal string table growth.  
;Thus the only time this added bufferring affects us is when the code 
;length is reset from 12 to 9 bits upon receipt of the special clear 
;request (code 256), at which time we must possibly bypass up to 10 
;input bytes.  This is handled by a simple down-counter in location 
;CODES, whose mod-8 value indicates the no. of codes (1.5 bytes/code) 
;which should be skipped (must be initialized to 0, code assumes that 
;CODES = BITSAV-1).
;\
; Note:	This can probably be made a lot faster (e.g. by unfolding into
;	8 separate cases and using a co-routine return), but that's a
;	lot of work.  For now, we KISS ("keep it short and simple").
NGETCR:	LD	HL,CODES	; First update code counter
	DEC	(HL)		;  for clear code processing
	INC	HL		; Point to BITSAV
	LD	A,(HL)		; Get saved residue bits
	INC	HL		; Point to BITS
	LD	B,(HL)		; Setup bit counter for new code
	LD	HL,7FFFH	; Init code (msb reset for end detect)
; Top of loop for next input bit
NGETC1:	SRL	A		; Shift out next input bit
	JR	Z,NGETC6	; But skip out if new byte needed
NGETC2:	RR	H		; Shift bit into high end of code word
	RR	L		;  (double-register shift)
	DJNZ	NGETC1		; Loop until have all bits needed
; Input complete, cleanup code word
NGETC3:	SRL	H		; Shift code down,
	RR	L		;  to right-justify it in HL
	JR	C,NGETC3	; Loop until end flag shifted out
	LD	(BITSAV),A	; Save input residue for next call
	LD	A,H		; But is it code 256?
	DEC	A		; (i.e. adaptive reset request)
	OR	L
	RET	NZ		; No, return (carry clear)
; Special handling to reset string table upon receipt of clear code
	LD	HL,BITS		; Point to BITS
	LD	(HL),9		; Go back to 9-bit codes
	DEC	HL		; Point to BITSAV
	LD	(HL),A		; Empty the residue buffer
	DEC	HL		; Point to CODES
	LD	A,(HL)		; Get code counter
	AND	7		; Modulo 8 is no. codes to flush
	JR	Z,NGETC5	; Skip if none
; Note:	It's a shame we have to do this at all.  With a minor change in
;	its implementation, the MS-DOS ARC program could have simply
;	shuffled down its buffer and avoided wasting up to 10 bytes in
;	the crunched file (not to mention a lot of unnecessary effort).
	LD	(HL),0		; Reset code counter to 0 for next time
	LD	B,A		; Get 1.5 times the no. of 12-bit codes
	RRA			;  to obtain no. input bytes to bypass
	ADD	A,B
	LD	B,A
NGETC4:	PUSH	BC		; Loop to flush the (encoder's) buffer
	CALL	GETCX
	EXX			; (No need to test for end-of-file
	POP	BC		;  here, we'll pick it up later if
	DJNZ	NGETC4		;  it happens)
;NGETC5:	LD	HL,STRT+(3*256)	; Clear out (all but one-byte) strings
NGETC5:
	LD	HL,STRT+768	;Clear out all but ...
	LD	BC,STRSZ-769	;strsz-(3*256)-1
	CALL	STRTCL
	LD	HL,257		; Reset count for just one-byte strings
	LD	(STRCT),HL	;  plus the unused entry
; Kludge:  We rely here on the fact that the previous input code is at
;	top of caller's stack, where -1 indicates none.  This should
;	properly be done by the caller, but doing it here preserves
;	commonality of coding for old-style crunched files (i.e. caller
;	never knows this happened).
	POP	HL		; Get return address
	EX	(SP),HL		; Exchange with top of (caller's) stack
	LD	HL,-1		; Set no previous code
	EX	(SP),HL		; Replace on stack
	PUSH	HL		; Restore return
	JR	NGETCR		; Go again for next input code
; Read next input byte
NGETC6:	PUSH	BC		; Save bit count
	PUSH	HL		; Save partial code
	CALL	GETCX		; Get next input byte
	EXX			; Save output regs
	POP	HL		; Restore code
	POP	BC		; Restore count
	RET	C		; But stop if reached end of file
; Special test to speed things up a bit...
; (If need the whole byte, might as well save some bit fiddling)
	BIT	3,B		; At least 8 more bits needed?
	JR	NZ,NGETC7	; Yes, go do it faster
	SCF			; Else, set flag for end-of-byte detect
	RRA			; Shift out first bit of new byte
	JR	NGETC2		; Go back to bit-shifting loop
; Update code by (entire) new byte
NGETC7:	LD	L,H		; Shift code down 8 bits
	LD	H,A		; Insert new byte into code
	LD	A,B		; Get bit count
	SUB	8		; Reduce by 8
	LD	B,A		; Update remaining count
	JR	NZ,NGETC6	; Get another byte if still more needed
	JR	NGETC3		; Else, go exit early (note A=0)
	PAGE
; Hash functions for (old-style) crunched files
; This stuff exists for the sole purpose of processing files which were
; created by older releases of MS-DOS ARC (pre-version 5.0).  To quote
; that program's author:  "Please note how much trouble it can be to
; maintain upwards compatibility."  Amen!
; Note:	The multiplications required by the two hash function versions
;	are sufficiently specialized that we've hand-coded each of them
;	separately, for speed, rather than use a common multiply
;	subroutine.
; Versions 5 and 6...
; Compute hash key = upper 12 of lower 18 bits of unsigned square of:
;	(prefix code + suffix byte) OR 800H
; Note:	I'm sure there's a faster way to do this, but I didn't want to
;	exert myself unduly for an obsolete crunching method.
OHASH:	LD	DE,0		; Clear product
	LD	L,A		; Extend suffix byte
	LD	H,D		;  to 16 bits
	ADD	HL,BC		; Sum with prefix code
	SET	3,H		; Or in 800H
; We now have a 13-bit number which is to be squared, but we are only
; interested in the lower 18 bits of the 26-bit product.  The following
; reduces this to a 12-bit multiply which yields the correct product
; shifted right 2 bits.  This is acceptable (we discard the low 6 bits
; anyway) and allows us to compute desired result in a 16-bit register.
; For the algebraically inclined...
;   If n is even (n = 2m + 0):  n * n = 4(m * m)
;   If n is odd  (n = 2m + 1):  n * n = 4(m * (m+1)) + 1
	SRA	H		; Divide number by 2 (i.e. "m")
	RR	L		; HL will be multiplicand (m or m+1)
	LD	C,H		; Copy to multiplier in C (high byte)
	LD	A,L		;  and A (low byte)
	ADC	HL,DE		; If was odd, add 1 to multiplicand
; Note there is one anomalous case:  The first one-byte string (with
; prefix = -1 = 0FFFFH and suffix = 0) generates the 16-bit sum 0FFFFH,
; which should hash to 800H (not 0).  The following test handles this.
	JR	C,OHASH3	; Skip if special case (will get 800H)
	LD	B,12		; Setup count for 12 bits in multiplier
; Top of multiply loop (vanilla shift-and-add)
OHASH1:	SRL	C		; Shift out next multiplier bit
	RRA
	JR	NC,OHASH2	; Skip if 0
	EX	DE,HL		; Else, swap in product
	ADD	HL,DE		; Add multiplicand (carries ignored)
	EX	DE,HL		; Reswap
OHASH2:	ADD	HL,HL		; Shift multiplicand
	DJNZ	OHASH1		; Loop until done all multiplier bits
; Now have the desired hash key in upper 12 bits of the 16-bit product
	EX	DE,HL		; Obtain product in HL
	ADD	HL,HL		; Shift high bit into carry
OHASH3:	RLA			; Shift up 4 bits into A...
	ADD	HL,HL
	RLA
	ADD	HL,HL
	RLA
	ADD	HL,HL
	RLA
	LD	L,H		; Move down low 8 bits of final result
	JR	HASH		; Join common code to mask high 4 bits
; Version 7 (faster)...
; Compute hash key = lower 12 bits of unsigned product:
;	(prefix code + suffix byte) * 15073
FHASH:	LD	L,A		; Extend suffix byte
	LD	H,0		;  to 16 bits
	ADD	HL,BC		; Sum with prefix code
; Note:	15073 = 2785 mod 4096, so we need only multiply by 2785.
	LD	D,H		; Copy sum, and compute in HL:
	LD	E,L		;    1 * sum
	ADD	HL,HL		;    2 * sum
	ADD	HL,HL		;    4 * sum
	ADD	HL,DE		;    5 * sum
	ADD	HL,HL		;   10 * sum
	ADD	HL,HL		;   20 * sum
	ADD	HL,DE		;   21 * sum
	ADD	HL,HL		;   42 * sum
	ADD	HL,DE		;   43 * sum
	ADD	HL,HL		;   86 * sum
	ADD	HL,DE		;   87 * sum
	ADD	HL,HL		;  174 * sum
	ADD	HL,HL		;  348 * sum
	ADD	HL,HL		;  696 * sum
	ADD	HL,HL		; 1392 * sum
	ADD	HL,HL		; 2784 * sum
	ADD	HL,DE		; 2785 * sum
	LD	A,H		; Setup high byte of result
; Common code for old-style hashing
HASH:	AND	0FH		; Mask hash key to 12 bits
	LD	H,A
	PUSH	HL		; Save key as trial string table index
	CALL	STRPTR		; Point to string table entry
	POP	DE		; Restore its index
	LD	A,(HL)		; Is table entry used?
	OR	A
	RET	Z		; No (that was easy), return table ptr
; Hash collision occurred.  Trace down list of entries with duplicate
; keys (in auxilliary table HSHT) until the last duplicate is found.
	LD	BC,HSHT		; Setup collision table base
	PUSH	HL		; Create dummy stack level
HASH1:	POP	HL		; Discard last index
	EX	DE,HL		; Get next trial index
	PUSH	HL		; Save it
	ADD	HL,HL		; Get ptr to collision table entry
	ADD	HL,BC
	LD	E,(HL)		; Fetch entry
	INC	HL
	LD	D,(HL)
	LD	A,D		; Is it zero?
	OR	E
	JR	NZ,HASH1	; No, loop for next in chain
; We now have the index (top of stack) and pointer (HL) for the last
; entry in the duplicate key list.  In order to find an empty spot for
; the new string, we search the string table sequentially starting 101
