;Filei
; A few decimal ASCII conversion callers, for convenience
WTODA:	LD	B,5		; List blank-filled word in 5 cols
WTODB:	LD	C,' '		; List blank-filled word in B cols
	JR	WTOD		; List C-filled word in B cols
BTODA:	LD	B,4		; List blank-filled byte in 4 cols
BTODB:	LD	C,' '		; List blank-filled byte in B cols
	JR	BTOD		; List C-filled byte in B cols
LTODA:	LD	BC,9*256+' '	; List blank-filled long in 9 cols
;	JR	LTOD
	PAGE
; Convert Long (or Word or Byte) Binary to Decimal ASCII
; R. A. Freed
; 2.0	15 Mar 85
; Entry:	A  = Unsigned 8-bit byte value (BTOD)
;		DE = Unsigned 16-bit word value (WTOD)
;		DE = Pointer to low byte of 32-bit long value (LTOD)
;		B  = Max. string length (0 implies 256, i.e. no limit)
;		C  = High-zero fill (0 to suppress high-zero digits)
;		HL = Address to store ASCII byte string
;
; Return:	HL = Adress of next byte after last stored
;
; Stack:	n+1 levels, where n = no. significant digits in output
;
; Notes:	If B > n, (B-n) leading fill chars (C non-zero) stored.
;		If B < n, high-order (n-B) digits are suppressed.
;		If only word or byte values need be converted, use the
;		 shorter version of this routine (WTOD or BTOD) instead.
RADIX	EQU	10		; (Will work with any radix <= 10)
LTOD:	PUSH	DE		; Entry for 32-bit long pointed to by DE
	EXX			; Save caller's regs, swap in alt set
	POP	HL		; Get pointer and fetch value to HADE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	EX	DE,HL		; Value now in DAHL
	JR	LTOD1		; Join common code
BTOD:	LD	E,A		; Entry for 8-bit byte in A
	LD	D,0		; Copy to 16-bit word in DE
WTOD:	PUSH	DE		; Entry for 16-bit word in DE, save it
	EXX			; Swap in alt regs for local use
	POP	HL		; Recover value in HL
	XOR	A		; Set to clear upper bits in DE
	LD	D,A
; Common code for all entries
LTOD1:	LD	E,A		; Now have 32-bit value in DEHL
	LD	C,RADIX		; Setup radix for divides
	SCF			; Set first-time flag
	PUSH	AF		; Save for stack emptier when done
	PAGE
; Top of conversion loop
; Method:  Generate output digits on stack in reverse order.  Each loop
; divides the value by the radix.  Remainder is the next output digit,
; quotient becomes the dividend for the next loop.  Stop when get zero
; quotient or no. of digits = max. string length.  (Always generates at
; least one digit, i.e. zero value has one "significant" digit.)
LTOD2:	CALL	DIVLB		; Divide to get next digit
	OR	'0'		; Convert to ASCII (clears carry)
	EXX			; Swap in caller's regs
	DJNZ	LTOD5		; Skip if still more room in string
; All done (value fills string), this is the output loop
LTOD3:	LD	(HL),A		; Store digit in string
	INC	HL		; Bump string ptr
LTOD4:	POP	AF		; Unstack next digit
	JR	NC,LTOD3	; Loop if any
	RET			; Return to caller
; Still more room in string, test if more significant digits
LTOD5:	PUSH	AF		; Stack this digit
	EXX			; Swap back local regs
	LD	A,H		; Last quotient = 0?
	OR	L
	OR	D
	OR	E
	JR	NZ,LTOD2	; No, loop for next digit
; Can stop early (no more digits), handle leading zero-fill (if any)
	EXX			; Swap back caller's regs
	OR	C		; Any leading fill wanted?
	JR	Z,LTOD4		; No, go to output loop
LTOD6:	LD	(HL),A		; Store leading fill
	INC	HL		; Bump string ptr
	DJNZ	LTOD6		; Repeat until fill finished
	JR	LTOD4		; Then go store the digits
	PAGE
	SUBTTL	Miscellaneous Support Routines
; Note:	The following general-purpose routine is currently used in this
;	program only to divide longs by 10 (by decimal convertor, LTOD).
;	Thus, a few unneeded code locations have been commented out.
;	(May be restored if program requirements change.)
; Unsigned Integer Division of Long (or Word or Byte) by Byte
; R. A. Freed
; Divisor in C, dividend in (A)DEHL or (A)HL or L (depends on call used)
; Quotient returned in DEHL (or just HL), remainder in A
;DIVXLB:OR	A		; 40-bit dividend in ADEHL (A < C)
;	JR	NZ,DIVLB1	; Skip if have more than 32 bits
DIVLB:	LD	A,D		; 32-bit dividend in DEHL
	OR	E		; But is it really only 16 bits?
	JR	Z,DIVWB		; Yes, skip (speeds things up a lot)
	XOR	A		; Clear high quotient for first divide
DIVLB1:	CALL	DIVLB2		; Get upper quotient first, then swap:
DIVLB2:	EX	DE,HL		; Upper quotient in DE, lower in HL
DIVXWB:	OR	A		; 24-bit dividend in AHL (A < C)
	JR	NZ,DIVWB1	; Skip if have more than 16 bits
DIVWB:	LD	A,H		; 16-bit dividend in HL
	CP	C		; Will quotient be less than 8 bits?
	JR	C,DIVBB1	; Yes, skip (small dividend speed-up)
	XOR	A		; Clear high quotient
DIVWB1:	LD	B,16		; Setup count for 16-bit divide
	JR	DIVB		; Skip to divide loop
;DIVBB:	XOR	A		; 8-bit dividend in L
DIVBB1:	LD	H,L		; For very small nos., pre-shift 8 bits
	LD	L,0		; High byte of quotient will be zero
	LD	B,8		; Setup count for 8-bit divide
; Top of divide loop (vanilla in-place shift-and-subtract)
DIVB:	ADD	HL,HL		; Divide AHL (B=16) or AH (B=8) by C
	RLA			; Shift out next remainder bit
;	JR	C,DIVB1		; (This needed only for divsors > 128)
	CP	C		; Greater than divisor?
	JR	C,DIVB2		; No, skip (next quotient bit is 0)
DIVB1:	SUB	C		; Yes, reduce remainder
	INC	L		;  and set quotient bit to 1
DIVB2:	DJNZ	DIVB		; Loop for no. bits in quotient
	RET			; Done (quotient in HL, remainder in A)
	PAGE
; Fetch a long (4-byte) value
LGET:	LD	E,(HL)		; Fetch BCDE from (HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	RET
; Add two longs
LADD:	LD	B,4		; (DE) + (HL) -> (HL)
	OR	A
LADD1:	LD	A,(DE)
	ADC	A,(HL)
	LD	(HL),A
	INC	HL
	INC	DE
	DJNZ	LADD1
	RET	
; Fill routines
FILL2B:	LD	B,2		; Fill 2 blanks
FILLB:	LD	C,' '		; Fill B blanks
FILL:	LD	(HL),C		; Fill B bytes with char in C
	INC	HL
	DJNZ	FILL
	RET
; Convert character to upper case
UPCASE:	CP	'a'
	RET	C
	CP	'z'+1
	RET	NC
	ADD	A,'A'-'a'
	RET
;

