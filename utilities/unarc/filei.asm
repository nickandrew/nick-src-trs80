;Filei/asm
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
; Print character
PCHAR:	PUSH	DE		; Save register
	CALL	33H
	POP	DE		; Restore register
	RET			; Return
	PAGE
; Print string on new line, then start another
;
PRINTX:	CALL	CRLF
	JR	PRINTL
; Print string on new line
PRINT:	CALL	CRLF
; Print NUL-terminated string
PRINTS:	LD	A,(DE)
	OR	A
	RET	Z
	CALL	PCHAR
	INC	DE
	JR	PRINTS
;
; Output warning message about extracted file
OWARN:	PUSH	DE
	LD	DE,WARN
	CALL	PRINTS
	POP	DE
	JR	PRINTL
	PAGE
; List file name
; Note:	We use name in output file FCB, rather than original name in
;	archive header (illegal chars already filtered by GETNAM).
;	This routine also called by INIT to unparse ARC file name.
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
