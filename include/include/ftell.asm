;ftell: Return in HL lower 2 bytes of NEXT position.
;
_FTELL
;
	LD	HL,2
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,FD_FCBPTR
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	PUSH	DE
	POP	IX
	LD	A,(IX+5)	;Low value
	LD	L,A
;;	LD	(POSBUF_L),A
	LD	A,(IX+10)	;Med value
	LD	H,A
;;	LD	(POSBUF_M),A
;;	LD	A,(IX+11)
;;	LD	(POSBUF_H),A
	RET
;
