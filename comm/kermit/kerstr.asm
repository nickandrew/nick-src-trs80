;kerstr/asm.
;Pure storage.
OUTLN2	DB	CR,'Number of packets:'
	DB	CR,'Number of retries:'
	DB	CR,'File name:$'
KERM	DB	'Kermit Trs-80'
KERM1	DB	'>$'
;DELPR:	DB	'Delete it? $'
CRLF	DB	CR,'$'
ERMES1	DB	CR,'?Unrecognized command$'
ERMES2	DB	CR,'?Illegal character$'
ERMES3	DB	CR,'?Not confirmed$'
ERMES4	DB	'?Unable to receive initiate',CR,'$'
ERMES5	DB	'?Unable to receive file name',CR,'$'
ERMES6	DB	'?Unable to receive end of file',CR,'$'
ERMS10	DB	'?Unable to receive data',CR,'$'
ERMS11	DB	'?System DOS error',CR,'$'
ERMS14	DB	'?Unable to receive an acknowledgement from the host',CR,'$'
ERMS15	DB	CR,'?Unable to find file',CR,'$'
ERMS16	DB	'?Unable to rename file$'
ERMS17	DB	CR,'?System DOS error$'
ERMS18	DB	CR,'?Unable to tell host that the session is finished$'
ERMS19	DB	CR,'?Unable to tell host to logout$'
INFMS3	DB	BELL,'Completed$'
INFMS4	DB	BELL,'Failed$'
INFMS5	DB	'%Renaming file to $'
INFMS6	DB	CR,'<Closing the log file>$'
INFMS7	DB	CR,'<Connected to remote host, type $'
INFMS8	DB	'C to return>',CR
	DB	'<CLEAR> is Control-',95,CR,'$'
INFMS9	DB	CR,'<Connection closed, back at micro>$'
INMS10	DB	' Control-$'
INMS11	DB	' (Type Left Arrow to send CTRL-S)',CR,'$'
INMS12	DB	' (Not implemented)',CR,'$'
INMS13	DB	BELL,'Interrupted$'
DNAM14	DB	'DIR  :'
DIRSPEC	DB	'0',CR
;INMS15:	DB	CR,TAB,TAB,'Drive $'
;INMS16:	DB	'  has $';filled in by summary code with drive letter
;INMS17:	DB	'K bytes free',CR,'$'
INMS18	DB	CR,'File KILLED$',CR
BADDRV	DB	CR,'++ Bad drive name$',CR
CFRMES	DB	' Confirm with <ENTER>, cancel with <BREAK> $'
;FILHLP:	DB	' Input file spec $'
ESCMES	DB	CR,'Type the new escape character:  $'
TOPHLP	DB	CR,'BYE to host (LOGOUT) and exit to DOS'
	DB	CR,'CONNECT to host on selected port'
	DB	CR,'DIR of local disk'
	DB	CR,'EXIT to DOS'
	DB	CR,'FINISH running Kermit on the host'
	DB	CR,'HELP by giving this message'
	DB	CR,'KILL a file'
	DB	CR,'LOG the terminal session to a file'
	DB	CR,'LOGOUT the host'
	DB	CR,'RECEIVE file from host'
	DB	CR,'SEND file to host'
	DB	CR,'SET a parameter'
	DB	CR,'SHOW the parameters'
	DB	CR,'STATUS of Kermit$'
SETHLP	DB	CR,'BAud (rate)'
	DB	CR,'BLock-check-type (for error detection'
	DB	CR,'DEBugging mode (to display packets)'
;	DB	CR,'DEFault-disk (to receive data)'
	DB	CR,'Escape (character during CONNECT)'
	DB	CR,'File-mode (obsolete)'
	DB	CR,'Ibm (parity and turn around handling)'
	DB	CR,'Local-echo (half/duplex)'
	DB	CR,'PArity (for communication line)'
	DB	CR,'POrt (to communicate on)'
	DB	CR,'PRinter (to print terminal session)'
;*	DB      CR,LF,'RECEIVE (parameter)'	;Not currently implemented
;*	DB      CR,LF,'SEND (parameter)'	;Ditto
	DB	CR,'Vt52-emulation'
	DB	CR,'Warning (for filename conflicts)'
	DB	'$'
STSHLP	DB	CR,'PAD-CHAR'
	DB	CR,'PADDING$'
BLKHLP	DB	CR,'1-CHARACTER-CHECKSUM'
	DB	CR,'2-CHARACTER-CHECKSUM'
	DB	CR,'3-CHARACTER-CRC-CCITT$'
PARHLP	DB	CR,'EVEN   MARK  NONE   ODD   SPACE$'
ONHLP	DB	CR,'OFF  ON$'
YESHLP	DB	CR,'NO   YES$'
PRTHLP	DB	CR,'STANDARD RS232 port$'
INTHLP	DB	CR,'?  This message'
	DB	CR,'C  Close the connection'
	DB	CR,'0  (zero) Transmit a NULL'
	DB	CR,'S  Status of the connection'
	DB	CR,'Type the escape character again to send it to the host'
	DB	CR,CR,'Command>$'
ONSTR	DB	' on$'
OFFSTR	DB	' off$'
LOCST	DB	CR,'Local echo$'
DEFSTR	DB	' default$'
ASCSTR	DB	' ASCII$'
BINSTR	DB	' binary$'
TYPHLP	DB	CR,'ASCII     BINARY     DEFAULT$'
SPDHLP	DB	CR,'     50     75     110   134.5    150   300   600    1200'
	DB	CR,'   1800   2000    2400    3600   4800  7200  9600   19200$'
VTEMST	DB	CR,'VT52 emulation$'
CPMST	DB	CR,'File Mode$'
IBMST	DB	CR,'IBM flag$'
FILST	DB	CR,'File warning$'
PNTSTR	DB	CR,'Printer$'
ESCST	DB	CR,'Escape char: $'
BUGST	DB	CR,'Debugging mode$'
PARST	DB	CR,'Parity: $'
BCKST	DB	CR,'Block check type: $'
BCKST1	DB	'-character$'
PNONST	DB	'none$'
PMRKST	DB	'mark$'
PSPCST	DB	'space$'
PODDST	DB	'odd$'
PEVNST	DB	'even$'
SPEDST	DB	'Line Speed: $'
BAUST	DB	' Baud',CR,'$'
OUTLIN	DB	28,31,CR,'$'
VERSIO	DM	'Kermit-80 V 4.0 (TRS-80/Sys80 Model 1/3)',CR,'$'
DELSTR	DB	10O,' ',10O,'$'
CLRSPC	DB	' ',8,'$'
CLRLIN	DB	29,30,'$'
SCRNP	DB	28,26,26,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,'$';place for packets
SCRNRT	DB	28,26,26,26,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,'$';place for retries
SCRST	DB	28,'$'		;place for complete
SCRFLN	DB	28,26,26,26,26,25,25,25,25,25,25,25,25,25,25,25,'$';place for filename
SCRERR	DB	28,26,26,26,26,26,26,'$';location for errors
SCREND	DB	28,26,26,26,26,26,26,26,26,26,26,26,26,'$';location of last line
RPPOS	DB	28,26,26,26,26,26,26,26,31,'RPack: $'
SPPOS	DB	28,26,26,26,26,26,26,26,26,26,26,31,'SPack: $'
TA	DB	1BH,'$',0,0	;cursor up
TB	DB	1AH,'$',0,0	;cursor down
TC	DB	19H,'$',0,0	;cursor right
TD	DB	18H,'$',0,0	;cursor left
CLRTOP	DB	1CH,1FH,'$',0	;clear screen
TF	DB	'$',0,0,'$'
TG	DB	'$',0,0,'$'
TH	DB	1CH,'$',0,0	;cursor home
TI	DB	1BH,'$',0,0	;reverse line feed
TJ	DB	1FH,'$',0,0	;clear to end  of screen
TK	DB	1EH,'$'		;clear  to end of line
;
;	COMND tables
;
;	Structure of command table:	[UTK008]
;
;	1) Number of entries.
;	2) Each entry is arranged as follows:
;		a) length of command in bytes.
;		b) 'name of command and $-sign'
;		c) offset into command table at KERMTB:
;		d) offset into command table at KERMTB:
;
;	---> Note this command table is in alphabetic order.
;
COMTAB	DB	10H		;Number of entries (currently 16.)
	DB	03H,'BYE$',21H,21H
	DB	07H,'CONNECT$',00H,00H
	DB	03H,'DIR$',24H,24H
	DB	03H,'ERA$',27H,27H
	DB	04H,'EXIT$',03H,03H
	DB	06H,'FINISH$',1BH,1BH
	DB	03H,'GET$',0CH,0CH;Same as RECEIVE
	DB	04H,'HELP$',06H,06H
	DB	04H,'KILL$',27H,27H;SAME AS ERA
	DB	03H,'LOG$',09H,09H
	DB	06H,'LOGOUT$',1EH,1EH
	DB	07H,'RECEIVE$',0CH,0CH
	DB	04H,'SEND$',0FH,0FH
	DB	03H,'SET$',12H,12H
	DB	04H,'SHOW$',15H,15H
	DB	06H,'STATUS$',18H,18H
SETTAB	DB	0CH		;Number of entries (currently 12.)
	DB	04H,'BAUD$',21H,21H;Data keys to SETJTB positions.
	DB	10H,'BLOCK-CHECK-TYPE$',18H,18H
	DB	09H,'DEBUGGING$',27H,27H
;*	DB	0CH,'DEFAULT-DISK$',24H,24H
	DB	06H,'ESCAPE$',00H,00H
	DB	09H,'FILE-MODE$',12H,12H
	DB	03H,'IBM$',03H,03H
	DB	0AH,'LOCAL-ECHO$',06H,06H
	DB	06H,'PARITY$',15H,15H
	DB	04H,'PORT$',1EH,1EH
	DB	07H,'PRINTER$',24H,24H
;*	DB	07H,'RECEIVE$',09H,09H	;Not implemented yet.
;*	DB	04H,'SEND$',0CH,0CH	;Ditto
	DB	0EH,'VT52-EMULATION$',1BH,1BH
	DB	07H,'WARNING$',0FH,0FH
STSNTB	DB	02H
	DB	08H,'PAD-CHAR$',00H,00H
	DB	07H,'PADDING$',03H,03H
BLKTAB	DB	03H
	DB	14H,'1-CHARACTER-CHECKSUM$','1','1'
	DB	14H,'2-CHARACTER-CHECKSUM$','2','2'
	DB	15H,'3-CHARACTER-CRC-CCITT$','3','3'
PARTAB	DB	05H		;Five entries.
	DB	04H,'EVEN$',PAREVN,PAREVN
	DB	04H,'MARK$',PARMRK,PARMRK
	DB	04H,'NONE$',PARNON,PARNON
	DB	03H,'ODD$',PARODD,PARODD
	DB	05H,'SPACE$',PARSPC,PARSPC
ONTAB	DB	02H		;Two entries.
	DB	02H,'ON$',01H,01H
	DB	03H,'OFF$',00H,00H
TYPTAB	DB	03H		;Three entries
	DB	05H,'ASCII$',01H,01H
	DB	06H,'BINARY$',02H,02H
	DB	07H,'DEFAULT$',00H,00H
PRTTAB	DB	01H		;Only one port known at this point
	DB	08H,'STANDARD$'
;;;	DW	MNPORT,MNPORT			;********
	DEFW	RDDATA,RDDATA	;********
				;what the hell for??
YESTAB	DB	02H		;Two entries.
	DB	02H,'NO$',00H,00H
	DB	03H,'YES$',01H,01H
CMER00	DB	CR,'?Program error:  Invalid COMND call$'
CMER01	DB	CR,'?Ambiguous$'
CMER02	DB	CR,'?Illegal input file spec$'
CMIN00	DB	' Confirm with <ENTER>, Cancel with <BREAK>$'
CMCRLF	DB	CR,'$'
SPDTAB	DB	10H		;16 entries
	DB	2,'50$',0,0
	DB	02H,'75$',11H,11H
	DB	03H,'110$',22H,22H
	DB	05H,'134.5$',33H,33H
	DB	03H,'150$',44H,44H
	DB	03H,'300$',55H,55H
	DB	03H,'600$',66H,66H
	DB	04H,'1200$',77H,77H
	DB	04H,'1800$',88H,88H
	DB	04H,'2000$',99H,99H
	DB	04H,'2400$',0AAH,0AAH
	DB	04H,'3600$',0BBH,0BBH
	DB	04H,'4800$',0CCH,0CCH
	DB	04H,'7200$',0DDH,0DDH
	DB	04H,'9600$',0EEH,0EEH
	DB	05H,'19200$',0FFH,0FFH
	;Impure data
;COMND storage
CMSTAT	DS	1		;What is presently being parsed.
CMAFLG	DS	1		;Non-zero when an action char has been found.
CMCCNT	DS	1		;Non-zero if a significant char is found.
CMSFLG	DS	1		;Non-zero when the last char was a space.
CMOSTP	DS	2		;Old stack pointer for reparse.
CMRPRS	DS	2		;Address to go to on reparse.
CMPRMP	DS	2		;Address of prompt.
CMPTAB	DS	2		;Address of present keyword table.
CMHLP	DS	2		;Address of present help.
CMDBUF	DS	80H		;Buffer for command parsing.
CMFCB	DS	2		;Pointer to FCB.
;CMFCB2:	DS	2		;Pointer to position in FCB.
CMCPTR	DS	2		;Pointer for next char input.
CMDPTR	DS	2		;Pointer into the command buffer.
CMKPTR	DS	2		;Pointer to keyword.
CMSPTR	DS	2		;Place to save a pointer.
OLDSP	DS	2		;Room for old system stack.
	DS	100H		;Room for lots of calls
STACK	DS	2
EOFLAG	DS	1		;EOF flag; non-zero on EOF.
FILFLG	DS	1		;NON-ZERO WHEN FILE NOT OPEN
LSTCHR	DB	0		;Last character in disk i/o
;CURDSK:	DB	0		;holds "logged" disk
LOGFLG	DB	0		;Flag for a log file.
ECOFLG	DB	0		;Local echo flag (default off).
ESCFLG	DB	0		;Escape flag (start off).
VTFLG	DB	1		;VT52 emulation flag (default on).
FLWFLG	DB	1		;file warning flag (default on)
IBMFLG	DB	0		;IBM flag (default off).
CPMFLG	DB	0		;File was created by DOS
DBFLG	DB	DIASW		;debugging flag.
PRTFLG	DB	0		;printer flag (default off)
PARITY	DB	DEFPAR		;Parity.
ESCCHR	DB	DEFESC		;Storage for the escape character.
CHRCNT	DS	1		;Number of chars in the file buffer.
FILCNT	DS	1		;Number of chars left to fill.
PORT	DS	1		;port for communications
OUTPNT	DS	2		;Position in packet.
BUFPNT	DS	2		;Position in file buffer.
FCBPTR	DS	2		;Position in FCB.
;FCBEXT	DS	2
DATPTR	DS	2		;Position in packet data buffer.
LOGPTR	DW	LBUFF		;pointer into log file buffer
CBFPTR	DS	2		;Position in character buffer.
PKTPTR	DS	2		;Poistion in receive packet.
SIZE	DS	1		;Size of data from gtchr.
SPEED	DB	DBAUD		;baud rate
;
;*** My & your defaults .... ***
;
SPSIZ	DB	DSPSIZ		;Send packet size.
STIME	DB	DSTIME		;Send time out.
SPAD	DB	DSPAD		;Send padding.
SPADCH	DB	DSPADC		;Send padding char.
SEOL	DB	DSEOL		;Send EOL char.
SQUOTE	DB	DSQUOT		;Send quote char.
SQUOTE8	DEFB	DSQUOTE8	;Send 8'th bit quote
SQUOTER	DEFB	DSQUOTER	;Send repeat quote
;
RPSIZ	DB	DRPSIZ		;Receive packet size.
RTIME	DB	DRTIME		;Receive time out.
RPAD	DB	DRPAD		;Receive padding.
RPADCH	DB	DRPADC		;Receive padding char.
REOL	DB	DREOL		;Receive EOL char.
RQUOTE	DB	DRQUOT		;Receive quote char.
RQUOTE8	DEFB	DRQUOTE8	;Receive quote8
RQUOTER	DEFB	DRQUOTER	;Receive quoter
;
;
BIT7_FLAG	DEFB	0	;Receive prior quoted B7.
;
CHKTYP	DB	DSCHKT		;Checksum type desired
CURCHK	DB	DSCHKT		;Current checksum type
INICHK	DB	DSCHKT		;Agreed upon checksum type
;
CZSEEN	DS	1		;Flag that control-Z was typed
MFNPTR	DW	MFNBUF		;multiple file processing buffer
PKTNUM	DS	1		;Packet number.
NUMPKT	DS	2		;Total number of packets sent.
NUMRTR	DS	2		;Total number of retries.
NUMTRY	DS	1		;Number of tries on this packet.
OLDTRY	DS	1		;Number of tries on previous packet.
STATE	DS	1		;Present state of the automaton.
PACKET	DS	4		;Packet (data is part of it).
DATA	DS	5AH		;Data and checksum field of packet.
RECPKT	DS	60H		;Receive packet storage (use the following).
FILBUF	DS	60H		;Character buffer.
;** Temp 1 & 2 must be in order
TEMP1	DS	1		;Temporary storage.
TEMP2	DS	1
TEMP3	DS	1
TEMP4	DS	1
;	Data storage for MFNAME (multi-file access)
MFREQ	DS	32		;Requested name
MFNBUF	DS	7AH		;filename buffer
;
FCB	DS	50		;file control block
LFCB	DS	50		;log file fcb
KFCB	DS	50		;kill file fcb
BUFF	DS	256		;file buffer
LBUFF	DS	256		;log file buffer
ARGBLK	DS	20H		;Used for subroutine arguments.
;
