;Filef - Last updated 14-Jan-88
;
; Unsqueeze (Huffman-coded) file
;Note:  Although numerous assembly-language implementations of Richard 
;Greenlaw's pioneer USQ (C language) program have appeared, all of the 
;coding here is original.  At risk of being accused of "re-inventing 
;the wheel," we do this primarily for personal satisfaction (not to 
;mention protection of our copyright).
;We were tempted to use the super-fast algorithm suggested by Steven 
;Greenberg's recent public contribution, FU.  (After all, we require a 
;Z80, so why not take advantage of the latest technology?)  However, 
;some of the speed benefit of Greenberg's method is necessarily lost, 
;since we do not buffer the input file and must count each input byte 
;against the file size recorded in the archive header.  (Input buffering 
;is not advantageous, since we must have random access to the archive 
;file.)  Also, the occurence of squeezed files in archives is relatively 
;rare, since the "crunching" method produces better compression in most 
;cases.  Thus we use a more classical approach, albeit at the expense of 
;the ultimate in performance, but with a substantial savings in code 
;complexity and memory requirements.
;Note also that many authors go to elaborate pains to check the validity 
;of the binary decoding tree.  Such checks include:  (1) the node count 
;(can be at most 256, although some people mistakenly think it can be 
;greater -- c.f. Knuth, vol. 1, 2nd ed., sec. 2.3.4.5, pp. 399-405); (2) 
;all node links in the tree must be in the range specified by the node 
;count; (3) no infinite loops in the tree (this one's not so easy to 
;test); and (4) premature end-of-file in the tree or data.  Instead, we 
;take a KISS approach which assumes the tree is valid and relies upon 
;the final output file CRC and length checks to warn of any possible 
;errors:  (1) the tree is initially cleared (all links point to the root 
;node); (2) at most 256 nodes are stored; and (3) decoding terminates 
;upon detecting the special end-of-file code in the data (the normal 
;case), the physical end-of-file (as determined by the size recorded in 
;the archive header), or a tree link to the root node (which indicates a 
;diseased tree).
	PAGE
; Start unsqueezing
USQ:	JR	NZ,UCR		; But skip if crunched file
; First clear the decoding tree
	LD	BC,TREESZ-1	; Setup bytes to clear - 1
	CALL	TREECL		; (Leaves DE pointing past end of tree)
; Read in the tree
; Note:	The end-of-file condition may be safely ignored while reading 
;	the node count and tree, since GETC will repeatedly return
;	zero bytes in this case.
	CALL	GETC		; Get node count, low byte
	LD	C,A		; Save for loop
	CALL	GETC		; Get high byte (can be ignored)
	OR	C		; But is it zero nodes?
	JR	Z,USQ3		; Yes (very unlikely), it's empty file
USQ1:	LD	B,4		; Setup count for 4 bytes in node
	LD	A,D		; Each byte will be stored in a separate
	SUB	B		;  page (tree is page-aligned), so
	LD	D,A		;  point back to the first page
USQ2:	CALL	GETC		; Get next byte
	LD	(DE),A		; Store in tree
	INC	D		; Point to next page
	DJNZ	USQ2		; Loop for all bytes in node
	INC	E		; Bump tree index
	DEC	C		; Reduce node count
	JR	NZ,USQ1		; Loop for all nodes
USQ3:	CALL	PUTSET		; Done with tree, setup output regs
	PUSH	HL		; Reset current input byte (on stack)
; Start of decoding loop for next output byte
USQ4:	EXX			; Save output registers
	XOR	A		; Reset node index to root of tree
; Top of loop for next input bit
USQ5:	LD	L,A		; Setup index of next tree node
	POP	AF		; Get current input byte
	SRL	A		; Shift out next input bit
	JR	NZ,USQ6		; Skip unless need a new byte
	PAGE
; Read next input byte
	PUSH	HL		; Save tree index
	CALL	GETCX		; Get next input byte
	EXX			; Save output regs
	JR	C,USQEND	; But go stop if reached end of input
	POP	HL		; Restore tree index
	SCF			; Set flag for end-of-byte detection
	RRA			; Shift out first bit of new byte
; Process next input bit
USQ6:	PUSH	AF		; Save input byte
;;	LD	H,HIGH TREE	; Point to start of current node
	LD	H,TREE/16/16	; Point to start of current node
	JR	NC,USQ7		; Skip if new bit is 0
	INC	H		; Bit is 1, point to 2nd word of node
	INC	H		; (3rd tree page)
USQ7:	LD	A,(HL)		; Get low byte of node word
	INC	H
	LD	B,(HL)		; Get high byte (from next tree page)
	INC	B
	JR	NZ,USQ8		; Skip if high byte not -1
	CPL			; We've got output byte (complemented)
	EXX			; Restore regs for output
	CALL	PUTUP		; Output with repeated byte expansion
	JR	USQ4		; Loop for next byte
USQ8:	DJNZ	USQEND		; If high byte not 0, it's special EOF
	OR	A		; If high byte was 0, its new node link
	JR	NZ,USQ5		; Loop for new node (but can't be root)
; End of squeezed file (physical, logical, or due to Dutch elm disease)
USQEND:	POP	HL		; Cleanup stack
; End of unsqueezed or uncrunched file output
UCREND:	EXX			; Restore output regs
	JP	OUTEND		; Go end output
; Clear squeezed file decoding tree (or crunched file string table)
TREECL:	LD	HL,TREE		; Point to tree (also string table)
STRTCL:				; (Entry for partial string table clear)
	LD	(HL),L		; Clear first byte (it's page-aligned)
	LD	D,H		; Copy pointer to first byte
	LD	E,L
	INC	DE		; Propogate it thru second byte, etc.
	LDIR			; (called with BC = byte count - 1)
	RET			; Return

