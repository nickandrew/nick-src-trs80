;Filef/asm
TREECL:	LD	HL,TREE		; Point to tree (also string table)
STRTCL:				; (Entry for partial string table clear)
	LD	(HL),L		; Clear first byte (it's page-aligned)
	LD	D,H		; Copy pointer to first byte
	LD	E,L
	INC	DE		; Propogate it thru second byte, etc.
	LDIR			; (called with BC = byte count - 1)
	RET			; Return
	PAGE
; Uncrunch (LZW-coded) file
;	.COMMENT \
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
	PAGE
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
