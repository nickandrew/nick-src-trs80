;
;CI_CMP: Case independent    CP (hl),(de) for Z,NZ
CI_CMP
	LD	A,(DE)
	XOR	(HL)
	RET	Z
	CP	20H
	RET	NZ
	LD	A,(HL)
	RES	5,A	;UC/LC bit
;;	DEC	A	;now 40 to 59h
	CP	41H
	RET	C
	CP	5AH	;59h='Z'=Zero Flag.
	RET	NC
	CP	A
	RET
