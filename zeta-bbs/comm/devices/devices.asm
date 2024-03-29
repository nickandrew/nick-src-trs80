;devices: set up all devices.
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
*GET	RS232
;
STD_DEV	EQU	1
;
	IF	STD_DEV
;$KI	EQU	0FF00H
;$DO	EQU	0FF08H
;$SI	EQU	0FF10H
;$SO	EQU	0FF18H
;$PR	EQU	0FF30H
;$TA	EQU	0FF38H
	ENDIF
;
	COM	'<Devices 2.8  18-Jan-88>'
;
	ORG	BASE+100H
START	LD	SP,START
	LD	HL,(HIMEM)
	LD	A,H
	CP	0FFH
	JR	NZ,HI_OK
	LD	HL,EXTERNALS-1
HI_OK	LD	DE,END_DRIVERS-DRIVERS
	OR	A
	SBC	HL,DE
	LD	(HIMEM),HL
	INC	HL
	PUSH	HL
;Do pre-relocation address offsetting.
	PUSH	HL
	OR	A
	LD	DE,DRIVERS	;old origin
	SBC	HL,DE
	EX	DE,HL
;
	LD	HL,(RELOC1+2)	;its IX!!
	ADD	HL,DE
	LD	(RELOC1+2),HL
;
	LD	HL,(RELOC2+1)
	ADD	HL,DE
	LD	(RELOC2+1),HL
;
	LD	HL,(RELOC3)
	ADD	HL,DE
	LD	(RELOC3),HL
;
	LD	HL,(RELOC4)
	ADD	HL,DE
	LD	(RELOC4),HL
;
	LD	HL,(RELOC5)
	ADD	HL,DE
	LD	(RELOC5),HL
;
	LD	HL,(RELOC6)
	ADD	HL,DE
	LD	(RELOC6),HL
;
	LD	HL,(RELOC7+1)
	ADD	HL,DE
	LD	(RELOC7+1),HL
;
	LD	HL,(RELOC8+1)
	ADD	HL,DE
	LD	(RELOC8+1),HL
;
;;	LD	HL,(RELOC9+1)
;;	ADD	HL,DE
;;	LD	(RELOC9+1),HL
;
;;	LD	HL,(RELOC10+1)
;;	ADD	HL,DE
;;	LD	(RELOC10+1),HL
;
	LD	HL,(RELOC11+1)
	ADD	HL,DE
	LD	(RELOC11+1),HL
;
	LD	HL,(RELOC12+1)
	ADD	HL,DE
	LD	(RELOC12+1),HL
;
	LD	HL,(RELOC13+1)
	ADD	HL,DE
	LD	(RELOC13+1),HL
;
	LD	HL,(RELOC14+1)
	ADD	HL,DE
	LD	(RELOC14+1),HL
;
	LD	HL,(RELOC15+1)
	ADD	HL,DE
	LD	(RELOC15+1),HL
;
	LD	HL,(RELOC16+1)
	ADD	HL,DE
	LD	(RELOC16+1),HL
;
	LD	HL,(RELOC17+1)
	ADD	HL,DE
	LD	(RELOC17+1),HL
;
	LD	HL,(RELOC18+1)
	ADD	HL,DE
	LD	(RELOC18+1),HL
;
	LD	HL,(RELOC19+1)
	ADD	HL,DE
	LD	(RELOC19+1),HL
;
	LD	HL,(RELOC20+1)
	ADD	HL,DE
	LD	(RELOC20+1),HL
;
	LD	HL,(RELOC21+1)
	ADD	HL,DE
	LD	(RELOC21+1),HL
;
	LD	HL,(RELOC22+1)
	ADD	HL,DE
	LD	(RELOC22+1),HL
;
	LD	HL,(RELOC23+1)
	ADD	HL,DE
	LD	(RELOC23+1),HL
;
	LD	HL,(RELOC24+1)
	ADD	HL,DE
	LD	(RELOC24+1),HL
;
	LD	HL,(RELOC25+1)
	ADD	HL,DE
	LD	(RELOC25+1),HL
;
	LD	HL,(RELOC26+1)
	ADD	HL,DE
	LD	(RELOC26+1),HL
;
	LD	HL,(RELOC27+1)
	ADD	HL,DE
	LD	(RELOC27+1),HL
;
	LD	HL,(RELOC28+1)
	ADD	HL,DE
	LD	(RELOC28+1),HL
;
	LD	HL,(RELOC29+1)
	ADD	HL,DE
	LD	(RELOC29+1),HL
;
	LD	HL,(RELOC30+1)
	ADD	HL,DE
	LD	(RELOC30+1),HL
;
	LD	HL,(RELOC31+1)
	ADD	HL,DE
	LD	(RELOC31+1),HL
;
	LD	HL,(RELOC32+1)
	ADD	HL,DE
	LD	(RELOC32+1),HL
;
	LD	HL,(RELOC33+1)
	ADD	HL,DE
	LD	(RELOC33+1),HL
;
	LD	HL,(RELOC34+1)
	ADD	HL,DE
	LD	(RELOC34+1),HL
;
	LD	HL,(RELOC35+1)
	ADD	HL,DE
	LD	(RELOC35+1),HL
;
	LD	HL,(RELOC36+1)
	ADD	HL,DE
	LD	(RELOC36+1),HL
;
	LD	HL,(RELOC37+1)
	ADD	HL,DE
	LD	(RELOC37+1),HL
;
	LD	HL,(RELOC38+1)
	ADD	HL,DE
	LD	(RELOC38+1),HL
;
	LD	HL,(RELOC39+1)
	ADD	HL,DE
	LD	(RELOC39+1),HL
;
	LD	HL,(RELOC40+1)
	ADD	HL,DE
	LD	(RELOC40+1),HL
;
;End of relocating
	POP	DE
	LD	HL,DRIVERS
	LD	BC,END_DRIVERS-DRIVERS
	LDIR				;move in drivers
	LD	HL,DCBS
	LD	DE,$KI			;addr 1st driver
	LD	BC,8*8			;8 devices
	LDIR
	POP	DE
;Post-relocation address manipulation.
	LD	HL,DEV_KI-DRIVERS
	ADD	HL,DE
;move in next address for each driver.
	LD	($KI+1),HL
	LD	HL,DEV_DO-DRIVERS
	ADD	HL,DE
	LD	($DO+1),HL
	LD	HL,DEV_SI-DRIVERS
	ADD	HL,DE
	LD	($SI+1),HL
	LD	HL,DEV_SO-DRIVERS
	ADD	HL,DE
	LD	($SO+1),HL
	LD	HL,DEV_2-DRIVERS	;Was 2I
	ADD	HL,DE
	LD	(DCB_2I+1),HL
	LD	HL,DEV_2-DRIVERS	;Was 2O
	ADD	HL,DE
	LD	(DCB_2O+1),HL
;
	LD	HL,SERINP-DRIVERS
	ADD	HL,DE
	LD	A,0C3H
	LD	(SER_INP),A
	LD	(SER_INP+1),HL
;
;;	XOR	A
;;	LD	($TA+3),A
;;	LD	($TA+4),A
;
;Setup SER_OUT Serial Output.
	LD	A,0C3H
	LD	(SER_OUT),A
	LD	HL,SEROUT-DRIVERS
	ADD	HL,DE
	LD	(SER_OUT+1),HL
;
;Setup output mode
	LD	A,OM_COOKED
	LD	(OUTPUT_MODE),A
;
; finished setting up stuff
;now initialise devices.
	LD	A,82H
	OUT	(WRSTAT),A
	LD	A,40H
	OUT	(WRSTAT),A
	LD	A,4FH		;300,8,n,1
	OUT	(WRSTAT),A
	LD	(MODEM_STAT1),A
	LD	A,05H		;Tx,Rx,No Dtr, No Rts
	OUT	(WRSTAT),A
	LD	(MODEM_STAT2),A
;
	JP	DOS_NOERROR
;
;Here are the DCBs for the devices.
;
DCBS
;1st byte is capability - B0=Input, B1=Output, B2=Control
;Standard KBD driver
	DEFB	1,0,0,0,0,0,'KI'
;Standard VDU driver
	DEFB	2,0,0		;All funny stuff unused!
	DEFW	3C00H		;cursor posn.
	DEFB	0,'DO'
;RS-232 input
	DEFB	1,0,0,1,0,0,'SI'
;RS-232 output
	DEFB	2,0,0
	DEFB	0,0
	DEFB	0,'SO'
;Dual KI/SI input	(input & output)
	DEFB	3,0,0,0,0,0,'2I'
;Dual DO/SO output	(input & output)
	DEFB	3,0,0,0,0,0,'2O'
;Printer output (no longer used, called XX)
	DEFB	0,0,0,0,0,0,'XX'
;Type-Ahead buffer device. Outdated!
	DEFB	7,0,0,0,0,0,'TA'
;End of device dcb string.
;
DRIVERS
;
;DEV_2: Input/Output dual driver entry point for DCB_2O and DCB_2I
DEV_2	JR	C,DEV_2I
	JR	DEV_2O
;
;Dual $DO and $SO output driver.
DEV_2O	LD	A,C
	PUSH	BC
	LD	DE,$DO
	CALL	ROM@PUT
	POP	BC
;;	RET	NZ
	LD	A,(SYS_STAT)
	BIT	SYS_TEST,A
	JR	NZ,NO_2SO
	LD	A,C
	LD	DE,$SO
	CALL	ROM@PUT
	RET
;
NO_2SO
	LD	BC,310H
	CALL	ROM@PAUSE
	CP	A
	RET
;
;Dual $KI and $SI input driver.
DEV_2I
	LD	DE,$KI
	CALL	ROM@GET		;first keyboard.
	OR	A
	JR	NZ,D2I_KEY
	LD	A,(SYS_STAT)
	BIT	SYS_TEST,A
	JR	NZ,NO_2SI
	LD	DE,$SI
	CALL	ROM@GET		;then serial.
	CP	A
	RET
;
D2I_KEY
;Silence the serial port for a while.
	PUSH	AF
	LD	A,30		;=0.75 second
	LD	(SER_OVRRIDE),A
	LD	A,(F_XOFF)
	RES	1,A
	LD	(F_XOFF),A
	POP	AF
	CP	A
	RET
;
NO_2SI
	XOR	A
	RET
;
;---------------------------------------
DEV_KI
RELOC18	CALL	KEY_GET_BUFFER
	OR	A
	RET	NZ
RELOC17	CALL	RAW_KI
	RET
;
RAW_KI
	CALL	4516H
;
	OR	A
	RET	Z
	CP	1BH
	JR	Z,KI_ABORT
;Check for ^S
	CP	XOFF		;^S
	JR	Z,KI_CTL_S
	CP	A
	RET
KI_CTL_S
	LD	A,(F_XOFF)
	SET	1,A
	LD	(F_XOFF),A
	XOR	A
	RET
;
KI_ABORT
	LD	HL,(ABORT)
	LD	A,H
	OR	L
	RET	Z
	LD	A,(F_XOFF)
	RES	1,A
	LD	(F_XOFF),A
	JP	(HL)
;
;
;-------------------------------
DEV_DO
	LD	A,C
	PUSH	AF
RELOC7	LD	HL,VDU_CRTAB
	CP	CR
	JR	Z,VDU_XLATE
	CP	LF
	JR	NZ,DEV_DO_OUT
RELOC40	LD	HL,VDU_LFTAB
VDU_XLATE
	LD	A,(OUTPUT_MODE)
	LD	E,A
	LD	D,0
	ADD	HL,DE
	LD	C,(HL)
DEV_DO_OUT
	POP	AF
	LD	IX,DCB_VDU$		;Use $VDU cursor.
	CALL	4505H		;NEWDOS DEPENDANT!!
;
	LD	A,(F_XOFF)	;XOFF flag
	BIT	1,A
	JR	NZ,DO_IS_CTLS
;
RELOC19	CALL	RAW_KI
	OR	A
	JR	NZ,DO_HANDLE_INPUT
;
	LD	A,(F_XOFF)
	BIT	1,A
	JR	NZ,DO_IS_CTLS
	XOR	A
	RET
;
DO_HANDLE_INPUT
;;	CP	XOFF
;;	JR	Z,DO_IS_CTLS
	LD	C,A
RELOC12	CALL	KEY_PUT_BUFFER
	XOR	A
	RET
;
DO_IS_CTLS
	XOR	A
	LD	(F_XOFF),A
	LD	A,'^'
	LD	(3C3EH),A
	LD	A,'s'
	LD	(3C3FH),A
	XOR	A			;zero type-ahead
RELOC13	LD	(KEY_TA_1),A
RELOC28	LD	(KEY_TA_2),A
;
;wait for ctrl-Q or CR hit.
KEY_WAIT_Q
RELOC27	CALL	RAW_KI
	OR	A
	JR	Z,KEY_WAIT_Q
;
KEY_WQ_2
	CP	CR
	JR	Z,KEY_WQ_3
	CP	XON			;^Q
	JR	NZ,KEY_WAIT_Q
KEY_WQ_3
	LD	A,' '		;erase ^S
	LD	(3C3EH),A
	LD	(3C3FH),A
	LD	HL,F_XOFF
	RES	1,(HL)
	RET
;
VDU_CRTAB	DEFB	'?',CR,CR,1DH,1DH
VDU_LFTAB	DEFB	'?',LF,1DH,1AH,CR
;
KEY_PUT_BUFFER			;To type-ahead
RELOC14	LD	A,(KEY_TA_2)
	INC	A
	AND	15
	LD	B,A
RELOC15	LD	A,(KEY_TA_1)
	CP	B
RELOC25	JP	Z,RET_NZ	;if buffer full.
	LD	A,B
RELOC16	LD	(KEY_TA_2),A
	DEC	A
	AND	15
	LD	E,A
	LD	D,0
RELOC29	LD	HL,KEY_TA
	ADD	HL,DE
	LD	(HL),C
	XOR	A
	RET
;
KEY_GET_BUFFER
RELOC20	LD	A,(KEY_TA_1)
	LD	B,A
RELOC21	LD	A,(KEY_TA_2)
	CP	B
	LD	A,0
RELOC26	JP	Z,RET_NZ	;if empty.
	LD	E,B
	LD	D,0
RELOC22	LD	HL,KEY_TA
	ADD	HL,DE
	LD	C,(HL)
	LD	A,B
	INC	A
	AND	15
RELOC23	LD	(KEY_TA_1),A
	XOR	A
	LD	A,C
	RET
;
;---------------------------------------
DEV_SO
	LD	A,(OUTPUT_MODE)
	CP	OM_RAW
	LD	A,C
	JR	Z,_ASIS
;
	CP	10H
	JR	NC,_ASIS
	LD	HL,TFLAG2
;
	CP	BELL
	JR	NZ,_NS1
	LD	A,(HL)
	BIT	TF_BELL,A
	JR	Z,_NSX
	LD	A,C			;bell
	JR	_ASIS
;
_NS1	CP	BS
	JR	NZ,_NS2
	LD	A,(HL)
	BIT	TF_BS,A
	LD	A,C			;bs
	JR	Z,_ASIS
	CALL	SER_OUT
	LD	A,' '
	CALL	SER_OUT
	LD	A,BS
	JR	_ASIS
;
_NS2	CP	CR
	JR	NZ,_NS2A
	LD	A,(OUTPUT_MODE)
	CP	OM_COOKED
	JR	Z,SER_CRLF
	LD	A,CR
	JR	_ASIS
SER_CRLF
	LD	A,CR
	CALL	SER_OUT
	LD	A,LF
	JR	_ASIS
;
_NS2A	CP	LF		;Convert linefeeds
	JR	NZ,_NS3
	LD	A,(OUTPUT_MODE)
	CP	OM_UNIX
	JR	Z,SER_CRLF
	CP	OM_DISPLAY
	LD	A,C		;lf
	JR	Z,_ASIS
	LD	A,CR
	JR	_ASIS
;
_NS3	CP	0EH			;cursor on
	JR	NZ,_NS4
	LD	A,(HL)
	BIT	TF_CURSOR,A
	LD	A,C
	CALL	Z,SER_OUT
;;	LD	A,(HL)
;;	BIT	TF_BELL,A
;;	LD	A,BELL
;;	JR	NZ,_ASIS
	JR	_NSX
;
_NS4	CP	0FH			;cursor off
	JR	NZ,_ASIS
	LD	A,(HL)
	BIT	TF_CURSOR,A
	LD	A,C			;=0fh
	JR	NZ,_NSX
_ASIS	CALL	SER_OUT
_NSX
;
	LD	A,(F_XOFF)
	BIT	0,A
	JR	NZ,IS_CTLS	;was handle_input
;
	CALL	SER_INP
	OR	A
	JR	NZ,HANDLE_INPUT
;
	LD	A,(F_XOFF)
	BIT	0,A
	JR	NZ,IS_CTLS	;was handle_input
;
	XOR	A
	RET
;
HANDLE_INPUT
	CP	XOFF			;ctrl-S
	JR	Z,IS_CTLS
	LD	C,A
RELOC8	CALL	MDM_PUT_BUFFER
	XOR	A
	RET
;
IS_CTLS
	XOR	A
	LD	(F_XOFF),A
	LD	A,'^'
	LD	(3C3EH),A
	LD	A,'S'
	LD	(3C3FH),A
	XOR	A			;zero type-ahead
RELOC30	LD	(MDM_TA_1),A
RELOC31	LD	(MDM_TA_2),A
;
;wait for ctrl-Q or CR hit.
WAIT_Q
;;	LD	DE,$KI
;;	CALL	ROM@GET
;;	OR	A
;;	JR	NZ,WQ_2
	CALL	SER_INP
	OR	A
	JR	Z,WAIT_Q
WQ_2	CP	CR
	JR	Z,WQ_3
	CP	XON			;^Q
	JR	NZ,WAIT_Q
WQ_3	LD	A,' '		;erase ^S
	LD	(3C3EH),A
	LD	(3C3FH),A
	XOR	A
	LD	(F_XOFF),A	;Make sure.
	RET
;
RET_NZ	OR	A
	RET	NZ
	CP	1
	RET
;
;-------------------------------
MDM_PUT_BUFFER			;To type-ahead
RELOC32	LD	A,(MDM_TA_2)
	INC	A
	AND	15
	LD	B,A
RELOC33	LD	A,(MDM_TA_1)
	CP	B
	JR	Z,RET_NZ	;if buffer full.
	LD	A,B
RELOC34	LD	(MDM_TA_2),A
	DEC	A
	AND	15
	LD	E,A
	LD	D,0
RELOC35	LD	HL,MDM_TA
	ADD	HL,DE
	LD	(HL),C
	XOR	A
	RET
;
MDM_GET_BUFFER
RELOC36	LD	A,(MDM_TA_1)
	LD	B,A
RELOC37	LD	A,(MDM_TA_2)
	CP	B
	LD	A,0
	JR	Z,RET_NZ	;if empty.
	LD	E,B
	LD	D,0
RELOC38	LD	HL,MDM_TA
	ADD	HL,DE
	LD	C,(HL)
	LD	A,B
	INC	A
	AND	15
RELOC39	LD	(MDM_TA_1),A
	XOR	A
	LD	A,C
	RET
;
SEROUT				;Serial output subroutine
	PUSH	HL
	LD	HL,CD_STAT
	LD	C,A
SOPU_1	BIT	CDS_DISCON,(HL)
	JR	NZ,DSO_DISC
	IN	A,(RDSTAT)
	BIT	CTS_BIT,A
	JR	Z,SOPU_1
	LD	A,C
	OUT	(WRDATA),A
	POP	HL
	XOR	A
	RET
;
DSO_DISC			;On disconnect.
	LD	HL,(DISCON)
	LD	A,H
	OR	L
	POP	HL
	RET	Z		;Ignore - return 0
	LD	HL,(DISCON)
	JP	(HL)
;
;-------------------------------
DEV_SI
RELOC11	CALL	MDM_GET_BUFFER
	OR	A
	RET	NZ
RELOC24	CALL	SERINP
	RET
;
;-------------------------------
SERINP
	LD	HL,CD_STAT
	BIT	CDS_DISCON,(HL)
	JR	Z,N_SINP_DISC
	LD	HL,(DISCON)	;Disconnect place.
	LD	A,H
	OR	L
	RET	Z		;Ignore
	JP	(HL)
;
N_SINP_DISC
;check if serial input has been overridden.
	LD	A,(SER_OVRRIDE)
	OR	A
	JR	Z,NO_ORIDE
;else attempt to decrement it.
	LD	HL,SER_TICKER
	LD	A,(TICKER)
	CP	(HL)
	LD	A,0
	RET	Z
	LD	A,(TICKER)
	LD	(HL),A
	LD	HL,SER_OVRRIDE
	DEC	(HL)
	LD	A,0
	CP	A
	RET
;
NO_ORIDE			;no override delays
	IN	A,(RDSTAT)
	BIT	DAV_BIT,A
	LD	A,0
	RET	Z
	IN	A,(RDDATA)
	LD	C,A
	LD	A,(OUTPUT_MODE)
	CP	OM_RAW
	LD	A,C
	RET	Z
	AND	07FH			;Take off parity
	LD	C,A
;
	CP	LF
	JR	Z,NO_CHAR_SINP
	CP	19H			;^Y alias 23d
	JR	Z,NO_CHAR_SINP
	CP	1FH
	JR	NZ,ITEST_01
NO_CHAR_SINP
	LD	A,0			;null
	JR	DSI_2A
ITEST_01
	CP	ETX		;change ^C to ^A
	JR	NZ,ITEST_02
	LD	A,1
	JR	DSI_2C
ITEST_02
	CP	7FH		;change DEL to ^H
	JR	NZ,ITEST_03
	LD	A,BS		;to backspace
	JR	DSI_2C
ITEST_03
	CP	0BH		;^K and ESC to abort.
	JR	Z,DSI_2B
DSI_2A	CP	1BH
	JR	NZ,DSI_2C
DSI_2B	LD	HL,(ABORT)
	LD	A,H
	OR	L
	RET	Z
	XOR	A
	LD	(F_XOFF),A
	JP	(HL)
;
DSI_2C
	CP	XOFF		;^S
	JR	NZ,DSI_2D
;
	LD	HL,F_XOFF
	SET	0,(HL)
	XOR	A
	RET
;
DSI_2D
	LD	HL,F_XOFF
	RES	0,(HL)
;This code checks if a visitor typed a rude word
	LD	(SER_CHAR),A	;Store char
	LD	A,(PRIV_2)
	BIT	IS_VISITOR,A
	JR	NZ,DSI_3
	LD	A,(SER_CHAR)
	CP	A
	RET
;
DSI_3
	LD	A,(SER_CHAR)
	CP	BS
	JR	NZ,DSI_3A
;backspace. zero last (decrement). next already 0.
	LD	A,(CIRC_LOCN)
	DEC	A
	AND	0FH
	LD	(CIRC_LOCN),A
	LD	HL,CIRC_BUFF
	ADD	A,L
	LD	L,A
	LD	(HL),0
	LD	A,BS		;was bs to start with!
	CP	A
	RET
DSI_3A	LD	A,(CIRC_LOCN)
	LD	HL,CIRC_BUFF
	LD	C,L
	ADD	A,L
	LD	L,A		;Current locn
	LD	A,(SER_CHAR)
	AND	5FH
	LD	(HL),A		;Store char
	LD	B,A
	LD	A,(CIRC_LOCN)
	INC	A
	AND	0FH
	LD	(CIRC_LOCN),A
	ADD	A,C
	LD	L,A
	LD	(HL),0		;Zero end buffer
RELOC1	LD	IX,RUDE_TABLE
DSI_4	LD	E,(IX)
	LD	D,(IX+1)
	INC	IX
	INC	IX
	LD	A,D
	OR	E
	JR	NZ,DSI_5
	LD	A,(SER_CHAR)	;End of table.
	CP	A
	RET
;
DSI_5	LD	A,(DE)
	CP	B
	JR	NZ,DSI_4
	LD	HL,CIRC_BUFF
	LD	A,(CIRC_LOCN)
	ADD	A,L
	LD	L,A
;
DSI_6	DEC	L		;Step back
	LD	A,L
	AND	0FH
	OR	CIRC_BUFF.AND.0F0H
	LD	L,A
	LD	A,(HL)
	OR	A
	JR	Z,DSI_4		;end of buffer
	JR	DSI_7
;
DSI_7	LD	A,(DE)
	CP	(HL)
	JR	NZ,DSI_4
	INC	DE
	LD	A,(DE)
	OR	A
	JR	NZ,DSI_6	;if not Eos.
;Haha - a very rude person (most likely anyway).
;or perhaps they typed MISSHIT. oh well...
RELOC2	LD	HL,M_RUDE
	CALL	LOG_MSG
	LD	A,1
	LD	(RUDE_DISC),A
;Save the screen to the log file.
	LD	A,CR
	LD	(3FFEH),A	;cr at end,
	XOR	A
	LD	(3FFFH),A	;NULL at end of msg!
	LD	HL,3C00H
	CALL	LOG_MSG		;log the screen.
	JP	USR_LOGOUT	;bye bye fool!!!
;
M_RUDE	DEFM	'*** Rude user - disconnected ***',CR,0
;
RUDE_TABLE
RELOC3	DEFW	RUDE_1
RELOC4	DEFW	RUDE_2
RELOC5	DEFW	RUDE_3
RELOC6	DEFW	RUDE_4
	DEFW	0		;end of table
;
RUDE_1	DEFM	'KCUF',0
RUDE_2	DEFM	'TIHS',0
RUDE_3	DEFM	' KCOC ',0
RUDE_4	DEFM	'SSIP',0
;End of rude words.
;
;Keyboard type-ahead buffer.
KEY_TA	DC	16,0		;16 bytes long.
KEY_TA_1	DEFB	0	;out pointer
KEY_TA_2	DEFB	0	;in pointer
;
MDM_TA	DC	16,0		;Modem type-ahead
MDM_TA_1	DEFB	0	;out pointer
MDM_TA_2	DEFB	0	;in pointer
END_DRIVERS
;
	END	START
