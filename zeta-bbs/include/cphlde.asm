;
;CPHLDE: Compare HL to DE.
CPHLDE
	LD	A,H
	CP	D
	RET	NZ
	LD	A,L
	CP	E
	RET