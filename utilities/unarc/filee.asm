; @(#) filee.asm - Output routines - 29-Apr-89
;
	IFDEF	SHOWE
*LIST	ON
	ELSE
*LIST	OFF
	ENDIF
;
;-------------------------------------------------------------------------
; # CKTYP: Check for valid file name for typeout
;-------------------------------------------------------------------------
;
CKTYP:	OR	C		; Typeout not allowed?
	RET	Z		; Yes, return (will just list file)
	RET			; Do it regardless of filename
;
;-------------------------------------------------------------------------
; # OUTPUT: Extract file for disk or console output
;-------------------------------------------------------------------------
;
OUTPUT	LD	A,(X_FLAG)	;=0 if no extraction reqd
	OR	A
	JR	NZ,OUTPUT_00
	LD	A,(T_FLAG)
	OR	A
	JR	NZ,OUTPUT_00
	RET
;
OUTPUT_00
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
;*******************************
	LD	A,(T_FLAG)	;=1 if typing output
	OR	A
	JR	Z,OUTDSK
;*******************************
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
	LD	B,62
	LD	C,'-'
	CALL	FILL
	CALL	LISTL		; Print separating line first
	JR	OUTBEG		; Go extract file for typeout
;
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
	LD	A,(O_FLAG)	;Test overwrite flag
	OR	A
	JR	NZ,OUTD2_1	;If set, allow it
	LD	DE,ABOMSG	;Print abort message
	CALL	PRINTL
	LD	A,12		;Return code 12
	JP	_ERROR
;
OUTD2
	CP	18H		;File not in directory
	JP	NZ,F_ERROR	;Some other error
	LD	HL,OFCB_BUF
	LD	DE,OFCB
	LD	B,0
	CALL	DOS_OPEN_NEW
	JP	NZ,F_ERROR	;Print error & abort
OUTD2_1
	LD	A,1
	LD	(OFLAG),A	; Set flag for output file open
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
; (repeat character encoding)
;
UPK1:	CALL	PUTUP		; Output with repeated byte expansion
UPK:	CALL	GETC		; Get input byte
	JR	NC,UPK1		; Loop until end of file
	JR	OUTEND
;
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
	LD	A,(WARNFLAG)	;Check if warning issued
	OR	A
	JR	NZ,OUTEND_01	;A warning!
	CALL	OCLOSE		; Close output file
	RET	Z		; Return unless error closing file
	LD	DE,CLSERR	; Else, report close failure
	JP	PABORT		;  and abort
;
OUTEND_01
	CALL	OCLOSE		;Close incorrect file
	LD	DE,WRNMSG
	JP	PABORT		;And abort cc=8
;
