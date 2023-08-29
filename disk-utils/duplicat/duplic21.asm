; duplic21.asm: Copy Microsoft Adventure from a protected diskette
; A protected diskette is 40 track SSSD with translated track/sector numbers
; (0, 127, 125, 123, 121, ...)
; Usage:
;    DUPLIC21
;      Reads a protected diskette, writes a standard diskette
;    DUPLIC21 /P
;      Reads a protected diskette, writes a protected diskette
; Source and destination drives are hard-coded

*GET	DOSCALLS
*GET	FD1771

SOURCE_DISK_SELECTOR	EQU	1<<1		; Copy from drive 1
DEST_DISK_SELECTOR	EQU	2<<1		; Copy to drive 2

	ORG	5200H
START
	LD	A,(HL)
	CP	'/'
	JR	NZ,START_01
	INC	HL
	LD	A,(HL)
	CP	'P'
	JR	NZ,START_01
	LD	A,1
	LD	(PROTECTED_DISK),A
START_01
	DI
	LD	HL,SMES		; "Insert <SOURCE> DISK..."
	CALL	MSGKEY		; Print message and wait for return key

	CALL	SET_SINGLE_DENSITY

	LD	A,SOURCE_DISK_SELECTOR
	LD	(CURRENT_DISK_SELECTOR),A
	CALL	SPIN_UP
	CALL	RESTOR		; Move head to track zero
	LD	A,0
	LD	(TRAK),A

	CALL	RESET
	CALL	LOAD50		; Load the first 5 tracks

	LD	HL,DMES		; "Insert <DESTINATION> DISK..."
	CALL	MSGKEY		; Print message and wait for return key

	LD	A,DEST_DISK_SELECTOR
	LD	(CURRENT_DISK_SELECTOR),A
	CALL	SPIN_UP
	CALL	RESTOR		; Move head to track zero
	LD	A,0
	LD	(TRAK),A

	CALL	RESET
	CALL	SAVE50		; Save the first 5 tracks

	LD	B,6		; Copy 35 tracks total (5 + 6 * 5)
COPY_LOOP
	PUSH	BC
	LD	HL,M_LOADING	; "Loading..."
	CALL	MESSAGE

	LD	A,SOURCE_DISK_SELECTOR
	LD	(CURRENT_DISK_SELECTOR),A
	CALL	SPIN_UP
	CALL	RESET
	CALL	LOAD50		; Load 5 tracks

	LD	A,(TRAK)	; Subtract the 5 tracks just read
	SUB	A,5
	LD	(TRAK),A	; Store to current track

	LD	HL,M_SAVING
	CALL	MESSAGE
	LD	A,DEST_DISK_SELECTOR
	LD	(CURRENT_DISK_SELECTOR),A
	CALL	SPIN_UP
	CALL	RESET
	CALL	SAVE50		; Save 5 tracks

	POP	BC
	DJNZ	COPY_LOOP

	LD	HL,M_SYS	; "Copy done; press Enter'
	CALL	MSGKEY
	EI
	JP	DOS_NOERROR

RESTOR:
	LD	A,FDC_CMD_RESTORE
	LD	(FDC_COMMAND$),A
	LD	B,6
	DJNZ	$
	LD	HL,FDC_COMMAND$
LOP1	LD	A,(HL)
	BIT	0,A
	JR	NZ,LOP1
	AND	98H
	JP	NZ,ABORT
	RET

; STOUT5: Step the disk head out 5 tracks
STOUT5	LD	B,5
STEP	PUSH	BC
	CALL	STOUT
	POP	BC
	DJNZ	STEP
	RET

; STOUT: Step the disk head out 1 track
STOUT:
	LD	A,FDC_CMD_STEP_OUT
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
LOP2	LD	A,(37ECH)
	BIT	0,A
	JR	NZ,LOP2
	LD	A,(TRAK)
	DEC	A
	LD	(TRAK),A
	RET

LOAD50	LD	B,5
LOP3	PUSH	BC
	XOR	A
	LD	(SECT),A
	CALL	LOAD10
	CALL	STEPIN
	POP	BC
	DJNZ	LOP3
	RET

LOAD10	CALL	LOAD
	LD	A,(SECT)
	INC	A
	LD	(SECT),A
	CP	0AH
	JR	C,LOAD10
	RET

SAVE50	LD	B,5
LOP6	PUSH	BC
	XOR	A
	LD	(SECT),A
	CALL	SAVE10
	CALL	STEPIN
	POP	BC
	DJNZ	LOP6
	RET

SAVE10	CALL	SAVE
	LD	A,(SECT)
	INC	A
	LD	(SECT),A
	CP	0AH
	JR	C,SAVE10
	RET

STEPIN:
	LD	A,40H
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
LOP4	LD	A,(37ECH)
	BIT	0,A
	JR	NZ,LOP4
	LD	A,(TRAK)
	INC	A
	LD	(TRAK),A
	RET

RESET	LD	BC,8300H
	LD	(LDAREA),BC
	RET

LOAD	LD	A,(CURRENT_DISK_SELECTOR)
	LD	(37E1H),A

	LD	A,(SECT)
	CALL	TRANSLATE
	LD	(37EEH),A
	LD	HL,M_READING_2
	CALL	HEX8

	LD	A,(TRAK)
	CALL	TRANSLATE
	LD	(37EDH),A
	LD	HL,M_READING_1
	CALL	HEX8

	LD	HL,M_READING
	CALL	MESS_PR

	LD	BC,(LDAREA)
	LD	HL,37ECH
	LD	DE,37EFH
	LD	(HL),88H
	PUSH	BC
	POP	BC
LOP5	LD	A,(HL)
	BIT	0,A
	JR	Z,LOAD_01
	BIT	1,A
	JR	Z,LOP5
	LD	A,(DE)
	LD	(BC),A
	INC	BC
	JR	LOP5
LOAD_01
	AND	9CH
	JR	NZ,ABORT
	LD	(LDAREA),BC
	RET

ABORT
	LD	HL,M_STATUS_1
	CALL	HEX8
	LD	HL,M_STATUS
	CALL	MESSAGE
	EI
	JP	DOS_NOERROR

SAVE	LD	A,(CURRENT_DISK_SELECTOR)
	LD	(37E1H),A

	LD	A,(SECT)
	CALL	COND_TRANSLATE
	LD	(37EEH),A
	LD	HL,M_WRITING_2
	CALL	HEX8

	LD	A,(TRAK)
	CALL	COND_TRANSLATE
	LD	(37EDH),A
	LD	HL,M_WRITING_1
	CALL	HEX8

	LD	HL,M_WRITING
	CALL	MESS_PR

	LD	BC,(LDAREA)
	LD	HL,37ECH
	LD	DE,37EFH
	LD	(HL),0A8H		; Was 0AAH: Write with 0xFA DAM
	PUSH	BC
	POP	BC
LOP7	LD	A,(HL)
	BIT	0,A
	JR	Z,SAVE_01
	BIT	1,A
	JR	Z,LOP7
	LD	A,(BC)
	LD	(DE),A
	INC	BC
	JR	LOP7
SAVE_01
	AND	9CH
	JR	NZ,ABORT
	LD	(LDAREA),BC
	RET

; TRANSLATE: Convert a track or sector number (in register A) into the
; corresponding number, and return it in register A.
;   A == 0 => 0
;   A > 0  => (129 - 2 * A)
TRANSLATE:
	ADD	A,A
	RET	Z
	CPL
	ADD	A,82H
	RET

; COND_TRANSLATE: Conditionally translate a track or sector number
COND_TRANSLATE:
	PUSH	BC
	LD	B,A			; Save track/sector number
	LD	A,(PROTECTED_DISK)
	OR	A			; Test if protected dest
	LD	A,B			; Restore track/sector number
	POP	BC
	RET	Z
	CALL	TRANSLATE
	RET

; MSGKEY: Print a message (in register HL) then wait for a key to be pressed
MSGKEY	CALL	MESSAGE		; Print a message to the display
	CALL	ROM@WAIT_KEY	; Wait for a key to be pressed
	CP	1
	RET	NZ		; Key pressed was not break
	LD	HL,M_EXIT	; 'Aborting'
	CALL	MESSAGE
	EI
	JP	DOS_NOERROR

; MESSAGE: Print a message to the display, starting in register HL and ending after 0x0d
MESSAGE	LD	A,(HL)
	OR	A
	RET	Z
	CALL	ROM@PUT_VDU
	INC	HL
	CP	0DH
	RET	Z
	JR	MESSAGE

; SET_SINGLE_DENSITY: Sets the PERCOM doubler hardware to use FD1771
SET_SINGLE_DENSITY:
	LD	HL,FDC_COMMAND$
	LD	(HL),0FEH
	RET

; SPIN_UP: Start disk drive spinning
; Args:
;       A       Drive selector

SPIN_UP:
	LD	(FDC_DISK_SELECT$),A
	RET

*GET	HEX

M_LOADING	DEFM	'Loading...',0DH
M_SAVING	DEFM	'Saving...',0DH
M_EXIT		DEFM	'Break hit; aborting',0DH
M_SYS		DEFM	'Copy done; press Enter',0DH

M_STATUS	DEFM	'Controller error status '
M_STATUS_1	DEFM	'xx'
		DEFM	', Aborting',0DH

M_READING	DEFM	'Reading track '
M_READING_1	DEFM	'xx'
		DEFM	' sector '
M_READING_2	DEFM	'xx',0DH

M_WRITING	DEFM	'Writing track '
M_WRITING_1	DEFM	'xx'
		DEFM	' sector '
M_WRITING_2	DEFM	'xx',0DH

SMES	DEFM	'Insert protected Colossal Cave into drive 1 and press Enter',0DH
DMES	DEFM	'Insert formatted diskette into drive 2 and press Enter',0DH

SECT	DEFB	0			; Untranslated sector number
TRAK	DEFB	0			; Untranslated track number
CURRENT_DISK_SELECTOR	DEFB	0		; 1 << drive_number
LDAREA	DEFW	8300H			; Initial and current buffer address

; Set PROTECTED_DISK to 1 to write a copy-protected destination diskette
; (which requires a diskette formatted with translated track and sector
; numbers, using e.g. format2.asm)
PROTECTED_DISK	DEFB	0

	END	START
