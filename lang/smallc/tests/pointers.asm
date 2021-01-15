;/* this code should test all combinations of pointers and operations */
	COM	'<small c compiler output>'
*MOD
;
;char	gc,
_GC:
	DC	1,0
;	*pgc,
_PGC:
	DC	2,0
;	**ppgc;
_PPGC:
	DC	2,0
;
;main(ac,pac,ppac)
;char	ac,
_MAIN:
	DEBUG	'main'
;	*pac,
;	**ppac;
;{
;
;	gc = gc;
	LD	A,(_GC)
	CALL	CCSXT
	LD	A,L
	LD	(_GC),A
;	gc = *pgc;
	LD	HL,(_PGC)
	CALL	CCGCHAR
	LD	A,L
	LD	(_GC),A
;	gc = **ppgc;
	LD	HL,(_PPGC)
	CALL	CCGINT
	CALL	CCGCHAR
	LD	A,L
	LD	(_GC),A
;
;	pgc = pgc;
	LD	HL,(_PGC)
	LD	(_PGC),HL
;	pgc = *ppgc;
	LD	HL,(_PPGC)
	CALL	CCGINT
	LD	(_PGC),HL
;
;	ppgc = ppgc;
	LD	HL,(_PPGC)
	LD	(_PPGC),HL
;
;	gc = ac;
	LD	HL,6
	ADD	HL,SP
	CALL	CCGCHAR
	LD	A,L
	LD	(_GC),A
;	gc = *pac;
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGCHAR
	LD	A,L
	LD	(_GC),A
;	gc = **ppac;
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGINT
	CALL	CCGCHAR
	LD	A,L
	LD	(_GC),A
;
;	pgc = pac;
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	LD	(_PGC),HL
;	pgc = *ppac;
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGINT
	LD	(_PGC),HL
;
;	ppgc = ppac;
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	LD	(_PPGC),HL
;
;/* pointer assignments */
;
;	*pgc = gc;
	LD	HL,(_PGC)
	PUSH	HL
	LD	A,(_GC)
	CALL	CCSXT
	POP	DE
	LD	A,L
	LD	(DE),A
;	*pgc = **ppgc;
	LD	HL,(_PGC)
	PUSH	HL
	LD	HL,(_PPGC)
	CALL	CCGINT
	CALL	CCGCHAR
	POP	DE
	LD	A,L
	LD	(DE),A
;
;	*ppgc = *ppgc;
	LD	HL,(_PPGC)
	PUSH	HL
	LD	HL,(_PPGC)
	CALL	CCGINT
	POP	DE
	CALL	CCPINT
;	*ppgc = ppgc;
	LD	HL,(_PPGC)
	PUSH	HL
	LD	HL,(_PPGC)
	POP	DE
	CALL	CCPINT
;	**ppgc = ppgc;
	LD	HL,(_PPGC)
	CALL	CCGINT
	PUSH	HL
	LD	HL,(_PPGC)
	POP	DE
	LD	A,L
	LD	(DE),A
;	**ppgc = *ppgc;
	LD	HL,(_PPGC)
	CALL	CCGINT
	PUSH	HL
	LD	HL,(_PPGC)
	CALL	CCGINT
	POP	DE
	LD	A,L
	LD	(DE),A
;
;	*gc = ac;
  /\
**** Not a pointer type
	LD	A,(_GC)
	CALL	CCSXT
	PUSH	HL
	LD	HL,8
	ADD	HL,SP
	CALL	CCGCHAR
	POP	DE
	LD	A,L
	LD	(DE),A
;	*gc = *pac;
  /\
**** Not a pointer type
	LD	A,(_GC)
	CALL	CCSXT
	PUSH	HL
	LD	HL,6
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGCHAR
	POP	DE
	LD	A,L
	LD	(DE),A
;	*gc = **ppac;
  /\
**** Not a pointer type
	LD	A,(_GC)
	CALL	CCSXT
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGINT
	CALL	CCGCHAR
	POP	DE
	LD	A,L
	LD	(DE),A
;
;	*pgc = pac;
	LD	HL,(_PGC)
	PUSH	HL
	LD	HL,6
	ADD	HL,SP
	CALL	CCGINT
	POP	DE
	LD	A,L
	LD	(DE),A
;	*pgc = *ppac;
	LD	HL,(_PGC)
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	CALL	CCGINT
	POP	DE
	LD	A,L
	LD	(DE),A
;
;	**ppgc = ppac;
	LD	HL,(_PPGC)
	CALL	CCGINT
	PUSH	HL
	LD	HL,4
	ADD	HL,SP
	CALL	CCGINT
	POP	DE
	LD	A,L
	LD	(DE),A
;}
	RET
;
	END
