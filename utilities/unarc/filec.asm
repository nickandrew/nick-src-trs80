;Filec/asm
	DB	'[afn]',CR,CR
	DB	'Examples:',CR
	DB	'UNARC SAVE/'
ARCTYP:	DB	'ARC'		; Default filetype for archive files
	DB	' *.*       '
	DB	'; List all files in archive SAVE',CR
	DB	'UNARC SAVE             '
	DB	'; Same as above',CR
	DB	'UNARC SAVE *.DOC       '
	DB	'; List just .DOC files',CR
USE2:	DB	'UNARC SAVE READ.ME     '
	DB	'; Typeout the file READ.ME',CR
USE3:	DB	'UNARC SAVE A:          '
	DB	'; Extract all files to drive A',CR
	DB	'UNARC SAVE B:*.DOC     '
	DB	'; Extract .DOC files to drive B',CR
	DB	'UNARC SAVE C:READ.ME   '
	DB	'; Extract file READ.ME to drive C',CR
	DB	CR
	COPR			; Copyright notice last
; (We'd like to be unobtrusive, but please don't remove or patch out)
	DB	0		; End of message marker
	DB	CTLZ		; Stop attempted .COM file typeout here
	PAGE
	SUBTTL	Beginnings and Endings
; Program begins
; Note:	The program is self-initializing.  Once loaded, it may be
;	re-executed multiple times (e.g. by a zero-length COM file,
;	or the ZCPR GO command).
;
PARAMS	DEFW	0		;Parameter start
;
BEGIN:
	LD	(PARAMS),HL
	LD	(SPSAV),SP	; Save CCP stack
	LD	SP,STACK
	CALL	CHECK		; Check if we can proceed
	CALL	INIT		; Process command line, open ARC file
	CALL	OUTSET		; Check output drive, setup for output
	LD	HL,TOTS		; Zero all listing totals
	LD	BC,TOTC*256+0
	CALL	FILL
; Find first archive header
	LD	B,3		; Setup count of allowed extra bytes
; Note:	As of UNARC 1.2, up to three additional bytes are tolerated
;	before first header mark (for "self-unpacking" archives).
	DEBUG	'First'
FIRST:	CALL	GET		; Get next byte
	CP	ARCMARK		; Is it header marker?
	JR	Z,NEXT		; Yes, skip
	DJNZ	FIRST		; Else loop for no. allowed extras
	PAGE
; File processing loop
LOOP:	CALL	GET		; Get next byte
	CP	ARCMARK		; Is it archive header marker?
	JR	Z,NEXT		; Yes, go process next file (if any)
; Bad archive file header
; Note:	This added in UNARC 1.2 (compatible with MS-DOS ARC 5.12)
	LD	HL,0		; Init count of bytes skipped
BAD:	INC	HL		; Bump bad byte count
	LD	A,H
	OR	L
	JR	Z,BAD1		; But 64K bytes is enough!
	CALL	GET		; Attempt to re-synchronize,
	CP	ARCMARK		; Read bytes until next header marker
	JR	NZ,BAD		; (or end of file abort)
	CALL	GET		; Ok, found another header
	CP	ARCVER+1	; Is it a valid version?
BAD1:	LD	DE,FMTERR	; Report bad format error
	JP	NC,PABORT	;  and abort if not
	PUSH	AF		; Save header version
	EX	DE,HL		; Get count of bytes skipped
	LD	HL,HDRSKP	; Store in message
	LD	BC,0
	CALL	WTOD
	LD	(HL),0
	LD	DE,HDRERR	; Print warning message
	CALL	PRINTX
	POP	AF		; Restore version
	PAGE
; Process next file
NEXT:
	DEBUG	'Next'
	CALL	NC,GET		; Get header version (if haven't yet)
	OR	A		; If zero, that's logical end of file,
	JR	Z,DONE		;  and we're done
	CALL	GETHDR		; Read archive header
	CALL	GETNAM		; Does file name match test pattern?
	JR	NZ,SKIP		; No, skip this file
	CALL	LIST		; List file info
	CALL	OUTPUT		; Output the file (possibly)
	CALL	TAMBIG		; Ambiguous output file selection?
	JR	NZ,EXIT		; No, quit early
; Skip to next file
SKIP:	LD	HL,SIZE		; Get two-word remaining file size
	CALL	LGET		; (will be 0 if output was completed)
	CALL	SEEK		; Seek past it
	JR	LOOP		; Loop for next file
; Done with all files
DONE:	LD	HL,(TFILES)	; Get no. files processed
	LD	A,H
	OR	A
	JR	NZ,DONE1	; Skip if many
	OR	L		; No files found?
	LD	DE,NOFILS	; Yes, setup error message
	JP	Z,PABORT	;  and abort
	DEC	A		; Test if just one file
DONE1:	CALL	NZ,LISTT	; If more than one, list totals
; Exit program
EXIT:	CALL	ICLOSE		; Close input and output files (if open)
	LD	HL,(SPSAV)	; Restore stack pointer
	LD	SP,HL
	JP	DOS		; Return to Newdos
SPSAV	DEFW	0		; SP save word.
HIPAGE	DEFB	0
	PAGE
; Preliminary checks
; Note:	Following is called before local stack is setup.  Primary
;	caution	here is that PRINT and PRINTX (called by PABORT and
;	PEXIT) use no more than 6 stack levels.
CHECK:	XOR	A		; Clear flags in case early abort:
	LD	(IFLAG),A	;  Input file open flag
	LD	(OFLAG),A	;  Output file open flag
	LD	A,(MEMTOP+1)	;Get msb of himem
	DEC	A		;protect last page.
	LD	(HIPAGE),A	; Save highest usable page (+1)
	LD	BC,MINMEM	; Ensure enough memory to do anything.
; Check for enough memory
CKMEM:	CP	B
	RET	NC		;If OK
	LD	DE,NOROOM	; Else, abort due to no room
; Early abort during preliminary checks
EABORT:	POP	HL		; Reclaim stack level for extra safety
; Print error message and abort
PABORT:	CALL	PRINT
; Abort program
ABORT:	LD	DE,ABOMSG	; Print general abort message
; Print message and exit
PEXIT:	CALL	PRINTX
	JR	EXIT
	PAGE
; Validate command line parameters and open input file
SFCB_2	DEFS	32		; Address of second parameter.
;
FN_ERROR
	JP	HELP
;
F_ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	ABORT
;
INIT
	LD	HL,(PARAMS)
	LD	DE,IFCB
	CALL	DOS_EXTRACT
	JP	NZ,FN_ERROR
	LD	HL,ARCTYP	;Add default extension
	LD	DE,IFCB
	CALL	DOS_EXTEND
;
	LD	HL,(PARAMS)	;Move second parameter into SCFB_2
INIT_1	LD	A,(HL)
	CP	CR
	JR	Z,INIT_3
	INC	HL
	CP	' '
	JR	NZ,INIT_1
INIT_2	LD	A,(HL)
	CP	' '
	JR	NZ,INIT_3
	INC	HL
	JR	INIT_2
INIT_3
	LD	DE,SFCB_2
INIT_4	LD	A,(HL)
	CP	CR
	JR	Z,INIT_5
	CP	' '
	JR	Z,INIT_5
	LD	(DE),A
	INC	HL
	INC	DE
	JR	INIT_4
INIT_5	XOR	A
	LD	(DE),A
;
;;	LD	HL,SFCB		; Point to second parameter FCB
;;	LD	DE,OFCB		; Point to file output FCB
;;	LDI			; Save output drive, point to file name
	LD	HL,SFCB_2	; +1 ???
	LD	DE,TNAME	; Set to save test pattern
	LD	BC,11		; Setup count for file name and type
	XOR	A
	CP	(HL)		; Output file name specified?
	JP	NZ,INIT_99	; if no, default. else move.
;
;Move a filespec ABCDEFGH/IJK into ABCDEFGHIJK with check
	LD	B,9		; move up to 8 chars
INIT_6
	LD	A,(HL)
	OR	A
	JR	Z,INIT_7
	CP	'/'
	JR	Z,INIT_7
	CP	'.'
	JR	Z,INIT_7
	CP	':'
	JR	Z,INIT_7
	DEC	B
	JP	Z,FN_ERROR
	LD	(DE),A
	INC	HL
	INC	DE
	JR	INIT_6
INIT_7	DEC	B
	JR	Z,INIT_7B
	LD	A,' '
	LD	(DE),A
	INC	DE
	JR	INIT_7
INIT_7B
	LD	B,4		;Move 3 chars.
	LD	A,(HL)
	CP	'/'
	JR	Z,INIT_8
	CP	'.'
	JR	NZ,INIT_9
INIT_8
	LD	A,(HL)
	OR	A
	JR	Z,INIT_9
	CP	':'
	JR	Z,INIT_9
	DEC	B
	JP	Z,FN_ERROR
	LD	(DE),A
	INC	HL
	INC	DE
	JR	INIT_8
INIT_9	DEC	B
	JR	Z,INIT_9A
	LD	A,' '
	LD	(DE),A
	INC	DE
	JR	INIT_9
INIT_9A
	LD	A,(HL)
	CP	':'
	JR	NZ,INIT_98
	INC	HL
	LD	A,(HL)		;Ignore it...
	JR	INIT_98
;
INIT_99
	LD	H,D		; No, default to "*.*"
	LD	L,E
	LD	(HL),'?'	; (I.e. all "?" chars)
	INC	DE
	DEC	BC
INIT1:	LDIR			; Save test name pattern
INIT_98
INIT2:	LD	HL,IFCB		; Any ARC file name?
;;	LD	A,3		; ETX = terminator fcb?
;;	CP	(HL)
;;	JR	Z,HELP		; No, go show on-line help
	PUSH	HL		; Save name ptr for message generation
	CALL	FAMBIG		; Ambiguous ARC file name?
	LD	DE,NAMERR	; Yes, report error
	JP	Z,PABORT	;  and abort
	POP	HL		; Recover ptr to FCB name
	LD	DE,ARCNAM	; Unparse name for message
;*******************************
	LD	B,11
INIT97	LD	A,(HL)
	CP	'.'
	JR	Z,INIT96
	CP	':'
	JR	Z,INIT96
	CP	ETX
	JR	Z,INIT96
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	INIT97
INIT96
;;	LD	C,' '		; (with no blanks)
;;	CALL	LNAME
	XOR	A		; Cleanup end of message string
	LD	(DE),A
;;	DEC	A		; Set to read a new record next
;;	LD	(GETPTR),A	; (initializes GET)
;;	LD	HL,IFCB		; Point to ARC file FCB
	PAGE
; Open archive file
	LD	HL,IFCB_BUF	;Open file
	LD	DE,IFCB
	LD	B,0
	CALL	DOS_OPEN_EX
	LD	DE,OPNERR	;If error opening
	JP	NZ,PABORT	;  and abort
	LD	A,1
	LD	(IFLAG),A	; Yes, set input file open flag
	LD	DE,ARCMSG	; Show ARC file name
	CALL	PRINTX
;;	LD	A,(BLKSZ)	; Get default disk block size
;;	OR	A		; Explicit default?
;;	CALL	Z,WHLCK		; Or non-wheel if none? (i.e. forces 1K)
;;	JR	NZ,SAVBLS	; Yes, skip
;; Get current disk's allocation block size for listing
;;GETBLS:	LD	C,$GETDPB	; Get DPB address
;;	CALL	BDOS
;;	INC	HL		; Point to block mask
;;	INC	HL
;;	INC	HL
;;	LD	A,(HL)		; Fetch block mask
;;	INC	A		; Compute block size / 1K bytes
;;	RRCA
;;	RRCA
;;	RRCA
;;SAVBLS:	LD	(LBLKSZ),A	; Save block size for listing
	RET			; Return
	PAGE
; Display program usage help message
HELP:
HELP2:	LD	DE,USAGE	; Just print usage message
	JP	PEXIT		;  and exit
; Check wheel byte
WHLCK:	PUSH	HL		; Save register
	LD	HL,(WHEEL)	; Get wheel byte address
	LD	A,(HL)		; Fetch wheel byte
	POP	HL		; Restore reg
	LD	A,1		;Default wheel priv...
	OR	A		; Check wheel byte
	JR	NZ,WHLCK1
	INC	A		; If zero, user is not privileged
	RET			; Return A=1 (NZ)
;
