;xfer/asm
;	FILE ROUTINES
;	OUTPUT THE CHARS IN A PACKET.
PTCHR	LD	(TEMP1),A	;SAVE THE SIZE.
	LD	HL,DATA		;BEGINNING OF RECEIVED PACKET DATA.
	LD	(OUTPNT),HL	;REMEMBER WHERE WE ARE.
	LD	A,(RQUOTE)
	LD	B,A		;KEEP THE QUOTE CHAR IN B.
PTCHR1	LD	HL,TEMP1
	DEC	(HL)		;DECREMENT # OF CHARS IN PACKET.
	JP	M,RSKP		;RETURN SUCCESSFULLY IF DONE.
PTCHR2	LD	HL,(OUTPNT)	;GET POSITION IN OUTPUT BUFFER.
	LD	A,(HL)		;GRAB A CHAR.
	INC	HL
	LD	(OUTPNT),HL	;AND BUMP POINTER.
	LD	C,A
	LD	A,0
	LD	(BIT7_FLAG),A
	LD	A,(RQUOTE8)
	CP	' '		;if no bit 7 quoting
	JR	Z,PTCHR2A	;then use 8 bits A asis.
	CP	C
	JR	NZ,PTCHR2A	;if char is not &
	LD	A,80H		;for >= 80h.
	LD	(BIT7_FLAG),A
;Bump over '&' to next char.
	LD	HL,TEMP1
	DEC	(HL)		;should check for empty buffer
	LD	HL,(OUTPNT)
	LD	A,(HL)
	INC	HL
	LD	(OUTPNT),HL
	LD	C,A
PTCHR2A	LD	A,C
	CP	B		;IS IT '#' control quote?
	JP	NZ,PTCHR4	;IF NOT PROCEED.
	LD	A,(HL)		;GET THE QUOTED CHARACTER
	INC	HL
	LD	(OUTPNT),HL	;AND BUMP POINTER.
	LD	HL,TEMP1
	DEC	(HL)		;DECREMENT # OF CHARS IN PACKET.
	LD	D,A		;SAVE THE CHAR.
;Sys3 Kermit quotes a character in the range 80-9F
;so if this char is quoted then retain bit 7 contents.
;Foolish, I'd say but thats what happens.
	AND	7FH
;A3 etc.. now become 23 etc...
;for 3f-5f inclusive change to 7f,00-1f.
;All others leave asis. ALWAYS retain bit 7 contents.
;Check for @AB...YZ,5b,\,],^,_
	CP	3FH
	JR	C,PTCHR2D	;if outside normal
	CP	60H		;quote range then
	JR	NC,PTCHR2D	;leave asis.
	LD	A,D		;use orig. see mod above!
	XOR	40H		;make ctl char or DEL
				;or 80-9Fh.
	JR	PTCHR4		;end of transforms.
PTCHR2D	LD	A,D		;get back original +b7.
PTCHR4
;Mod by nick... add in bit 7 (if QUOTE8 and & before).
	LD	C,A
	LD	A,(BIT7_FLAG)
	ADD	A,C
;
	LD	DE,FCB
	CALL	@PUT		;output character to file
	JP	NZ,QUIT		;bad write
	JP	PTCHR1
;
;	GET THE CHARS FROM THE FILE.
GTCHR	LD	A,(SQUOTE)	;GET THE QUOTE CHAR.
	LD	C,A		;KEEP QUOTE CHAR IN C.
	LD	A,(EOFLAG)
	OR	A
	RET	NZ
	LD	A,(FILFLG)	;GET THE FILE FLAG.
	OR	A		;IS THERE ANYTHING IN THE DMA?
	JR	Z,GTCHR0	;YUP, PROCEED.
	LD	B,0		;NO CHARS YET.
GTCHR0	LD	A,(CURCHK)	;GET CURRENT BLOCK CHECK TYPE
	SUB	'1'		;GET THE EXTRA OVERHEAD
	LD	B,A		;GET A COPY
	LD	A,(SPSIZ)	;GET THE MAXIMUM PACKET SIZE.
	SUB	5		;SUBTRACT THE OVERHEAD.
	SUB	B		;DETERMINE MAX PACKET LENGTH
	LD	(TEMP1),A	;THIS IS THE NUMBER OF CHARS WE ARE TO GET.
	LD	HL,FILBUF	;WHERE TO PUT THE DATA.
	LD	(CBFPTR),HL	;REMEMBER WHERE WE ARE.
	LD	B,0		;NO CHARS.
GTCHR1	LD	A,(TEMP1)
	DEC	A		;DECREMENT THE NUMBER OF CHARS LEFT.
	CP	3
	JR	NC,GTCHR2	;more quoted chars poss.
	LD	A,B		;RETURN THE COUNT IN A.
	JP	RSKP
GTCHR2	LD	(TEMP1),A
GTCHR4	LD	DE,FCB
	CALL	@GET		;get a character
	JP	NZ,GTCHR9
GTCR4A	LD	D,A		;SAVE THE CHAR.
;Mod by nick. This bit of code has bugs maybe?
GTCR4B	AND	80H		;test bit 7
	JR	Z,GTCHR4D	;jump if <80h
	LD	A,(SQUOTE8)
	CP	' '		;ie: no 8'th bit quoting.
	JR	Z,GTCHR4E	;dont quote. leave asis.
	LD	HL,TEMP1	;do quote
	DEC	(HL)		;should chk end of buffer
	LD	HL,(CBFPTR)
	LD	(HL),A
	INC	HL
	LD	(CBFPTR),HL
	INC	B
;
GTCHR4D	LD	A,D		;RESTORE THE CHAR.
	AND	7FH		;TURN OFF bit 7
	LD	D,A
GTCHR4E	LD	A,D
	LD	(LSTCHR),A	;SAVE THIS CHARACTER 
	CP	' '		;COMPARE TO A SPACE.
	JR	C,GTCHR7	;IF CONTROL CHAR, HANDLE IT.
	CP	DEL		;IS THE CHAR A DELETE?
	JR	Z,GTCHR7	;if so handle as control.
	CP	C
	JR	Z,GTCHR4C	;if # quote.
	LD	A,(SQUOTE8)	;&
	CP	' '		;don't quote space since
	LD	A,D		;no 8'th bit quoting done
	JR	Z,GTCHR8	;...
	LD	A,(SQUOTE8)	;non-blank.
	CP	D
	JR	Z,GTCHR4C	;if '&' then quote with #
	LD	A,D
	JR	GTCHR8		;otherwise leave asis.
GTCHR4C				;Handle escaping of # or &.
	LD	HL,TEMP1	;POINT TO THE CHAR TOTAL REMAINING.
	DEC	(HL)		;DECREMENT IT.
	LD	HL,(CBFPTR)	;POSITION IN CHARACTER BUFFER.
	LD	(HL),C		;put quote in buffer.
	LD	A,D		;get char back.
	INC	HL
	LD	(CBFPTR),HL
	INC	B		;INCREMENT THE CHAR COUNT.
	JR	GTCHR8		;next char asis.
;
;gtchr7: Handle control char escaping. #A to #?
GTCHR7	LD	(TEMP2),A	;SAVE THE CHAR.
	LD	HL,TEMP1	;POINT TO THE CHAR TOTAL REMAINING.
	DEC	(HL)		;DECREMENT IT.
	LD	HL,(CBFPTR)	;POSITION IN CHARACTER BUFFER.
	LD	(HL),C		;PUT THE QUOTE IN THE BUFFER.
	INC	HL
	LD	(CBFPTR),HL
	INC	B		;INCREMENT THE CHAR COUNT.
	LD	A,(TEMP2)	;GET THE CONTROL CHAR BACK.
;Mod by Nick. XOR 40H swap bit 6...
;   DEL = 7F becomes 3F
;   00-1F    becomes 40-5F.
	XOR	40H
GTCHR8	LD	HL,(CBFPTR)	;POSITION IN CHARACTER BUFFER.
	LD	(HL),A		;PUT THE CHAR IN THE BUFFER.
	INC	HL
	LD	(CBFPTR),HL
	INC	B		;INCREMENT THE CHAR COUNT.
	JP	GTCHR1
GTCHR9	LD	A,0FFH
	LD	(EOFLAG),A
	LD	A,B
	JP	RSKP
;
;MULTI-FILE ACCESS SUBROUTINE.  ALLOWS PROCESSING OF MULTIPLE FILES
;(I.E., *.ASM) FROM DISK.  THIS ROUTINE BUILDS THE PROPER NAME IN THE
;FCB EACH TIME IT IS CALLED.  THIS COMMAND WOULD BE USED IN SUCH PRO-
;GRAMS SUCH AS MODEM TRANSFER, TAPE SAVE, ETC. IN WHICH YOU WANT TO
;PROCESS SINGLE OR MULTIPLE FILES.
;
;THE FCB WILL BE SET UP WITH THE NEXT NAME, READY TO DO NORMAL PROCES-
;SING (OPEN, READ, ETC.) WHEN ROUTINE IS CALLED.
;
;CARRY IS SET IF NO MORE NAMES CAN BE FOUND
;
;MFFLG1 IS COUNT/SWITCH [0 FOR FIRST TIME THRU, POS FOR ALL OTHERS]
;MFFLG2 IS COUNTED DOWN FOR EACH SUCCESSIVE GETNEXT FILE CALL
MFNAME	JP	NC,MFN00
	CCF			;CLEAR CARRY
MFN00	PUSH	BC		;SAVE REGISTERS
	PUSH	DE
	PUSH	HL
	LD	B,50
	LD	HL,FCB
MFN0A	LD	(HL),20H
	INC	HL
	DJNZ	MFN0A
	LD	B,32
	LD	HL,MFREQ
MFN0B	LD	(HL),20H
	INC	HL
	DJNZ	MFN0B
	LD	HL,(MFNPTR)
	LD	DE,MFREQ
	CALL	@FSPEC
	LD	(MFNPTR),HL
	JR	NZ,MFFIX2
MFN01	LD	HL,MFREQ	;SFIRST REQ NAME
	LD	DE,FCB
	CALL	@FSPEC		;MOVE TO FCB
MFFIX1	POP	HL		;RESTORE REGISTERS
	POP	DE
	POP	BC
	RET			;AND RETURN
MFFIX2	SCF			;SET CARRY
	JR	MFFIX1		;RETURN WITH CARRY SET
GETFIL	LD	A,0FFH
	LD	(FILFLG),A	;NOTHING IN THE DMA.
	XOR	A
	LD	(EOFLAG),A	;NOT THE END OF FILE.
	LD	(LSTCHR),A
	PUSH	HL
	LD	DE,FCB
	LD	HL,BUFF
	CALL	@OPEN
	POP	HL
	JP	NZ,ERRORD
	JP	RSKP
GOFIL	LD	HL,DATA		;GET THE ADDRESS OF THE FILE NAME.
	LD	(DATPTR),HL	;STORE THE ADDRESS.
	LD	HL,FCB		;ADDRESS OF THE FCB.
	LD	(FCBPTR),HL	;SAVE IT.
	XOR	A
	LD	(TEMP1),A	;INITIALIZE THE CHAR COUNT.
	LD	(TEMP2),A
	LD	B,50
GOFIL1	LD	(HL),20H	;BLANK THE FCB.
	INC	HL
	DJNZ	GOFIL1
GOFIL2	LD	HL,(DATPTR)	;GET THE NAME FIELD.
	LD	A,(HL)
	INC	HL
	LD	(DATPTR),HL
	CP	'.'		;SEPaRATOR?
	JP	NZ,GOFIL3
	LD	A,(TEMP1)
	LD	(TEMP2),A
	XOR	A
	LD	(TEMP1),A
	JP	GOFIL5
GOFIL3	OR	A		;TRAILING NULL?
	JP	Z,GOFIL7	;THEN WE'RE DONE.
	LD	HL,(FCBPTR)
	LD	(HL),A
	INC	HL
	LD	(FCBPTR),HL
	LD	A,(TEMP1)	;GET THE CHAR COUNT.
	INC	A
	LD	(TEMP1),A
	CP	8H		;ARE WE FINISHED WITH THIS FIELD?
	JP	M,GOFIL2
GOFIL4	LD	(TEMP2),A
	XOR	A
	LD	(TEMP1),A
	LD	HL,(DATPTR)
	LD	A,(HL)
	INC	HL
	LD	(DATPTR),HL
	OR	A
	JP	Z,GOFIL7
	CP	'.'		;IS THIS THE TERMINATOR?
	JP	NZ,GOFIL4	;GO UNTIL WE FIND IT.
GOFIL5	LD	HL,(FCBPTR)
	LD	(HL),'/'	;PUT IN A SLASH
	INC	HL
	LD	(FCBPTR),HL
GOFIL6	LD	HL,(DATPTR)	;GET THE TYPE FIELD.
	LD	A,(HL)
	INC	HL
	LD	(DATPTR),HL
	OR	A		;TRAILING NULL?
	JP	Z,GOFIL7	;THEN WE'RE DONE.
	LD	HL,(FCBPTR)
	LD	(HL),A
	INC	HL
	LD	(FCBPTR),HL
	LD	A,(TEMP1)	;GET THE CHAR COUNT.
	INC	A
	LD	(TEMP1),A
	CP	03H		;ARE WE FINISHED WITH THIS FIELD?
	JP	M,GOFIL6
GOFIL7	LD	HL,(DATPTR)
	LD	(HL),'$'	;PUT IN A DOLLAR SIGN FOR PRINTING.
	LD	DE,SCRFLN	;POSITION CURSOR
	CALL	PRTSTR
	LD	DE,DATA		;PRINT THE FILE NAME
	CALL	PRTSTR
	LD	HL,(FCBPTR)
	LD	(HL),3		;PUT TERMINATOR IN FCB
	LD	A,(FLWFLG)	;IS FILE WARNING ON?
	OR	A
	JP	Z,GOFIL9	;IF NOT, JUST PROCEED.
	LD	DE,FCB
	LD	HL,BUFF
	CALL	@OPEN
	JP	NZ,GOFIL9	;IF NOT CREATE IT.
	LD	DE,INFMS5
	CALL	ERROR3
	LD	DE,FCB
	CALL	@CLOSE		;close opened file
GOFIL8	LD	HL,(FCBPTR)	;make a new filename
GOFL8A	DEC	HL
GOFL8B	LD	A,(HL)
	CP	'B'
	JR	C,GOFL8A	;TOO SMALL
	DEC	(HL)		;DECREMENT CHARACTER
	LD	(FCBPTR),HL
	LD	DE,FCB		;new file name ok?
	LD	HL,BUFF
	CALL	@OPEN
	JP	NZ,GOFL89	;yes!
	LD	DE,FCB
	CALL	@CLOSE
	LD	HL,(FCBPTR)
	OR	A
	SBC	HL,DE
	JR	NZ,GOFIL8	;TRY AGAIN
GOFL88	LD	DE,ERMS16	;TELL USER THAT WE CAN'T RENAME IT.
	CALL	PRTSTR
	RET
GOFL89	LD	HL,FCB		;move it for usage by other routines
	LD	DE,MFREQ
	CALL	@FSPEC
	LD	A,':'
	LD	BC,14
	LD	HL,MFREQ
	CPIR
	INC	HL
	LD	(HL),'$'
	LD	DE,MFREQ
	CALL	PRTSTR
GOFIL9	XOR	A
	LD	(LSTCHR),A
	LD	DE,FCB
	LD	HL,BUFF
	CALL	@INIT
	JP	Z,RSKP
	PUSH	AF
	LD	DE,ERMS11
	CALL	ERROR3
	POP	AF
	JP	ERRORD
;	PACKET ROUTINES
;SEND_PACKET
;THIS ROUTINE ASSEMBLES A PACKET FROM THE ARGUMENTS GIVEN AND SENDS IT
;TO THE HOST.
;
;EXPECTS THE FOLLOWING:
;	A        - TYPE OF PACKET (D,Y,N,S,R,E,F,Z,T)
;	ARGBLK   - PACKET SEQUENCE NUMBER
;	ARGBLK+1 - NUMBER OF DATA CHARACTERS
;RETURNS: +1 ON FAILURE
;	   +2 ON SUCCESS
SPACK	LD	(ARGBLK+2),A
	LD	HL,PACKET	;GET ADDRESS OF THE SEND PACKET.
	LD	A,SOH		;GET THE START OF HEADER CHAR.
	LD	(HL),A		;PUT IN THE PACKET.
	INC	HL		;POINT TO NEXT CHAR.
	LD	A,(CURCHK)	;GET CURRENT CHECKSUM TYPE
	SUB	'1'		;DETERMINE EXTRA LENGTH OF CHECKSUM
	LD	B,A		;COPY LENGTH
	LD	A,(ARGBLK+1)	;GET THE NUMBER OF DATA CHARS.
	ADD	A,' '+3		;REAL PACKET CHARACTER COUNT MADE PRINTABLE.
	ADD	A,B		;DETERMINE OVERALL LENGTH
	LD	(HL),A		;PUT IN THE PACKET.
	INC	HL		;POINT TO NEXT CHAR.
	LD	BC,0		;ZERO THE CHECKSUM AC.
	LD	C,A		;START THE CHECKSUM.
	LD	A,(ARGBLK)	;GET THE PACKET NUMBER.
	ADD	A,' '		;ADD A SPACE SO THE NUMBER IS PRINTABLE.
	LD	(HL),A		;PUT IN THE PACKET.
	INC	HL		;POINT TO NEXT CHAR.
	ADD	A,C
	LD	C,A		;ADD THE PACKET NUMBER TO THE CHECKSUM.
	LD	A,0		;CLEAR A (CANNOT BE XOR A, SINCE WE CAN'T TOUCH CARRY FLAG)
	ADC	A,B		;GET HIGH ORDER PORTION OF CHECKSUM
	LD	B,A		;COPY BACK TO B
	LD	A,(ARGBLK+2)	;GET THE PACKET TYPE.
	LD	(HL),A		;PUT IN THE PACKET.
	INC	HL		;POINT TO NEXT CHAR.
	ADD	A,C
	LD	C,A		;ADD THE PACKET NUMBER TO THE CHECKSUM.
	LD	A,0		;CLEAR A
	ADC	A,B		;GET HIGH ORDER PORTION OF CHECKSUM
	LD	B,A		;COPY BACK TO B
SPACK2	LD	A,(ARGBLK+1)	;GET THE PACKET SIZE.
	OR	A		;ARE THERE ANY CHARS OF DATA?
	JP	Z,SPACK3	;NO, FINISH UP.
	DEC	A		;DECREMENT THE CHAR COUNT.
	LD	(ARGBLK+1),A	;PUT IT BACK.
	LD	A,(HL)		;GET THE NEXT CHAR.
	INC	HL		;POINT TO NEXT CHAR.
	ADD	A,C
	LD	C,A		;ADD THE PACKET NUMBER TO THE CHECKSUM.
	LD	A,0		;CLEAR A
	ADC	A,B		;GET HIGH ORDER PORTION OF CHECKSUM
	LD	B,A		;COPY BACK TO B
	JP	SPACK2		;GO TRY AGAIN.
SPACK3	LD	A,(CURCHK)	;GET THE CURRENT CHECKSUM TYPE
	CP	'2'		;TWO CHARACTER?
	JP	Z,SPACK4	;YES, GO HANDLE IT
	JP	NC,SPACK5	;NO, GO HANDLE CRC IF '3'
	LD	A,C		;GET THE CHARACTER TOTAL.
	AND	0C0H		;TURN OFF ALL BUT THE TWO HIGH ORDER BITS.
;	RRC
;	RRC
;	RRC
;	RRC
;	RRC
;	RRC			;SHIFT THEM INTO THE LOW ORDER POSITION.
	RLCA			;TWO LEFT ROTATES SAME AS 6 RIGHTS
	RLCA			;.  .  .
	ADD	A,C		;ADD IT TO THE OLD BITS.
	AND	3FH		;TURN OFF THE TWO HIGH ORDER BITS.  (MOD 64)
	ADD	A,' '		;ADD A SPACE SO THE NUMBER IS PRINTABLE.
	LD	(HL),A		;PUT IN THE PACKET.
	INC	HL		;POINT TO NEXT CHAR.
	JP	SPACK7		;GO STORE EOL CHARACTER
;HERE FOR 3 CHARACTER CRC-CCITT
SPACK5	LD	(HL),0		;STORE A NULL FOR CURRENT END
	PUSH	HL		;SAVE H
	LD	HL,PACKET+1	;POINT TO FIRST CHECKSUMED CHARACTER
	CALL	CRCCLC		;CALCULATE THE CRC
	POP	HL		;RESTORE THE POINTER
	LD	C,E		;GET LOW ORDER HALF FOR LATER
	LD	B,D		;COPY THE HIGH ORDER
	LD	A,D		;GET THE HIGH ORDER PORTION
	RLCA			;SHIFT OFF LOW 4 BITS
	RLCA			;.  .  .
	RLCA			;.  .  .
	RLCA			;.  .  .
	AND	0FH		;KEEP ONLY LOW 4 BITS
	ADD	A,' '		;PUT INTO PRINTING RANGE
	LD	(HL),A		;STORE THE CHARACTER
	INC	HL		;POINT TO NEXT POSITION
;HERE FOR TWO CHARACTER CHECKSUM
SPACK4	LD	A,B		;GET HIGH ORDER PORTION
	AND	0FH		;ONLY KEEP LAST FOUR BITS
	RLCA			;SHIFT UP TWO BITS
	RLCA			;. .  .
	LD	B,A		;COPY BACK INTO SAFE PLACE
	LD	A,C		;GET LOW ORDER HALF
	RLCA			;SHIFT HIGH TWO BITS
	RLCA			;TO LOW TWO BITS
	AND	03H		;KEEP ONLY TWO LOW BITS
	OR	B		;GET HIGH ORDER PORTION IN
	ADD	A,' '		;CONVERT TO PRINTING CHARACTER RANGE
	LD	(HL),A		;STORE THE CHARACTER
	INC	HL		;POINT TO NEXT CHARACTER
	LD	A,C		;GET LOW ORDER PORTION
	AND	3FH		;KEEP ONLY SIX BITS
	ADD	A,' '		;CONVERT TO PRINTING RANGE
	LD	(HL),A		;STORE IT
	INC	HL		;BUMP THE POINTER
SPACK7	LD	A,(SEOL)	;GET THE EOL THE OTHER HOST WANTS.
	LD	(HL),A		;PUT IN THE PACKET.
	INC	HL		;bump pointer
	XOR	A		;terminate packet
	LD	(HL),A		;with null.
	LD	A,(DBFLG)
	OR	A
	JR	Z,SPACK8	;debug is off
;;	INC	HL		;POINT TO NEXT CHAR.
;;	LD	A,'$'		;GET A DOLLAR SIGN.
;;	LD	(HL),A		;PUT IN THE PACKET.
SPACK8	CALL	OUTPKT		;CALL THE SYSTEM DEPENDENT ROUTINE.
	JP	QUIT
	JP	RSKP
;	WRITE OUT A PACKET.
OUTPKT	LD	A,(SPAD)	;GET THE NUMBER OF PADDING CHARS.
	LD	(TEMP1),A
OUTPK2	LD	A,(TEMP1)	;GET THE COUNT.
	DEC	A
	OR	A
	JP	M,OUTPK6	;IF NONE LEFT PROCEED.
	LD	(TEMP1),A
	LD	A,(SPADCH)	;GET THE PADDING CHAR.
	LD	E,A		;PUT THE CHAR IN RIGHT AC.
	CALL	OUTCHR		;OUTPUT IT.
	JP	OUTPK2
OUTPK6	LD	A,(IBMFLG)	;IS THIS THE (DUMB) IBM.
	OR	A
	JP	Z,OUTPK8	;IF NOT THEN PROCEED.
	LD	A,(STATE)	;CHECK IF THIS IS THE SEND-INIT PACKET.
	CP	'S'
;* THIS WILL ALSO HAVE TO BE TAKEN CARE FOR 'R' (RECEIVE), 'G' (GENERIC)
;* AND 'C' (COMMAND) PACKETS IF THE IBM BECOMES A SERVER.
	JP	Z,OUTPK8	;IF SO DON'T WAIT FOR THE XON.
OUTPK7	CALL	INCHR		;WAIT FOR THE TURN AROUND CHAR.
	JP	OUTPK8
	CP	XON		;IS IT THE IBM TURN AROUND CHARACTER?
	JP	NZ,OUTPK7	;IF NOT, GO UNTIL IT IS.
OUTPK8	LD	A,(DBFLG)
	OR	A
	JR	Z,OUTPK9
;;	LD	DE,SPPOS	;posn cursor.
;;
;;	CALL	PRTSTR
;;	LD	DE,PACKET+1
;;	CALL	PRTSTR
;Above packed debug code had heavy bugs. Now replaced
;by neater & cleaner Trs-80 specific code......
	LD	HL,3E10H	;cursor for send packet
	LD	DE,PACKET	;soh included
OUTPK8A	LD	A,(DE)		;loop writing to screen.
	OR	A
	JR	Z,OUTPK9
	LD	(HL),A
	INC	HL
	INC	DE
	JR	OUTPK8A
;
OUTPK9
	LD	(HL),255	;signal end of packet
	LD	HL,PACKET
OUTLUP	LD	A,(HL)		;GET THE NEXT CHARACTER.
	OR	A		;IS IT A NULL?
	JP	Z,OUTLUD	;IF SO RETURN SUCCESS.
	LD	E,A		;PUT THE CHAR IN RIGHT AC.
	CALL	OUTCHR		;OUTPUT THE CHARACTER.
	INC	HL		;INCREMENT THE CHAR POINTER.
	JP	OUTLUP
OUTLUD	JP	RSKP		;JUST RETURN
;THIS ROUTINE WAITS FOR A PACKET TO ARRIVE FROM THE HOST.  IT READS
;CHARACTERS UNTIL IT FINDS A SOH.  IT THEN READS THE PACKET INTO PACKET.
;
;RETURNS:  +1 FAILURE (IF THE CHECKSUM IS WRONG OR THE PACKET TRASHED)
;	    +2 SUCCESS WITH A        - MESSAGE TYPE
;			    ARGBLK   - MESSAGE NUMBER
;                           ARGBLK+1 - LENGTH OF DATA
RPACK	CALL	INPKT		;READ UP TO A CARRIAGE RETURN.
	JP	QUIT		;RETURN BAD.
RPACK0	CALL	GETCHR		;GET A CHARACTER.
	JP	RPACK		;HIT A CR;NULL LINE; JUST START OVER.
	CP	SOH		;IS THE CHAR THE START OF HEADER CHAR?
	JR	NZ,RPACK0	;NO, GO UNTIL IT IS.
RPACK1	CALL	GETCHR		;GET A CHARACTER.
	JP	QUIT		;HIT THE CARRIAGE RETURN, RETURN BAD.
	CP	SOH		;IS THE CHAR THE START OF HEADER CHAR?
	JR	Z,RPACK1	;YES, THEN GO START OVER.
	LD	(PACKET+1),A	;STORE IN PACKET ALSO
	LD	C,A		;START THE CHECKSUM.
	LD	A,(CURCHK)	;GET BLOCK CHECK TYPE
	SUB	'1'		;DETERMINE EXTRA LENGTH OF BLOCK CHECK
	LD	B,A		;GET A COPY
	LD	A,C		;GET BACK LENGTH CHARACTER
	SUB	' '+3		;GET THE REAL DATA COUNT.
	SUB	B		;GET TOTAL LENGTH
	LD	(ARGBLK+1),A
	LD	B,0		;CLEAR HIGH ORDER HALF OF CHECKSUM
	CALL	GETCHR		;GET A CHARACTER.
	JP	QUIT		;HIT THE CARRIAGE RETURN, RETURN BAD.
	CP	SOH		;IS THE CHAR THE START OF HEADER CHAR?
	JR	Z,RPACK1	;YES, THEN GO START OVER.
	LD	(ARGBLK),A
	LD	(PACKET+2),A	;SAVE ALSO IN PACKET
	ADD	A,C
	LD	C,A		;ADD THE CHARACTER TO THE CHECKSUM.
	LD	A,0		;CLEAR A
	ADC	A,B		;GET HIGH ORDER PORTION OF CHECKSUM
	LD	B,A		;COPY BACK TO B
	LD	A,(ARGBLK)
	SUB	' '		;GET THE REAL PACKET NUMBER.
	LD	(ARGBLK),A
	CALL	GETCHR		;GET A CHARACTER.
	JP	QUIT		;HIT THE CARRIAGE RETURN, RETURN BAD.
	CP	SOH		;IS THE CHAR THE START OF HEADER CHAR?
	JP	Z,RPACK1	;YES, THEN GO START OVER.
	LD	(TEMP1),A	;SAVE THE MESSAGE TYPE.
	LD	(PACKET+3),A	;SAVE IN PACKET
	ADD	A,C
	LD	C,A		;ADD THE CHARACTER TO THE CHECKSUM.
	LD	A,0		;CLEAR A
	ADC	A,B		;GET HIGH ORDER PORTION OF CHECKSUM
	LD	B,A		;COPY BACK TO B
	LD	A,(ARGBLK+1)	;GET THE NUMBER OF DATA CHARACTERS.
	LD	(TEMP2),A
	LD	HL,DATA		;POINT TO THE DATA BUFFER.
	LD	(DATPTR),HL
RPACK2	LD	A,(TEMP2)
	SUB	1		;ANY DATA CHARACTERS?
	JP	M,RPACK3	;IF NOT GO GET THE CHECKSUM.
	LD	(TEMP2),A
	CALL	GETCHR		;GET A CHARACTER.
	JP	QUIT		;HIT THE CARRIAGE RETURN, RETURN BAD.
	CP	SOH		;IS THE CHAR THE START OF HEADER CHAR?
	JP	Z,RPACK1	;YES, THEN GO START OVER.
	LD	HL,(DATPTR)
	LD	(HL),A		;PUT THE CHAR INTO THE PACKET.
	INC	HL		;POINT TO THE NEXT CHARACTER.
	LD	(DATPTR),HL
	ADD	A,C
	LD	C,A		;ADD THE CHARACTER TO THE CHECKSUM.
	LD	A,0		;CLEAR A
	ADC	A,B		;GET HIGH ORDER PORTION OF CHECKSUM
	LD	B,A		;COPY BACK TO B
	JR	RPACK2		;GO GET ANOTHER.
RPACK3	CALL	GETCHR		;GET A CHARACTER.
	JP	QUIT		;HIT THE CARRIAGE RETURN, RETURN BAD.
	CP	SOH		;IS THE CHAR THE START OF HEADER CHAR?
	JP	Z,RPACK1	;YES, THEN GO START OVER.
	SUB	' '		;TURN THE CHAR BACK INTO A NUMBER.
	LD	(TEMP3),A
;DETERMINE TYPE OF CHECKSUM
	LD	A,(CURCHK)	;GET THE CURRENT CHECKSUM TYPE
	CP	'2'		;1, 2 OR 3 CHARACTER?
	JP	Z,RPACK4	;IF ZERO, 2 CHARACTER
	JP	NC,RPACK5	;GO HANDLE 3 CHARACTER
	LD	A,C		;GET THE CHARACTER TOTAL.
	AND	0C0H		;TURN OFF ALL BUT THE TWO HIGH ORDER BITS.
	RLCA			;TWO LEFT ROTATES SAME AS SIX RIGHTS
	RLCA			;.  .  .
	ADD	A,C		;ADD IT TO THE OLD BITS.
	AND	3FH		;TURN OFF THE TWO HIGH ORDER BITS.  (MOD 64)
	LD	B,A
	LD	A,(TEMP3)	;GET THE REAL RECEIVED CHECKSUM.
	CP	B		;ARE THEY EQUAL?
	JP	Z,RPACK7	;IF SO, PROCEED.
RPACK9	CALL	UPDRTR		;IF NOT, UPDATE THE NUMBER OF RETRIES.
	RET			;RETURN ERROR.
;HERE FOR THREE CHARACTER CRC-CCITT
RPACK5	LD	HL,(DATPTR)	;GET THE ADDRESS OF THE DATA
	LD	(HL),0		;STORE A ZERO IN THE BUFFER TO TERMINATE PACKET
	LD	HL,PACKET+1	;POINT AT START OF CHECKSUMMED REGION
	CALL	CRCCLC		;CALCULATE THE CRC
	LD	C,E		;SAVE LOW ORDER HALF FOR LATER
	LD	B,D		;ALSO COPY HIGH ORDER
	LD	A,D		;GET HIGH BYTE
	RLCA			;WANT HIGH FOUR BITS
	RLCA			;.  .  .
	RLCA			;AND SHIFT TWO MORE
	RLCA			;.  .  .
	AND	0FH		;KEEP ONLY 4 BITS
	LD	D,A		;BACK INTO D
	LD	A,(TEMP3)	;GET FIRST VALUE BACK
	CP	D		;CORRECT?
	JR	NZ,RPACK9	;NO, PUNT
	CALL	GETCHR		;GET A CHARACTER.
	JP	QUIT		;HIT THE CARRIAGE RETURN, RETURN BAD.
	CP	SOH		;IS THE CHAR THE START OF HEADER CHAR?
	JP	Z,RPACK1	;YES, THEN GO START OVER.
	SUB	' '		;REMOVE SPACE OFFSET
	LD	(TEMP3),A	;STORE FOR LATER CHECK
;HERE FOR A TWO CHARACTER CHECKSUM AND LAST TWO CHARACTERS OF CRC
RPACK4	LD	A,B		;GET HIGH ORDER PORTION
	AND	0FH		;ONLY FOUR BITS
	RLCA			;SHIFT UP TWO BITS
	RLCA			;.  .  .
	LD	B,A		;SAVE BACK IN B
	LD	A,C		;GET LOW ORDER
	RLCA			;MOVE TWO HIGH BITS TO LOW BITS
	RLCA			;.  .  .
	AND	03H		;SAVE ONLY LOW TWO BITS
	OR	B		;GET OTHER 4 BITS
	LD	B,A		;SAVE BACK IN B
	LD	A,(TEMP3)	;GET THIS PORTION OF CHECKSUM
	CP	B		;CHECK FIRST HALF
	JP	NZ,RPACK9	;IF BAD, GO GIVE UP
	CALL	GETCHR		;GET A CHARACTER.
	JP	QUIT		;HIT THE CARRIAGE RETURN, RETURN BAD.
	CP	SOH		;IS THE CHAR THE START OF HEADER CHAR?
	JP	Z,RPACK1	;YES, THEN GO START OVER.
	SUB	' '		;REMOVE SPACE OFFSET
	LD	B,A		;SAVE IN SAFE PLACE
	LD	A,C		;GET LOW 8 BITS OF CHECKSUM
	AND	3FH		;KEEP ONLY 6 BITS
	CP	B		;CORRECT VALUE
	JP	NZ,RPACK9	;BAD, GIVE UP
RPACK7	LD	HL,(DATPTR)
	LD	(HL),0		;PUT A NULL AT THE END OF THE DATA.
	LD	A,(TEMP1)	;GET THE TYPE.
	JP	RSKP
INPKT	LD	HL,RECPKT	;POINT TO THE BEGINNING OF THE PACKET.
	LD	(PKTPTR),HL
INPKT2	CALL	INCHR		;GET A CHARACTER.
	JP	QUIT		;RETURN FAILURE.
	LD	HL,(PKTPTR)
	LD	(HL),A		;PUT THE CHAR IN THE PACKET.
	INC	HL
	LD	(PKTPTR),HL
	LD	B,A
	LD	A,(REOL)	;GET THE EOL CHAR.
	CP	B
	JR	NZ,INPKT2
	LD	A,(DBFLG)
	OR	A
	JR	Z,INPKT3	;DEBUG MODE IS OFF
;
;Append a null to the packet.
	LD	(HL),0
;
;;	LD	A,'$'		;GET A DOLLAR SIGN.
;;	LD	(HL),A		;PUT IN THE PACKET.
;;	INC	HL		;POINT TO NEXT CHAR.
;;	LD	DE,RPPOS	;PRINT THE PACKET
;;	CALL	PRTSTR
;;	LD	DE,RECPKT+1
;;	CALL	PRTSTR
;New method of printing out received contents.
	LD	HL,3D46H
	LD	DE,RECPKT	;Soh included
INPKT2A	LD	A,(DE)
	OR	A
	JR	Z,INPKT3
	LD	(HL),A
	INC	HL
	INC	DE
	JR	INPKT2A
;
INPKT3	LD	(HL),255	;signal end packet
	LD	HL,RECPKT
	LD	(PKTPTR),HL	;SAVE THE PACKET POINTER.
	JP	RSKP		;IF SO WE ARE DONE.
GETCHR	LD	HL,(PKTPTR)	;GET THE PACKET POINTER.
	LD	A,(HL)		;GET THE CHAR.
	INC	HL
	LD	(PKTPTR),HL
	CP	CR		;IS IT THE CARRIAGE RETURN?
	JP	NZ,RSKP		;IF NOT RETURN RETSKP.
	RET			;IF SO RETURN FAILURE.
;
;THIS ROUTINE WILL CALCULATE A CRC USING THE CCITT POLYNOMIAL FOR
;A STRING.
;
;USAGE:
;	HL/ ADDRESS OF STRING
;	A/  LENGTH OF STRING
;	CALL CRCCLC
;
;16-BIT CRC VALUE IS RETURNED IN DE.
;
;REGISTERS BC AND HL ARE PRESERVED.
;
CRCCLC	PUSH	HL		;SAVE HL
	PUSH	BC		;AND BC
	LD	DE,0		;INITIAL CRC VALUE IS 0
CRCCL0	LD	A,(HL)		;GET A CHARACTER
	OR	A		;CHECK IF ZERO
	JP	Z,CRCCL1	;IF SO, ALL DONE
	PUSH	HL		;SAVE THE POINTER
	XOR	E		;ADD IN WITH PREVIOUS VALUE
	LD	E,A		;GET A COPY
	AND	0FH		;GET LAST 4 BITS OF COMBINED VALUE
	LD	C,A		;GET INTO C
	LD	B,0		;AND MAKE HIGH ORDER ZERO
	LD	HL,CRCTB2	;POINT AT LOW ORDER TABLE
	ADD	HL,BC		;POINT TO CORRECT ENTRY
	ADD	HL,BC		;.  .  .
	PUSH	HL		;SAVE THE ADDRESS
	LD	A,E		;GET COMBINED VALUE BACK AGAIN
	RRCA			;SHIFT OVER TO MAKE INDEX
	RRCA			;.  .  .
	RRCA			;.  .  .
	AND	1EH		;KEEP ONLY 4 BITS
	LD	C,A		;SET UP TO OFFSET TABLE
	LD	HL,CRCTAB	;POINT AT HIGH ORDER TABLE
	ADD	HL,BC		;CORRECT ENTRY
	LD	A,(HL)		;GET LOW ORDER PORTION OF ENTRY
	XOR	D		;XOR   US HIGH ORDER HALF
	INC	HL		;POINT TO HIGH ORDER BYTE
	LD	D,(HL)		;GET INTO D
	POP	HL		;GET BACK POINTER TO OTHER TABLE ENTRY
	XOR	(HL)		;INCLUDE WITH NEW HIGH ORDER HALF
	LD	E,A		;COPY NEW LOW ORDER PORTION
	INC	HL		;POINT TO OTHER PORTION
	LD	A,(HL)		;GET THE OTHER PORTION OF THE TABLE ENTRY
	XOR	D		;INCLUDE WITH OTHER HIGH ORDER PORTION
	LD	D,A		;MOVE BACK INTO D
	POP	HL		;AND H
	INC	HL		;POINT TO NEXT CHARACTER
	JP	CRCCL0		;GO GET NEXT CHARACTER
CRCCL1	POP	BC		;RESTORE B
	POP	HL		;AND HL
	RET			;AND RETURN, DE=CRC-CCITT
CRCTAB	DW	00000H
	DW	01081H
	DW	02102H
	DW	03183H
	DW	04204H
	DW	05285H
	DW	06306H
	DW	07387H
	DW	08408H
	DW	09489H
	DW	0A50AH
	DW	0B58BH
	DW	0C60CH
	DW	0D68DH
	DW	0E70EH
	DW	0F78FH
CRCTB2	DW	00000H
	DW	01189H
	DW	02312H
	DW	0329BH
	DW	04624H
	DW	057ADH
	DW	06536H
	DW	074BFH
	DW	08C48H
	DW	09DC1H
	DW	0AF5AH
	DW	0BED3H
	DW	0CA6CH
	DW	0DBE5H
	DW	0E97EH
	DW	0F8F7H
;
