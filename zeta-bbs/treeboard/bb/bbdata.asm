; @(#) bbdata.asm - Data for treeboard, 14 May 89
;
;Meanings of bits of status byte for each topic (offset 19)
TOP_ECHO	EQU	0	;Bit #0, 1=echomail topic
;
M_BADCMD
M_UNK
	DEFM	'Unknown command',CR,0
M_BADSYN
	DEFM	'Command error',CR,0
M_BDRNG	DEFM	'Bad message range',CR,0
M_KILLERR
	DEFM	'Disk error while killing message',CR,0
M_SAVEERR
	DEFM	'Disk error while saving message',CR,0
M_NTFND
	DEFM	CR,'No messages found',CR,0
M_WHERE	DEFM	CR,'You are at ',0
M_READ	DEFM	CR,'     ** READing **',CR,0
M_SCAN	DEFM	CR,'     ** SCANning **',CR,0
M_KILL	DEFM	CR,'     ** KILLing **',CR,0
M_ENTER	DEFM	CR,'     ** ENTERing **',CR,0
M_FORWARD
	DEFM	CR,'     ** Forwarding **',CR,0
M_MOVEMSG
	DEFM	CR,'     ** Moving **',CR,0
M_TREEWALK
	DEFM	CR,'Treewalk',CR
	DEFM	'N to skip the message, T to skip the topic, Q to quit',CR,0
M_MSGNUM
	DEFM	'Message No ',0
M_MSGTOP
	DEFM	CR,'Topic:   ',0
M_SNDR	DEFM	CR,'From:    ',0
M_RCVR	DEFM	CR,'To:      ',0
M_DATE	DEFM	CR,'Date:    ',0
M_SUBJ	DEFM	CR,'Subject: ',0
M_NOWAT	DEFM	'Now at topic ',0
M_UNDER	DEFM	CR,'Topics under ',0
M_WHRTO	DEFM	'Where to (number,<U>, or <CR> to stay): ',0
M_WHOTO
	DEFM	'To:      ',0
M_FWDWHO
	DEFM	'To:      ',0
M_MOVWHR
	DEFM	'Move msgs to which topic? (by name): ',0
M_WHTSUBJ
	DEFM	'Subject: ',0
M_FROMFILE	DEFM	'Filename: ',0
M_BRDFULL
	DEFM	'The complete Message System is full.',CR
	DEFM	'I can''t handle any more messages.',CR,0
M_DESTSTR
	DEFM	'Not a user: ',0
M_DESTSTR2
	DEFM	'Messages in a local topic must be addressed to a real',CR
	DEFM	'Zeta user or to ALL.',CR,0
M_NONET
	DEFM	'You cannot enter network mail into an echomail topic',CR,0
M_TOPLOC
	DEFM	'This will be a local message',CR,0
M_TOPECHO
	DEFM	'This message will be distributed through ACSnet or Fidonet'
	DEFM	CR,0
;;M_ALL	DEFM	'ALL',CR
M_PRIVATE
	DEFM	'Private? (Y/N/Q): ',0
M_FWD_NOONE
	DEFM	CR,'No zeta user by that name.',CR,0
M_FORWARDING
	DEFM	'Forwarding msg # ',0
PMPT_MAIN
	DEFM	CR,'bb: ',0
PMPT_QUEST
	DEFM	'(L,E,C,A,S): ',0
PMPT_DS1
	DEFM	'Range: ',0
PMPT_SPEC
	DEFM	'Enter special command: ',0
PMPT_OPT
	DEFM	'Option: ',0
PMPT_STATUS
	DEFM	'Enter new topic status. E for echomail, L for local: ',0
M_STATOK
	DEFM	'Topic status byte updated OK',CR,0
M_NODLTP
	DEFM	'Sorry you can''t delete "GENERAL"',CR,0
M_NOTCRTR
	DEFM	'Sorry you''re not the creator of this topic',CR,0
M_TPNTMT
	DEFM	'Sorry this topic has messages.',CR,0
M_ACTSUB
	DEFM	'Sorry this topic has Sub-Topics.',CR,0
M_TRSEDIT
	DEFM	'Type L then H then retype the line',CR,0
M_MAXLIN
	DEFM	'Sorry you''ve already filled the message.',CR,0
M_MVGUP	DEFM	'OK Moving up...',CR,0
M_OK	DEFM	'OK',CR,0
M_CURTPC
	DEFM	'Your current topic is ',0
M_YOATUP
	DEFM	'   You are at the top.',CR,CR,0
M_UPWRD
	DEFM	CR,0
;
M_UPTO	DEFM	'<U>  Move up to ',0
M_DWNWRD
	DEFM	CR,0
M_NOBELO
	DEFM	'  NO Sub-Topics.',CR,0
M_NOPERMS
	DEFM	CR,'Sorry.',CR,0
M_OPTIONS
	DEFM	CR,'   Your current options are:',CR,0
M_CURR	DEFM	'#1  You see this topic only',CR,0
M_LOWR	DEFM	'#2  You see all topics beneath this',CR,0
M_NORM	DEFM	'#3  Long menus',CR,0
M_EXP	DEFM	'#4  Short menus',CR,0
M_WITHMSG
	DEFM	' with ',0
M_MSGS	DEFM	' Msgs.',CR,0
M_MESGS	DEFM	' Messages.',CR,0
M_MSG2	DEFM	CR,'Msg # ',0
M_LINES	DEFM	' lines',0
M_NTFRYO
M_NTFRYOMV
	DEFM	' doesn''t belong to you.',CR,0
M_MSGKLD
	DEFM	'Killed.',CR,0
M_MSGMVD
	DEFM	'Moved.',CR,0
M_SYSGOT
	DEFM	CR
	DEFM	'This system contains a total of ',0
M_NKLD	DEFM	'Killed messages comprise ',0
M_TO		DEFM	'  to  ',0
M_P		DEFM	'  (Private)',0
M_NETSENT	DEFM	'  (Sent)',0
M_SPACE		DEFM	'  Topic: ',0
M_ABOUT		DEFM	CR,'Subject: ',0
M_SPACES	DEFM	'   ',0
M_NO	DEFM	'  (No)',CR,0
M_YES	DEFM	'  (Yes)',CR,0
M_QUIT	DEFM	'  (Quit)',CR,0
M_ATBOTM
	DEFM	'I can''t create topics below this.',CR,0
M_SUBUSED
	DEFM	'Sorry but the tree at this level is full.',CR
	DEFM	'I can''t create any new subtopics here.',CR,0
M_GETTPC
	DEFM	CR,'New sub-topic name? ',0
M_ALRDYTOP
	DEFM	'Sorry there is already a topic of that name here.',CR,0
M_TPCMDE
	DEFM	'New sub-topic created successfully.',CR,0
M_TPCLNG
	DEFM	'Name too long. Limit it to 15 characters.',CR,0
M_TYPEIN
	DEFM	'Please type in your message now;',CR
	DEFM	'Enter two consecutive empty lines to finish.',CR,CR,0
M_ENDWRN
	DEFM	'Warning: Buffer nearly full. Finish entering your message',CR,0
M_IFABRT
	DEFM	'** Abort this message? (Y/N/Q): ',0
M_DISREG
	DEFM	'OK but last line disregarded.',CR,0
M_FRCEND
	DEFM	'** Buffer full. Message truncated BEFORE your last input line',CR,0
M_INTRO
	DEFM	'Treeboard Network news and echomail system,',CR
	DEFM	'Fidonet node 3:713/602',CR
	DEFM	'ACSnet site 713.602@fidogate.fido.oz',CR
	DEFM	CR,0
M_KLQRY	DEFM	'Ask before killing? (Y/N/Q): ',0
M_MVQRY	DEFM	'Ask before moving? (Y/N/Q): ',0
M_KILLIT
	DEFM	'Kill it? (Y/N/Q): ',0
M_MOVEIT
	DEFM	'Move it? (Y/N/Q): ',0
M_KILLING
	DEFM	'Killing # ',0
M_MOVING
	DEFM	'Moving  # ',0
M_PAUSE	DEFM	'Hit N to see the next message, Q to quit',CR,0
M_TRMPAUSE
	DEFM	CR,'Hit N to continue, T to skip this topic, Q to quit',CR,0
M_APAUSE
	DEFM	'Pause after each message? (Y/N/Q): ',0
;
M_NTOSKP
	DEFM	'Hit <N> skip to the next message, Q to quit.',CR,0
;
M_EDWHLI
	DEFM	'Edit which line? (CR to exit): ',0
M_FILESAFE
	DEFM	'Your file was safely saved.',CR,0
M_FILEFAIL
	DEFM	'File saved but truncated by disk error.',CR,0
M_LONGFILE
	DEFM	'File is too long. Limit it to <10k',CR,0
M_WHATFILE
	DEFM	'Take from which file? ',0
M_RESENDTO
	DEFM	'Resend to: ',0
M_TOPIC1
	DEFM	'Current topic is ',0
M_TOPIC2
	DEFM	CR,0
M_TOPIC3
	DEFM	'Topic:   ',0
M_READHELP
	DEFM	CR,'The following keys are accepted by more:',CR
	DEFM	'  <space>   Display the next page',CR
	DEFM	'  <enter>   Display another line',CR
	DEFM	'     N      Skip to the next message',CR
	DEFM	'     Q      Quit',CR
	DEFM	'     ?      Display this help message',CR
	DEFM	0
;
M_TRMHELP
	DEFM	CR,'The following keys are accepted by more:',CR
	DEFM	'  <space>   Display the next page',CR
	DEFM	'  <enter>   Display another line',CR
	DEFM	'     N      Skip to the next message',CR
	DEFM	'     T      Skip to the next topic',CR
	DEFM	'     Q      Quit',CR
	DEFM	'     ?      Display this help message',CR
	DEFM	0
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++
MENU_MAIN
	DEFW	MU_MAIN
	DEFW	CL_MAIN
	DEFW	MX_MAIN
;
MENU_SPEC
	DEFW	MU_SPEC
	DEFW	CL_SPEC
	DEFW	MX_SPEC
;
MENU_DS1
	DEFW	MU_DS1
	DEFW	CL_DS1
	DEFW	MX_DS1
;
MENU_OPT
	DEFW	MU_OPT
	DEFW	CL_OPT
	DEFW	MX_OPT
;
MENU_QUEST
	DEFW	MU_QUEST
	DEFW	CL_QUEST
	DEFW	MX_QUEST
;
MU_MAIN	DEFM	CR
	DEFM	'<R>  Read Messages           <S>  Scan Messages',CR
	DEFM	'<E>  Enter Message           <K>  Kill Messages',CR
	DEFM	'<T>  Treewalk (read Msgs)    <L>  List subtopics',CR
	DEFM	'<M>  Move Up or Down         <O>  Change/List Options',CR
	DEFM	'<X>  Exit                    <#>  Special commands',CR
	DEFM	0
;
MU_SPEC
	DEFM	'      Special functions',CR
	DEFM	'<M>  Move messages           <#>  Main functions',CR
	DEFM	'<C>  Create new subtopic     <D>  Delete this topic',CR
	DEFM	'<F>  Forward messages        <R>  Resend message',CR
	DEFM	'<S>  Change topic status',CR
	DEFM	0
;
MU_DS1	DEFM	'<A>  ALL Messages           <M>  Messages to you',CR
	DEFM	'<U>  "Unread" Messages      <F>  Messages sent by you',CR
	DEFM	'<enter> No messages',CR
	DEFM	'OR enter a range ie. 1+  20-30  18  $-  etc..',CR,0
;
MU_OPT
	DEFM	CR,'   Set your desired options..',CR
	DEFM	'<1>     You see this topic only',CR
	DEFM	'<2>     You see all topics beneath this',CR
	DEFM	'<3>     Long menus',CR
	DEFM	'<4>     Short menus',CR
	DEFM	'<enter> Change nothing',CR,0
;
MU_QUEST
	DEFM	'<L> List, <E> Edit, <C> Continue, <A> Abort, <S> Save',CR,0
MX_MAIN
	DEFM	'MAIN: (R,S,E,K,T,L,M,O,X,#)',CR,0
MX_SPEC
	DEFM	'Spec: (M,C,D,F,R,S,#)',CR,0
MX_DS1	DEFM	'Msg Select (M,U,A,F,<enter> or range)',CR,0
MX_OPT	DEFM	'Options: (1,2,3,4,<enter>)',CR,0
MX_QUEST
	DEFM	'Msg: (L,E,C,A,S)',CR,0
;
CL_MAIN		DEFM	'RSEKTLMOX#',0
CL_SPEC		DEFM	'MCDFRS#',0
CL_DS1		DEFM	'MUAF',0
CL_OPT		DEFM	'1234',0
CL_QUEST	DEFM	'LECAS',0
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++
MFD_DATA
	DEFM	'General',CR
	DC	16-8,0		;Pad out to 16 chars
	DEFB	0,0
	DEFB	0FFH,00H	;max age 255, no special flags
;
GENERAL	DEFM	'General',0
;
MOVE_RND
	DEFM	8,'U1234567'
;
DUMMY_READ
DUMMY_KILL
	DEFM	';M',CR,0
;
ADD_AND
	DEFB	20H,0E0H,00H
	DEFB	04H,1CH,00H
	DEFB	01H,03H,0E0H
	DEFB	00H,00H,0FCH
;
MASK_DATA
	DEFB	00H,0E0H,0FCH,0FFH
;
M_LINE		DEFB	0
CHAR_FLAG	DEFB	0
NOWRAP		DEFB	0
NETMSG		DEFB	0
TOPIC_BELOW	DEFB	0
SUB_CNT		DEFB	0
TOPIC_CNT	DEFB	0
;;TAG_POSN	DEFB	0
TEMP1		DEFB	0
TEMP2		DEFB	0
;
;Data for Find_top_num routine
FTN_STR		DEFW	0
FTN_NAME	DC	16,0
FTN_TOP		DEFB	0
;
NULL_LINE	DEFB	0
F_WARN		DEFB	0	;8 flags
TEXT_HIMEM	DEFW	0	;max addr to use on input
;
KILL_QUERY	DEFB	0
MOVE_QUERY	DEFB	0
;
OPTIONS		DEFB	0
FO_CURR		EQU	0	;current topic
FO_LOWR		EQU	1	;current and below
FO_NORM		EQU	2	;normal mode
FO_EXP		EQU	3	;expert.
;
HASH_BYTE	DEFB	0
US_NUM		DEFW	0
SCAN_ABORT	DEFB	0
;
CHAR_POSN	DEFW	0
CONTROL		DEFW	0
FUNCNM		DEFW	0
FUNCTION	DEFW	0
SCAN_MASK	DEFB	0
FIRST_MSG	DEFW	0
LAST_MSG	DEFW	0
N_MSG_TOP	DEFW	0
A_TOP_1ST	DEFW	0
A_TOP_LAST	DEFW	0
;
MY_TOPIC	DEFB	0
MY_LEVEL	DEFB	0
TR_TOPIC	DEFB	0	;For 'T' command
TR_LEVEL	DEFB	0	;For 'T' command
TR_OPTIONS	DEFB	0
TR_NEWFLAG	DEFB	0	;1=new topic
TR_SKIP		DEFB	0	;1=skip rest of topic
;
INT_TOP		DEFB	0
;
TEMP_TOPIC	DEFB	0
;
LINES		DEFB	0
;
IN_BUFF		DC	81,0
TOPNAM_BUFF	DC	33,0
NAME_BUFF	DC	81,0
;
USN_BUFF	DC	81,0	;For user_search.
OUTBUF		DC	81,0	;81 chars edit buffer.
;
MEM_PTR		DEFW	0
MEMT_PTR	DEFW	0
EDIT_PTR	DEFW	0
;
FORWARD_ID	DEFW	0
;
TRIES		DEFB	0
;
PAUSE		DEFB	0
TXT_RBA		DEFB	0,0,0	;low/mid/high
START_RBA	DEFB	0,0,0
;
MSG_FOUND	DEFB	0
BACKWARD	DEFB	0
A_MSG_POSN	DEFW	0
MSG_NUM		DEFW	0
TOPIC_MASK	DEFB	0FFH
;
;**************************************************
HDR_LEN	EQU	16				;**
THIS_MSG_HDR					;**
HDR_FLAG	DEFB	0			;**
HDR_LINES	DEFB	0			;**
HDR_RBA		DEFB	0,0,0	;low/mid/high	;**
HDR_DATE	DEFB	0,0,0	;day/mon/yr	;**
HDR_SNDR	DEFW	0	;sender id	;**
HDR_RCVR	DEFW	0	;dest. id	;**
HDR_TOPIC	DEFB	0	;topic code	;**
HDR_TIME	DEFB	0,0,0	;hr/min/sec	;**
;						;**
;flag definitions for bits.			;**
FM_KILLED	EQU	0			;**
FM_PRIVATE	EQU	1			;**
FM_IMPORT	EQU	2			;**
FM_RUDE		EQU	3			;**
FM_NETMSG	EQU	4			;**
FM_NETSENT	EQU	5			;**
;						;**
;**************************************************
;
TXT_FCB	DEFM	'MSGTXT.ZMS',CR
	DC	32-11,0
HDR_FCB	DEFM	'MSGHDR.ZMS',CR
	DC	32-11,0
TOP_FCB	DEFM	'MSGTOP.ZMS',CR
	DC	32-11,0
FILE_FCB
	DC	32,0
;
;**************************************************
TOPIC	;5K bytes for message info.		;**
N_MSG		DEFW	0			;**
N_KLD_MSG	DEFW	0			;**
EOF_RBA		DEFB	0,0,0	;EOF of TXT	;**
		DC	9,0	;Unused		;**
TOPIC_DAT					;**
		DEFS	4080	;204*20 bytes.	;**
MSG_TOPIC					;**
		DEFS	MAX_MSGS		;**
;**************************************************
;
HDR_B	DEFS	256
TOP_B	DEFS	256
FILE_BUF DEFS	256
;
TEXT_BUF
	NOP
;
;End of BBdata
