;fread( ... )
;Last updated: 28-Sep-87
;
;fread(ptr,sizeof ptr, nitems, ioptr)
;char *ptr;
;int  nitems;
;FILE *ioptr;
_FREAD
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(FR_IO),DE	;ioptr
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	(FR_NI),BC	;nitems
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	(FR_SI),BC	;size
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(FR_PTR),DE	;ptr
	LD	HL,0
	LD	(FR_NREAD),HL
	EX	DE,HL		;hl = ptr
	LD	BC,(FR_NI)
FR_01
	LD	A,B
	OR	C
	JR	Z,FR_99		;Read NITEMS items
	PUSH	BC
;
	LD	BC,(FR_SI)
FR_02
	PUSH	BC
	PUSH	HL
;
	LD	HL,(FR_IO)
	PUSH	HL
	CALL	_FGETC
	POP	IY
;
	LD	A,H
	OR	A
	JR	NZ,FR_98	;Hit EOF
	LD	A,L
;
	LD	HL,(FR_NREAD)
	INC	HL
	LD	(FR_NREAD),HL
;
	POP	HL
	LD	(HL),A
	INC	HL
;
	POP	BC
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,FR_02
;
	POP	BC
	DEC	BC
	JR	FR_01
;
FR_98
	POP	IY
	POP	IY
	POP	IY
FR_99
	LD	HL,(FR_NREAD)
	RET
;
FR_NI	DEFW	0
FR_IO	DEFW	0
FR_SI	DEFW	0
FR_PTR	DEFW	0
FR_NREAD	DEFW	0
