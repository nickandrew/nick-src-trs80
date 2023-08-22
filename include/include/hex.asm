; Hexadecimal to ASCII functions

; HEX16(DE,HL): Write the ASCII representation of DE to the 4-byte buffer at HL
; Return: HL = HL + 4
HEX16:
	LD	A,D
	CALL	HEX8
	LD	A,E
	CALL	HEX8
	RET

; HEX8(A,HL): Write the ASCII representation of A to the 2-byte buffer at HL
; This function uses the SRL instruction (Shift Right Logical) to work with
; the high-order 4 bits of 'A'; it might be faster to change the algorithm
; to use RLD or RRD to rotate 4 bits at a time into or out of memory.
; Also check out: DAA
; Return: HL = HL + 2
HEX8:
	LD	B,A
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	CALL	HEX4
	LD	A,B
	CALL	HEX4
	RET

; HEX4(A,HL): Write the ASCII representation of low order 4 bits of A to the 1-byte buffer at HL
; Return: HL = HL + 1
HEX4:
	AND	A,0FH
	CP	10
	JR	C,00001$
	ADD	A,7
00001$
	ADD	A,30H
	LD	(HL),A
	INC	HL
	RET
