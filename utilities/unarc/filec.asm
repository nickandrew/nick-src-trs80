; @(#) filec.asm - High level code - 29-Apr-89
;
	IFDEF	SHOWC
*LIST	ON
	ELSE
*LIST	OFF
	ENDIF
;
; # BEGIN:	Jump here to start the program
;
BEGIN:
	LD	(PARAMS),HL
	LD	SP,STACK
	CALL	CHECK		; Check if we can proceed
	CALL	INIT		; Process command line, open ARC file
	CALL	CRCINI		; Initialise CRC table
;
	LD	HL,TOTS		; Zero all listing totals
	LD	B,TOTC
	LD	C,0
	CALL	FILL
;
; Find first archive header
	LD	B,3		; Setup count of allowed extra bytes
; Note:	As of UNARC 1.2, up to three additional bytes are tolerated
;	before first header mark (for "self-unpacking" archives).
;
FIRST
	CALL	GET		; Get next byte
	CP	ARCMARK		; Is it header marker?
	JR	Z,NEXT		; Yes, skip
	DJNZ	FIRST		; Else loop for no. allowed extras
;
; File processing loop
LOOP
	CALL	GET		; Get next byte
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
; Process next file
NEXT:
	CALL	NC,GET		; Get header version (if haven't yet)
	OR	A		; If zero, that's logical end of file,
	JR	Z,DONE		;  and we're done
	CALL	GETHDR		; Read archive header
	CALL	GETNAM		; Is filename one we desire?
	JR	NZ,SKIP		; No, skip this file
	CALL	LIST		; List file info
	CALL	OUTPUT		; Extract/Type Output the file (possibly)
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
	CALL	OCLOSE
	JP	_EXIT
;
; # MESS: Print a null-terminated message on the console
;
MESS	LD	A,(HL)
	OR	A
	RET	Z
	CALL	ROM@PUT_VDU
	INC	HL
	JR	MESS
;
; # CHECK: Check that enough memory is available
;
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
;
	LD	DE,NOROOM	; abort due to no room
	POP	HL
	JP	PABORT
;
PABORT:
	CALL	PRINT		; Print msg & abort
	LD	DE,PABMSG
	CALL	PRINT
	JP	ABORT
;
; Abort program
ABORT:
	LD	DE,ABOMSG	; Print general abort msg
	CALL	PRINTX		;Print message
	CALL	ICLOSE		;Close file
	LD	DE,OFCB
	LD	A,(DE)
	AND	80H		;Check if file is open
	CALL	NZ,DOS_KILL	;Kill output file
	LD	A,8		;Return code=8
	JP	_ERROR		;Error exit
;
PEXIT:
	CALL	PRINTX
	JP	EXIT
;
;-------------------------------------------------------------------------
; # FN_ERROR: Print a help message and abort with code 8
;-------------------------------------------------------------------------
;
FN_ERROR
	JP	HELP
;
;-------------------------------------------------------------------------
; # F_ERROR: Display a dos error message
;-------------------------------------------------------------------------
;
F_ERROR	PUSH	AF
	OR	80H
	CALL	DOS_ERROR
	POP	AF
	JP	ABORT
;
;-------------------------------------------------------------------------
; # INIT: Initialise and parse command line
;-------------------------------------------------------------------------
;
INIT
	CALL	PROC_FLAGS	;Process dash options (if any)
	CALL	PROC_ARCFILE	;Process arc file name and open file
	RET
;
;-------------------------------------------------------------------------
; # PROC_FLAGS: Process dash options (if any)
;-------------------------------------------------------------------------
;
PROC_FLAGS
	LD	HL,(PARAMS)
	CALL	BYP_SPACES
;
	LD	A,1
	LD	(L_FLAG),A
	XOR	A
	LD	(O_FLAG),A	;No overwrite
;
PF_01
	LD	A,(HL)
	CP	CR
	JP	Z,HELP2		; No parameters entered
	CP	'-'
	RET	NZ		; Default option is to List
	INC	HL
	LD	A,(HL)
PF_02
	AND	5FH
	LD	DE,H_FLAG
	CP	'H'
	JR	Z,SET_FLAG
	LD	DE,L_FLAG
	CP	'L'		;List table of contents?
	JR	Z,SET_FLAG
	LD	DE,T_FLAG
	CP	'T'		;Type contents
	JR	Z,SET_FLAG
	LD	DE,X_FLAG
	CP	'X'		;Extract
	JR	Z,SET_FLAG
	LD	DE,O_FLAG
	CP	'O'		;Overwrite existing
	JR	Z,SET_FLAG
	JP	HELP
;
SET_FLAG
	LD	A,1
	LD	(DE),A
;
	INC	HL
	LD	A,(HL)
	CP	' '
	JR	NZ,PF_02	;Process another flag
	CALL	BYP_SPACES
	JR	PF_01		;Rescan for possibly another option
;
;-------------------------------------------------------------------------
; # BYP_SPACES: Bypass 0 or more spaces at HL
;-------------------------------------------------------------------------
;
BYP_SPACES
	LD	A,(HL)
	CP	' '
	RET	NZ
	INC	HL
	JR	BYP_SPACES
;
;-------------------------------------------------------------------------
; # BYP_WORD: Bypass a non-space word at HL
;-------------------------------------------------------------------------
;
BYP_WORD
BW_01	LD	A,(HL)
	CP	CR
	RET	Z
	OR	A
	RET	Z
	CP	' '
	JR	Z,BW_02
	INC	HL
	JR	BW_01
BW_02	INC	HL
	LD	A,(HL)
	CP	' '
	JR	Z,BW_02
	RET
;
;-------------------------------------------------------------------------
; # PROC_ARCFILE: Parse and open arcfile to use
;-------------------------------------------------------------------------
;
PROC_ARCFILE
	LD	(PARAMX),HL
	LD	DE,IFCB
	CALL	DOS_EXTRACT
	JP	NZ,FN_ERROR	;If no arc filename
	LD	HL,(PARAMX)
	PUSH	HL
	CALL	GETN81		;Fix first characters
	POP	HL
	CALL	BYP_WORD	;Bypass the arc filename
	LD	(PARAMX),HL
;
	CALL	PRINT_FN	;Copy the filename for printing
	LD	HL,IFCB_BUF
	LD	DE,IFCB
	LD	B,0
	CALL	DOS_OPEN_EX	;Open the arcfile
	LD	DE,OPNERR	;If error opening arcfile
	JP	NZ,PABORT
;
	LD	A,1
	LD	(IFLAG),A	; Yes, set input file open flag
	LD	DE,ARCMSG	; Show ARC file name
	CALL	PRINTX
	RET
;
;-------------------------------------------------------------------------
; # PRINT_FN: Copy the filename for printing
;-------------------------------------------------------------------------
;
PRINT_FN
	LD	HL,IFCB
	LD	DE,ARCNAM
	LD	B,30
PFN_1	LD	A,(HL)
	CP	ETX
	JR	Z,PFN_2
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	PFN_1
PFN_2
	XOR	A
	LD	(DE),A
	RET
;
; Display program usage help message
HELP:
	LD	DE,HELPMSG
	JP	PEXIT
;
HELP2:	LD	DE,USAGE	; Just print usage message
	JP	PEXIT		;  and exit
;
; Check wheel byte
WHLCK
	PUSH	HL		; Save register
	LD	HL,(WHEEL)	; Get wheel byte address
	LD	A,(HL)		; Fetch wheel byte
	POP	HL		; Restore reg
	LD	A,1		;Default wheel priv...
	OR	A		; Check wheel byte
	JR	NZ,WHLCK1
	INC	A		; If zero, user is not privileged
	RET			; Return A=1 (NZ)
;
WHLCK1:	XOR	A		;If non-zero, he's a big wheel
	RET			;Return A=0 (Z)
;
ICLOSE
	LD	DE,IFCB		;Setup ARC file FCB
	CALL	CLOSE
	LD	HL,IFLAG
	LD	(HL),0
	RET
;
;Close output file
OCLOSE
	LD	DE,OFCB		;Setup output file FCB
	CALL	CLOSE
	LD	HL,OFLAG
	LD	(HL),0
	RET
;
;Close a file if open
CLOSE
	LD	A,(DE)		;File is open?
	OR	A
	RET	Z
	CALL	DOS_CLOSE
	RET			;Return to caller (NZ if error)
;	
;Check for CTRL-C abort (and/or read console char if any)
CABORT
	CALL	ROM@KEY_NOWAIT		;read char from keyboard
	CP	CTLC		;Is it CTRL-C?
	JP	Z,ABORT
	CP	CTLS		;Is it pause?
	RET	NZ		;No, return char (and NZ) to caller
CABORT2	CALL	ROM@KEY_NOWAIT		;Wait for control-Q
	CP	CTLQ
	JR	NZ,CABORT2
	CP	1
	RET
;
;
;
	SUBTTL	File Output Routines
;
;
;Initialize lookup table for CRC generation
;Note:	For maximum speed, the CRC routines rely on the fact that the
;	lookup table (CRCTAB) is page-aligned.
CRCINI:
	LD	HL,CRCTAB+256	;Point to 2nd page of lookup table
	LD	A,H		;Check enough memory to store it
	CALL	CKMEM
	LD	DE,POLY		;Setup polynomial
;Loop to compute CRC for each possible byte value from 0 to 255
CRCIN1:	LD	A,L		;Init low CRC byte to table index
	LD	BC,256*8	;Setup bit count, clear high CRC byte
;Loop to include each bit of byte in CRC
CRCIN2:	SRL	C		;Shift CRC right 1 bit (high byte)
	RRA			;(low byte)
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
;
