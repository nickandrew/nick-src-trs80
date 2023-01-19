;pktass: Assemble messages into outgoing packets.
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
*GET	FIDONET
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	0
	DEFW	0
;End of program load info
;
	COM	'<Pktass 1.3c 19-Dec-87>'
	ORG	BASE+100H
;
START	LD	SP,START
;
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	LD	A,0
	JP	Z,TERMINATE
;
*GET	PKTASS1
*GET	BB7
;
*GET	ROUTINES
*GET	CI_CMP
;
;Data section...........................................
;
TXT_FCB	DEFM	'msgtxt.zms',CR
		DC	32-11,0
TOP_FCB	DEFM	'msgtop.zms',CR
		DC	32-11,0
HDR_FCB	DEFM	'msghdr.zms',CR
		DC	32-11,0
NETN_FCB	DEFM	'netn.zms',CR
		DC	32-9,0
NETL_FCB	DEFM	'netl.zms',CR
		DC	32-9,0
PKT_FCB		DC	32,0
;
MSGTXT_BUF	EQU	_BLOCK
MSGTOP_BUF	DEFS	256
MSGHDR_BUF	DEFS	256
NETN_BUF	DEFS	256
NETL_BUF	DEFS	256
PKT_BUF		DEFS	256
;
EM	DEFW	0
MSGBUF	DEFW	0
NLPTR	DEFW	0
LTPTR	DEFW	0
EMPTR	DEFW	0	;echomail table pointer.
MSGNO	DEFW	-1
;
LINK	DEFS	75	;room for 25 links
NODE	DEFS	300	;room for 50 nodes
;
NODE_SHORT	DEFW	0
NODE_FIDONODE	DEFW	0
NODE_LINK	DEFW	0
;
LINK_NAME	DEFW	0
LINK_FIDONODE	DEFW	0
LINK_FILENAME	DEFW	0
;
ROUTE_NET_NUM	DEFW	0
ROUTE_NODE_NUM	DEFW	0
TO_NET_NUM	DEFW	0
TO_NODE_NUM	DEFW	0
;
ORIG_NAME	DEFS	64	;"nick andrew@zeta"
DEST_NAME	DEFS	64	;"gary stern@realtors"
DATE_LEFT	DEFS	64	;"23 Oct 86  22:01:44"
SUBJECT		DEFS	73	;"Blah"
PRIM_LINK	DEFS	64
CURRENT_FILE	DEFS	32
CURRENT_FILEA	DEFS	32
FILE_APPEND	DEFM	'/poof:2',0
;
*GET	MSGHDR
;
NET_ADDRESS	DEFW	0	;Addr of @"realtors"
LINK_TOUSE	DEFW	0
ROUTE_ADDRESS	DEFW	0
ROUTE_FILENAME	DEFW	0
;
M_CORRUPT
	DEFM	'Something is corrupt!',CR,0
M_NOFF	DEFM	'No FF byte at start of message',CR,0
M_NOTNET
	DEFM	'NETmsg bit set but no "@" in dest',CR,0
M_UNKNLINK
	DEFM	'linkname in NETN.ZMS unknown',CR,0
M_BADADD
	DEFM	'Bad network address at ',0
M_FROM	DEFM	'# From ',0
M_TO	DEFM	'  to  ',0
M_CR	DEFM	CR,0
M_ONLINK
	DEFM	'Sending on link: ',0
;
GATEWAY	DEFM	'Acsnet@acsnet',0
ACSLINK	DEFM	'acsnet',0
ON_ACS	DEFB	0
;
ADDRESS	DEFM	'To: '
ADDRESSL	DEFB	0
	DC	64,0
;
;
F_ECHO	DEFB	0
ECHO_AREA	DEFW	0	;addr of AREA: line.
ECHO_ORIGIN	DEFW	0	;addr of ORIGIN lines
;
*GET	MSGTOP
;
;Echomail control information....
ECHOMAIL
	DEFW	CONF_1		;aust_sysop
	DEFW	COORD_1
	DEFW	AREA_1
	DEFW	ORIGIN_1
;
	DEFW	CONF_2		;aust_tech
	DEFW	COORD_2
	DEFW	AREA_2
	DEFW	ORIGIN_2
;
	DEFW	CONF_3		;aust_telecom
	DEFW	COORD_3
	DEFW	AREA_3
	DEFW	ORIGIN_3
;
	DEFW	CONF_4		;c_echo US.
	DEFW	COORD_4
	DEFW	AREA_4
	DEFW	ORIGIN_4
;
	DEFW	CONF_5		;ltuae
	DEFW	COORD_5
	DEFW	AREA_5
	DEFW	ORIGIN_5
;
	DEFW	CONF_6		;712
	DEFW	COORD_6
	DEFW	AREA_6
	DEFW	ORIGIN_6
;
	DEFW	CONF_7		;unix
	DEFW	COORD_7
	DEFW	AREA_7
	DEFW	ORIGIN_7
;
	DEFW	CONF_8		;54
	DEFW	COORD_8
	DEFW	AREA_8
	DEFW	ORIGIN_8
;
	DEFW	CONF_9		;religion
	DEFW	COORD_9
	DEFW	AREA_9
	DEFW	ORIGIN_9
;
	DEFW	CONF_A		;pams
	DEFW	COORD_A
	DEFW	AREA_A
	DEFW	ORIGIN_A
;
	DEFW	CONF_B		;rpg
	DEFW	COORD_B
	DEFW	AREA_B
	DEFW	ORIGIN_B
;
	DEFW	CONF_C		;gaming
	DEFW	COORD_C
	DEFW	AREA_C
	DEFW	ORIGIN_C
;
	DEFW	CONF_C2		;infocom
	DEFW	COORD_C		;Same as gaming
	DEFW	AREA_C
	DEFW	ORIGIN_C
;
	DEFW	CONF_D		;net713_sysop
	DEFW	COORD_D
	DEFW	AREA_D
	DEFW	ORIGIN_D
;
	DEFW	CONF_E		;minix (acsnet)
	DEFW	COORD_E
	DEFW	AREA_E
	DEFW	ORIGIN_E
;
	DEFW	CONF_F		;to_zeta (test)
	DEFW	COORD_F
	DEFW	AREA_F
	DEFW	ORIGIN_F
;
	DEFW	CONF_G		;gaters
	DEFW	COORD_G
	DEFW	AREA_G
	DEFW	ORIGIN_G
;
	DEFW	CONF_H
	DEFW	COORD_H
	DEFW	AREA_H
	DEFW	ORIGIN_H
;
	DEFW	CONF_I
	DEFW	COORD_I
	DEFW	AREA_I
	DEFW	ORIGIN_I
;
	DEFW	CONF_J
	DEFW	COORD_J
	DEFW	AREA_J
	DEFW	ORIGIN_J
;
	DEFW	0,0,0,0		;end of table.
;
CONF_1	DEFM	'z3',0
CONF_2	DEFM	'aust_tech',0
CONF_3	DEFM	'aust_telecom',0
CONF_4	DEFM	'c_echo',0
CONF_5	DEFM	'ltuae',0
CONF_6	DEFM	'712',0
CONF_7	DEFM	'unix',0
CONF_8	DEFM	'54',0
CONF_9	DEFM	'religion',0
CONF_A	DEFM	'pams',0
CONF_B	DEFM	'rpg',0
CONF_C	DEFM	'gaming',0
CONF_C2	DEFM	'infocom',0
CONF_D	DEFM	'713',0
CONF_E	DEFM	'minix',0
CONF_F	DEFM	'to_zeta',0
CONF_G	DEFM	'gaters',0
CONF_H	DEFM	'net_dev',0
CONF_I	DEFM	'sf',0
CONF_J	DEFM	'med',0
;
COORD_J
COORD_H
COORD_G
COORD_D
COORD_C
COORD_B
COORD_A
COORD_9
COORD_8
COORD_7
COORD_6
COORD_5
COORD_4
COORD_3
COORD_2
COORD_1
	DEFM	'naba',0	;Send to NABA-prophet
;
COORD_I
COORD_F
COORD_E
	DEFM	'acsnet',0	;Send to Nswitgould
;
S_AREA	DEFM	'AREA:',0
;
AREA_1	DEFM	'ZONE3_SYSOP',CR,LF,0
AREA_2	DEFM	'AUST_TECH',CR,LF,0
AREA_3	DEFM	'AUST_TELECOM',CR,LF,0
AREA_4	DEFM	'C_ECHO',CR,LF,0
AREA_5	DEFM	'LTUAE',CR,LF,0
AREA_6	DEFM	'ANYTHING',CR,LF,0
AREA_7	DEFM	'AUST_XENIX',CR,LF,0
AREA_8	DEFM	'RG54_SYSOP',CR,LF,0
AREA_9	DEFM	'RELIGION',CR,LF,0
AREA_A	DEFM	'AUST_PAMS',CR,LF,0
AREA_B	DEFM	'RPG',CR,LF,0
AREA_C	DEFM	'GAMING',CR,LF,0
AREA_D	DEFM	'NET713_SYSOP',CR,LF,0
AREA_E	DEFM	'UNET_MINIX',CR,LF,0
AREA_F	DEFM	'TO_ZETA',CR,LF,0
AREA_G	DEFM	'GATERS',CR,LF,0
AREA_H	DEFM	'NET_DEV',CR,LF,0
AREA_I	DEFM	'UNET_SF',CR,LF,0
AREA_J	DEFM	'UNET_MED',CR,LF,0
;
ORIGIN_J
ORIGIN_I
ORIGIN_H
ORIGIN_G
ORIGIN_F
ORIGIN_E
ORIGIN_D
ORIGIN_C
ORIGIN_B
ORIGIN_A
ORIGIN_9
ORIGIN_8
ORIGIN_7
ORIGIN_6
ORIGIN_5
ORIGIN_4
ORIGIN_3
ORIGIN_2
ORIGIN_1
	DEFM	'--- Zeta',CR,LF
	DEFM	' * Origin: Zeta, the first TRS-80 in Fidoworld (3:713/602)',CR,LF	; --ZETA_NUM--
	DEFM	'SEEN-BY: 713/602 713/600',CR,LF	; --ZETA_NUM-- --SCAN_NUM--
	DEFM	CR,LF,0
;
BIG_BUFF	DEFS	1024
;
THIS_PROG_END	EQU	$
;
	END	START
