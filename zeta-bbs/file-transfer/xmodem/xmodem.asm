;xmodem: Xmodem-CRC file transfer program.
;
; 1.13 05 Aug 89
;	Fixed several bugs :-)
;	Removed exmodem (partially)
;	Slackened receive data timeouts for Prophet
;	Cleaned up formatting of xmodem.asm
; 1.12 02 Jan 89
;	Base version
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	TERMINATE
;End of program load info.
;
	COM	'<Xmodem 1.13 05-Aug-89>'
	ORG	BASE+100H
;
;Zeta USART equates...
RDDATA	EQU	0F8H
WRDATA	EQU	0F8H
RDSTAT	EQU	0F9H
WRSTAT	EQU	0F9H
DAV	EQU	1
CTS	EQU	0
;
;XMODEM protocol type equates...
SOH	EQU	01H
EOT	EQU	04H
ENQ	EQU	05H
ACK	EQU	06H
NAK	EQU	15H
SYN	EQU	16H	;Telink block header
CAN	EQU	18H
CRCNAK	EQU	'C'	;Initial NAK ala CRC mode
SUB	EQU	1AH	;Control char for modem7
;
;Constants
BLOCKSIZE	EQU	128
MAX_NAKS	EQU	0AH
MAX_BLOCKS	EQU	18H	;Was 14H.
SEALINK		EQU	0	;Generate Sealink ACKs
CHARTIMEOUT	EQU	2	;0.2 seconds timeout when receiving
;
*GET	XMODEM1
*GET	XMODEM2
;
;Get useful routines.
*GET	TIMES
*GET	ROUTINES
;
;Special flags & stuff.
QUIET		DEFB	0	;1=Quiet output
OVERWRITE	DEFB	0	;1=Overwrite existing file
CRCMODE		DEFB	1	;1=In CRC mode
TELINK		DEFB	0	;1=In Telink mode
EX_FLAG		DEFB	0	;1=Exmodem on sending
DEBUG_FLAG	DEFB	0	;1=Debugging mode
NOLOG		DEFB	0	;No logging actions.
;
CRC_LOW		DEFW	0	;CRC as received
OLD_CRC		DEFW	0	;CRC calculated.
CHECKSUM	DEFB	0	;Checksum calculated
MAX_TOREAD	DEFB	0	;blks to read firstly.
;
M_S_ACK		DEFM	'ACK ',0
M_R_ACK		DEFM	'ack ',0
M_S_ENQ		DEFM	'ENQ ',0
M_R_ENQ		DEFM	'enq ',0
M_S_EOT		DEFM	'EOT ',0
M_R_EOT		DEFM	'eot ',0
M_S_NAK		DEFM	'NAK ',0
M_NAK		DEFM	'nak ',0
M_CRCNAK	DEFM	'crcnak ',0
M_S_CRCNAK	DEFM	'CRCNAK ',0
M_S_CAN		DEFM	'CAN ',0
M_CAN		DEFM	'can ',0
M_CAN_WHO	DEFM	'(Someone cancels) ',0
M_CAN_HIM	DEFM	'(He cancels) ',0
M_10_NAKS	DEFM	'(he sends too many naks) ',0
M_TIME2		DEFM	'timeout ',0
M_ABRT		DEFM	'Aborted!',CR,0
M_HUH		DEFM	CR,'Huh?',CR,0
;
MS_RCAN		DEFM	'Receiver cancelled',CR,0
;
MR_NOSOH	DEFM	'Nothing received for 10 seconds',CR,0
MR_NOBN		DEFM	'Timeout receiving block number or inverse',CR,0
MR_NOINV	DEFM	'Block numbers are not inverse',CR,0
MR_NOCHAR	DEFM	'Timeout receiving block data',CR,0
MR_NOSUM	DEFM	'Timeout receiving checksum',CR,0
MR_NOCRC	DEFM	'Timeout receiving crc',CR,0
MR_JUNK		DEFM	'Junk received instead of SOH, SYN or EOT',CR,0
MR_BADSUM	DEFM	'Bad checksum',CR,0
MR_BADCRC	DEFM	'Bad crc',CR,0
MR_BADSEQ	DEFM	'Bad sequence number',CR,0
;
ARG		DEFW	0
NEWARG		DEFW	0
M7_TRY		DEFB	0
M7_POSN		DEFW	0
M7_FIELD	DEFS	11	;FFFFFFFFeee
;
M_RECVNG	DEFM	'xmodem: receiving ',0
M_SENDING	DEFM	'xmodem: sending ',0
M_LOG_ERROR	DEFM	'*** xmf log file error',0
;
M_USAGE		DEFM	CR
		DEFM	' Illegal arguments given. Usage is:',CR
		DEFM	'Single file interactive mode:',CR
		DEFM	'xmodem',CR
		DEFM	'For multi file send/receive mode:',CR
		DEFM	'xmodem [-coqn] [-s files ...] [-r files ...]',CR,CR
		DEFM	'Putting you into interactive mode now:',CR,0
M_BDFL		DEFM	'Illegal Filename for a Zeta file!',CR
		DEFM	'Use a name like ABCDEFGH.EXT',CR,0
;
M_SRDY1		DEFM	'Sending ',0
M_SRDY2		DEFM	', ',0
M_SRDY3		DEFM	' blocks (',0
M_SRDY4		DEFM	'K). Start your local XMODEM receive now.',CR,0
;
M_RRDY		DEFM	CR,'Ready to receive - start your XMODEM module',CR,0
M_CANNOT	DEFM	'You must be a member to download that file',CR,0
M_EXISTS	DEFM	'That filename already exists',CR
		DEFM	'Upload with a different name',CR,0
M_FINI	DEFM	CR,'File transfer completed.',CR,CR,0
M_KILLED	DEFM	'XMF killed file',CR,0
M_ABORTED	DEFM	' <Aborted>',CR,0
M_BUSTED	DEFM	' <Busted>',CR,0
M_SENDEX	DEFM	' <Exists>',CR,0
M_RECVNO	DEFM	' <Nonexistant>',CR,0
M_ERROR		DEFM	' <Dos Error>',CR,0
M_DSKFUL	DEFM	' <Disk Full>',CR,0
M_TIME1		DEFM	' init-nak timeout ',CR,0
M_DISAL		DEFM	' <Disallowed>',CR,0
M_FNID		DEFM	'File requested not in directory.',CR
		DEFM	'Check filename and disk directory.',CR,0
M_S_OR_R	DEFM	'Tell Xmodem to send or receive file (S or R): ',0
M_FILE		DEFM	'Filename? ',0
M_SIGNON	DEFM	CR,'xmodem: EXmodem File Transfer utility plus CRC checking.',CR
		DEFM	'Xmodem protocol transfers only.',CR
		DEFM	'usage is: xmodem [-coqn] [-s files ...] [-r files ...]',CR,CR,0
M_NOVIS		DEFM	CR,'Sorry, you must be a MEMBER to send files.',CR,0
;
BLK1		DEFB	0
;
DATABUF		DC	80H,0		;Block buffer.
ZEROCRC		DEFW	0		;Must be imm. after DATABUF
;
AID		DEFW	BIG_BUFF	;Current read/write addr.
FIRST_BLK	DEFB	0	;1=First blk of transfer
BLK_RCV		DEFB	0	;block # being received
BLK_SNT		DEFB	0	;block # being sent
NNAKS		DEFB	0	;number of NAKs sent
FIL_EOF		DEFB	0	;1=no more blks to read
BLK_STORED	DEFB	0	;# blocks stored
XFABRT		DEFB	0	;flag 1=abort desired.
EOFB		DEFB	0	;EOF value 1-128 of blk.
;
FCB_1		DEFS	32		;FCB.
BUFF_1		DEFS	256		;File Buffer...
;
FCB_LOG		DEFM	'xferlog.zms:2',CR
		DC	32-12,0
BUFF_LOG	DEFS	256
;
B_DATE		DEFM	'DD-MMM-YY '
B_TIME		DEFM	'HH:MM:SS ',0
;
B_TYPE		DEFM	'S '
B_FILE		DEFM	'abcdefgh.xyz/password:1',CR,0
;
MSGBLK		DEFM	'xx  ',0
;
STRING		DEFS	64
;
IN_BUFF		DC	64,0
;
BIG_BUFF	NOP
;
		DEFS	MAX_BLOCKS*128
THIS_PROG_END	EQU	$
;
	END	START
