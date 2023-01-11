;
;COMMON_SEARCH: Search the USERFILE for a particular name.
; This module is common between USER_SEARCH and ZERO_SEARCH.
COMMON_SEARCH
	LD	HL,0
	LD	(US_POSN),HL
;
;Open file if necessary.
	LD	A,(US_FCB)
	BIT	7,A
	JR	NZ,_US_04
	LD	DE,US_FCB
	LD	HL,US_BUFF
	LD	B,0
	CALL	DOS_OPEN_EX
	SCF
	RET	NZ
	LD	A,(US_FCB+1)
	AND	0F8H		;Unprotect
	LD	(US_FCB+1),A
_US_04	LD	A,(US_FCB+1)	;Prevent shrink on write
	OR	0C0H		;and force lrl read.
	LD	(US_FCB+1),A
	LD	BC,1
	LD	DE,US_FCB
	CALL	DOS_POSIT
	SCF
	RET	NZ
	CALL	_US_RDREC
	RET	NZ
	LD	HL,(UF_UID)
	LD	(US_UMAX),HL
	LD	HL,(UF_NCALLS)	;max. rrecno posn.
	LD	(US_PMAX),HL
;
_US_LOOP	LD	DE,(US_POSN)
	LD	HL,(US_PMAX)
	CALL	CPHLDE
	JR	NC,_US_05
	CCF
	RET	;nz
_US_05	LD	HL,(US_POSN)
	LD	A,L
	OR	A
	JR	NZ,_US_06
;
;Read hash sector into buffer.
	LD	A,UF_LRL+1
	CALL	MULTIPLY
	LD	DE,US_FCB
	CALL	DOS_POS_RBA
	SCF
	RET	NZ
	LD	HL,US_HBUFF
	CALL	DOS_READ_SECT	;256 bytes.
	SCF
	RET	NZ
;
_US_06	LD	A,(US_POSN)	;low.
	LD	HL,US_HBUFF
	ADD	A,L
	LD	L,A
	LD	A,0
	ADC	A,H
	LD	H,A
	LD	B,(HL)
	LD	A,(US_ZERO)
	OR	A
	JR	Z,_US_06A
;check if b=0
	XOR	A
	CP	B
	JR	NZ,_US_INC
	JR	_US_07
_US_06A	LD	A,(US_HASH)
	CP	B
	JR	Z,_US_07
;
;Increment position
_US_INC	LD	HL,(US_POSN)
	INC	HL
	LD	(US_POSN),HL
	JR	_US_LOOP
;
_US_07	LD	HL,(US_POSN)
	PUSH	HL
	INC	H
	LD	L,0
	EX	DE,HL
	POP	HL
	LD	A,UF_LRL
	CALL	MULTIPLY
	LD	A,D
	ADD	A,L
	LD	L,A
	LD	A,0
	ADC	A,H
	LD	H,A
;Store RBA in C,L,H form.
	LD	A,C
	LD	(US_RBA),A
	LD	(US_RBA+1),HL
;
	LD	DE,US_FCB
	CALL	DOS_POS_RBA
	SCF
	RET	NZ
	CALL	_US_RDREC
	RET	NZ
	LD	A,(US_ZERO)
	OR	A
	JR	Z,_US_07A
;Bit 6 of (uf_status) must be 0 for Zero else NO GO.
	LD	A,(UF_STATUS)
	BIT	UF_ST_ZERO,A
	JR	NZ,_US_INC
	RET			;is OK. (Z)
_US_07A	LD	A,(UF_STATUS)
	BIT	UF_ST_ZERO,A	;if Z, recd unused.
	JR	Z,_US_INC
	CALL	_US_CHKNM
	RET	Z
	JR	_US_INC
;
_US_RDREC	LD	B,UF_LRL
	LD	HL,US_UBUFF
	LD	DE,US_FCB
_US_08	CALL	$GET
	SCF
	RET	NZ
	LD	(HL),A
	INC	HL
	DJNZ	_US_08
	CP	A
	RET
;
_US_CHKNM	LD	HL,(US_NSTR)
	LD	DE,UF_NAME
_US_09	CALL	CI_CMP
	RET	NZ
	LD	A,(HL)
	OR	A
	RET	Z
	INC	HL
	INC	DE
	JR	_US_09
;
US_POSN		DEFW	0	;Relrecno in ufile
US_HASH		DEFB	0	;Hash for user name.
US_HBUFF	DEFS	256	;Hash codes buffer.
US_RBA		DEFB	0,0,0	;RBA of name start.
US_FCB		DEFM	'USERFILE.ZMS',CR
		DC	32-13,0
US_BUFF		DEFS	256
US_NSTR		DEFW	0	;Name location.
US_UMAX		DEFW	0	;Maximum UID so far
US_PMAX		DEFW	0	;Maximum RRECNO.
;
US_ZERO		DEFB	0	;Zero search flag.
;
*GET	USERFILE		;Data definitions.
;
