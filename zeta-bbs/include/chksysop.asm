;chksysop: Check if sysop
;
_CHKSYSOP
	LD	A,(PRIV_1)
	BIT	IS_SYSOP,A
	JR	NZ,$CR2_1
	LD	HL,0
	RET
$CR2_1	LD	HL,1
	RET
;
