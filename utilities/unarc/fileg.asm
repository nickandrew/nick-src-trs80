;Fileg - Last updated 14-Jan-88
;
	PAGE
; Uncrunch (LZW-coded) file
;
;The Lempel-Ziv-Welch (so-called "LZW") data compression algorithm is 
;the most impressive benefit of ARC files.  It performs better than
;Huffman coding in many cases, often achieving 50% or better compression 
;of ASCII text files and 15%-40% compression of binary object files.  
;The algorithm is named after its inventors:  A. Lempel and J. Ziv 
;provided the original theoretical groundwork, while Terry A. Welch 
;published an elegant practical implementation of their procedure.  (The 
;definitive article is Welch's "A Technique for High-Performance Data 
;Compression", which appeared in the June 1984 issue of IEEE Computer 
;magazine.)
;The Huffman algorithm encoded each input byte by a variable-length bit 
;string (up to 16 bits in Greenlaw's implementation), with bit length 
;(approximately) inversely proportional to the frequency of occurrence 
;of the encoded byte.  This has the disadvantages of requiring (1) two 
;passes over the input file for encoding and (2) the inclusion of the 
;decoding information along with the output file (a binary tree of up to 
;1026 bytes in Greenlaw's implementation).  In comparison, LZW is a one- 
;pass procedure which encodes variable-length strings of bytes by a 
;fixed-length code (12 bits in this implementation), without additional 
;overhead in the output file.  In essence, the procedure adapts itself 
;dynamically to the redundancy present in the input data.  There is one 
;drawback:  LZW requires substantially more memory than the Huffman 
;algorithm for both encoding and decoding.  (A 12K-byte string table is 
;required in this program; the MS-DOS ARC program uses even more.  Of 
;course, 12K is not that much these days:  I don't think they're even 
;selling IBM-PC's or MAC's with less than 512K anymore.  But some of us 
;in the CP/M world are still concerned with efficiency of memory 
;utilization.)
;The MS-DOS ARC program by System Enhancement Associates has (to date) 
;employed four different variations on the LZW scheme, differentiated by 
;the version byte in the archive file header:
;     Version 5:  LZW applied to original input file
;     Version 6:  LZW applied to file after packing repeated bytes
;     Version 7:  Same as version 6 with a new (faster) hash code
;     Version 8:  Completely new (much improved) implementation
;Version 8 varies the output code width from 9 to 12 bits as the string 
;table grows (benefits small files), performs an adaptive reset of the 
;string table after it becomes full if the compression ratio drops 
;(benefits large files), and eliminates the need for hash computations 
;by the decoder (reduces decoding time and space; in this program, an 
;extra 8K-byte table is eliminated).  Although the latest release of the 
;ARC program uses only this last version for encoding, we (like ARC) 
;support all four versions for compatibility with files encoded by 
;earlier releases.
;
; Setup for uncrunching
; We've been able to isolate all of the differences between the four
; versions of LZW into just three routines -- input, output, and hash
; function.  These are disposed of first, by inserting appropriate
; vectors into common coding and initializing version-dependent data.
UCR:	CP	8		; Version 8?
	JR	Z,UCR2		; Yes, skip
	LD	DE,OGETCR	; Old versions get fixed 12-bit codes
	LD	BC,STRSZ+HSHSZ-1;  and need extra table for hashing
	LD	HL,OHASH	; Assume old hash function
	CP	6		; Test version
	LD	A,55H		; Setup initial flags for OGETCR
	JR	Z,UCR3		; All set if version 6
	JR	C,UCR1		; Skip if version 5
	LD	HL,FHASH	; Version 7 uses faster hash function
	JR	UCR3
UCR1:	LD	IX,PUT		; Version 5 has no repeated byte unpack
	JR	UCR4
; Note:	This is the only place that we reference the code size for
;	crunched files (CRBITS) symbolically.  Currently, a value of
;	12 bits is required and it is assumed throughout the program.
UCR2:	CALL	GETC		; Read code size used to crunch file
	XOR	CRBITS		; Same as what we expect?
	LD	DE,UCRERR	; No, report incompatible format
	JP	NZ,PABORT	;  and abort
	LD	H,A		; Clear code residue and count to
	LD	L,A		;  initialize NGETCR input
	LD	(CODES),HL	;  (BITSAV and CODES)
	LD	DE,NGETCR	; New version has variable-length codes,
	LD	BC,STRSZ-1	;  provides more buffer space,
	LD	HL,NHASH	;  and has a very simple "hash"
	LD	A,9		; Setup initial code size for NGETCR
UCR3:	LD	IX,PUTUP	; Versions 6-8 unpack repeated bytes
UCR4:	LD	(PUTCRP),IX	; Save ptr to output routine
	LD	(HASHP),HL	; Save ptr to hash function
	LD	(GETCRP),DE	; Save ptr to input routine
	LD	(BITS),A	; Initialize input routine
	PAGE
; Start uncrunching
; (All version-dependent differences are handled now)
	CALL	TREECL		; Clear string (and hash) table(s)
	LD	(STRCT),BC	; Set no entries in string table
	DEC	BC		; Get code for no prefix string (-1)
	PUSH	BC		; Save as first-time flag
	XOR	A		; Init table with one-byte strings...
GCR0:	POP	BC		; Set for no prefix string
	PUSH	BC		; (Resave first-time flag)
	PUSH	AF		; Save byte value
	CALL	STRADD		; Add to table
	POP	AF		; Recover byte
	INC	A		; Done all 256 bytes?
	JR	NZ,GCR0		; No, loop for next
	CALL	PUTSET		; Setup output registers
; Top of loop for next input code (top of stack holds previous code)
GCR:	EXX			; Save output regs first
GETCR:	CALL	0		; Get next input code
GETCRP	EQU	$-2		; (ptr to NGETCR or OGETCR stored here)
	POP	BC		; Recover previous input code (or -1)
	JR	C,UCREND	; But all done if end of input
	PUSH	HL		; Save new code for next loop
	CALL	STRPTR		; Point to string table entry for code
	INC	B		; Is this the first one in file?
	JR	NZ,GCR2		; No, skip
	INC	HL		; Yes,
	LD	A,(HL)		; Get first output byte
GCR1:	CALL	PUTCR		; Output final byte for this code
	JR	GCR		; Loop for next input code
GCR2:	DEC	B		; Correct prev code (stays in BC awhile)
	LD	A,(HL)		; Is new code in table?
	OR	A
	PUSH	AF		; (Save test result for later)
	JR	NZ,GCR3		; Yes, skip
	LD	H,B		; Else (special case), setup previous
	LD	L,C		;  code (it prefixes the new one)
	CALL	STRPTR		; Point to its table entry instead
	PAGE
; At this point, we have the table ptr for the new output string (except
; possibly its final byte, which is a special case to be handled later).
; Unfortunately, the table entries are linked in reverse order.  I.e.,
; we are pointing to the last byte to be output.  Therefore, we trace
; through the table to find the first byte of the string, reversing the
; link order as we go.  When done, we can output the string in forward
; order and restore the original link order.  (This is, we think, an
; innovative approach: it saves allocation of an extra 4K-byte stack,
; as in the MS-DOS ARC program, or an enormous program stack, as needed
; for the recursive algorithm of Steve Greenberg's UNCRunch program.)
; Careful:  The following value must be non-zero, so that the old-style
; hash (invoked by STRADD below) will not think a re-linked entry is
; unused!  (In a development version, we used zero; this worked fine for
; newer crunched files, but proved a difficult bug to squash when the
; old-style de-crunching failed randomly.)
GCR3:	LD	D,1		; Init previous entry ptr (01xxH = none)
GCR4:	LD	A,(HL)		; Test this entry
;;	CP	HIGH STRT	; Any prefix string?
	PUSH	BC		;Save needed register
	LD	BC,STRT		;B=high order value
	CP	B		;Any prefix string?
	POP	BC		;Restore again
	JR	C,GCR5		; No, we've reached the first byte
	LD	(HL),D		; Relink this entry
	LD	D,A		; (i.e. swap prev ptr with prefix ptr)
	DEC	HL
	LD	A,(HL)
	LD	(HL),E
	LD	E,A
	INC	HL
	EX	DE,HL		; Swap current ptr with prefix ptr
	JR	GCR4		; Loop for next entry
; HL points to table entry for first byte of output string.  We can now
; add the table entry for the string which the encoder placed in his
; table before sending us the current code.  (It's the previous code's
; string concatenated with the first byte of the new string).  Note that
; BC has been holding the previous code all this time.
GCR5:	INC	HL		; Point to byte
	POP	AF		; Recover special-case flag
	LD	A,(HL)		; Fetch byte
	PUSH	AF		; Re-save flag along with byte
	DEC	HL		; Restore table ptr
	PUSH	DE		; Save ptr to prev entry
	PUSH	HL		; Save ptr to this entry
	CALL	STRADD		; Add new code to table (for BC and A)
	POP	HL		; Setup table ptr for output loop
	PAGE
; Top of string output loop
; HL points to table entry for byte to output.
; Top of stack contains pointer to next table entry (or 01xxH).
GCR6:	INC	HL		; Point to byte
	LD	A,(HL)		; Fetch it
	PUSH	HL		; Save table ptr
	CALL	PUTCR		; Output the byte (finally!)
	EXX			; Save output regs
	POP	DE		; Recover ptr to this byte
	POP	HL		; Recover ptr to next byte's entry
	DEC	H		; Reached end of string?
	JR	Z,GCR7		; Yes, skip out of loop
	INC	H		; Correct next entry ptr from above test
	DEC	DE		; Restore ptr to this entry's mid byte
	LD	A,(HL)		; Relink the next entry
	LD	(HL),D		; (i.e. swap its "prefix" ptr with
	LD	D,A		;  ptr to this entry)
	DEC	HL
	LD	A,(HL)
	LD	(HL),E
	LD	E,A
	INC	HL
	PUSH	DE		; Save ptr to 2nd next entry
	JR	GCR6		; Loop to output next byte
; End of uncrunching loop
; All bytes of new string have been output, except possibly the final
; byte (which is the same as the first byte in this special case).
GCR7:	POP	AF		; Recover special-case flag and byte
	JR	NZ,GETCR	; If not set, loop for next input code
	JR	GCR1		; Else, go output final byte first
	PAGE
; Add entry to string table
; This routine receives a 12-bit prefix string code in BC and a suffix
; byte in A.  It then adds an entry to the string table (unless it's
; full) for the new string obtained by concatenating these.  Nothing
; is (or need be) returned to the caller.
;String table format:
;The table (STRT) contains 4096 three-byte entries, each of which is 
;identified by a 12-bit code (table index).  The third byte (highest 
;address) of each entry contains the suffix byte for the string.  The 
;first two bytes contain a pointer (low-byte first) to the middle byte 
;of the table entry for the prefix string.  The null string (prefix to 
;the one-byte strings) is represented by a (16-bit) code value -1, which 
;yields a non-zero pointer below the base address of the table.  An 
;empty table entry contains a zero prefix pointer.
;Our choice to represent prefix strings by pointers rather than codes 
;speeds up almost everything we do.  The high byte of the prefix pointer 
;(middle byte of an entry) may be tested for non-zero to determine if an
;entry is occupied, and (since the table is page-aligned) it may be 
;further tested against the page address of the table's base (HIGH STRT) 
;to decide if it represents the null string.
;Note that the entry for code 256 is not used in the newer version of 
;crunching.  This is reserved for a special signal to reset the string 
;table (handled by the hash and input routines, NHASH and NGETCR).
;\
STRADD:	LD	HL,(STRCT)	; Get count of strings in table
	BIT	4,H		; Is it the full 4K?
	RET	NZ		; Yes, forget it
	INC	HL		; Bump count for one more
	LD	(STRCT),HL	; Save new string count
	PUSH	AF		; Save suffix byte
	PUSH	BC		; Save prefix code
	CALL	0		; Hash them to get pointer to new entry
HASHP	EQU	$-2		; (ptr to xHASH routine stored here)
	EX	(SP),HL		; Save result, recover prefix code
	CALL	STRPTR		; Get pointer to prefix entry
	EX	DE,HL		; Save it
	POP	HL		; Recover new entry pointer
	DEC	HL		; Point to low byte of entry
	LD	(HL),E		; Store prefix ptr in entry
	INC	HL		;  (low byte first)
	LD	(HL),D		;  (then high byte, in mid entry byte)
	INC	HL		; Point to high byte of new entry
	POP	AF		; Recover suffix byte
	LD	(HL),A		; Store
	RET			; All done
	PAGE
; Hash function for (new-style) crunched files
; Note:	"Hash" is of course a misnomer here, since strings are simply
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
;
