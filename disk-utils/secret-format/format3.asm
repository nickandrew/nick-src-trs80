; format3.asm: Secret format
; This program writes a 40-track single density diskette with an additional secret sector 128 on each track.
; * Formats drive 1

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

$DRIVE_SELECTOR			EQU	2	; 1 << drive_number

	ORG	5200H

FORM3	DI
	LD	HL,M_INTRO
	CALL	MESSAGE

	LD	HL,M_INS	; "INSERT DESTINATION DISK"
	CALL	MSGKEY		; Print a message (in register HL) then wait for a key to be pressed
	CALL	SET_SINGLE_DENSITY
	CALL	RESTORE		; Seek to track 0 and wait for controller not busy
	XOR	A
	LD	(TRACK),A	; Initial track zero
FORV01
	LD	HL,BUFFER	; Clear 8k of the format buffer so garbage won't be written to disk
	LD	DE,BUFFER+1
	XOR	A
	LD	(HL),A
	LD	BC,8191
	LDIR

	LD	DE,BUFFER
	CALL	BUILD		; Prepare a buffer with the raw track data to be written to the diskette

	LD	DE,BUFFER	; Fill in buffer start address in message
	LD	HL,M_BUFFER_1
	CALL	HEX16

	CALL	FORMAT		; Format one track with pre-prepared buffer

	LD	HL,M_BUFFER_2	; Fill in buffer end address in message
	CALL	HEX16
	LD	HL,M_BUFFER_START
	CALL	MESSAGE		; Display the buffer start and end addresses


	CALL	STEPIN		; Step the disk head in 1 track
	LD	A,(TRACK)
	INC	A
	LD	(TRACK),A
	CP	40		; Only formatting 40 tracks on this diskette
	JR	NZ,FORV01
	LD	HL,M_SYS	; "INSERT SYSTEM DISK"
	CALL	MSGKEY		; Print a message (in register HL) then wait for a key to be pressed
	JP	DOS_NOERROR

; BUILD: Prepare a buffer with the raw track data to be written to the diskette.
; Sector numbers are interleaved according to the translation table in SECTOR.
; Parameters:
;    DE         Starting buffer address
;    TRACK      Track number
;    SECTOR     Sector number interleave table
; Variables:
;    SECTR      Sector number being worked on (before translation)
; Returns:
;    DE         First address beyond end of buffer
; Buffer contents: (see FD1771 or WD1771 datasheet for specs)
;    0x000      0xff x 11
;    0x00b      Sector 4 data
;    0x135      Sector 9 data
;    0x25f      Sector 0 data
;    0x389      Sector 5 data
;    0x4b3      Sector 1 data
;    0x5dd      Sector 6 data
;    0x707      Sector 2 data
;    0x831      Sector 7 data
;    0x95b      Sector 3 data
;    0xa85      Sector 8 data
;    0xbaf      0x00 x 6             The beginning of a secret sector 128, 16 bytes long
;    0xbb5      0xfe                 ID Address Mark
;    0xbb6      Track number
;    0xbb7      0x00
;    0xbb8      0x80                 Sector number 128
;    0xbb9      0x01                 Sector length ... 16? (only if bit 'b' on READ command is 0)
;    0xbba      0xf7                 Write 2-byte CRC
;    0xbbb      0xff x 11            Gap
;    0xbc6      0x00 x 6             Gap
;    0xbcc      0xfb                 Data Address Mark
;    0xbcd      0x00 x 16            Sector data
;    0xbdd      0xf7                 Write 2-byte CRC
;    0xbde      0xff x 11
;    0xbe9      0xff x 256
;    0xce9      size of BUFFER
;
; Per-sector data:
;    0x000      0x00 x 6
;    0x006      0xfe (ID Address Mark)
;    0x007      Track number (from TRACK)
;    0x008      0x00
;    0x009      Translated sector number
;    0x00a      0x01 (Sector length: 0x01 == 256)
;    0x00b      0xf7 (Write 2-byte CRC)
;    0x00c      0xff x 11
;    0x017      0x00 x 6
;    0x01d      0xfb (Data Address Mark - Options are f8/f9/fa/fb in single density)
;    0x01e      0xe5 x 256 (This is the standard single-density bit sequence 11100101)
;    0x11e      0xf7 (Write 2-byte CRC)
;    0x11f      0xff x 11
;    0x12a      size of per-sector data

BUILD
	LD	B,11
	CALL	POKFF
	XOR	A
	LD	(SECTR),A
SECTOR	LD	B,6
	CALL	POK00
	LD	A,0FEH
	LD	(DE),A
	INC	DE
	LD	A,(TRACK)
	LD	(DE),A
	INC	DE
	XOR	A
	LD	(DE),A
	INC	DE
	LD	A,(SECTR)	; Lookup SECTR in the interleave table
	LD	C,A
	LD	B,0
	LD	HL,STABLE
	ADD	HL,BC
	LD	A,(HL)		; Translated sector number
	LD	(DE),A
	INC	DE
	LD	A,1
	LD	(DE),A
	INC	DE
	LD	A,0F7H
	LD	(DE),A
	INC	DE
	LD	B,11
	CALL	POKFF
	LD	B,6
	CALL	POK00
	LD	A,0FBH
	LD	(DE),A
	INC	DE
	LD	A,0E1H		; Write 0xe1 bytes into the sector, just to be different
	LD	B,0
	CALL	POKDE
	LD	A,0F7H
	LD	(DE),A
	INC	DE
	LD	B,11
	CALL	POKFF
	LD	A,(SECTR)
	INC	A
	LD	(SECTR),A
	CP	10
	JR	NZ,SECTOR	; Repeat for each sector
	LD	B,6
	CALL	POK00
	LD	A,0FEH
	LD	(DE),A
	INC	DE
	LD	A,(TRACK)
	LD	(DE),A
	INC	DE
	XOR	A
	LD	(DE),A
	INC	DE
	LD	A,128
	LD	(DE),A
	INC	DE
	LD	A,1
	LD	(DE),A
	INC	DE
	LD	A,0F7H
	LD	(DE),A
	INC	DE
	LD	B,11
	CALL	POKFF
	LD	B,6
	CALL	POK00
	LD	A,0FBH
	LD	(DE),A
	INC	DE
	LD	B,16
	CALL	POK00
	LD	A,0F7H
	LD	(DE),A
	INC	DE
	LD	B,11
	CALL	POKFF
	LD	B,0
	CALL	POKFF
	RET

; POKDE: Write the value in register A to the buffer at DE. Repeat register B times (0 means 256), incrementing DE
; POK00: Write 0x00 to the buffer at DE. Repeat register B times (0 means 256), incrementing DE
; POKFF: Write 0xFF to the buffer at DE. Repeat register B times (0 means 256), incrementing DE
POKDE	LD	(DE),A
	INC	DE
	DJNZ	POKDE
	RET
POK00	XOR	A
	JR	POKDE
POKFF	LD	A,0FFH
	JR	POKDE

; MSGKEY: Print a message (in register HL) then wait for a key to be pressed
MSGKEY	CALL	MESSAGE		; Print a message to the display
	LD	BC,4000H
	CALL	ROM@PAUSE
	CALL	ROM@WAIT_KEY	; Wait for a key to be pressed
	CP	1
	RET	NZ		; Key pressed was not break
	LD	HL,M_EXIT	; 'Aborting'
	CALL	MESSAGE
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
SET_SINGLE_DENSITY
	LD	HL,$FDC_COMMAND
	LD	(HL),0FEH
	RET

; RESTORE: Seek to track 0 and wait for controller not busy
RESTORE	LD	HL,$FDC_COMMAND
	LD	(HL),$FDC_CMD_FORCE_INTERRUPT
	CALL	DELAY0
	CALL	SPIN
	LD	BC,2000H
	CALL	ROM@PAUSE
	LD	(HL),$FDC_CMD_RESTORE
	CALL	DELAY0
RESV01	LD	A,(HL)
	AND	1
	JR	NZ,RESV01
	RET

; DELAY0: Delay a moment.
; For B == 10 ... takes 9 x 13 T-states + 8 T-states: 70 uS at 1.77 MHz
DELAY0	PUSH	BC
	LD	B,10
	DJNZ	$
	POP	BC
	RET

; SPIN: Start disk drive 2 spinning
SPIN	LD	A,$DRIVE_SELECTOR
	LD	(37E0H),A
	RET

; STEPIN: Step the disk head in 1 track
STEPIN	LD	HL,$FDC_COMMAND
	LD	(HL),$FDC_CMD_FORCE_INTERRUPT
	CALL	DELAY0
	CALL	SPIN
	LD	(HL),$FDC_CMD_STEP_IN
	CALL	DELAY0
STEV01	LD	A,(HL)
	AND	1		; Wait for controller non-busy
	JR	NZ,STEV01
	RET

; FORMAT: Format one track with pre-prepared buffer.
; If the track is longer than the buffer, will write random garbage from memory until the track ends
; Parameters:
;    BUFFER     3255-byte buffer for raw track formatting data
FORMAT	LD	HL,$FDC_COMMAND
	LD	(HL),$FDC_CMD_FORCE_INTERRUPT
	CALL	DELAY0
	LD	DE,BUFFER
	LD	(HL),$FDC_CMD_WRITE_TRACK
	CALL	DELAY0
FORMV01	LD	A,(HL)
	AND	1			; Test BUSY; it will go zero when the controller is finished writing the track
	RET	Z
	BIT	1,(HL)			; Test DRQ; is the controller ready for another byte of data?
	JR	Z,FORMV01
	LD	A,(DE)
	LD	($FDC_DATA),A
	INC	DE
	JR	FORMV01

; Get common code
*GET	HEX

M_INTRO	DEFM	'Secret Format. Formats a diskette with a secret sector 128'
	DEFB	0DH

M_EXIT	DEFM	'Break hit; aborting'
	DEFB	0DH

; Change this message if $DRIVE_SELECTOR is changed
M_INS	DEFM	'Insert diskette to be formatted in drive 1 and press Enter'
	DEFB	0DH
M_SYS	DEFM	'Format done; press Enter'
	DEFB	0DH

M_BUFFER_START	DEFM	'Buffer addresses from '
M_BUFFER_1	DEFB	'xxxx'
		DEFM	' to '
M_BUFFER_2	DEFB	'xxxx'
	DEFB	0DH

TRACK	DEFB	0
SECTR	DEFB	0
STABLE	DEFB	4
	DEFB	9
	DEFB	0
	DEFB	5
	DEFB	1
	DEFB	6
	DEFB	2
	DEFB	7
	DEFB	3
	DEFB	8

BUFFER	DEFS	0CB7H		; Data buffer for Write Track

	END	FORM3
