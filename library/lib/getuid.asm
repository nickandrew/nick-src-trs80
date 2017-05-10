	COM	'<small c compiler output>'
*MOD
_GETUID:
	DEBUG	'getuid'
	LD	HL,2
	ADD	HL,SP
	CALL	CCGINT
	LD	A,H
	OR	L
	JP	NZ,$?2
	LD	HL,2
	RET
$?2:
	LD	HL,16
	RET
	END
