;Filec - last updated 13-Sep-87
	IFDEF	SHOWC
*LIST	ON
	ELSE
*LIST	OFF
	ENDIF
;
	DB	'[-t] [-e] [afn]',CR,CR
	DB	'Examples:',CR
;
	DB	'unarc save'
	DB	SEP
;
ARCTYP:	DB	'ARC'		; Default filetype for archive files
	DB	' *.*     '
	DB	'; Index of all files in archive SAVE',CR
	DB	'UNARC SAVE             '
	DB	'; Same as above',CR
	DB	'UNARC SAVE *.DOC       '
	DB	'; Index of just .DOC files',CR
USE2:	DB	'UNARC SAVE -t READ.ME  '
	DB	'; Display the file READ.ME',CR
USE3:
	DB	'UNARC SAVE -e READ.ME  '
	DB	'; Extract file READ.ME',CR
	DB	CR
	COPR			; Copyright notice last
; (We'd like to be unobtrusive, but please don't remove or patch out)
	DB	0		; End of message marker
	DB	CTLZ		; Stop .COM file typeout
	PAGE
	SUBTTL	Beginnings and Endings
; Program begins
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
EXIT:	CALL	ICLOSE		;Close input, output files
;;	LD	HL,(SPSAV)	; Restore stack pointer
;;	LD	SP,HL
	JP	_EXIT
;
SPSAV	DEFW	0		; SP save word.
HIPAGE	DEFB	0
;
; Preliminary checks
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
	LD	DE,NOROOM	; abort due to no room
;
EABORT:	POP	HL		; Early abort
;
PABORT:	CALL	PRINT		; Print msg & abort
; Abort program
ABORT:	LD	DE,ABOMSG	; Print general abort msg
	CALL	PRINTX		;Print message
	CALL	ICLOSE		;Close files
	JP	_ERROR		;Error exit
PEXIT:	CALL	PRINTX
	JP	EXIT
;
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
	JP	NZ,FN_ERROR	;If no first parameter
	LD	HL,ARCTYP	;Add default extension
	LD	DE,IFCB
	CALL	DOS_EXTEND
;
	LD	HL,(PARAMS)	;Bypass first parameter
INIT_1	LD	A,(HL)		;Bypass Arc filename
	CP	CR
	JR	Z,INIT_3
	OR	A
	JR	Z,INIT_3	;If end of cmd line
	INC	HL
	CP	' '
	JR	NZ,INIT_1
;
INIT_2	LD	A,(HL)		;Bypass subseq. spaces
	CP	' '
	JR	NZ,INIT_3
	INC	HL
	JR	INIT_2
INIT_3
	LD	A,(HL)
	CP	'-'
	CALL	Z,PROC_FLAGS	;do -e or -t flags.
	LD	DE,SFCB_2
	XOR	A
	LD	(DE),A
	LD	B,13
INIT_4	LD	A,(HL)
	CP	CR
	JR	Z,INIT_5
	OR	A
	JR	Z,INIT_5
	CP	' '
	JR	Z,INIT_5
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	INIT_4
	JP	FN_ERROR
INIT_5	XOR	A
	LD	(DE),A
;
	LD	HL,SFCB_2
	LD	DE,TNAME	; Set to save test pattern
	XOR	A
	CP	(HL)		;Null string?
	JP	Z,INIT_99	;if none, assume *.*
;
;Move a filespec ABCDEFGH/IJK into ABCDEFGHIJK with check
	LD	B,9		; move up to 8 chars
INIT_6
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,INIT_7
	CP	'.'
	JR	Z,INIT_7
	CP	'/'
	JR	Z,INIT_7
	DEC	B
	JP	Z,FN_ERROR
	CP	'*'
	JR	Z,INIT_6B
	LD	(DE),A
	INC	DE
	JR	INIT_6
;
INIT_6B	LD	A,'?'
	LD	(DE),A
	INC	DE
	DJNZ	INIT_6B
	INC	B
	JR	INIT_6
;
INIT_7	DEC	B
	JR	Z,INIT_7B
	LD	A,' '
	LD	(DE),A
	INC	DE
	JR	INIT_7
INIT_7B
	LD	B,4		;Move 3 chars.
INIT_8
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,INIT_9
	DEC	B
	JP	Z,FN_ERROR
	CP	'*'
	JR	Z,INIT_8B
	LD	(DE),A
	INC	DE
	JR	INIT_8
;
INIT_8B	LD	A,'?'
	LD	(DE),A
	INC	DE
	DJNZ	INIT_8B
	INC	B
	JR	INIT_8
;
INIT_9	DEC	B
	JR	Z,INIT_9A
	LD	A,' '
	LD	(DE),A
	INC	DE
	JR	INIT_9
INIT_9A
	JR	INIT_98
;
INIT_99
	LD	BC,10
	LD	H,D		; No, default to "*.*"
	LD	L,E
	LD	(HL),'?'	; (I.e. all "?" chars)
	INC	DE
;;init1:
	LDIR
;
INIT_98
INIT2:	LD	HL,IFCB		; Any ARC file name?
	PUSH	HL		; Save name ptr for message generation
	CALL	FAMBIG		; Ambiguous ARC file name?
	LD	DE,NAMERR	; Yes, report error
	JP	Z,PABORT	;  and abort
	POP	HL		; Recover ptr to FCB name
	LD	DE,ARCNAM	; Unparse name for message
;*******************************
	LD	B,12
INIT97	LD	A,(HL)
;
	CP	SEP
;
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
	XOR	A		; Cleanup end of message string
	LD	(DE),A
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
	RET			; Return
;
PROC_FLAGS
	INC	HL
	LD	A,(HL)
	AND	5FH
	CP	'E'
	JR	Z,PROC_EFLAG
	CP	'T'
	JR	Z,PROC_TFLAG
	JP	HELP
PROC_TFLAG
	LD	A,1
	LD	(T_FLAG),A
	LD	(E_FLAG),A
	XOR	A
	LD	(E_DRIVE),A
	INC	HL
	JR	PEF_1
PROC_EFLAG
	LD	A,1
	LD	(E_FLAG),A
	INC	HL
	LD	A,(HL)
	CP	':'
	JR	NZ,PEF_1
	INC	HL
	LD	A,(HL)
	LD	(E_DRIVE),A
	INC	HL
PEF_1
	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	PEF_1
;
; Display program usage help message
HELP:
HELP2:	LD	DE,USAGE	; Just print usage message
	JP	PEXIT		;  and exit
;
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
