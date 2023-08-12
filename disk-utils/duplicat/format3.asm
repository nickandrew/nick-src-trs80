; format3.asm: Special format
; This program writes a 40-track single density diskette with an additional secret sector 128 on each track.

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

	ORG	5200H

FORM3	DI
	CALL	INSERT		; Print "INSERT DESTINATION DISK" and wait for a key to be pressed
	CALL	RESTORE		; Seek to track 0 and wait for controller not busy
	XOR	A
	LD	(TRACK),A	; Initial track zero
FORV01	CALL	BUILD		; Prepare a buffer with the raw track data to be written to the diskette
	CALL	FORMAT		; Format one track with pre-prepared buffer
	CALL	STEPIN		; Step the disk head in 1 track
	LD	A,(TRACK)
	INC	A
	LD	(TRACK),A
	CP	40		; Only formatting 40 tracks on this diskette
	JR	NZ,FORV01
	CALL	SYSDISK		; Print "INSERT SYSTEM DISK" and wait for a key to be pressed
	JP	DOS_NOERROR

; BUILD: Prepare a buffer with the raw track data to be written to the diskette.
; Sector numbers are interleaved according to the translation table in SECTOR.
; Parameters:
;    TRACK      Track number
;    SECTOR     Sector number interleave table
; Variables:
;    BUFFER     3255-byte buffer for raw track formatting data
;    SECTR      Sector number being worked on (before translation)
; Buffer contents: (see FD1771 or WD1771 datasheet for specs)
;    0x000      0xff x 11
;    0x00b      Sector 4 data
;    0x130      Sector 9 data
;    0x255      Sector 0 data
;    0x37a      Sector 5 data
;    0x49f      Sector 1 data
;    0x5c4      Sector 6 data
;    0x6e9      Sector 2 data
;    0x80e      Sector 7 data
;    0x933      Sector 3 data
;    0xa58      Sector 8 data
;    0xb7d      0x00 x 6             This looks like the beginning of a secret sector 128, 16 bytes long
;    0xb83      0xfe                 ID Address Mark
;    0xb84      Track number
;    0xb85      0x00
;    0xb86      0x80                 Sector number 128
;    0xb87      0x01                 Sector length ... 16? (only if bit 'b' on READ command is 0)
;    0xb88      0xf7                 Write 2-byte CRC
;    0xb89      0xff x 11            Gap
;    0xb94      0x00 x 6             Gap
;    0xb9a      0xfb                 Data Address Mark
;    0xb9b      0x00 x 16            Sector data
;    0xbab      0xf7                 Write 2-byte CRC
;    0xbac      0xff x 11
;    0xbb7      0xff x 256
;    0xcb7      size of BUFFER
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
;    0x018      0xfb (Data Address Mark - Options are f8/f9/fa/fb in single density)
;    0x019      0xe5 x 256 (This is the standard single-density bit sequence 11100101)
;    0x119      0xf7 (Write 2-byte CRC)
;    0x11a      0xff x 11
;    0x125      size of per-sector data

BUILD	LD	DE,BUFFER
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
	LD	A,0E5H
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

; INSERT: Print "INSERT DESTINATION DISK" and wait for a key to be pressed
INSERT	LD	HL,M_INS
INSV01	CALL	MESSAGE		; Print a message to the display
	LD	BC,4000H
	CALL	ROM@PAUSE
INSV02	LD	A,(38FFH)	; Wait for a key to be pressed
	OR	A
	JR	Z,INSV02
	RET

; MESSAGE: Print a message to the display, starting in register HL and ending after 0x0d
MESSAGE	LD	A,(HL)
	OR	A
	RET	Z
	CALL	ROM@PUT_VDU
	INC	HL
	CP	0DH
	RET	Z
	JR	MESSAGE

; Print "INSERT SYSTEM DISK" and wait for a key to be pressed
SYSDISK	LD	HL,M_SYS
	JR	INSV01

M_INS	DEFM	'INSERT DESTINATION DISK'
	DEFB	0DH
M_SYS	DEFM	'INSERT SYSTEM DISK'
	DEFB	0DH

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

SPIN	LD	A,1
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

BUFFER	DEFS	0CB7H		; Data buffer for Write Track

	END	FORM3
