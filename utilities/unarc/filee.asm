;Filee/asm
	JR	NC,CRCIN3	; Skip if 0 shifted out
	EX	AF,AF'		; Save lower CRC byte
	LD	A,C		; Update upper CRC byte
	XOR	D		;  with upper polynomial byte
	LD	C,A
	EX	AF,AF'		; Recover lower CRC byte
	XOR	E		; Update with lower polynomial byte
CRCIN3:	DJNZ	CRCIN2		; Loop for 8 bits
	LD	(HL),C		; Store upper CRC byte (2nd table page)
	DEC	H
	LD	(HL),A		; Store lower CRC byte (1st table page)
	INC	H
	INC	L		; Bump table index
	JR	NZ,CRCIN1	; Loop for 256 table entries
	RET
	PAGE
; Check for valid file name for typeout
CKTYP:	OR	C		; Typeout not allowed?
	CALL	NZ,TAMBIG	; Or ambiguous output file name?
	RET	Z		; Yes, return (will just list file)
	LD	DE,NOTYP	; Point to table of excluded types
CKTYP1:	LD	HL,TNAME+8	; Point to type of selected file
	LD	B,3		; Setup count for 3 chars
CKTYP2:	LD	A,(DE)		; Fetch next table char
	OR	A		; End of table?
	JR	Z,CKTYP5	; Yes, go set flag to allow typeout
	CP	'?'		; Matches any char?
	JR	Z,CKTYP3	; Yes, skip
	CP	(HL)		; Matches this char?
CKTYP3:	INC	DE		; Bump table ptr
	JR	Z,CKTYP4	; Matched?
	DJNZ	CKTYP3		; No, just advance to next table entry
	JR	CKTYP1		; Then loop to try again
CKTYP4:	INC	HL		; Char matched, point to next
	DJNZ	CKTYP2		; Loop for all chars in file type
	RET			; If all matched, return (no typeout)
CKTYP5:	DEC	A		; If no match, file name is valid
;;	LD	(OFCB),A	; Set dummy drive (0FFH) in output FCB
	RET			; Return
;
;
;
;
;
; Test for ambiguous output file selection
TAMBIG:	LD	HL,TNAME	; Point to test pattern
; Check for ambiguous file name (HL = ptr to FCB-type name)
FAMBIG:	LD	BC,11		; Setup count for file name and type
	LD	A,'?'		; Any "?" chars?
	CPIR			; Yes, return with Z set
	RET			; No, return NZ
	PAGE
;
;
;
;
;
; Extract file for disk or console output
OUTPUT:	LD	A,(OFCB)	; Any output drive (or typing files)?
	OR	A
	RET	Z		; No, there's nothing to do here
	LD	B,A		; Save output drive
	LD	A,(VER)		; Get header version
	CP	ARCVER+1	; Supported for output?
	LD	DE,BADVER	; No, report unknown version
	JP	NC,PABORT	;  and abort
	LD	L,A		; Copy version
	LD	H,0
	LD	DE,OBUFT-1	; Use to index table of starting
	ADD	HL,DE		;  output buffer pages
	LD	A,(HL)		; Get starting page of buffer
	CALL	CKMEM		; Ensure enough memory
	LD	HL,BUFPAG	; Point to buffer start page
	LD	(HL),A		; Save it
	LD	C,A		; (also for typeout buffer check)
	LD	HL,BUFLIM
	LD	A,(HIPAGE)	; Get memory limit page
	LD	(HL),A		; Assume max possible output buffer
	INC	B		; Typing files?
	JR	NZ,OUTDSK	; No, go extract to disk
; Setup for console output
	LD	A,(TYPGS)	; Get max. pages to buffer typeout
	OR	A		; No limit?
	CALL	Z,WHLCK		; And is this privileged user?
	JR	Z,OUTCON	; Yes, skip (use 1 page if no privilege)
	ADD	A,C		; Compute desired limit page
	JR	C,OUTCON	; But skip if exceeds (physical) memory
	CP	(HL)
	JR	NC,OUTCON	; Also if exceeds available memory
	LD	(HL),A		; If ok, set lower buffer limit
OUTCON:	LD	HL,LINE		; Fill listing line with dashes
	LD	BC,256*LINLEN+'-'
	CALL	FILL
	CALL	LISTL		; Print separating line first
	JR	OUTBEG		; Go extract file for typeout
	PAGE
; Setup for disk file output
OUTDSK:
	LD	DE,OFCB		;Try to open existing
	LD	HL,OFCB_BUF
	LD	B,0
	CALL	DOS_OPEN_EX
	JR	NZ,OUTD2	; no, skip.
OUTD1_0
	LD	DE,EXISTS	; Inform user and ask:
	CALL	PRINTS		; Should we overwrite existing file?
OUTD1:	CALL	CABORT		; Wait for response (or CTRL-C abort)
	OR	A
	JR	Z,OUTD1
	LD	E,A		; Save response
	CALL	CRLF		; Start a new line after prompt
	LD	A,E		; Get response char
	CALL	UPCASE		; Upper and lower case are the same
	CP	'Y'		; Answer was yes?
	JR	Z,OUTD2_1
	CP	'N'
	JR	NZ,OUTD1_0
	RET
;;	RET	NZ		; No, return (skip file output)
;;	JR	OUTD2_1		;File already open.
OUTD2:
	LD	HL,OFCB_BUF
	LD	DE,OFCB
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,F_ERROR	;Print error & abort
;
OUTD2_1
	LD	A,1
	LD	(OFLAG),A	; Set flag for output file open
	PAGE
;
;
;
;
; All set to output file
OUTBEG:	LD	A,(VER)		; Check compression type
	CP	4
	JR	NC,USQ		; Skip if squeezed or crunched
	CALL	PUTSET		; Else (simple cases), setup output regs
	CP	3		; Packed?
	JR	Z,UPK		; Yes, skip
; Unchanged file
UNC:	CALL	GETC		; Just copy input to output
	JR	C,OUTEND	;  until end of file
	CALL	PUT
	JR	UNC
; Packed file (repeat character encoding)
;
UPK1:	CALL	PUTUP		; Output with repeated byte expansion
UPK:	CALL	GETC		; Get input byte
	JR	NC,UPK1		; Loop until end of file
; End of output file
OUTEND:	CALL	PUTBUF		; Flush final buffer (if any)
	LD	A,(OFLAG)	; File open?
	OR	A
	RET	Z		; No, return from file typeout
	EX	DE,HL		; Save computed CRC
	LD	HL,(CRC)	; Get CRC recorded in archive header
	SBC	HL,DE		; Do they match?
	LD	DE,CRCERR	; If not,
	CALL	NZ,OWARN	;  print warning message
	LD	HL,LEN		; Point to remaining (output) length
	CALL	LGET		; Fetch length (it's 4 bytes)
	LD	A,B		; All should be zero...
	OR	C
	OR	D
	OR	E
	LD	DE,LENERR	; If not,
	CALL	NZ,OWARN	;  print incorrect length warning
	CALL	OCLOSE		; Close output file
	LD	HL,OFLAG	; Clear file open flag
	LD	(HL),0
	RET	Z		; Return unless error closing file
	LD	DE,CLSERR	; Else, report close failure
	JP	PABORT		;  and abort
	PAGE
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
