; duplic21.asm: Copy Microsoft Adventure from a protected diskette
; A protected diskette is 40 track SSSD with translated track/sector numbers
; (0, 127, 125, 123, 121, ...)
; Usage:
;    DUPLIC21
;      Reads a protected diskette, writes a standard diskette
;    DUPLIC21 /P
;      Reads a protected diskette, writes a protected diskette

*GET	DOSCALLS

; WD1771/FD1771 Floppy Disk Controller registers/commands
$FDC_STATUS			EQU	37ECH	; FDC Status/Command register
$FDC_COMMAND			EQU	37ECH	; FDC Status/Command register
$FDC_TRACK			EQU	37EDH	; FDC Track register
$FDC_SECTOR			EQU	37EEH	; FDC Sector register
$FDC_DATA			EQU	37EFH	; FDC Data register
$FDC_CMD_FORCE_INTERRUPT	EQU	0D0H	; Terminate whatever you're doing
$FDC_CMD_RESTORE		EQU	005H	; Seek to track 0 (slow stepping rate)
$FDC_CMD_STEP_IN		EQU	058H	; Step in (fast stepping rate)
$FDC_CMD_WRITE_TRACK		EQU	0F4H	; Write track


	ORG	8000H
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
	CALL	RESTOR
	DI
SAVER	LD	HL,SMES		; "Insert <SOURCE> DISK..."
	CALL	WTINP		; Print message and wait for return key
	CALL	RESET
	LD	A,143
	LD	(3C04H),A
	CALL	LOAD50
	LD	A,20H
	LD	(3C04H),A
	CALL	STOUT5
	LD	HL,DMES		; "Insert <DESTINATION> DISK..."
	CALL	WTINP		; Print message and wait for return key
	CALL	RESET
	CALL	SAVE50
	JP	SAVER

; Print a message (address in HL) and wait for return key, then spin up disk 0
WTINP	LD	A,(HL)
	CALL	ROM@PUT_VDU
	CP	0DH
	JR	Z,WTOUT
	INC	HL
	JR	WTINP
WTOUT	LD	A,(38FFH)
	OR	A
	JR	NZ,WTOUT
WTKBD	LD	A,(3840H)
	AND	1
	JR	Z,WTKBD
	LD	A,1
	LD	(37E1H),A
	LD	BC,4000H
	CALL	ROM@PAUSE
	RET

RESTOR	LD	A,1
	LD	(37E1H),A
	LD	BC,4000H
	CALL	ROM@PAUSE
	LD	A,0
	LD	(37ECH),A
	LD	B,6
	DJNZ	$
LOP1	LD	A,(37ECH)
	BIT	0,A
	JR	NZ,LOP1
	RET

; STOUT5: Step the disk head out 5 tracks
STOUT5	LD	B,5
STEP	PUSH	BC
	CALL	STOUT
	POP	BC
	DJNZ	STEP
	RET

; STOUT: Step the disk head out 1 track
STOUT	LD	A,1
	LD	(37E1H),A
	LD	B,6
	DJNZ	$
	LD	A,60H
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
	CALL	LOAD10
	POP	BC
	DJNZ	LOP3
	RET

LOAD10	CALL	LOAD
	LD	A,(SECT)
	INC	A
	LD	(SECT),A
	OR	30H
	LD	(3C00H),A
	AND	15
	CP	0AH
	JR	C,LOAD10
	XOR	A
	LD	(SECT),A
	CALL	STEPIN
	RET

STEPIN	LD	A,1
	LD	(37E1H),A
	LD	BC,4000H
	CALL	ROM@PAUSE
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

LOAD	LD	A,1
	LD	(37E1H),A
	LD	BC,1000H
	CALL	ROM@PAUSE
	LD	A,255
	LD	(3C02H),A
	LD	HL,37ECH
	LD	DE,37EFH
	LD	BC,(LDAREA)
	LD	A,(SECT)
	CALL	TRANSLATE
	LD	(37EEH),A
	LD	A,(TRAK)
	CALL	TRANSLATE
	LD	(37EDH),A
	PUSH	BC
	LD	B,6
	DJNZ	$
	LD	(HL),88H
	POP	BC
	PUSH	BC
	POP	BC
LOP5	BIT	1,(HL)
	JR	Z,LOP5
	LD	A,(DE)
	LD	(BC),A
	INC	BC
	LD	A,C
	OR	A
	JR	NZ,LOP5
	LD	(LDAREA),BC
	LD	A,20H
	LD	(3C02H),A
	RET

SAVE50	LD	B,5
LOP6	PUSH	BC
	CALL	SAVE10
	POP	BC
	DJNZ	LOP6
	RET

SAVE10	CALL	SAVE
	LD	A,(SECT)
	INC	A
	LD	(SECT),A
	CP	0AH
	JR	C,SAVE10
	XOR	A
	LD	(SECT),A
	CALL	STEPIN
	RET

SAVE	LD	A,1
	LD	(37E1H),A
	LD	BC,1000H
	CALL	ROM@PAUSE
	LD	HL,37ECH
	LD	DE,37EFH
	LD	BC,(LDAREA)
	LD	A,(SECT)
	CALL	COND_TRANSLATE
	LD	(37EEH),A
	LD	A,(TRAK)
	CALL	COND_TRANSLATE
	LD	(37EDH),A
	PUSH	BC
	LD	B,6
	DJNZ	$
	LD	(HL),0AAH
	POP	BC
	PUSH	BC
	POP	BC
LOP7	BIT	1,(HL)
	JR	Z,LOP7
	LD	A,(BC)
	LD	(DE),A
	INC	BC
	LD	A,C
	OR	A
	JR	NZ,LOP7
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

SMES	DEFM	'INSERT <SOURCE> DISK AND HIT RETURN:'
	DEFB	0DH
DMES	DEFM	'INSERT <DESTINATION> DISK AND HIT RETURN:'
	DEFB	0DH

SECT	DEFB	0			; Untranslated sector number
TRAK	DEFB	0			; Untranslated track number
LDAREA	DEFW	8300H			; Initial and current buffer address

; Set PROTECTED_DISK to 1 to write a copy-protected destination diskette
; (which requires a diskette formatted with translated track and sector
; numbers, using e.g. format2.asm)
PROTECTED_DISK	DEFB	0

	END	START
