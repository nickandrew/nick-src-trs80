;Fileb
	PAGE
;	SUBTTL	Definitions
; ARC file parameters
ARCMARK	EQU	26		; Archive header marker byte
; Note:	The following two definitions should not be changed lightly.
;	These are hard-wired into the code at numerous places!
ARCVER	EQU	8		; Max. header vers. supported for output
CRBITS	EQU	12		; Max. bits in crunched file input codes
; system equates
MEMTOP	EQU	4049H		; himem for model 1
	PAGE
; ASCII control codes
ETX	EQU	3		;^C
CTLC	EQU	'C'-'@'		; Control-C (console abort)
HT	EQU	'I'-'@'		; Horizontal tab
LF	EQU	'J'-'@'		; Line feed
CR	EQU	'M'-'@'		; Carriage return
CTLQ	EQU	'Q'-'@'		;XON
CTLS	EQU	'S'-'@'		;XOFF
CTLZ	EQU	'Z'-'@'		; Control-Z (CP/M end-of-file)
DEL	EQU	7FH		; Delete/rubout
REP	EQU	'P'-'@'+80H	; Repeated byte flag (DLE with msb set)
	PAGE
;	SUBTTL	Patchable Options
; Useful options here at start of file to simplify patching
;
CCPSV:	DB	0		; This to clobber CCP and force reboot
BLKSZ:	DB	1		; Default disk allocation block size (K)
				;  for listing, when no output drive
HIDRV:	DB	0		; This restricts input to default drive
HODRV	DB	3
; Note:	As of UNARC 1.2, the following byte serves only as a flag.
;	I.e., it no longer defines a pseudo typeout "drive".
TYFLG:	DB	0FFH		; This enables single file typeout
TYPGS:	DB	0		;*No. buffer pages for typeout (0=max)
TYLIM:	DB	0		; No line limit for file typeout
; Following added in UNARC 1.2 to simplify use by RCPM sysops.  If byte
; addressed by WHEEL is zero, no file output allowed (as if HODRV = 0).
; Also BLKSZ and/or TYPGS are assumed = 1, if these are zero by default.
; If byte addressed by WHEEL is non-zero (indicates a privileged user),
; TYFLG and TYLIM are not enforced (unlimited typeout allowed).  The
; default wheel byte address defined here (HODRV) provides compatibility
; with previous releases of UNARC for systems which do not implement a
; wheel byte.  (ZCPR3 users should set this word to the address of their
; Z3WHL byte, as determined by running SHOW.COM.)
WHEEL:	DW	HODRV		; Address of "wheel" byte (this if none)
	PAGE
; Table of file types which are disallowed for typeout
NOTYP:	DB	'COM'		; CP/M-80 or MS-DOS binary object
	DB	'CMD'		; CP/M-86 binary object
	DB	'EXE'		; MS-DOS executable
	DB	'OBJ'		; Renamed COM
	DB	'OV?'		; Binary overlay
	DB	'REL'		; Relocatable object
	DB	'?RL'		; Other relocatables (PRL, CRL, etc.)
	DB	'INT'		; Intermediate compiler code
	DB	'SYS'		; System file
	DB	'BAD'		; Bad disk block
	DB	'LBR'		; Library
	DB	'ARC'		; Archive (unlikely in an ARC)
	DB	'?Q?'		; Any squeezed file (ditto)
	DB	'?Z?'		; Any crunched file
; Note:	Additional types may be added below.  To remove one of the above
;types without replacing it, simply set the msb in any byte.
	DB	0,0,0		;Room for more types (19)?
	DB	0,0,0
	DB	0,0,0
	DB	0,0,0
	DB	0,0,0
	DB	0,0,0
	DB	0,0,0
	DB	0		; End of table
	PAGE
;
MESS	LD	A,(HL)
	OR	A
	RET	Z
	CALL	33H
	INC	HL
	JR	MESS
;
;	SUBTTL	Program Usage
; Following displays if no command line parameters
; (Also on attempts to type the .COM file)
USAGE:	IDENT			; Program version identification first
	DB	CR
	DB	'Archive File Extractor (Trs-80 version)'
	DB	CR,'Usage: UNARC arcfile '
USE1
;
DEBUG	MACRO	#STRING
*MOD
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	HL,$+9
	CALL	MESS
	JP	MAC_?
	DEFM	#STRING,' ',0
MAC_?
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	ENDM
;
