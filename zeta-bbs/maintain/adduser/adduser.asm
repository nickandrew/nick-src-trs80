;Adduser: Add a new user to the user file.
;         Or give a person member status.
;
*GET	DOSCALLS
*GET	EXTERNAL
*GET	ASCII
;
;
	ORG	PROG_START
	DEFW	BASE
	DEFW	THIS_PROG_END
	DEFW	TERM_ABORT
	DEFW	0
;End of program load info.
;
	COM	'<ADDUSER 1.2b 13-Aug-86>'
	ORG	BASE+100H
START	LD	SP,START
	LD	HL,PRIV_1
	BIT	7,(HL)
	JP	Z,EXIT
	LD	HL,M_WHO
	CALL	MESS
	LD	HL,RECD_NAME
	LD	B,23
	CALL	40H
	JP	C,EXIT
	CALL	TERMINATE_S	;Was fix_eos
;
	LD	HL,M_PWD
	CALL	MESS
	LD	HL,RECD_PASS
	LD	B,12
	CALL	40H
	JP	C,EXIT
	CALL	TO_UPPER
	CALL	TERMINATE_S	;fix_eos
;
;Check if name already exists.
	LD	HL,RECD_NAME
	CALL	USER_SEARCH
	JP	Z,EXISTS
	JR	NC,NONEX
ERROR	LD	HL,M_ERROR
	CALL	MESS
	LD	A,130
	JP	TERMINATE
;
NONEX
	LD	HL,M_REG
	CALL	MESS
	LD	HL,RECD_NAME
	LD	DE,$2
	CALL	MESS_0
	LD	HL,M_REG_E
	CALL	MESS
;
	LD	HL,M_REG_2
	CALL	MESS
	LD	HL,RECD_PASS
	LD	DE,$2
	CALL	MESS_0
	LD	HL,M_REG_2E
	CALL	MESS
;
	LD	HL,M_REG_3
	CALL	MESS
	LD	HL,IN_BUFF	;quick register
	LD	B,1
	CALL	40H
	JP	C,EXIT
	LD	A,(HL)
	AND	5FH
	CP	'Y'
	JP	NZ,EXIT
;User-Name and Password OK for registration.
;Basic search.
	CALL	ZERO_SEARCH	;Search for empty.
	JR	Z,ADD_2		;for overwrite only.
	LD	HL,(US_PMAX)
	INC	HL
	LD	(US_PMAX),HL	;should = US_POSN.
			;US_POSN will be used so
		;watch out!
	JP	C,ERROR
;Name must be appended.
	LD	A,L
	OR	A		;if need new hash sector.
	JR	NZ,ADD_2
;OK. Write new hash sector.....
	LD	A,UF_LRL+1
	CALL	MULTIPLY
	LD	DE,US_FCB
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	LD	B,0
ADD_1	XOR	A		;Write 256 zeroes.
	CALL	$PUT
	JP	NZ,ERROR
	DJNZ	ADD_1
ADD_2
;Set hash.
	LD	HL,(US_POSN)	;***
	LD	E,L
	LD	L,0
	LD	A,UF_LRL+1
	CALL	MULTIPLY
	LD	C,E
	LD	DE,US_FCB
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
	LD	A,(US_HASH)
	CALL	$PUT		;Write hash.
	JP	NZ,ERROR
;
;Now write rest of data.
	LD	HL,(US_UMAX)	;highest uid + 1
	INC	HL
	LD	(US_UMAX),HL
;
	LD	HL,(US_POSN)
	PUSH	HL
	INC	H
	LD	L,0
	EX	DE,HL
	POP	HL
	LD	A,UF_LRL
	CALL	MULTIPLY
	LD	A,L
	ADD	A,D
	LD	L,A
	LD	A,0
	ADC	A,H
	LD	H,A
	LD	DE,US_FCB
	CALL	DOS_POS_RBA
;Setup.
;
	LD	A,040H		;Active.
	LD	(UF_STATUS),A
;
	LD	HL,RECD_NAME
	LD	B,24
	LD	DE,UF_NAME
ADD_3	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	ADD_3
;
	LD	HL,RECD_PASS
	LD	B,13
	LD	DE,UF_PASSWD
ADD_4	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	ADD_4
;
	LD	HL,(US_UMAX)
	LD	(UF_UID),HL
;
	LD	HL,0
	LD	(UF_NCALLS),HL
;
	LD	A,(4045H)	;dd
	LD	(UF_LASTCALL),A
	LD	A,(4046H)	;mm
	LD	(UF_LASTCALL+1),A
	LD	A,(4044H)	;yy
	LD	(UF_LASTCALL+2),A
;
	LD	A,1BH		;Priv 1 Visitor
	LD	(UF_PRIV1),A
	LD	A,0BH		;Priv 2 Visitor
	LD	(UF_PRIV2),A
	XOR	A
	LD	(UF_PRIV3),A
;
	XOR	A
	LD	(UF_TDATA),A
;
	LD	A,40H		;Unpaid.
	LD	(UF_REGCOUNT),A
;
	XOR	A
	LD	(UF_BADLOGIN),A
;
	XOR	A
	LD	(UF_TFLAG1),A
	LD	A,0BFH		;CPM type.
	LD	(UF_TFLAG2),A
;
	LD	A,8
	LD	(UF_ERASE),A
	LD	A,18H
	LD	(UF_KILL),A
;
;OK now write the data out....
	LD	HL,US_UBUFF
	LD	B,UF_LRL
	LD	DE,US_FCB
ADD_5	LD	A,(HL)
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	DJNZ	ADD_5
;
;Now update info at start of file.
	LD	BC,1
	LD	DE,US_FCB
	CALL	DOS_POSIT
	JP	NZ,ERROR
”
	CALL	_US_RDREC
	JP	NZ,ERROR
;Update record and write.
	LD	BC,1		;Position fcb.
	LD	DE,US_FCB
	CALL	DOS_POSIT
	JP	NZ,ERROR
;
	LD	HL,(US_PMAX)
	LD	(UF_NCALLS),HL
	LD	HL,(US_UMAX)
	LD	(UF_UID),HL
	LD	HL,US_UBUFF
	LD	B,UF_LRL
ADD_6	LD	A,(HL)
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	DJNZ	ADD_6
;
	LD	DE,US_FCB	;Done!!!
	CALL	DOS_CLOSE
	JP	NZ,ERROR
;
	LD	HL,M_REG_OK	;Finished.
	CALL	MESS
	XOR	A
	JP	TERMINATE
;
MESS	LD	DE,$2
	CALL	MESS_0
	RET
;
EXIT	XOR	A
	JP	TERMINATE	;finish up.
;
MESS_0	LD	A,(HL)
	OR	A
	RET	Z
	CALL	$PUT
	INC	HL
	JR	MESS_0
;
EXISTS	LD	HL,M_EXISTS
	CALL	MESS
	LD	HL,IN_BUFF
	LD	B,1
	CALL	40H
	JP	C,EXIT
	LD	A,(HL)
	AND	5FH
	CP	'Y'
	JP	NZ,EXIT
;Give person full permissions.
;
	LD	A,7FH		;First perms
	LD	(UF_PRIV1),A
	LD	A,09H		;2nd perms
	LD	(UF_PRIV2),A
	LD	A,0		;Is a member.
	LD	(UF_REGCOUNT),A	;All other bytes the same
;
	LD	A,(US_RBA)
	LD	C,A
	LD	HL,(US_RBA+1)
	LD	DE,US_FCB
	CALL	DOS_POS_RBA
	JP	NZ,ERROR
;
	LD	HL,US_UBUFF
	LD	B,UF_LRL
SET_MEM	LD	A,(HL)
	CALL	$PUT
	JP	NZ,ERROR
	INC	HL
	DJNZ	SET_MEM
;Finished.
	CALL	DOS_CLOSE
	JP	NZ,ERROR
	JP	EXIT
;
;
*GET	ROUTINES
;
M_REG	DEFM	'Registering: "',0
M_REG_E	DEFM	'".',CR,0
M_REG_2	DEFM	'With password "',0
M_REG_2E DEFM	'".',CR,0
M_REG_3	DEFM	'Is this correct? (Y/N): ',0
M_REG_OK DEFM	'Register Successful.',CR,0
;
M_WHO	DEFM	'Register who? ',0
M_PWD	DEFM	'With what password? (CR if none): ',0
;
;
M_EXISTS
	DEFM	'User already registered!',CR
	DEFM	'Make him a member? ',0
M_ERROR	DEFM	'USER_SEARCH encountered error!!',CR,0
;
RECD_NAME	DC	24,0
RECD_PASS	DC	13,0
;
;Now all data blocks...
;
IN_BUFF	DEFS	64
;
THIS_PROG_END	EQU	$
;
	END	START
