;pktdis: Fido packet disassembler
;usage:  pktdis [-r] filename
;
*GET	DOSCALLS.HDR
*GET	EXTERNAL.HDR
*GET	ASCII.HDR
*GET	FIDONET.HDR
;
	COM	'<Pktdis 1.5h 11-Apr-88>'
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info.
;
	ORG	BASE+100H
;
*GET	PKTDIS1
*GET	BB7		;Text file routines
;
*GET	TIMES.LIB	;Time output routines
*GET	ROUTINES.LIB	;General routines
;
DEFAULT_TOPIC	EQU	10000100B	;gen>mail>fidonet
;Known Echomail conferences. Names; topic numbers.
CONF_TABLE
;
	DEFM	'NET713_SYSOP',0
	DEFM	'713',0
	DEFB	01101011B	;gen>fido>admin>713
	DEFB	0
;
	DEFM	'RG54_SYSOP',0	;First name = incoming
	DEFM	'54',0		;2nd name = displayed
	DEFB	01101010B	;gen>fido>admin>54
	DEFB	0		;Count of msgs rcvd
;
	DEFM	'ZONE3_SYSOP',0
	DEFM	'z3',0
	DEFB	01101001B	;gen>fido>admin>z3
	DEFB	0
;
	DEFM	'AUST_PAMS',0
	DEFM	'pams',0
	DEFM	00101000B	;gen>echomail>pams
	DEFB	0
;
	DEFM	'aust_xenix',0
	DEFM	'unix',0
	DEFB	00100100B	;gen>echomail>unix
	DEFB	0
;
	DEFM	'unet_sf',0
	DEFM	'sf',0
	DEFB	11001000B	;gen>usenet>sf
	DEFB	0
;
	DEFM	'UNET_JOKES',0
	DEFM	'jokes',0
	DEFB	11000100B	;gen>usenet>jokes
	DEFB	0
;
	DEFM	'UNET_MED',0
	DEFM	'med',0
	DEFB	11010000B	;gen>usenet>med
	DEFB	0
;
	DEFM	'unet_minix',0
	DEFM	'minix',0
	DEFB	01000000B	;gen>minix
	DEFB	0
;
	DEFM	'AUST_C_HERE',0
	DEFM	'c',0
	DEFB	00110000B	;gen>echomail>c
	DEFB	0
;
	DEFM	'GATERS',0
	DEFM	'gaters',0
	DEFB	00101100B	;gen>echomail>gaters
	DEFB	0
;
	DEFM	'AUS.GENERAL',0
	DEFM	'aus.general',0
	DEFB	11001100B	;gen>usenet>aus.general
	DEFB	0
;
	DEFM	'AUS.FORSALE',0
	DEFM	'aus.forsale',0
	DEFB	11010100B	;gen>usenet>aus.forsale
	DEFB	0
;
	DEFM	'AUS.JOBS',0
	DEFM	'aus.jobs',0
	DEFB	11011000B	;gen>usenet>aus.jobs
	DEFB	0
;
	DEFM	'AUS.AI',0
	DEFM	'aus.ai',0
	DEFB	11011100B	;gen>usenet>aus.ai
	DEFB	0
;
	DEFM	'TRANSPUTER',0
	DEFM	'transputer',0
	DEFB	10100100B	;gen>misc>t'puter
	DEFB	0
;
;These conferences are no longer being received.
;
	DEFM	'c_echo',0
	DEFM	'c_echo',0
	DEFB	10100000B	;general>misc
	DEFB	0
;
	DEFB	0		;end of table.
;
ECHOMAIL	DEFB	0	;1=Echomail.
TO_ZETA		DEFB	0	;1=Addressed to zeta.
RMFLAG		DEFB	0	;1=Remove packet
ECHO_MARK	DEFM	'AREA:',0
ECHO_MARK2	DEFM	01H,'AREA:',0
SEEN_MARK	DEFM	'SEEN-BY: ',0
CTRL_MARK	DEFM	01H,0	;^A
;
;******************************************
;Definitions for packet header
HEADER
H_ORIG_NODE	DEFW	0
H_DEST_NODE	DEFW	0
H_YEAR		DEFW	0
H_MONTH		DEFW	0	;Month is zero offset!
H_DAY		DEFW	0
H_HR		DEFW	0
H_MIN		DEFW	0
H_SEC		DEFW	0
H_RATE		DEFW	0
H_VER		DEFW	0
H_ORIG_NET	DEFW	0
H_DEST_NET	DEFW	0
H_X		DEFS	34
;******************************************
;
M_HDROK	DEFM	'Header correct',CR,0
M_NOMSG	DEFM	'** Could not read message',CR,0
M_NOCOPY DEFM	'** Could not copy message',CR,0
M_NOTME	DEFM	'** Packet not intended for Zeta',CR,0
M_BADVER DEFM	'** Packet version # not = 2',CR,0
M_BADHDR DEFM	'** Bad message header in packet',CR,0
M_BADMSG DEFM	'** Bad message format (echomail?)',CR,0
M_LONGLINE
	DEFM	'** First line too long',CR,0
M_EMPTY	DEFM	'** Empty message',CR,0
M_WRITERR DEFM	'** Write error',CR,0
M_PKTOK	DEFM	'Packet was OK',CR,0
M_PKTDIS DEFM	'pktdis: ',0
M_STATS	DEFM	'Echomail message counts:',CR,0
M_RDERR	DEFM	'Error while reading message',CR,0
BLANKS	DEFM	'                    ',0
;
;*****************************************
MSGHDR_REC				;*
HDR_FLAG	DEFB	0		;*
HDR_LINES	DEFB	0		;*
HDR_RBA		DC	3,0		;*
HDR_DATE	DC	3,0		;*
HDR_SNDR	DEFW	0		;*
HDR_RCVR	DEFW	0		;*
HDR_TOPIC	DEFB	0		;*
HDR_TIME	DC	3,0		;*
;*****************************************
PKT_FCB		DEFS	32
PKT_BUFF	DEFS	256
;
NODE_FCB	DEFM	'netnodes.zms',ETX
	DC	32-13,0
NODE_BUF	DEFS	256
;
LIST_POS	DEFW	0
LEFT_STR	DEFW	0
RIGHT_STR	DEFW	0
NODE_STR	DEFW	0
DEST_KNOWN	DEFB	0	;Flag. 1=dest valid user
;
TXT_FCB	DEFM	'msgtxt.zms',ETX
	DC	32-11,0
TOP_FCB	DEFM	'msgtop.zms',ETX
	DC	32-11,0
HDR_FCB	DEFM	'msghdr.zms',ETX
	DC	32-11,0
;
MSGTXT_BUFF	EQU	_BLOCK
MSGTOP_BUFF	DEFS	256
MSGHDR_BUFF	DEFS	256
;
ID_ORIG	DEFS	32	;Naba
;
ID_DEST	DEFS	32	;Zeta
STRING	DEFS	256
;
;*******
COUNTS
NUM_MSG		DEFW	0
NUM_KLD_MSG	DEFW	0
EOF_RBA		DC	3,0
		DEFS	9
;*******
COUNTS_ORIG	DEFS	16	;Original msg counts
;
;*******
F_MSG_HDR
;-;type		defw	0	;read and discarded
ORIG_NODE	DEFW	0
DEST_NODE	DEFW	0
ORIG_NET	DEFW	0
DEST_NET	DEFW	0
FLAGS		DEFW	0
COST		DEFW	0
;*******
;
;
DATE_BUFFER	DEFS	24
TO_BUFFER	DEFS	40
FROM_BUFFER	DEFS	40
SUBJ_BUFFER	DEFS	82
LINEBUF		DEFS	81	;Each message line.
;
THIS_PROG_END	EQU	$	;Excluding message stuff
;
;
	DEFW	082H		;Marker
NODELIST	EQU	$
	END	START
