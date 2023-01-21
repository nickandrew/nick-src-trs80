;external.asm: definitions for external constants
;and high memory locations.
;last modified 31-Dec-88.
;
*LIST	OFF
;
MAX_LOWMEM	EQU	0B400H
;
;First 256 bytes of externals follow.....
ALLOC_PAGE	EQU	0FE00H	;C- allocate a page # (See special.asm)
FREE_PAGE	EQU	0FE03H	;C- unalloc a page (See special.asm)
SWAP_PAGE	EQU	0FE06H	;C- swap a page in. (See special.asm)
PROCESS		EQU	0FE09H	;B- Current process #
;;BRK		EQU	0FE0AH	;C- Set top of addr space
SYS_CALL	EQU	0FE0DH	;C- Any system call
;
;
;Device equates. Initialised by zeta-bbs/comm/devices/devices.asm
$KI	EQU	0FF00H		;8- keyboard
$DO	EQU	0FF08H		;8- display
$SI	EQU	0FF10H		;8- serial in
$SO	EQU	0FF18H		;8- serial out
DCB_2I	EQU	0FF20H		;8- keyboard OR serial in (equivalent to DCB_2O)
DCB_2O	EQU	0FF28H		;8- Screen AND serial out (equivalent to DCB_2I)
;;$PR	EQU	0FF30H		;8- printer OR screen
;;$TA	EQU	0FF38H		;8- type-ahead.
;
;Standard devices
$KBD	EQU	4015H		;Kbd device driver
$VDU	EQU	401DH		;VDU device driver
;
;Rom / Dos System calls.
$CTL	EQU	0023H		;device control
;
;High Memory ZETA System calls and data
LOST_CARRIER	EQU	0FF40H	;J- Lost Carrier (See special.asm)
IO_TIMEOUT	EQU	0FF43H	;J- Timeout. (See special.asm)
CARR_DETECT	EQU	0FF46H	;C- Chk Carrier (See special.asm)
TEL_HANGUP	EQU	0FF49H	;C- Hang up. (See special.asm)
TEL_PICKUP	EQU	0FF4CH	;C- Pick up. (See special.asm)
SER_CHAR	EQU	0FF4FH	;B- Last char typed
INPUT_BUFFER	EQU	0FF50H	;16- Buff for $TA
;Replace chars_sent & chars_recvd by these:
MEM_OWNER	EQU	0FF60H	;W- addr page owners (See special.asm)
MEM_TABLE	EQU	0FF62H	;W- addr swapped-in pages (See special.asm)
;
;;BUFFER		EQU	0FF64H	;W- buffer space
;;FCB		EQU	0FF66H	;W- fcb space
USR_NAME	EQU	0FF68H	;W- name string
USR_NUMBER	EQU	0FF6AH	;W- user #
USR_LOGOUT	EQU	0FF6CH	;J- log off user (See special.asm)
SECOND		EQU	0FF6FH	;C- wait 'A' sec (See special.asm)
;;MESSAGE		EQU	0FF72H	;C- msg to device
;;LIST		EQU	0FF75H	;C- list file to DCB_2O
PRIV_1		EQU	0FF78H	;B- first privileges
PRIV_2		EQU	0FF79H	;B- second.
;Definitions for privilege bits PRIV_1
GRA_NWDOS	EQU	0	;Dos access.
GRA_ELOC	EQU	1	;Can enter local messages
GRA_ENET	EQU	2	;Can enter net messages
XP1_3		EQU	3	;_1
XP1_4		EQU	4	;_1
XP1_5		EQU	5	;_1
XP1_6		EQU	6	;_1
IS_SYSOP	EQU	7	;Sysop access.
;and for PRIV_2.
GRA_LOGIN	EQU	0	;login granted.
;PRIV_VISITOR	EQU	1	;1=visitor.
IS_VISITOR	EQU	1	;1=visitor.
DEN_GAMES	EQU	2	;1=No game playing allwd.
DEN_LOGCMD	EQU	3	;1=log commands.
EXPERT_USER	EQU	4	;1=Expert.
XP2_4		EQU	4	;_2
;;DEN_PASSWD	EQU	5	;System password reqd.
KEY_APPROVAL	EQU	6	;Requires sysop approval.
XP2_6		EQU	6	;_2
XP2_7		EQU	7	;_2
;
;Replace CR_COUNT by this:
OUTPUT_MODE	EQU	0FF7AH	;B- output mode
;
;Output modes are:  character(vdu, terminal)
OM_RAW		EQU	1	;cr(cr,cr) lf(lf,lf)
OM_COOKED	EQU	2	;cr(cr,crlf) lf(cr,crlf)
OM_DISPLAY	EQU	3	;cr(1d,cr) lf(1a,lf)
OM_UNIX		EQU	4	;CR(1dh,cr) lf(cr,crlf)
;
;CR_COUNT	EQU	0FF7AH	;W?- crash count?
;
PUP_TIME	EQU	0FF7CH	;8- call start time
CALLER		EQU	0FF84H	;W- caller number logdin
PUP_DATE	EQU	0FF86H	;8- call date
SP_SAVED	EQU	0FF8EH	;W- SP on crash
CD_MODE		EQU	0FF90H	;B- carrier mode
CD_STAT		EQU	0FF91H	;B- send/recv status
;Bit definitions for cd_stat:
CDS_0		EQU	0
CDS_1		EQU	1
CDS_2		EQU	2
CDS_CSTAT	EQU	3	;1 if not ignoring carrier
CDS_DSTAT	EQU	4	;1 if discon when carrier drops
CDS_LOST	EQU	5	;1 if we did lose carrier
CDS_DISCON	EQU	7	;1 if disconnect in process
;
CD_COUNT	EQU	0FF92H	;B- carrier count
CD_LOSS		EQU	0FF93H	;B- carrier losses
MODEM_STAT1	EQU	0FF94H	;B- word length etc
MODEM_STAT2	EQU	0FF95H	;B- rs232 signals etc
;
LOG_BYTE	EQU	0FF9BH	;B- for ptr/dsk log
;Bit definitions:
ON_DISK		EQU	0
;ON_PRINTER	EQU	1
;
WORD_WRAP	EQU	0FF9CH	;B- 1=Wrap going
BELL_TOGGLE	EQU	0FF9DH	;2-  rel-locn & xor
TERM_TYPE	EQU	0FF9FH	;B- term config
;
SER_INHIBIT	EQU	0FFA0H	;B- ser port inhibit
				;bit defns required.
SER_OVRRIDE	EQU	0FFA1H	;B- ser o/ride count
SER_TICKER	EQU	0FFA2H	;B- ser o/r tick
TMR_COUNT	EQU	0FFA3H	;W- 5 sec intervals.
;
LAST_CALL	EQU	0FFA5H	;3- Date last call.
;
F_XOFF		EQU	0FFA8H	;B- 1=Ctrl-S Pending.
;
TFLAG2		EQU	0FFA9H	;B- Terminal Flags 2
				;Defs follow:
TF_WIDTH	EQU	3	;Bits 0 & 1
TF_HEIGHT	EQU	2	;1=24 lines
TF_CRLF		EQU	3	;1=CR+LF
TF_BS		EQU	4	;1=08,20,08
TF_CURSOR	EQU	5	;1=Mask out 0E,0F
TF_DEL		EQU	6	;1=DEL=08H
TF_BELL		EQU	7	;1=Bell on
;
SER_OUT		EQU	0FFAAH	;C- Put byte to RS-232
SER_INP		EQU	0FFADH	;C- Get from RS-232
;
CIRC_BUFF	EQU	0FFB0H	;16- Circular Buffer
				;for rude check.
;
LOG_MSG		EQU	0FFC0H	;J- Message to log file.
;
CIRC_LOCN	EQU	0FFD0H	;B- offset in circ_buff
RUDE_DISC	EQU	0FFD1H	;B- user was rude -> disc
;
END_OF_LIST	EQU	0FFD2H	;W- End of linked list
PROG_START	EQU	0FFD4H	;W- addr of prog start
PROG_END	EQU	0FFD6H	;W- addr of prog end
ABORT		EQU	0FFD8H	;W- Abort program
DISCON		EQU	0FFDAH	;W- Disconnection.
;
TERMINATE	EQU	0FFDCH	;C- terminate prog
CALL_PROG	EQU	0FFDFH	;C- call a program
OVERLAY		EQU	0FFE2H	;C- jump to program
TERM_ABORT	EQU	0FFE5H	;C- abort signal
TERM_DISCON	EQU	0FFE8H	;C- discon signal
;
LASTCC		EQU	0FFEBH	;B- Last return code
$STDOUT		EQU	0FFECH	;W- Standard output ptr
$STDIN		EQU	0FFEEH	;W- Standard input ptr
$STDOUT_DEF	EQU	0FFF0H	;W- Default $stdout
$STDIN_DEF	EQU	0FFF2H	;W- Default $stdin
$STDIN_FCB	EQU	0FFF4H	;W- Addr stdin FCB
$STDIN_BUFF	EQU	0FFF6H	;W- Addr stdin BUFF
$STDOUT_FCB	EQU	0FFF8H	;W- Addr stdout FCB
$STDOUT_BUFF	EQU	0FFFAH	;W- Addr stdout BUFF
;
PKTS_RCVD	EQU	0FFFCH	;W- count pkts rcvd.
;
SYS_STAT	EQU	0FFFFH	;B- System status
;Definitions for each bit of SYS_STAT follow:
SYS_OFFHK	EQU	0	;Modem off-hook
;carr_found	equ	1?
;carr_lost	equ	2?
;devices_routd	equ	3
;test_boot	equ	4
SYS_LOGDIN	EQU	5
SYS_TEST	EQU	6
;Undefined	equ	7
;
BASE		DEFL	5C00H	;ORG base for progs.
BASE_PAGEX	EQU	8	;base log.page offset
TOP_RAM		EQU	0E800H	;High Memory (zeta)
TOP_PAGE	EQU	0E8H
TOP_PAGEX	EQU	42
;
TEMP_RAM	EQU	0F800H	;Temporary ram address
TEMP_PAGE	EQU	0F8H	;Temp logical page addr
TEMP_PAGEX	EQU	46	;temp logical page offset
;
EXTERNALS	EQU	0FE00H	;Start of externals
;
*LIST	ON
