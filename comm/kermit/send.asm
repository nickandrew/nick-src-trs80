;send/asm.
;	SEND COMMAND
SEND	PUSH	BC
	PUSH	HL
	LD	B,7AH
	LD	HL,MFNBUF
SEND0	LD	(HL),20H
	INC	HL
	DJNZ	SEND0
	POP	HL
	POP	BC
	LD	A,CMTXT		;PARSE AN INPUT FILE SPEC.
	LD	DE,MFNBUF	;GIVE THE ADDRESS FOR THE FCB.
	CALL	COMND
	JP	KERMIT		;GIVE UP ON BAD PARSE.
SEND1	LD	A,CMCFM
	CALL	COMND		;GET A CONFIRM.
	JP	KERMIT		;DIDN'T GET A CONFIRM.
SEND11	LD	HL,MFNBUF
	LD	(MFNPTR),HL
	CALL	MFNAME		;HANDLE (MULTI) FILES
	JR	NC,SEND14	;GOT A VALID FILE-NAME
	LD	DE,ERMS15
	CALL	ERROR3		;DISPLAY ERROR MSG.
	JP	KERMIT
SEND14	CALL	INIT		;CLEAR THE LINE AND INITIALIZE THE BUFFERS.
	XOR	A
	LD	(PKTNUM),A	;SET THE PACKET NUMBER TO ZERO.
	LD	(NUMTRY),A	;SET THE NUMBER OF TRIES TO ZERO.
	LD	HL,0
	LD	(NUMPKT),HL	;SET THE NUMBER OF PACKETS TO ZERO.
	LD	(NUMRTR),HL	;SET THE NUMBER OF RETRIES TO ZERO.
	LD	DE,SCRNRT	;POSITION CURSOR
	CALL	PRTSTR
	LD	HL,0
	CALL	NOUT		;WRITE THE NUMBER OF RETRIES.
	LD	A,'1'		;RESET TO USE SINGLE CHARACTER CHECKSUM
	LD	(CURCHK),A	;FOR STARTUP
	LD	A,'S'
	LD	(STATE),A	;SET THE STATE TO RECEIVE INITIATE.
;SEND STATE TABLE SWITCHER
SEND2	LD	DE,SCRNP	;POSITION CURSOR
	CALL	PRTSTR
	LD	HL,(NUMPKT)
	CALL	NOUT		;WRITE THE PACKET NUMBER.
	LD	A,(STATE)	;GET THE STATE.
	CP	'D'		;ARE WE IN THE DATA SEND STATE?
	JR	NZ,SEND3
	CALL	SDATA
	JP	SEND2
SEND3	CP	'F'		;ARE WE IN THE FILE SEND STATE?
	JR	NZ,SEND4
	CALL	SFILE		;CALL SEND FILE.
	JP	SEND2
SEND4	CP	'Z'		;ARE WE IN THE EOF STATE?
	JR	NZ,SEND5
	CALL	SEOF
	JP	SEND2
SEND5	CP	'S'		;ARE WE IN THE SEND INITIATE STATE?
	JR	NZ,SEND6
	CALL	SINIT
	JP	SEND2
SEND6	CP	'B'		;ARE WE IN THE EOT STATE?
	JR	NZ,SEND7
	CALL	SEOT
	JP	SEND2
SEND7	CP	'C'		;ARE WE IN THE SEND COMPLETE STATE?
	JR	NZ,SEND8	;NO...
	LD	DE,INFMS3	;YES, WRITE "COMPLETE" MESSAGE.
	LD	A,(CZSEEN)
	OR	A		;.  .  .
	JR	Z,SEND7A	;NO.
	LD	DE,INMS13	;YES, THEN SAY "INTERRUPTED" INSTEAD.
SEND7A	CALL	FINMES
	JP	KERMIT
SEND8	CP	'A'		;ARE WE IN THE SEND "ABORT" STATE?
	JR	NZ,SEND9
	LD	DE,INFMS4	;PRINT MESSAGE.
	CALL	FINMES
	JP	KERMIT
SEND9	LD	DE,INFMS4	;ANYTHING ELSE IS EQUIVALENT TO "ABORT".
	CALL	FINMES
	JP	KERMIT
;
;	SEND ROUTINES
;	SEND INITIATE
;********************************************************
SINIT	LD	A,(NUMTRY)	;GET THE NUMBER OF TRIES.
	CP	IMXTRY		;REACHED THE MAXIMUM NUMBER OF TRIES?
	JP	M,SINIT2
	LD	DE,ERMS14
	CALL	ERROR3		;DISPLAY ERMSG
	JP	ABORT		;CHANGE THE STATE TO ABORT.
SINIT2	INC	A		;INCREMENT IT.
	LD	(NUMTRY),A	;SAVE THE UPDATED NUMBER OF TRIES.
	LD	A,'1'		;RESET TO USE SINGLE CHARACTER CHECKSUM
	LD	(CURCHK),A	;FOR STARTUP
	LD	A,(CHKTYP)	;GET OUR DESIRED BLOCK CHECK TYPE
	LD	(INICHK),A
;
;This place is where you would want to set up the
;values for the defaults in the send initiate packet.
;
	LD	HL,DATA		;GET A POINTER TO OUR DATA BLOCK.
;******              ***********************************
	CALL	RPAR		;SET UP THE PARAMETER INFORMATION.
;****** ^^^^^^^^^^^^ ***********************************
	LD	(ARGBLK+1),A	;SAVE THE NUMBER OF ARGUMENTS.
	LD	A,(NUMPKT)	;GET THE PACKET NUMBER.
	LD	(ARGBLK),A
	LD	A,'S'		;SEND INITIATE PACKET.
	CALL	SPACK		;SEND THE PACKET.
	JP	ABORT		;FAILED, ABORT.
	CALL	RPACK		;GET A PACKET.
	JP	QUIT		;TRASHED PACKET DON'T CHANGE STATE, RETRY.
	CP	'Y'		;ACK?
	JP	NZ,SINIT3	;IF NOT TRY NEXT.
	LD	A,(PKTNUM)	;GET THE PACKET NUMBER.
	LD	B,A
	LD	A,(ARGBLK)
	CP	B		;IS IT THE RIGHT PACKET NUMBER?
	RET	NZ		;IF NOT TRY AGAIN.
	INC	A		;INCREMENT THE PACKET NUMBER.
	AND	3FH		;TURN OFF THE TWO HIGH ORDER BITS.
	LD	(PKTNUM),A	;SAVE MODULO 64 OF THE NUMBER.
	LD	HL,(NUMPKT)
	INC	HL		;INCREMENT THE NUMBER OF PACKETS.
	LD	(NUMPKT),HL
	LD	A,(ARGBLK+1)	;GET THE NUMBER OF PIECES OF DATA.
	LD	HL,DATA		;POINTER TO THE DATA.
;******              ***********************************
	CALL	SPAR		;READ IN THE DATA.
;****** ^^^^^^^^^^^^ ***********************************
	LD	A,(NUMTRY)	;GET THE NUMBER OF TRIES.
	LD	(OLDTRY),A	;SAVE IT.
	XOR	A
	LD	(NUMTRY),A	;RESET THE NUMBER OF TRIES.
	LD	A,(INICHK)	;GET THE AGREED UPON BLOCK-CHECK-TYPE
	LD	(CURCHK),A	;STORE AS TYPE TO USE FOR PACKETS NOW
	LD	A,'F'		;SET THE STATE TO FILE SEND.
	LD	(STATE),A
	CALL	GETFIL		;OPEN THE FILE.
	JP	ABORT		;SOMETHING IS WRONG, DIE.
	RET
SINIT3	CP	'N'		;NAK?
	JP	NZ,SINIT4	;IF NOT SEE IF ITS AN ERROR.
	CALL	UPDRTR		;UPDATE THE NUMBER OF RETRIES.
	LD	A,(PKTNUM)	;GET THE PRESENT PACKET NUMBER.
	INC	A		;INCREMENT.
	LD	B,A
	LD	A,(ARGBLK)	;GET THE PACKET'S NUMBER.
	CP	B		;IS THE PACKET'S NUMBER ONE MORE THAN NOW?
	RET	NZ		;IF NOT ASSUME ITS FOR THIS PACKET, GO AGAIN.
	XOR	A
	LD	(NUMTRY),A	;RESET NUMBER OF TRIES.
	LD	A,'F'		;SET THE STATE TO FILE SEND.
	LD	(STATE),A
	RET
SINIT4	CP	'E'		;IS IT AN ERROR PACKET.
	JP	NZ,ABORT
	CALL	ERROR
	JP	ABORT
;	SEND FILE HEADER
SFILE	LD	A,(NUMTRY)	;GET THE NUMBER OF TRIES.
	CP	MAXTRY		;HAVE WE REACHED THE MAXIMUM NUMBER OF TRIES?
	JP	M,SFILE1
	LD	DE,ERMS14
	CALL	ERROR3
	JP	ABORT		;CHANGE THE STATE TO ABORT.
SFILE1	INC	A		;INCREMENT IT.
	LD	(NUMTRY),A	;SAVE THE UPDATED NUMBER OF TRIES.
	XOR	A		;CLEAR A
	LD	(CZSEEN),A
	LD	HL,DATA		;GET A POINTER TO OUR DATA BLOCK.
	LD	(DATPTR),HL	;SAVE IT.
	LD	HL,MFREQ	;get filename
	LD	(FCBPTR),HL	;SAVE POSITION IN FCB.
	LD	B,0		;NO CHARS YET.
	LD	C,0
SFIL11	LD	A,B
;Mod by nick. remove klugdy '.' insertion after char 8.
	JP	SFIL12
;
;;	CP	8H		;IS THIS THE NINTH CHAR?
;;	JP	NZ,SFIL12	;IF NOT PROCEED.
SFL11A	LD	A,'.'		;GET A DOT.
	LD	HL,(DATPTR)
	LD	(HL),A		;PUT THE CHAR IN THE DATA PACKET.
	INC	HL
	LD	(DATPTR),HL	;SAVE POSITION IN DATA PACKET.
	LD	B,8
	INC	C
SFIL12	INC	B		;INCREMENT THE COUNT.
	LD	A,B
	CP	0CH		;TWELVE?
	JP	P,SFIL13
	LD	HL,(FCBPTR)
	LD	A,(HL)
	AND	7FH		;TURN OFF CP/M 2 OR 3'S HIGH BITS.[UTK013]
	INC	HL
	LD	(FCBPTR),HL	;SAVE POSITION IN FCB.
	CP	'!'		;IS IT A GOOD CHARACTER?
	JP	M,SFIL13
	LD	HL,(DATPTR)
	CP	'/'		;extension?
	JP	Z,SFL11A
	CP	':'		;drive spec?
	JR	Z,SFIL13
SFL12A	LD	(HL),A		;PUT THE CHAR IN THE DATA PACKET.
	INC	HL
	LD	(DATPTR),HL	;SAVE POSITION IN DATA PACKET.
	INC	C
	JP	SFIL11		;GET ANOTHER.
SFIL13	LD	A,C		;NUMBER OF CHAR IN FILE NAME.
	LD	(ARGBLK+1),A
	LD	HL,(DATPTR)
	LD	A,'$'
	LD	(HL),A		;PUT IN A DOLLAR SIGN FOR PRINTING.
	LD	DE,SCRFLN	;POSITION CURSOR
	CALL	PRTSTR
	LD	DE,DATA		;PRINT THE FILE NAME
	CALL	PRTSTR
	LD	A,(PKTNUM)	;GET THE PACKET NUMBER.
	LD	(ARGBLK),A
	LD	A,'F'		;FILE HEADER PACKET.
	CALL	SPACK		;SEND THE PACKET.
	JP	ABORT		;FAILED, ABORT.
	CALL	RPACK		;GET A PACKET.
	JP	QUIT		;TRASHED PACKET DON'T CHANGE STATE, RETRY.
	CP	'Y'		;ACK?
	JP	NZ,SFILE2	;IF NOT TRY NEXT.
	LD	A,(PKTNUM)	;GET THE PACKET NUMBER.
	LD	B,A
	LD	A,(ARGBLK)
	CP	B		;IS IT THE RIGHT PACKET NUMBER?
	RET	NZ		;IF NOT HOLD OUT FOR THE RIGHT ONE.
SFIL14	INC	A		;INCREMENT THE PACKET NUMBER.
	AND	3FH		;TURN OFF THE TWO HIGH ORDER BITS.
	LD	(PKTNUM),A	;SAVE MODULO 64 OF THE NUMBER.
	LD	HL,(NUMPKT)
	INC	HL		;INCREMENT THE NUMBER OF PACKETS.
	LD	(NUMPKT),HL
	LD	A,(NUMTRY)	;GET THE NUMBER OF TRIES.
	LD	(OLDTRY),A	;SAVE IT.
	XOR	A
	LD	(NUMTRY),A	;RESET THE NUMBER OF TRIES.
SFIL15	XOR	A		;GET A ZERO.
	LD	(EOFLAG),A	;INDICATE NOT EOF.
	LD	A,0FFH
	LD	(FILFLG),A	;INDICATE FILE BUFFER EMPTY.
	CALL	GTCHR
	JP	SFIL16		;ERROR GO SEE IF ITS EOF.
	JP	SFIL17		;GOT THE CHARS, PROCEED.
SFIL16	CP	0FFH		;IS IT EOF?
	JP	NZ,ABORT	;IF NOT GIVE UP.
	LD	A,'Z'		;SET THE STATE TO EOF.
	LD	(STATE),A
	RET
SFIL17	LD	(SIZE),A	;SAVE THE SIZE OF THE DATA GOTTEN.
	LD	A,'D'		;SET THE STATE TO DATA SEND.
	LD	(STATE),A
	RET
SFILE2	CP	'N'		;NAK?
	JP	NZ,SFILE3	;TRY IF ERROR PACKET.
	CALL	UPDRTR		;UPDATE THE NUMBER OF RETRIES.
	LD	A,(PKTNUM)	;GET THE PRESENT PACKET NUMBER.
	INC	A		;INCREMENT.
	LD	B,A
	LD	A,(ARGBLK)	;GET THE PACKET'S NUMBER.
	CP	B		;IS THE PACKET'S NUMBER ONE MORE THAN NOW?
	RET	NZ		;IF NOT GO TRY AGAIN.
	JP	SFIL14		;JUST AS GOOD AS A ACK;GO TO THE ACK CODE.
SFILE3	CP	'E'		;IS IT AN ERROR PACKET.
	JP	NZ,ABORT
	CALL	ERROR
	JP	ABORT
;	SEND DATA
SDATA	LD	A,(NUMTRY)	;GET THE NUMBER OF TRIES.
	CP	MAXTRY		;HAVE WE REACHED THE MAXIMUM NUMBER OF TRIES?
	JP	M,SDATA1
	LD	DE,ERMS14
	CALL	ERROR3
	JP	ABORT		;CHANGE THE STATE TO ABORT.
SDATA1	INC	A		;INCREMENT IT.
	LD	(NUMTRY),A	;SAVE THE UPDATED NUMBER OF TRIES.
	LD	HL,DATA		;GET A POINTER TO OUR DATA BLOCK.
	LD	(DATPTR),HL	;SAVE IT.
	LD	HL,FILBUF	;POINTER TO CHARS TO BE SENT.
	LD	(CBFPTR),HL	;SAVE POSITION IN CHAR BUFFER.
	LD	B,1		;FIRST CHAR.
SDAT11	LD	HL,(CBFPTR)
	LD	A,(HL)
	INC	HL
	LD	(CBFPTR),HL	;SAVE POSITION IN CHAR BUFFER.
	LD	HL,(DATPTR)
	LD	(HL),A		;PUT THE CHAR IN THE DATA PACKET.
	INC	HL
	LD	(DATPTR),HL	;SAVE POSITION IN DATA PACKET.
	INC	B		;INCREMENT THE COUNT.
	LD	A,(SIZE)	;GET THE NUMBER OF CHARS IN CHAR BUFFER.
	CP	B		;HAVE WE TRANSFERED THAT MANY?
	JP	P,SDAT11	;IF NOT GET ANOTHER.
	LD	A,(SIZE)	;NUMBER OF CHAR IN CHAR BUFFER.
	LD	(ARGBLK+1),A
	LD	A,(PKTNUM)	;GET THE PACKET NUMBER.
	LD	(ARGBLK),A
	LD	A,'D'		;DATA PACKET.
	CALL	SPACK		;SEND THE PACKET.
	JP	ABORT		;FAILED, ABORT.
	CALL	RPACK		;GET A PACKET.
	JP	QUIT		;TRASHED PACKET DON'T CHANGE STATE, RETRY.
	CP	'Y'		;ACK?
	JP	NZ,SDATA2	;IF NOT TRY NEXT.
	LD	A,(PKTNUM)	;GET THE PACKET NUMBER.
	LD	B,A
	LD	A,(ARGBLK)
	CP	B		;IS IT THE RIGHT PACKET NUMBER?
	RET	NZ		;IF NOT HOLD OUT FOR THE RIGHT ONE.
	LD	A,(ARGBLK)	;GET THE PACKET NUMBER BACK
	INC	A		;INCREMENT THE PACKET NUMBER.
	AND	3FH		;TURN OFF THE TWO HIGH ORDER BITS.
	LD	(PKTNUM),A	;SAVE MODULO 64 OF THE NUMBER.
	LD	HL,(NUMPKT)
	INC	HL		;INCREMENT THE NUMBER OF PACKETS.
	LD	(NUMPKT),HL
	LD	A,(NUMTRY)	;GET THE NUMBER OF TRIES.
	LD	(OLDTRY),A	;SAVE IT.
	XOR	A
	LD	(NUMTRY),A	;RESET THE NUMBER OF TRIES.
	LD	A,(ARGBLK+1)	;GET THE DATA LENGTH
	CP	1		;CHECK IF ONLY 1 CHARACTER?
	JP	NZ,SDAT15	;IF NOT, JUST CONTINUE
	LD	A,(DATA)	;GOT ONE CHARACTER, GET IT FROM DATA
	CP	'Z'		;WANT TO ABORT ENTIRE STREAM?
	JR	NZ,SDAT14	;IF NOT, CHECK FOR JUST THIS FILE
	LD	(CZSEEN),A
SDAT14	CP	'X'		;DESIRE ABORT OF CURRENT FILE?
	JR	NZ,SDAT15	;IF NOT, JUST CONTINUE
	LD	(CZSEEN),A
SDAT15	LD	A,(CZSEEN)
	OR	A		;CHECK IF EITHER GIVEN
	JR	Z,SDAT12	;IF NEITHER GIVEN, CONTINUE
	LD	A,'Z'		;CHANGE STATE TO EOF
	LD	(STATE),A	;.  .  .
	RET			;AND RETURN
SDAT12	CALL	GTCHR
	JP	SDAT13		;ERROR GO SEE IF ITS EOF.
	LD	(SIZE),A	;SAVE THE SIZE OF THE DATA GOTTEN.
	RET
SDAT13	CP	0FFH		;IS IT EOF?
	JP	NZ,ABORT	;IF NOT GIVE UP.
	LD	A,'Z'		;SET THE STATE TO EOF.
	LD	(STATE),A
	RET
SDATA2	CP	'N'		;NAK?
	JP	NZ,SDATA3	;SEE IF IS AN ERROR PACKET.
	CALL	UPDRTR		;UPDATE THE NUMBER OF RETRIES.
	LD	A,(PKTNUM)	;GET THE PRESENT PACKET NUMBER.
	INC	A		;INCREMENT.
	LD	B,A
	LD	A,(ARGBLK)	;GET THE PACKET'S NUMBER.
	CP	B		;IS THE PACKET'S NUMBER ONE MORE THAN NOW?
	RET	NZ		;IF NOT GO TRY AGAIN.
	JP	SDAT12		;JUST AS GOOD AS A ACK;GO TO THE ACK CODE.
SDATA3	CP	'E'		;IS IT AN ERROR PACKET.
	JP	NZ,ABORT
	CALL	ERROR
	JP	ABORT
;	SEND EOF
SEOF	LD	A,(NUMTRY)	;GET THE NUMBER OF TRIES.
	CP	MAXTRY		;HAVE WE REACHED THE MAXIMUM NUMBER OF TRIES?
	JP	M,SEOF1
	LD	DE,ERMS14
	CALL	ERROR3
	JP	ABORT		;CHANGE THE STATE TO ABORT.
SEOF1	INC	A		;INCREMENT IT.
	LD	(NUMTRY),A	;SAVE THE UPDATED NUMBER OF TRIES.
	LD	A,(PKTNUM)	;GET THE PACKET NUMBER.
	LD	(ARGBLK),A
	XOR	A
	LD	(ARGBLK+1),A	;NO DATA.
	LD	A,(CZSEEN)
	OR	A		;.  .  .
	JR	Z,SEOF14	;IF NOT ABORTED, JUST KEEP GOING
	LD	A,'D'		;TELL OTHER END TO DISCARD PACKET
	LD	(DATA),A	;STORE IN DATA PORTION
	LD	A,1		;ONE CHARACTER
	LD	(ARGBLK+1),A	;STORE THE LENGTH
SEOF14	LD	A,'Z'		;EOF PACKET.
	CALL	SPACK		;SEND THE PACKET.
	JP	ABORT		;FAILED, ABORT.
	CALL	RPACK		;GET A PACKET.
	JP	QUIT		;TRASHED PACKET DON'T CHANGE STATE, RETRY.
	CP	'Y'		;ACK?
	JR	NZ,SEOF2	;IF NOT TRY NEXT.
	LD	A,(PKTNUM)	;GET THE PACKET NUMBER.
	LD	B,A
	LD	A,(ARGBLK)
	CP	B		;IS IT THE RIGHT PACKET NUMBER?
	RET	NZ		;IF NOT HOLD OUT FOR THE RIGHT ONE.
SEOF12	INC	A		;INCREMENT THE PACKET NUMBER.
	AND	3FH		;TURN OFF THE TWO HIGH ORDER BITS.
	LD	(PKTNUM),A	;SAVE MODULO 64 OF THE NUMBER.
	LD	HL,(NUMPKT)
	INC	HL		;INCREMENT THE NUMBER OF PACKETS.
	LD	(NUMPKT),HL
	LD	A,(NUMTRY)	;GET THE NUMBER OF TRIES.
	LD	(OLDTRY),A	;SAVE IT.
	XOR	A
	LD	(NUMTRY),A	;RESET THE NUMBER OF TRIES.
	LD	DE,FCB
	CALL	@CLOSE
;* CHECK IF SUCCESSFUL
	LD	A,(CZSEEN)
	CP	'Z'		;DESIRE ABORT OF ENTIRE STREAM?
	JR	Z,SEOF13	;IF SO, JUST GIVE UP NOW
	CALL	MFNAME		;GET THE NEXT FILE.
	JR	C,SEOF13	;NO MORE.
	CALL	GETFIL		;AND OPEN IT
	JP	ABORT		;SOMETHING IS WRONG, DIE.
	XOR	A		;CLEAR A
	LD	(CZSEEN),A
	LD	A,'F'		;SET THE STATE TO FILE SEND.
	LD	(STATE),A
	RET
SEOF13	LD	A,'B'		;SET THE STATE TO EOT.
	LD	(STATE),A
	RET
SEOF2	CP	'N'		;NAK?
	JR	NZ,SEOF3	;TRY AND SEE IF ITS AN ERROR PACKET.
	CALL	UPDRTR		;UPDATE THE NUMBER OF RETRIES.
	LD	A,(PKTNUM)	;GET THE PRESENT PACKET NUMBER.
	INC	A		;INCREMENT.
	LD	B,A
	LD	A,(ARGBLK)	;GET THE PACKET'S NUMBER.
	CP	B		;IS THE PACKET'S NUMBER ONE MORE THAN NOW?
	RET	NZ		;IF NOT GO TRY AGAIN.
	JP	SEOF12		;JUST AS GOOD AS A ACK;GO TO THE ACK CODE.
SEOF3	CP	'E'		;ERROR PACKET?
	JP	NZ,ABORT
	CALL	ERROR
	JP	ABORT
;	SEND EOT
SEOT	LD	A,(NUMTRY)	;GET THE NUMBER OF TRIES.
	CP	MAXTRY		;HAVE WE REACHED THE MAXIMUM NUMBER OF TRIES?
	JP	M,SEOT1
	LD	DE,ERMS14
	CALL	ERROR3
	JP	ABORT		;CHANGE THE STATE TO ABORT.
SEOT1	INC	A		;INCREMENT IT.
	LD	(NUMTRY),A	;SAVE THE UPDATED NUMBER OF TRIES.
	LD	A,(PKTNUM)	;GET THE PACKET NUMBER.
	LD	(ARGBLK),A
	XOR	A
	LD	(ARGBLK+1),A	;NO DATA.
	LD	A,'B'		;EOF PACKET.
	CALL	SPACK		;SEND THE PACKET.
	JP	ABORT		;FAILED, ABORT.
	CALL	RPACK		;GET A PACKET.
	JP	QUIT		;TRASHED PACKET DON'T CHANGE STATE, RETRY.
	CP	'Y'		;ACK?
	JR	NZ,SEOT2	;IF NOT TRY NEXT.
	LD	A,(PKTNUM)	;GET THE PACKET NUMBER.
	LD	B,A
	LD	A,(ARGBLK)
	CP	B		;IS IT THE RIGHT PACKET NUMBER?
	RET	NZ		;IF NOT HOLD OUT FOR THE RIGHT ONE.
SEOT12	INC	A		;INCREMENT THE PACKET NUMBER.
	AND	3FH		;TURN OFF THE TWO HIGH ORDER BITS.
	LD	(PKTNUM),A	;SAVE MODULO 64 OF THE NUMBER.
	LD	HL,(NUMPKT)
	INC	HL		;INCREMENT THE NUMBER OF PACKETS.
	LD	(NUMPKT),HL
	LD	A,(NUMTRY)	;GET THE NUMBER OF TRIES.
	LD	(OLDTRY),A	;SAVE IT.
	XOR	A
	LD	(NUMTRY),A	;RESET THE NUMBER OF TRIES.
	LD	A,'C'		;SET THE STATE TO FILE SEND.
	LD	(STATE),A
	RET
SEOT2	CP	'N'		;NAK?
	JR	NZ,SEOT3	;IS IT ERROR.
	CALL	UPDRTR		;UPDATE THE NUMBER OF RETRIES.
	LD	A,(PKTNUM)	;GET THE PRESENT PACKET NUMBER.
	INC	A		;INCREMENT.
	LD	B,A
	LD	A,(ARGBLK)	;GET THE PACKET'S NUMBER.
	CP	B		;IS THE PACKET'S NUMBER ONE MORE THAN NOW?
	RET	NZ		;IF NOT GO TRY AGAIN.
	JP	SEOT12		;JUST AS GOOD AS A ACK;GO TO THE ACK CODE.
SEOT3	CP	'E'		;IS IT AN ERROR PACKET.
	JP	NZ,ABORT
	CALL	ERROR
	JP	ABORT
