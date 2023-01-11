;
;HASH: Calculate 8-bit hash of a string
HASH
	LD	C,0
HASH_1	LD	A,(HL)
	OR	A
	JR	Z,HASH_2
	CP	CR
	JR	Z,HASH_2
	XOR	C
	RLCA
	LD	C,A
	INC	HL
	JR	HASH_1
HASH_2	LD	A,C
	OR	A
	JR	NZ,HASH_3	;use 0 = no user here.
	INC	A
HASH_3	LD	C,A
	RET
;
