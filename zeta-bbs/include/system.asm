;system : Provide the system(cmd) call.
;Last updated: 14-Jan-88
;
	IF	ZETA.EQ.0
	ERR	'Can only use system() with Zeta'
	ENDIF
;
	IFREF	_SYSTEM
;
_SYSTEM
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	EX	DE,HL
	CALL	CALL_PROG
	LD	L,A
	LD	H,0
	RET
;
	ENDIF	;_system
;
